import 'package:collection/collection.dart';
import 'package:flutter_app_test_stacked/app/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/models/cart_entry.dart';
import 'package:flutter_app_test_stacked/models/product.dart';

abstract class MockData {
  static const category1 = 'category1';

  static const product1 = Product(
    id: 1,
    title: "product1 Title",
    description: "product1 Description",
    price: 549,
    discountPercentage: 12.96,
    rating: 4.69,
    stock: 94,
    brand: "product1 Brand",
    category: category1,
    thumbnail: "thumbnail.jpg",
    images: ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "thumbnail.jpg"],
  );

  static const product2 = Product(
    id: 2,
    title: "product2 Title",
    description: "product2 Description",
    price: 151,
    discountPercentage: 13.96,
    rating: 4.5,
    stock: 754,
    brand: "product2 Brand",
    category: category1,
    thumbnail: "thumbnail.jpg",
    images: ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "thumbnail.jpg"],
  );

  static const category2 = 'category2';

  static const product3 = Product(
    id: 3,
    title: "product3 Title",
    description: "product3 Description",
    price: 753,
    discountPercentage: 16.96,
    rating: 4.53,
    stock: 34,
    brand: "product3 Brand",
    category: category2,
    thumbnail: "thumbnail.jpg",
    images: ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "thumbnail.jpg"],
  );

  static const product4 = Product(
    id: 4,
    title: "product4 Title",
    description: "product4 Description",
    price: 897,
    discountPercentage: 12.43,
    rating: 3.53,
    stock: 65,
    brand: "product4 Brand",
    category: category2,
    thumbnail: "thumbnail.jpg",
    images: ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "thumbnail.jpg"],
  );

  static const category3 = 'category3';

  static const product5 = Product(
    id: 5,
    title: "product5 Title",
    description: "product5 Description",
    price: 45,
    discountPercentage: 12.2,
    rating: 3.8,
    stock: 5,
    brand: "product5 Brand",
    category: category3,
    thumbnail: "thumbnail.jpg",
    images: ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "thumbnail.jpg"],
  );

  static const category4 = 'category4';

  static const product6 = Product(
    id: 6,
    title: "product6 Title",
    description: "product6 Description",
    price: 75,
    discountPercentage: 3.96,
    rating: 4.6,
    stock: 0,
    brand: "product6 Brand",
    category: category4,
    thumbnail: "thumbnail.jpg",
    images: ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "thumbnail.jpg"],
  );

  static const product7 = Product(
    id: 7,
    title: "product7 Title",
    description: "product7 Description",
    price: 11,
    discountPercentage: 56.43,
    rating: 4.8,
    stock: 54,
    brand: "product7 Brand",
    category: category4,
    thumbnail: "thumbnail.jpg",
    images: ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "thumbnail.jpg"],
  );

  static const category5 = 'category5';

  static const product8 = Product(
    id: 8,
    title: "product8 Title",
    description: "product8 Description",
    price: 76,
    discountPercentage: 24.96,
    rating: 2.6,
    stock: 675,
    brand: "product8 Brand",
    category: category5,
    thumbnail: "thumbnail.jpg",
    images: ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "thumbnail.jpg"],
  );

  static const product9 = Product(
    id: 9,
    title: "product9 Title",
    description: "product9 Description",
    price: 11,
    discountPercentage: 56.43,
    rating: 4.8,
    stock: 54,
    brand: "product9 Brand",
    category: category5,
    thumbnail: "thumbnail.jpg",
    images: ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "thumbnail.jpg"],
  );

  static const product10 = Product(
    id: 10,
    title: "product10 Title",
    description: "product10 Description",
    price: 11,
    discountPercentage: 56.43,
    rating: 4.8,
    stock: 54,
    brand: "product10 Brand",
    category: category5,
    thumbnail: "thumbnail.jpg",
    images: ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "thumbnail.jpg"],
  );

  static List<Product> get products => [
        product1,
        product2,
        product3,
        product4,
        product5,
        product6,
        product7,
        product8,
        product9,
        product10,
      ];

  static List<String> get categories => [
        category1,
        category2,
        category3,
        category4,
        category5,
      ];

  static List<Product> getCategoryProducts(String category) =>
      products.whereList(
        (p) => p.category == category,
      );

  static Product get zeroStockProduct => product6;
  static Product get lowStockProduct => product5;
  static Product get normalStockProduct => product1;

  static final cartEntry1 = CartEntry(
    id: 1,
    productId: product1.id,
    count: 1,
  );

  static final cartEntry2 = CartEntry(
    id: 2,
    productId: product2.id,
    count: 3,
  );

  static final cartEntry3 = CartEntry(
    id: 3,
    productId: product3.id,
    count: 2,
  );

  static List<CartEntry> get cartEntries => [
        cartEntry1,
        cartEntry2,
        cartEntry3,
      ];

  static List<Product> get cartProducts {
    final ids = cartEntries.mapList((entry) => entry.productId);

    return products.whereList((e) => ids.contains(e.id));
  }

  static int get cartCount => cartEntries.reduceAndCompute(
        (acc, element) => acc + element.count,
        0,
      );

  static double get cartTotal => products.reduceAndCompute(
        (acc, product) {
          final cartEntry = cartEntries
              .firstWhereOrNull((entry) => entry.productId == product.id);

          if (cartEntry != null) {
            return acc + product.price * cartEntry.count;
          }

          return acc;
        },
        0.0,
      );
}
