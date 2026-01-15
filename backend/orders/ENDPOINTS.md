# API Endpoints - Orders (Commandes)

## Base URL
`http://127.0.0.1:8000/api/orders/`

## Authentification
Tous les endpoints nécessitent un token JWT dans le header:
```
Authorization: Bearer <token>
```

---

## 📋 Endpoints disponibles

### 1. **Liste des commandes (pour l'utilisateur connecté)**
**GET** `/api/orders/`

Retourne les commandes selon le rôle :
- **Admin/Staff** : Toutes les commandes
- **Artisan** : Ses commandes en tant qu'acheteur + commandes contenant ses produits
- **Acheteur** : Uniquement ses commandes

**Réponse :**
```json
[
  {
    "id": 1,
    "buyer_id": "4",
    "buyer_name": "John Doe",
    "artisan_id": "5",
    "artisan_name": "Marie Artisan",
    "status": "paid",
    "status_display": "Payé",
    "total_amount": "15000",
    "subtotal": "15000",
    "delivery_fee": "0",
    "delivery_address": "Abidjan, Cocody",
    "delivery_phone": "0700000000",
    "payment_method": "orange_money",
    "payment_status": "inescrow",
    "transaction_id": "TXN_ABC123",
    "is_paid": true,
    "is_delivered": false,
    "is_received": false,
    "created_at": "2026-01-15T10:00:00Z",
    "confirmed_at": "2026-01-15T10:05:00Z",
    "delivered_at": null,
    "received_at": null,
    "updated_at": "2026-01-15T10:05:00Z",
    "items": [
      {
        "id": 1,
        "product_id": 10,
        "product_name": "Masque Baoulé",
        "product_image": "http://127.0.0.1:8000/media/products/masque.jpg",
        "quantity": 2,
        "unit_price": "7500",
        "total_price": "15000",
        "artisan_name": "Marie Artisan"
      }
    ]
  }
]
```

---

### 2. **Mes commandes (acheteur)**
**GET** `/api/orders/my/`

**Query params (optionnel):**
- `limit` : Limiter le nombre de résultats (ex: `?limit=3`)

**Réponse :** Même format que `/api/orders/`

---

### 3. **Commandes artisan**
**GET** `/api/orders/artisan/`

Retourne toutes les commandes qui contiennent des produits de l'artisan connecté.

**Réponse :** Même format que `/api/orders/`

---

### 4. **Créer une commande**
**POST** `/api/orders/`

**Body :**
```json
{
  "items": [
    {
      "product_id": 10,
      "quantity": 2
    },
    {
      "product_id": 12,
      "quantity": 1
    }
  ],
  "delivery_address": "Abidjan, Cocody",
  "delivery_phone": "0700000000",
  "payment_method": "orange_money"
}
```

**Réponse :**
```json
{
  "id": 1,
  "buyer_id": "4",
  "buyer_name": "John Doe",
  "status": "pending",
  "total_amount": "22500",
  "items": [...]
}
```

---

### 5. **Payer une commande**
**POST** `/api/orders/pay/`

**Body :**
```json
{
  "order_id": "1",
  "payment_method": "orange_money",
  "phone_number": "0700000000"
}
```

**Réponse :**
```json
{
  "success": true,
  "message": "Paiement effectué avec succès",
  "transaction_id": "TXN_ABC123XYZ",
  "order": {
    "id": 1,
    "status": "paid",
    "is_paid": true,
    ...
  }
}
```

---

### 6. **Mettre à jour le statut**
**PATCH** `/api/orders/{id}/update_status/`

**Body :**
```json
{
  "status": "preparing"
}
```

**Statuts valides :**
- `pending` : En attente
- `paid` : Payé
- `preparing` : En préparation
- `ready_for_pickup` : Prêt pour enlèvement (mappé vers `delivering`)
- `delivering` : En livraison
- `delivered` : Livré
- `cancelled` : Annulé

**Réponse :**
```json
{
  "id": 1,
  "status": "preparing",
  ...
}
```

---

### 7. **Confirmer la réception (client)**
**PATCH** `/api/orders/{id}/confirm_received/`

**Body :**
```json
{}
```

**Conditions :**
- L'utilisateur doit être l'acheteur de la commande
- La commande doit avoir le statut `delivered`

**Réponse :**
```json
{
  "success": true,
  "message": "Réception confirmée avec succès",
  "order": {
    "id": 1,
    "is_received": true,
    "received_at": "2026-01-15T15:30:00Z",
    ...
  }
}
```

---

### 8. **Confirmer la livraison**
**POST** `/api/orders/{id}/confirm-delivery/`

Permet à l'acheteur de confirmer qu'il a reçu la livraison.

**Conditions :**
- L'utilisateur doit être l'acheteur
- Le statut doit être `delivering`

**Réponse :**
```json
{
  "success": true,
  "message": "Livraison confirmée"
}
```

---

### 9. **Annuler une commande**
**POST** `/api/orders/{id}/cancel/`

**Conditions :**
- L'utilisateur doit être l'acheteur
- La commande ne doit pas être `delivered` ou `cancelled`

**Effet :**
- Change le statut vers `cancelled`
- Remet le stock des produits

**Réponse :**
```json
{
  "success": true,
  "message": "Commande annulée"
}
```

---

## 🔄 Workflow typique

### Pour un acheteur :
1. `POST /api/orders/` - Créer la commande
2. `POST /api/orders/pay/` - Payer la commande
3. `GET /api/orders/my/` - Suivre l'état
4. `PATCH /api/orders/{id}/confirm_received/` - Confirmer réception

### Pour un artisan :
1. `GET /api/orders/artisan/` - Voir les nouvelles commandes
2. `PATCH /api/orders/{id}/update_status/` - Passer en `paid` (confirmer)
3. `PATCH /api/orders/{id}/update_status/` - Passer en `preparing`
4. `PATCH /api/orders/{id}/update_status/` - Passer en `ready_for_pickup`
5. `PATCH /api/orders/{id}/update_status/` - Passer en `delivered`

### Pour un admin :
1. `GET /api/orders/` - Voir toutes les commandes
2. Peut utiliser tous les endpoints de modification

---

## 📝 Notes importantes

1. **Permissions** : Tous les endpoints nécessitent une authentification
2. **Stock** : Le stock est automatiquement géré lors de la création/annulation
3. **Mapping de statuts** : `ready_for_pickup` est automatiquement mappé vers `delivering`
4. **Dates** : `confirmed_at`, `delivered_at`, `received_at` sont gérés automatiquement
5. **Notifications** : À implémenter pour notifier les artisans des nouvelles commandes

---

## 🐛 Codes d'erreur courants

- **400 Bad Request** : Données invalides ou manquantes
- **403 Forbidden** : Pas les droits d'accès à cette commande
- **404 Not Found** : Commande introuvable
- **500 Internal Server Error** : Erreur serveur

---

## 🧪 Tester avec cURL

```bash
# Liste des commandes
curl -H "Authorization: Bearer <token>" \
  http://127.0.0.1:8000/api/orders/

# Créer une commande
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"items":[{"product_id":1,"quantity":2}],"delivery_address":"Abidjan","delivery_phone":"0700000000"}' \
  http://127.0.0.1:8000/api/orders/

# Mettre à jour le statut
curl -X PATCH \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"status":"preparing"}' \
  http://127.0.0.1:8000/api/orders/1/update_status/
```
