import 'package:flutter/services.dart';

class BlacklistService {
  static final Set<String> blacklist = {};

  static Future<void> loadBlacklist() async {
    final String data = await rootBundle.loadString('assets/scam_links.txt');

    final lines = data.split('\n');

    for (final line in lines) {
      final cleaned = line.trim().toLowerCase();

      if (cleaned.isEmpty) continue;

      blacklist.add(cleaned);

      final urlMatches = RegExp(r'https?:\/\/[^\s,)]+').allMatches(cleaned);
      for (final match in urlMatches) {
        final url = match.group(0)!;
        blacklist.add(url);

        final uri = Uri.tryParse(url);
        if (uri != null && uri.host.isNotEmpty) {
          blacklist.add(uri.host.toLowerCase());
        }
      }

      final domainMatches = RegExp(
        r'\b[a-z0-9.-]+\.(com|com\.my|my|net|org|biz|info|online|site|xyz|tk)\b',
      ).allMatches(cleaned);

      for (final match in domainMatches) {
        blacklist.add(match.group(0)!.toLowerCase());
      }
    }

    print('Blacklist loaded: ${blacklist.length} items');
  }

  static bool isBlacklisted(String url) {
    final lowerUrl = url.toLowerCase();

    for (final item in blacklist) {
      if (lowerUrl.contains(item)) {
        return true;
      }
    }

    return false;
  }

  static List<String> getMatchedItems(String url) {
    final lowerUrl = url.toLowerCase();
    final List<String> matches = [];

    for (final item in blacklist) {
      if (lowerUrl.contains(item)) {
        matches.add(item);
      }
    }

    return matches;
  }
} 