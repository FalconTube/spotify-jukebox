import 'package:json_annotation/json_annotation.dart';

part 'simplified_track_object.g.dart';

@JsonSerializable(explicitToJson: true, createToJson: true, createFactory: true)
class SimplifiedTrackObject {
  final String id;
  // Add other relevant data like title, description, etc.
  SimplifiedTrackObject({
    required this.id,
  });

  factory SimplifiedTrackObject.fromJson(Map<String, dynamic> json) =>
      _$SimplifiedTrackObjectFromJson(json);

  Map<String, dynamic> toJson() => _$SimplifiedTrackObjectToJson(this);

  @override
  String toString() {
    return id;
  }
}
