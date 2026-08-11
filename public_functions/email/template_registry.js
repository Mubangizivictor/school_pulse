const application = require('./templates/application');
const payment = require('./templates/payment');
const subscription = require('./templates/subscription');
const account = require('./templates/account');
const security = require('./templates/security');
const appointment = require('./templates/appointment');
const reports = require('./templates/reports');
const notification = require('./templates/notification');

// Flat template id -> renderer(data) map. Each renderer returns the content
// fields consumed by base_template.js (title, bodyHtml, status, cta, ...).
// Template families never render HTML themselves — only content.
const TEMPLATES = {
  ...application,
  ...payment,
  ...subscription,
  ...account,
  ...security,
  ...appointment,
  ...reports,
  ...notification,
};

function getTemplate(templateId) {
  const renderer = TEMPLATES[templateId];
  if (!renderer) throw new Error(`Unknown email template id "${templateId}".`);
  return renderer;
}

function isValidTemplateId(templateId) {
  return Object.prototype.hasOwnProperty.call(TEMPLATES, templateId);
}

module.exports = {
  TEMPLATES,
  getTemplate,
  isValidTemplateId,
  TEMPLATE_IDS: Object.keys(TEMPLATES),
};
