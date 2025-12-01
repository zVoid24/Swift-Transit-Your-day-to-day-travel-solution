import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:swifttransit/core/colors.dart';
import 'package:swifttransit/widgets/app_snackbar.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/input_field.dart';
import '../../widgets/primary_button.dart';
import 'login_screen.dart';

class _CachedLottie extends StatefulWidget {
  final String asset;
  final double height;
  const _CachedLottie({required this.asset, required this.height});

  @override
  State<_CachedLottie> createState() => _CachedLottieState();
}

class _CachedLottieState extends State<_CachedLottie> {
  late final Future<LottieComposition> _compositionFuture;

  @override
  void initState() {
    super.initState();
    // Preload the composition once
    _compositionFuture = _loadComposition();
  }

  Future<LottieComposition> _loadComposition() async {
    return await AssetLottie(widget.asset).load();
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary prevents unnecessary repaints of the animation
    return RepaintBoundary(
      child: FutureBuilder<LottieComposition>(
        future: _compositionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return SizedBox(
              height: widget.height,
              child: Lottie(
                composition: snapshot.data!,
                fit: BoxFit.contain,
                // keep animation playing but it won't re-create composition
              ),
            );
          }

          // lightweight placeholder while loading
          return SizedBox(
            height: widget.height,
            child: const Center(child: SizedBox.shrink()),
          );
        },
      ),
    );
  }
}

/// Helper wrapper to load Lottie composition from asset programmatically.
/// We define this so preloading composition is easy and reused.
class AssetLottie {
  final String assetPath;
  AssetLottie(this.assetPath);

  Future<LottieComposition> load() async {
    final assetData = await rootBundle.load(assetPath);
    return await LottieComposition.fromByteData(assetData);
  }
}

/// Main SignupScreen
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  double? _initialHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Capture initial height once (first real frame). This prevents
    // layout breakpoints from changing when the keyboard opens.
    _initialHeight ??= MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    // Use listen: false where we only need controllers, preventing rebuilds
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    // Use initial height (fallback to current if not set)
    final baseHeight = _initialHeight ?? size.height;
    final isSmallHeight = baseHeight < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // let Flutter adjust layout
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: baseHeight * 0.02),

                  // Fixed-height Lottie that uses a cached composition
                  _CachedLottie(
                    asset: 'assets/signup.json',
                    height: isSmallHeight ? 80 : 120,
                  ),

                  SizedBox(height: baseHeight * 0.02),

                  Text(
                    "Sign Up",
                    style: GoogleFonts.poppins(
                      fontSize: isSmallHeight ? 26 : 32,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Join Swift Transit and travel smarter",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: isSmallHeight ? 12 : 14,
                    ),
                  ),

                  SizedBox(height: baseHeight * 0.03),

                  // Input fields. These reference controllers in provider but do not
                  // cause whole screen rebuilds when provider notifies.
                  AppInputField(
                    controller: auth.fullName,
                    icon: HugeIcons.strokeRoundedUserCircle,
                    hint: "Full Name (As Per NID)",
                  ),

                  AppInputField(
                    controller: auth.email,
                    icon: HugeIcons.strokeRoundedMail01,
                    hint: "Email Address",
                    keyboardType: TextInputType.emailAddress,
                  ),

                  AppInputField(
                    controller: auth.nid,
                    icon: HugeIcons.strokeRoundedIdentification,
                    hint: "NID Number",
                    keyboardType: TextInputType.number,
                  ),

                  AppInputField(
                    controller: auth.phone,
                    icon: HugeIcons.strokeRoundedCall,
                    hint: "Contact Number",
                    keyboardType: TextInputType.phone,
                    customPrefix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network("https://flagcdn.com/w40/bd.png", width: 20),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),

                  AppInputField(
                    controller: auth.password,
                    icon: HugeIcons.strokeRoundedLockPassword,
                    hint: "Create Password",
                    isPassword: true,
                  ),

                  AppInputField(
                    controller: auth.confirmPassword,
                    icon: HugeIcons.strokeRoundedLockPassword,
                    hint: "Confirm Password",
                    isPassword: true,
                  ),

                  //const SizedBox(height: 2),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // We use Consumer only for the agreed checkbox so only that small
                      // piece rebuilds when toggled.
                      Consumer<AuthProvider>(
                        builder: (context, ap, _) => Checkbox(
                          value: ap.agreed,
                          onChanged: ap.toggleAgreement,
                          side: const BorderSide(color: Colors.black),
                          checkColor: Colors.white,
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            children: [
                              const TextSpan(text: "I agree to the "),
                              TextSpan(
                                text: "Terms & Conditions",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: const Color(0xFF258BA1),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: " of Swift Transit."),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: baseHeight * 0.02),

                  // Use Consumer only for button loading state (small rebuild)
                  Consumer<AuthProvider>(
                    builder: (context, ap, _) => PrimaryButton(
                      text: ap.isLoading ? "Loading..." : "Sign Up",
                      onTap: () async {
                        if (!ap.isSignupValid()) {
                          AppSnackBar.error(
                            context,
                            "Please fill up all fields correctly and make sure passwords match.",
                          );
                          return;
                        }

                        final ok = await ap.signup();
                        if (ok) {
                          AppSnackBar.success(context, "Account created successfully!");
                        } else {
                          AppSnackBar.error(context, "Failed to create account. Try again.");
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      "Already have an account? ",   // ← added space here
      style: GoogleFonts.poppins(color: Colors.black),
    ),
    TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,                     // removes all default padding
        minimumSize: Size.zero,                       // allows button to shrink to text size
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // removes extra tap padding
      ),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      },
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
}
