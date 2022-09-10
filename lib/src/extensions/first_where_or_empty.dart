import 'package:boleto_utils/src/entities/banco_emissor.dart';

/// Criando um método de extensão para a classe List.
extension FirstWhereOrEmpty on List<BancoEmissor> {
  /// Retorna o primeiro elemento da lista que corresponde à condição ou um `BancoEmissor` vazio se nenhum elemento
  /// corresponde à condição.
  ///
  /// Args:
  /// numBanco (String): O valor do campo a ser pesquisado.
  BancoEmissor firstWhereOrEmpty(String numBanco) {
    /// Criando uma nova instância da classe BancoEmissor com o construtor vazio.
    BancoEmissor bancoEmissor = BancoEmissor.empty();

    /// Um ​​loop for que itera sobre a lista de objetos `BancoEmissor`.
    for (var i = 0; i < length; i++) {
      /// Verificando se a propriedade `codigo` da classe `BancoEmissor` contém o `numBanco`
      /// parâmetro.
      if (this[i].codigo.contains(numBanco)) {
        /// Atribuindo o valor do objeto atual à variável `bancoEmissor`.
        bancoEmissor = this[i];
        break;
      }
    }
    return bancoEmissor;
  }
}
