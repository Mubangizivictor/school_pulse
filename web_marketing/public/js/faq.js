// Generic accordion behaviour for elements matching .accordion-trigger.
(function () {
  function initAccordions() {
    document.querySelectorAll('.accordion-trigger').forEach(function (trigger) {
      if (trigger.dataset.bound) return;
      trigger.dataset.bound = '1';
      trigger.addEventListener('click', function () {
        var panel = document.getElementById(trigger.getAttribute('aria-controls'));
        var expanded = trigger.getAttribute('aria-expanded') === 'true';
        trigger.setAttribute('aria-expanded', String(!expanded));
        if (!expanded) {
          panel.style.maxHeight = panel.scrollHeight + 'px';
        } else {
          panel.style.maxHeight = '0px';
        }
      });
    });
  }
  document.addEventListener('DOMContentLoaded', initAccordions);
  window.initAccordions = initAccordions;
})();
