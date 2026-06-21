class UrlHelper {
  static String normalizeUrl(String input) {
    String value = input.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('www.')) {
      return 'https://$value';
    }

    return value;
  }

  static bool isValidHttpUrl(String text) {
    final normalized = normalizeUrl(text);
    final uri = Uri.tryParse(normalized);

    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}