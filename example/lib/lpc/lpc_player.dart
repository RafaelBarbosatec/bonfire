import 'package:bonfire/bonfire.dart';

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
class LPCPlayer extends SimplePlayer {
  LPCPlayer({
    required Vector2 position,
    required SimpleDirectionAnimation animation,
  }) : super(
          position: position,
          size: Vector2.all(48),
          animation: animation,
        );
}
