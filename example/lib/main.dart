import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:boleto_utils/boleto_utils.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late BoletoUtils boletoUtils;
  BoletoValidado? boletoValidado;
  StreamSubscription? streamBarcode;

  @override
  void initState() {
    super.initState();
    boletoUtils = BoletoUtils();
  }

  Future<void> startBarcodeScanStream(BuildContext context) async {
    FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    ).then(
      (barcode) async {
        if (barcode.length == 44) {
          boletoValidado = boletoUtils.validarBoleto(barcode);
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InfosBoleto(boletoValidado),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BoletoUtils'),
      ),
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async => await startBarcodeScanStream(context),
              child: const Text('Start barcode scan'),
            ),
          ],
        ),
      ),
    );
  }
}

class InfosBoleto extends StatelessWidget {
  const InfosBoleto(
    this.boletoValidado, {
    Key? key,
  }) : super(key: key);

  final BoletoValidado? boletoValidado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Boleto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText('Sucesso: ${boletoValidado?.sucesso}\n'),
            SelectableText('mensagem: ${boletoValidado?.mensagem}\n'),
            SelectableText(
                'Código de entrada:\n${boletoValidado?.codigoInput}\n'),
            SelectableText(
                'Tipo de código de entrada: ${boletoValidado?.tipoCodigoInput}\n'),
            SelectableText('Tipo de boleto: ${boletoValidado?.tipoBoleto}\n'),
            SelectableText(
                'Código de barras:\n ${boletoValidado?.codigoBarras}\n'),
            SelectableText(
                'Linha digitável:\n${boletoValidado?.linhaDigitavel}\n'),
            SelectableText('Banco emissor: ${boletoValidado?.bancoEmissor}\n'),
            SelectableText('Vencimento: ${boletoValidado?.vencimento}\n'),
            SelectableText('Valor: ${boletoValidado?.valor}\n'),
          ],
        ),
      ),
    );
  }
}
