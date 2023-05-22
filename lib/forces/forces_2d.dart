import 'package:bonfire/bonfire.dart';

class Force2D {
  dynamic id;
  Vector2 value;
  Force2D(this.id,this.value);
}

class Forces2D {
  final List<Force2D> _forces;
  final List<Force2D> _resistences;

  List<Force2D> get forces => _forces;
  List<Force2D> get resistences => _resistences;

  Forces2D({List<Force2D>? forces, List<Force2D>? resistences})
      : _forces = forces ?? [],
        _resistences = resistences ?? [];

  void addForce(Force2D force) {
    _forces.where((f) => f.id == force.id).forEach((f) => _forces.remove(f));
    _forces.add(force);
  }

  void removeForce(dynamic id) {
    _forces.where((f) => f.id == id).forEach((f) => _forces.remove(f));
  }

  void addResistence(Force2D resistence) {
    _resistences
        .where((f) => f.id == resistence.id)
        .forEach((f) => _resistences.remove(f));
    _resistences.add(resistence);
  }

  void removeResistence(dynamic id) {
    _resistences
        .where((f) => f.id == id)
        .forEach((f) => _resistences.remove(f));
  }
}
