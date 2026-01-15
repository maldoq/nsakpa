import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';

class ArtisanOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const ArtisanOrderDetailScreen({super.key, required this.orderId});

  @override
  State<ArtisanOrderDetailScreen> createState() =>
      _ArtisanOrderDetailScreenState();
}

class _ArtisanOrderDetailScreenState extends State<ArtisanOrderDetailScreen> {
  Map<String, dynamic>? _orderData;
  Map<String, dynamic>? _buyerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiService.getArtisanOrderDetail(widget.orderId);
      if (data != null) {
        setState(() {
          _orderData = data['order'];
          _buyerData = data['buyer'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la commande'),
        backgroundColor: AppColors.secondary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orderData == null
          ? const Center(child: Text('Commande non trouvée'))
          : _buildOrderDetail(),
    );
  }

  Widget _buildOrderDetail() {
    final order = _orderData!;
    final buyer = _buyerData ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations acheteur
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations Acheteur',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.person, 'Nom', buyer['name'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.phone,
                    'Téléphone',
                    buyer['phone'] ?? 'N/A',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.email, 'Email', buyer['email'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on,
                    'Localisation',
                    buyer['location'] ?? 'N/A',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Articles de la commande
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Articles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (order['items'] != null)
                    ...(order['items'] as List).map(
                      (item) => _buildOrderItem(item),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Adresse de livraison
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Adresse de livraison',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(order['delivery_address'] ?? 'N/A'),
                  if (order['delivery_phone'] != null) ...[
                    const SizedBox(height: 8),
                    Text('Tél: ${order['delivery_phone']}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Totaux
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTotalRow('Sous-total', order['subtotal'] ?? 0),
                  const SizedBox(height: 8),
                  _buildTotalRow(
                    'Frais de livraison',
                    order['delivery_fee'] ?? 0,
                  ),
                  const Divider(height: 24),
                  _buildTotalRow('Total', order['total'] ?? 0, isTotal: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                item['product']?['images'] != null &&
                    (item['product']['images'] as List).isNotEmpty
                ? Image.network(
                    item['product']['images'][0],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: AppColors.border,
                        child: const Icon(Icons.image),
                      );
                    },
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppColors.border,
                    child: const Icon(Icons.image),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['product']?['name'] ?? 'Produit',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qté: ${item['quantity'] ?? 0} x ${double.tryParse(item['price']?.toString() ?? '0')?.toInt() ?? 0} FCFA',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${((item['quantity'] ?? 0) * (double.tryParse(item['price']?.toString() ?? '0') ?? 0)).toInt()} FCFA',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '${amount.toInt()} FCFA',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
