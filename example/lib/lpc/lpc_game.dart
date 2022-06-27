import 'package:bonfire/bonfire.dart';
import 'package:example/lpc/lpc_player.dart';
import 'package:example/lpc/lpc_sprite_sheet_loader.dart';
import 'package:flutter/material.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 27/06/22
class LPCGame extends StatelessWidget {
  const LPCGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SimpleDirectionAnimation>(
      future: LPCSpriteSheetLoader.geSpriteSheet(hair: LPCHairEnum.xlong),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        return BonfireTiledWidget(
          joystick: Joystick(
            keyboardConfig: KeyboardConfig(),
            directional: JoystickDirectional(),
          ),
          map: TiledWorldMap(
            'tiled/mapa2.json',
            forceTileSize: Size(32, 32),
          ),
          cameraConfig: CameraConfig(zoom: 2),
          player:
              LPCPlayer(position: Vector2(140, 140), animation: snapshot.data!),
        );
      },
    );
  }
}
