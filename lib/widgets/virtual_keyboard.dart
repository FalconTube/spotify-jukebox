import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/states/settings_provider.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class MyKeyboard extends ConsumerWidget {
  const MyKeyboard(
      {super.key, required this.textcontroller, required this.focusNode});

  final TextEditingController textcontroller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: settings.showVirtualKeyboard
            ? VirtualKeyboard(
                alwaysCaps: true,
                preKeyPress: (value) {
                  // Need to set to end of line once if empty
                  if (textcontroller.text == "") {
                    textcontroller.selection = TextSelection.fromPosition(
                        TextPosition(offset: textcontroller.text.length));
                  }
                },
                textController: textcontroller,
                type: VirtualKeyboardType.Alphanumeric)
            : Center());
  }
}
