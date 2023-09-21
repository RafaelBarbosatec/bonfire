// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:example/core/theme/app_colors.dart';
import 'package:example/core/widgets/bonfire_version.dart';
import 'package:example/pages/home/widgets/drawer/section_drawer_widget.dart';
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
      child: SafeArea(
        child: SizedBox(
          width: 220,
          child: ListView.builder(
            itemCount: itens.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: BonfireVersion(),
                      ),
                    ),
                    Container(
                      color: Colors.white.withOpacity(0.2),
                      height: 1,
                    )
                  ],
                );
              }

              return SectionDrawerWidget(
                section: itens[index - 1],
                itemSelected: itemSelected,
                onChange: onChange,
              );
            },
          ),
        ),
      ),
    );
  }
}
