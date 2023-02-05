/// This is a temporary solution to solve warnings issues,
/// until we can migrate to Flutter 3.7. completely.
///
/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
///
/// Note: `Overlay.of(context)` is non-nullable in Flutter 3.7
/// but it is in previous versions.
///
/// In all cases, we can ensures that `overlayState` will be of type `OverlayState?`.
///
/// e.g.
/// ```dart
///   var overlayState = ambiguate(Overlay.of(context));
///   // overlayState is OverlayState? in all versions of Flutter
/// ```
T? ambiguate<T>(T? value) => value;
