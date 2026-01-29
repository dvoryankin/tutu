// Stimulus controller for payment form validation
document.addEventListener('DOMContentLoaded', function() {
  initializePayment();
});

document.addEventListener('turbolinks:load', function() {
  initializePayment();
});

function initializePayment() {
  const paymentForm = document.getElementById('payment-form');
  const paymentMethodInputs = document.querySelectorAll('input[name="payment_method"]');
  const cardDetails = document.getElementById('card-details');

  // Toggle card details visibility based on payment method
  if (paymentMethodInputs.length > 0 && cardDetails) {
    paymentMethodInputs.forEach(function(input) {
      input.addEventListener('change', function() {
        if (this.value === 'card') {
          cardDetails.style.display = 'block';
        } else {
          cardDetails.style.display = 'none';
        }
      });
    });
  }

  // Card number formatting
  const cardNumberInput = document.querySelector('input[name="card_number"]');
  if (cardNumberInput) {
    cardNumberInput.addEventListener('input', function(e) {
      let value = this.value.replace(/\s/g, '').replace(/\D/g, '');
      let formatted = '';

      for (let i = 0; i < value.length && i < 16; i++) {
        if (i > 0 && i % 4 === 0) {
          formatted += ' ';
        }
        formatted += value[i];
      }

      this.value = formatted;
    });
  }

  // Expiry date formatting
  const expiryInput = document.querySelector('input[name="card_expiry"]');
  if (expiryInput) {
    expiryInput.addEventListener('input', function(e) {
      let value = this.value.replace(/\D/g, '');
      if (value.length >= 2) {
        value = value.substring(0, 2) + '/' + value.substring(2, 4);
      }
      this.value = value;
    });
  }

  // CVV validation
  const cvvInput = document.querySelector('input[name="card_cvv"]');
  if (cvvInput) {
    cvvInput.addEventListener('input', function(e) {
      this.value = this.value.replace(/\D/g, '').substring(0, 4);
    });
  }

  // Form validation
  if (paymentForm) {
    paymentForm.addEventListener('submit', function(e) {
      const selectedMethod = document.querySelector('input[name="payment_method"]:checked');

      if (selectedMethod && selectedMethod.value === 'card') {
        const cardNumber = cardNumberInput ? cardNumberInput.value.replace(/\s/g, '') : '';
        const expiry = expiryInput ? expiryInput.value : '';
        const cvv = cvvInput ? cvvInput.value : '';

        if (cardNumber.length < 16) {
          e.preventDefault();
          alert('Please enter a valid card number');
          return;
        }

        if (!/^\d{2}\/\d{2}$/.test(expiry)) {
          e.preventDefault();
          alert('Please enter a valid expiry date (MM/YY)');
          return;
        }

        if (cvv.length < 3) {
          e.preventDefault();
          alert('Please enter a valid CVV');
          return;
        }
      }
    });
  }
}
