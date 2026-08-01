import 'package:flutter/material.dart';

/// A single proportional bar row — no charting dependency required.
/// Used to break down counts (e.g. visits by status) as simple bars.
class SimpleBarRow extends StatelessWidget {
  const SimpleBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    this.color,
  });

  final String label;
  final int value;
  final int maxValue;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    final fraction = maxValue == 0 ? 0.0 : value / maxValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: accent.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }
}
