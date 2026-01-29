// Stimulus controller for dynamic search
document.addEventListener('DOMContentLoaded', function() {
  initializeSearch();
});

document.addEventListener('turbolinks:load', function() {
  initializeSearch();
});

function initializeSearch() {
  const transportTypeSelect = document.querySelector('select[name="search[transport_type]"]');
  const startStationSelect = document.querySelector('select[name="search[start_station_id]"]');
  const endStationSelect = document.querySelector('select[name="search[end_station_id]"]');

  if (transportTypeSelect) {
    transportTypeSelect.addEventListener('change', function() {
      // Could filter stations based on transport type
      console.log('Transport type changed to:', this.value);
    });
  }

  // Swap stations button
  const swapButton = document.getElementById('swap-stations');
  if (swapButton && startStationSelect && endStationSelect) {
    swapButton.addEventListener('click', function(e) {
      e.preventDefault();
      const startValue = startStationSelect.value;
      startStationSelect.value = endStationSelect.value;
      endStationSelect.value = startValue;
    });
  }
}
