import 'package:example/core/widgets/bonfire_version.dart';
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
                  'What is Bonfire?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Bonfire is a game development framework that enables the creation of\nFlutter/Flame games in a more easy, objective and fast way!',
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
        const Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: BonfireVersion(),
          ),
        ),
      ],
    );
  }
}
