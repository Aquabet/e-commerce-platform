class Product {
  int? id;
  final String name;
  final double price;
  final int categoryId;
  bool isFavorite;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category_id': categoryId,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      categoryId: map['category_id'],
      isFavorite: map['is_favorite'] == 1,
    );
  }
}
