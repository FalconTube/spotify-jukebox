import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/states/loading_state.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    Log.log("init speech");
    _speechEnabled = await _speechToText.initialize();
    Log.log("speech enabled: $_speechEnabled");
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    Log.log("Pressed start");
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    Log.log("Pressed stop");
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
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
              // Expanded(
              //   child: TextField(
              //     controller: widget.textcontroller,
              //     decoration: InputDecoration(
              //       hintText: "Search...",
              //       border: InputBorder.none, // Remove default border
              //       hintStyle: TextStyle(
              //           color: Theme.of(context).colorScheme.onSurfaceVariant),
              //     ),
              //   ),
              // ),
              Expanded(
                child: Text(_speechToText.isListening
                    ? '$_lastWords'
                    : _speechEnabled
                        ? 'Tap mic...'
                        : 'Speech disabled'),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                  child: IconButton(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      onPressed: () {
                        widget.textcontroller.text = "";
                      },
                      icon: Icon(Icons.delete))),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    onPressed: () {
                      Log.log(
                          "in speech button. Not listening: ${_speechToText.isNotListening}");
                      _speechToText.isNotListening
                          ? _startListening()
                          : _stopListening();
                    },
                    icon: Icon(_speechToText.isNotListening
                        ? Icons.mic_off
                        : Icons.mic),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
