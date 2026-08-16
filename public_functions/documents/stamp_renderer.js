const fs = require('node:fs');
const path = require('node:path');

const STAMP_PATH = path.join(__dirname, 'assets', 'stamp', 'my_stamp.png');
// The source artwork is 1774 x 887 (2:1). These ratios are deliberately
// centralized so a future artwork adjustment cannot affect document layouts.
const STAMP_ASPECT_RATIO = 1774 / 887;
// Calibrated against the transparent source artwork's DATE rule. PDFKit's
// image coordinate transform puts text at a slightly lower visual baseline,
// hence the y ratio is intentionally above the visible rule rather than its
// raw-pixel center.
const DATE_POSITION = Object.freeze({ x: 0.18, y: 0.59, fontSize: 7.3 });

function assertStampAsset() {
  if (!fs.existsSync(STAMP_PATH)) throw new Error('Official stamp asset is missing.');
  return STAMP_PATH;
}

function renderOfficialStamp(pdf, { x, y, width, dateLabel }) {
  const height = width / STAMP_ASPECT_RATIO;
  pdf.image(assertStampAsset(), x, y, { width, height });
  pdf.fillColor('#0019b8').font('Helvetica-Bold').fontSize(DATE_POSITION.fontSize)
    .text(dateLabel, x + width * DATE_POSITION.x, y + height * DATE_POSITION.y, {
      width: width * 0.44,
      lineBreak: false,
    });
  return { width, height };
}

module.exports = { STAMP_PATH, STAMP_ASPECT_RATIO, DATE_POSITION, assertStampAsset, renderOfficialStamp };
