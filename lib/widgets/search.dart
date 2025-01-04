import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/states/loading_state.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MySearchbar extends ConsumerWidget {
  const MySearchbar({
    super.key,
    required this.textcontroller,
    required this.focusNode,
  });

  final TextEditingController textcontroller;
  final FocusNode focusNode;
  final double iconSize = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900], // Background color
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: isLoading
                    ? SizedBox(
                        height: iconSize,
                        width: iconSize,
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child:
                              SpinKitPulse(size: iconSize, color: Colors.grey),
                        ))
                    : Icon(Icons.search,
                        color: Colors.grey, size: iconSize), // Search icon
              ),
              Expanded(
                child: TextField(
                  controller: textcontroller,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none, // Remove default border
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
