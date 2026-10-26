import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  // Immutable app-side version of a document in Firestore's `items` collection.
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.sku,
    required this.status,
    required this.imageUrl,
    required this.imagePath,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int quantity;
  final String sku;
  final String status;
  final String imageUrl;
  final String imagePath;
  final DateTime? createdAt;

  factory Product.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    // Defaults let older or partially filled documents still display safely.
    final data = doc.data() ?? <String, dynamic>{};
    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      sku: data['sku'] as String? ?? '',
      status: data['status'] as String? ?? 'Available',
      imageUrl: data['imageUrl'] as String? ?? '',
      imagePath: data['imagePath'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
