extension NumericOnly on String {
  String get numericOnly => replaceAll(RegExp("[^0-9]"), "");
}
