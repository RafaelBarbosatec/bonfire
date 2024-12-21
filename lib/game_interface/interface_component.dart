import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

/// Component used to add in your [GameInterface]
class InterfaceComponent extends GameComponent
    with UseAssetsLoader, UseSprite, TapGesture {
  /// identifier
  final int id;

  /// sprite that will be render
  Sprite? spriteUnselected;

  /// sprite that will be render when pressed
  Sprite? spriteSelected;

  /// Callback used to receive onTab gesture in your component.
  ///  this return if is selected
  final ValueChanged<bool>? onTapComponent;
  final bool selectable;
  bool _lastSelected = false;
  bool selected = false;

  InterfaceComponent({
    required this.id,
    required Vector2 position,
    required Vector2 size,
    Future<Sprite>? spriteUnselected,
    Future<Sprite>? spriteSelected,
    this.selectable = false,
    this.onTapComponent,
  }) {
    loader?.add(
      AssetToLoad<Sprite>(spriteUnselected, (value) {
        this.spriteUnselected = value;
      }),
    );
    loader?.add(
      AssetToLoad<Sprite>(spriteSelected, (value) {
        this.spriteSelected = value;
      }),
    );
    this.position = position;
    this.size = size;
  }

  @override
  void update(double dt) {
    sprite = selected ? (spriteSelected ?? spriteUnselected) : spriteUnselected;
    super.update(dt);
  }

  @override
  void onTapCancel() {
    if (selectable) {
      return;
    }
    selected = !selected;
  }

  @override
  void onTap() {
    if (selectable && !_lastSelected) {
      selected = true;
    } else {
      selected = !selected;
    }
    _lastSelected = selected;
    onTapComponent?.call(selected);
  }

  @override
  bool onTapDown(GestureEvent event) {
    selected = true;
    return true;
  }
}
