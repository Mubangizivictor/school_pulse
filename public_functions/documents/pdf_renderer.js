const path = require('node:path');
const PDFDocument = require('pdfkit');
const QRCode = require('qrcode');
const { renderOfficialStamp } = require('./stamp_renderer');

const LOGO_PATH = path.join(__dirname, 'assets', 'logo', 'splash_light_mode.png');
const PAGE = Object.freeze({ left: 54, right: 541, footerTop: 736 });

function text(value, max = 300) { return String(value ?? '').replace(/[\r\n]+/g, ' ').trim().slice(0, max); }
function rowValues(row) { return Array.isArray(row) ? row : [row?.label, row?.value]; }
function statusValue(label, value) { return /status/i.test(label) && /approved|paid|verified|activated|renewed/i.test(value); }
function rule(pdf, y, color = '#D7DCE8') { pdf.strokeColor(color).lineWidth(0.7).moveTo(PAGE.left, y).lineTo(PAGE.right, y).stroke(); }

function header(pdf, snapshot) {
  pdf.image(LOGO_PATH, PAGE.left, 23, { fit: [148, 82], align: 'left', valign: 'center' });
  pdf.fillColor('#1026A8').font('Helvetica-Bold').fontSize(10).text('A VictorBee Technologies Product', 335, 43, { width: 206, align: 'right' });
  pdf.fillColor('#475467').font('Helvetica').fontSize(9).text('Kampala, Uganda', 335, 58, { width: 206, align: 'right' });
  rule(pdf, 108, '#B9C5E5');
  pdf.fillColor('#102B79').font('Helvetica-Bold').fontSize(19).text(text(snapshot.title, 70), PAGE.left, 121, { width: 390, lineGap: 1 });
  const titleBottom = pdf.y;
  pdf.fillColor('#FF4B23').rect(PAGE.left, titleBottom + 8, 48, 2).fill();
  return titleBottom + 23;
}

function referenceCard(pdf, snapshot, y) {
  const h = 53;
  pdf.roundedRect(PAGE.left, y, PAGE.right - PAGE.left, h, 6).lineWidth(0.8).strokeColor('#1B65DC').stroke();
  pdf.fillColor('#475467').font('Helvetica-Bold').fontSize(8).text('OFFICIAL REFERENCE', 69, y + 11);
  pdf.fillColor('#102B79').font('Helvetica-Bold').fontSize(12).text(text(snapshot.documentNumber, 60), 69, y + 25, { width: 268 });
  pdf.strokeColor('#B9C5E5').lineWidth(0.8).moveTo(350, y).lineTo(350, y + h).stroke();
  pdf.fillColor('#475467').font('Helvetica-Bold').fontSize(8).text('ISSUED', 367, y + 11);
  pdf.fillColor('#1D2939').font('Helvetica-Bold').fontSize(10).text(text(snapshot.issuedLabel, 30), 367, y + 26, { width: 155 });
  return y + h + 12;
}

function rows(pdf, snapshot, y) {
  for (const row of snapshot.rows || []) {
    const [rawLabel, rawValue] = rowValues(row); const label = text(rawLabel, 60); const value = text(rawValue, 260);
    if (!value) continue;
    const valueHeight = pdf.font('Helvetica').fontSize(9.5).heightOfString(value, { width: 278, lineGap: 1 });
    const height = Math.max(25, valueHeight + 10);
    if (y + height > 480) throw new Error('Official document contains more content than fits safely on one A4 page.');
    pdf.roundedRect(PAGE.left, y + 3, 27, 20, 3).fillColor('#103F94').fill();
    pdf.fillColor('#FFFFFF').font('Helvetica-Bold').fontSize(10).text('•', 64, y + 7, { width: 8, align: 'center' });
    pdf.fillColor('#102B79').font('Helvetica-Bold').fontSize(8.3).text(label.toUpperCase(), 91, y + 8, { width: 150 });
    if (statusValue(label, value)) {
      const badgeWidth = Math.min(190, pdf.font('Helvetica-Bold').fontSize(8.8).widthOfString(value) + 16);
      pdf.roundedRect(250, y + 5, badgeWidth, 17, 4).fillColor('#E9F8EB').fill().lineWidth(0.6).strokeColor('#2E9B43').stroke();
      pdf.fillColor('#167330').font('Helvetica-Bold').fontSize(8.8).text(value, 258, y + 9, { width: badgeWidth - 16, lineBreak: false });
    } else pdf.fillColor('#1D2939').font('Helvetica').fontSize(9.5).text(value, 250, y + 8, { width: 280, lineGap: 1 });
    rule(pdf, y + height, '#E1E6EF'); y += height;
  }
  return y;
}

function confirmation(pdf, snapshot, y) {
  const body = text(snapshot.notice, 520); const h = Math.max(48, pdf.font('Helvetica').fontSize(9.5).heightOfString(body, { width: 380, lineGap: 2 }) + 18);
  if (y + h > 536) throw new Error('Official document confirmation cannot fit safely on one A4 page.');
  pdf.roundedRect(PAGE.left, y, PAGE.right - PAGE.left, h, 6).fillColor('#F2FBF3').fill().lineWidth(0.8).strokeColor('#2E9B43').stroke();
  pdf.circle(75, y + 20, 10).fillColor('#16823A').fill(); pdf.fillColor('#FFFFFF').font('Helvetica-Bold').fontSize(11).text('✓', 70.7, y + 13.8, { lineBreak: false });
  pdf.fillColor('#102B79').font('Helvetica').fontSize(9.5).text(body, 97, y + 11, { width: 416, lineGap: 2 }); return y + h;
}

function verificationCard(pdf, snapshot, qr, y) {
  const h = 112;
  if (y + h > PAGE.footerTop - 6) throw new Error('Official document verification block cannot fit safely on one A4 page.');
  pdf.roundedRect(PAGE.left, y, 248, h, 6).lineWidth(0.8).strokeColor('#1B65DC').stroke();
  pdf.fillColor('#102B79').font('Helvetica-Bold').fontSize(8.7).text('VERIFY DOCUMENT', 67, y + 12);
  pdf.fillColor('#344054').font('Helvetica').fontSize(8.5).text('Scan the QR code to verify this official document.', 67, y + 28, { width: 112, lineGap: 1 });
  pdf.fillColor('#102B79').font('Helvetica-Bold').fontSize(7.6).text(`Ref: ${text(snapshot.documentNumber, 60)}`, 67, y + 85, { width: 125 });
  pdf.image(qr, 190, y + 11, { width: 89, height: 89 });
}

function footer(pdf) {
  const y = PAGE.footerTop;
  pdf.rect(0, y, 595, 106).fillColor('#092C7B').fill();
  pdf.save().strokeColor('#FF4B23').lineWidth(4).moveTo(0, y + 8).bezierCurveTo(150, y + 55, 320, y - 16, 595, y + 10).stroke().restore();
  pdf.fillColor('#FFFFFF').font('Helvetica-Bold').fontSize(9).text('Victor Mubangizi', 54, y + 37);
  pdf.font('Helvetica').fontSize(8.5).text('0793128137', 54, y + 52).text('mubangizivic@gmail.com', 54, y + 67);
  pdf.font('Helvetica-Bold').fontSize(10).text('SCHOOL PULSE', 360, y + 43, { width: 181, align: 'right' });
  pdf.font('Helvetica-Oblique').fontSize(8.5).text('Educate. Empower. Excel.', 360, y + 60, { width: 181, align: 'right' });
}

async function renderOfficialPdf(snapshot) {
  if (!snapshot?.verificationUrl) throw new Error('Official document verification URL is required.');
  const qr = await QRCode.toBuffer(snapshot.verificationUrl, { errorCorrectionLevel: 'M', margin: 1, width: 320, color: { dark: '#061B55', light: '#FFFFFFFF' } });
  return new Promise((resolve, reject) => {
    const pdf = new PDFDocument({ size: 'A4', margin: 0, compress: false, info: { Title: `${text(snapshot.title, 70)} - ${text(snapshot.documentNumber, 60)}`, Author: 'School Pulse', Creator: 'VictorBee Technologies / School Pulse', Subject: 'Official School Pulse document' } });
    const buffers = []; pdf.on('data', (part) => buffers.push(part)); pdf.on('end', () => resolve(Buffer.concat(buffers))); pdf.on('error', reject);
    const contentStart = referenceCard(pdf, snapshot, header(pdf, snapshot)); const detailsBottom = rows(pdf, snapshot, contentStart); const confirmationBottom = confirmation(pdf, snapshot, detailsBottom + 12);
    const stampWidth = 174; renderOfficialStamp(pdf, { x: PAGE.right - stampWidth, y: confirmationBottom + 13, width: stampWidth, dateLabel: snapshot.stampDate });
    verificationCard(pdf, snapshot, qr, confirmationBottom + 7); footer(pdf); pdf.end();
  });
}

module.exports = { LOGO_PATH, renderOfficialPdf };
