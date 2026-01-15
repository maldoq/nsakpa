# Test des endpoints Orders

Script pour tester manuellement tous les endpoints de l'API Orders.

## Prérequis

1. Backend Django doit être lancé:
```bash
cd backend
python manage.py runserver
```

2. Avoir au moins 2 utilisateurs en base de données:
   - Un artisan (avec des produits)
   - Un acheteur

---

## Étape 1: Obtenir les tokens d'authentification

### Token Artisan
```bash
curl -X POST http://127.0.0.1:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"votre_artisan","password":"votre_password"}'
```

**Remplacez:** `votre_artisan` et `votre_password`

**Notez le token:** `eyJ0eXAiOiJKV1Qi...`

### Token Acheteur
```bash
curl -X POST http://127.0.0.1:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"votre_acheteur","password":"votre_password"}'
```

**Notez le token:** `eyJ0eXAiOiJKV1Qi...`

---

## Étape 2: Créer une commande (en tant qu'acheteur)

```bash
curl -X POST http://127.0.0.1:8000/api/orders/ \
  -H "Authorization: Bearer <TOKEN_ACHETEUR>" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {
        "product_id": 1,
        "quantity": 2
      }
    ],
    "delivery_address": "Abidjan, Cocody Riviera",
    "delivery_phone": "0700000000",
    "payment_method": "orange_money"
  }'
```

**Remplacez:**
- `<TOKEN_ACHETEUR>` par le token de l'acheteur
- `product_id: 1` par un ID de produit existant dans votre base

**Réponse attendue:**
```json
{
  "id": 1,
  "buyer_id": "2",
  "buyer_name": "Jean Acheteur",
  "status": "pending",
  "total_amount": "15000",
  ...
}
```

**Notez l'ID de la commande:** `1`

---

## Étape 3: Payer la commande

```bash
curl -X POST http://127.0.0.1:8000/api/orders/pay/ \
  -H "Authorization: Bearer <TOKEN_ACHETEUR>" \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "1",
    "payment_method": "orange_money",
    "phone_number": "0700000000"
  }'
```

**Réponse attendue:**
```json
{
  "success": true,
  "message": "Paiement effectué avec succès",
  "transaction_id": "TXN_123ABC...",
  "order": {
    "id": 1,
    "status": "paid",
    "is_paid": true,
    ...
  }
}
```

---

## Étape 4: Voir les commandes (artisan)

```bash
curl -H "Authorization: Bearer <TOKEN_ARTISAN>" \
  http://127.0.0.1:8000/api/orders/artisan/
```

**Réponse attendue:** Liste des commandes contenant vos produits

---

## Étape 5: Confirmer la commande (artisan)

Le statut passe de `pending` ou `paid` à `paid` (confirmation artisan).

```bash
curl -X PATCH http://127.0.0.1:8000/api/orders/1/update_status/ \
  -H "Authorization: Bearer <TOKEN_ARTISAN>" \
  -H "Content-Type: application/json" \
  -d '{"status": "paid"}'
```

**Réponse attendue:**
```json
{
  "id": 1,
  "status": "paid",
  "confirmed_at": "2026-01-15T10:05:00Z",
  ...
}
```

---

## Étape 6: Commencer la préparation (artisan)

```bash
curl -X PATCH http://127.0.0.1:8000/api/orders/1/update_status/ \
  -H "Authorization: Bearer <TOKEN_ARTISAN>" \
  -H "Content-Type: application/json" \
  -d '{"status": "preparing"}'
```

**Réponse attendue:**
```json
{
  "id": 1,
  "status": "preparing",
  ...
}
```

---

## Étape 7: Marquer comme prêt (artisan)

Flutter envoie `ready_for_pickup`, Django le mappe vers `delivering`.

```bash
curl -X PATCH http://127.0.0.1:8000/api/orders/1/update_status/ \
  -H "Authorization: Bearer <TOKEN_ARTISAN>" \
  -H "Content-Type: application/json" \
  -d '{"status": "ready_for_pickup"}'
```

**Réponse attendue:**
```json
{
  "id": 1,
  "status": "delivering",
  ...
}
```

---

## Étape 8: Marquer comme livré (artisan)

```bash
curl -X PATCH http://127.0.0.1:8000/api/orders/1/update_status/ \
  -H "Authorization: Bearer <TOKEN_ARTISAN>" \
  -H "Content-Type: application/json" \
  -d '{"status": "delivered"}'
```

**Réponse attendue:**
```json
{
  "id": 1,
  "status": "delivered",
  "is_delivered": true,
  "delivered_at": "2026-01-15T14:30:00Z",
  ...
}
```

---

## Étape 9: Confirmer la réception (acheteur)

```bash
curl -X PATCH http://127.0.0.1:8000/api/orders/1/confirm_received/ \
  -H "Authorization: Bearer <TOKEN_ACHETEUR>"
```

**Réponse attendue:**
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

## Étape 10: Voir mes commandes (acheteur)

```bash
curl -H "Authorization: Bearer <TOKEN_ACHETEUR>" \
  http://127.0.0.1:8000/api/orders/my/
```

**Réponse attendue:** Liste de toutes vos commandes avec statuts mis à jour

---

## 🧪 Tests supplémentaires

### Annuler une commande (avant livraison)

```bash
curl -X POST http://127.0.0.1:8000/api/orders/1/cancel/ \
  -H "Authorization: Bearer <TOKEN_ACHETEUR>"
```

**Conditions:**
- Statut doit être `pending`, `paid`, ou `preparing`
- Pas encore `delivered` ou `cancelled`

**Réponse attendue:**
```json
{
  "success": true,
  "message": "Commande annulée"
}
```

**Effet:** Le stock des produits est restauré.

---

### Voir toutes les commandes (admin)

Si vous avez un utilisateur admin/staff:

```bash
curl -H "Authorization: Bearer <TOKEN_ADMIN>" \
  http://127.0.0.1:8000/api/orders/
```

**Réponse attendue:** TOUTES les commandes de tous les utilisateurs

---

## ✅ Checklist de validation

- [ ] Créer une commande (acheteur)
- [ ] Payer la commande (acheteur)
- [ ] Voir les commandes artisan (artisan)
- [ ] Confirmer la commande (artisan)
- [ ] Démarrer la préparation (artisan)
- [ ] Marquer comme prêt (artisan)
- [ ] Marquer comme livré (artisan)
- [ ] Confirmer la réception (acheteur)
- [ ] Voir mes commandes (acheteur)
- [ ] Annuler une commande (acheteur)
- [ ] Voir toutes les commandes (admin)

---

## 🐛 Résolution de problèmes

### Erreur 401 Unauthorized
- Le token est expiré ou invalide
- Redemander un nouveau token

### Erreur 403 Forbidden
- Vous n'avez pas les permissions pour cette action
- Ex: Un acheteur ne peut pas modifier le statut d'une commande

### Erreur 404 Not Found
- La commande n'existe pas
- Vérifiez l'ID de la commande

### Erreur 400 Bad Request
- Les données envoyées sont invalides
- Vérifiez le format JSON
- Vérifiez que tous les champs requis sont présents

### Le statut ne change pas
- Vérifiez que vous utilisez le bon token (artisan ou acheteur)
- Vérifiez que le statut actuel permet le changement
- Ex: On ne peut pas passer de `delivered` à `preparing`

---

## 📝 Notes

1. Remplacez toujours `<TOKEN_ACHETEUR>` et `<TOKEN_ARTISAN>` par vos vrais tokens
2. Les IDs de commande et de produit doivent exister dans votre base
3. Testez dans l'ordre des étapes pour un workflow complet
4. Les timestamps sont en UTC (format ISO 8601)
