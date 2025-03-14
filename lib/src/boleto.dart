import 'package:boleto_utils/src/constants/lista_bancos.dart';
import 'package:boleto_utils/src/entities/boleto_validado.dart';
import 'package:boleto_utils/src/entities/banco_emissor.dart';
import 'package:boleto_utils/src/entities/referencia.dart';
import 'package:boleto_utils/src/extensions/first_where_or_empty.dart';
import 'package:boleto_utils/src/extensions/numeric_only.dart';
import 'package:boleto_utils/src/types/tipo_codigo.dart';

import 'types/tipo_boleto.dart';

///Classe com métodos para a validação de todos os tipos de boleto do Brasil definidos pela FEBRABAN
class BoletoUtils {
  TipoCodigo identificarTipoCodigo(String codigo) {
    /// Pega uma string, remove todos os caracteres não numéricos e então verifica o comprimento do resultado.
    /// Se o comprimento for 44, ele retornará um valor de enumeração `TipoCodigo.codigoDeBarras`. Se o comprimento for
    /// entre 46 e 48, retorna um valor de enum `TipoCodigo.linhaDigitavel`. Caso contrário, retorna um
    /// valor enum `TipoCodigo.invalido`
    ///
    /// Args:
    /// codigo (String): O código que será analisado.
    ///
    /// Retorna:
    /// O tipo de retorno é um TipoCodigo enum.
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
    /// Verificando se os últimos 14 dígitos são todos zeros ou se os dígitos de 5 a 19 são todos zeros caso verdadeiro retorna `TipoBoleto.cartaoDeCredito`.
    /// Senão
    /// Verifica o primeiro dígito do código de barras, e se for 8, verifica o segundo dígito para determinar
    /// o tipo de código de barras
    ///
    /// Args:
    /// codigo (String): O número do código de barras.
    ///
    /// Retorna:
    /// O tipo do boleto.

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
    ///
    /// Pega um código de barras e retorna uma classe `Referencia`
    ///
    /// Args:
    /// código de barras (String): A string do código de barras.
    ///
    /// Retorna:
    /// retorna uma classe `Referencia`.
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

    ///Se for `true` retorna a linha digitável formatada quando for `TipoCodigo.codigoDeBarras`
  }) {
    /// Pega um código de barras e retorna uma linha digitável
    ///
    /// Args:
    /// código de barras (String): O código de barras a ser convertido.
    /// formatada (bool): Se true, o resultado será formatado com pontos e espaços. Padrões para falso
    ///
    /// Retorna:
    /// Uma linha digitável
    barcode = barcode.numericOnly;

    /// Chamando a função identificarTipoBoleto e passando o código de barras como parâmetro.
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

  /// Calcula a data de vencimento de um boleto bancário.
  ///
  /// Esta função determina a data de vencimento de um boleto com base no código fornecido
  /// e no tipo de código especificado. Utiliza um fator de vencimento associado ao código
  /// e uma data base fixada em 7 de outubro de 1997.
  ///
  /// [Parâmetros]:
  /// - [codigo]: Uma string representando o código do boleto, que pode estar formatado ou não.
  /// - [tipoCodigo]: O tipo de código utilizado no boleto, especificado pela enumeração [TipoCodigo].
  ///
  /// [Retorna]:
  /// - Uma instância de [DateTime] representando a data de vencimento calculada.
  DateTime identificarData({
    required String codigo,
    required TipoCodigo tipoCodigo,
  }) {
    codigo = codigo.numericOnly;
    final DateTime dataBase = DateTime.utc(1997, 10, 07, 00, 00, 00);
    final TipoBoleto? tipoBoleto = identificarTipoBoleto(codigo);

    final int fatorData = obtemFatorData(tipoCodigo, tipoBoleto, codigo);

    return dataBase.add(Duration(days: fatorData));
  }

  /// Calcula a data de vencimento do boleto com base no código fornecido e no tipo de código.
  ///
  /// Esta função determina a data de vencimento de um boleto utilizando o fator de vencimento
  /// definido a partir de 22/02/2025. O fator de vencimento é um número que representa a quantidade
  /// de dias decorridos desde uma data base até a data de vencimento do boleto.
  ///
  /// A função requer:
  /// - Um código de boleto completo (com ou sem formatação).
  /// - Especificação do tipo de código utilizado: [TipoCodigo.codigoDeBarras] ou [TipoCodigo.linhaDigitavel].
  ///
  /// [Parâmetros]:
  /// - [codigo]: Código do boleto, podendo estar formatado ou não.
  /// - [tipoCodigo]: Tipo de código utilizado no boleto (Código de Barras ou Linha Digitável).
  ///
  /// [Retorna]:
  /// - [DateTime]: Data de vencimento calculada a partir do fator de vencimento.
  DateTime identificarDataComNovoFator2025({
    required String codigo,
    required TipoCodigo tipoCodigo,
  }) {
    codigo = codigo.numericOnly;
    final DateTime dataBase = DateTime.utc(2025, 2, 22, 00, 00, 00);
    final TipoBoleto? tipoBoleto = identificarTipoBoleto(codigo);

    final int fatorData = obtemFatorData(tipoCodigo, tipoBoleto, codigo);

    return dataBase.add(Duration(days: fatorData - 1000));
  }

  /// Retorna o fator de vencimento do boleto.
  ///
  /// O fator de vencimento é um número de quatro dígitos que representa a quantidade
  /// de dias decorridos desde uma data base até a data de vencimento do boleto.
  /// Para boletos emitidos antes de 22/02/2025, a data base é 07/10/1997.
  /// Para boletos emitidos a partir de 22/02/2025, a data base é 22/02/2025.
  ///
  /// A posição do fator de vencimento varia conforme o tipo de código e o tipo de boleto.
  ///
  /// - [tipoCodigo]: Enumeração que indica se o código é do tipo código de barras ou linha digitável.
  /// - [tipoBoleto]: Enumeração que indica o tipo de boleto (banco, cartão de crédito, etc.).
  /// - [codigo]: String que contém o código completo do boleto.
  ///
  /// Retorna o fator de vencimento como um inteiro. Se o tipo de boleto não for suportado,
  /// retorna 0.
  int obtemFatorData(
    TipoCodigo tipoCodigo,
    TipoBoleto? tipoBoleto,
    String codigo,
  ) {
    late int fatorData;

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

    return fatorData;
  }

  BoletoValidado validarBoleto(
    String codigo, {
    bool formatada = false,

    ///Se for `true` retorna a linha digitável formatada quando for `TipoCodigo.codigoDeBarras`
  }) {
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
          vencimentoFator2025: identificarData(
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
          linhaDigitavel: codBarrasParaLinhaDigitavel(
            barcode: codigo,
            formatada: formatada,
          ),
          bancoEmissor: identificarBancoEmissor(codigo),
          vencimento: identificarData(
            codigo: codigo,
            tipoCodigo: TipoCodigo.codigoDeBarras,
          ),
          vencimentoFator2025: identificarDataComNovoFator2025(
            codigo: codigo,
            tipoCodigo: TipoCodigo.linhaDigitavel,
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
    /// Recebe uma string, identifica o tipo de código e retorna o valor do título
    ///
    /// Args:
    /// codigo (String): O código a ser analisado.
    ///
    /// Retorna:
    /// O valor do título.
    ///
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

  BancoEmissor identificarBancoEmissor(String codigo) {
    /// Identifica o banco emissor do código de barras.
    ///
    ///Verifica os três primeiros digitos e retorna o BancoEmissor com
    ///número, nome do banco, ISPB, PDF com lista atualizada diariamente pelo Banco Central.
    ///
    /// Args:
    /// codigo (String): String - O código a ser identificado.
    ///
    /// Retorna:
    /// BancoEmissor
    codigo = codigo.numericOnly;
    String numeroBancoEmissor = '000';
    BancoEmissor? bancoEmissor;
    final tipoCodigo = identificarTipoCodigo(codigo);
    if (tipoCodigo != TipoCodigo.invalido) {
      numeroBancoEmissor = codigo.substring(0, 3);
      bancoEmissor = kListaBancos.firstWhereOrEmpty(
        numeroBancoEmissor,
      );

      ///Percorre a Lista e retorna o primeiro BancoEmissor com o mesmo código identificado,
      ///caso não encontre retorna um BancoEmissor vazio
    }
    return bancoEmissor ?? BancoEmissor.empty();
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
    late int digito;

    for (int i = 0; i < numeroReverso.length; i++) {
      String c = numeroReverso[i];

      soma += (int.parse(c)) * peso;
      if (peso < base) {
        peso++;
      } else {
        peso = 2;
      }
    }
    digito = soma % 11;

    if (digito < 2) {
      digito = 0;
    } else if (digito == 10) {
      digito = 1;
    } else if (digito >= 2) {
      digito = 11 - digito;
    }

    return digito.toString();
  }
}
