import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../dashboard_screen.dart';
import '../seller/seller_home_screen.dart';
import 'login_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool isFromLogin;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.isFromLogin = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  bool _resendLoading = false;
  String? _error;
  int _resendCooldown = 0;

  Timer? _timer;

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) {
      setState(() => _error = 'Please enter complete 6-digit OTP');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response =
          await AuthService.verifyOtp(widget.email.trim(), _otpCode);
      if (response['success']) {
        final authProvider = context.read<AuthProvider>();
        await authProvider.loadUser();
        if (!mounted) return;
        final user = authProvider.user;
        if (!mounted) return;
        if (user?['role'] == 'seller') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SellerHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } else {
        setState(
            () => _error = AppLocalizations.of(context)!.invalidOrExpiredOtp);
      }
    } catch (e) {
      setState(() => _error = AppLocalizations.of(context)!.connectionError);
    }
    setState(() => _loading = false);
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) return;
    setState(() {
      _resendLoading = true;
      _error = null;
    });
    try {
      final response = await AuthService.resendOtp(widget.email.trim());
      if (response['success']) {
        _startResendCooldown();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('OTP sent successfully'),
            ),
          );
        }
      } else {
        setState(() => _error = 'Failed to resend OTP');
      }
    } catch (e) {
      setState(() => _error = AppLocalizations.of(context)!.connectionError);
    }
    setState(() => _resendLoading = false);
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
                const SizedBox(height: 40),

                // App Icon
                Icon(
                  Icons.verified_user,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  AppLocalizations.of(context)!.otpVerification,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to\n${widget.email}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // OTP Form
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
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final screenWidth = constraints.maxWidth;
                              final boxWidth = screenWidth > 400 ? 50.0 : (screenWidth - 48) / 6;
                              final boxHeight = screenWidth > 400 ? 58.0 : 54.0;
                              final fontSize = screenWidth > 400 ? 24.0 : 20.0;
                              final spacing = screenWidth > 400 ? 8.0 : 6.0;
                              return Wrap(
                                alignment: WrapAlignment.center,
                                spacing: spacing,
                                runSpacing: spacing,
                                children: List.generate(6, (index) {
                                  return SizedBox(
                                    width: boxWidth.clamp(40.0, 55.0),
                                    height: boxHeight.clamp(46.0, 60.0),
                                    child: TextFormField(
                                      controller: _otpControllers[index],
                                      focusNode: _focusNodes[index],
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: screenWidth > 400 ? 16 : 12,
                                          horizontal: 0,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty && index < 5) {
                                          _focusNodes[index + 1].requestFocus();
                                        }
                                        if (value.isEmpty && index > 0) {
                                          _focusNodes[index - 1].requestFocus();
                                        }
                                        if (_otpCode.length == 6) {
                                          Future.delayed(const Duration(milliseconds: 300), () {
                                            if (_otpCode.length == 6 && mounted) {
                                              _verifyOtp();
                                            }
                                          });
                                        }
                                      },
                                    ),
                                );
                                }),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loading ? null : _verifyOtp,
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
                                    'Verify OTP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: (_resendLoading || _resendCooldown > 0)
                                ? null
                                : _resendOtp,
                            child: _resendLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: SpinKitWaveSpinner(
                                        color: Colors.blue, size: 20.0),
                                  )
                                : Text(
                                    _resendCooldown > 0
                                        ? 'Resend OTP in ${_resendCooldown}s'
                                        : 'Resend OTP',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.grey[600],
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
