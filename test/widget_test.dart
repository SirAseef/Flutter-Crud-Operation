import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:easy_flutter_crud/controllers/app_controller.dart';
import 'package:easy_flutter_crud/controllers/product_controller.dart';
import 'package:easy_flutter_crud/main.dart';
import 'package:easy_flutter_crud/models/product.dart';
import 'package:easy_flutter_crud/views/home_page.dart';
import 'package:easy_flutter_crud/views/product_form_page.dart';
import 'package:easy_flutter_crud/views/product_view_page.dart';

void main() {
  // The app should still show its dashboard when Firebase is not configured.
  testWidgets('splash opens the dashboard without Firebase configuration', (
    tester,
  ) async {
    Get.testMode = true;
    Get.put(AppController());
    Get.put(ProductController(firebaseReady: false));

    await tester.pumpWidget(const EasyCrudApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Products'), findsOneWidget);
    expect(find.textContaining('Firebase setup required'), findsOneWidget);
    Get.reset();
  });

  // Verify the form accepts a web image link as an upload alternative.
  testWidgets('product form accepts a pasted image link', (tester) async {
    Get.testMode = true;
    Get.put(ProductController(firebaseReady: false));

    await tester.pumpWidget(const GetMaterialApp(home: ProductFormPage()));
    final imageUrlField = find.widgetWithText(
      TextFormField,
      'Or paste an image link',
    );
    const imageUrl = 'https://example.com/photo.jpg';
    await tester.enterText(imageUrlField, imageUrl);

    expect(
      tester.widget<TextFormField>(imageUrlField).controller!.text,
      imageUrl,
    );
    Get.reset();
  });

  testWidgets('splash and dashboard fit on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Get.testMode = true;
    Get.put(AppController());
    Get.put(ProductController(firebaseReady: false));

    await tester.pumpWidget(const EasyCrudApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Products'), findsOneWidget);
    final layoutError = tester.takeException();
    expect(layoutError, isNull, reason: '$layoutError');
    Get.reset();
  });

  testWidgets('product detail image fits completely inside its view', (
    tester,
  ) async {
    const product = Product(
      id: 'image-test',
      name: 'Test product',
      description: '',
      category: 'Other',
      price: 1,
      quantity: 1,
      sku: '',
      status: 'Available',
      imageUrl: 'https://example.com/photo.jpg',
      imagePath: '',
      createdAt: null,
    );
    Get.testMode = true;
    Get.put(ProductController(firebaseReady: false));
    await tester.pumpWidget(
      const GetMaterialApp(home: ProductViewPage(product: product)),
    );
    final containedImages = find.byWidgetPredicate(
      (widget) => widget is Image && widget.fit == BoxFit.contain,
    );
    expect(containedImages, findsOneWidget);
    Get.reset();
  });

  testWidgets(
    'main screens render without overflow on phone, tablet, desktop',
    (tester) async {
      const product = Product(
        id: 'responsive-test',
        name: 'Responsive sample',
        description: 'Sample description',
        category: 'Other',
        price: 12,
        quantity: 3,
        sku: 'SAMPLE',
        status: 'Available',
        imageUrl: '',
        imagePath: '',
        createdAt: null,
      );
      const screenSizes = [Size(320, 720), Size(768, 1024), Size(1440, 900)];

      for (final size in screenSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        Get.reset();
        Get.testMode = true;
        Get.put(AppController());
        Get.put(ProductController(firebaseReady: false));

        await tester.pumpWidget(const GetMaterialApp(home: HomePage()));
        expect(find.text('Products'), findsOneWidget);
        expect(
          tester.widget<FloatingActionButton>(
            find.byType(FloatingActionButton),
          ).isExtended,
          size.width >= 430,
        );
        expect(tester.takeException(), isNull, reason: 'Dashboard at $size');

        await tester.pumpWidget(const GetMaterialApp(home: ProductFormPage()));
        expect(find.text('Add a new product'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Form at $size');

        await tester.pumpWidget(
          const GetMaterialApp(home: ProductViewPage(product: product)),
        );
        expect(find.text('Product details'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Details at $size');
      }

      Get.reset();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );
}
