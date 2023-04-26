import 'dart:convert';

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromJson(String source) {
    return Product.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      price: map['price'].toDouble(),
      discountPercentage: map['discountPercentage'].toDouble(),
      rating: map['rating'].toDouble(),
      stock: map['stock'],
      brand: map['brand'],
      category: map['category'],
      thumbnail: map['thumbnail'],
      images: (map['images'] as List).cast<String>(),
    );
  }
}
