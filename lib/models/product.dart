class Product {
  final int id;
  final String name;
  final int stock;
  final String price; // backend sends string; convert if you prefer
  final int category;
  final String categoryName;
  final String? image;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
    required this.category,
    required this.categoryName,
    required this.image,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'],
    name: j['name'] ?? '',
    stock: j['stock'] ?? 0,
    price: j['price']?.toString() ?? '0',
    category: j['category'] ?? 0,
    categoryName: j['category_name'] ?? '',
    image: j['image'],
    imageUrl: j['image_url'],
  );
}
