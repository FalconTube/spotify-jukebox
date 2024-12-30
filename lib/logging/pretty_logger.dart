import 'package:logger/logger.dart';

class Log {
  static void log(String code, {String? message}) {
    final Logger logger = Logger(
      //filter: CustomLogFilter(), // custom logfilter can be used to have logs in release mode
      printer: PrettyPrinter(
        methodCount: 2, // number of method calls to be displayed
        errorMethodCount: 8, // number of method calls if stacktrace is provided
        lineLength: 120, // width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
      ),
    );

    var text = message ?? '';
    logger.i('$code$text');
  }
}
