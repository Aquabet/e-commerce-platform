import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models/product.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const HomePage({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  int _page = 0;
  final int _pageSize = 10;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final newProducts = await widget.dbHelper.fetchProducts(
      query: _searchQuery,
      page: _page,
      pageSize: _pageSize,
    );

    setState(() {
      _isLoading = false;
      _hasMore = newProducts.length == _pageSize; // 如果返回的数据少于 pageSize，说明没有更多数据了
      _products.addAll(newProducts);
      _page++;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading) {
      _loadProducts(); // 加载下一页数据
    }
  }

  void _onSearchChanged() {
    setState(() {
      _page = 0;
      _products.clear(); // 清空当前列表以显示新的搜索结果
      _searchQuery = _searchController.text;
      _hasMore = true;
      _loadProducts();
    });
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _page = 0;
      _products.clear();
      _hasMore = true;
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
                _refreshProducts(); // 刷新产品列表
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Products',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => _onSearchChanged(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProducts,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _products.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _products.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final product = _products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('\$${product.price.toString()}'),
                      trailing: IconButton(
                        icon: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isFavorite ? Colors.red : null,
                        ),
                        onPressed: () async {
                          product.isFavorite = !product.isFavorite;
                          await widget.dbHelper.updateProduct(product);
                          _refreshProducts();
                        },
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              product: product,
                            ),
                          ),
                        );
                        if (result == true) {
                          _refreshProducts(); // 刷新产品列表
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
