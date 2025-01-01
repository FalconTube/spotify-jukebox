import 'package:flutter/material.dart';

class MySearchbar extends StatelessWidget {
  const MySearchbar(
      {super.key, required this.textcontroller, required this.focusNode});

  final TextEditingController textcontroller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      keyboardType: TextInputType.none,
      focusNode: focusNode,
      leading: Icon(Icons.search),
      hintText: "Find anything",
      controller: textcontroller,
    );
  }
}
