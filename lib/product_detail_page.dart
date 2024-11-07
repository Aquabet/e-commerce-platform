import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models/product.dart';
import 'models/review.dart';
import 'models/category.dart';

class ProductDetailPage extends StatefulWidget {
  final Product? product;

  const ProductDetailPage({super.key, this.product});

  @override
  ProductDetailPageState createState() => ProductDetailPageState();
}

class ProductDetailPageState extends State<ProductDetailPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _reviewController = TextEditingController();
  final _categoryController = TextEditingController();
  late Future<List<Review>> _reviews;
  late bool _isNewProduct;
  late Product _product;
  List<Category> _categories = [];
  int? _selectedCategoryId;
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _isNewProduct = widget.product == null;
    _product = widget.product ??
        Product(
          name: '',
          price: 0.0,
          categoryId: 1,
          isFavorite: false,
        );
    _nameController.text = _product.name;
    _priceController.text = _product.price.toString();
    _selectedCategoryId = _product.categoryId;

    _loadCategories();
    if (!_isNewProduct) _loadReviews();
  }

  void _loadCategories() async {
    final dbHelper = DatabaseHelper.instance;
    final categories = await dbHelper.fetchCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _loadReviews() {
    final dbHelper = DatabaseHelper.instance;
    setState(() {
      _reviews = dbHelper.fetchReviewsForProduct(_product.id!);
    });
  }

  Future<void> _saveProduct() async {
    final dbHelper = DatabaseHelper.instance;

    if (_categoryController.text.isNotEmpty) {
      _selectedCategoryId =
          await dbHelper.insertOrFindCategory(_categoryController.text);
    }

    _product = Product(
      id: _isNewProduct ? null : _product.id,
      name: _nameController.text,
      price: double.tryParse(_priceController.text) ?? _product.price,
      categoryId: _selectedCategoryId!,
      isFavorite: _product.isFavorite,
    );

    if (_isNewProduct) {
      await dbHelper.insertProduct(_product);
    } else {
      await dbHelper.updateProduct(_product);
    }

    await dbHelper.deleteEmptyCategories();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isNewProduct
              ? 'Product added successfully'
              : 'Product updated successfully'),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _addReview() async {
    final dbHelper = DatabaseHelper.instance;
    final newReview = Review(
      productId: _product.id!,
      reviewText: _reviewController.text,
      rating: _selectedRating,
    );
    await dbHelper.insertReview(newReview);
    _reviewController.clear();
    _selectedRating = 5;
    _loadReviews();
  }

  Future<void> _updateReview(Review review) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.updateReview(review);
    _loadReviews();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review updated successfully')),
      );
    }
  }

  Future<void> _deleteProduct() async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteProduct(_product.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteReview(reviewId);
    _loadReviews();
    if (mounted){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review deleted successfully')),
    );
    }
  }

  void _showEditReviewDialog(Review review) {
    final reviewController = TextEditingController(text: review.reviewText);
    final ratingController =
        TextEditingController(text: review.rating.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(labelText: 'Review Text'),
              ),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(labelText: 'Rating (1-5)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedReview = Review(
                  id: review.id,
                  productId: review.productId,
                  reviewText: reviewController.text,
                  rating: int.tryParse(ratingController.text) ?? review.rating,
                );
                _updateReview(updatedReview);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewProduct ? 'New Product' : _product.name),
        actions: [
          if (!_isNewProduct)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProduct,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: _selectedCategoryId,
              items: _categories
                  .map((category) => DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                  _categoryController.clear();
                });
              },
              hint: const Text('Select Category'),
            ),
            TextField(
              controller: _categoryController,
              decoration:
                  const InputDecoration(labelText: 'Or Add New Category'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProduct,
              child: Text(_isNewProduct ? 'Add Product' : 'Update Product'),
            ),
            if (!_isNewProduct) ...[
              const SizedBox(height: 32),
              const Text(
                'Reviews',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  labelText: 'Add Review',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Rating:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _selectedRating,
                    items: [1, 2, 3, 4, 5]
                        .map((value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRating = value!;
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _addReview,
                child: const Text('Add Review'),
              ),
              Expanded(
                child: FutureBuilder<List<Review>>(
                  future: _reviews,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No reviews available'));
                    } else {
                      final reviews = snapshot.data!;
                      return ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return ListTile(
                            title: Text(review.reviewText),
                            subtitle: Text('Rating: ${review.rating}/5'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showEditReviewDialog(review),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteReview(review.id!),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
