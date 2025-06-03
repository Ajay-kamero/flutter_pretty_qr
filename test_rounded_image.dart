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
      title: 'Rounded Image QR Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QrRoundedImageDemoPage(),
    );
  }
}

class QrRoundedImageDemoPage extends StatelessWidget {
  const QrRoundedImageDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code with Rounded Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Square Image (Default)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: PrettyQrView.data(
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
            ),
            const SizedBox(height: 40),
            
            const Text(
              'Rounded Corners Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: PrettyQrView.data(
                data: 'https://example.com',
                decoration: PrettyQrDecoration(
                  shape: const PrettyQrHybridSymbol(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    smoothFactor: 1.0,
                  ),
                  image: PrettyQrDecorationImage.rounded(
                    image: const AssetImage('images/flutter.png'),
                    cornerRadius: 12.0,
                    position: PrettyQrDecorationImagePosition.embedded,
                  ),
                  quietZone: const PrettyQrQuietZone.modules(4),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            const Text(
              'Circular Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: PrettyQrView.data(
                data: 'https://example.com',
                decoration: PrettyQrDecoration(
                  shape: const PrettyQrHybridSymbol(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    smoothFactor: 1.0,
                  ),
                  image: PrettyQrDecorationImage.rounded(
                    image: const AssetImage('images/flutter.png'),
                    cornerRadius: 50.0, // Large value for a circular image
                    position: PrettyQrDecorationImagePosition.embedded,
                    scale: 0.25, // Slightly larger image
                  ),
                  quietZone: const PrettyQrQuietZone.modules(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
