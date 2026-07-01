import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../utils/number_formatter.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/product_image.dart';

class PosScreen extends StatefulWidget {
  final bool embedded;

  const PosScreen({super.key, this.embedded = false});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _CartItem {
  final Product product;
  int quantity;
  double price;

  _CartItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  Map<String, dynamic> toSaleItem() {
    return {
      'product_id': product.id,
      'quantity': quantity,
      'price': price,
    };
  }
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, _CartItem> _cart = {};

  List<Product> _products = [];
  bool _loading = true;
  bool _saving = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      final response = await ApiService.get('/api/products');
      final products = (response['data'] as List)
          .map((product) => Product.fromJson(product))
          .toList();
      if (!mounted) return;
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load products. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Product> get _filteredProducts {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return _products;
    return _products.where((product) {
      final name = product.name?.toLowerCase() ?? '';
      final barcode = product.barcode?.toLowerCase() ?? '';
      final category = product.category?.toLowerCase() ?? '';
      return name.contains(normalizedQuery) ||
          barcode.contains(normalizedQuery) ||
          category.contains(normalizedQuery);
    }).toList();
  }

  int get _itemCount {
    return _cart.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get _subtotal {
    return _cart.values.fold(0, (sum, item) => sum + item.total);
  }

  void _addProduct(Product product) {
    final stock = product.stock ?? 0;
    if (stock <= 0) {
      _showMessage('${product.name} is out of stock.', isError: true);
      return;
    }

    final item = _cart[product.id];
    if (item != null && item.quantity >= stock) {
      _showMessage(
        'Only ${NumberFormatter.formatDecimal(stock)} in stock.',
        isError: true,
      );
      return;
    }

    setState(() {
      if (item == null) {
        _cart[product.id] = _CartItem(
          product: product,
          quantity: 1,
          price: product.sellingPrice ?? 0,
        );
      } else {
        item.quantity += 1;
      }
    });
  }

  void _updateQuantity(_CartItem item, int quantity) {
    if (quantity <= 0) {
      setState(() => _cart.remove(item.product.id));
      return;
    }

    final stock = item.product.stock ?? 0;
    if (quantity > stock) {
      _showMessage('Only ${NumberFormatter.formatDecimal(stock)} in stock.',
          isError: true);
      return;
    }

    setState(() => item.quantity = quantity);
  }

  void _clearCart() {
    if (_cart.isEmpty) return;
    setState(_cart.clear);
  }

  Future<void> _scanBarcode() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (!status.isGranted) {
      _showMessage('Camera permission is required to scan barcodes.',
          isError: true);
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return;
    }

    final barcode = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 420,
          child: Column(
            children: [
              AppBar(
                title: const Text('Scan Barcode'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final value = capture.barcodes
                        .where((barcode) => barcode.rawValue != null)
                        .map((barcode) => barcode.rawValue!)
                        .firstOrNull;
                    if (value != null) Navigator.pop(context, value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (barcode == null) return;
    final localMatch = _productByBarcode(barcode);

    if (localMatch != null) {
      _addProduct(localMatch);
      return;
    }

    try {
      final response = await ApiService.get('/api/products/barcode/$barcode');
      if (response['success'] == true && response['data'] != null) {
        final product = Product.fromJson(response['data']);
        setState(() {
          if (!_products.any((item) => item.id == product.id)) {
            _products = [..._products, product];
          }
        });
        _addProduct(product);
      } else {
        _showMessage('No product found for barcode $barcode.', isError: true);
      }
    } catch (_) {
      _showMessage('Could not find product for barcode $barcode.',
          isError: true);
    }
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) {
      _showMessage('Add products before checkout.', isError: true);
      return;
    }

    for (final item in _cart.values) {
      final stock = item.product.stock ?? 0;
      if (item.quantity > stock) {
        _showMessage('${item.product.name} has only $stock in stock.',
            isError: true);
        return;
      }
    }

    setState(() => _saving = true);
    final data = {
      'seller_id': null,
      'sale_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'items': _cart.values.map((item) => item.toSaleItem()).toList(),
    };

    try {
      await ApiService.post('/api/sales', data);
      if (!mounted) return;
      _showMessage('Sale completed successfully.');
      setState(_cart.clear);
      await _loadProducts();
    } catch (_) {
      if (!mounted) return;
      _showMessage('Checkout failed. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Product? _productByBarcode(String barcode) {
    for (final product in _products) {
      if (product.barcode == barcode) return product;
    }
    return null;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? Center(
            child: SpinKitWaveSpinner(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          )
        : _buildContent(context);

    if (widget.embedded) return content;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('POS Mode'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh products',
            onPressed: _loadProducts,
          ),
        ],
      ),
      drawer: const AppDrawer(activeScreen: 'pos'),
      body: content,
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        if (wide) {
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildProductsPane(wide: true),
              ),
              SizedBox(
                width: 360,
                child: _buildCartPane(),
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(child: _buildProductsPane(wide: false)),
            _buildMobileCartSummary(),
          ],
        );
      },
    );
  }

  Widget _buildProductsPane({required bool wide}) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search products or barcode',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _scanBarcode,
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Scan barcode',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(child: Text('No products found'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: wide ? 4 : 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: wide ? 0.68 : 0.72,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductTile(_filteredProducts[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductTile(Product product) {
    final stock = product.stock ?? 0;
    final outOfStock = stock <= 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: outOfStock ? null : () => _addProduct(product),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 180;
            final imageSize = compact ? 56.0 : 76.0;
            final padding = compact ? 8.0 : 10.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ProductImage(
                      imageUrl: product.imageUrl ?? product.photo,
                      width: imageSize,
                      height: imageSize,
                      borderRadius: 8,
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 10),
                  Text(
                    product.name ?? 'Unnamed product',
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormatter.formatCurrency(product.sellingPrice),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outOfStock
                        ? 'Out of stock'
                        : 'Stock ${NumberFormatter.formatDecimal(stock)} ${product.unit ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: outOfStock ? Colors.red : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          },
                ),
      ),
    );
  }

  Widget _buildCartPane() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Current Sale',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _cart.isEmpty ? null : _clearCart,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _cart.isEmpty
                  ? _buildEmptyCart()
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children:
                          _cart.values.map((item) => _buildCartItem(item)).toList(),
                    ),
            ),
            _buildCheckoutPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              'Tap products to add them to the sale.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(_CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.product.name ?? 'Unnamed product',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => _updateQuantity(item, 0),
              ),
            ],
          ),
          Row(
            children: [
              _quantityButton(Icons.remove, () {
                _updateQuantity(item, item.quantity - 1);
              }),
              SizedBox(
                width: 44,
                child: Text(
                  item.quantity.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _quantityButton(Icons.add, () {
                _updateQuantity(item, item.quantity + 1);
              }),
              const Spacer(),
              Text(
                NumberFormatter.formatCurrency(item.total),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton.outlined(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildCheckoutPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          _summaryRow('Items', _itemCount.toString()),
          const SizedBox(height: 8),
          _summaryRow('Total', NumberFormatter.formatCurrency(_subtotal),
              emphasized: true),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _checkout,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: SpinKitWaveSpinner(
                        color: Colors.white,
                        size: 18,
                      ),
                    )
                  : const Icon(Icons.payments),
              label: Text(_saving ? 'Processing...' : 'Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasized = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: emphasized ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasized ? 20 : 14,
            fontWeight: FontWeight.bold,
            color: emphasized ? Theme.of(context).primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCartSummary() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _showMobileCart,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_itemCount items',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        NumberFormatter.formatCurrency(_subtotal),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _cart.isEmpty ? null : _showMobileCart,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMobileCart() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void refreshSheet(VoidCallback action) {
              action();
              setSheetState(() {});
            }

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.78,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Current Sale',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _cart.isEmpty
                              ? null
                              : () => refreshSheet(_cart.clear),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _cart.isEmpty
                        ? _buildEmptyCart()
                        : ListView(
                            padding: const EdgeInsets.all(12),
                            children: _cart.values.map((item) {
                              return _MobileCartItem(
                                item: item,
                                onRemove: () =>
                                    refreshSheet(() => _cart.remove(item.product.id)),
                                onDecrease: () => refreshSheet(
                                  () => _updateQuantity(item, item.quantity - 1),
                                ),
                                onIncrease: () => refreshSheet(
                                  () => _updateQuantity(item, item.quantity + 1),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  _buildCheckoutPanel(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MobileCartItem extends StatelessWidget {
  final _CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _MobileCartItem({
    required this.item,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name ?? 'Unnamed product',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(NumberFormatter.formatCurrency(item.total)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: onDecrease,
          ),
          Text(
            item.quantity.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onIncrease,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
