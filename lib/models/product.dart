class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final double oldPrice;
  final String imageUrl;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'old_price': oldPrice,
      'image': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      oldPrice: map['old_price'],
      imageUrl: map['image'],
    );
  }
}
