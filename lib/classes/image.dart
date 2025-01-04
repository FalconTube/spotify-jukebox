import 'package:json_annotation/json_annotation.dart';

part 'image.g.dart';

@JsonSerializable(explicitToJson: true, createToJson: true, createFactory: true)
class SimpleImage {
  String url;
  int width;
  int height;

  SimpleImage({required this.url, required this.width, required this.height});
  Map<String, dynamic> toJson() => _$SimpleImageToJson(this);

  factory SimpleImage.fromJson(Map<String, dynamic> json) =>
      _$SimpleImageFromJson(json);
}
