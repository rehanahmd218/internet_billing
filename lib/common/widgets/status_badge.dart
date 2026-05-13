import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isPaid;

  const StatusBadge({
    super.key,
    required this.status,
    this.isPaid = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color backgroundColor;
    Color textColor;
    
    if (status == 'Paid' || isPaid) {
      backgroundColor = isDark 
          ? Colors.green[900]!.withOpacity(0.3)
          : Colors.green[100]!;
      textColor = isDark ? Colors.green[400]! : Colors.green[700]!;
    } else if (status == 'Pending') {
      backgroundColor = isDark
          ? Colors.orange[900]!.withOpacity(0.3)
          : Colors.orange[100]!;
      textColor = isDark ? Colors.orange[400]! : Colors.orange[700]!;
    } else if (status == 'Active') {
      backgroundColor = isDark
          ? Colors.green[900]!.withOpacity(0.3)
          : Colors.green[100]!;
      textColor = isDark ? Colors.green[400]! : Colors.green[700]!;
    } else if (status == 'Inactive') {
      backgroundColor = isDark
          ? Colors.grey[700]!
          : Colors.grey[100]!;
      textColor = isDark ? Colors.grey[300]! : Colors.grey[600]!;
    } else {
      backgroundColor = isDark
          ? Colors.grey[800]!
          : Colors.grey[100]!;
      textColor = isDark ? Colors.grey[300]! : Colors.grey[600]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

