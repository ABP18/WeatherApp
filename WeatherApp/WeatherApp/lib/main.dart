import 'package:flutter/material.dart';
import 'package:weatherapp/screens/weather_home_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:weatherapp/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notifications
  await NotificationService().initialize();
  // Set the WebView platform implementation
  _setupWebViewPlatform();
  runApp(const MyApp());
}

void _setupWebViewPlatform() {
  // Set the platform implementation for WebView
  if (WebViewPlatform.instance == null) {
    WebViewPlatform.instance = WebKitWebViewPlatform(); // For iOS
    WebViewPlatform.instance = AndroidWebViewPlatform(); // For Android
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherHomePage(),
    );
  }
}