import 'package:boleto_utils/src/entities/banco_emissor.dart';

extension FirstWhereOrEmpty on List<BancoEmissor> {
  BancoEmissor firstWhereOrEmpty(String numBanco) {
    BancoEmissor bancoEmissor = BancoEmissor.empty();
    for (var i = 0; i < length; i++) {
      if (this[i].codigo.contains(numBanco)) {
        bancoEmissor = this[i];
        break;
      }
    }
    return bancoEmissor;
  }
}
