import 'package:flutter/material.dart';

/// Badge de statut
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color ?? Colors.blue,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color ?? Colors.blue),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge de niveau/priorité
class PriorityBadge extends StatelessWidget {
  final String level;

  const PriorityBadge({super.key, required this.level});

  Color _getColor() {
    switch (level.toLowerCase()) {
      case 'high':
      case 'urgent':
      case 'élevé':
        return Colors.red;
      case 'medium':
      case 'moyen':
        return Colors.orange;
      case 'low':
      case 'faible':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (level.toLowerCase()) {
      case 'high':
      case 'urgent':
      case 'élevé':
        return Icons.arrow_upward;
      case 'medium':
      case 'moyen':
        return Icons.remove;
      case 'low':
      case 'faible':
        return Icons.arrow_downward;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: level,
      color: _getColor(),
      icon: _getIcon(),
    );
  }
}

/// Badge de compteur
class CountBadge extends StatelessWidget {
  final int count;
  final Color? color;

  const CountBadge({
    super.key,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 20),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Badge avec icône uniquement
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;

  const IconBadge({
    super.key,
    required this.icon,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withValues(alpha:0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color ?? Colors.blue,
        size: size,
      ),
    );
  }
}