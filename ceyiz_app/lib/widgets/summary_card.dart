import 'package:flutter/material.dart';

import '../utils/currency_formatter.dart';

/// Özet kartı widget'ı
class SummaryCard extends StatelessWidget {
  final int totalItems;
  final int purchasedItems;
  final double totalPrice;
  final double purchaseProgress;
  final List<Color> gradientColors;
  final Color shadowColor;
  final IconData itemIcon;

  const SummaryCard({
    super.key,
    required this.totalItems,
    required this.purchasedItems,
    required this.totalPrice,
    required this.purchaseProgress,
    required this.gradientColors,
    required this.shadowColor,
    required this.itemIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                context,
                'Toplam Öğe',
                totalItems.toString(),
                itemIcon,
                Colors.white,
              ),
              _buildSummaryItem(
                context,
                'Alınanlar',
                purchasedItems.toString(),
                Icons.check_circle_outline,
                Colors.white,
              ),
              _buildSummaryItem(
                context,
                'Toplam Tutar',
                CurrencyFormatter.format(totalPrice),
                Icons.currency_lira,
                Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: purchaseProgress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.circular(8),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            'İlerleme: %${(purchaseProgress * 100).toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
} 