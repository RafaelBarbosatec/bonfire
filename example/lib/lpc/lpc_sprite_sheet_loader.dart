import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/direction_animations/simple_direction_animation.dart';

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

enum LPCBodyEnum { light, brown, orc, skeleton }

class LPCSpriteSheetLoader {
  static Vector2 size = Vector2(64, 64);
  static Future<SimpleDirectionAnimation> geSpriteSheet({
    LPCBodyEnum body = LPCBodyEnum.light,
    bool withFeet = false,
    bool withHands = false,
    bool withHelm = false,
    bool withLeg = false,
    bool withShoulder = false,
    bool withChest = false,
    bool withArms = false,
    bool withGloves = false,
  }) async {
    Image imagePlayerBase = await Flame.images.load(_getPathBody(body));

    if (withFeet) {
      Image imageFeet = await Flame.images.load('lpc/feet/1.png');
      imagePlayerBase = await imagePlayerBase.overlap(imageFeet);
    }

    if (withHands) {
      Image imageHands = await Flame.images.load('lpc/hands/1.png');
      imagePlayerBase = await imagePlayerBase.overlap(imageHands);
    }

    if (withHelm) {
      Image imageHelm = await Flame.images.load('lpc/head/1.png');
      imagePlayerBase = await imagePlayerBase.overlap(imageHelm);
    }

    if (withLeg) {
      Image imageEquip = await Flame.images.load('lpc/leg/1.png');
      imagePlayerBase = await imagePlayerBase.overlap(imageEquip);
    }

    if (withShoulder) {
      Image imageEquip = await Flame.images.load('lpc/shoulder/1.png');
      imagePlayerBase = await imagePlayerBase.overlap(imageEquip);
    }

    if (withChest) {
      Image imageEquip = await Flame.images.load('lpc/torco/chest.png');
      imagePlayerBase = await imagePlayerBase.overlap(imageEquip);
    }

    if (withArms) {
      Image imageEquip = await Flame.images.load('lpc/torco/arms.png');
      imagePlayerBase = await imagePlayerBase.overlap(imageEquip);
    }

    if (withGloves) {
      Image imageEquip = await Flame.images.load('lpc/gloves/2.png');
      imagePlayerBase = await imagePlayerBase.overlap(imageEquip);
    }

    return SimpleDirectionAnimation(
      idleRight: imagePlayerBase.getAnimation(
        size: size,
        count: 1,
        startDy: (size.y * 11).toInt(),
      ),
      idleUp: imagePlayerBase.getAnimation(
        size: size,
        count: 1,
        startDy: (size.y * 8).toInt(),
      ),
      idleDown: imagePlayerBase.getAnimation(
        size: size,
        count: 1,
        startDy: (size.y * 10).toInt(),
      ),
      runRight: imagePlayerBase.getAnimation(
        size: size,
        count: 9,
        startDy: (size.y * 11).toInt(),
      ),
      runUp: imagePlayerBase.getAnimation(
        size: size,
        count: 9,
        startDy: (size.y * 8).toInt(),
      ),
      runDown: imagePlayerBase.getAnimation(
        size: size,
        count: 9,
        startDy: (size.y * 10).toInt(),
      ),
    );
  }

  static String _getPathBody(LPCBodyEnum body) {
    switch (body) {
      case LPCBodyEnum.light:
        return 'lpc/body/light.png';
      case LPCBodyEnum.brown:
        return 'lpc/body/brown.png';
      case LPCBodyEnum.orc:
        return 'lpc/body/orc1.png';
      case LPCBodyEnum.skeleton:
        return 'lpc/body/skeleton.png';
    }
  }
}
