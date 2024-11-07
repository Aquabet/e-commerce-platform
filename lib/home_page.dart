import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models/product.dart';
import 'models/category.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const HomePage({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> _products;
  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  void _loadCategories() async {
    final categories = await widget.dbHelper.fetchCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _loadProducts() {
    setState(() {
      _products = widget.dbHelper.fetchProductsWithFilters(
        categoryId: _selectedCategoryId,
        showOnlyFavorites: _showOnlyFavorites,
      );
    });
  }

  void _onCategorySelected(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _loadProducts();
    });
  }

  void _onFavoriteFilterChanged(bool? showOnlyFavorites) {
    setState(() {
      _showOnlyFavorites = showOnlyFavorites ?? false;
      _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductDetailPage(),
                ),
              );
              if (result == true) {
                _loadProducts();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int?>(
                    value: _selectedCategoryId,
                    hint: const Text('Select Category'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ..._categories.map((category) {
                        return DropdownMenuItem<int?>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ],
                    onChanged: _onCategorySelected,
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Text('Only Favorites'),
                    Checkbox(
                      value: _showOnlyFavorites,
                      onChanged: _onFavoriteFilterChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products available'));
                } else {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('\$${product.price.toString()}'),
                        trailing: IconButton(
                          icon: Icon(
                            product.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: product.isFavorite ? Colors.red : null,
                          ),
                          onPressed: () async {
                            product.isFavorite = !product.isFavorite;
                            await widget.dbHelper.updateProduct(product);
                            _loadProducts();
                          },
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: product),
                            ),
                          );
                          if (result == true) {
                            _loadProducts();
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
