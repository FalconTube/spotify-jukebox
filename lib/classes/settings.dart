import 'package:flutter/material.dart';

extension ColorExtension on Color {
  String toHex() {
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  static Color fromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    } else if (hexCode.length == 8) {
      return Color(int.parse(hexCode, radix: 16));
    } else {
      return Colors.transparent; // Or throw an exception for invalid format
    }
  }
}

class AppSettings {
  bool showVirtualKeyboard;
  bool showTypeFilters;
  double debounceDelay;
  int searchResultAmount;
  Brightness brightness;
  Color seedColor;

  AppSettings(
      {required this.showVirtualKeyboard,
      required this.showTypeFilters,
      required this.debounceDelay,
      required this.searchResultAmount,
      required this.brightness,
      required this.seedColor});

  // Factory constructor to create from JSON (for persistence)
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    // Map Brightness
    Brightness? brightness;
    if (json['brightness'] == 'dark') {
      brightness = Brightness.dark;
    } else {
      brightness = Brightness.light;
    }

    Color? seedColor;
    String? hexColor = json['seedColor'];
    if (hexColor != null) {
      seedColor = ColorExtension.fromHex(hexColor);
    }

    // Map Color hex code to actual Color

    return AppSettings(
        showVirtualKeyboard: json['showVirtualKeyboard'] ?? false,
        showTypeFilters: json['showTypeFilters'] ?? true,
        debounceDelay: json['debounceDelay'] ?? 1500,
        searchResultAmount: json['searchResultAmount'] ?? 8,
        brightness: brightness,
        seedColor: seedColor ?? Color(0xFFFA00F8));
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'showVirtualKeyboard': showVirtualKeyboard,
        'showTypeFilters': showTypeFilters,
        'debounceDelay': debounceDelay,
        'searchResultAmount': searchResultAmount,
        'brightness': brightness.name,
        'seedColor': seedColor.toHex(),
        // 'seedColor': seedColor.toString(),
      };

  // Create a copy with changes
  AppSettings copyWith({
    bool? showVirtualKeyboard,
    bool? showTypeFilters,
    double? debounceDelay,
    int? searchResultAmount,
    Brightness? brightness,
    Color? seedColor,
  }) {
    return AppSettings(
      showVirtualKeyboard: showVirtualKeyboard ?? this.showVirtualKeyboard,
      showTypeFilters: showTypeFilters ?? this.showTypeFilters,
      debounceDelay: debounceDelay ?? this.debounceDelay,
      searchResultAmount: searchResultAmount ?? this.searchResultAmount,
      brightness: brightness ?? this.brightness,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}
