import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _activeTabIndex = 0; // 0: Log in, 1: Sign up
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = AuthService();
    Map<String, dynamic> res;

    if (_activeTabIndex == 0) {
      // Log in
      res = await auth.login(
        identifier: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } else {
      // Sign up
      final username = _usernameCtrl.text.trim().isNotEmpty
          ? _usernameCtrl.text.trim()
          : _emailCtrl.text.split('@').first;
      res = await auth.register(
        username: username,
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      widget.onLoginSuccess?.call();
    } else {
      setState(() => _errorMessage = res['error'] ?? 'Authentication failed.');
    }
  }

  void _continueAsGuest() {
    AuthService().continueAsGuest();
    widget.onLoginSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background Gradient (Figma #8:132) ───────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.welcomeGradient,
              ),
            ),
          ),

          // ── Decorative Floating Ellipses from Figma ──────────────
          // Ellipse 1: top-left (-60, -60, 220x220)
          Positioned(
            left: -60,
            top: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x17FFFFFF),
              ),
            ),
          ),
          // Ellipse 2: top-right (230, 0, 160x160)
          Positioned(
            right: -20,
            top: 20,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x304ECDC4),
              ),
            ),
          ),
          // Ellipse 3: bottom-left (-30, 580, 140x140)
          Positioned(
            left: -30,
            bottom: 120,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x21FF6B6B),
              ),
            ),
          ),
          // Ellipse 4: bottom-right (280, 620, 180x180)
          Positioned(
            right: -40,
            bottom: 80,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x21FFE166),
              ),
            ),
          ),

          // ── Foreground Content ───────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Brand mark & Willow wordmark (Figma #8:142)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.19),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'willow',
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Welcome copy (Figma #8:145)
                  Text(
                    'Welcome to Willow',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A little clarity. A healthier everyday.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Glass Login Panel (Figma #8:149) ─────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B4EFF).withValues(alpha: 0.13),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Authentication tabs (Figma #8:150)
                          Container(
                            height: 54,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurpleLight,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _activeTabIndex = 0;
                                      _errorMessage = null;
                                    }),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: _activeTabIndex == 0
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF4ECDC4),
                                                  Color(0xFF4E8BFF),
                                                ],
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(100),
                                        boxShadow: _activeTabIndex == 0
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.primaryPurple.withValues(alpha: 0.25),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        'Log in',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: _activeTabIndex == 0
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: _activeTabIndex == 0
                                              ? Colors.white
                                              : AppTheme.primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _activeTabIndex = 1;
                                      _errorMessage = null;
                                    }),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: _activeTabIndex == 1
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF4ECDC4),
                                                  Color(0xFF4E8BFF),
                                                ],
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(100),
                                        boxShadow: _activeTabIndex == 1
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.primaryPurple.withValues(alpha: 0.25),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        'Sign up',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: _activeTabIndex == 1
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: _activeTabIndex == 1
                                              ? Colors.white
                                              : AppTheme.primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.redSoftBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.redDanger.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(
                                  color: AppTheme.redDanger,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          if (_activeTabIndex == 1) ...[
                            Text(
                              'NAME',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryPurpleDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _usernameCtrl,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Alex Morgan',
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: AppTheme.primaryPurple,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // EMAIL Field
                          Text(
                            'EMAIL',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryPurpleDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'alex.morgan@gmail.com',
                              prefixIcon: const Icon(
                                Icons.mail_outline_rounded,
                                color: AppTheme.primaryPurple,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // PASSWORD Field
                          Text(
                            'PASSWORD',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryPurpleDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                            validator: (v) {
                              if (v == null || v.length < 4) {
                                return 'Password must be at least 4 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(
                                Icons.key_rounded,
                                color: AppTheme.primaryPurple,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (_activeTabIndex == 0)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                            ),
                          const SizedBox(height: 22),

                          // Primary Action Button (Figma #8:168)
                          GestureDetector(
                            onTap: _isLoading ? null : _handleSubmit,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryButtonGradient,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryPurple.withValues(alpha: 0.33),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isLoading)
                                    const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  else ...[
                                    Text(
                                      _activeTabIndex == 0 ? 'Log in' : 'Create account',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Divider "or continue with" (Figma #8:171)
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: AppTheme.purpleBorder,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or continue with',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: AppTheme.purpleBorder,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Continue as guest button (Figma #8:175)
                          GestureDetector(
                            onTap: _continueAsGuest,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: AppTheme.purpleBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.qr_code_scanner_rounded,
                                    color: AppTheme.primaryPurple,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 9),
                                  Text(
                                    'Continue as guest',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryPurple,
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
                  const SizedBox(height: 16),

                  // Terms & Privacy copy (Figma #8:178)
                  Text(
                    'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
