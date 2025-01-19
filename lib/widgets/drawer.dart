import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/states/settings_provider.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
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
                color: Colors.white,
                fontSize: 24,
              ),
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
