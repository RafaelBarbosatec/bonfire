import 'package:example/pages/home/widgets/home_content.dart';
import 'package:example/pages/home/widgets/home_drawer.dart';
import 'package:example/pages/map/terrain_builder/terrain_builder_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget content = const HomeContent();
  ItemDrawer? itemSelected;
  late List<SectionDrawer> menu;

  @override
  void initState() {
    menu = _buildMenu();
    itemSelected = menu.first.itens.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Text('Bonfire examples'),
      ),
      drawer: HomeDrawer(
        itemSelected: itemSelected,
        itens: menu,
        onChange: _onChange,
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: content,
          ),
          if (itemSelected?.codeUrl.isNotEmpty == true)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _launch(itemSelected!.codeUrl),
                  child: const Text(
                    'Source code',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  void _onChange(ItemDrawer value) {
    setState(() {
      itemSelected = value;
      content = value.builder(context);
    });
  }

  List<SectionDrawer> _buildMenu() {
    return [
      SectionDrawer(
        itens: [
          ItemDrawer(name: 'Home', builder: (_) => const HomeContent()),
        ],
      ),
      SectionDrawer(
        name: 'Map',
        itens: [
          ItemDrawer(
            name: 'TerrainBuilder',
            builder: (_) => const TerrainBuilderPage(),
            codeUrl: 'https://www.google.com.br',
          )
        ],
      ),
    ];
  }

  _launch(String codeUrl) {}
}
