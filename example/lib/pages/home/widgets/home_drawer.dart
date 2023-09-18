// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:example/core/theme/app_colors.dart';
import 'package:example/pages/home/widgets/item_drawer_widget.dart';
import 'package:flutter/material.dart';

class SectionDrawer {
  final String name;
  final List<ItemDrawer> itens;

  SectionDrawer({this.name = '', required this.itens});
}

class ItemDrawer {
  final String name;
  final WidgetBuilder builder;
  final String codeUrl;
  String? _id;
  ItemDrawer({
    String? id,
    required this.name,
    required this.builder,
    this.codeUrl = '',
  }) {
    _id == id;
  }

  String get id => _id ?? name;
}

class HomeDrawer extends StatelessWidget {
  final List<SectionDrawer> itens;
  final ValueChanged<ItemDrawer>? onChange;
  final ItemDrawer? itemSelected;
  const HomeDrawer({
    Key? key,
    required this.itens,
    this.onChange,
    this.itemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      width: 220,
      child: ListView.builder(
        itemCount: itens.length,
        itemBuilder: (context, index) {
          var section = itens[index];
          bool containTitle = section.name.isNotEmpty;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (containTitle)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    section.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ...section.itens.map((e) {
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
                    onChange?.call(value);
                  },
                  item: e,
                  selected: e.id == itemSelected?.id,
                );
              }).toList(),
              if (containTitle)
                Container(
                  width: double.maxFinite,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                )
            ],
          );
        },
      ),
    );
  }
}
