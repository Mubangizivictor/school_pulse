const existing = require('./index');
const draft = require('./draft');
const owner = require('./owner');

module.exports = { ...existing, ...draft, ...owner };
