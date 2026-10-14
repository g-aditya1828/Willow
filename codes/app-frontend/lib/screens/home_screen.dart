import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'scan_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onGoToHistory;
  const HomeScreen({super.key, this.onGoToHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      body: Stack(
        children: [
          // ── Decorative Blobs ──────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryPink.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFC1D4).withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: -30,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryPink.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top Bar ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.pinkGradient,
                        ),
                        child: const Center(
                          child: Text("🌿", style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back 👋",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            AuthService().isAuthenticated
                                ? (AuthService().currentUser?.username ?? 'Willow User')
                                : 'Willow Scanner',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Sparkle icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPinkBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppTheme.primaryPink,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── Hero Title ─────────────────────────────
                        const Text(
                          "AI Food",
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1.05,
                            letterSpacing: -1.2,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.pinkGradient.createShader(bounds),
                          child: const Text(
                            "Scanner",
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.05,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Scan. Analyze. Eat Smarter.",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Hero Food Image ────────────────────────
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Soft pink glow behind image
                              Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppTheme.primaryPink.withValues(alpha: 0.12),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              // Food image
                              SizedBox(
                                width: 230,
                                height: 230,
                                child: Image.network(
                                  "https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=500&q=80",
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Text("🥗", style: TextStyle(fontSize: 120)),
                                  ),
                                ),
                              ),
                              // Floating scan frame corners
                              Positioned(
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.primaryPink.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Quick Action Buttons ───────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionChip(
                                icon: Icons.history_rounded,
                                label: "Recent",
                                onTap: onGoToHistory ?? () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Central big scan button
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ScanScreen(),
                                ),
                              ),
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.pinkGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryPink.withValues(alpha: 0.35),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.document_scanner_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionChip(
                                icon: Icons.info_outline_rounded,
                                label: "About",
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // ── Smart Tip Card ─────────────────────────
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPinkBg,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text("💡", style: TextStyle(fontSize: 26)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, size: 13, color: AppTheme.watchOrange),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Smart Tip",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.watchOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      "Scan the ingredient label of any packaged food to check for FSSAI-flagged additives instantly.",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppTheme.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.pinkGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── How it Works ───────────────────────────
                        const Text(
                          "How It Works",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _HowItWorksStep(
                              number: "1",
                              icon: "📸",
                              label: "Scan Label",
                            ),
                            _StepConnector(),
                            _HowItWorksStep(
                              number: "2",
                              icon: "🔍",
                              label: "AI Analysis",
                            ),
                            _StepConnector(),
                            _HowItWorksStep(
                              number: "3",
                              icon: "✅",
                              label: "Get Score",
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.pillSurface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String icon;
  final String label;

  const _HowItWorksStep({
    required this.number,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.primaryPinkBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: AppTheme.cardBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
