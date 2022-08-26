///Extensão utilizada para pegar apenas os números do código
extension NumericOnly on String {
  String get numericOnly => replaceAll(RegExp("[^0-9]"), "");
}
