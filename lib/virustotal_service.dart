import 'dart:convert';
import 'package:http/http.dart' as http;

class VirusTotalService {
  static const String _apiKey = 'YOUR-VIRUSTOTAL-API-KEY';

  static Future<Map<String, dynamic>> checkUrl(String url) async {
    try {
      final scanResponse = await http.post(
        Uri.parse('https://www.virustotal.com/api/v3/urls'),
        headers: {
          'x-apikey': _apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'url': url,
        },
      );

      if (scanResponse.statusCode != 200) {
        return {
          'safe': false,
          'message': 'VirusTotal scan error: ${scanResponse.statusCode}',
          'malicious': 0,
          'suspicious': 0,
          'harmless': 0,
        };
      }

      final scanData = jsonDecode(scanResponse.body);
      final analysisId = scanData['data']['id'];

      await Future.delayed(const Duration(seconds: 8));

      final reportResponse = await http.get(
        Uri.parse('https://www.virustotal.com/api/v3/analyses/$analysisId'),
        headers: {
          'x-apikey': _apiKey,
          'accept': 'application/json',
        },
      );

      if (reportResponse.statusCode != 200) {
        return {
          'safe': false,
          'message': 'VirusTotal report error: ${reportResponse.statusCode}',
          'malicious': 0,
          'suspicious': 0,
          'harmless': 0,
        };
      }

      final reportData = jsonDecode(reportResponse.body);
      final stats = reportData['data']['attributes']['stats'];

      final int malicious = stats['malicious'] ?? 0;
      final int suspicious = stats['suspicious'] ?? 0;
      final int harmless = stats['harmless'] ?? 0;

      final bool isUnsafe = malicious > 0 || suspicious > 0;

      return {
        'safe': !isUnsafe,
        'message': isUnsafe
            ? 'VirusTotal detected $malicious malicious and $suspicious suspicious result(s).'
            : 'VirusTotal did not detect any malicious result.',
        'malicious': malicious,
        'suspicious': suspicious,
        'harmless': harmless,
      };
    } catch (e) {
      return {
        'safe': false,
        'message': 'VirusTotal connection error: $e',
        'malicious': 0,
        'suspicious': 0,
        'harmless': 0,
      };
    }
  }
}
