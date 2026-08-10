const existing = require('./index');
const draft = require('./draft');
module.exports = { ...existing, ...draft };
