/// Está criando um método de extensão na classe String chamado `numericOnly` que retorna uma nova string
/// com todos os caracteres não numéricos removidos.
extension NumericOnly on String {
  String get numericOnly => replaceAll(RegExp("[^0-9]"), "");
}
