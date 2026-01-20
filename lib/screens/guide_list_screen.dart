// lib/screens/guide_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../models/guide.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';

class GuideListScreen extends StatefulWidget {
  const GuideListScreen({super.key});

  @override
  State<GuideListScreen> createState() => _GuideListScreenState();
}

class _GuideListScreenState extends State<GuideListScreen> {
  List<Guide> _guides = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    setState(() => _loading = true);
    try {
      final localeProvider = context.read<LocaleProvider>();
      final guides = await ApiService.getGuides(
          language: localeProvider.locale.languageCode);
      if (mounted) {
        setState(() => _guides = guides);
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load guides: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  List<Guide> get _filteredGuides {
    final auth = context.watch<AuthProvider>();
    final userRole = auth.user?['role'] ?? '';
    return _guides.where((guide) {
      if (guide.targetRole == 'both') return true;
      if (userRole == 'owner' || userRole == 'admin')
        return guide.targetRole == 'owner';
      if (userRole == 'seller') return guide.targetRole == 'seller';
      return false;
    }).toList();
  }

  void _showGuideContent(Guide guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      guide.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Html(data: guide.content),
                ),
              ),
              if (guide.filePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadGuide(guide),
                    icon: const Icon(Icons.download),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadGuide(Guide guide) async {
    try {
      final response = await ApiService.downloadGuide(guide.id);
      final bytes = response.bodyBytes;

      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/${guide.title.replaceAll(' ', '_')}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await OpenFile.open(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guide downloaded and opened')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download guide: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guides'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? Center(
              child: SpinKitWaveSpinner(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
            )
          : _filteredGuides.isEmpty
              ? Center(
                  child: Text(AppLocalizations.of(context)!.noDataAvailable),
                )
              : ListView.builder(
                  itemCount: _filteredGuides.length,
                  itemBuilder: (context, index) {
                    final guide = _filteredGuides[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(guide.title),
                        subtitle: Text('Target: ${guide.targetRole}'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _showGuideContent(guide),
                      ),
                    );
                  },
                ),
    );
  }
}
