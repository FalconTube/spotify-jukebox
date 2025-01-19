class AppSettings {
  bool showVirtualKeyboard;
  bool showTypeFilters;
  double debounceDelay;

  AppSettings(
      {required this.showVirtualKeyboard,
      required this.showTypeFilters,
      required this.debounceDelay});

  // Factory constructor to create from JSON (for persistence)
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      showVirtualKeyboard: json['showVirtualKeyboard'] ?? true,
      showTypeFilters: json['showTypeFilters'] ?? true,
      debounceDelay: json['debounceDelay'] ?? 1500,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'showVirtualKeyboard': showVirtualKeyboard,
        'showTypeFilters': showTypeFilters,
        'debounceDelay': debounceDelay,
      };

  // Create a copy with changes
  AppSettings copyWith(
      {bool? showVirtualKeyboard,
      bool? showTypeFilters,
      double? debounceDelay}) {
    return AppSettings(
      showVirtualKeyboard: showVirtualKeyboard ?? this.showVirtualKeyboard,
      showTypeFilters: showTypeFilters ?? this.showTypeFilters,
      debounceDelay: debounceDelay ?? this.debounceDelay,
    );
  }
}
