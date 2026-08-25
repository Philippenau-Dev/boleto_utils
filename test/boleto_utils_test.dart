import 'package:boleto_utils/src/types/tipo_boleto.dart';
import 'package:boleto_utils/src/types/tipo_codigo.dart';
import 'package:boleto_utils/src/boleto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BoletoUtils boleto;

  setUp(() {
    boleto = BoletoUtils();
  });

  group('Boleto Inválido \n', () {
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

        test('deve retornar a data de vencimento com base no dia 07/10/1997 ', () {
          final resultado = boleto.identificarData(
            codigo: '32090074201080049084849760000023994480000071327',
            tipoCodigo: TipoCodigo.linhaDigitavel,
          );

          expect(resultado, DateTime.parse('2023-08-20 00:00:00.000Z'));
        });

        test('deve retornar a data de vencimento com base no dia 22/02/2025 ', () {
          final resultado = boleto.identificarDataComNovoFator2025(
            codigo: '32090074201080049084849760000023910010000071327',
            tipoCodigo: TipoCodigo.linhaDigitavel,
          );

          expect(resultado, DateTime.parse('2025-02-23 00:00:00.000Z'));
        });

        test('validarBoleto deve retornar vencimentoFator2025 correto para linha digitável', () {
          final resultado = boleto.validarBoleto('32090074201080049084849760000023910010000071327');
          expect(resultado.sucesso, true);
          expect(resultado.vencimentoFator2025, DateTime.parse('2025-02-23 00:00:00.000Z'));
        });

        test('validarBoleto deve retornar vencimentoFator2025 correto para código de barras', () {
          final resultado = boleto.validarBoleto('32096100100000713270074210800490844976000002');
          expect(resultado.sucesso, true);
          expect(resultado.vencimentoFator2025, DateTime.parse('2025-02-23 00:00:00.000Z'));
        });

        test('calculaMod11 deve retornar 1 quando resto for 0 ou 1 (regra FEBRABAN de cobrança)', () {
          final resultado = boleto.calculaMod11('00000000000');
          expect(resultado, equals('1'));
        });
      });

      group('linhaDigitavelParaCodBarras', () {
        test('Converte linha digitável de boleto bancário corretamente', () {
          const linhaDigitavel =
              '32090074201080049084849760000023994480000071327';
          const esperado = '32099944800000713270074210800490844976000002';

          final resultado = boleto.linhaDigitavelParaCodBarras(linhaDigitavel);

          expect(resultado, esperado);
        });

        test('codBarrasParaLinhaDigitavel com formatada: true insere pontos e espaços', () {
          const codigoBarras = '32099944800000713270074210800490844976000002';
          final resultado = boleto.codBarrasParaLinhaDigitavel(barcode: codigoBarras, formatada: true);
          expect(resultado, equals('32090.07420 10800.490848 49760.000023 9 94480000071327'));
        });
      });
    });
  });

  group('identificarTipoCodigo \n', () {
    test('deve identificar código de barras com 44 dígitos', () {
      final tipo = boleto.identificarTipoCodigo('32099944800000713270074210800490844976000002');
      expect(tipo, TipoCodigo.codigoDeBarras);
    });

    test('deve identificar linha digitável com 47 dígitos', () {
      final tipo = boleto.identificarTipoCodigo('32090074201080049084849760000023994480000071327');
      expect(tipo, TipoCodigo.linhaDigitavel);
    });

    test('deve identificar código inválido para comprimentos fora do padrão', () {
      expect(boleto.identificarTipoCodigo('12345'), TipoCodigo.invalido);
      expect(boleto.identificarTipoCodigo('1234567890123456789012345678901234567890123'), TipoCodigo.invalido);
      expect(boleto.identificarTipoCodigo('123456789012345678901234567890123456789012345'), TipoCodigo.invalido);
    });
  });

  group('Arrecadação Módulo 11 \n', () {
    test('calculaMod11 com isArrecadacao: true deve retornar 0 quando resto for 0 ou 1', () {
      final resultado = boleto.calculaMod11('00000000000', isArrecadacao: true);
      expect(resultado, equals('0'));
    });
  });

  group('Extração de Valor em Arrecadação / Convênios \n', () {
    test('identificarValorCodBarrasArrecadacao extrai valor de código de barras de 44 dígitos', () {
      const codigoBarras = '84660000001819300048100501122084280892308214';
      final valor = boleto.identificarValorCodBarrasArrecadacao(
        codigo: codigoBarras,
        tipoCodigo: TipoCodigo.codigoDeBarras,
      );
      expect(valor, equals(181.93));
    });

    test('identificarValor extrai valor corretamente para boleto de arrecadação com valor efetivo (ref 6)', () {
      const linhaDigitavel = '846600000018193000481005011220842808923082149330';
      final valor = boleto.identificarValor(linhaDigitavel);
      expect(valor, equals(119.30));
    });

    test('identificarValor retorna 0.0 para arrecadação com referência de moeda/quantidade (ref 7)', () {
      const codigo = '81720000001819300048100501122084280892308214';
      final valor = boleto.identificarValor(codigo);
      expect(valor, equals(0.0));
    });
  });

  group('Banco Emissor Desconhecido \n', () {
    test('deve retornar BancoEmissor vazio para código de banco não cadastrado', () {
      final bancoEmissor = boleto.identificarBancoEmissor('99990074201080049084849760000023994480000071327');
      expect(bancoEmissor.codigo, equals('000'));
      expect(bancoEmissor.banco, equals('N/A'));
    });
  });

  group('identificarTipoBoleto - Tipos de Arrecadação e Cartão \n', () {
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

    test('deve identificar e validar convenio telecomunicacao', () {
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

    test('deve identificar outros para prefixos não mapeados especificamente como 80 e 88', () {
      final tipo1 = boleto.identificarTipoBoleto('80123456789012345678901234567890123456789012');
      final tipo2 = boleto.identificarTipoBoleto('88123456789012345678901234567890123456789012');
      expect(tipo1, TipoBoleto.outros);
      expect(tipo2, TipoBoleto.outros);
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

