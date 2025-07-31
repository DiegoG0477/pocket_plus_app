import 'package:flutter/material.dart';

class BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const BenefitItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15), // Un blanco translúcido sobre el fondo amarillo
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texto blanco sobre fondo amarillo
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85), // Texto blanco con ligera transparencia
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}