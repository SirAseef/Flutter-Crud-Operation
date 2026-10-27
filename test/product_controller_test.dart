import 'package:easy_flutter_crud/controllers/product_controller.dart';
import 'package:easy_flutter_crud/models/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Product _product(String id, String name, {String category = 'Other', String sku = ''}) {
  return Product(
    id: id,
    name: name,
    description: '$name description',
    category: category,
    price: 10,
    quantity: 1,
    sku: sku,
    status: 'Available',
    imageUrl: '',
    imagePath: '',
    createdAt: null,
  );
}

void main() {
  group('ProductController search', () {
    late ProductController controller;

    setUp(() {
      Get.testMode = true;
      // Firebase is not touched: the service resolves Firestore lazily and
      // onInit returns early when firebaseReady is false.
      controller = ProductController(firebaseReady: false);
      controller.products.assignAll([
        _product('1', 'Wireless Mouse', category: 'Electronics', sku: 'WM-01'),
        _product('2', 'Cotton Shirt', category: 'Fashion', sku: 'CS-22'),
        _product('3', 'Desk Lamp', category: 'Home', sku: 'DL-07'),
      ]);
    });

    test('returns every product when the query is empty', () {
      expect(controller.filteredProducts, hasLength(3));
    });

    test('matches name case-insensitively and ignores surrounding spaces', () {
      controller.searchText.value = '  MOUSE ';
      expect(controller.filteredProducts.map((p) => p.id), ['1']);
    });

    test('matches category and SKU', () {
      controller.searchText.value = 'fashion';
      expect(controller.filteredProducts.map((p) => p.id), ['2']);

      controller.searchText.value = 'dl-07';
      expect(controller.filteredProducts.map((p) => p.id), ['3']);
    });

    test('returns an empty list when nothing matches', () {
      controller.searchText.value = 'keyboard';
      expect(controller.filteredProducts, isEmpty);
    });
  });

  test('reports setup state when Firebase is not configured', () {
    Get.testMode = true;
    final controller = Get.put(ProductController(firebaseReady: false));
    expect(controller.connectionStatus.value, 'Setup needed');
    expect(controller.isLoading.value, isFalse);
    expect(controller.errorMessage.value, isNotEmpty);
    Get.reset();
  });
}
