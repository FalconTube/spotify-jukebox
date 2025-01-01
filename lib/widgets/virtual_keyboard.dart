import 'package:flutter/material.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class MyKeyboard extends StatelessWidget {
  const MyKeyboard(
      {super.key, required this.textcontroller, required this.focusNode});

  final TextEditingController textcontroller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.inversePrimary,
        child: VirtualKeyboard(
            alwaysCaps: true,
            preKeyPress: (value) {
              // Need to set to end of line once if empty
              if (textcontroller.text == "") {
                textcontroller.selection = TextSelection.fromPosition(
                    TextPosition(offset: textcontroller.text.length));
              }
            },
            textController: textcontroller,
            type: VirtualKeyboardType.Alphanumeric));
  }
}
