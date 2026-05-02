import 'dart:io';
import 'package:flutter/foundation.dart';

/// HttpOverrides to allow bad certificates for testing SSL handshake issues
/// Only use this temporarily to confirm if handshake is the blocker
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

/// Initialize the HTTP overrides - call this in main() if needed
void initHttpOverrides() {
  if (!kReleaseMode) {
    // Only allow bad certificates in debug mode
    HttpOverrides.global = MyHttpOverrides();
  }
}
