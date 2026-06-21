import 'package:http/http.dart' as http;

class RedirectService {
  static Future<Map<String, dynamic>> inspectRedirect(String url) async {
    try {
      final startUri = Uri.tryParse(url);

      if (startUri == null) {
        return {
          'success': false,
          'originalUrl': url,
          'finalUrl': url,
          'redirected': false,
          'message': 'Invalid URL',
        };
      }

      final client = http.Client();

      Uri currentUri = startUri;
      bool redirected = false;
      int redirectCount = 0;

      while (redirectCount < 10) {
        final request = http.Request('GET', currentUri)
          ..followRedirects = false
          ..headers.addAll({
            'User-Agent':
                'Mozilla/5.0 (Android) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          });

        final response = await client.send(request).timeout(
          const Duration(seconds: 10),
        );

        final statusCode = response.statusCode;
        final location = response.headers['location'];

        if (statusCode >= 300 && statusCode < 400 && location != null) {
          redirected = true;
          redirectCount++;

          currentUri = currentUri.resolve(location);
          continue;
        }

        break;
      }

      client.close();

      final finalUrl = currentUri.toString();

      return {
        'success': true,
        'originalUrl': url,
        'finalUrl': finalUrl,
        'redirected': redirected || finalUrl != url,
        'message': redirected || finalUrl != url
            ? 'Redirect detected. Final destination inspected.'
            : 'No redirect detected.',
      };
    } catch (e) {
      return {
        'success': false,
        'originalUrl': url,
        'finalUrl': url,
        'redirected': false,
        'message': 'Redirect inspection failed: $e',
      };
    }
  }
}