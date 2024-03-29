import 'package:boleto_utils/src/types/tipo_boleto.dart';
import 'package:boleto_utils/src/types/tipo_codigo.dart';
import 'package:boleto_utils/src/boleto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BoletoUtils boleto;
  group('Boleto Inválido \n', () {
    setUp(() {
      boleto = BoletoUtils();
    });
    test('Caracteres inválidos', () {
      final boletoValidado = boleto.validarBoleto('whwudhwd');
      expect(boletoValidado.sucesso, false);
    });
    test('deve retornar BoletoValidado com sucesso: false', () {
      final boletoValidado = boleto.validarBoleto(
          '123482938102381039810293810938093819023810982309182301238109238109328091');
      expect(boletoValidado.sucesso, false);
    });
  });
  group('Boletos de 5 campos \n', () {
    setUp(() {
      boleto = BoletoUtils();
    });
    group('Boleto Bancário \n', () {
      group('Código de barras \n', () {
        test('deve retornar BoletoValidado com informações do boleto \n', () {
          final result = boleto
              .validarBoleto('32090074201080049084849760000023994480000071327');
          expect(result.sucesso, true);
          expect(result.mensagem, equals('Boleto válido'));
          expect(result.tipoCodigoInput, TipoCodigo.linhaDigitavel);
          expect(result.tipoBoleto, TipoBoleto.banco);
          expect(
            result.codigoBarras,
            equals('32099944800000713270074210800490844976000002'),
          );
          expect(
            result.linhaDigitavel,
            equals('32090074201080049084849760000023994480000071327'),
          );
          expect(
            result.bancoEmissor?.codigo,
            equals('320'),
          );

          expect(result.vencimento, DateTime.parse('2023-08-20 20:54:59.000Z'));
          expect(result.valor, equals(713.27));
        });
      });
      group('Linha Digitável', () {
        test('deve retornar BoletoValidado com informações do boleto', () {
          final result = boleto
              .validarBoleto('10492006506100010004200997263900989810000021403');
          expect(result.sucesso, true);
          expect(result.mensagem, equals('Boleto válido'));
          expect(result.tipoCodigoInput, TipoCodigo.linhaDigitavel);
          expect(result.tipoBoleto, TipoBoleto.banco);
          expect(
            result.codigoBarras,
            equals('10499898100000214032006561000100040099726390'),
          );
          expect(
            result.linhaDigitavel,
            equals('10492006506100010004200997263900989810000021403'),
          );
          expect(
            result.bancoEmissor?.codigo,
            equals('104'),
          );
          expect(
            result.vencimento,
            DateTime.parse('2022-05-10T20:54:59.000Z'),
          );
          expect(result.valor, equals(214.03));
        });
      });
    });
  });
}
