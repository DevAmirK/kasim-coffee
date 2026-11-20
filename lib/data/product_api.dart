import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

const _configuredApiUrl = String.fromEnvironment(
  'API_URL',
);

String get _apiUrl => _configuredApiUrl.isNotEmpty
    ? _configuredApiUrl
    : !kIsWeb && defaultTargetPlatform == TargetPlatform.android
    ? 'http://10.0.2.2:8080'
    : 'http://localhost:8080';

Future<List<Product>> fetchProducts() async {
  final url = Uri.parse(_apiUrl).resolve('/products');
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    switch (response.statusCode) {
      case 200:
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json is! List ||
            json.any((item) => item is! Map<String, dynamic>)) {
          throw const FormatException('Invalid product list.');
        }
        return json.cast<Map<String, dynamic>>().map(Product.fromJson).toList();
      case 404:
        throw const CatalogException(
          'The catalog endpoint was not found (404).',
        );
      case 500:
        throw const CatalogException(
          'The catalog server returned an error (500).',
        );
      default:
        throw CatalogException('Request failed (HTTP ${response.statusCode}).');
    }
  } on TimeoutException {
    throw const CatalogException(
      'The request timed out. Check your connection.',
    );
  } on http.ClientException {
    throw const CatalogException(
      'Could not reach the catalog. Check your connection.',
    );
  } on FormatException {
    throw const CatalogException('The server returned invalid catalog data.');
  }
}

class CatalogException implements Exception {
  const CatalogException(this.message);

  final String message;
}
