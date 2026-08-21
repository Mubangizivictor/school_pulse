// Official A4 report-card PDF rendering + QR verification.
//
// Renders directly from the canonical schools/{schoolId}/reportCards
// snapshot - the exact same fields the Flutter preview
// (ReportCardBody) shows - so the PDF and the in-app preview can never
// disagree about what a report contains. Mirrors the visual conventions of
// public_functions/documents/pdf_renderer.js (A4, pdfkit, qrcode) but is a
// separate module: report cards belong to the `functions` (default)
// codebase, which is what actually holds admin.firestore() access to
// schools/{schoolId}/reportCards, not the `publicwebsite` codebase.
const PDFDocument = require("pdfkit");
const QRCode = require("qrcode");

const PAGE = Object.freeze({ left: 42, right: 553, footerTop: 780 });

function text(value, max = 300) {
  return String(value ?? "").replace(/[\r\n]+/g, " ").trim().slice(0, max);
}

function rule(pdf, y, color = "#D7DCE8") {
  pdf.strokeColor(color).lineWidth(0.7).moveTo(PAGE.left, y).lineTo(PAGE.right, y).stroke();
}

/** Downloads a small image (school logo) for embedding; returns null on any failure so a missing/broken logo never blocks report generation. */
async function fetchImageBuffer(url) {
  if (!url) return null;
  try {
    const res = await fetch(url);
    if (!res.ok) return null;
    const arrayBuffer = await res.arrayBuffer();
    return Buffer.from(arrayBuffer);
  } catch (_err) {
    return null;
  }
}

function header(pdf, { schoolName, schoolAddress, schoolContacts, logoBuffer }, y) {
  if (logoBuffer) {
    try {
      pdf.image(logoBuffer, PAGE.left, y, { fit: [64, 64] });
    } catch (_err) {
      // A corrupt/unsupported image must not fail the whole render.
    }
  }
  const textLeft = logoBuffer ? PAGE.left + 76 : PAGE.left;
  pdf.fillColor("#102B79").font("Helvetica-Bold").fontSize(16).text(text(schoolName, 90), textLeft, y, { width: PAGE.right - textLeft });
  pdf.fillColor("#475467").font("Helvetica").fontSize(9).text(text(schoolAddress, 140), textLeft, pdf.y + 2, { width: PAGE.right - textLeft });
  if (schoolContacts) {
    pdf.fillColor("#475467").font("Helvetica").fontSize(9).text(text(schoolContacts, 140), textLeft, pdf.y + 2, { width: PAGE.right - textLeft });
  }
  const bottom = Math.max(pdf.y + 8, y + 64 + 8);
  rule(pdf, bottom, "#B9C5E5");
  pdf.fillColor("#102B79").font("Helvetica-Bold").fontSize(13).text("STUDENT REPORT CARD", PAGE.left, bottom + 10, { width: PAGE.right - PAGE.left, align: "center" });
  return bottom + 30;
}

function studentInfo(pdf, snapshot, y) {
  const h = 46;
  pdf.roundedRect(PAGE.left, y, PAGE.right - PAGE.left, h, 6).lineWidth(0.8).strokeColor("#1B65DC").stroke();
  const colWidth = (PAGE.right - PAGE.left - 20) / 2;
  pdf.fillColor("#475467").font("Helvetica-Bold").fontSize(7.5).text("STUDENT", PAGE.left + 10, y + 8);
  pdf.fillColor("#102B79").font("Helvetica-Bold").fontSize(11).text(text(snapshot.studentName || snapshot.studentId, 60), PAGE.left + 10, y + 20, { width: colWidth });
  pdf.fillColor("#475467").font("Helvetica-Bold").fontSize(7.5).text("CLASS / STREAM", PAGE.left + 10 + colWidth, y + 8);
  pdf.fillColor("#102B79").font("Helvetica-Bold").fontSize(11).text(text(`${snapshot.classId || ""}${snapshot.streamId ? ` - ${snapshot.streamId}` : ""}`, 60), PAGE.left + 10 + colWidth, y + 20, { width: colWidth });
  return y + h + 12;
}

function periodInfo(pdf, snapshot, y) {
  pdf.fillColor("#1D2939").font("Helvetica").fontSize(9.5).text(`Academic Year: ${text(snapshot.academicYearId, 30)}    Term: ${text(snapshot.termId, 30)}    Version: ${snapshot.version}`, PAGE.left, y);
  return y + 20;
}

function subjectsTable(pdf, subjects, y) {
  const columns = [
    { key: "subjectId", label: "SUBJECT", width: 200 },
    { key: "average", label: "SCORE", width: 90 },
    { key: "grade", label: "GRADE", width: 90 },
    { key: "gradePoint", label: "POINTS", width: 90 },
    { key: "status", label: "STATUS", width: 41 },
  ];
  let x = PAGE.left;
  pdf.fillColor("#FFFFFF").rect(PAGE.left, y, PAGE.right - PAGE.left, 20).fill("#102B79");
  for (const col of columns) {
    pdf.fillColor("#FFFFFF").font("Helvetica-Bold").fontSize(8).text(col.label, x + 4, y + 6, { width: col.width - 8 });
    x += col.width;
  }
  let rowY = y + 20;
  for (const subject of subjects) {
    if (rowY + 18 > PAGE.footerTop - 120) {
      throw new Error("Report card has more subjects than fit safely on one A4 page.");
    }
    x = PAGE.left;
    const isComplete = subject.isComplete;
    const scoreText = isComplete ? (subject.average != null ? subject.average.toFixed(1) : "-") : (subject.incompleteReason || "Incomplete");
    const values = [subject.subjectId || "", scoreText, isComplete ? (subject.grade || "-") : "-", isComplete && subject.gradePoint != null ? String(subject.gradePoint) : "-", isComplete ? "" : "!"];
    for (let i = 0; i < columns.length; i += 1) {
      pdf.fillColor(isComplete ? "#1D2939" : "#B42318").font("Helvetica").fontSize(9).text(text(values[i], 40), x + 4, rowY + 5, { width: columns[i].width - 8 });
      x += columns[i].width;
    }
    rule(pdf, rowY + 18, "#E1E6EF");
    rowY += 18;
  }
  return rowY + 10;
}

function summary(pdf, snapshot, y) {
  const h = 50;
  pdf.roundedRect(PAGE.left, y, PAGE.right - PAGE.left, h, 6).fillColor("#F2F6FF").fill().lineWidth(0.8).strokeColor("#1B65DC").stroke();
  const colWidth = (PAGE.right - PAGE.left) / 3;
  const cells = [
    ["AVERAGE", snapshot.average != null ? snapshot.average.toFixed(1) : "-"],
    ["OVERALL GRADE", snapshot.overallGrade || "-"],
    ["POSITION", snapshot.isRanked ? String(snapshot.position) : "Unranked"],
  ];
  cells.forEach(([label, value], i) => {
    const cellX = PAGE.left + i * colWidth;
    pdf.fillColor("#475467").font("Helvetica-Bold").fontSize(7.5).text(label, cellX + 8, y + 8);
    pdf.fillColor("#102B79").font("Helvetica-Bold").fontSize(14).text(value, cellX + 8, y + 20, { width: colWidth - 16 });
  });
  return y + h + 12;
}

function attendanceConduct(pdf, snapshot, y) {
  pdf.fillColor("#1D2939").font("Helvetica-Bold").fontSize(9.5).text("Attendance & Conduct", PAGE.left, y);
  y += 14;
  pdf.fillColor("#1D2939").font("Helvetica").fontSize(9).text(
    snapshot.attendanceVerified ? "Attendance verified by the class teacher." : "Attendance not yet verified.",
    PAGE.left,
    y,
  );
  y += 14;
  if (snapshot.overallConductCode) {
    pdf.font("Helvetica").fontSize(9).text(`Conduct: ${text(snapshot.overallConductCode, 40)}`, PAGE.left, y);
    y += 14;
  }
  return y + 6;
}

function comment(pdf, snapshot, y) {
  if (!snapshot.classTeacherComment) return y;
  pdf.fillColor("#1D2939").font("Helvetica-Bold").fontSize(9.5).text("Class Teacher's Comment", PAGE.left, y);
  y += 14;
  const body = text(snapshot.classTeacherComment, 500);
  const h = pdf.font("Helvetica").fontSize(9.5).heightOfString(body, { width: PAGE.right - PAGE.left, lineGap: 1 });
  pdf.fillColor("#1D2939").font("Helvetica").fontSize(9.5).text(body, PAGE.left, y, { width: PAGE.right - PAGE.left, lineGap: 1 });
  return y + h + 12;
}

function signatures(pdf, snapshot, y) {
  const cols = [
    ["Class Teacher", snapshot.classTeacherSignedByName || null],
    ["Dean of Studies", snapshot.deanDecision && snapshot.deanDecision.decision === "signed" ? snapshot.deanDecision.actorDisplayName : null],
    ["Headteacher", snapshot.headteacherDecision && snapshot.headteacherDecision.decision === "signed" ? snapshot.headteacherDecision.actorDisplayName : null],
  ];
  const colWidth = (PAGE.right - PAGE.left) / cols.length;
  cols.forEach(([label, name], i) => {
    const cellX = PAGE.left + i * colWidth;
    rule(pdf, y + 22, "#8592AD");
    pdf.fillColor("#1D2939").font("Helvetica").fontSize(8.5).text(name || "Not signed", cellX, y, { width: colWidth - 10 });
    pdf.fillColor("#475467").font("Helvetica").fontSize(7.5).text(label, cellX, y + 26, { width: colWidth - 10 });
  });
  return y + 44;
}

async function verificationBlock(pdf, verificationUrl, y) {
  const qrSize = 70;
  const qrDataUrl = await QRCode.toDataURL(verificationUrl, { margin: 0, width: qrSize * 4 });
  const base64 = qrDataUrl.split(",")[1];
  const qrBuffer = Buffer.from(base64, "base64");
  pdf.image(qrBuffer, PAGE.left, y, { fit: [qrSize, qrSize] });
  pdf.fillColor("#475467").font("Helvetica").fontSize(7.5).text("Scan to verify authenticity", PAGE.left + qrSize + 10, y + 14, { width: 200 });
  pdf.fillColor("#475467").font("Helvetica").fontSize(6.5).text(verificationUrl, PAGE.left + qrSize + 10, y + 26, { width: 300 });
  return y + qrSize + 10;
}

function draftWatermark(pdf, label) {
  pdf.save();
  pdf.rotate(-30, { origin: [297.5, 421] });
  pdf.fillColor("red", 0.15).font("Helvetica-Bold").fontSize(60).text(label, 60, 380, { width: 480, align: "center" });
  pdf.restore();
}

/**
 * Renders one report card to A4 PDF bytes.
 *
 * `snapshot` is the reportCards document data (plus a resolved
 * `verificationUrl` and, for unsigned previews, `isDraftPreview: true`).
 * Never called for an already-rendered official (isFinalized + pdfUrl
 * already set) report - the caller (generateReportCardPdf) is responsible
 * for that idempotency check.
 */
async function renderReportCardPdf(snapshot) {
  const doc = new PDFDocument({ size: "A4", margin: 0, bufferPages: true });
  const chunks = [];
  doc.on("data", (chunk) => chunks.push(chunk));
  const donePromise = new Promise((resolve, reject) => {
    doc.on("end", resolve);
    doc.on("error", reject);
  });

  const logoBuffer = await fetchImageBuffer(snapshot.schoolLogoUrl);

  let y = header(doc, {
    schoolName: snapshot.schoolName,
    schoolAddress: snapshot.schoolAddress,
    schoolContacts: snapshot.schoolContacts,
    logoBuffer,
  }, 40);
  y = studentInfo(doc, snapshot, y);
  y = periodInfo(doc, snapshot, y);
  y = subjectsTable(doc, snapshot.subjectResults || [], y);
  y = summary(doc, snapshot, y);
  y = attendanceConduct(doc, snapshot, y);
  y = comment(doc, snapshot, y);
  y = signatures(doc, snapshot, y + 8);
  await verificationBlock(doc, snapshot.verificationUrl, y + 10);

  if (snapshot.isDraftPreview) {
    draftWatermark(doc, "DRAFT — NOT OFFICIAL");
  } else if (!snapshot.isFinalized) {
    draftWatermark(doc, "AWAITING SIGNATURES");
  }

  doc.end();
  await donePromise;
  return Buffer.concat(chunks);
}

module.exports = { renderReportCardPdf, fetchImageBuffer };
