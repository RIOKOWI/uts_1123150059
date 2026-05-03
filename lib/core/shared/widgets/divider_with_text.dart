import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Expanded(child: Divider(color: onSurface,)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(color: onSurface, fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: onSurface,)),
      ],
    );
  }
}
