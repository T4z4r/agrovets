// lib/screens/sellers/seller_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../l10n/app_localizations.dart';

class SellerFormScreen extends StatefulWidget {
  final User? seller;
  final VoidCallback onSave;

  const SellerFormScreen({super.key, this.seller, required this.onSave});

  @override
  State<SellerFormScreen> createState() => _SellerFormScreenState();
}

class _SellerFormScreenState extends State<SellerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _confirmPasswordCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.seller?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.seller?.email ?? '');
    _passwordCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = <String, dynamic>{
      'name': _nameCtrl.text,
      'email': _emailCtrl.text,
    };

    if (widget.seller == null) {
      // Create: password required
      data['password'] = _passwordCtrl.text;
      data['password_confirmation'] = _confirmPasswordCtrl.text;
    } else {
      // Update: password optional
      if (_passwordCtrl.text.isNotEmpty) {
        data['password'] = _passwordCtrl.text;
        data['password_confirmation'] = _confirmPasswordCtrl.text;
      }
    }

    try {
      if (widget.seller == null) {
        await ApiService.createSeller(data);
        _showSuccessDialog(AppLocalizations.of(context)!.sellerCreated);
      } else {
        await ApiService.updateSeller(widget.seller!.id, data);
        _showSuccessDialog(AppLocalizations.of(context)!.sellerUpdated);
      }
      widget.onSave();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${AppLocalizations.of(context)!.failedSaveSeller}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.retry,
              textColor: Colors.white,
              onPressed: _save,
            ),
          ),
        );
      }
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwnerOrAdmin = authProvider.isOwner || authProvider.isAdmin;

    if (!isOwnerOrAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.accessDenied),
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(AppLocalizations.of(context)!.noPermission),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.seller == null
            ? AppLocalizations.of(context)!.createSeller
            : AppLocalizations.of(context)!.editSeller),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(activeScreen: 'sellers'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seller Icon Header
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  widget.seller == null ? Icons.person_add : Icons.edit,
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
                        widget.seller == null
                            ? AppLocalizations.of(context)!.addNewSeller
                            : AppLocalizations.of(context)!.editSeller,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Seller Name Field
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.sellerName,
                          hintText:
                              AppLocalizations.of(context)!.enterSellerName,
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppLocalizations.of(context)!
                                .sellerNameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.enterEmailAddress,
                          hintText:
                              AppLocalizations.of(context)!.enterEmailAddress,
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppLocalizations.of(context)!.emailRequired;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(v)) {
                            return AppLocalizations.of(context)!.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordCtrl,
                        decoration: InputDecoration(
                          labelText: widget.seller == null
                              ? AppLocalizations.of(context)!.password
                              : AppLocalizations.of(context)!
                                  .newPasswordOptional,
                          hintText: widget.seller == null
                              ? AppLocalizations.of(context)!.enterPassword
                              : AppLocalizations.of(context)!
                                  .leaveEmptyKeepCurrent,
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        obscureText: true,
                        validator: (v) {
                          if (widget.seller == null &&
                              (v == null || v.isEmpty)) {
                            return AppLocalizations.of(context)!
                                .passwordRequired;
                          }
                          if (v != null && v.isNotEmpty && v.length < 6) {
                            return AppLocalizations.of(context)!
                                .passwordMinLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        decoration: InputDecoration(
                          labelText: widget.seller == null
                              ? AppLocalizations.of(context)!.confirmPassword
                              : AppLocalizations.of(context)!
                                  .confirmNewPassword,
                          hintText: widget.seller == null
                              ? AppLocalizations.of(context)!
                                  .enterConfirmPassword
                              : AppLocalizations.of(context)!
                                  .leaveEmptyNotChanging,
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        obscureText: true,
                        validator: (v) {
                          if (widget.seller == null &&
                              (v == null || v.isEmpty)) {
                            return AppLocalizations.of(context)!
                                .passwordConfirmationRequired;
                          }
                          if (_passwordCtrl.text != v) {
                            return AppLocalizations.of(context)!
                                .passwordsDoNotMatch;
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
                                widget.seller == null
                                    ? AppLocalizations.of(context)!.createSeller
                                    : AppLocalizations.of(context)!
                                        .updateSeller,
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
