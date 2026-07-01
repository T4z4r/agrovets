import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../utils/password_validator.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await AuthService.resetPassword(
        widget.email,
        _otpCtrl.text.trim(),
        _passwordCtrl.text,
        _confirmPasswordCtrl.text,
      );
      if (response['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Password reset successfully. Please login with your new password.'),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        final message = response['message']?.toString() ?? '';
        if (message.contains('User not found')) {
          setState(() => _error = 'User not found');
        } else if (message.contains('Invalid or expired OTP')) {
          setState(() => _error = 'Invalid or expired OTP');
        } else {
          setState(() => _error = 'Failed to reset password');
        }
      }
    } catch (e) {
      setState(() => _error = AppLocalizations.of(context)!.connectionError);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // App Icon
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  AppLocalizations.of(context)!.resetPassword,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!
                      .resetPasswordDescription(widget.email),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Form
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                            controller: _otpCtrl,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.otpCode,
                              hintText:
                                  AppLocalizations.of(context)!.enterOtpCode,
                              prefixIcon: const Icon(Icons.verified_user),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .otpRequired;
                              }
                              if (v.length != 6) {
                                return AppLocalizations.of(context)!
                                    .otpMustBe6Digits;
                              }
                              if (!RegExp(r'^\d{6}$').hasMatch(v)) {
                                return AppLocalizations.of(context)!
                                    .otpMustBeDigits;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordCtrl,
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
                                  'Password Requirements:',
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
                          TextFormField(
                            controller: _confirmPasswordCtrl,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.confirmPassword,
                              hintText: AppLocalizations.of(context)!
                                  .enterConfirmPassword,
                              prefixIcon: const Icon(Icons.lock),
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
                                    .passwordConfirmationRequired;
                              }
                              if (v != _passwordCtrl.text) {
                                return AppLocalizations.of(context)!
                                    .passwordsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loading ? null : _resetPassword,
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
                                    height: 20,
                                    width: 20,
                                    child: SpinKitWaveSpinner(
                                        color: Colors.white, size: 20.0),
                                  )
                                : const Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
