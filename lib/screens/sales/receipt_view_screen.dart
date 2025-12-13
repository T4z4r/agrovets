// lib/screens/sales/receipt_view_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../services/api_service.dart';

class ReceiptViewScreen extends StatefulWidget {
  final int saleId;

  const ReceiptViewScreen({super.key, required this.saleId});

  @override
  State<ReceiptViewScreen> createState() => _ReceiptViewScreenState();
}

class _ReceiptViewScreenState extends State<ReceiptViewScreen> {
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
      appBar: AppBar(title: const Text('Receipt')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SfPdfViewer.file(File(_pdfPath!)),
    );
  }
}
