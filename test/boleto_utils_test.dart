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
          final resultado = boleto
              .validarBoleto('32090074201080049084849760000023994480000071327');
          expect(resultado.sucesso, true);
          expect(resultado.mensagem, equals('Boleto válido'));
          expect(resultado.tipoCodigoInput, TipoCodigo.linhaDigitavel);
          expect(resultado.tipoBoleto, TipoBoleto.banco);
          expect(
            resultado.codigoBarras,
            equals('32099944800000713270074210800490844976000002'),
          );
          expect(
            resultado.linhaDigitavel,
            equals('32090074201080049084849760000023994480000071327'),
          );
          expect(
            resultado.bancoEmissor?.codigo,
            equals('320'),
          );

          expect(
              resultado.vencimento, DateTime.parse('2023-08-20 00:00:00.000Z'));
          expect(resultado.valor, equals(713.27));
        });
        test('deve retornar a data de vencimento com base no dia 07/10/1997 ',
            () {
          final resultado = boleto.identificarData(
            codigo: '32090074201080049084849760000023994480000071327',
            tipoCodigo: TipoCodigo.linhaDigitavel,
          );

          expect(resultado, DateTime.parse('2023-08-20 00:00:00.000Z'));
        });
        test('deve retornar a data de vencimento com base no dia 22/02/2025 ',
            () {
          final resultado = boleto.identificarDataComNovoFator2025(
            codigo: '32090074201080049084849760000023910010000071327',
            tipoCodigo: TipoCodigo.linhaDigitavel,
          );

          expect(resultado, DateTime.parse('2025-02-23 00:00:00.000Z'));
        });
      });
      group('linhaDigitavelParaCodBarras', () {
        test('Converte linha digitável de boleto de arrecadação corretamente',
            () {
          const linhaDigitavel =
              '32090074201080049084849760000023994480000071327';
          const esperado = '32099944800000713270074210800490844976000002';

          final resultado = boleto.linhaDigitavelParaCodBarras(linhaDigitavel);

          expect(resultado, esperado);
        });
      });
    });
  });
  group('identificarTipoBoleto - Tipos de Arrecadação e Cartão \n', () {
    setUp(() {
      boleto = BoletoUtils();
    });
    test('deve identificar cartão de crédito por zeros', () {
      final tipo = boleto.identificarTipoBoleto(
          '12345000000000000000000000000000000000000000');
      expect(tipo, TipoBoleto.cartaoDeCredito);
    });

    test('deve identificar arrecadacao prefeitura', () {
      final tipo = boleto.identificarTipoBoleto(
          '81123456789012345678901234567890123456789012');
      expect(tipo, TipoBoleto.arrecadacaoPrefeitura);
    });

    test('deve identificar convenio saneamento', () {
      final tipo = boleto.identificarTipoBoleto(
          '82123456789012345678901234567890123456789012');
      expect(tipo, TipoBoleto.convenioSaneamento);
    });

    test('deve identificar convenio energia', () {
      final tipo = boleto.identificarTipoBoleto(
          '83123456789012345678901234567890123456789012');
      expect(tipo, TipoBoleto.convenioEnergiaEletricaGas);
    });

    test('deve identificar convenio telecomunicacao', () {
      final tipo = boleto.identificarTipoBoleto(
          '846600000018193000481005011220842808923082149330');
      expect(tipo, TipoBoleto.convenioTelecomunicacao);
    });

    test('deve identificar convenio telecomunicacao', () {
      final tipo = boleto
          .validarBoleto('846600000018193000481005011220842808923082149330');
      expect(tipo.tipoBoleto, TipoBoleto.convenioTelecomunicacao);
      expect(tipo.valor, 119.30);
    });

    test('deve identificar arrecadacao orgaos governamentais', () {
      final tipo = boleto.identificarTipoBoleto(
          '85123456789012345678901234567890123456789012');
      expect(tipo, TipoBoleto.arrecadacaoOrgaosGovernamentais);
    });

    test('deve identificar outros', () {
      final tipo1 = boleto.identificarTipoBoleto(
          '86123456789012345678901234567890123456789012');
      final tipo2 = boleto.identificarTipoBoleto(
          '89123456789012345678901234567890123456789012');
      expect(tipo1, TipoBoleto.outros);
      expect(tipo2, TipoBoleto.outros);
    });

    test('deve identificar arrecadacao taxas de transito', () {
      final tipo = boleto.identificarTipoBoleto(
          '87123456789012345678901234567890123456789012');
      expect(tipo, TipoBoleto.arrecadacaoTaxasDeTransito);
    });

    test('deve identificar como banco (padrao)', () {
      final tipo = boleto.identificarTipoBoleto(
          '34191790010104351004791020150008291070000005000');
      expect(tipo, TipoBoleto.banco);
    });
  });
}
