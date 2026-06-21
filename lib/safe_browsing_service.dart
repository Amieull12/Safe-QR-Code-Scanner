import 'dart:convert';
import 'package:http/http.dart' as http;

class SafeBrowsingService {
  static const String _apiKey = 'AIzaSyAUym-3wYJ-7AFJArPEYbK5f0a-43IWGXs';

  static Future<Map<String, dynamic>> checkUrl(String url) async {
    final Uri endpoint = Uri.parse(
      'https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$_apiKey',
    );

    final Map<String, dynamic> requestBody = {
      "client": {
        "clientId": "safe_qr_code_scanner_project",
        "clientVersion": "1.0.0"
      },
      "threatInfo": {
        "threatTypes": [
          "MALWARE",
          "SOCIAL_ENGINEERING",
          "UNWANTED_SOFTWARE",
          "POTENTIALLY_HARMFUL_APPLICATION"
        ],
        "platformTypes": ["ANY_PLATFORM"],
        "threatEntryTypes": ["URL"],
        "threatEntries": [
          {"url": url}
        ]
      }
    };

    try {
      final response = await http.post(
        endpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('matches')) {
          return {
            'safe': false,
            'message': 'Threat detected by Google Safe Browsing.',
            'matches': data['matches'],
          };
        } else {
          return {
            'safe': true,
            'message': 'No threat found by Google Safe Browsing.',
            'matches': [],
          };
        }
      } else {
        return {
          'safe': false,
          'message': 'API error: ${response.statusCode}',
          'matches': [],
        };
      }
    } catch (e) {
      return {
        'safe': false,
        'message': 'Connection error: $e',
        'matches': [],
      };
    }
  }
}