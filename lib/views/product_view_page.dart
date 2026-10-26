import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../models/product.dart';

class ProductViewPage extends StatelessWidget {
  const ProductViewPage({super.key, required this.product});
  final Product product;

  Future<void> _delete() async {
    // Ask before permanently deleting a product.
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: const Text('Delete product?'),
        content: Text('“${product.name}” will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // Return only after the controller confirms that deletion succeeded.
    final deleted = await Get.find<ProductController>().deleteItem(product.id);
    if (deleted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final createdAt = product.createdAt;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: [
          IconButton(
            tooltip: 'Edit product',
            onPressed: () => Get.toNamed('/form', arguments: product),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete product',
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 900
                ? 840.0
                : constraints.maxWidth;
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: SizedBox(
                        height: constraints.maxWidth < 420 ? 230 : 320,
                        child: ColoredBox(
                          color: colors.surfaceContainerHighest,
                          child: product.imageUrl.isEmpty
                              ? Icon(
                                  Icons.image_outlined,
                                  size: 64,
                                  color: colors.onSurfaceVariant,
                                )
                              : Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stack) => Icon(
                                    Icons.broken_image_outlined,
                                    size: 64,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Badge(
                          text: product.category,
                          color: colors.secondaryContainer,
                        ),
                        _Badge(
                          text: product.status,
                          color: product.status == 'Available'
                              ? const Color(0xFFDDF5E7)
                              : colors.tertiaryContainer,
                        ),
                        if (product.sku.isNotEmpty)
                          _Badge(
                            text: 'SKU ${product.sku}',
                            color: colors.surfaceContainerHighest,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description.isEmpty
                          ? 'No description provided.'
                          : product.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, summaryConstraints) {
                        // Use a row on wide screens and a column on narrow ones.
                        final wide = summaryConstraints.maxWidth > 480;
                        final cards = [
                          _InfoCard(
                            label: 'Price',
                            value: product.price.toStringAsFixed(2),
                            icon: Icons.payments_outlined,
                          ),
                          _InfoCard(
                            label: 'Stock',
                            value: '${product.quantity} units',
                            icon: Icons.inventory_2_outlined,
                          ),
                          _InfoCard(
                            label: 'Availability',
                            value: product.status,
                            icon: Icons.sell_outlined,
                          ),
                        ];
                        if (wide) {
                          return Row(
                            children: [
                              for (var i = 0; i < cards.length; i++)
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: i == cards.length - 1 ? 0 : 10,
                                    ),
                                    child: cards[i],
                                  ),
                                ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            for (final card in cards)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: card,
                              ),
                          ],
                        );
                      },
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Added ${createdAt.toLocal().toString().split('.').first}',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: () => Get.toNamed('/form', arguments: product),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit product'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: Theme.of(context).textTheme.labelMedium),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
