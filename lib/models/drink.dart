class Drink {
  const Drink({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.rating,
    this.ingredients = const [],
    this.volumes = const {'S': 200, 'M': 300, 'L': 400},
    this.sizeExtras = const {'S': -200, 'M': 0, 'L': 300},
    this.milkOptions = const ['Whole', 'Oat', 'Almond'],
    this.syrupOptions = const ['None', 'Vanilla', 'Caramel', 'Hazelnut'],
    this.serving = 'Hot',
    this.caffeine = 'Contains caffeine',
    this.allergens = 'Milk; almond milk contains nuts',
    this.milkExtra = 300,
    this.syrupExtra = 200,
  });

  final List<String> ingredients;
  final Map<String, int> volumes;
  final Map<String, double> sizeExtras;
  final List<String> milkOptions;
  final List<String> syrupOptions;
  final String serving;
  final String caffeine;
  final String allergens;
  final double milkExtra;
  final double syrupExtra;
  String get defaultSize => volumes.containsKey('M') ? 'M' : volumes.keys.first;
  String get defaultMilk => milkOptions.isEmpty ? 'None' : milkOptions.first;
  int volumeFor(String size) => volumes[size] ?? volumes[defaultSize]!;
  double priceFor(String size) => price + (sizeExtras[size] ?? 0);

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final String category;
  final double rating;
}
