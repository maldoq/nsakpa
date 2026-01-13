import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher le logo N'SAPKA
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  
  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo image
        ClipRRect(
          borderRadius: BorderRadius.circular(size / 4),
          child: Image.asset(
            'assets/logo/unnamed (2).jpg',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback si l'image ne charge pas
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(size / 4),
                ),
                child: Icon(
                  Icons.back_hand,
                  size: size * 0.5,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
        
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            "N'SAPKA",
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ],
    );
  }
}
