// cart.js - Gestion de la page panier

document.addEventListener('DOMContentLoaded', function() {
    const cartItemsContainer = document.querySelector('.cart-items');
    const subtotalElement = document.querySelector('.subtotal');
    const totalElement = document.querySelector('.total');
    const promoCodeInput = document.getElementById('promoCode');
    const applyPromoBtn = document.querySelector('.apply-promo');
    const checkoutBtn = document.getElementById('checkout-btn');
    const checkoutForm = document.getElementById('checkout-form');
    const cartDataInput = document.getElementById('cart-data-input');

    // Initialisation
    function init() {
        console.log('Initialisation du panier...');
        loadCartItems();
        setupEventListeners();
        updateCheckoutButton();
    }

    // Charger les articles du panier
    function loadCartItems() {
        let cart = JSON.parse(localStorage.getItem('cart')) || [];
        console.log('Panier chargé:', cart);
        
        if (cart.length === 0) {
            renderEmptyCart();
            return;
        }

        renderCartItems(cart);
        updateTotals(cart);
    }

    // Afficher le panier vide
    function renderEmptyCart() {
        if (cartItemsContainer) {
            cartItemsContainer.innerHTML = `
                <div class="empty-cart">
                    <i class="fas fa-shopping-cart"></i>
                    <h2>Votre panier est vide</h2>
                    <p>Découvrez nos produits et commencez votre shopping</p>
                    <a href="/products/" class="start-shopping">Commencer les achats</a>
                </div>
            `;
        }
        // Cacher le résumé
        const cartSummary = document.querySelector('.cart-summary');
        if (cartSummary) {
            cartSummary.style.display = 'none';
        }
        // Désactiver le bouton
        if (checkoutBtn) {
            checkoutBtn.disabled = true;
        }
    }

    // Afficher les articles du panier
    function renderCartItems(cart) {
        if (!cartItemsContainer) return;
        
        let cartHTML = `
            <div class="cart-header">
                <div class="product-info-header">Produit</div>
                <div class="quantity-header">Quantité</div>
                <div class="price-header">Prix</div>
                <div class="total-header">Total</div>
                <div class="remove-header"></div>
            </div>
        `;

        cart.forEach(item => {
            const itemTotal = item.price * item.quantity;
            cartHTML += `
                <div class="cart-item" data-id="${item.id}" data-stock="${item.stock || 999}">
                    <div class="product-info">
                        <img src="${item.image}" alt="${item.name}" onerror="this.src='/static/img/placeholder.jpg'">
                        <div class="product-details">
                            <h3>${item.name}</h3>
                        </div>
                    </div>
                    <div class="quantity-controls">
                        <button class="quantity-btn minus" data-id="${item.id}">-</button>
                        <input type="number" class="quantity-input" value="${item.quantity}" min="1" max="${item.stock || 999}">
                        <button class="quantity-btn plus" data-id="${item.id}">+</button>
                    </div>
                    <div class="price">${item.price.toLocaleString()} F CFA</div>
                    <div class="total">${itemTotal.toLocaleString()} F CFA</div>
                    <button class="remove-btn" data-id="${item.id}">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            `;
        });

        cartItemsContainer.innerHTML = cartHTML;
        
        // Afficher le résumé
        const cartSummary = document.querySelector('.cart-summary');
        if (cartSummary) {
            cartSummary.style.display = 'block';
        }
    }

    // Configurer les écouteurs d'événements
    function setupEventListeners() {
        if (cartItemsContainer) {
            // Boutons + et -
            cartItemsContainer.addEventListener('click', function(e) {
                const btn = e.target.closest('.quantity-btn');
                if (btn) {
                    const itemId = btn.dataset.id;
                    const isPlus = btn.classList.contains('plus');
                    updateQuantity(itemId, isPlus ? 1 : -1);
                }
                
                // Bouton supprimer
                const removeBtn = e.target.closest('.remove-btn');
                if (removeBtn) {
                    removeItem(removeBtn.dataset.id);
                }
            });
            
            // Changement direct de quantité
            cartItemsContainer.addEventListener('change', function(e) {
                if (e.target.classList.contains('quantity-input')) {
                    const cartItem = e.target.closest('.cart-item');
                    const itemId = cartItem.dataset.id;
                    const newQuantity = parseInt(e.target.value);
                    updateItemQuantity(itemId, newQuantity);
                }
            });
        }
        
        // Bouton appliquer code promo
        if (applyPromoBtn && promoCodeInput) {
            applyPromoBtn.addEventListener('click', function() {
                const promoCode = promoCodeInput.value.trim();
                if (promoCode) {
                    applyPromoCode(promoCode);
                }
            });
        }
        
        // Formulaire de checkout
        if (checkoutForm) {
            checkoutForm.addEventListener('submit', function(e) {
                const cart = JSON.parse(localStorage.getItem('cart')) || [];
                console.log('Soumission du panier:', cart);
                
                if (cart.length === 0) {
                    e.preventDefault();
                    alert('Votre panier est vide');
                    return false;
                }
                
                // Synchroniser le panier avec le serveur via session
                syncCartToServer(cart);
                
                // Mettre les données dans le champ caché
                if (cartDataInput) {
                    cartDataInput.value = JSON.stringify(cart);
                }
                
                return true;
            });
        }
    }

    // Synchroniser le panier avec le serveur
    function syncCartToServer(cart) {
        // Envoyer le panier au serveur pour le stocker en session
        fetch('/cart/sync/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': getCsrfToken()
            },
            body: JSON.stringify({ cart: cart })
        }).catch(err => console.log('Sync error:', err));
    }

    // Récupérer le token CSRF
    function getCsrfToken() {
        const csrfInput = document.querySelector('[name=csrfmiddlewaretoken]');
        return csrfInput ? csrfInput.value : '';
    }

    // Mettre à jour la quantité d'un article
    function updateQuantity(itemId, change) {
        let cart = JSON.parse(localStorage.getItem('cart')) || [];
        const itemIndex = cart.findIndex(item => item.id == itemId);
        
        if (itemIndex > -1) {
            const item = cart[itemIndex];
            const newQuantity = item.quantity + change;
            
            if (newQuantity <= 0) {
                removeItem(itemId);
                return;
            }
            
            if (newQuantity > (item.stock || 999)) {
                window.showNotification && window.showNotification(`Stock limité à ${item.stock} unités`, 'warning');
                return;
            }
            
            item.quantity = newQuantity;
            localStorage.setItem('cart', JSON.stringify(cart));
            renderCartItems(cart);
            updateTotals(cart);
            updateCheckoutButton();
        }
    }

    // Définir une quantité spécifique
    function updateItemQuantity(itemId, newQuantity) {
        let cart = JSON.parse(localStorage.getItem('cart')) || [];
        const itemIndex = cart.findIndex(item => item.id == itemId);
        
        if (itemIndex > -1) {
            const item = cart[itemIndex];
            
            if (newQuantity <= 0) {
                removeItem(itemId);
                return;
            }
            
            if (newQuantity > (item.stock || 999)) {
                window.showNotification && window.showNotification(`Stock limité à ${item.stock} unités`, 'warning');
                return;
            }
            
            item.quantity = newQuantity;
            localStorage.setItem('cart', JSON.stringify(cart));
            renderCartItems(cart);
            updateTotals(cart);
            updateCheckoutButton();
        }
    }

    // Supprimer un article
    function removeItem(itemId) {
        let cart = JSON.parse(localStorage.getItem('cart')) || [];
        cart = cart.filter(item => item.id != itemId);
        localStorage.setItem('cart', JSON.stringify(cart));
        
        if (cart.length === 0) {
            renderEmptyCart();
        } else {
            renderCartItems(cart);
            updateTotals(cart);
        }
        updateCheckoutButton();
        window.showNotification && window.showNotification('Article supprimé du panier');
    }

    // Appliquer un code promo
    function applyPromoCode(code) {
        if (code.toUpperCase() === 'WELCOME') {
            const cart = JSON.parse(localStorage.getItem('cart')) || [];
            updateTotals(cart, 0.1);
            window.showNotification && window.showNotification('Code promo appliqué : 10% de réduction');
            if (promoCodeInput) promoCodeInput.disabled = true;
            if (applyPromoBtn) applyPromoBtn.disabled = true;
        } else {
            window.showNotification && window.showNotification('Code promo invalide', 'error');
        }
    }

    // Mettre à jour les totaux
    function updateTotals(cart, discount = 0) {
        const subtotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        const discountAmount = subtotal * discount;
        const total = subtotal - discountAmount;
        
        if (subtotalElement) {
            subtotalElement.textContent = `${subtotal.toLocaleString()} F CFA`;
        }
        if (totalElement) {
            totalElement.textContent = `${total.toLocaleString()} F CFA`;
        }
    }

    // Activer/désactiver le bouton checkout
    function updateCheckoutButton() {
        const cart = JSON.parse(localStorage.getItem('cart')) || [];
        console.log('Mise à jour bouton checkout, articles:', cart.length);
        if (checkoutBtn) {
            checkoutBtn.disabled = cart.length === 0;
            console.log('Bouton disabled:', checkoutBtn.disabled);
        }
    }

    // Mise à jour du compteur du panier
    function updateCartCount() {
        const cart = JSON.parse(localStorage.getItem('cart')) || [];
        const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
        
        document.querySelectorAll('.cart-count').forEach(element => {
            element.textContent = totalItems;
        });
    }

    // Démarrer l'initialisation
    init();
});