// Shared client-side form validation + success-state swap helpers.
// No backend calls — purely cosmetic validation for the marketing site.
(function () {
  var EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  function showError(field, message) {
    field.classList.add('has-error');
    var err = field.querySelector('.error-text');
    if (err) err.textContent = message;
  }
  function clearError(field) {
    field.classList.remove('has-error');
  }

  // Validate a form given a list of {input, fieldEl, required, isEmail} rules.
  function validateForm(rules) {
    var valid = true;
    rules.forEach(function (rule) {
      var input = rule.input;
      var fieldEl = rule.fieldEl || input.closest('.form-field');
      var value = (input.value || '').trim();
      clearError(fieldEl);

      if (rule.required && !value) {
        showError(fieldEl, rule.requiredMessage || 'This field is required.');
        valid = false;
        return;
      }
      if (rule.isEmail && value && !EMAIL_RE.test(value)) {
        showError(fieldEl, 'Please enter a valid email address.');
        valid = false;
      }
    });
    return valid;
  }

  function swapToSuccess(formEl, successEl) {
    formEl.style.display = 'none';
    successEl.style.display = 'block';
    successEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  window.SPForms = { validateForm: validateForm, swapToSuccess: swapToSuccess, EMAIL_RE: EMAIL_RE, showError: showError, clearError: clearError };
})();
