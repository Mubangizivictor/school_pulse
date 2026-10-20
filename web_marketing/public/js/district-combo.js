// Contained, keyboard-accessible searchable district combobox for
// register-school.html's Step 5.
//
// This is a thin UI layer over the existing plumbing:
//   - #district stays a real <input name="district"> — wizard.js draft
//     persistence, register-submit.js's region->district cascade + blur
//     re-validation, and the submit body all keep working unchanged.
//   - The option list is read live from #districtOptions, the <datalist>
//     that initRegionDistrictCascade() already fills with only the selected
//     region's districts. One source of truth, region filtering for free.
//
// The popover is absolutely positioned inside #fieldDistrict — it never
// overlays the whole page and never blocks other controls.
(function () {
  var DEBOUNCE_MS = 160;

  function init() {
    var combo = document.getElementById('districtCombo');
    var input = document.getElementById('district');
    var toggle = document.getElementById('districtToggle');
    var popover = document.getElementById('districtPopover');
    var listbox = document.getElementById('districtListbox');
    var emptyEl = document.getElementById('districtEmpty');
    var optionsSource = document.getElementById('districtOptions');
    var fieldEl = document.getElementById('fieldDistrict');
    if (!combo || !input || !popover || !listbox || !optionsSource) return;

    var open = false;
    var activeIndex = -1;
    var rendered = [];       // district names currently shown
    var debounceTimer = null;

    function allDistricts() {
      return Array.prototype.map.call(
        optionsSource.querySelectorAll('option'),
        function (o) { return o.value; }
      );
    }

    function setOpen(next) {
      if (input.disabled) next = false;
      open = next;
      combo.setAttribute('data-open', next ? 'true' : 'false');
      input.setAttribute('aria-expanded', next ? 'true' : 'false');
      popover.hidden = !next;
      if (!next) { activeIndex = -1; }
    }

    function filtered() {
      var q = input.value.trim().toLowerCase();
      var list = allDistricts();
      if (!q) return list;
      // Prefix matches first, then substring matches — feels more predictable.
      var starts = [], contains = [];
      list.forEach(function (name) {
        var lc = name.toLowerCase();
        if (lc.indexOf(q) === 0) starts.push(name);
        else if (lc.indexOf(q) !== -1) contains.push(name);
      });
      return starts.concat(contains);
    }

    function renderList() {
      rendered = filtered();
      listbox.innerHTML = '';
      var chosen = input.value.trim();
      rendered.forEach(function (name, i) {
        var li = document.createElement('li');
        li.className = 'combo-option';
        li.id = 'district-opt-' + i;
        li.setAttribute('role', 'option');
        li.setAttribute('aria-selected', name === chosen ? 'true' : 'false');
        li.textContent = name;
        li.addEventListener('mousedown', function (e) {
          // mousedown (not click) so the input doesn't blur-close first.
          e.preventDefault();
          choose(name);
        });
        listbox.appendChild(li);
      });
      var noResults = rendered.length === 0;
      emptyEl.hidden = !noResults;
      listbox.hidden = noResults;
      if (activeIndex >= rendered.length) activeIndex = rendered.length - 1;
      paintActive();
    }

    function paintActive() {
      var opts = listbox.querySelectorAll('.combo-option');
      opts.forEach(function (el, i) {
        el.classList.toggle('is-active', i === activeIndex);
      });
      if (activeIndex >= 0 && opts[activeIndex]) {
        input.setAttribute('aria-activedescendant', opts[activeIndex].id);
        opts[activeIndex].scrollIntoView({ block: 'nearest' });
      } else {
        input.removeAttribute('aria-activedescendant');
      }
    }

    function choose(name) {
      input.value = name;
      // Fire input + change so wizard.js saveDraft() persists the pick and
      // register-submit.js's blur/validation logic sees a normal value.
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
      if (fieldEl) fieldEl.classList.remove('has-error');
      setOpen(false);
      input.focus();
    }

    // ---- events ----
    input.addEventListener('focus', function () {
      if (input.disabled) return;
      renderList();
      setOpen(true);
    });

    input.addEventListener('input', function () {
      if (debounceTimer) clearTimeout(debounceTimer);
      debounceTimer = setTimeout(function () {
        activeIndex = -1;
        renderList();
        if (!open) setOpen(true);
      }, DEBOUNCE_MS);
    });

    input.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (!open) { renderList(); setOpen(true); }
        if (rendered.length) { activeIndex = Math.min(activeIndex + 1, rendered.length - 1); paintActive(); }
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (rendered.length) { activeIndex = Math.max(activeIndex - 1, 0); paintActive(); }
      } else if (e.key === 'Enter') {
        if (open && activeIndex >= 0 && rendered[activeIndex]) {
          e.preventDefault();
          choose(rendered[activeIndex]);
        }
      } else if (e.key === 'Escape') {
        if (open) { e.preventDefault(); setOpen(false); }
      } else if (e.key === 'Tab') {
        setOpen(false);
      }
    });

    toggle.addEventListener('mousedown', function (e) {
      e.preventDefault();
      if (input.disabled) return;
      if (open) { setOpen(false); }
      else { renderList(); setOpen(true); input.focus(); }
    });

    input.addEventListener('blur', function () {
      // Let a mousedown on an option resolve first; then close.
      setTimeout(function () { setOpen(false); }, 0);
    });

    document.addEventListener('click', function (e) {
      if (open && !combo.contains(e.target)) setOpen(false);
    });

    // When the region changes, initRegionDistrictCascade() rebuilds the
    // datalist and clears #district. Refresh the popover if it's open.
    var regionEl = document.getElementById('region');
    if (regionEl) {
      regionEl.addEventListener('change', function () {
        activeIndex = -1;
        if (open) renderList();
      });
    }
  }

  document.addEventListener('DOMContentLoaded', init);
})();
