import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WeatherRadarPage extends StatefulWidget {
  const WeatherRadarPage({super.key});

  @override
  State<WeatherRadarPage> createState() => _WeatherRadarPageState();
}

class _WeatherRadarPageState extends State<WeatherRadarPage> {
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Asegura que la plataforma WebView esté inicializada
    if (InAppWebViewPlatform.instance == null) {
      setState(() {
        errorMessage = 'La plataforma WebView no está inicializada. Por favor, reinicia la aplicación.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar'),
        backgroundColor: const Color(0xFF2E335A),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          if (errorMessage == null)
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri('https://www.ventusky.com')),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                transparentBackground: true,
              ),
              onLoadError: (controller, url, code, message) {
                setState(() {
                  errorMessage = 'No se pudo cargar el radar: $message (Código: $code)';
                });
              },
            ),
          if (errorMessage != null)
            Center(
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}