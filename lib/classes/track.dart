class SimpleTrack {
  final String name;
  final String artistName;
  final String img;
  final int durationMs;
  // Add other relevant data like title, description, etc.
  SimpleTrack({
    required this.name,
    required this.artistName,
    required this.img,
    required this.durationMs,
  });

  @override
  String toString() {
    return "Name: $name, Artist: $artistName, Img: $img";
  }

  String prettyDuration() {
    int durationSec = (durationMs / 1000).toInt();
    int remainSec = durationSec % 60;
    int remainMin = ((durationSec - remainSec) / 60).toInt();
    String paddedSec = remainSec.toString().padLeft(2, "0");

    return "$remainMin : $paddedSec";
  }
}
