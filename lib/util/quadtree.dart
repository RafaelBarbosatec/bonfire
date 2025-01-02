import 'dart:math';

// defaults should almost never be used, tune the quad tree to fit your problem
// ignore: constant_identifier_names
const int default_max_depth = 1000;
// ignore: constant_identifier_names
const int default_max_items = 100;

// names reflect a coordinate system where values increase as one goes left or down
const _upperLeftIndex = 0;
const _upperRightIndex = 1;
const _lowerLeftIndex = 2;
const _lowerRightIndex = 3;

class QuadTree<T> extends Rectangle<num> {
  final int maxDepth;
  final int maxItems;

  final int _depth;
  final Point<num> _center;
  final List<_ItemAtPoint<T>> _items = <_ItemAtPoint<T>>[];
  final List<QuadTree<T>> _children = <QuadTree<T>>[];

  factory QuadTree(
    num left,
    num top,
    num width,
    num height, {
    int? maxDepth,
    int? maxItems,
  }) =>
      QuadTree._(
        left,
        top,
        width,
        height,
        0,
        maxDepth: maxDepth,
        maxItems: maxItems,
      );

  QuadTree._(
    super.left,
    super.top,
    super.width,
    super.height,
    int depth, {
    int? maxDepth,
    int? maxItems,
  })  : maxDepth = maxDepth ?? default_max_depth,
        maxItems = maxItems ?? default_max_items,
        _depth = depth,
        _center = Point<num>(left + width / 2.0, top + height / 2.0);

  bool insert(T item, Point<num> atPoint, {dynamic id}) {
    if (!containsPoint(atPoint)) {
      return false;
    }
    if (_children.isEmpty) {
      if (_items.length + 1 <= maxItems || _depth + 1 > maxDepth) {
        _items.add(_ItemAtPoint<T>(id, item, atPoint));
        return true;
      }
      _splitItemsBetweenChildren();
    }
    return _insertItemIntoChildren(item, atPoint, id: id);
  }

  void removeById(dynamic id) {
    if (_children.isEmpty) {
      _items.removeWhere((item) => item.id == id);
    }
    for (final element in _children) {
      element.removeById(id);
    }
  }

  void clear() {
    _items.clear();
    for (final element in _children) {
      element.clear();
    }
    _children.clear();
  }

  void remove(T item) {
    if (_children.isEmpty) {
      _items.removeWhere((i) => i.item == item);
    }
    for (final element in _children) {
      element.remove(item);
    }
  }

  List<T> query(Rectangle range) {
    if (_children.isEmpty) {
      return _items
          .where((item) => range.containsPoint(item.point))
          .map((item) => item.item)
          .toList();
    }
    return _children
        .where((child) => child.intersects(range))
        .expand((child) => child.query(range))
        .toList();
  }

  @override
  String toString() {
    return '[$_depth](${_items.map((item) => item.item).toList()}:$_children)';
  }

  bool _insertItemIntoChildren(T item, Point<num> atPoint, {dynamic id}) {
    if (atPoint.x > _center.x) {
      if (atPoint.y > _center.y) {
        return _children[_lowerRightIndex].insert(item, atPoint, id: id);
      }
      return _children[_upperRightIndex].insert(item, atPoint, id: id);
    } else {
      if (atPoint.y > _center.y) {
        return _children[_lowerLeftIndex].insert(item, atPoint, id: id);
      } else {
        return _children[_upperLeftIndex].insert(item, atPoint, id: id);
      }
    }
  }

  void _splitItemsBetweenChildren() {
    _children.addAll([
      _newUpperLeft, // _upperLeftIndex = 0
      _newUpperRight, // _upperRightIndex = 1
      _newLowerLeft, // _lowerLeftIndex = 2
      _newLowerRight, // _lowerRightIndex = 3
    ]);
    for (final item in _items) {
      _insertItemIntoChildren(item.item, item.point, id: item.id);
    }
    _items.clear();
  }

  QuadTree<T> get _newUpperLeft => QuadTree<T>._(
        left,
        top,
        width / 2.0,
        height / 2.0,
        _depth + 1,
        maxItems: maxItems,
        maxDepth: maxDepth,
      );

  QuadTree<T> get _newUpperRight => QuadTree<T>._(
        _center.x,
        top,
        width / 2.0,
        height / 2.0,
        _depth + 1,
        maxItems: maxItems,
        maxDepth: maxDepth,
      );

  QuadTree<T> get _newLowerLeft => QuadTree<T>._(
        left,
        _center.y,
        width / 2.0,
        height / 2.0,
        _depth + 1,
        maxItems: maxItems,
        maxDepth: maxDepth,
      );

  QuadTree<T> get _newLowerRight => QuadTree<T>._(
        _center.x,
        _center.y,
        width / 2.0,
        height / 2.0,
        _depth + 1,
        maxItems: maxItems,
        maxDepth: maxDepth,
      );
}

class _ItemAtPoint<T> {
  final dynamic id;
  final T item;
  final Point<num> point;

  _ItemAtPoint(
    this.id,
    this.item,
    this.point,
  );
}
