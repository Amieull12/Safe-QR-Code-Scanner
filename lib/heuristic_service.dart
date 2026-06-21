class HeuristicService {
  static bool isSuspicious(String link) {
    return getReasons(link).isNotEmpty;
  }

  static bool shouldShowSemakMuleAdvisory(String link) {
    final lower = link.toLowerCase();

    final semakMuleTriggers = [
      'bank',
      'payment',
      'transfer',
      'duitnow',
      'ewallet',
      'account',
      'claim',
      'reward',
    ];

    return semakMuleTriggers.any((word) => lower.contains(word));
  }

  static List<String> getReasons(String link) {
    final lower = link.toLowerCase();
    final Set<String> reasons = {};

    final uri = Uri.tryParse(link);
    final host = uri?.host.toLowerCase() ?? '';

    // 1. General phishing keywords
    final phishingKeywords = [
      'login',
      'verify',
      'verification',
      'secure',
      'update',
      'password',
      'account',
      'bank',
      'payment',
      'wallet',
      'claim',
      'reward',
    ];

    for (final keyword in phishingKeywords) {
      if (lower.contains(keyword)) {
        reasons.add('Contains phishing keyword: $keyword');
      }
    }

    // 2. Suspicious TLDs
    final badTlds = [
      '.xyz',
      '.top',
      '.tk',
      '.info',
      '.buzz',
      '.site',
      '.net',
      '.us',
      '.org',
      '.wang',
    ];

    for (final tld in badTlds) {
      if (host.endsWith(tld) || lower.contains(tld)) {
        reasons.add('Uses suspicious domain extension: $tld');
      }
    }

    // 3. Special symbol detection
    if (lower.contains('@')) {
      reasons.add('Contains suspicious @ symbol');
    }

    if (lower.contains('%')) {
      reasons.add('Contains encoded special character %');
    }

    if (lower.contains('//') && lower.lastIndexOf('//') > 8) {
      reasons.add('Contains suspicious double slash redirect');
    }

    // 4. Excessive dots / subdomains
    if (host.isNotEmpty) {
      final dotCount = '.'.allMatches(host).length;

      if (dotCount >= 3) {
        reasons.add('Too many subdomains/excessive dots detected');
      }
    }

    // 5. Raw IP address URL
    final ipPattern = RegExp(r'\b\d{1,3}(\.\d{1,3}){3}\b');

    if (ipPattern.hasMatch(host)) {
      reasons.add('Uses raw IP address instead of domain');
    }

   
    // 6. URL shorteners
    final shorteners = [
      'bit.ly',
      'tinyurl.com',
      'cutt.ly',
      'is.gd',
      't.co',
      'shorturl.at',
      'rebrand.ly',
    ];

    for (final shortener in shorteners) {
      if (host.contains(shortener)) {
        reasons.add('Uses URL shortener: $shortener');
      }
    }

    return reasons.toList();
  }
}