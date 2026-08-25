## 1.2.0

- Atualizadas dependências e suporte SDK Dart `>=3.0.0 <4.0.0` e Flutter `>=3.10.0` (`flutter_lints` `^5.0.0`)
- Adicionado método `identificarValorCodBarrasArrecadacao()` e expandido `identificarValor()` para todos os boletos de Arrecadação/Convênios (Água, Luz, Gás, IPTU, Taxas) com valor efetivo
- Fix do retorno de `vencimentoFator2025` no método `validarBoleto()` para Linha Digitável e Código de Barras
- Ajustado cálculo do `calculaMod11()` com parâmetro `isArrecadacao` para retornar `0` em arrecadação e `1` em cobrança bancária quando o resto for `< 2` ou `== 10`

## 1.1.1

- Fix bug no método de identificador de tipo de boleto
- Adicionado algoritmo para extrair o valor do boleto de convênio de telecomunicações
- Adicionado anotação sobre a impossibilidade de ler o vencimento de boletos de convênio de telecomunicações

## 1.1.0

- Atualizado para ser compatível com o novo fator de vencimento implementado em 22/02/2025 definido pela FEBRABAN (identificarDataComNovoFator2025())

## 1.0.3

- Fix modulo11

## 1.0.2

- Improved documentation
- Added parameter to return a typed line format in the method validateBoleto()

## 1.0.1

- Change method identificarBancoEmissor() to return BancoEmissor with bank name, code, ispb and link with updated PDF by Banco Central

## 1.0.0+3

- Added comments to methods

## 1.0.0+2

- Change tables README

## 1.0.0+1

- Change README

## 1.0.0

- First release
