import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/ingredient_scanner_service.dart';
import '../model/scan_model.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onGoToScan;
  final VoidCallback? onGoToHistory;

  const HomeScreen({
    super.key,
    this.onGoToScan,
    this.onGoToHistory,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scanner = IngredientScannerService();
  List<ScanHistoryItem> _recentScans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentScans();
  }

  Future<void> _loadRecentScans() async {
    try {
      final items = await _scanner.getScanHistory();
      if (mounted) {
        setState(() {
          _recentScans = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  String _getUserInitials(String? username) {
    if (username == null || username.trim().isEmpty) return 'AL';
    final parts = username.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _openScannedItem(ScanHistoryItem item) {
    // Navigate with real data saved from backend scan
    final analysis = ProductAnalysis(
      scanId: item.id,
      productName: item.productName,
      category: item.category,
      riskScore: item.riskScore,
      scoreLabel: AppTheme.scoreLabel(item.riskScore),
      confidence: item.confidence,
      isFallback: item.isFallback,
      fallbackNote: item.fallbackNote,
      fssaiNumber: item.fssaiNumber,
      isFavorite: item.isFavorite,
      flagged: item.flagged,
      clean: item.clean,
      unknown: item.unknown,
      alternatives: [],
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(analysis: analysis),
      ),
    ).then((_) => _loadRecentScans());
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final username = user?.username.trim().isNotEmpty == true
        ? user!.username.trim()
        : 'Alex';
    final initials = _getUserInitials(username);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Stack(
        children: [
          // ── Top Gradient Ambient Banner (Figma #2:1876) ──────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.homeTopGradient,
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              color: AppTheme.primaryPurple,
              onRefresh: _loadRecentScans,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),

                    // ── Brand Header (Figma #2:1884) ─────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.eco_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'willow',
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textHeading,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            ).then((_) => _loadRecentScans());
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              initials,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryPurpleDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Welcome Heading (Figma #2:1891) ──────────────────────
                    Text(
                      '${_greetingText()}, ${username.toUpperCase()}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textHeading,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Small choices.\nA little more clarity.',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        color: AppTheme.textHeading,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Main Card Container (Figma #12:22) ───────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Scan Invitation Hero Card (Figma #2:1894) ────────
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: AppTheme.scanHeroBannerGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryPurple.withValues(alpha: 0.28),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.qr_code_scanner_rounded,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "What's in your basket?",
                                            style: GoogleFonts.inter(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Scan a barcode. Understand the label.',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: widget.onGoToScan,
                                  child: Container(
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Scan a product',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryPurpleDark,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: AppTheme.primaryPurpleDark,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // ── Recently Scanned Section (Figma #2:1904) ─────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recently scanned',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              if (_recentScans.isNotEmpty)
                                GestureDetector(
                                  onTap: widget.onGoToHistory,
                                  child: Text(
                                    'View all',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryPurple,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Real scans only — arriving from backend when scanned
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                            )
                          else if (_recentScans.isEmpty)
                            // Clean Empty State when no scans exist yet
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurpleSoft,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppTheme.purpleBorder.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.document_scanner_outlined,
                                      color: AppTheme.primaryPurple,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No products scanned yet',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Scan any food packaging or ingredient list.\nResults will appear here automatically.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: _recentScans.take(3).map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _buildRecentScanCard(item),
                                );
                              }).toList(),
                            ),

                          const SizedBox(height: 18),

                          // Brand Promise Footer Banner (Figma #2:1926)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.eco_rounded,
                                color: AppTheme.greenDeep,
                                size: 16,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'More understanding. Less guesswork.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.primaryPurpleDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Sample Data Notice (Figma #2:1929)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppTheme.textMuted,
                                size: 13,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Illustrative products & scores. Not medical advice.',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScanCard(ScanHistoryItem item) {
    final score = item.riskScore;
    final isGood = score >= 75;
    final isMid = score >= 60 && score < 75;

    final mediaBg = isGood
        ? const Color(0xFFE8FBF7)
        : (isMid ? const Color(0xFFFFF7E6) : const Color(0xFFFFF0F0));

    return GestureDetector(
      onTap: () => _openScannedItem(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Media square thumbnail (Figma layout_a128cf5c)
            Container(
              width: 58,
              height: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: mediaBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: isGood
                    ? AppTheme.tealAccent
                    : (isMid ? AppTheme.amberWarning : AppTheme.redDanger),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),

            // Product Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.category} · ${item.timeAgo}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Score Pill (Figma layout_4b7bcf2e)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppTheme.scoreGradient(score),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '$score/100',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron container (Figma layout_be9d5bd8)
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: mediaBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
