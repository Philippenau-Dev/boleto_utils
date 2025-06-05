## 📘 Sobre o pacote

**boleto_utils** é um pacote Dart que fornece utilitários para **validação, leitura e interpretação de boletos** bancários e de arrecadação. Ele facilita a manipulação de códigos de barras e linhas digitáveis, extraindo informações como banco emissor, valor, vencimento e estrutura interna. Ideal para aplicações financeiras, ERPs, gateways de pagamento ou sistemas de automação que precisem interpretar boletos de forma precisa e eficiente.

---

## ✅ Recursos

- Validar boleto
- Identificar banco emissor
- Converter código de barras ⇄ linha digitável
- Identificar tipo de boleto e tipo de código
- Obter valor e vencimento (quando aplicável)
- Cálculo dos dígitos verificadores (Mod10 e Mod11)
- Compatível com fator de vencimento 2025+

---

## 🚀 Métodos disponíveis

| Método                                                | Descrição                                                                                 |
| ----------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `TipoCodigo identificarTipoCodigo(String codigo)`     | Retorna `TipoCodigo.codigoDeBarra`, `TipoCodigo.linhaDigitavel` ou `TipoCodigo.invalido`. |
| `TipoBoleto? identificarTipoBoleto(String codigo)`    | Retorna se o boleto é bancário, convênio ou arrecadação.                                  |
| `DateTime identificarData(...)`                       | Retorna a data de vencimento do boleto (exceto arrecadação).                              |
| `DateTime identificarDataComNovoFator2025(...)`       | Mesmo que o anterior, com base na nova referência de fator (22/02/2025).                  |
| `double identificarValor(String codigo)`              | Retorna o valor do boleto (com casas decimais corretas).                                  |
| `String codBarrasParaLinhaDigitavel(...)`             | Converte código de barras para linha digitável.                                           |
| `String linhaDigitavelParaCodBarras(String codigo)`   | Converte linha digitável para código de barras.                                           |
| `String calculaDVCodBarras(...)`                      | Calcula dígito verificador do código de barras usando módulo 10 ou 11.                    |
| `bool validarCodigoComDV(...)`                        | Retorna se o código informado é válido com base no DV.                                    |
| `String calculaMod10(String numero)`                  | Cálculo manual de módulo 10.                                                              |
| `String calculaMod11(String numero)`                  | Cálculo manual de módulo 11.                                                              |
| `BoletoValidado validarBoleto(...)`                   | Retorna objeto com todos os dados analisados do boleto.                                   |
| `BancoEmissor identificarBancoEmissor(String codigo)` | Retorna nome, número e ISPB do banco emissor.                                             |

---

## 🧠 Estrutura dos Boletos

### 🏦 Boleto Bancário

#### Código de Barras (44 dígitos)

| Bloco | Posições | Definição                    |
| ----- | -------- | ---------------------------- |
| 1     | 0 a 2    | Código do Banco              |
| 2     | 3 a 3    | Código da Moeda              |
| 3     | 4 a 4    | Dígito verificador geral     |
| 4     | 5 a 8    | Fator de vencimento          |
| 5     | 9 a 18   | Valor (com 2 casas decimais) |
| 6     | 19 a 43  | Campo livre                  |

#### Linha Digitável (47 dígitos)

| Campo | Posições | Descrição                            |
| ----- | -------- | ------------------------------------ |
| A     | 0 a 2    | Código do banco                      |
| B     | 3 a 3    | Moeda                                |
| C     | 4 a 8    | Campo livre                          |
| X     | 9 a 9    | DV bloco 1                           |
| D     | 10 a 19  | Campo livre                          |
| Y     | 20 a 20  | DV bloco 2                           |
| E     | 21 a 30  | Campo livre                          |
| Z     | 31 a 31  | DV bloco 3                           |
| K     | 32 a 32  | DV geral (mesmo do código de barras) |
| U     | 33 a 36  | Fator de vencimento                  |
| V     | 37 a 43  | Valor                                |

---

### 🧾 Boleto de Arrecadação / Convênio

> Boletos iniciados com `8` (ex: conta de luz, telecom, água...)

#### Código de Barras (44 dígitos)

| Bloco | Posições | Definição                             |
| ----- | -------- | ------------------------------------- |
| 1     | 0 a 0    | "8" - Identificador de arrecadação    |
| 2     | 1 a 1    | Segmento (veja abaixo)                |
| 3     | 2 a 2    | Valor real ou referência              |
| 4     | 3 a 3    | Dígito verificador geral              |
| 5     | 4 a 14   | Valor (centavos)                      |
| 6     | 15 a 43  | Campo livre (instituição ou convênio) |

#### Linha Digitável (48 dígitos)

| Campo | Posições | Descrição              |
| ----- | -------- | ---------------------- |
| A     | 0 a 0    | "8" Identificação      |
| B     | 1 a 1    | Segmento               |
| C     | 2 a 2    | Tipo de valor          |
| D     | 3 a 3    | DV geral               |
| E     | 4 a 14   | Valor (centavos)       |
| F     | 15 a 18  | Identificação do órgão |
| G     | 19 a 43  | Campo livre            |
| DV1   | 11 a 11  | DV bloco 1             |
| DV2   | 23 a 23  | DV bloco 2             |
| DV3   | 35 a 35  | DV bloco 3             |
| DV4   | 47 a 47  | DV bloco 4             |

---

### 📚 Segmentos de arrecadação

| Dígito | Segmento               |
| ------ | ---------------------- |
| 1      | Arrecadação municipal  |
| 2      | Saneamento             |
| 3      | Energia elétrica e gás |
| 4      | **Telecomunicações**   |
| 5      | Órgãos governamentais  |
| 6 / 9  | Outros                 |
| 7      | Multas de trânsito     |

---

### 💡 Observações importantes

- A **data de vencimento só pode ser lida em boletos bancários** (com fator de vencimento).
- Boletos de arrecadação **não contêm vencimento codificado** — deve ser extraído manualmente ou de fontes externas.
- O **valor** em boletos de arrecadação está sempre nas posições 5 a 15 do código de barras e representa **centavos**.

```txt
Exemplo:
Código de barras: 84660000001993000481000112208428092308214933
Valor extraído:   00000119300 → R$ 119,30
```

---

## 📦 Instalação

```yaml
dependencies:
  boleto_utils:
```

---

## ▶️ Exemplo rápido

```dart
import 'package:boleto_utils/boleto_utils.dart';

void main() {
  final codigo = '34191790010104351004791020150008291070000005000';

  final boleto = BoletoUtils();
  final tipo = boleto.identificarTipoBoleto(codigo);
  final valor = boleto.identificarValor(codigo);
  final vencimento = boleto.identificarData(
    codigo: codigo,
    tipoCodigo: TipoCodigo.codigoDeBarras,
  );

  print('Tipo: $tipo');
  print('Valor: R\$ ${valor.toStringAsFixed(2)}');
  print('Vencimento: $vencimento');
}
```

---

## 👨‍💻 Contribuições

Contribuições são bem-vindas! Relate issues ou envie PRs com melhorias e testes.

---

## 🤝 Contribuindo

Este projeto é open source. Sinta-se à vontade para:

- Reportar bugs
- Sugerir funcionalidades
- Enviar pull requests com correções ou melhorias
- Criar issues com dúvidas ou ideias

---

## 📄 Licença

Distribuído sob a licença MIT. Consulte o arquivo `LICENSE` para mais informações.
