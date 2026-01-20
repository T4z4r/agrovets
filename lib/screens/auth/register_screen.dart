import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../utils/password_validator.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _shopNameCtrl = TextEditingController();
  final _shopLocationCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  String? _error;
  late Map<String, bool> _passwordRequirements;

  @override
  void initState() {
    super.initState();
    _passwordRequirements = {
      'length': false,
      'uppercase': false,
      'lowercase': false,
      'number': false,
      'special': false,
    };
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      setState(
          () => _error = AppLocalizations.of(context)!.acceptTermsRequired);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await AuthService.register(
        _nameCtrl.text,
        _emailCtrl.text,
        _passCtrl.text,
        _confirmPassCtrl.text,
        _shopNameCtrl.text,
        _shopLocationCtrl.text,
      );
      if (response['success']) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              email: _emailCtrl.text,
              isFromLogin: false,
            ),
          ),
        );
      } else {
        setState(() => _error = response['message'] ??
            AppLocalizations.of(context)!.registrationFailed);
      }
    } catch (e) {
      setState(() => _error = AppLocalizations.of(context)!.connectionError);
    }
    setState(() => _loading = false);
  }

  Future<void> _showPrivacyPolicy() async {
    try {
      final policy = await ApiService.getPrivacyPolicy();
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                policy.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Html(data: policy.content),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.ok ?? 'OK'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${AppLocalizations.of(context)!.failedLoadReport}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // App Icon
                const Image(
                  image: AssetImage('assets/logo.png'),
                  width: 100,
                  height: 100,
                ),

                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.createAccount,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Registration Form
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error,
                                      color: Colors.red[600], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(color: Colors.red[600]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.fullName,
                              hintText:
                                  AppLocalizations.of(context)!.enterFullName,
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .nameRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.emailAddress,
                              hintText:
                                  AppLocalizations.of(context)!.enterEmail,
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .emailRequired;
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(v)) {
                                return AppLocalizations.of(context)!
                                    .invalidEmail;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _shopNameCtrl,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.shopName,
                              hintText:
                                  AppLocalizations.of(context)!.enterShopName,
                              prefixIcon: const Icon(Icons.store),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) => null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _shopLocationCtrl,
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.shopLocation,
                              hintText: AppLocalizations.of(context)!
                                  .enterShopLocation,
                              prefixIcon: const Icon(Icons.location_on),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) => null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscurePassword,
                            onChanged: (value) {
                              setState(() {
                                _passwordRequirements =
                                    PasswordValidator.checkRequirements(value);
                              });
                            },
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.password,
                              hintText:
                                  AppLocalizations.of(context)!.enterPassword,
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() =>
                                      _obscurePassword = !_obscurePassword);
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              String? validation = PasswordValidator.validate(
                                  v ?? '', AppLocalizations.of(context)!);
                              if (validation != null) {
                                return validation;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPassCtrl,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.confirmPassword,
                              hintText:
                                  AppLocalizations.of(context)!.confirmPassword,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() => _obscureConfirmPassword =
                                      !_obscureConfirmPassword);
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .confirmPasswordRequired;
                              }
                              if (v != _passCtrl.text) {
                                return AppLocalizations.of(context)!
                                    .passwordsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          // Password Requirements
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .passwordRequirements,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...PasswordValidator.getRequirements(
                                        AppLocalizations.of(context)!)
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  String requirement = entry.value;
                                  String key = _passwordRequirements.keys
                                      .elementAt(index);
                                  bool met =
                                      _passwordRequirements[key] ?? false;
                                  return Row(
                                    children: [
                                      Icon(
                                        met
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: 14,
                                        color: met ? Colors.green : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          requirement,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: met
                                                ? Colors.green
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          CheckboxListTile(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() => _agreeToTerms = value ?? false);
                            },
                            title: RichText(
                              text: TextSpan(
                                text:
                                    AppLocalizations.of(context)!.agreeToTerms,
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .termsAndPolicy,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showPrivacyPolicy,
                                  ),
                                ],
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed:
                                _loading || !_agreeToTerms ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _agreeToTerms
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
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
                                    AppLocalizations.of(context)!.signUp,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              AppLocalizations.of(context)!.alreadyHaveAccount,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
