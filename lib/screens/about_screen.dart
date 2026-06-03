// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../models/about.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  About? _about;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAbout();
  }

  Future<void> _loadAbout() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/api/about');
      setState(() => _about = About.fromJson(res['data']));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedLoadReport),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? Center(
              child: SpinKitWaveSpinner(
                  color: Theme.of(context).colorScheme.primary, size: 50.0))
          : _about == null
              ? Center(
                  child: Text(AppLocalizations.of(context)!.failedLoadReport))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        _about!.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content
                      Text(
                        _about!.content,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Metadata
                      Text(
                        'Last updated: ${_about!.updatedAt}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
