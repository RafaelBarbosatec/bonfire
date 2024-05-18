import 'package:bonfire/bonfire.dart';
import 'package:example/shared/decoration/spikes.dart';
import 'package:flutter/material.dart';

class TiledNetworkPage extends StatefulWidget {
  const TiledNetworkPage({Key? key}) : super(key: key);

  @override
  State<TiledNetworkPage> createState() => _TiledNetworkPageState();
}

class _TiledNetworkPageState extends State<TiledNetworkPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          const Center(
            child: Text(
              'Loading...\n From: http://rafaelbarbosatec.github.io/tiled/my_map.json',
              textAlign: TextAlign.center,
            ),
          ),
          FadeTransition(
            opacity: _controller,
            child: BonfireWidget(
              playerControllers: [
                Joystick(
                  directional: JoystickDirectional(),
                )
              ],
              map: WorldMapByTiled(
                WorldMapReader.fromNetwork(
                  Uri.parse(
                    'http://rafaelbarbosatec.github.io/tiled/my_map.json',
                  ),
                ),
                objectsBuilder: {
                  'spikes': (props) => Spikes(
                        props.position,
                        size: props.size,
                      ),
                },
              ),
              onReady: (_) {
                Future.delayed(
                  const Duration(milliseconds: 300),
                  () => _controller.forward(),
                );
              },
              cameraConfig: CameraConfig(
                zoom: getZoomFromMaxVisibleTile(context, tileSize, 20),
                initPosition: Vector2(tileSize * 5, tileSize * 5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
