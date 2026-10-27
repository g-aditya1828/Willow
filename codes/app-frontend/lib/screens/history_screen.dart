import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/scan_model.dart';
import '../services/auth_service.dart';
import '../services/ingredient_scanner_service.dart';
import '../theme/app_theme.dart';
import 'results_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _scanner = IngredientScannerService();
  final _auth = AuthService();
  final _searchCtrl = TextEditingController();

  List<ScanHistoryItem> _allHistory = [];
  bool _isLoading = true;
  int _activeFilterIndex = 0; // 0: All, 1: 75+ score, 2: Saved
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _auth.addListener(_onAuthChanged);
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final items = await _scanner.getScanHistory();
      if (mounted) {
        setState(() {
          _allHistory = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ScanHistoryItem> get _filteredHistory {
    return _allHistory.where((item) {
      if (_searchQuery.isNotEmpty) {
        final matchName = item.productName.toLowerCase().contains(_searchQuery);
        final matchCat = item.category.toLowerCase().contains(_searchQuery);
        if (!matchName && !matchCat) return false;
      }
      if (_activeFilterIndex == 1) {
        return item.riskScore >= 75;
      }
      if (_activeFilterIndex == 2) {
        return item.isFavorite;
      }
      return true;
    }).toList();
  }

  // Calculated Real Statistics from Backend Scans
  int get _totalScans => _allHistory.length;
  int get _avgScore {
    if (_allHistory.isEmpty) return 0;
    final sum = _allHistory.fold<int>(0, (prev, e) => prev + e.riskScore);
    return (sum / _allHistory.length).round();
  }
  int get _highScoresCount => _allHistory.where((e) => e.riskScore >= 75).length;

  void _openScannedItem(ScanHistoryItem item) {
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
    ).then((_) => _loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredHistory;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Stack(
        children: [
          // ── Top Gradient Ambient Banner (Figma #2:2148) ──────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.historyTopGradient,
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              color: AppTheme.primaryPurple,
              onRefresh: _loadHistory,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Brand Header (Figma #12:96) ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Row(
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
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: AppTheme.textHeading,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Page Heading (Figma #12:103) ────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan history',
                            style: GoogleFonts.inter(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textHeading,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'A little knowledge, saved for later.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textHeading,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Stats Row (Figma #12:104) ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              number: '$_totalScans',
                              label: 'Total scans',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              number: _allHistory.isNotEmpty ? '$_avgScore' : '—',
                              label: 'Avg. score',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              number: '$_highScoresCount',
                              label: 'High scores',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Main Content Container (Figma #2:2155) ───────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search Input (Figma #2:2160)
                          Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryPurple.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  color: AppTheme.textMuted,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppTheme.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search products or brands',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppTheme.textMuted,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () => _searchCtrl.clear(),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Filter Pills (Figma #2:2163)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildFilterPill(
                                  index: 0,
                                  title: 'All scans · ${_allHistory.length}',
                                ),
                                const SizedBox(width: 8),
                                _buildFilterPill(
                                  index: 1,
                                  title: '75+ score',
                                ),
                                const SizedBox(width: 8),
                                _buildFilterPill(
                                  index: 2,
                                  title: 'Saved',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // History List
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                            )
                          else if (filtered.isEmpty)
                            // Empty state — no dummy fallback items!
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurpleSoft,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.history_rounded,
                                      color: AppTheme.primaryPurple,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No matching scans found'
                                        : 'No scan history yet',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Try searching with a different product or brand name.'
                                        : 'Scan any food packaging to build your history log here.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Saved Scans',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${filtered.length} products',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryPurple,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...filtered.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildHistoryCard(item),
                                  );
                                }),
                              ],
                            ),

                          const SizedBox(height: 16),

                          // Sample Data Notice (Figma #2:2214)
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
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String number, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textHeading,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textHeading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({required int index, required String title}) {
    final isActive = _activeFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.filterActiveGradient : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: isActive ? null : Border.all(color: AppTheme.borderLight),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ScanHistoryItem item) {
    final score = item.riskScore;
    final isGood = score >= 75;
    final isMid = score >= 60 && score < 75;

    final mediaBg = isGood
        ? const Color(0xFFD4FAF0)
        : (isMid ? const Color(0xFFFFF3D4) : const Color(0xFFFFE8E8));

    return GestureDetector(
      onTap: () => _openScannedItem(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: AppTheme.borderLight, width: 1),
        ),
        child: Row(
          children: [
            // Media thumbnail
            Container(
              width: 62,
              height: 74,
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
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // Product information
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
                  // Score pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppTheme.scoreGradient(score),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '$score/100',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron container
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
