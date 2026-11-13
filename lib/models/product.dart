import 'drink.dart';

class Product extends Drink {
  Product({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.price,
    required super.category,
    required super.rating,
    required super.ingredients,
    required super.volumes,
    required super.sizeExtras,
    required super.milkOptions,
    required super.syrupOptions,
    required super.serving,
    required super.caffeine,
    required super.allergens,
    required super.milkExtra,
    required super.syrupExtra,
    required this.reviewCount,
    required List<String> gallery,
  }) : gallery = List.unmodifiable(gallery);

  final int reviewCount;
  final List<String> gallery;

  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim();
    if (id == null || id.isEmpty) {
      throw const FormatException('Product ID is missing.');
    }

    final volumes = <String, int>{
      for (final entry in _object(json['volumes']).entries)
        if (entry.value is num && (entry.value as num).toInt() > 0)
          entry.key: (entry.value as num).toInt(),
    };
    final image = _text(json['imageUrl'], '');
    final gallery = <String>{
      if (image.isNotEmpty) image,
      ..._strings(json['gallery']),
    };
    final rating = _object(json['rating']);

    return Product(
      id: id,
      title: _text(json['title'], 'Untitled drink'),
      description: _text(json['description'], 'No description available.'),
      imageUrl: gallery.isEmpty ? '' : gallery.first,
      price: _number(json['price']),
      category: _text(json['category'], 'Drinks'),
      rating: _number(rating['rate'] ?? json['rating']).clamp(0, 5).toDouble(),
      reviewCount: _number(json['reviewCount'] ?? rating['count']).toInt(),
      gallery: gallery.toList(),
      ingredients: _strings(json['ingredients']),
      volumes: volumes.isEmpty ? const {'M': 300} : volumes,
      sizeExtras: {
        for (final entry in _object(json['sizeExtras']).entries)
          entry.key: _number(entry.value),
      },
      milkOptions: _strings(json['milkOptions']),
      syrupOptions: _strings(json['syrupOptions']),
      serving: _text(json['serving'], 'Regular'),
      caffeine: _text(json['caffeine'], 'Caffeine information unavailable.'),
      allergens: _text(json['allergens'], 'Ask about allergens'),
      milkExtra: _number(json['milkExtra']),
      syrupExtra: _number(json['syrupExtra']),
    );
  }

  static String _text(Object? value, String fallback) =>
      value is String && value.trim().isNotEmpty ? value : fallback;

  static double _number(Object? value) =>
      value is num && value.isFinite ? value.toDouble() : 0;

  static Map<String, dynamic> _object(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  static List<String> _strings(Object? value) => value is List
      ? value
            .whereType<String>()
            .where((item) => item.trim().isNotEmpty)
            .toList()
      : const [];
}
