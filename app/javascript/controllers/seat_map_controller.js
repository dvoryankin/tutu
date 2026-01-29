// Stimulus controller for interactive seat map
document.addEventListener('DOMContentLoaded', function() {
  initializeSeatMap();
});

document.addEventListener('turbolinks:load', function() {
  initializeSeatMap();
});

function initializeSeatMap() {
  const seatMaps = document.querySelectorAll('.seat-map');

  seatMaps.forEach(function(seatMap) {
    const seats = seatMap.querySelectorAll('.seat.available');
    const form = document.getElementById('seat-reservation-form');
    const seatIdInput = document.getElementById('seat_id_input');
    const selectedInfo = document.getElementById('selected-seat-info');
    const selectedPrice = document.getElementById('selected-seat-price');

    let selectedSeat = null;

    seats.forEach(function(seat) {
      seat.addEventListener('click', function() {
        // Deselect previous seat
        if (selectedSeat) {
          selectedSeat.classList.remove('selected');
          selectedSeat.classList.add('available');
        }

        // Select new seat
        seat.classList.remove('available');
        seat.classList.add('selected');
        selectedSeat = seat;

        // Update form
        const seatId = seat.dataset.seatId;
        const seatNumber = seat.dataset.seatNumber;
        const seatType = seat.dataset.seatType;
        const price = seat.dataset.price;

        if (form) {
          form.classList.remove('d-none');
          form.action = '/seats/' + seatId + '/select';
        }

        if (seatIdInput) {
          seatIdInput.value = seatId;
        }

        if (selectedInfo) {
          selectedInfo.textContent = 'Seat ' + seatNumber + ' (' + seatType + ')';
        }

        if (selectedPrice) {
          selectedPrice.textContent = formatCurrency(price) + ' RUB';
        }
      });
    });
  });
}

function formatCurrency(amount) {
  return parseFloat(amount).toLocaleString('ru-RU', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });
}
