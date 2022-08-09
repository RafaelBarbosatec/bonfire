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
/// on 23/02/22

typedef BuildDependency<T> = T Function(BonfireInjector i);

/// Class used to manager dependencies
class BonfireInjector {
  static final BonfireInjector _singleton = BonfireInjector._internal();

  factory BonfireInjector() {
    return _singleton;
  }

  static final BonfireInjector instance = _singleton;

  BonfireInjector._internal();

  static final Map<Type, BuildDependency> _dependencies = {};
  static final Map<Type, dynamic> _dependenciesSingleton = {};

  /// Used to register dependency as a Singleton.
  /// Always that you call [get] this will be return the same instance.
  /// When you use this to register a [StateController] all components that use
  /// he will be use the same instance.
  void put<T>(BuildDependency<T> build) {
    _dependencies[T] = build;
    _dependenciesSingleton[T] = null;
  }

  /// Used to register dependency as a Factory.
  /// Always that you call [get] this will be return a new instance.
  /// When you use this to register a [StateController] all components that use
  /// he will be using different instances.
  void putFactory<T>(BuildDependency<T> build) {
    _dependencies[T] = build;
  }

  /// Used to get dependency registered
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

  /// This method clean all dependencies registered.
  void dispose() {
    _dependencies.clear();
    _dependenciesSingleton.clear();
  }
}
