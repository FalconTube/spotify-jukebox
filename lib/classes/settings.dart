class AppSettings {
  bool showVirtualKeyboard;
  bool showTypeFilters;
  double debounceDelay;
  int searchResultAmount;

  AppSettings(
      {required this.showVirtualKeyboard,
      required this.showTypeFilters,
      required this.debounceDelay,
      required this.searchResultAmount});

  // Factory constructor to create from JSON (for persistence)
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      showVirtualKeyboard: json['showVirtualKeyboard'] ?? false,
      showTypeFilters: json['showTypeFilters'] ?? true,
      debounceDelay: json['debounceDelay'] ?? 1500,
      searchResultAmount: json['searchResultAmount'] ?? 8,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'showVirtualKeyboard': showVirtualKeyboard,
        'showTypeFilters': showTypeFilters,
        'debounceDelay': debounceDelay,
        'searchResultAmount': searchResultAmount,
      };

  // Create a copy with changes
  AppSettings copyWith({
    bool? showVirtualKeyboard,
    bool? showTypeFilters,
    double? debounceDelay,
    int? searchResultAmount,
  }) {
    return AppSettings(
      showVirtualKeyboard: showVirtualKeyboard ?? this.showVirtualKeyboard,
      showTypeFilters: showTypeFilters ?? this.showTypeFilters,
      debounceDelay: debounceDelay ?? this.debounceDelay,
      searchResultAmount: searchResultAmount ?? this.searchResultAmount,
    );
  }
}
