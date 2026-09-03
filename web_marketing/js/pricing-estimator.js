// Drives the interactive slider-based termly pricing estimator on /pricing.
(function () {
  function initEstimator() {
    var slider = document.getElementById('estimatorSlider');
    if (!slider) return;
    var countLabel = document.getElementById('estimatorCount');
    var tierLabel = document.getElementById('estimatorTier');
    var priceLabel = document.getElementById('estimatorPrice');
    var cards = document.querySelectorAll('[data-tier-card]');

    function render() {
      var count = Number(slider.value);
      countLabel.textContent = count.toLocaleString('en-UG');

      var tier = window.getTierForCount(count);
      if (!tier) {
        tierLabel.textContent = '—';
        priceLabel.textContent = 'Pricing is being updated — contact us for current rates.';
        cards.forEach(function (card) { card.classList.remove('popular'); });
        return;
      }

      tierLabel.textContent = tier.label;
      priceLabel.textContent = tier.price === null
        ? 'Talk to us'
        : window.formatUGX(tier.price) + ' / term';

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
