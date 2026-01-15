// payment.js - Gestion du paiement avec vérification du stock

document.addEventListener('DOMContentLoaded', function() {
    const paymentForm = document.getElementById('payment-form');
    const paymentMethods = document.querySelectorAll('input[name="payment_method"]');
    const cardForm = document.getElementById('card-form');
    const mobileMoneyForm = document.getElementById('mobile-money-form');
    const cashDeliveryInfo = document.getElementById('cash-delivery-info');
    const submitBtn = document.getElementById('submit-payment');
    const loadingModal = document.getElementById('loading-modal');
    const stockErrorModal = document.getElementById('stock-error-modal');
    const savedAddressSelect = document.getElementById('saved-address');

    // Gestion du changement de méthode de paiement
    paymentMethods.forEach(method => {
        method.addEventListener('change', function() {
            // Cacher tous les formulaires
            cardForm.style.display = 'none';
            mobileMoneyForm.style.display = 'none';
            cashDeliveryInfo.style.display = 'none';

            // Afficher le formulaire approprié
            switch(this.value) {
                case 'card':
                    cardForm.style.display = 'block';
                    break;
                case 'orange_money':
                case 'mtn_momo':
                    mobileMoneyForm.style.display = 'block';
                    break;
                case 'cash_on_delivery':
                    cashDeliveryInfo.style.display = 'block';
                    break;
            }
        });
    });

    // Remplir l'adresse depuis une adresse enregistrée
    if (savedAddressSelect) {
        savedAddressSelect.addEventListener('change', function() {
            const option = this.options[this.selectedIndex];
            if (option.value) {
                document.getElementById('shipping_address').value = option.dataset.street || '';
                document.getElementById('shipping_city').value = option.dataset.city || '';
                document.getElementById('shipping_postal_code').value = option.dataset.postal || '';
                document.getElementById('shipping_country').value = option.dataset.country || '';
            }
        });
    }

    // Formatage du numéro de carte
    const cardNumberInput = document.getElementById('card_number');
    if (cardNumberInput) {
        cardNumberInput.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\s/g, '').replace(/\D/g, '');
            let formattedValue = value.match(/.{1,4}/g)?.join(' ') || value;
            e.target.value = formattedValue.substring(0, 19);
        });
    }

    // Formatage de la date d'expiration
    const cardExpiryInput = document.getElementById('card_expiry');
    if (cardExpiryInput) {
        cardExpiryInput.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length >= 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }
            e.target.value = value;
        });
    }

    // Soumission du formulaire
    paymentForm.addEventListener('submit', async function(e) {
        e.preventDefault();

        // Validation basique
        if (!validateForm()) {
            return;
        }

        // Afficher le modal de chargement
        showLoadingModal();

        // Collecter les données du formulaire
        const formData = new FormData(paymentForm);
        const data = Object.fromEntries(formData.entries());

        try {
            const response = await fetch('/payment/process/', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': getCsrfToken()
                },
                body: JSON.stringify(data)
            });

            const result = await response.json();

            if (result.success) {
                // Rediriger vers la page de confirmation
                window.location.href = result.redirect_url;
            } else {
                hideLoadingModal();
                
                if (result.stock_errors) {
                    showStockErrorModal(result.stock_errors);
                } else {
                    showNotification(result.error || 'Une erreur est survenue', 'error');
                }
            }
        } catch (error) {
            hideLoadingModal();
            console.error('Erreur:', error);
            showNotification('Une erreur de connexion est survenue. Veuillez réessayer.', 'error');
        }
    });

    // Validation du formulaire
    function validateForm() {
        const requiredFields = paymentForm.querySelectorAll('[required]');
        let isValid = true;

        requiredFields.forEach(field => {
            if (!field.value.trim()) {
                field.classList.add('error');
                isValid = false;
            } else {
                field.classList.remove('error');
            }
        });

        // Validation spécifique selon la méthode de paiement
        const selectedMethod = document.querySelector('input[name="payment_method"]:checked');
        
        if (selectedMethod) {
            switch(selectedMethod.value) {
                case 'card':
                    isValid = validateCardDetails() && isValid;
                    break;
                case 'orange_money':
                case 'mtn_momo':
                    const mobilePhone = document.getElementById('mobile_phone');
                    if (!mobilePhone.value.trim()) {
                        mobilePhone.classList.add('error');
                        isValid = false;
                    }
                    break;
            }
        }

        // Vérifier les conditions générales
        const termsCheckbox = document.getElementById('accept_terms');
        if (!termsCheckbox.checked) {
            showNotification('Veuillez accepter les conditions générales', 'warning');
            isValid = false;
        }

        return isValid;
    }

    // Validation des détails de la carte
    function validateCardDetails() {
        const cardNumber = document.getElementById('card_number').value.replace(/\s/g, '');
        const cardExpiry = document.getElementById('card_expiry').value;
        const cardCvv = document.getElementById('card_cvv').value;

        let isValid = true;

        // Validation numéro de carte (16 chiffres)
        if (!/^\d{16}$/.test(cardNumber)) {
            document.getElementById('card_number').classList.add('error');
            isValid = false;
        }

        // Validation date d'expiration
        if (!/^\d{2}\/\d{2}$/.test(cardExpiry)) {
            document.getElementById('card_expiry').classList.add('error');
            isValid = false;
        }

        // Validation CVV (3 ou 4 chiffres)
        if (!/^\d{3,4}$/.test(cardCvv)) {
            document.getElementById('card_cvv').classList.add('error');
            isValid = false;
        }

        return isValid;
    }

    // Afficher le modal de chargement
    function showLoadingModal() {
        loadingModal.style.display = 'flex';
        submitBtn.disabled = true;
    }

    // Cacher le modal de chargement
    function hideLoadingModal() {
        loadingModal.style.display = 'none';
        submitBtn.disabled = false;
    }

    // Afficher le modal d'erreur de stock
    function showStockErrorModal(stockErrors) {
        const detailsContainer = document.getElementById('stock-error-details');
        let html = '<ul class="stock-error-list">';
        
        stockErrors.forEach(error => {
            if (error.error) {
                html += `<li><strong>${error.product}</strong>: ${error.error}</li>`;
            } else {
                html += `<li>
                    <strong>${error.product}</strong>: 
                    Vous avez demandé ${error.requested} unité(s), 
                    mais seulement ${error.available} disponible(s)
                </li>`;
            }
        });
        
        html += '</ul>';
        detailsContainer.innerHTML = html;
        stockErrorModal.style.display = 'flex';
    }

    // Fermer le modal d'erreur de stock
    window.closeStockErrorModal = function() {
        stockErrorModal.style.display = 'none';
    };

    // Récupérer le token CSRF
    function getCsrfToken() {
        return document.querySelector('[name=csrfmiddlewaretoken]').value;
    }

    // Afficher une notification
    function showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.innerHTML = `
            <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
            <span>${message}</span>
            <button class="close-notification">&times;</button>
        `;
        
        document.body.appendChild(notification);
        
        // Animation d'entrée
        setTimeout(() => notification.classList.add('show'), 10);
        
        // Fermeture automatique après 5 secondes
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        }, 5000);
        
        // Fermeture manuelle
        notification.querySelector('.close-notification').addEventListener('click', () => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        });
    }

    // Vérification du stock en temps réel
    async function checkProductStock(productId, quantity) {
        try {
            const response = await fetch('/check-stock/', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': getCsrfToken()
                },
                body: JSON.stringify({ product_id: productId, quantity: quantity })
            });
            
            return await response.json();
        } catch (error) {
            console.error('Erreur lors de la vérification du stock:', error);
            return { available: true }; // Par défaut, on considère disponible
        }
    }

    // Vérifier le stock de tous les produits au chargement
    async function verifyAllStock() {
        const cartItems = document.querySelectorAll('.cart-item');
        
        for (const item of cartItems) {
            const productId = item.dataset.productId;
            const quantityEl = item.querySelector('.item-quantity');
            const quantity = parseInt(quantityEl.textContent.match(/\d+/)[0]);
            
            const stockInfo = await checkProductStock(productId, quantity);
            
            if (!stockInfo.available) {
                item.classList.add('stock-warning');
                const warningEl = item.querySelector('.stock-warning') || document.createElement('p');
                warningEl.className = 'stock-warning';
                warningEl.innerHTML = `<i class="fas fa-exclamation-triangle"></i> Stock limité (${stockInfo.stock} disponible(s))`;
                
                if (!item.querySelector('.stock-warning')) {
                    item.querySelector('.item-details').appendChild(warningEl);
                }
            }
        }
    }

    // Vérifier le stock au chargement de la page
    verifyAllStock();
});