# Intégration Flutter - Orders API

Guide complet pour utiliser les endpoints des commandes dans l'application Flutter.

---

## 🔗 Configuration ApiService

```dart
// lib/core/services/api_service.dart

class RemoteApiService extends ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
  
  // Headers avec authentification
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
```

---

## 📖 Exemples d'utilisation par page

### 1️⃣ **Page Acheteur** (`BuyerOrdersScreen`)

#### Charger mes commandes
```dart
Future<void> _loadMyOrders() async {
  setState(() => _isLoading = true);
  
  try {
    final orders = await _apiService.getBuyerOrders();
    setState(() {
      _orders = orders;
      _filteredOrders = orders;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

**API Endpoint utilisé:**
```
GET /api/orders/my/
```

#### Confirmer la réception d'une commande
```dart
Future<void> _confirmReceived(int orderId) async {
  try {
    await _apiService.confirmReceived(orderId);
    
    // Synchroniser avec OrderService
    final updatedOrder = await _apiService.getOrderById(orderId);
    OrderService().updateOrder(updatedOrder);
    
    // Recharger les données
    await _loadMyOrders();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Réception confirmée avec succès')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e')),
    );
  }
}
```

**API Endpoint utilisé:**
```
PATCH /api/orders/{id}/confirm_received/
```

---

### 2️⃣ **Page Artisan** (`ArtisanOrderManagementScreen`)

#### Charger les commandes artisan
```dart
Future<void> _loadArtisanOrders() async {
  setState(() => _isLoading = true);
  
  try {
    final orders = await _apiService.getArtisanOrders();
    setState(() {
      _orders = orders;
      _filteredOrders = _applyFilter(orders);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

**API Endpoint utilisé:**
```
GET /api/orders/artisan/
```

#### Confirmer une commande (paid)
```dart
Future<void> _confirmOrder(OrderModel order) async {
  try {
    await _apiService.updateOrderStatus(order.id, 'paid');
    
    // Synchroniser avec OrderService
    OrderService().confirmOrder(order.id);
    
    // Recharger
    await _loadArtisanOrders();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Commande confirmée')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e')),
    );
  }
}
```

**API Endpoint utilisé:**
```
PATCH /api/orders/{id}/update_status/
Body: { "status": "paid" }
```

#### Commencer la préparation
```dart
Future<void> _startPreparation(OrderModel order) async {
  try {
    await _apiService.updateOrderStatus(order.id, 'preparing');
    OrderService().startPreparation(order.id);
    await _loadArtisanOrders();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Préparation commencée')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e')),
    );
  }
}
```

**API Endpoint utilisé:**
```
PATCH /api/orders/{id}/update_status/
Body: { "status": "preparing" }
```

#### Marquer comme prêt
```dart
Future<void> _markReady(OrderModel order) async {
  try {
    // Flutter envoie 'ready_for_pickup', Django le mappe vers 'delivering'
    await _apiService.updateOrderStatus(order.id, 'ready_for_pickup');
    OrderService().markReady(order.id);
    await _loadArtisanOrders();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Commande prête pour enlèvement')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e')),
    );
  }
}
```

**API Endpoint utilisé:**
```
PATCH /api/orders/{id}/update_status/
Body: { "status": "ready_for_pickup" }
Note: Le backend mappe automatiquement vers "delivering"
```

#### Marquer comme livré
```dart
Future<void> _markAsDelivered(OrderModel order) async {
  try {
    await _apiService.updateOrderStatus(order.id, 'delivered');
    OrderService().markAsDelivered(order.id);
    await _loadArtisanOrders();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Commande marquée comme livrée')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e')),
    );
  }
}
```

**API Endpoint utilisé:**
```
PATCH /api/orders/{id}/update_status/
Body: { "status": "delivered" }
```

---

### 3️⃣ **Page Admin** (`AdminOrdersScreen`)

#### Charger toutes les commandes
```dart
Future<void> _loadAllOrders() async {
  setState(() => _isLoading = true);
  
  try {
    // L'admin voit TOUTES les commandes
    final orders = await _apiService.getAllOrders();
    setState(() {
      _orders = orders;
      _filteredOrders = orders;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

**API Endpoint utilisé:**
```
GET /api/orders/
Note: Seuls les staff/admin peuvent voir toutes les commandes
```

#### Mettre à jour le statut (admin)
```dart
Future<void> _updateOrderStatus(int orderId, String newStatus) async {
  try {
    await _apiService.updateOrderStatus(orderId, newStatus);
    await _loadAllOrders();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Statut mis à jour')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e')),
    );
  }
}
```

---

## 🔄 OrderService - Synchronisation

Le `OrderService` est un singleton qui synchronise les données entre toutes les pages.

```dart
// Utilisation basique
import 'package:nsapka/core/services/order_service.dart';

// Écouter les changements
OrderService().addListener(() {
  // Les données ont changé, recharger l'UI
  setState(() {
    _orders = OrderService().orders;
  });
});

// Notifier un changement après un appel API
OrderService().updateOrder(updatedOrder);
```

---

## 🎯 Mapping des statuts

### Flutter → Django
```dart
// Ce que Flutter envoie → Ce que Django reçoit
'ready_for_pickup' → 'delivering'  // Mappé automatiquement côté backend
'preparing' → 'preparing'
'delivered' → 'delivered'
'cancelled' → 'cancelled'
```

### Django → Flutter
```dart
// Ce que Django retourne → Comment Flutter l'affiche
'pending' → 'En attente'
'paid' → 'Payé'
'preparing' → 'En préparation'
'delivering' → 'En livraison'
'delivered' → 'Livré'
'cancelled' → 'Annulé'
```

---

## ⚠️ Gestion des erreurs

```dart
try {
  await _apiService.updateOrderStatus(orderId, status);
} on HttpException catch (e) {
  // Erreur HTTP (400, 403, 404, 500, etc.)
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur HTTP: ${e.message}')),
  );
} on FormatException catch (e) {
  // Erreur de parsing JSON
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur de format: ${e.message}')),
  );
} catch (e) {
  // Erreur générique
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur: $e')),
  );
}
```

---

## 🧪 Tests avec Postman/cURL

### Obtenir le token
```bash
curl -X POST http://127.0.0.1:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"artisan1","password":"password123"}'
```

**Réponse:**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### Tester les endpoints

```bash
# Mes commandes
curl -H "Authorization: Bearer <access_token>" \
  http://127.0.0.1:8000/api/orders/my/

# Commandes artisan
curl -H "Authorization: Bearer <access_token>" \
  http://127.0.0.1:8000/api/orders/artisan/

# Mettre à jour le statut
curl -X PATCH \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{"status":"preparing"}' \
  http://127.0.0.1:8000/api/orders/1/update_status/

# Confirmer la réception
curl -X PATCH \
  -H "Authorization: Bearer <access_token>" \
  http://127.0.0.1:8000/api/orders/1/confirm_received/
```

---

## 📱 Notes importantes

1. **BaseURL selon la plateforme:**
   - Android Emulator: `http://10.0.2.2:8000`
   - iOS Simulator: `http://127.0.0.1:8000`
   - Appareil réel: `http://<IP_LOCALE>:8000`

2. **Toujours recharger après modification:**
   ```dart
   await _apiService.updateOrderStatus(...);
   await _loadOrders(); // Recharger pour avoir les données à jour
   ```

3. **Synchroniser avec OrderService:**
   ```dart
   OrderService().updateOrder(updatedOrder);
   ```

4. **Gérer le loading state:**
   ```dart
   setState(() => _isLoading = true);
   // ... API call
   setState(() => _isLoading = false);
   ```

---

## 🚀 Workflow complet

### Création d'une commande
1. Client ajoute des produits au panier
2. Client valide le panier → `POST /api/orders/`
3. Client paie → `POST /api/orders/pay/`
4. Backend change le statut vers `paid`

### Traitement par l'artisan
1. Artisan voit la nouvelle commande → `GET /api/orders/artisan/`
2. Artisan confirme → `PATCH /api/orders/{id}/update_status/` (`paid`)
3. Artisan commence préparation → `PATCH /api/orders/{id}/update_status/` (`preparing`)
4. Artisan marque prêt → `PATCH /api/orders/{id}/update_status/` (`ready_for_pickup`)
5. Artisan marque livré → `PATCH /api/orders/{id}/update_status/` (`delivered`)

### Réception par le client
1. Client reçoit le colis
2. Client confirme → `PATCH /api/orders/{id}/confirm_received/`
3. Backend met `is_received = True` et `received_at = now()`
4. Artisan voit la confirmation dans son interface
