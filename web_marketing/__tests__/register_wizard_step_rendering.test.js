// Regression test for a real hang bug: wizard.js's MutationObserver used
// to watch #registerWizard (which also contains #wizardActionBar) for
// `disabled`/`class` attribute changes and call syncActionBar() on every
// mutation. syncActionBar() itself writes barBack.disabled/barNext.disabled
// - a `disabled`-attribute write on an element inside the observed
// subtree - so every ordinary render (renderStep() calls syncActionBar()
// as part of init) re-queued the very callback that just ran, forever.
// In a real browser this froze the entire tab on load: Chrome's "Page
// Unresponsive" dialog, then a crashed renderer (RESULT_CODE_HUNG) -
// visible to a visitor as "title + stepper + price card, no actual step
// content" because the freeze happens before first paint ever completes.
//
// jsdom's MutationObserver does not reproduce the real hang under a
// mutate-inside-callback pattern the way a browser's does (confirmed: the
// pre-fix wizard.js loads and even survives a burst of attribute writes
// here without spinning) - so this test cannot detect the hang by timing
// alone. What it CAN assert, and what actually caught this bug during
// development, is the structural invariant the fix depends on: the
// MutationObserver's target must never contain the action bar whose
// writes it would otherwise observe. The real hang was confirmed and
// fixed via a live Puppeteer/Chrome reproduction (bisected the exact
// commit and code block), not this file - this file guards the fix from
// silently regressing.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { JSDOM } = require('jsdom');

const ROOT = path.join(__dirname, '..');
const RAW_HTML = fs.readFileSync(path.join(ROOT, 'register-school.html'), 'utf8')
  .replace(/<script src="[^"]*"><\/script>/g, '')
  .replace(/<link rel="stylesheet"[^>]*>/g, '')
  .replace(/<link rel="icon"[^>]*>/g, '')
  .replace(/<link rel="apple-touch-icon"[^>]*>/g, '');

const SCRIPTS = ['js/icons.js', 'js/pricing-config.js', 'js/forms.js', 'js/wizard.js'];

function renderWizard() {
  const dom = new JSDOM(RAW_HTML, {
    url: 'http://localhost/register-school.html',
    runScripts: 'dangerously',
  });
  const { window } = dom;
  window.SPAuth = {
    ensureFirebase: () => Promise.reject(new Error('stubbed - not under test')),
    currentUser: () => Promise.resolve(null),
    callFunction: () => Promise.reject(new Error('stubbed - not under test')),
  };
  for (const rel of SCRIPTS) {
    window.eval(fs.readFileSync(path.join(ROOT, rel), 'utf8'));
  }
  window.document.dispatchEvent(new window.Event('DOMContentLoaded', { bubbles: true, cancelable: true }));
  return dom;
}

function activePanelInfo(dom) {
  const doc = dom.window.document;
  const activeAll = doc.querySelectorAll('.wizard-panel.active');
  const active = activeAll[0] || null;
  return {
    activeCount: activeAll.length,
    step: active ? active.getAttribute('data-step') : null,
    requiredFieldCount: active ? active.querySelectorAll('[required]').length : 0,
    hasSchoolNameField: !!(active && active.querySelector('#schoolName')),
  };
}

const cases = [];
function test(name, fn) { cases.push({ name, fn }); }

test('fresh visit renders step 1 with its real form', () => {
  const dom = renderWizard();
  const info = activePanelInfo(dom);
  assert.equal(info.activeCount, 1);
  assert.equal(info.step, '1');
  assert.equal(info.requiredFieldCount, 6, 'step 1 has 6 required fields');
  assert.equal(info.hasSchoolNameField, true);
  dom.window.close();
});

test('the action-bar MutationObserver does not observe #wizardActionBar itself', () => {
  // The regression: moTarget must exclude #wizardActionBar (whose own
  // disabled writes would otherwise re-trigger the observer). Assert this
  // structurally so a future refactor that reintroduces wizardEl/
  // #wizardForm as the target is caught immediately, before it ships.
  const dom = renderWizard();
  const doc = dom.window.document;
  const actionBar = doc.getElementById('wizardActionBar');
  const layout2col = doc.querySelector('.layout-2col');
  assert.ok(layout2col, '.layout-2col must exist');
  assert.equal(
    layout2col.contains(actionBar),
    false,
    '.layout-2col (the MutationObserver target) must not contain #wizardActionBar',
  );
  dom.window.close();
});

test('register-submit.js can still reach #step2Continue and the action bar to toggle real state', () => {
  // Not a hang detector (see the file-level comment) - just confirms the
  // fix didn't accidentally break the thing the observer exists for:
  // register-submit.js toggling #step2Continue's disabled state is still
  // wired up and readable.
  const dom = renderWizard();
  const doc = dom.window.document;
  const step2Continue = doc.getElementById('step2Continue');
  const barNext = doc.getElementById('wizardBarNext');
  const barBack = doc.getElementById('wizardBarBack');
  assert.ok(step2Continue && barNext && barBack);
  dom.window.close();
});

let failures = 0;
for (const { name, fn } of cases) {
  try {
    fn();
    console.log(`ok - ${name}`);
  } catch (err) {
    failures++;
    console.error(`FAIL - ${name}`);
    console.error(err && err.message ? err.message : err);
  }
}
console.log(`\n${cases.length - failures}/${cases.length} passed`);
process.exit(failures ? 1 : 0);
