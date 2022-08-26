

# Package com métodos úteis para a validação de todos os tipos de boleto

###  1. Recursos
- [x] Validar boleto
- [x] Código de barras para linha digitável
- [x] Linha digitável para código de barras
- [x] Identificar tipo de boleto
- [x] Identificar tipo de código
- [x] Identificar data de vencimento
- [x] Identificar valor do boleto
- [x] Cálculo digito verrificador módulo 10
- [x] Cálculo digito verrificador módulo 11
## 2. Métodos
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

## 3. Regras de numeração dos boletos
---
### 4.1 __`BOLETO COBRANÇA`__
>**IMPORTANTE**: As posições aqui mencionadas partem do número 0 e não do 1, a fim de facilitar o entendimento lógico
---
#### 4.1.1 __TIPO:__ CÓDIGO DE BARRAS (44 POSIÇÕES NUMÉRICAS)

##### __EXEMPLO:__ 11123444455555555556666666666666666666666666
---
<table border ='1'>
    <tr>
        <td>Bloco</td>
        <td>Posições</td>
        <td>Definição</td>
    </tr>
    <tr>
        <td>1</td>
        <td>0 a 2</td>
        <td>Código do Banco na Câmara de Compensação</td>
    </tr>
    <tr>
        <td>2</td>
        <td>3 a 3</td>
        <td>Código da Moeda = 9 (Real)</td>
    </tr>
    <tr>
        <td>3</td>
        <td>4 a 4</td>
        <td>Digito Verificador (DV) do código de Barras</td>
    </tr>
    <tr>
        <td>4</td>
        <td>5 a 8</td>
        <td>Fator de Vencimento</td>
    </tr>
    <tr>
        <td>5</td>
        <td>9 a 18</td>
        <td>Valor com 2 casas de centavos</td>
    </tr>
    <tr>
        <td>6</td>
        <td>19 a 43</td>
        <td>Campo Livre (De uso da instituição bancária)</td>
    </tr>
</table>

---
#### 4.1.2 __TIPO:__ LINHA DIGITÁVEL (47 POSIÇÕES NUMÉRICAS)

##### __EXEMPLO__: AAABC.CCCCX DDDDD.DDDDDY EEEEE.EEEEEZ K UUUUVVVVVVVVVV
---

##### __EXEMPLO:__ 11123444455555555556666666666666666666666666
---
<table border ='1'>
    <tr>
        <td>Campo</td>
        <td>Posições linha dig</td>
        <td>Definição</td>
    </tr>
    <tr>
        <td>A</td>
        <td>0 a 2 (0 a 2 do cód. barras)</td>
        <td>Código do Banco na Câmara de compensação</td>
    </tr>
    <tr>
        <td>B</td>
        <td>3 a 3 (3 a 3 do cód. barras)</td>
        <td>Código da moeda</td>
    </tr>
    <tr>
        <td>C</td>
        <td>4 a 8 (19 a 23 do cód. barras)</td>
        <td>Campo Livre</td>
    </tr>
    <tr>
        <td>X</td>
        <td>9 a 9</td>
        <td>Dígito verificador do Bloco 1 (Módulo 10)</td>
    </tr>
    <tr>
        <td>D</td>
        <td>10 a 19 (24 a 33 do cód. barras)</td>
        <td>Campo Livre</td>
    </tr>
    <tr>
        <td>Y</td>
        <td>20 a 20</td>
        <td>Dígito verificador do Bloco 2 (Módulo 10)</td>
    </tr>
    <tr>
        <td>E</td>
        <td>21 a 30 (24 a 43 do cód. barras)</td>
        <td>Campo Livre</td>
    </tr>
    <tr>
        <td>Z</td>
        <td>31 a 31</td>
        <td>Dígito verificador do Bloco 3 (Módulo 10)</td>
    </tr>
    <tr>
        <td>K</td>
        <td>32 a 32 (4 a 4 do cód. barras)</td>
        <td>Dígito verificador do código de barras</td>
    </tr>
    <tr>
        <td>U</td>
        <td>33 a 36 (5 a 8 do cód. barras)</td>
        <td>Fator de Vencimento</td>
    </tr>
    <tr>
        <td>V</td>
        <td>37 a 43 (9 a 18 do cód. barras)</td>
        <td>Valor</td>
    </tr>
</table>

---
### 4.2 __`CONTA CONVÊNIO / ARRECADAÇÃO`__

#### 4.2.1 __TIPO:__ CÓDIGO DE BARRAS (44 POSIÇÕES NUMÉRICAS)
---
##### __EXEMPLO__: 12345555555555566667777777777777777777777777
---

<table border ='1'>
    <tr>
        <td>Bloco</td>
        <td>Posições</td>
        <td>Definição</td>
    </tr>
    <tr>
        <td>1</td>
        <td>0 a 0</td>
        <td>"8" Identificação da Arrecadação/convênio</td>
    </tr>
    <tr>
        <td>2</td>
        <td>1 a 1</td>
        <td>Identificação do segmento</td>
    </tr>
    <tr>
        <td>3</td>
        <td>2 a 2</td>
        <td>Identificação do valor real ou referência</td>
    </tr>
    <tr>
        <td>4</td>
        <td>3 a 3</td>
        <td>Dígito verificador geral (módulo 10 ou 11)</td>
    </tr>
    <tr>
        <td>5</td>
        <td>4 a 14</td>
        <td>Valor efetivo ou valor referência</td>
    </tr>
    <tr>
        <td>6</td>
        <td>15 a 18</td>
        <td>Identificação da empresa/órgão</td>
    </tr>
    <tr>
        <td>6</td>
        <td>19 a 43</td>
        <td>CCampo livre de utilização da empresa/órgão</td>
    </tr>
</table>

---
#### 4.2.2 __TIPO:__ LINHA DIGITÁVEL (48 POSIÇÕES NUMÉRICAS)
---
##### __EXEMPLO__: ABCDEEEEEEE-W EEEEFFFFGGG-X GGGGGGGGGGG-Y GGGGGGGGGGG-Z
---
<table border ='1'>
    <tr>
        <td>Campo</td>
        <td>Posições</td>
        <td>Definição</td>
    </tr>
    <tr>
        <td>A</td>
        <td>0 a 0</td>
        <td>"8" Identificação da Arrecadação/convênio</td>
    </tr>
    <tr>
        <td>B</td>
        <td>1 a 1</td>
        <td>Identificação do segmento</td>
    </tr>
    <tr>
        <td>C</td>
        <td>2 a 2</td>
        <td>Identificação do valor real ou referência</td>
    </tr>
    <tr>
        <td>D</td>
        <td>3 a 3</td>
        <td>Dígito verificador geral (módulo 10 ou 11)</td>
    </tr>
    <tr>
        <td>E</td>
        <td>1 A 14</td>
        <td>Valor efetivo ou valor referência</td>
    </tr>
    <tr>
        <td>W</td>
        <td>11 a 11</td>
        <td>Dígito verificador do Bloco 1</td>
    </tr>
    <tr>
        <td>F</td>
        <td>15 a 18</td>
        <td>Identificação da empresa/órgão</td>
    </tr>
    <tr>
        <td>G</td>
        <td>19 a 43</td>
        <td>Campo livre de utilização da empresa/órgão</td>
    </tr>
    <tr>
        <td>X</td>
        <td>23 a 23</td>
        <td>Dígito verificador do Bloco 2</td>
    </tr>
    <tr>
        <td>Y</td>
        <td>35 a 35</td>
        <td>Dígito verificador do Bloco 3</td>
    </tr>
    <tr>
        <td>Z</td>
        <td>47 a 47</td>
        <td>Dígito verificador do Bloco 4</td>
    </tr>
</table>

