import 'package:flutter/material.dart';

import '../app/posly_theme.dart';

class PoslyBrandMark extends StatelessWidget {
  const PoslyBrandMark({this.compact = false, this.color, super.key});

  final bool compact;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 38 : 46,
          height: compact ? 38 : 46,
          decoration: BoxDecoration(
            color: PoslyColors.turquoise,
            borderRadius: BorderRadius.circular(compact ? 11 : 14),
          ),
          child: const Icon(
            Icons.point_of_sale_rounded,
            color: PoslyColors.navy,
          ),
        ),
        const SizedBox(width: 11),
        Text(
          'PoSly',
          style: TextStyle(
            fontSize: compact ? 21 : 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
