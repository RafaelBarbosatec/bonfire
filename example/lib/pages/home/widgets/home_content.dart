import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GifView.asset(
                  'assets/bonfire.gif',
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 10),
                Text(
                  'Whats is Bonfire?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Bonfire was created with purpose that create Flutter games on easy, objective and fast way!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kToolbarHeight),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
            ),
          ),
        ),
      ],
    );
  }
}
