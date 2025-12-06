import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import 'package:swifttransit/app/routes/app_routes.dart';
import 'package:swifttransit/core/colors.dart';
import 'package:swifttransit/features/auth/application/auth_provider.dart';
import 'package:swifttransit/shared/widgets/app_snackbar.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _nidFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _nidFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width > 700 ? 520.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  CircleAvatar(
                    radius: 46,
                    backgroundImage: const AssetImage('assets/stlogo.png'),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sign Up',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join Swift Transit and travel smarter',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Form card
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 0,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          buildInputField(
                            controller: auth.fullName,
                            hint: 'Full Name (As Per NID)',
                            icon: HugeIcons.strokeRoundedUserCircle,
                            focusNode: _nameFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          buildInputField(
                            controller: auth.email,
                            hint: 'Email Address',
                            icon: HugeIcons.strokeRoundedMail01,
                            keyboardType: TextInputType.emailAddress,
                            focusNode: _emailFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _nidFocus.requestFocus(),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter email';
                              }
                              final regex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!regex.hasMatch(v.trim())) {
                                return 'Enter valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          buildInputField(
                            controller: auth.nid,
                            hint: 'NID Number',
                            icon: HugeIcons.strokeRoundedIdentification,
                            keyboardType: TextInputType.number,
                            focusNode: _nidFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter NID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          buildInputField(
                            controller: auth.phone,
                            hint: 'Contact Number',
                            icon: HugeIcons.strokeRoundedCall,
                            keyboardType: TextInputType.phone,
                            focusNode: _phoneFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _passwordFocus.requestFocus(),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter contact number';
                              }
                              if (v.trim().length < 8) {
                                return 'Enter valid phone';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          buildInputField(
                            controller: auth.password,
                            hint: 'Create Password',
                            icon: HugeIcons.strokeRoundedLockPassword,
                            isPassword: true,
                            isPasswordVisible: _isPasswordVisible,
                            onVisibilityChanged: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            focusNode: _passwordFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _confirmFocus.requestFocus(),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter password';
                              }
                              if (v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          buildInputField(
                            controller: auth.confirmPassword,
                            hint: 'Confirm Password',
                            icon: HugeIcons.strokeRoundedLockPassword,
                            isPassword: true,
                            isPasswordVisible: _isConfirmPasswordVisible,
                            onVisibilityChanged: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                            focusNode: _confirmFocus,
                            textInputAction: TextInputAction.done,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Confirm your password';
                              }
                              if (v != auth.password.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Agreement
                          Row(
                            children: [
                              Consumer<AuthProvider>(
                                builder: (context, ap, _) => Checkbox(
                                  value: ap.agreed,
                                  onChanged: (val) => ap.toggleAgreement(val),
                                  activeColor: AppColors.primary,
                                ),
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms & Conditions',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' of Swift Transit.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Consumer<AuthProvider>(
                    builder: (context, ap, _) => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: ap.isLoading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  AppSnackBar.error(
                                    context,
                                    'Fix the highlighted errors.',
                                  );
                                  return;
                                }
                                if (!ap.agreed) {
                                  AppSnackBar.warning(
                                    context,
                                    'Please accept Terms & Conditions.',
                                  );
                                  return;
                                }

                                final ok = await ap.initiateSignup();
                                if (ok) {
                                  AppSnackBar.success(
                                    context,
                                    'OTP sent to your email!',
                                  );
                                  if (!context.mounted) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OtpVerificationScreen(
                                        email: ap.email.text,
                                      ),
                                    ),
                                  );
                                } else {
                                  AppSnackBar.error(
                                    context,
                                    'Failed to initiate signup. Try again.',
                                  );
                                }
                              },
                        child: ap.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Sign Up',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.poppins(color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    required dynamic icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityChanged,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !isPasswordVisible : false,
        keyboardType: keyboardType,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 20,
              width: 20,
              child: HugeIcon(icon: icon, color: Colors.grey, size: 20),
            ),
          ),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Feather.eye : Feather.eye_off,
                    size: 22,
                    color: Colors.grey,
                  ),
                  onPressed: onVisibilityChanged,
                )
              : null,
        ),
      ),
    );
  }
}
