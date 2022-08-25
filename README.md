

# Biblioteca com funções úteis para a validação de todos os tipos de boleto

###  Recursos
- [x] Validar boleto
- [x] Código de barras para linha digitável
- [x] Linha digitável para código de barras
- [x] Identificar tipo de boleto
- [x] Identificar tipo de código
- [x] Identificar data de vencimento
- [x] Identificar valor do boleto
- [x] Cálculo digito verrificador módulo 10
- [x] Cálculo digito verrificador módulo 11
## Métodos
Métodos | Definição
--- | ---
`TipoCodigo identificarTipoCodigo(String codigo)` | Verifica a numeração e retorna o tipo do código inserido. TipoCodigo.codigoDeBarra, TipoCodigo.linhaDigitavel ou TipoCodigo.invalido. Requer numeração completa (com ou sem formatação).
`TipoBoleto? identificarTipoBoleto(String codigo)` | Verifica a numeração e retorna o tipo do boleto inserido. Se boleto bancário, convênio ou arrecadação. Requer numeração completa (com ou sem formatação).
`DateTime identificarData({required String codigo, required TipoCodigo tipoCodigo}` | Verifica a numeração, o tipo de código inserido e o tipo de boleto e retorna a data de vencimento. Requer numeração completa (com ou sem formatação) e tipo de código que está sendo inserido (TipoCodigo.codigoDeBarra ou TipoCodigo.linhaDigitavel).
`double identificarValor(String codigo)` | Verifica a numeração, o tipo de código inserido e o tipo de boleto e retorna o valor do título. Requer numeração completa (com ou sem formatação).
`String codBarrasParaLinhaDigitavel({required String barcode, bool formatada = false})` | Transforma a numeração no formato de código de barras em linha digitável. Requer numeração completa (com ou sem formatação) e valor `true` ou `false` que representam a forma em que o código convertido será exibido. Com (true) ou sem (false) formatação.
`String linhaDigitavelParaCodBarras(String codigo)` | Transforma a numeração no formato linha digitável em código de barras. Requer numeração completa (com ou sem formatação).
`String calculaDVCodBarras({required String codigo,required int posicaoCodigo, required int mod})` | Verifica a numeração do código de barras, extrai o DV (dígito verificador) presente na posição indicada, realiza o cálculo do dígito utilizando o módulo indicado e retorna o dígito verificador. Serve para validar o código de barras. Requer numeração completa (com ou sem formatação), caracteres numéricos que representam a posição do dígito verificador no código de barras e caracteres numéricos que representam o módulo a ser usado (valores aceitos: 10 ou 11).
`bool validarCodigoComDV({required String codigo, required TipoCodigo tipoCodigo})` | Calcula o dígito verificador de toda a numeração do código de barras. Retorno `true` para numeração válida e `false` para inválida.
`String calculaMod10(String numero)` | Realiza o cálculo Módulo 10 do número inserido.
`String calculaMod11(String numero)` | Realiza o cálculo Módulo 11 do número inserido.
`BoletoValidado validarBoleto(String codigo)` | Verifica a numeração e utiliza várias das funções acima para retornar um BoletoValidado contendo informações sobre a numeração inserida: `Tipo de código inserido`, `Tipo de boleto inserido`, `Código de barras`, `Linha digitável`, `Vencimento` e `Valor`.
`String? identificarBancoEmissor(String codigo)` | Verifica a numeração e retorna o número do banco emissor.
