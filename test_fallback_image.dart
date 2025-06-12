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
      title: 'QR Code Fallback Image Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QrFallbackImageTestPage(),
    );
  }
}

class QrFallbackImageTestPage extends StatelessWidget {
  const QrFallbackImageTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Fallback Image Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Primary image loads successfully',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: PrettyQrView.data(
                data: 'https://example.com/primary-works',
                decoration: const PrettyQrDecoration(
                  shape: PrettyQrHybridSymbol(
                    color: Colors.black,
                    smoothFactor: 1.0,
                  ),
                  image: PrettyQrDecorationImage(
                    image: AssetImage('images/flutter.png'), // This should load
                    fallbackImage: AssetImage('images/android12splash copy.png'),
                    position: PrettyQrDecorationImagePosition.embedded,
                    scale: 0.3,
                  ),
                  quietZone: PrettyQrQuietZone.modules(4),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            const Text(
              'Primary image fails, fallback image used',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: PrettyQrView.data(
                data: 'https://example.com/primary-fails',
                decoration: const PrettyQrDecoration(
                  shape: PrettyQrHybridSymbol(
                    color: Colors.black,
                    smoothFactor: 1.0,
                  ),
                  image: PrettyQrDecorationImage(
                    image: AssetImage('images/nonexistent.png'), // This will fail
                    fallbackImage: AssetImage('images/flutter.png'), // This should load
                    position: PrettyQrDecorationImagePosition.embedded,
                    scale: 0.3,
                  ),
                  quietZone: PrettyQrQuietZone.modules(4),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            const Text(
              'Both images fail, no image displayed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: PrettyQrView.data(
                data: 'https://example.com/both-fail',
                decoration: const PrettyQrDecoration(
                  shape: PrettyQrHybridSymbol(
                    color: Colors.black,
                    smoothFactor: 1.0,
                  ),
                  image: PrettyQrDecorationImage(
                    image: AssetImage('images/nonexistent1.png'), // This will fail
                    fallbackImage: AssetImage('images/nonexistent2.png'), // This will also fail
                    position: PrettyQrDecorationImagePosition.embedded,
                    scale: 0.3,
                  ),
                  quietZone: PrettyQrQuietZone.modules(4),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            const Text(
              'No fallback image specified',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: PrettyQrView.data(
                data: 'https://example.com/no-fallback',
                decoration: const PrettyQrDecoration(
                  shape: PrettyQrHybridSymbol(
                    color: Colors.black,
                    smoothFactor: 1.0,
                  ),
                  image: PrettyQrDecorationImage(
                    image: AssetImage('images/flutter.png'),
                    // No fallbackImage specified
                    position: PrettyQrDecorationImagePosition.embedded,
                    scale: 0.3,
                  ),
                  quietZone: PrettyQrQuietZone.modules(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
