class AppSettings {
  bool showVirtualKeyboard;
  bool showTypeFilters;

  AppSettings(
      {required this.showVirtualKeyboard, required this.showTypeFilters});

  // Factory constructor to create from JSON (for persistence)
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      showVirtualKeyboard: json['showVirtualKeyboard'] ?? true,
      showTypeFilters: json['showTypeFilters'] ?? true,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'showVirtualKeyboard': showVirtualKeyboard,
        'showTypeFilters': showTypeFilters,
      };

  // Create a copy with changes
  AppSettings copyWith({bool? showVirtualKeyboard, bool? showTypeFilters}) {
    return AppSettings(
      showVirtualKeyboard: showVirtualKeyboard ?? this.showVirtualKeyboard,
      showTypeFilters: showTypeFilters ?? this.showTypeFilters,
    );
  }
}
