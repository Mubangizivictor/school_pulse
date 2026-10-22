// Source-text-assertion test: proves every one of the 10 scheduled jobs
// (and the 6 payment/onboarding failure catch sites) was actually
// instrumented with recordJobRun/recordJobFailure, without needing the
// emulator - catches an accidental skip during future edits to any of
// these files.
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

function source(file) {
  return fs.readFileSync(path.resolve(__dirname, "..", file), "utf8");
}

test("all 10 scheduled jobs are wrapped with recordJobRun", () => {
  const jobs = [
    { file: "index.js", name: "autoEscalateApprovalRequests" },
    { file: "index.js", name: "checkVisitorOverstays" },
    { file: "index.js", name: "processScheduledBroadcasts" },
    { file: "appointments.js", name: "sendAppointmentReminderEmails" },
    { file: "exam_factory_reminders.js", name: "sendExamFactoryDeadlineReminders" },
    { file: "communication_campaigns.js", name: "reconcileCommunicationCampaigns" },
    { file: "notifications.js", name: "dispatchScheduledNotifications" },
    { file: "notifications.js", name: "escalateUnacknowledgedAlerts" },
    { file: "notifications.js", name: "purgeExpiredNotifications" },
    { file: "report_card_release.js", name: "expireLapsedReportCardExceptions" },
  ];
  const sourcesByFile = {};
  for (const { file, name } of jobs) {
    sourcesByFile[file] ||= source(file);
    const pattern = new RegExp(`recordJobRun\\(\\s*["']${name}["']`);
    assert.match(sourcesByFile[file], pattern, `${name} in ${file} is missing its recordJobRun wrap`);
  }
});

test("every job-owning file requires platform_health_instrumentation", () => {
  const files = [
    "index.js", "appointments.js", "exam_factory_reminders.js",
    "communication_campaigns.js", "notifications.js", "report_card_release.js",
  ];
  for (const file of files) {
    assert.match(
      source(file),
      /require\(["']\.\/platform_health_instrumentation["']\)/,
      `${file} does not require ./platform_health_instrumentation`,
    );
  }
});

test("both payment-processing failure catch sites call recordJobFailure", () => {
  const text = source("index.js");
  assert.match(text, /recordJobFailure\(\s*["']payment_processing["'],\s*["']initiateMobileMoneyCharge["']/);
  assert.match(text, /recordJobFailure\(\s*["']payment_processing["'],\s*["']markTransactionResult["']/);
});

test("all 4 school-onboarding failure sites in provisionSchoolAdmin call recordJobFailure", () => {
  const text = source("index.js");
  const matches = text.match(/recordJobFailure\(\s*["']school_onboarding["'],\s*["']provisionSchoolAdmin["']/g) || [];
  assert.equal(matches.length, 4, `expected 4 recordJobFailure('school_onboarding', ...) call sites, found ${matches.length}`);
});
