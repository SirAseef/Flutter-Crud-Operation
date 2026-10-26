import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // These shared controllers are registered when the app starts.
    final products = Get.find<ProductController>();
    final app = Get.find<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Easy CRUD',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(
            () => IconButton(
              tooltip: app.isDarkMode.value ? 'Light mode' : 'Dark mode',
              onPressed: app.toggleTheme,
              icon: Icon(
                app.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: MediaQuery.sizeOf(context).width < 430
          ? FloatingActionButton(
              tooltip: 'Add product',
              onPressed: () => Get.toNamed('/form'),
              child: const Icon(Icons.add),
            )
          : FloatingActionButton.extended(
              onPressed: () => Get.toNamed('/form'),
              icon: const Icon(Icons.add),
              label: const Text('Add product'),
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              _DashboardCard(controller: products),
              const SizedBox(height: 20),
              TextField(
                // Changing the observable query refreshes the visible results.
                onChanged: (value) => products.searchText.value = value,
                decoration: InputDecoration(
                  hintText: 'Search products',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(
                    () => products.searchText.value.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            onPressed: () => products.searchText.value = '',
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Products',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Obx(() => Text('${products.filteredProducts.length} items')),
                ],
              ),
              const SizedBox(height: 12),
              _ProductResults(controller: products),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.controller});
  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.primary, colors.tertiary]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage your products',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => Text(
                      '${controller.products.length}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'total products',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              Obx(
                () => Chip(
                  avatar: Icon(
                    controller.connectionStatus.value == 'Connected'
                        ? Icons.cloud_done
                        : Icons.cloud_sync,
                    size: 18,
                  ),
                  label: Text(controller.connectionStatus.value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductResults extends StatelessWidget {
  const _ProductResults({required this.controller});
  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.firebaseReady) {
      return const _InfoMessage(
        icon: Icons.cloud_off_outlined,
        message: 'Firebase setup required. Check README for setup steps.',
      );
    }

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (controller.errorMessage.value.isNotEmpty) {
        return const _InfoMessage(
          icon: Icons.cloud_off_outlined,
          message: 'Could not connect to Firestore. Check your internet and database rules.',
        );
      }

      final products = controller.filteredProducts;
      if (products.isEmpty) {
        return _InfoMessage(
          icon: Icons.inventory_2_outlined,
          message: controller.searchText.value.isEmpty
              ? 'No products yet. Add your first product.'
              : 'No matching products found.',
        );
      }
      return _ProductGrid(products: products);
    });
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final columns = size.maxWidth >= 680
          ? 3
          : size.maxWidth >= 430
          ? 2
          : 1;
      // Choose a card count that fits the current screen width.
      const gap = 12.0;
      final width = (size.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final product in products)
            SizedBox(
              width: width,
              child: _ProductCard(product: product),
            ),
        ],
      );
    },
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Tapping a card opens the matching product detail route.
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed('/view', arguments: product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 145,
              width: double.infinity,
              child: ColoredBox(
                color: colors.surfaceContainerHighest,
                child: product.imageUrl.isEmpty
                    ? Icon(
                        Icons.image_outlined,
                        size: 42,
                        color: colors.onSurfaceVariant,
                      )
                    : Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        cacheWidth: 600,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.broken_image_outlined),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.price.toStringAsFixed(2),
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.category}  •  ${product.quantity} in stock',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  const _InfoMessage({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      children: [
        Icon(icon, size: 38),
        const SizedBox(height: 10),
        Text(message, textAlign: TextAlign.center),
      ],
    ),
  );
}
