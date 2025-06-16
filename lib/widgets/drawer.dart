import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/states/sdk_connected_provider.dart';
import 'package:jukebox_spotify_flutter/states/settings_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  const CustomDrawer({super.key});

  @override
  ConsumerState<CustomDrawer> createState() => CustomDrawerState();
}

class CustomDrawerState extends ConsumerState<CustomDrawer> {
  final TextEditingController _controller = TextEditingController(text: "");
  @override
  void initState() {
    super.initState();

    final adminPin = ref.read(settingsProvider).adminPin;
    _controller.text = adminPin;
    // Listen to changes in the text field and update the provider.
    _controller.addListener(() {
      if (_controller.text.length < 4) return;
      ref.read(settingsProvider.notifier).updateAdminPin(_controller.text);
    });
  }

  @override
  void dispose() async {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.read(settingsProvider);
    Color currentColor = settings.seedColor;
    void changeColor(Color color) => setState(() {
          currentColor = color;
          ref.read(settingsProvider.notifier).updateSeedColor(color);
        });

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Light/Dark mode'),
            trailing: Switch(
              value: settings.brightness == Brightness.dark,
              onChanged: (bool value) {
                ref.read(settingsProvider.notifier).switchBrightness();
              },
            ),
          ),
          ListTile(
            title: const Text('Show virtual keyboard'),
            trailing: Switch(
              value: settings.showVirtualKeyboard,
              onChanged: (bool value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateShowVirtualKeyboard(value);
              },
            ),
          ),
          ListTile(
            title: const Text('Show Type Filters'),
            trailing: Switch(
              value: settings.showTypeFilters,
              onChanged: (bool value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateShowTypeFilters(value);
              },
            ),
          ),
          ListTile(
            // title: const Text("Admin Pin"),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Admin Pin"),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,
                    maxLength: 4,
                    keyboardType: TextInputType.numberWithOptions(),
                    // onSubmitted: (String pin) {
                    //   ref.read(settingsProvider.notifier).updateAdminPin(pin);
                    // },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Search Delay'),
            subtitle: Slider(
                min: 0,
                max: 2000,
                divisions: 10,
                label: settings.debounceDelay.toString(),
                value: settings.debounceDelay,
                onChanged: (double value) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateDebounceDelay(value);
                }),
          ),
          ListTile(
            title: const Text('Search Results'),
            subtitle: Slider(
                min: 2,
                max: 20,
                divisions: 9,
                label: settings.searchResultAmount.toString(),
                value: settings.searchResultAmount.toDouble(),
                onChanged: (double value) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateSearchResultAmount(value);
                }),
          ),
          ListTile(
            title: const Text('Color Picker'),
            subtitle: Padding(
              padding: const EdgeInsets.all(20.0),
              child: OutlinedButton.icon(
                  icon: Icon(Icons.color_lens),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          // backgroundColor: Colors.transparent,
                          titlePadding: const EdgeInsets.all(0),
                          contentPadding: const EdgeInsets.all(8),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                          content: SizedBox(
                            height: 500,
                            width: 300,
                            child: ListView(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: BlockPicker(
                                    // enableAlpha: false,
                                    // labelTypes: [],
                                    // displayThumbColor: true,
                                    pickerColor: currentColor,
                                    onColorChanged: (value) {
                                      changeColor(value);
                                    },
                                  ),
                                ),
                                ListTile(
                                  title: const Text('Vibrant Colors'),
                                  trailing: Switch(
                                    value: ref
                                        .read(settingsProvider)
                                        .vibrantColors,
                                    onChanged: (bool value) {
                                      ref
                                          .read(settingsProvider.notifier)
                                          .updateVibrantColor(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  label: Text('Choose color')),
            ),
          ),
          ListTile(
            title: const Text('Disconnect'),
            subtitle: Padding(
              padding: const EdgeInsets.all(20.0),
              child: OutlinedButton.icon(
                  label: const Text('Disconnect'),
                  // color: Theme.of(context).colorScheme.onSurface,
                  onPressed: () async {
                    await SpotifySdk.disconnect();
                    ref.read(isSdkConnected.notifier).update((state) => false);
                  },
                  icon: Icon(Icons.exit_to_app)),
            ),
          ),
          const Divider(), // Adds a visual separator
          ListTile(
            title: const Text('Close Drawer'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}
