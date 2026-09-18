import 'package:flutter/material.dart';

class FontSizeSlider extends StatelessWidget {
  const FontSizeSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Size (${value.toStringAsFixed(2)}x)',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Slider(
          min: 0.85,
          max: 1.45,
          divisions: 12,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
