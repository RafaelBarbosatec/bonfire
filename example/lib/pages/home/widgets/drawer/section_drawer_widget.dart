import 'package:example/pages/home/widgets/drawer/home_drawer.dart';
import 'package:example/pages/home/widgets/drawer/item_drawer_widget.dart';
import 'package:flutter/material.dart';

class SectionDrawerWidget extends StatefulWidget {
  final SectionDrawer section;
  final ValueChanged<ItemDrawer>? onChange;
  final ItemDrawer? itemSelected;
  const SectionDrawerWidget(
      {Key? key, required this.section, this.onChange, this.itemSelected})
      : super(key: key);

  @override
  State<SectionDrawerWidget> createState() => _SectionDrawerWidgetState();
}

class _SectionDrawerWidgetState extends State<SectionDrawerWidget>
    with TickerProviderStateMixin {
  bool expanded = false;

  late AnimationController _controller;

  bool get containTitle => widget.section.name.isNotEmpty;

  late Animation<double> _rotate;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotate = Tween(begin: 0.0, end: 0.25).animate(_controller);
    expanded = _containItemSelected();
    if (!containTitle) {
      expanded = true;
    }
    if (expanded) {
      _controller.value = 1.0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.topCenter,
      child: InkWell(
        onTap: containTitle
            ? () {
                setState(() {
                  expanded = !expanded;
                  if (expanded) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                });
              }
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (containTitle)
              Container(
                color: Colors.black.withOpacity(0.2),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.section.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    RotationTransition(
                      turns: _rotate,
                      child: const Icon(
                        Icons.arrow_right_rounded,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            if (expanded)
              FadeTransition(
                opacity: _controller,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...widget.section.itens.map((e) {
                      return ItemDrawerWidget(
                        padding: containTitle
                            ? const EdgeInsets.only(
                                top: 16,
                                bottom: 16,
                                right: 16,
                                left: 32,
                              )
                            : null,
                        onChange: (value) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          widget.onChange?.call(value);
                        },
                        item: e,
                        selected: e.id == widget.itemSelected?.id,
                      );
                    }).toList(),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  bool _containItemSelected() {
    for (var element in widget.section.itens) {
      if (element.id == widget.itemSelected?.id) {
        return true;
      }
    }
    return false;
  }
}
