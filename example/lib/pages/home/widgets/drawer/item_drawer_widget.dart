import 'package:example/pages/home/widgets/drawer/home_drawer.dart';
import 'package:flutter/material.dart';

class ItemDrawerWidget extends StatelessWidget {
  final ItemDrawer item;
  final ValueChanged<ItemDrawer>? onChange;
  final EdgeInsetsGeometry? padding;
  final bool selected;
  const ItemDrawerWidget({
    Key? key,
    required this.item,
    this.onChange,
    this.padding,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          onChange?.call(item);
        },
        child: Container(
          color: selected ? Theme.of(context).primaryColor : null,
          padding: padding ?? const EdgeInsets.all(16),
          child: Text(item.name),
        ),
      ),
    );
  }
}
