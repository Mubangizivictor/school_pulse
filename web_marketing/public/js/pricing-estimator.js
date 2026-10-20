// Drives the interactive slider-based termly pricing estimator on /pricing.
(function () {
  function initEstimator() {
    var slider = document.getElementById('estimatorSlider');
    if (!slider) return;
    var countLabel = document.getElementById('estimatorCount');
    var tierLabel = document.getElementById('estimatorTier');
    var priceLabel = document.getElementById('estimatorPrice');
    var priceWrap = document.getElementById('estimatorPriceWrap');
    var cards = document.querySelectorAll('[data-tier-card]');

    function render() {
      var count = Number(slider.value);
      countLabel.textContent = count.toLocaleString('en-UG');

      var tier = window.getTierForCount(count);
      if (!tier) {
        tierLabel.textContent = '—';
        tierLabel.classList.remove('badge-tier');
        priceLabel.textContent = 'Pricing is being updated — contact us for current rates.';
        cards.forEach(function (card) { card.classList.remove('popular'); });
        return;
      }

      tierLabel.textContent = tier.label;
      tierLabel.classList.add('badge-tier');

      if (tier.price === null) {
        priceLabel.textContent = 'Talk to us';
        priceWrap.querySelectorAll('.per').forEach(function (el) { el.remove(); });
      } else {
        priceLabel.textContent = window.formatUGX(tier.price);
        if (!priceWrap.querySelector('.per')) {
          var per = document.createElement('span');
          per.className = 'per';
          per.textContent = '/ term';
          priceWrap.appendChild(per);
        }
      }

      cards.forEach(function (card) {
        var cardLabel = card.getAttribute('data-tier-card');
        card.classList.toggle('popular', cardLabel === tier.label);
      });
    }

    slider.addEventListener('input', render);
    render();
  }
  document.addEventListener('DOMContentLoaded', initEstimator);
})();
