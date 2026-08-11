// Inline-style tokens shared across the base template and templates. Kept as
// plain hex/px values (no CSS variables, no <style> blocks) because Gmail and
// Outlook strip <style> tags and ignore custom properties in transactional
// mail — every style must be inlined on the element.

const COLORS = {
  pageBackground: '#eef1f8',
  cardBackground: '#ffffff',
  border: '#eef2f8',
  infoCardBackground: '#f7f9fd',
  textPrimary: '#0b1935',
  textSecondary: '#44546a',
  textMuted: '#9aa8ba',
  textLabel: '#718096',
};

// Semantic status palette. Each status maps to a background/text/border trio
// used for the status pill and information card accents.
const STATUS_STYLES = {
  success: { background: '#e8f8ee', text: '#1c7c4d', border: '#bdead0', label: 'Success' },
  pending: { background: '#fff6e6', text: '#9a6a00', border: '#f5e0ab', label: 'Pending' },
  warning: { background: '#fff1e0', text: '#a3540d', border: '#f6d3ab', label: 'Warning' },
  error: { background: '#fdeaea', text: '#b42318', border: '#f5c2be', label: 'Action needed' },
  information: { background: '#eaf1ff', text: '#2451c4', border: '#c6d7f8', label: 'Information' },
  neutral: { background: '#f1f3f7', text: '#44546a', border: '#dde3ee', label: 'Update' },
};

function statusStyle(status) {
  return STATUS_STYLES[status] || STATUS_STYLES.neutral;
}

module.exports = {
  COLORS,
  STATUS_STYLES,
  statusStyle,
};
