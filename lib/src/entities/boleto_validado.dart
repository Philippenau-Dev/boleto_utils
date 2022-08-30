import 'package:boleto_utils/src/entities/banco_emissor.dart';
import 'package:boleto_utils/src/types/tipo_boleto.dart';
import 'package:boleto_utils/src/types/tipo_codigo.dart';

///Classe com atributos do boleto
class BoletoValidado {
  final bool? sucesso;
  final String? codigoInput;
  final String? mensagem;
  final TipoCodigo? tipoCodigoInput;
  final TipoBoleto? tipoBoleto;
  final String? codigoBarras;
  final String? linhaDigitavel;
  final BancoEmissor? bancoEmissor;

  final DateTime? vencimento;
  final double? valor;

  BoletoValidado({
    this.sucesso,
    this.codigoInput,
    this.mensagem,
    this.tipoCodigoInput,
    this.tipoBoleto,
    this.codigoBarras,
    this.linhaDigitavel,
    this.bancoEmissor,
    this.vencimento,
    this.valor,
  });
}
