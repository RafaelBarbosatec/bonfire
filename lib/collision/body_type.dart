/// Body type for collision physics
enum BodyType {
  dynamic,
  static;

  bool get isDynamic => this == BodyType.dynamic;
  bool get isStatic => this == BodyType.static;
}
