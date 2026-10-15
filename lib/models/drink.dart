class Drink {
  const Drink({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.rating,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final String category;
  final double rating;
}
