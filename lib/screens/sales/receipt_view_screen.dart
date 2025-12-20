// lib/screens/sales/receipt_view_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../widgets/app_drawer.dart';

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
        _error = AppLocalizations.of(context)!.operationFailed;
        _loading = false;
      });
    }
  }

  Future<void> _downloadAndOpenPdf() async {
    if (_pdfPath == null) return;

    try {
      // Save to documents directory
      final docsDir = await getApplicationDocumentsDirectory();
      final fileName = 'receipt_${widget.saleId}.pdf';
      final savedFile = File('${docsDir.path}/$fileName');
      await File(_pdfPath!).copy(savedFile.path);

      // Open the file
      final result = await OpenFile.open(savedFile.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        actions: [
          if (!_loading && _pdfPath != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadAndOpenPdf,
              tooltip: 'Download',
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? Center(child: SpinKitWaveSpinner(color: Colors.green, size: 50.0))
          : _error != null
              ? Center(child: Text(_error!))
              : SfPdfViewer.file(File(_pdfPath!)),
    );
  }
}
