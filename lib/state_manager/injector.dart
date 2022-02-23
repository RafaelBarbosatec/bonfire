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
/// on 23/02/22

typedef T BuildDependency<T>(BonfireInjector i);

class BonfireInjector {
  static final BonfireInjector _singleton = BonfireInjector._internal();

  factory BonfireInjector() {
    return _singleton;
  }

  static final BonfireInjector instance = _singleton;

  BonfireInjector._internal();

  static final Map<Type, BuildDependency> _dependencies = {};

  void put<T>(BuildDependency<T> build) {
    _dependencies[T] = build;
  }

  T get<T>() {
    if (_dependencies.containsKey(T)) {
      return _dependencies[T]?.call(this);
    }
    throw Exception('Not found $T dependecy');
  }

  void dispose() {
    _dependencies.clear();
  }
}
