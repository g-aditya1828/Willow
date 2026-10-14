import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await AuthService().login(
      identifier: _identifierCtrl.text,
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res["success"] == true) {
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      }
    } else {
      setState(() {
        _errorMessage = res["error"] ?? "Invalid email or password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // App Logo / Icon with Orange Glow
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: AppTheme.pinkGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPink.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 34),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Clean Typography Title
                const Center(
                  child: Text(
                    "Welcome back",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    "Your personal AI nutrition & food safety scanner",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Error message banner
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.alertRedBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.highRiskRed.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppTheme.highRiskRed, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppTheme.highRiskRed,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Email / Username Label
                const Text(
                  "Email or Username",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _identifierCtrl,
                  decoration: InputDecoration(
                    hintText: "Enter your username or email",
                    prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppTheme.textMuted, size: 20),
                    fillColor: const Color(0xFFF8F8FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFEFEFF3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFEFEFF3)),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter your email or username";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Label
                const Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "••••••••",
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textMuted, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    fillColor: const Color(0xFFF8F8FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFEFEFF3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFEFEFF3)),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Remember Me Row
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: AppTheme.primaryPink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        onChanged: (val) => setState(() => _rememberMe = val ?? true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Remember me on this device",
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Glowing Orange Action Button
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: AppTheme.pinkGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPink.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text(
                            "Sign In",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Switch to Register
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(onRegisterSuccess: widget.onLoginSuccess),
                            ),
                          );
                        },
                        child: const Text(
                          "Create one",
                          style: TextStyle(
                            color: AppTheme.primaryPink,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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
