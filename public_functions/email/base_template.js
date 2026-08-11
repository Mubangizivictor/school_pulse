const { escapeHtml, escapeAttr, text } = require('./email_helpers');
const { COLORS, statusStyle } = require('./email_styles');
const { BRAND_START, BRAND_END, SUPPORT_EMAIL, FOOTER_LINES } = require('./branding');

/**
 * Render an information card of label/value rows. Rows with no value are
 * dropped so templates can pass optional fields without conditional logic.
 */
function infoCard(rows = []) {
  const filtered = (rows || []).filter((row) => row && row.value);
  if (filtered.length === 0) return '';
  const rowsHtml = filtered.map((row) => `
    <tr>
      <td style="padding:9px 0;color:${COLORS.textLabel};font-size:13px;border-bottom:1px solid ${COLORS.border}">${escapeHtml(row.label, 80)}</td>
      <td style="padding:9px 0;text-align:right;font-weight:700;font-size:13px;color:${COLORS.textPrimary};border-bottom:1px solid ${COLORS.border}">${escapeHtml(row.value, 300)}</td>
    </tr>`).join('');
  return `<table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin-top:20px;background:${COLORS.infoCardBackground};border-radius:14px;padding:6px 18px"><tbody>${rowsHtml}</tbody></table>`;
}

/** Semantic status pill shown under the title (success/pending/warning/error/information/neutral). */
function statusPill(status) {
  if (!status) return '';
  const style = statusStyle(status);
  return `<div style="display:inline-block;margin-bottom:14px;padding:5px 12px;border-radius:999px;font-size:12px;font-weight:700;letter-spacing:.02em;background:${style.background};color:${style.text};border:1px solid ${style.border}">${escapeHtml(style.label, 40)}</div>`;
}

function ctaButton(cta) {
  if (!cta?.label || !cta?.url) return '';
  return `<tr><td align="center" style="padding:24px 0 4px">
      <a href="${escapeAttr(cta.url, 500)}" style="display:inline-block;background:${BRAND_START};color:#ffffff;text-decoration:none;font-weight:700;font-size:14px;padding:14px 32px;border-radius:12px;letter-spacing:.2px">${escapeHtml(cta.label, 60)}</a>
    </td></tr>`;
}

function secondaryMessage(message) {
  if (!message) return '';
  return `<p style="margin:20px 0 0;font-size:14px;line-height:1.6;color:${COLORS.textSecondary}">${escapeHtml(message, 1000)}</p>`;
}

/**
 * Render the single reusable transactional email layout. Every template
 * family produces this same shape of input — the layout itself never
 * changes between templates, only its content.
 *
 * @param {object} params
 * @param {string} params.preheader - hidden preview text shown in inbox lists
 * @param {string} params.title - main heading
 * @param {string} params.status - one of the semantic status keys, optional
 * @param {string} params.bodyHtml - already-escaped/assembled body markup
 * @param {Array<{label:string,value:string}>} [params.infoRows] - information card rows
 * @param {{label:string,url:string}} [params.cta] - primary call to action
 * @param {string} [params.secondaryText] - secondary supporting message
 * @param {string} [params.eyebrow] - small label shown in the header band
 * @param {object} [params.branding] - resolved branding (see branding.js)
 */
function renderBaseTemplate(params) {
  const {
    preheader = '',
    title = '',
    status = null,
    bodyHtml = '',
    infoRows = [],
    cta = null,
    secondaryText = '',
    eyebrow = '',
    branding = {},
  } = params;

  const brandStart = branding.brandStart || BRAND_START;
  const brandEnd = branding.brandEnd || BRAND_END;
  const supportEmail = branding.supportEmail || SUPPORT_EMAIL;
  const wordmark = branding.schoolName ? `${text(branding.schoolName, 160)}` : 'School Pulse';

  // Hidden preheader: rendered but visually collapsed, padded so email
  // clients don't fall back to showing the first visible body text instead.
  const preheaderHtml = preheader
    ? `<div style="display:none;max-height:0;overflow:hidden;opacity:0;mso-hide:all">${escapeHtml(preheader, 150)}${'&nbsp;&zwnj;'.repeat(20)}</div>`
    : '';

  return `<!doctype html>
<html>
<head><meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/></head>
<body style="margin:0;padding:0;background:${COLORS.pageBackground};font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif;color:${COLORS.textPrimary}">
  ${preheaderHtml}
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:${COLORS.pageBackground}">
    <tr><td align="center" style="padding:40px 16px">
      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:560px;background:${COLORS.cardBackground};border-radius:20px;overflow:hidden;box-shadow:0 1px 3px rgba(11,25,53,0.08)">
        <tr>
          <td style="background:linear-gradient(135deg,${brandStart},${brandEnd});padding:32px 36px">
            <div style="font-size:20px;font-weight:800;color:#ffffff;letter-spacing:.2px">${escapeHtml(wordmark, 160)}</div>
            ${eyebrow ? `<div style="margin-top:6px;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:rgba(255,255,255,0.85)">${escapeHtml(eyebrow, 80)}</div>` : ''}
          </td>
        </tr>
        <tr>
          <td style="padding:36px 36px 8px">
            ${statusPill(status)}
            <h1 style="margin:0 0 16px;font-size:22px;line-height:1.3;color:${COLORS.textPrimary}">${escapeHtml(title, 200)}</h1>
            <div style="font-size:15px;line-height:1.65;color:${COLORS.textSecondary}">${bodyHtml}</div>
            ${infoCard(infoRows)}
            ${secondaryMessage(secondaryText)}
          </td>
        </tr>
        <tr><td style="padding:8px 36px 0">
          <table role="presentation" width="100%" cellspacing="0" cellpadding="0">${ctaButton(cta)}</table>
        </td></tr>
        <tr>
          <td style="padding:28px 36px 32px;border-top:1px solid ${COLORS.border};margin-top:12px">
            <div style="font-size:12px;line-height:1.7;color:${COLORS.textMuted}">
              Need help? <a href="mailto:${escapeAttr(supportEmail, 200)}" style="color:${brandStart};text-decoration:none;font-weight:600">${escapeHtml(supportEmail, 200)}</a><br/>
              ${FOOTER_LINES.map((line) => escapeHtml(line, 80)).join(' &middot; ')}
            </div>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
}

/** Plain-text fallback mirroring the HTML layout's content order. */
function renderPlainText({ title, bodyText, infoRows = [], cta = null, secondaryText = '', supportEmail = SUPPORT_EMAIL }) {
  const lines = [];
  if (title) lines.push(text(title, 200));
  if (bodyText) lines.push('', text(bodyText, 2000));
  const infoLines = (infoRows || []).filter((row) => row && row.value)
    .map((row) => `${text(row.label, 80)}: ${text(row.value, 300)}`);
  if (infoLines.length) lines.push('', ...infoLines);
  if (secondaryText) lines.push('', text(secondaryText, 1000));
  if (cta?.label && cta?.url) lines.push('', `${text(cta.label, 60)}: ${text(cta.url, 500)}`);
  lines.push('', `Need help? ${text(supportEmail, 200)}`, FOOTER_LINES.join(' | '));
  return lines.join('\n');
}

module.exports = {
  renderBaseTemplate,
  renderPlainText,
  infoCard,
  statusPill,
};
