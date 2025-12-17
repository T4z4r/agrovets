// lib/screens/products/product_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../widgets/app_drawer.dart';
import '../../l10n/app_localizations.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final VoidCallback onSave;

  const ProductFormScreen({super.key, this.product, required this.onSave});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _costPriceCtrl;
  late TextEditingController _sellingPriceCtrl;
  late TextEditingController _minimumQuantityCtrl;
  late TextEditingController _barcodeCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _unitCtrl = TextEditingController(text: widget.product?.unit ?? '');
    _categoryCtrl =
        TextEditingController(text: widget.product?.category ?? '--');
    _stockCtrl =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _costPriceCtrl =
        TextEditingController(text: widget.product?.costPrice.toString() ?? '');
    _sellingPriceCtrl = TextEditingController(
        text: widget.product?.sellingPrice.toString() ?? '');
    _minimumQuantityCtrl = TextEditingController(
        text: widget.product?.minimumQuantity.toString() ?? '');
    _barcodeCtrl = TextEditingController(text: widget.product?.barcode ?? '');
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close form
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'name': _nameCtrl.text,
      'unit': _unitCtrl.text,
      'category': _categoryCtrl.text,
      'stock': double.parse(_stockCtrl.text),
      'cost_price': double.parse(_costPriceCtrl.text),
      'selling_price': double.parse(_sellingPriceCtrl.text),
      'minimum_quantity': double.parse(_minimumQuantityCtrl.text),
      'barcode': _barcodeCtrl.text.isEmpty ? null : _barcodeCtrl.text,
    };
    try {
      if (widget.product == null) {
        await ApiService.post('/api/products', data);
        _showSuccessDialog('Product created successfully.');
      } else {
        await ApiService.put('/api/products/${widget.product!.id}', data);
        _showSuccessDialog('Product updated successfully.');
      }
      widget.onSave();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _loading = false);
    }
  }

  Future<void> _scanBarcode() async {
    // Check camera permission
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan barcodes'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Camera permission is permanently denied. Please enable it in settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              AppBar(
                title: Text('Scan Barcode'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final barcode = barcodes.first.rawValue;
                      if (barcode != null) {
                        Navigator.pop(context, barcode);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _barcodeCtrl.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.product == null
            ? AppLocalizations.of(context)!.createProduct
            : AppLocalizations.of(context)!.editProduct),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(activeScreen: 'products'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Icon Header
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  widget.product == null ? Icons.add_box : Icons.edit,
                  size: 40,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.product == null
                            ? AppLocalizations.of(context)!.addNewProduct
                            : AppLocalizations.of(context)!.editProduct,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Product Name Field
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.productName,
                          hintText:
                              AppLocalizations.of(context)!.enterProductName,
                          prefixIcon: const Icon(Icons.inventory_2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Unit Field
                      TextFormField(
                        controller: _unitCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.unit,
                          hintText: AppLocalizations.of(context)!.enterUnit,
                          prefixIcon: const Icon(Icons.straighten),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Unit is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Field
                      TextFormField(
                        controller: _categoryCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.category,
                          hintText: AppLocalizations.of(context)!.enterCategory,
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Category is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Barcode Field
                      TextFormField(
                        controller: _barcodeCtrl,
                        decoration: InputDecoration(
                          labelText: 'Barcode',
                          hintText: 'Barcode',
                          prefixIcon: const Icon(Icons.qr_code),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: _scanBarcode,
                            tooltip: 'Scan Barcode',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stock Field
                      TextFormField(
                        controller: _stockCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.initialStock,
                          hintText:
                              AppLocalizations.of(context)!.enterStockQuantity,
                          prefixIcon: const Icon(Icons.inventory),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Stock quantity is required';
                          }
                          if (double.tryParse(v) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Minimum Quantity Field
                      TextFormField(
                        controller: _minimumQuantityCtrl,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.minimumQuantity,
                          hintText: AppLocalizations.of(context)!
                              .enterMinimumQuantity,
                          prefixIcon: const Icon(Icons.warning),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppLocalizations.of(context)!
                                .minimumQuantityRequired;
                          }
                          if (double.tryParse(v) == null) {
                            return AppLocalizations.of(context)!
                                .enterValidAmount;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Cost Price Field
                      TextFormField(
                        controller: _costPriceCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.costPrice,
                          hintText:
                              AppLocalizations.of(context)!.enterCostPrice,
                          prefixIcon: const Icon(Icons.money_off),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Cost price is required';
                          }
                          if (double.tryParse(v) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Selling Price Field
                      TextFormField(
                        controller: _sellingPriceCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.sellingPrice,
                          hintText:
                              AppLocalizations.of(context)!.enterSellingPrice,
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Selling price is required';
                          }
                          if (double.tryParse(v) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      ElevatedButton(
                        onPressed: _loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: SpinKitWaveSpinner(
                                    color: Colors.white, size: 20.0),
                              )
                            : Text(
                                widget.product == null
                                    ? AppLocalizations.of(context)!
                                        .createProduct
                                    : AppLocalizations.of(context)!
                                        .updateProduct,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
