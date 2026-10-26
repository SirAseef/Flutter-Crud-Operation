import 'dart:async';
import 'dart:typed_data';

import 'package:get/get.dart';

import '../models/product.dart';
import '../services/product_service.dart';

// ProductController app ke products ka data aur unki operations manage karta hai.
// GetxController ki wajah se yeh GetX ke lifecycle aur reactive state ko use karta hai.
class ProductController extends GetxController {
  // Constructor ke through Firebase ki readiness aur error information receive karta hai.
  ProductController({required this.firebaseReady, this.firebaseError});

  // Batata hai ke Firebase successfully initialize hua hai ya nahi.
  final bool firebaseReady;

  // Firebase initialization ke waqt koi error aaye to uski information yahan store ho sakti hai.
  final String? firebaseError;

  // ProductService ka object create karta hai.
  // Actual Firebase Storage aur Firestore operations service handle karti hai.
  final _service = ProductService();

  // Products ki reactive list hai.
  // Is list mein changes hone par GetX UI ko update kar sakta hai.
  final products = <Product>[].obs;

  // Search field ka text reactive variable mein store hota hai.
  final searchText = ''.obs;

  // Batata hai ke products load ho rahe hain ya nahi.
  // Starting mein loading true hai.
  final isLoading = true.obs;

  // Loading ya Firebase operation ke waqt aane wala error message store karta hai.
  final errorMessage = ''.obs;

  // Firebase connection ki current status show karta hai.
  // Starting mein status Connecting hai.
  final connectionStatus = 'Connecting'.obs;

  // Firestore stream ki subscription ko store karta hai.
  // Iski madad se stream ko baad mein cancel kiya ja sakta hai.
  StreamSubscription<List<Product>>? _subscription;

  // Search ke mutabiq products ki filtered list return karta hai.
  List<Product> get filteredProducts {
    // Search text ke start/end ke extra spaces remove karta hai
    // aur text ko lowercase mein convert karta hai.
    final query = searchText.value.trim().toLowerCase();

    // Agar search field empty hai to tamam products return karta hai.
    if (query.isEmpty) return products;

    // Sirf un products ko select karta hai jinki information search text se match kare.
    return products.where((item) {
      // Product ke name, description, category ya SKU mein search text check karta hai.
      // Kisi bhi field mein match milne par product result mein include ho jata hai.
      return item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);
    }).toList(); // Filtered results ko List mein convert karta hai.
  }

  @override
  void onInit() {
    super.onInit();

    // Controller initialize hone par sab se pehle check karta hai
    // ke Firebase ready hai ya nahi.
    // Agar Firebase initialize nahi hua to Firestore calls start nahi hoti.
    if (!firebaseReady) {
      errorMessage.value = 'Firebase abhi configure nahi hai.';
      connectionStatus.value = 'Setup needed';
      isLoading.value = false;
      return; // Aage ka code execute kiye baghair method se bahar aa jata hai.
    }

    // Firestore se products ki real-time stream listen karta hai.
    // Database mein products add, update ya delete hone par
    // stream updated list provide kar sakti hai.
    _subscription = _service.watchProducts().listen(
      (items) {
        // Stream se milne wale tamam products reactive list mein set karta hai.
        products.assignAll(items);

        // Connection status ko Connected kar deta hai.
        connectionStatus.value = 'Connected';

        // Loading complete hone par loading indicator band karta hai.
        isLoading.value = false;

        // Purana error message clear kar deta hai.
        errorMessage.value = '';
      },

      // Agar Firestore stream mein error aaye to yeh callback execute hota hai.
      onError: (Object error) {
        connectionStatus.value = 'Connection issue';
        isLoading.value = false;

        // Error ki details ko reactive variable mein store karta hai.
        errorMessage.value = error.toString();
      },
    );
  }

  // Naya product save karne ya existing product update karne ka method.
  // true return hone ka matlab operation successful hua.
  // false return hone ka matlab operation fail hua.
  Future<bool> saveItem({
    String?
    id, // Existing product ki ID; new product ke liye null ho sakti hai.
    required String name,
    required String description,
    required String category,
    required double price,
    required int quantity,
    required String sku,
    required String status,

    // Image file ka binary data receive karta hai.
    // Uint8List mobile ya web se selected image bytes represent kar sakta hai.
    Uint8List? imageBytes,

    // Selected image ka file name.
    String? imageName,

    // Agar image kisi external URL par available ho to woh URL.
    String? externalImageUrl,

    // Existing product ki image ka URL.
    // Default empty string hai agar pehle se image URL na ho.
    String currentImageUrl = '',

    // Firebase Storage mein existing image ka path.
    // Purani image ko manage karne mein use ho sakta hai.
    String currentImagePath = '',
  }) async {
    // Firebase ready nahi hai to save operation perform nahi hota.
    if (!firebaseReady) return _showFirebaseNotReady();

    try {
      // ProductService ko product ki tamam details pass karta hai.
      // Image upload aur Firestore mein save/update karne ka actual logic service mein hai.
      await _service.saveProduct(
        id: id,
        name: name,
        description: description,
        category: category,
        price: price,
        quantity: quantity,
        sku: sku,
        status: status,
        imageBytes: imageBytes,
        imageName: imageName,
        externalImageUrl: externalImageUrl,
        currentImageUrl: currentImageUrl,
        currentImagePath: currentImagePath,
      );

      // Operation successful hone par true return karta hai.
      return true;
    } catch (error) {
      // Agar request time limit se zyada waqt le to timeout ka message show karta hai.
      // Warna general save error show karta hai.
      final message = error is TimeoutException
          ? 'Request timed out. Internet ya Firebase Storage/Firestore rules check karein, phir dobara try karein.'
          : 'Save nahi ho saka: $error';

      // User ko snackbar mein save failure ki information deta hai.
      Get.snackbar('Save failed', message);

      // Operation fail hone par false return karta hai.
      return false;
    }
  }

  // Product ko delete karne ka method.
  // Product ki ID parameter ke taur par receive karta hai.
  Future<bool> deleteItem(String id) async {
    // Firebase ready nahi hai to delete operation perform nahi hota.
    if (!firebaseReady) return _showFirebaseNotReady();

    try {
      // Local products list mein us product ka record find karta hai
      // jiski ID delete karne ke liye provide ki gayi hai.
      final item = products.firstWhereOrNull((product) => product.id == id);

      // ProductService ko product record aur ID pass karta hai.
      // Service Firestore record aur associated Storage image delete kar sakti hai.
      await _service.deleteProduct(item, id);

      // Delete successful hone par true return karta hai.
      return true;
    } catch (error) {
      // Delete fail hone par user ko error snackbar mein show karta hai.
      Get.snackbar('Error', 'Delete nahi ho saka: $error');

      // Delete fail hone par false return karta hai.
      return false;
    }
  }

  // Firebase ready na hone par user ko setup ka message show karta hai.
  // false return karke batata hai ke requested operation perform nahi hua.
  bool _showFirebaseNotReady() {
    Get.snackbar(
      'Firebase setup',
      'Pehle README ke Firebase setup steps complete karein.',
    );
    return false;
  }

  @override
  void onClose() {
    // Controller dispose hone par Firestore stream ki listening cancel karta hai.
    // Is se unnecessary listening aur resource usage se bachne mein madad milti hai.
    _subscription?.cancel();

    // Parent GetxController ka cleanup method call karta hai.
    super.onClose();
  }
}
