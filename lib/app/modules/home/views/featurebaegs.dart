import 'package:flutter/material.dart';

/// Feature Badges Widget - Safe Payments, Fast Delivery, Join Community
class FeatureBadgesWidget extends StatelessWidget {
  const FeatureBadgesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: const Row(
        children: [
          Expanded(
            child: _FeatureBadge(
              icon: Icons.verified_user_outlined,
              label: 'Safe Payments',
              color: Color(0xFF2C6B7A),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _FeatureBadge(
              icon: Icons.local_shipping_outlined,
              label: 'Fast Delivery',
              color: Color(0xFFFF9B3D),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _FeatureBadge(
              icon: Icons.people_outline,
              label: 'Join Community',
              color: Color(0xFF2C6B7A),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.2,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
