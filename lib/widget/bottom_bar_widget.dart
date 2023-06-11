import 'package:flutter/material.dart';

class MenuSelector extends StatefulWidget {
  final PageController controller;
  const MenuSelector(this.controller, {super.key});

  @override
  MenuSelectorState createState() => MenuSelectorState();
}

class MenuSelectorState extends State<MenuSelector> {
  int _selectedIndex = 0;

  Widget _menuBar(String title, int index) {
    return GestureDetector(
      onTap: () {
        _selectedIndex = index;
        widget.controller.jumpToPage(index);
        setState(() {});
      },
      child: Column(children: [
        Text(title,
            style: TextStyle(
                fontSize: 16,
                color: index == _selectedIndex ? Colors.white : Colors.grey)),
        const SizedBox(height: 4),
        ClipOval(
          child: Container(
              width: 4,
              height: 4,
              color:
                  index == _selectedIndex ? Colors.white : Colors.transparent),
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 21),
      child: Row(children: [
        SizedBox(width: _selectedIndex == 0 ? 156 : 86),
        _menuBar('扫一扫', 0),
        const SizedBox(width: 30),
        _menuBar('翻译', 1)
      ]),
    );
  }
}
