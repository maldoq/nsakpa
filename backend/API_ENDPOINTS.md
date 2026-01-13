# Documentation API N'SAPKA

Cette API est construite avec Django REST Framework.

**URL de base :**
- Développement local : `http://127.0.0.1:8000/api/`
- Émulateur Android : `http://10.0.2.2:8000/api/`
- Appareil réel (même WiFi) : `http://<TON_IP_LOCALE>:8000/api/`

---

## 🔐 Authentification & Utilisateurs (Users)

| Méthode | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/users/` | **Inscription**. Body: `username`, `password`, `email`, `role`, `phone` |
| `GET` | `/users/` | Liste de tous les utilisateurs (Admin) |
| `GET` | `/users/{id}/` | Voir un profil (Artisan ou Acheteur) |
| `PATCH` | `/users/{id}/` | Mise à jour profil (Photo, Bio, etc.) |

**Utilisateur (JSON Sample) :**
```json
{
    "username": "yohann_artisan",
    "password": "monMotDePasse",
    "email": "yohann@nsapka.ci",
    "role": "artisan",  // 'buyer' ou 'artisan'
    "phone": "+22507070707",
    "stand_name": "Yohann Arts",
    "specialties": ["sculpture", "bijoux"]
}
```

---

## 🛍️ Produits (Products)

| Méthode | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/products/` | **Catalogue**. Liste complète des produits. |
| `POST` | `/products/` | **Ajouter un produit** (Artisan seulement). |
| `GET` | `/products/{id}/` | Détails d'un produit spécifique. |
| `GET` | `/products/?search=bronze` | Recherche par nom ou description. |

**Produit (JSON Sample) :**
```json
{
    "artisan": 1, // ID de l'artisan connecté
    "name": "Masque Baoulé",
    "description": "Masque traditionnel en bois...",
    "price": 25000,
    "category": "Sculpture",
    "stock": 5,
    "is_limited_edition": true,
    "origin": "Bouaké",
    "tags": ["tradition", "bois"]
}
```

---

## 📦 Commandes (Orders)

| Méthode | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/orders/` | **Passer une commande**. Après validation du panier. |
| `GET` | `/orders/` | Historique de mes commandes. |
| `GET` | `/orders/{id}/` | Détails et statut d'une commande. |

**Commande (JSON Sample) :**
```json
{
    "buyer": 2, // ID de l'acheteur
    "total_amount": 50000,
    "delivery_address": "Cocody Riviera, Abidjan",
    "delivery_phone": "+22501020304",
    "payment_method": "orange_money",
    "items": [
        {
            "product": 5,
            "quantity": 1,
            "unit_price": 25000
        },
        {
            "product": 8,
            "quantity": 2,
            "unit_price": 12500
        }
    ]
}
```

---

## 💬 Social (Chat & Avis)

| Méthode | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/reviews/` | Laisser un avis sur un produit ou artisan. |
| `GET` | `/conversations/` | Voir mes chats en cours. |
| `POST` | `/messages/` | Envoyer un message dans une conversation. |

---

## 🚀 Étapes pour tester

1. Lance le serveur :
   ```bash
   python manage.py runserver
   ```
2. Ouvre `http://127.0.0.1:8000/api/` dans ton navigateur.
3. Tu verras la liste des endpoints cliquables.

## 📱 Note pour Flutter

Dans ton code Flutter, change l'URL de base selon ton environnement :

```dart
// lib/core/constants/api_constants.dart

import 'dart:io';

String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000/api';
  } else {
    // iOS ou Web
    return 'http://127.0.0.1:8000/api';
  }
}
```
