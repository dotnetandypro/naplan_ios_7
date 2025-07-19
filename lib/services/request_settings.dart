class RequestSettings {
  /// The base URL for all API requests
  static const String baseUrl = 'https://naplanapi.tdagroup.online/api';

  /// Headers to be included in all API requests
  static Map<String, String> getHeaders() {
    return {
      'X-API-KEY': 'XCrossAPIkeyLocalhost',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Add additional headers to the default headers
  static Map<String, String> addHeaders(Map<String, String> additionalHeaders) {
    final headers = getHeaders();
    headers.addAll(additionalHeaders);
    return headers;
  }
}
