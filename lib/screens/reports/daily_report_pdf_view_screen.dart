// lib/screens/reports/daily_report_pdf_view_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../widgets/app_drawer.dart';

class DailyReportPdfViewScreen extends StatefulWidget {
  final String date;

  const DailyReportPdfViewScreen({super.key, required this.date});

  @override
  State<DailyReportPdfViewScreen> createState() =>
      _DailyReportPdfViewScreenState();
}

class _DailyReportPdfViewScreenState extends State<DailyReportPdfViewScreen> {
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
          Uri.parse(
              '${ApiService.baseUrl}/api/reports/daily/${widget.date}/pdf'),
          headers: headers);
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/daily_report_${widget.date}.pdf');
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
      final fileName = 'daily_report_${widget.date}.pdf';
      final savedFile = File('${docsDir.path}/$fileName');
      await File(_pdfPath!).copy(savedFile.path);

      // Open the file
      final result = await OpenFile.open(savedFile.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.operationFailed),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('File downloaded successfully'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.operationFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${AppLocalizations.of(context)!.dailyReport} - ${DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.date))}'),
        backgroundColor: Theme.of(context).primaryColor,
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
      drawer: const AppDrawer(activeScreen: 'reports'),
      body: _loading
          ? Center(child: SpinKitWaveSpinner(color: Theme.of(context).primaryColor, size: 50.0))
          : _error != null
              ? Center(child: Text(_error!))
              : SfPdfViewer.file(File(_pdfPath!)),
    );
  }
}
