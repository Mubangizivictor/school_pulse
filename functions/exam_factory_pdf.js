// Server-side rendering for Exam Factory question papers and marking guides.
// Mirrors report_card_pdf.js's conventions (A4, pdfkit, institution branding,
// draft/confidential watermarking) so generated exam documents look and
// behave consistently with the rest of the platform's official PDFs.
const PDFDocument = require("pdfkit");

const PAGE = Object.freeze({ left: 48, right: 547, footerTop: 780 });

function text(value, max = 4000) {
  return String(value ?? "").replace(/\r\n/g, "\n").trim().slice(0, max);
}

function rule(pdf, y, color = "#D7DCE8") {
  pdf.strokeColor(color).lineWidth(0.7).moveTo(PAGE.left, y).lineTo(PAGE.right, y).stroke();
}

function watermark(pdf, label) {
  pdf.save();
  pdf.rotate(-30, { origin: [297.5, 421] });
  pdf.fillColor("red", 0.12).font("Helvetica-Bold").fontSize(56).text(label, 60, 380, { width: 480, align: "center" });
  pdf.restore();
}

function header(pdf, { schoolName, examTitle, className, subjectName, durationMinutes, totalMarks, paperCode, version }, y) {
  pdf.fillColor("#102B79").font("Helvetica-Bold").fontSize(15).text(text(schoolName, 90), PAGE.left, y, { width: PAGE.right - PAGE.left, align: "center" });
  pdf.fillColor("#1D2939").font("Helvetica-Bold").fontSize(12).text(text(examTitle, 120), PAGE.left, pdf.y + 6, { width: PAGE.right - PAGE.left, align: "center" });
  pdf.fillColor("#475467").font("Helvetica").fontSize(10).text(`${text(subjectName, 60)} · ${text(className, 60)}`, PAGE.left, pdf.y + 4, { width: PAGE.right - PAGE.left, align: "center" });
  const infoY = pdf.y + 10;
  pdf.fillColor("#1D2939").font("Helvetica").fontSize(9).text(`Duration: ${durationMinutes} minutes`, PAGE.left, infoY);
  pdf.font("Helvetica").fontSize(9).text(`Total marks: ${totalMarks}`, PAGE.left, infoY, { width: PAGE.right - PAGE.left, align: "center" });
  pdf.font("Helvetica").fontSize(9).text(`${text(paperCode, 40)} · v${version}`, PAGE.left, infoY, { width: PAGE.right - PAGE.left, align: "right" });
  const bottom = infoY + 16;
  rule(pdf, bottom, "#B9C5E5");
  return bottom + 14;
}

function candidateFields(pdf, y) {
  const h = 34;
  pdf.roundedRect(PAGE.left, y, PAGE.right - PAGE.left, h, 5).lineWidth(0.8).strokeColor("#8592AD").stroke();
  const colWidth = (PAGE.right - PAGE.left) / 2;
  pdf.fillColor("#475467").font("Helvetica").fontSize(8.5).text("Candidate name:", PAGE.left + 10, y + 12);
  pdf.fillColor("#475467").font("Helvetica").fontSize(8.5).text("Index number:", PAGE.left + 10 + colWidth, y + 12);
  return y + h + 16;
}

function instructions(pdf, lines, y) {
  if (!lines || !lines.length) return y;
  pdf.fillColor("#1D2939").font("Helvetica-Bold").fontSize(9.5).text("Instructions to candidates", PAGE.left, y);
  y = pdf.y + 4;
  for (const line of lines) {
    pdf.font("Helvetica").fontSize(9).text(`• ${text(line, 200)}`, PAGE.left + 6, y, { width: PAGE.right - PAGE.left - 6 });
    y = pdf.y + 3;
  }
  return y + 10;
}

function ensureSpace(pdf, y, needed, footerLabel) {
  if (y + needed <= PAGE.footerTop) return y;
  pageFooter(pdf, footerLabel);
  pdf.addPage();
  return 50;
}

function pageFooter(pdf, label) {
  rule(pdf, PAGE.footerTop, "#D7DCE8");
  pdf.fillColor("#8592AD").font("Helvetica").fontSize(8).text(text(label, 60), PAGE.left, PAGE.footerTop + 6, { width: PAGE.right - PAGE.left - 60 });
  pdf.font("Helvetica").fontSize(8).text(`Page ${pdf.bufferedPageRange().count}`, PAGE.left, PAGE.footerTop + 6, { width: PAGE.right - PAGE.left, align: "right" });
}

function questionsSection(pdf, questions, y, { includeAnswers, footerLabel }) {
  questions.forEach((q, index) => {
    const body = text(q.text, 3000);
    const bodyHeight = pdf.font("Helvetica").fontSize(10).heightOfString(body, { width: PAGE.right - PAGE.left - 24 });
    y = ensureSpace(pdf, y, bodyHeight + 40, footerLabel);
    pdf.fillColor("#102B79").font("Helvetica-Bold").fontSize(10).text(`${index + 1}.`, PAGE.left, y, { width: 20 });
    pdf.fillColor("#1D2939").font("Helvetica").fontSize(10).text(body, PAGE.left + 20, y, { width: PAGE.right - PAGE.left - 60 });
    pdf.fillColor("#475467").font("Helvetica").fontSize(9).text(`(${q.marks} marks)`, PAGE.right - 60, y, { width: 60, align: "right" });
    y = Math.max(pdf.y, y + bodyHeight) + 10;
    if (includeAnswers) {
      const answer = text(q.suggestedAnswer || q.markingGuide || "No marking guide provided.", 2000);
      const answerHeight = pdf.font("Helvetica-Oblique").fontSize(9).heightOfString(answer, { width: PAGE.right - PAGE.left - 40 });
      y = ensureSpace(pdf, y, answerHeight + 20, footerLabel);
      pdf.fillColor("#1B65DC").font("Helvetica-Bold").fontSize(8.5).text("Marking guide:", PAGE.left + 20, y);
      y = pdf.y + 2;
      pdf.fillColor("#475467").font("Helvetica-Oblique").fontSize(9).text(answer, PAGE.left + 20, y, { width: PAGE.right - PAGE.left - 40 });
      y = pdf.y + 12;
    } else {
      const answerSpace = Math.min(80, Math.max(24, q.marks * 8));
      y = ensureSpace(pdf, y, answerSpace, footerLabel);
      pdf.roundedRect(PAGE.left + 20, y, PAGE.right - PAGE.left - 40, answerSpace, 3).lineWidth(0.5).strokeColor("#D7DCE8").stroke();
      y += answerSpace + 12;
    }
  });
  return y;
}

/**
 * Renders one exam paper. `mode` selects "question" (candidate-facing, no
 * answers, blank answer spaces) or "guide" (marking guide, includes
 * suggested answers/marking notes; must never be exposed to students).
 */
async function renderExamPaperPdf({ paper, series, questions, branding, mode, watermarkLabel }) {
  const doc = new PDFDocument({ size: "A4", margin: 0, bufferPages: true });
  const chunks = [];
  doc.on("data", (chunk) => chunks.push(chunk));
  const donePromise = new Promise((resolve, reject) => {
    doc.on("end", resolve);
    doc.on("error", reject);
  });

  const footerLabel = `${branding.schoolName || ""} · ${paper.title} · CONFIDENTIAL`;
  let y = header(doc, {
    schoolName: branding.schoolName,
    examTitle: series.name,
    className: paper.classId,
    subjectName: paper.subjectId,
    durationMinutes: paper.durationMinutes,
    totalMarks: paper.totalMarks,
    paperCode: paper.id,
    version: paper.version,
  }, 40);

  if (mode === "question") {
    y = candidateFields(doc, y);
    y = instructions(doc, ["Answer all questions.", "Write your answers in the spaces provided.", "Show all your working where applicable."], y);
  } else {
    doc.fillColor("#B42318").font("Helvetica-Bold").fontSize(10).text("MARKING GUIDE — NOT FOR CANDIDATE DISTRIBUTION", PAGE.left, y, { width: PAGE.right - PAGE.left, align: "center" });
    y = doc.y + 16;
  }

  y = questionsSection(doc, questions, y, { includeAnswers: mode === "guide", footerLabel });

  pageFooter(doc, footerLabel);
  if (watermarkLabel) {
    const range = doc.bufferedPageRange();
    for (let i = 0; i < range.count; i += 1) {
      doc.switchToPage(range.start + i);
      watermark(doc, watermarkLabel);
    }
  }

  doc.end();
  await donePromise;
  return Buffer.concat(chunks);
}

module.exports = { renderExamPaperPdf };
