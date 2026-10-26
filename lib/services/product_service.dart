import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/product.dart';

// ProductService products ka data Firebase Firestore mein save aur update karta hai.
// Product ki images ko Firebase Storage mein upload aur delete karne ka kaam bhi karta hai.
class ProductService {
  // Firestore ke 'items' collection ka reference return karta hai.
  // Isi collection mein products ke records store honge.
  CollectionReference<Map<String, dynamic>> get _items =>
      FirebaseFirestore.instance.collection('items');

  // Firebase Storage ka instance return karta hai.
  // Isko product images upload aur delete karne ke liye use kiya jata hai.
  FirebaseStorage get _storage => FirebaseStorage.instance;

  // Firestore se products ki real-time stream return karta hai.
  Stream<List<Product>> watchProducts() {
    // snapshots() collection mein hone wali changes ko continuously listen karta hai.
    // Har snapshot ke documents ko Product model mein convert karta hai.
    // Aakhir mein tamam products ki List return karta hai.
    return _items.snapshots().map(
      (snapshot) => snapshot.docs.map(Product.fromDocument).toList(),
    );
  }

  // Naya product save ya existing product update karta hai.
  // Agar image di gayi ho to usay bhi Firebase Storage mein upload karta hai.
  Future<void> saveProduct({
    String?
    id, // Existing product ki ID; null hone par naya product create hoga.
    required String name,
    required String description,
    required String category,
    required double price,
    required int quantity,
    required String sku,
    required String status,

    // Image file ka binary data receive karta hai.
    Uint8List? imageBytes,

    // Selected image ka file name receive karta hai.
    String? imageName,

    // Agar image kisi external URL par ho to uska link receive karta hai.
    String? externalImageUrl,

    // Product ki pehle se saved image ka download URL.
    String currentImageUrl = '',

    // Firebase Storage mein pehle se saved image ka path.
    String currentImagePath = '',
  }) async {
    // Agar ID null hai to Firestore naya document ID generate karega.
    // Agar ID di gayi hai to usi document ko update kiya jayega.
    final document = id == null ? _items.doc() : _items.doc(id);

    // Initially existing image ka URL aur path preserve karta hai.
    var imageUrl = currentImageUrl;
    var imagePath = currentImagePath;

    // Nayi uploaded image ka path track karne ke liye variable.
    // Upload start na ho to iski value null rahegi.
    String? uploadedImagePath;

    // Track karta hai ke Firestore write timeout hua tha ya nahi.
    var documentWriteTimedOut = false;

    try {
      // Check karta hai ke user ne nayi image select ki hai ya nahi.
      if (imageBytes != null) {
        // Image ka safe file name banata hai.
        // Agar file name available nahi hai to photo.jpg use karta hai.
        // Split('/') path ka sirf last part rakhta hai.
        // replaceAll() unsupported characters ko underscore se replace karta hai.
        final safeName = (imageName ?? 'photo.jpg')
            .split('/')
            .last
            .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

        // Storage mein image save karne ka unique path banata hai.
        // Ismein product ki ID, current timestamp aur file name shamil hain.
        imagePath =
            'items/${document.id}/${DateTime.now().microsecondsSinceEpoch}_$safeName';

        // Firebase Storage mein image ke reference ko create karta hai.
        final imageRef = _storage.ref(imagePath);

        // Image ke binary data ko Firebase Storage par upload karta hai.
        // Metadata mein image ka content type bhi set karta hai.
        final uploadTask = imageRef.putData(
          imageBytes,
          SettableMetadata(contentType: _contentType(safeName)),
        );

        // Nayi image ka path store karta hai taake failure par cleanup kiya ja sake.
        uploadedImagePath = imagePath;

        try {
          // Upload complete hone ke liye maximum 60 seconds wait karta hai.
          // Agar timeout ho to upload cancel karke error dobara throw karta hai.
          await uploadTask.timeout(const Duration(seconds: 60));
        } on TimeoutException {
          await uploadTask.cancel();
          rethrow;
        }

        // Upload successful hone ke baad image ka download URL hasil karta hai.
        // URL hasil karne ke liye maximum 30 seconds wait karta hai.
        imageUrl = await imageRef.getDownloadURL().timeout(
          const Duration(seconds: 30),
        );
      } else if (externalImageUrl != null &&
          externalImageUrl.trim().isNotEmpty) {
        // Agar uploaded image bytes nahi hain lekin external URL diya gaya hai,
        // to us URL ko directly save karta hai.
        // Is case mein Firebase Storage par image upload nahi hoti.
        imageUrl = externalImageUrl.trim();

        // External URL use hone par Firebase Storage image path empty rakhta hai.
        imagePath = '';
      }

      // Product ki tamam details ko Map ki form mein prepare karta hai.
      // Yeh data Firestore document mein save hoga.
      final data = <String, dynamic>{
        'name': name.trim(), // Name ke extra start/end spaces remove karta hai.
        'description': description
            .trim(), // Description ke extra spaces remove karta hai.
        'category': category,
        'price': price,
        'quantity': quantity,
        'sku': sku.trim(), // SKU ke extra start/end spaces remove karta hai.
        'status': status,
        'imageUrl': imageUrl, // Product image ka URL save karta hai.
        'imagePath': imagePath, // Storage image ka path save karta hai.
        'updatedAt': FieldValue.serverTimestamp(), // Server ka current timestamp save karta hai.
      };

      // Sirf naye product ke liye createdAt field add karta hai.
      // Existing product update hone par original createdAt preserve rehta hai.
      if (id == null) data['createdAt'] = FieldValue.serverTimestamp();

      try {
        // Product ka data Firestore mein save ya update karta hai.
        // merge: true existing document ke doosre fields ko preserve karta hai.
        // Maximum 30 seconds wait karta hai.
        await document
            .set(data, SetOptions(merge: true))
            .timeout(const Duration(seconds: 30));
      } on TimeoutException {
        // Record write timeout hone ka flag true karta hai.
        documentWriteTimedOut = true;

        // Timeout error ko calling code tak forward karta hai.
        rethrow;
      }

      // Purani image tabhi delete karta hai jab Firestore update successful ho.
      // Agar current aur new image paths different hain to purani image remove hoti hai.
      if (currentImagePath.isNotEmpty && currentImagePath != imagePath) {
        await _removePhoto(currentImagePath);
      }
    } catch (_) {
      // Agar nayi image upload hui ho aur Firestore write timeout na hua ho,
      // to failed operation ki nayi uploaded image ko remove karne ki koshish karta hai.
      if (uploadedImagePath != null && !documentWriteTimedOut) {
        await _removePhoto(uploadedImagePath);
      }

      // Original error ko dobara throw karta hai taake controller handle kar sake.
      rethrow;
    }
  }

  // Firestore se product delete karta hai aur uski uploaded image bhi remove karta hai.
  Future<void> deleteProduct(Product? product, String id) async {
    // Sab se pehle Firestore ke 'items' collection se product record delete karta hai.
    await _items.doc(id).delete();

    // Agar product record available hai aur uski image Firebase Storage mein hai,
    // to us image ko bhi delete karne ki koshish karta hai.
    if (product != null && product.imagePath.isNotEmpty) {
      await _removePhoto(product.imagePath);
    }
  }

  // Firebase Storage se image delete karne ka helper method.
  Future<void> _removePhoto(String path) async {
    try {
      // Diye gaye path par stored image ko Firebase Storage se delete karta hai.
      await _storage.ref(path).delete();
    } catch (_) {
      // Agar image delete na ho sake to error ignore karta hai.
      // Is se pehle se saved Firestore record par cleanup failure ka asar nahi hota.
    }
  }

  // File extension ke mutabiq image ka MIME content type return karta hai.
  // Firebase Storage upload ke waqt is type ko metadata mein use kiya jata hai.
  String _contentType(String fileName) {
    // File name ki extension nikal kar lowercase mein convert karta hai.
    switch (fileName.split('.').last.toLowerCase()) {
      // PNG image ke liye content type.
      case 'png':
        return 'image/png';

      // WebP image ke liye content type.
      case 'webp':
        return 'image/webp';

      // GIF image ke liye content type.
      case 'gif':
        return 'image/gif';

      // Baqi tamam extensions ke liye JPEG type return hota hai.
      default:
        return 'image/jpeg';
    }
  }
}
