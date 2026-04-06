// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_html/flutter_html.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../models/privacy_policy.dart';
import '../widgets/app_drawer.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  PrivacyPolicy? _privacyPolicy;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    setState(() => _loading = true);
    try {
      final privacyPolicy = await ApiService.getPrivacyPolicy();
      setState(() => _privacyPolicy = privacyPolicy);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${AppLocalizations.of(context)!.failedLoadReport}: $e'),
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
        title: Text(AppLocalizations.of(context)!.privacyPolicy),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(activeScreen: 'privacy'),
      body: _loading
          ? Center(
              child: SpinKitWaveSpinner(
                  color: Theme.of(context).colorScheme.primary, size: 50.0))
          : _privacyPolicy == null
              ? Center(
                  child: Text(AppLocalizations.of(context)!.failedLoadReport))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        _privacyPolicy!.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content
                      Html(
                        data: _privacyPolicy!.content,
                        style: {
                          "body": Style(
                            fontSize: FontSize(16),
                            color: Colors.grey[700],
                            lineHeight: const LineHeight(1.5),
                          ),
                          "h1": Style(
                            fontSize: FontSize(22),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            margin: Margins.only(bottom: 16),
                          ),
                          "h2": Style(
                            fontSize: FontSize(20),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            margin: Margins.only(top: 24, bottom: 8),
                          ),
                          "h3": Style(
                            fontSize: FontSize(18),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            margin: Margins.only(top: 16, bottom: 8),
                          ),
                          "p": Style(
                            margin: Margins.only(bottom: 12),
                          ),
                          "ul": Style(
                            margin: Margins.only(left: 16, bottom: 12),
                          ),
                          "li": Style(
                            margin: Margins.only(bottom: 4),
                          ),
                        },
                      ),

                      const SizedBox(height: 24),

                      // Metadata
                      Text(
                        'Last updated: ${_privacyPolicy!.updatedAt}',
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
