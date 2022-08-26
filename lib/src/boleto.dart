import 'package:boleto_utils/src/entities/boleto_validado.dart';
import 'package:boleto_utils/src/entities/referencia.dart';
import 'package:boleto_utils/src/extensions/numeric_only.dart';
import 'package:boleto_utils/src/types/tipo_codigo.dart';

import 'types/tipo_boleto.dart';

///Classe com métodos úteis para a validação de todos os tipos de boleto do Brasil
class BoletoUtils {
  TipoCodigo identificarTipoCodigo(String codigo) {
    /// Verifica a numeração e retorna o tipo do código inserido.
    /// TipoCodigo.codigoDeBarra, TipoCodigo.linhaDigitavel ou TipoCodigo.invalido.
    /// Requer numeração completa (com ou sem formatação).
    codigo = codigo.numericOnly;

    if (codigo.length == 44) {
      return TipoCodigo.codigoDeBarras;
    } else if (codigo.length >= 46 && codigo.length <= 48) {
      return TipoCodigo.linhaDigitavel;
    } else {
      return TipoCodigo.invalido;
    }
  }

  TipoBoleto? identificarTipoBoleto(String codigo) {
    ///Verifica a numeração e retorna o tipo do boleto inserido.
    ///Se boleto bancário, convênio ou arrecadação.
    ///Requer numeração completa (com ou sem formatação).
    codigo = codigo.numericOnly;

    if (codigo.split('').reversed.join().substring(14) == '00000000000000' ||
        codigo.substring(5, 19) == '00000000000000') {
      return TipoBoleto.cartaoDeCredito;
    } else if (codigo.substring(0, 1) == '8') {
      if (codigo.substring(1, 1) == '1') {
        return TipoBoleto.arrecadacaoPrefeitura;
      } else if (codigo.substring(1, 2) == '2') {
        return TipoBoleto.convenioSaneamento;
      } else if (codigo.substring(1, 2) == '3') {
        return TipoBoleto.convenioEnergiaEletricaGas;
      } else if (codigo.substring(1, 2) == '4') {
        return TipoBoleto.convenioTelecomunicacao;
      } else if (codigo.substring(1, 2) == '5') {
        return TipoBoleto.arrecadacaoOrgaosGovernamentais;
      } else if (codigo.substring(1, 2) == '6' ||
          codigo.substring(1, 2) == '9') {
        return TipoBoleto.outros;
      } else if (codigo.substring(1, 2) == '7') {
        return TipoBoleto.arrecadacaoTaxasDeTransito;
      }
    } else {
      return TipoBoleto.banco;
    }
    return null;
  }

  Referencia? _identificarReferencia(String barcode) {
    ///Valida o terceiro campo da numeração inserida para definir como será calculado o Dígito Verificador.
    ///Requer numeração completa (com ou sem formatação).
    barcode = barcode.numericOnly;

    final referencia = barcode.substring(2, 3);

    final obj = {
      '6': Referencia(mod: 10, efetivo: true),
      '7': Referencia(mod: 10, efetivo: false),
      '8': Referencia(mod: 11, efetivo: true),
      '9': Referencia(mod: 11, efetivo: false),
    };

    return obj[referencia];
  }

  String codBarrasParaLinhaDigitavel({
    required String barcode,
    bool formatada = false,
  }) {
    ///Transforma a numeração no formato de código de barras em linha digitável.
    ///Requer numeração completa (com ou sem formatação) e valor true ou false que representam a forma em que o código convertido será exibido.
    ///Com (true) ou sem (false) formatação.
    barcode = barcode.numericOnly;

    final tipoBoleto = identificarTipoBoleto(barcode);

    String resultado = '';

    if (tipoBoleto == TipoBoleto.banco ||
        tipoBoleto == TipoBoleto.cartaoDeCredito) {
      final novaLinha = barcode.substring(0, 4) +
          barcode.substring(19, 44) +
          barcode.substring(4, 5) +
          barcode.substring(5, 19);

      final bloco1 =
          novaLinha.substring(0, 9) + calculaMod10(novaLinha.substring(0, 9));
      final bloco2 =
          novaLinha.substring(9, 19) + calculaMod10(novaLinha.substring(9, 19));
      final bloco3 = novaLinha.substring(19, 29) +
          calculaMod10(novaLinha.substring(19, 29));
      final bloco4 = novaLinha.substring(29);

      resultado = (bloco1 + bloco2 + bloco3 + bloco4).toString();

      if (formatada) {
        resultado =
            '${resultado.substring(0, 5)}.${resultado.substring(5, 10)} ${resultado.substring(10, 15)}.${resultado.substring(15, 21)} ${resultado.substring(21, 26)}.${resultado.substring(26, 32)} ${resultado.substring(32, 33)} ${resultado.substring(33)}';
      }
    } else {
      final identificacaoValorRealOuReferencia =
          _identificarReferencia(barcode);
      late String bloco1;
      late String bloco2;
      late String bloco3;
      late String bloco4;

      if (identificacaoValorRealOuReferencia?.mod == 10) {
        bloco1 =
            barcode.substring(0, 11) + calculaMod10(barcode.substring(0, 11));
        bloco2 =
            barcode.substring(11, 22) + calculaMod10(barcode.substring(11, 22));
        bloco3 =
            barcode.substring(22, 33) + calculaMod10(barcode.substring(22, 33));
        bloco4 =
            barcode.substring(33, 44) + calculaMod10(barcode.substring(33, 44));
      } else if (identificacaoValorRealOuReferencia?.mod == 11) {
        bloco1 =
            barcode.substring(0, 11) + calculaMod11(barcode.substring(0, 11));
        bloco2 =
            barcode.substring(11, 22) + calculaMod11(barcode.substring(11, 22));
        bloco3 =
            barcode.substring(22, 33) + calculaMod11(barcode.substring(22, 33));
        bloco4 =
            barcode.substring(33, 44) + calculaMod11(barcode.substring(33, 44));
      }

      resultado = bloco1 + bloco2 + bloco3 + bloco4;
    }

    return resultado;
  }

  String linhaDigitavelParaCodBarras(String codigo) {
    ///Transforma a numeração no formato linha digitável em código de barras.
    ///Requer numeração completa (com ou sem formatação).
    codigo = codigo.numericOnly;

    final tipoBoleto = identificarTipoBoleto(codigo);

    late String resultado;

    if (tipoBoleto == TipoBoleto.banco ||
        tipoBoleto == TipoBoleto.cartaoDeCredito) {
      resultado = codigo.substring(0, 4) +
          codigo.substring(32, 33) +
          codigo.substring(33) +
          codigo.substring(4, 9) +
          codigo.substring(10, 20) +
          codigo.substring(21, 31);
    } else {
      final listaCodigo = codigo.split('');
      listaCodigo.removeAt(11);
      listaCodigo.removeAt(22);
      listaCodigo.removeAt(33);
      listaCodigo.removeAt(44);
      codigo = listaCodigo.join('');

      resultado = codigo;
    }

    return resultado;
  }

  DateTime identificarData({
    required String codigo,
    required TipoCodigo tipoCodigo,
  }) {
    ///Verifica a numeração, o tipo de código inserido e o tipo de boleto e retorna a data de vencimento.
    ///Requer numeração completa (com ou sem formatação) e tipo de código que está sendo inserido (TipoCodigo.codigoDeBarra ou TipoCodigo.linhaDigitavel).
    codigo = codigo.numericOnly;
    final tipoBoleto = identificarTipoBoleto(codigo);

    late int fatorData;
    DateTime dataBoleto = DateTime.utc(1997, 10, 07, 20, 54, 59);

    if (tipoCodigo == TipoCodigo.codigoDeBarras) {
      if (tipoBoleto == TipoBoleto.banco ||
          tipoBoleto == TipoBoleto.cartaoDeCredito) {
        fatorData = int.parse(codigo.substring(5, 9));
      } else {
        fatorData = 0;
      }
    } else if (tipoCodigo == TipoCodigo.linhaDigitavel) {
      if (tipoBoleto == TipoBoleto.banco ||
          tipoBoleto == TipoBoleto.cartaoDeCredito) {
        fatorData = int.parse(codigo.substring(33, 37));
      } else {
        fatorData = 0;
      }
    }

    dataBoleto = dataBoleto.add(Duration(days: fatorData));

    return dataBoleto;
  }

  BoletoValidado validarBoleto(String codigo) {
    ///Verifica a numeração, o tipo de código inserido e o tipo de boleto e retorna a data de vencimento.
    ///Requer numeração completa (com ou sem formatação) e tipo de código que está sendo inserido (TipoCodigo.codigoDeBarra ou TipoCodigo.linhaDigitavel).
    final tipoCodigo = identificarTipoCodigo(codigo);

    late BoletoValidado boletoValidado;
    codigo = codigo.numericOnly;

    /// Boletos de cartão de crédito geralmente possuem 46 dígitos. É necessário adicionar mais um zero no final, para formar 47 caracteres
    ///Alguns boletos de cartão de crédito do Itaú possuem 36 dígitos. É necessário acrescentar 11 zeros no final.
    if (codigo.length == 36) {
      codigo = '${codigo}00000000000';
    } else if (codigo.length == 46) {
      codigo = '${codigo}0';
    }

    if (tipoCodigo == TipoCodigo.invalido) {
      boletoValidado = BoletoValidado(
        sucesso: false,
        codigoInput: codigo,
      );
    } else if (codigo.length < 44 && codigo.length > 48) {
      boletoValidado = BoletoValidado(
        sucesso: false,
        codigoInput: codigo,
        mensagem:
            'O código inserido possui ${codigo.length} dígitos. Por favor insira uma numeração válida. Códigos de barras SEMPRE devem ter 44 caracteres numéricos. Linhas digitáveis podem possuir 46 (boletos de cartão de crédito), 47 (boletos bancários/cobrança) ou 48 (contas convênio/arrecadação) caracteres numéricos. Qualquer caractere não numérico será desconsiderado.',
      );
    } else if (codigo.substring(0, 1) == '8' &&
        (codigo.length == 46 || codigo.length == 47)) {
      boletoValidado = BoletoValidado(
        sucesso: false,
        codigoInput: codigo,
        mensagem:
            'Este tipo de boleto deve possuir um código de barras 44 caracteres numéricos. Ou linha digitável de 48 caracteres numéricos.',
      );
    } else if (!validarCodigoComDV(codigo: codigo, tipoCodigo: tipoCodigo)) {
      boletoValidado = BoletoValidado(
        sucesso: false,
        codigoInput: codigo,
        mensagem:
            'A validação do dígito verificador falhou. Tem certeza que inseriu a numeração correta?',
      );
    } else {
      final obj = {
        TipoCodigo.linhaDigitavel: BoletoValidado(
          sucesso: true,
          codigoInput: codigo,
          mensagem: 'Boleto válido',
          tipoCodigoInput: TipoCodigo.linhaDigitavel,
          tipoBoleto: identificarTipoBoleto(codigo),
          codigoBarras: linhaDigitavelParaCodBarras(codigo),
          linhaDigitavel: codigo,
          bancoEmissor: identificarBancoEmissor(codigo),
          vencimento: identificarData(
            codigo: codigo,
            tipoCodigo: TipoCodigo.linhaDigitavel,
          ),
          valor: identificarValor(codigo),
        ),
        TipoCodigo.codigoDeBarras: BoletoValidado(
          sucesso: true,
          codigoInput: codigo,
          mensagem: 'Boleto válido',
          tipoCodigoInput: TipoCodigo.codigoDeBarras,
          tipoBoleto: identificarTipoBoleto(codigo),
          codigoBarras: codigo,
          linhaDigitavel: codBarrasParaLinhaDigitavel(barcode: codigo),
          bancoEmissor: identificarBancoEmissor(codigo),
          vencimento: identificarData(
            codigo: codigo,
            tipoCodigo: TipoCodigo.codigoDeBarras,
          ),
          valor: identificarValor(codigo),
        )
      };

      boletoValidado = obj[tipoCodigo] ??
          BoletoValidado(
            sucesso: true,
            codigoInput: codigo,
            mensagem: 'Boleto válido',
          );
    }

    return boletoValidado;
  }

  String calculaDVCodBarras({
    required String codigo,
    required int posicaoCodigo,
    required int mod,
  }) {
    ///Verifica a numeração do código de barras, extrai o DV (dígito verificador) presente na posição indicada, realiza o cálculo do dígito
    ///utilizando o módulo indicado e retorna o dígito verificador. Serve para validar o código de barras.
    ///Requer numeração completa (com ou sem formatação), caracteres numéricos que representam a posição do
    ///dígito verificador no código de barras e caracteres numéricos que representam o módulo a ser usado (valores aceitos: 10 ou 11).
    codigo = codigo.numericOnly;

    final listaCodigo = codigo.split('');
    listaCodigo.removeAt(posicaoCodigo);
    codigo = listaCodigo.join('');

    if (mod == 10) {
      return calculaMod10(codigo);
    } else {
      return calculaMod11(codigo);
    }
  }

  bool validarCodigoComDV({
    required String codigo,
    required TipoCodigo tipoCodigo,
  }) {
    ///alcula o dígito verificador de toda a numeração do código de barras.
    ///Retorno true para numeração válida e false para inválida.
    codigo = codigo.numericOnly;
    late TipoBoleto? tipoBoleto;
    late String resultado;

    if (tipoCodigo == TipoCodigo.linhaDigitavel) {
      tipoBoleto = identificarTipoBoleto(codigo);

      if (tipoBoleto == TipoBoleto.banco ||
          tipoBoleto == TipoBoleto.cartaoDeCredito) {
        final bloco1 =
            codigo.substring(0, 9) + calculaMod10(codigo.substring(0, 9));
        final bloco2 =
            codigo.substring(10, 20) + calculaMod10(codigo.substring(10, 20));
        final bloco3 =
            codigo.substring(21, 31) + calculaMod10(codigo.substring(21, 31));
        final bloco4 = codigo.substring(32, 33);
        final bloco5 = codigo.substring(33);

        resultado = (bloco1 + bloco2 + bloco3 + bloco4 + bloco5).toString();
      } else {
        final identificacaoValorRealOuReferencia =
            _identificarReferencia(codigo);
        late String bloco1;
        late String bloco2;
        late String bloco3;
        late String bloco4;

        if (identificacaoValorRealOuReferencia?.mod == 10) {
          bloco1 =
              codigo.substring(0, 11) + calculaMod10(codigo.substring(0, 11));
          bloco2 =
              codigo.substring(12, 23) + calculaMod10(codigo.substring(12, 23));
          bloco3 =
              codigo.substring(24, 35) + calculaMod10(codigo.substring(24, 35));
          bloco4 =
              codigo.substring(36, 47) + calculaMod10(codigo.substring(36, 47));
        } else if (identificacaoValorRealOuReferencia?.mod == 11) {
          bloco1 = codigo.substring(0, 11);
          bloco2 = codigo.substring(12, 23);
          bloco3 = codigo.substring(24, 35);
          bloco4 = codigo.substring(36, 47);

          final dv1 = codigo.substring(11, 12);
          final dv2 = codigo.substring(23, 24);
          final dv3 = codigo.substring(35, 36);
          final dv4 = codigo.substring(47, 48);

          final valid = (calculaMod11(bloco1) == dv1 &&
              calculaMod11(bloco2) == dv2 &&
              calculaMod11(bloco3) == dv3 &&
              calculaMod11(bloco4) == dv4);

          return valid;
        }

        resultado = bloco1 + bloco2 + bloco3 + bloco4;
      }
    } else if (tipoCodigo == TipoCodigo.codigoDeBarras) {
      tipoBoleto = identificarTipoBoleto(codigo);

      if (tipoBoleto == TipoBoleto.banco ||
          tipoBoleto == TipoBoleto.cartaoDeCredito) {
        final dv =
            calculaDVCodBarras(codigo: codigo, posicaoCodigo: 4, mod: 11);
        resultado = codigo.substring(0, 4) + dv + codigo.substring(5);
      } else {
        final identificacaoValorRealOuReferencia =
            _identificarReferencia(codigo);

        final listaString = codigo.split('');
        listaString.removeAt(3);
        resultado = listaString.join('');

        final dv = calculaDVCodBarras(
          codigo: codigo,
          posicaoCodigo: 3,
          mod: identificacaoValorRealOuReferencia?.mod ?? 10,
        );
        resultado = resultado.substring(0, 3) + dv + resultado.substring(3, 4);
      }
    } else if (tipoCodigo == TipoCodigo.invalido) {
      return false;
    }

    return codigo == resultado;
  }

  double identificarValor(String codigo) {
    ///Verifica a numeração, o tipo de código inserido e o tipo de boleto e retorna o valor do título.
    ///Requer numeração completa (com ou sem formatação).
    codigo = codigo.numericOnly;
    final tipoCodigo = identificarTipoCodigo(codigo);
    if (tipoCodigo == TipoCodigo.codigoDeBarras) {
      codigo = codBarrasParaLinhaDigitavel(barcode: codigo);
    }
    String valor = codigo.substring(codigo.length - 10);
    valor = '${valor.substring(0, 8)}.${valor.substring(8)}';

    valor = valor.replaceAll(RegExp('^0+(?!\$)'), '');
    return double.parse(valor);
  }

  String? identificarBancoEmissor(String codigo) {
    ///Verifica a numeração e retorna o número do banco emissor.
    codigo = codigo.numericOnly;
    String? numeroBancoEmissor;
    final tipoBoleto = identificarTipoBoleto(codigo);
    if (tipoBoleto == TipoBoleto.banco) {
      numeroBancoEmissor = codigo.substring(0, 3);
    }

    return numeroBancoEmissor;
  }

  String calculaMod10(String numero) {
    ///Realiza o cálculo Módulo 10 do número inserido.
    numero = numero.numericOnly;
    int i;
    int peso = 2;
    int soma = 0;
    String s = '';

    for (i = numero.length - 1; i >= 0; i--) {
      s = (peso * int.parse(numero[i])).toString() + s;
      if (--peso < 1) {
        peso = 2;
      }
    }
    for (i = 0; i < s.length; i++) {
      soma = soma + int.parse(s[i]);
    }
    soma = soma % 10;
    if (soma != 0) {
      soma = 10 - soma;
    }
    return soma.toString();
  }

  String calculaMod11(String numero) {
    ///	Realiza o cálculo Módulo 11 do número inserido.
    final numeroReverso = numero.split('').reversed.join();

    int soma = 0;
    int peso = 2;
    int base = 9;
    String digito = '';

    for (int i = 0; i < numeroReverso.length; i++) {
      String c = numeroReverso[i];

      soma += int.parse(c) * peso;
      if (peso < base) {
        peso++;
      } else {
        peso = 2;
      }
    }
    digito = (soma % 11).toString();

    if (int.parse(digito) < 2) {
      digito = '1';
    } else if (int.parse(digito) >= 2) {
      digito = (11 - int.parse(digito)).toString();
    }

    return digito;
  }
}
