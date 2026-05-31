// lib/screens/seller/seller_product_form_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/product_image.dart';

class SellerProductFormScreen extends StatefulWidget {
  final Product? product;
  final VoidCallback onSave;

  const SellerProductFormScreen({super.key, this.product, required this.onSave});

  @override
  State<SellerProductFormScreen> createState() => _SellerProductFormScreenState();
}

class _SellerProductFormScreenState extends State<SellerProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _sellingPriceCtrl;
  late TextEditingController _minimumQuantityCtrl;
  late TextEditingController _barcodeCtrl;
  XFile? _pickedImage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _unitCtrl = TextEditingController(text: widget.product?.unit ?? '');
    _categoryCtrl =
        TextEditingController(text: widget.product?.category ?? '--');
    _stockCtrl = TextEditingController(
        text: widget.product?.stock.toString() ?? '');
    _sellingPriceCtrl = TextEditingController(
        text: widget.product?.sellingPrice.toString() ?? '');
    _minimumQuantityCtrl = TextEditingController(
        text: widget.product?.minimumQuantity.toString() ?? '');
    _barcodeCtrl = TextEditingController(text: widget.product?.barcode ?? '');
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (image != null) {
      setState(() => _pickedImage = image);
    }
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
              AppLocalizations.of(context)!.success,
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
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    print('Starting _save for seller product update');
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'name': _nameCtrl.text,
      'unit': _unitCtrl.text,
      'category': _categoryCtrl.text,
      'stock': double.parse(_stockCtrl.text),
      'cost_price': widget.product!.costPrice ?? 0,
      'selling_price': double.parse(_sellingPriceCtrl.text),
      'minimum_quantity': double.parse(_minimumQuantityCtrl.text),
      'barcode': _barcodeCtrl.text.isEmpty ? null : _barcodeCtrl.text,
    };
    print('Seller updating product ${widget.product!.id} with data: $data');
    print('API URL: /api/products/${widget.product!.id}');
    try {
      if (_pickedImage != null) {
        await ApiService.postMultipart(
          '/api/products/update/${widget.product!.id}',
          data,
          filePath: _pickedImage!.path,
        );
      } else {
        await ApiService.post('/api/products/update/${widget.product!.id}', data);
      }
      _showSuccessDialog(AppLocalizations.of(context)!.productUpdated);
      widget.onSave();
    } catch (e) {
      print('Error saving product (seller): $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _scanBarcode() async {
    // Check camera permission
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.cameraPermissionRequired),
            action: const SnackBarAction(
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
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.cameraPermissionPermanentlyDenied),
          action: const SnackBarAction(
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
                title: Text(AppLocalizations.of(context)!.scanBarcode),
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
        title: Text(AppLocalizations.of(context)!.editProduct),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(_pickedImage!.path),
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ProductImage(
                            imageUrl: widget.product?.imageUrl,
                            width: 96,
                            height: 96,
                            borderRadius: 20,
                          ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: Theme.of(context).primaryColor,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.photo_camera,
                              color: Colors.white),
                          tooltip: 'Select product image',
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
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
                        AppLocalizations.of(context)!.editProduct,
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
                            return AppLocalizations.of(context)!
                                .productNameRequired;
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
                            return AppLocalizations.of(context)!.unitRequired;
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
                            return AppLocalizations.of(context)!
                                .categoryRequired;
                          }
                          return null;
                        },
                       ),
                       const SizedBox(height: 16),

                       // Stock Field
                       TextFormField(
                         controller: _stockCtrl,
                         decoration: InputDecoration(
                           labelText: AppLocalizations.of(context)!.stock,
                           hintText: AppLocalizations.of(context)!.enterQuantity,
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
                             return AppLocalizations.of(context)!.stockRequired;
                           }
                           if (double.tryParse(v) == null) {
                             return AppLocalizations.of(context)!
                                 .enterValidAmount;
                           }
                           return null;
                         },
                       ),
                       const SizedBox(height: 16),

                       // Barcode Field
                      TextFormField(
                        controller: _barcodeCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.barcode,
                          hintText: AppLocalizations.of(context)!.barcode,
                          prefixIcon: const Icon(Icons.qr_code),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: _scanBarcode,
                            tooltip: AppLocalizations.of(context)!.scanBarcode,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
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
                            return AppLocalizations.of(context)!
                                .sellingPriceRequired;
                          }
                          if (double.tryParse(v) == null) {
                            return AppLocalizations.of(context)!
                                .enterValidAmount;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      ElevatedButton(
                        onPressed: _loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: SpinKitWaveSpinner(
                                    color: Colors.white, size: 24.0),
                              )
                            : Text(
                                AppLocalizations.of(context)!
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
