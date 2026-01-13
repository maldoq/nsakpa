import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProductFilterSheet extends StatefulWidget {
  final String selectedCategory;
  final String sortBy;
  final bool showOnlyLimitedEdition;
  final double maxPrice;
  final Function(String, String, bool, double) onApply;

  const ProductFilterSheet({
    super.key,
    required this.selectedCategory,
    required this.sortBy,
    required this.showOnlyLimitedEdition,
    required this.maxPrice,
    required this.onApply,
  });

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  late String _selectedCategory;
  late String _sortBy;
  late bool _showOnlyLimitedEdition;
  late double _maxPrice;

  final List<String> categories = [
    'Tous',
    'Masques',
    'Peinture',
    'Sculpture',
    'Mobilier',
    'Cuisine',
    'Décoration',
  ];

  final Map<String, String> sortOptions = {
    'recent': 'Plus récents',
    'price_asc': 'Prix croissant',
    'price_desc': 'Prix décroissant',
    'rating': 'Mieux notés',
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _sortBy = widget.sortBy;
    _showOnlyLimitedEdition = widget.showOnlyLimitedEdition;
    _maxPrice = widget.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtres',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'Tous';
                      _sortBy = 'recent';
                      _showOnlyLimitedEdition = false;
                      _maxPrice = 200000;
                    });
                  },
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Contenu
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie
                  _buildSectionTitle('Catégorie'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.textWhite
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tri
                  _buildSectionTitle('Trier par'),
                  const SizedBox(height: 12),
                  ...sortOptions.entries.map((entry) {
                    return RadioListTile<String>(
                      value: entry.key,
                      groupValue: _sortBy,
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                      title: Text(entry.value),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                  
                  const SizedBox(height: 24),
                  
                  // Prix maximum
                  _buildSectionTitle('Prix maximum'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _maxPrice,
                          min: 0,
                          max: 200000,
                          divisions: 20,
                          activeColor: AppColors.primary,
                          label: '${_maxPrice.toInt()} FCFA',
                          onChanged: (value) {
                            setState(() {
                              _maxPrice = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_maxPrice.toInt()} FCFA',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Édition limitée
                  SwitchListTile(
                    value: _showOnlyLimitedEdition,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyLimitedEdition = value;
                      });
                    },
                    title: Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Édition limitée uniquement',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          
          // Bouton Appliquer
          Padding(
            padding: EdgeInsets.all((MediaQuery.of(context).size.width / 390 * 20).clamp(16.0, 20.0)),
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final buttonHeight = (screenWidth / 390 * 45).clamp(40.0, 50.0);
                final fontSize = (screenWidth / 390 * 14).clamp(14.0, 16.0);
                final padding = (screenWidth / 390 * 20).clamp(16.0, 20.0);
                
                return ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      _selectedCategory,
                      _sortBy,
                      _showOnlyLimitedEdition,
                      _maxPrice,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    minimumSize: Size(double.infinity, buttonHeight),
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Appliquer les filtres',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
    );
  }
}
