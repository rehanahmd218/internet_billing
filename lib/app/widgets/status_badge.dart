import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status.toLowerCase());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: config.textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'paid':
        return _StatusConfig(
          label: 'Paid',
          backgroundColor: const Color(0xFFD1FAE5),
          borderColor: const Color(0xFF6EE7B7),
          textColor: const Color(0xFF047857),
        );
      case 'pending':
        return _StatusConfig(
          label: 'Pending',
          backgroundColor: const Color(0xFFFED7AA),
          borderColor: const Color(0xFFFBBF24),
          textColor: const Color(0xFFD97706),
        );
      case 'overdue':
        return _StatusConfig(
          label: 'Overdue',
          backgroundColor: const Color(0xFFFEE2E2),
          borderColor: const Color(0xFFFCA5A5),
          textColor: const Color(0xFFDC2626),
        );
      case 'active':
        return _StatusConfig(
          label: 'Active',
          backgroundColor: const Color(0xFFD1FAE5),
          borderColor: const Color(0xFF6EE7B7),
          textColor: const Color(0xFF047857),
        );
      case 'inactive':
        return _StatusConfig(
          label: 'Inactive',
          backgroundColor: const Color(0xFFFEE2E2),
          borderColor: const Color(0xFFFCA5A5),
          textColor: const Color(0xFFDC2626),
        );
      default:
        return _StatusConfig(
          label: status,
          backgroundColor: const Color(0xFFF3F4F6),
          borderColor: const Color(0xFFD1D5DB),
          textColor: const Color(0xFF6B7280),
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
