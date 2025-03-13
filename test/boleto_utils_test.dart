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

          expect(result.vencimento, DateTime.parse('2023-08-20 00:00:00.000Z'));
          expect(result.valor, equals(713.27));
        });
        test('deve retornar a data de vencimento com base no dia 07/10/1997 ',
            () {
          final result = boleto.identificarData(
            codigo: '32090074201080049084849760000023994480000071327',
            tipoCodigo: TipoCodigo.linhaDigitavel,
          );

          expect(result, DateTime.parse('2023-08-20 00:00:00.000Z'));
        });
        test('deve retornar a data de vencimento com base no dia 22/02/2025 ',
            () {
          final result = boleto.identificarDataComNovoFator2025(
            codigo: '32090074201080049084849760000023910010000071327',
            tipoCodigo: TipoCodigo.linhaDigitavel,
          );

          expect(result, DateTime.parse('2025-02-23 00:00:00.000Z'));
        });
      });
      group('Linha Digitável', () {
        test('', () {
          final result = boleto.linhaDigitavelParaCodBarras(
              '846600000018193000481005011220842808923082149330');
          print(result);
        });
      });
    });
  });
}
