// lib/screens/seller/seller_receipt_view_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';

class SellerReceiptViewScreen extends StatefulWidget {
  final int saleId;

  const SellerReceiptViewScreen({super.key, required this.saleId});

  @override
  State<SellerReceiptViewScreen> createState() =>
      _SellerReceiptViewScreenState();
}

class _SellerReceiptViewScreenState extends State<SellerReceiptViewScreen> {
  String? _pdfPath;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final headers = await ApiService.getHeaders();
      final response = await http.get(
          Uri.parse('${ApiService.baseUrl}/api/sales/${widget.saleId}/receipt'),
          headers: headers);
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/receipt_${widget.saleId}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _pdfPath = file.path;
          _loading = false;
        });
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.receipt),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? Center(child: SpinKitWaveSpinner(color: Colors.green, size: 50.0))
          : _error != null
              ? Center(child: Text(_error!))
              : SfPdfViewer.file(File(_pdfPath!)),
    );
  }
}
