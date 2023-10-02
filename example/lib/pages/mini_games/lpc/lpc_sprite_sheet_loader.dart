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

class CustomStatus {
  final LPCBodyEnum body;
  final LPCHairEnum hair;
  final bool withFeet;
  final bool withHelm;
  final bool withLeg;
  final bool withChest;
  final bool withArms;
  final bool withGloves;

  const CustomStatus({
    this.body = LPCBodyEnum.light,
    this.hair = LPCHairEnum.empty,
    this.withFeet = false,
    this.withHelm = false,
    this.withLeg = false,
    this.withChest = false,
    this.withArms = false,
    this.withGloves = false,
  });

  CustomStatus copyWith({
    LPCBodyEnum? body,
    LPCHairEnum? hair,
    bool? withFeet,
    bool? withHelm,
    bool? withLeg,
    bool? withChest,
    bool? withArms,
    bool? withGloves,
  }) {
    return CustomStatus(
      body: body ?? this.body,
      hair: hair ?? this.hair,
      withFeet: withFeet ?? this.withFeet,
      withHelm: withHelm ?? this.withHelm,
      withLeg: withLeg ?? this.withLeg,
      withChest: withChest ?? this.withChest,
      withArms: withArms ?? this.withArms,
      withGloves: withGloves ?? this.withGloves,
    );
  }
}

enum LPCBodyEnum { light, brown, orc, skeleton }

enum LPCHairEnum { empty, curly, longknot, single, xlong }

class LPCSpriteSheetLoader {
  static Vector2 size = Vector2(64, 64);
  static Future<SimpleDirectionAnimation> geSpriteSheet({
    CustomStatus status = const CustomStatus(),
  }) async {
    final composition = ImageComposition();
    Image imageBody = await Flame.images.load(_getPathBody(status.body));
    composition.add(imageBody, Vector2.zero());

    if (status.withFeet) {
      Image imageFeet = await Flame.images.load('lpc/feet/1.png');
      composition.add(imageFeet, Vector2.zero());
    }

    if (status.withHelm) {
      Image imageHelm = await Flame.images.load('lpc/head/1.png');
      composition.add(imageHelm, Vector2.zero());
    }

    if (status.withLeg) {
      Image imageEquip = await Flame.images.load('lpc/leg/1.png');
      composition.add(imageEquip, Vector2.zero());
    }

    if (status.withChest) {
      Image imageEquip = await Flame.images.load('lpc/torco/chest.png');
      composition.add(imageEquip, Vector2.zero());
    }

    if (status.withArms) {
      Image imageEquip = await Flame.images.load('lpc/torco/arms.png');
      composition.add(imageEquip, Vector2.zero());
    }

    if (status.withGloves) {
      Image imageEquip = await Flame.images.load('lpc/gloves/2.png');
      composition.add(imageEquip, Vector2.zero());
    }

    Image? imageHair = await _getHair(status.hair);
    if (imageHair != null && !status.withHelm) {
      composition.add(imageHair, Vector2.zero());
    }

    Image image = await composition.compose();

    return SimpleDirectionAnimation(
      idleRight: image.getAnimation(
        size: size,
        amount: 1,
        position: Vector2(0, size.y * 11),
      ),
      idleUp: image.getAnimation(
        size: size,
        amount: 1,
        position: Vector2(0, size.y * 8),
      ),
      idleDown: image.getAnimation(
        size: size,
        amount: 1,
        position: Vector2(0, size.y * 10),
      ),
      runRight: image.getAnimation(
        size: size,
        amount: 9,
        position: Vector2(0, size.y * 11),
      ),
      runUp: image.getAnimation(
        size: size,
        amount: 9,
        position: Vector2(0, size.y * 8),
      ),
      runDown: image.getAnimation(
        size: size,
        amount: 9,
        position: Vector2(0, size.y * 10),
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

  static Future<Image?> _getHair(LPCHairEnum hair) async {
    switch (hair) {
      case LPCHairEnum.empty:
        return Future.value(null);
      case LPCHairEnum.curly:
        return await Flame.images.load('lpc/hair/curly.png');

      case LPCHairEnum.longknot:
        return await Flame.images.load('lpc/hair/longknot.png');
      case LPCHairEnum.single:
        return await Flame.images.load('lpc/hair/single.png');
      case LPCHairEnum.xlong:
        return await Flame.images.load('lpc/hair/xlong.png');
    }
  }
}
