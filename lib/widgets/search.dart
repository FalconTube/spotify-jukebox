import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/states/loading_state.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jukebox_spotify_flutter/states/speech_listening_provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MySearchbar extends ConsumerStatefulWidget {
  const MySearchbar({
    super.key,
    required this.textcontroller,
    required this.focusNode,
  });

  final TextEditingController textcontroller;
  final FocusNode focusNode;
  final double iconSize = 30;

  @override
  ConsumerState<MySearchbar> createState() => _MySearchbarState();
}

class _MySearchbarState extends ConsumerState<MySearchbar> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    ref.read(isSpeechListening.notifier).state = true;
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    ref.read(isSpeechListening.notifier).state = false;
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      widget.textcontroller.text = _lastWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    // Listen to changes of speech listening
    ref.listen(isSpeechListening, (_, isListening) {
      if (isListening == false) _stopListening();
    });
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .secondaryContainer, // Background color
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: isLoading
                    ? SizedBox(
                        height: widget.iconSize,
                        width: widget.iconSize,
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: SpinKitPulse(
                              size: widget.iconSize,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer),
                        ))
                    : Icon(Icons.search,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        size: widget.iconSize), // Search icon
              ),
              Expanded(
                child: TextField(
                  controller: widget.textcontroller,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none, // Remove default border
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
              Padding(
                  // Need to make room, if mic icon does not exist
                  padding: _speechEnabled
                      ? EdgeInsets.symmetric(horizontal: 0.0)
                      : EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      onPressed: () {
                        widget.textcontroller.text = "";
                      },
                      icon: Icon(Icons.delete))),
              _speechEnabled
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          onPressed: () {
                            _speechToText.isNotListening
                                ? _startListening()
                                : _stopListening();
                          },
                          icon: ref.watch(isSpeechListening.notifier).state
                              ? Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: SpinKitWave(
                                      size: (widget.iconSize - 12),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer),
                                )
                              : Icon(Icons.mic)))
                  : Center(),
            ],
          ),
        ),
      ),
    );
  }
}
