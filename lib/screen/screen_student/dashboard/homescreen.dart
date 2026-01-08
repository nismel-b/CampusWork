import 'package:flutter/material.dart';
import 'package:campuswork/providers/auth_provider.dart';
import 'package:campuswork/service/store_service.dart';
import 'package:store_buy/service/product_service.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:store_buy/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:store_buy/screen_vendeur/add_product_screen.dart';
import 'package:store_buy/screen_vendeur/edit_product_screen.dart';
import 'package:store_buy/screen_vendeur/dashboard_screen.dart';
import 'package:store_buy/screen_vendeur/commande_screen.dart';
import 'package:store_buy/login/store_create.dart' show LoginStore;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final StoreService _storeService = StoreService();
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _products = [];
  String? _selectedStoreId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStores();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final stores = await _storeService.getStoresByUserId(
        authProvider.currentUser!.userId,
      );
      setState(() {
        _stores = stores;
        if (stores.isNotEmpty) {
          _selectedStoreId = stores.first['storeId'];
          _loadProducts();
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProducts() async {
    if (_selectedStoreId == null) return;
    final products = await _productService.getProductsByStore(_selectedStoreId!);
    setState(() {
      _products = products;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_stores.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mes Magasins'),
          backgroundColor: const Color(0xFF3B82F6),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Vous n\'avez pas encore de magasin',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginStore(),
                    ),
                  ).then((_) => _loadStores());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text('Créer un magasin'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'img/logo-storeself.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'Store Self',
              style: TextStyle(fontFamily: 'Wizzard'),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: () {
              Navigator.pushNamed(context, '/create-store').then((result) {
                if (result != null && result is String) {
                  // Preview store after creation
                  Navigator.pushNamed(
                    context,
                    '/vendor-home',
                    arguments: result,
                  );
                }
                _loadStores();
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'reviews':
                  Navigator.pushNamed(context, '/vendor-reviews');
                  break;
                case 'employees':
                  Navigator.pushNamed(context, '/vendor-employees');
                  break;
                case 'stories':
                  Navigator.pushNamed(context, '/vendor-stories');
                  break;
                case 'history':
                  Navigator.pushNamed(context, '/vendor-history');
                  break;
                case 'reservations':
                  Navigator.pushNamed(context, '/vendor-reservations');
                  break;
                case 'deliveries':
                  Navigator.pushNamed(context, '/vendor-deliveries');
                  break;
                case 'messages':
                  Navigator.pushNamed(context, '/vendor-messages');
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/vendor-settings');
                  break;
                case 'support':
                  Navigator.pushNamed(context, '/vendor-support');
                  break;
                case 'inventory':
                  Navigator.pushNamed(context, '/vendor-inventory');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'reviews', child: Text('Avis clients')),
              const PopupMenuItem(value: 'employees', child: Text('Employés')),
              const PopupMenuItem(value: 'stories', child: Text('Stories')),
              const PopupMenuItem(value: 'history', child: Text('Historique')),
              const PopupMenuItem(value: 'reservations', child: Text('Réservations')),
              const PopupMenuItem(value: 'deliveries', child: Text('Livraisons')),
              const PopupMenuItem(value: 'messages', child: Text('Messages')),
              const PopupMenuItem(value: 'inventory', child: Text('Gestion des stocks')),
              const PopupMenuItem(value: 'settings', child: Text('Personnalisation')),
              const PopupMenuItem(value: 'support', child: Text('Support client')),
            ],
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Info du magasin'),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryDark,
                        AppColors.accent,
                      ],
                    ),
                  ),
                  child: _selectedStoreId != null && _stores.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.store, size: 60, color: Colors.white),
                            const SizedBox(height: 10),
                            Text(
                              _stores.firstWhere(
                                (s) => s['storeId'] == _selectedStoreId,
                              )['storename'] ?? 'Magasin',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'ChettaVissto',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Produits'),
                    Tab(text: 'Dashboard'),
                    Tab(text: 'Commandes'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Products tab
            _buildProductsTab(),
            // Dashboard tab
            DashboardScreen(storeId: _selectedStoreId),
            // Orders tab
            CommandeScreen(storeId: _selectedStoreId),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedStoreId != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductScreen(
                      storeId: _selectedStoreId!,
                    ),
                  ),
                ).then((_) => _loadProducts());
              }
            : null,
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductsTab() {
    if (_selectedStoreId == null) {
      return const Center(child: Text('Sélectionnez un magasin'));
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: _products.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Aucun produit',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = Product.fromMap(_products[index]);
                return _buildProductCard(product);
              },
            ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                color: Colors.grey[200],
              ),
              child: product.photo.isNotEmpty
                  ? Image.network(
                      product.photo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, size: 50);
                      },
                    )
                  : const Icon(Icons.image, size: 50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price} FCFA',
                  style: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Stock: ${product.quantity}',
                  style: TextStyle(
                    color: product.quantity > 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProductScreen(product: product),
                          ),
                        );
                        if (result == true) {
                          _loadProducts();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Supprimer le produit'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir supprimer ce produit?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && product.productId != null) {
                          final productService = ProductService();
                          await productService.deleteProduct(product.productId!);
                          _loadProducts();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
