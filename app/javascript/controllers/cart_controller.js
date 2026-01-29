// Stimulus controller for cart functionality
document.addEventListener('DOMContentLoaded', function() {
  initializeCart();
});

document.addEventListener('turbolinks:load', function() {
  initializeCart();
});

function initializeCart() {
  // Confirm before removing items
  const removeButtons = document.querySelectorAll('[data-confirm]');
  removeButtons.forEach(function(button) {
    button.addEventListener('click', function(e) {
      const message = this.dataset.confirm;
      if (!confirm(message)) {
        e.preventDefault();
      }
    });
  });

  // Update cart count in navbar (could be enhanced with AJAX)
  updateCartBadge();
}

function updateCartBadge() {
  // This could make an AJAX call to get current cart count
  // For now, it's updated on page load from server
}

// Add item to cart via AJAX (optional enhancement)
function addToCart(seatId, passengerData) {
  return fetch('/cart/add_item', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
    },
    body: JSON.stringify({
      seat_id: seatId,
      ...passengerData
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      updateCartBadge();
    }
    return data;
  });
}

// Remove item from cart via AJAX (optional enhancement)
function removeFromCart(ticketId) {
  return fetch('/cart/remove_item', {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
    },
    body: JSON.stringify({
      ticket_id: ticketId
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      updateCartBadge();
    }
    return data;
  });
}
