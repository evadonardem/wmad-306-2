import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

Future<void> main() async {
  final server = await HttpServer.bind('localhost', 8080);
  print('CORS proxy running at http://localhost:8080');

  await for (final request in server) {
    _setCorsHeaders(request.response.headers);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    final targetUri = Uri.https(
      'superheroapi.com',
      '/api${request.uri.path}',
      request.uri.queryParameters,
    );
    print('Proxy request: ${request.method} ${request.uri} -> $targetUri');

    final client = HttpClient();
    client.autoUncompress = false;

    try {
      final clientRequest = await client.openUrl(request.method, targetUri);
      request.headers.forEach((name, values) {
        final lowerName = name.toLowerCase();
        if (lowerName == 'host' || lowerName == 'content-length') {
          return;
        }
        clientRequest.headers.set(name, values);
      });

      if (request.contentLength > 0) {
        await clientRequest.addStream(request.cast<Uint8List>());
      }

      final clientResponse = await clientRequest.close();
      request.response.statusCode = clientResponse.statusCode;
      clientResponse.headers.forEach((name, values) {
        final lowerName = name.toLowerCase();
        if (lowerName == 'transfer-encoding') {
          return;
        }
        request.response.headers.set(name, values);
      });
      await clientResponse.pipe(request.response);
    } catch (error, stackTrace) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.headers.set('Content-Type', 'application/json');
      request.response.write(jsonEncode({
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      }));
      await request.response.close();
    }
  }
}

void _setCorsHeaders(HttpHeaders headers) {
  headers.set('Access-Control-Allow-Origin', '*');
  headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  headers.set('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');
  headers.set('Access-Control-Allow-Credentials', 'false');
  headers.set('Access-Control-Max-Age', '86400');
}
