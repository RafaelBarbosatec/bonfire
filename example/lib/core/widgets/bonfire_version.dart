import 'package:flutter/material.dart';

class BonfireVersion extends StatelessWidget {
  const BonfireVersion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Bonfire',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(width: 2),
        Text(
          'v3',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
        ),
      ],
    );
  }
}
