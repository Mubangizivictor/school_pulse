const { escapeHtml, humanReference } = require('../email_helpers');
const { STATUS_URL } = require('../branding');

module.exports = {
  report_available: (data) => {
    const reference = humanReference('report', data.reportId);
    return {
      subject: 'A new report is available',
      preheader: `${data.reportName} is now available for ${data.schoolName}.`,
      eyebrow: 'Report available',
      title: 'A new report is available',
      status: 'information',
      bodyText: `${data.reportName} is now available for ${data.schoolName}.`,
      bodyHtml: `<p><strong>${escapeHtml(data.reportName)}</strong> is now available for <strong>${escapeHtml(data.schoolName)}</strong>.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Report', value: data.reportName },
        { label: 'Reference', value: reference },
        { label: 'Period', value: data.periodLabel },
      ],
      cta: { label: 'View Report', url: STATUS_URL },
    };
  },

  report_published: (data) => {
    const reference = humanReference('report', data.reportId);
    return {
      subject: 'A report has been published',
      preheader: `${data.reportName} has been published for ${data.schoolName}.`,
      eyebrow: 'Report published',
      title: 'A report has been published',
      status: 'success',
      bodyText: `${data.reportName} has been published for ${data.schoolName}.`,
      bodyHtml: `<p><strong>${escapeHtml(data.reportName)}</strong> has been published for <strong>${escapeHtml(data.schoolName)}</strong>.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Report', value: data.reportName },
        { label: 'Reference', value: reference },
        { label: 'Published by', value: data.publishedByLabel },
      ],
      cta: { label: 'View Report', url: STATUS_URL },
    };
  },
};
