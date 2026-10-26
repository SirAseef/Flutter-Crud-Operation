import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/product_controller.dart';
import '../models/product.dart';

const _categories = [
  'Other',
  'Electronics',
  'Fashion',
  'Home',
  'Books',
  'Food',
];
const _statuses = ['Available', 'Out of stock', 'Coming soon'];

// The same page supports both creating a product and editing one.
class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});
  final Product? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _sku;
  late final TextEditingController _price;
  late final TextEditingController _quantity;
  late final TextEditingController _imageUrl;
  late String _category;
  late String _status;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _saving = false;

  bool get _editing => widget.product != null;

  String? get _previewImageUrl {
    // Prefer a selected local image, then a valid link, then the saved image.
    if (_imageBytes != null) return null;
    final url = _imageUrl.text.trim();
    final uri = Uri.tryParse(url);
    if (uri != null &&
        uri.hasAuthority &&
        (uri.scheme == 'https' || uri.scheme == 'http')) {
      return url;
    }
    return widget.product?.imageUrl;
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill the controls when the form is opened for an existing product.
    final item = widget.product;
    _name = TextEditingController(text: item?.name ?? '');
    _description = TextEditingController(text: item?.description ?? '');
    _sku = TextEditingController(text: item?.sku ?? '');
    _price = TextEditingController(
      text: item == null ? '' : item.price.toString(),
    );
    _quantity = TextEditingController(
      text: item == null ? '1' : item.quantity.toString(),
    );
    _imageUrl = TextEditingController(
      text: item != null && item.imagePath.isEmpty ? item.imageUrl : '',
    );
    _category = item != null && _categories.contains(item.category)
        ? item.category
        : 'Other';
    _status = item != null && _statuses.contains(item.status)
        ? item.status
        : 'Available';
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _sku.dispose();
    _price.dispose();
    _quantity.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      // Compress the chosen photo before reading it into memory for upload.
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1400,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
        _imageUrl.clear();
      });
    } catch (error) {
      Get.snackbar('Photo unavailable', 'Photo could not be selected: $error');
    }
  }

  Future<void> _save() async {
    // Validate before parsing numbers or starting any network operations.
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final item = widget.product;
    final saved = await Get.find<ProductController>().saveItem(
      id: item?.id,
      name: _name.text,
      description: _description.text,
      category: _category,
      price: double.parse(_price.text.trim()),
      quantity: int.parse(_quantity.text.trim()),
      sku: _sku.text,
      status: _status,
      imageBytes: _imageBytes,
      imageName: _imageName,
      externalImageUrl: _imageUrl.text.trim().isEmpty
          ? null
          : _imageUrl.text.trim(),
      currentImageUrl: item?.imageUrl ?? '',
      currentImagePath: item?.imagePath ?? '',
    );
    if (!mounted) return;
    // Restore the button after either a successful save or a handled failure.
    setState(() => _saving = false);
    if (saved) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit product' : 'Add product')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Limit the form width on large displays and split fields if wide.
            final contentWidth = constraints.maxWidth > 760
                ? 720.0
                : constraints.maxWidth;
            // Account for page and card padding before sizing form fields.
            final fieldAreaWidth = contentWidth - 76;
            final fieldWidth = fieldAreaWidth > 576
                ? (fieldAreaWidth - 16) / 2
                : fieldAreaWidth;
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      Text(
                        _editing ? 'Update your product' : 'Add a new product',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Add the details below to keep your catalogue organized.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 22),
                      _SectionCard(
                        title: 'Product photo',
                        subtitle: 'Choose a photo from your device',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PhotoPreview(
                              bytes: _imageBytes,
                              imageUrl: _previewImageUrl,
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: _saving ? null : _pickPhoto,
                              icon: const Icon(Icons.add_a_photo_outlined),
                              label: Text(
                                _imageBytes == null
                                    ? 'Choose photo'
                                    : 'Change photo',
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _imageUrl,
                              keyboardType: TextInputType.url,
                              decoration: const InputDecoration(
                                labelText: 'Or paste an image link',
                                hintText: 'https://example.com/photo.jpg',
                                prefixIcon: Icon(Icons.link),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) return null;
                                // Only web links are accepted, not local paths.
                                final uri = Uri.tryParse(text);
                                if (uri == null ||
                                    !uri.hasAuthority ||
                                    (uri.scheme != 'https' &&
                                        uri.scheme != 'http')) {
                                  return 'Enter a valid http or https image link';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                // Selecting a link replaces any picked photo.
                                if (_imageBytes != null) {
                                  setState(() {
                                    _imageBytes = null;
                                    _imageName = null;
                                  });
                                } else {
                                  setState(() {});
                                }
                              },
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Use a direct, publicly accessible image link. HTTPS is recommended.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Basic information',
                        subtitle: 'Name and product description',
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _name,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Product name *',
                                prefixIcon: Icon(Icons.inventory_2_outlined),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Product name is required'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _description,
                              textCapitalization: TextCapitalization.sentences,
                              minLines: 3,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                alignLabelWithHint: true,
                                prefixIcon: Icon(Icons.notes_rounded),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Pricing & inventory',
                        subtitle: 'Category, price, SKU and stock quantity',
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 14,
                          children: [
                            SizedBox(
                              width: fieldWidth,
                              child: DropdownButtonFormField<String>(
                                initialValue: _category,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  prefixIcon: Icon(Icons.category_outlined),
                                ),
                                items: _categories
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _saving
                                    ? null
                                    : (value) => setState(
                                        () => _category = value ?? 'Other',
                                      ),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: _sku,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: const InputDecoration(
                                  labelText: 'SKU / code',
                                  prefixIcon: Icon(Icons.qr_code_2_rounded),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: _price,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  prefixIcon: Icon(Icons.attach_money_rounded),
                                ),
                                validator: (value) {
                                  // Prices can be zero but must be valid numbers.
                                  final number = double.tryParse(
                                    value?.trim() ?? '',
                                  );
                                  return number == null || number < 0
                                      ? 'Enter a valid price'
                                      : null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: _quantity,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Stock quantity',
                                  prefixIcon: Icon(Icons.numbers_rounded),
                                ),
                                validator: (value) {
                                  // Stock must be a non-negative whole number.
                                  final number = int.tryParse(
                                    value?.trim() ?? '',
                                  );
                                  return number == null || number < 0
                                      ? 'Enter a valid quantity'
                                      : null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: DropdownButtonFormField<String>(
                                initialValue: _status,
                                decoration: const InputDecoration(
                                  labelText: 'Availability',
                                  prefixIcon: Icon(Icons.sell_outlined),
                                ),
                                items: _statuses
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _saving
                                    ? null
                                    : (value) => setState(
                                        () => _status = value ?? 'Available',
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: Text(
                          _saving
                              ? 'Saving product...'
                              : _editing
                              ? 'Save changes'
                              : 'Add product',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({this.bytes, this.imageUrl});
  final Uint8List? bytes;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    // Preview selected bytes immediately, otherwise show the saved/link image.
    final background = Theme.of(context).colorScheme.surfaceContainerHighest;
    final hasPhoto = bytes != null || (imageUrl?.isNotEmpty ?? false);
    return Container(
      width: double.infinity,
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: !hasPhoto
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 42),
                SizedBox(height: 8),
                Text('No photo selected'),
              ],
            )
          : bytes != null
            ? Image.memory(bytes!, fit: BoxFit.contain)
          : Image.network(
              imageUrl!,
                fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => const Center(
                child: Icon(Icons.broken_image_outlined, size: 42),
              ),
            ),
    );
  }
}
