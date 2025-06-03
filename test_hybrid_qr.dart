import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hybrid QR Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QrDemoPage(),
    );
  }
}

class QrDemoPage extends StatelessWidget {
  const QrDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hybrid QR Style Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hybrid QR Code',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            PrettyQrView.data(
              data: 'https://example.com',
              decoration: const PrettyQrDecoration(
                shape: PrettyQrHybridSymbol(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  smoothFactor: 1.0,
                ),
                image: PrettyQrDecorationImage(
                  image: AssetImage('images/flutter.png'),
                  position: PrettyQrDecorationImagePosition.embedded,
                ),
                quietZone: PrettyQrQuietZone.modules(4),
              ),
            ),
            const SizedBox(height: 40),
            
            // Comparison with other styles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Rounded Style'),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: PrettyQrView.data(
                        data: 'https://example.com',
                        decoration: const PrettyQrDecoration(
                          shape: PrettyQrRoundedSymbol(),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Smooth Style'),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: PrettyQrView.data(
                        data: 'https://example.com',
                        decoration: const PrettyQrDecoration(
                          shape: PrettyQrSmoothSymbol(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
