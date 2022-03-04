import 'package:bonfire/state_manager/state_controller.dart';

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
  static final Map<Type, dynamic> _dependenciesSingleton = {};

  void put<T>(BuildDependency<T> build) {
    _dependencies[T] = build;
    _dependenciesSingleton[T] = null;
  }

  void putFactory<T>(BuildDependency<T> build) {
    _dependencies[T] = build;
  }

  T get<T>() {
    if (_dependenciesSingleton.containsKey(T) &&
        _dependenciesSingleton[T] != null) {
      return _dependenciesSingleton[T];
    }
    if (_dependencies.containsKey(T)) {
      final d = _dependencies[T]?.call(this);
      if (_dependenciesSingleton.containsKey(T)) {
        _dependenciesSingleton[T] = d;
      }
      return d;
    }
    throw Exception('Not found $T dependecy');
  }

  void dispose() {
    _dependencies.clear();
  }
}

T get<T extends StateController>() {
  return BonfireInjector().get<T>();
}
