import 'package:flutter/material.dart';
import '../model/scan_model.dart';
import '../services/auth_service.dart';
import '../services/ingredient_scanner_service.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _scanner = IngredientScannerService();
  final _auth = AuthService();

  List<ScanHistoryItem> _history = [];
  bool _isLoading = false;
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!_auth.isAuthenticated) {
      setState(() {
        _history = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    final items = await _scanner.getScanHistory();
    if (!mounted) return;
    setState(() {
      _history = items;
      _isLoading = false;
    });
  }

  Future<void> _toggleBookmark(ScanHistoryItem item) async {
    final res = await _scanner.toggleFavorite(item.id);
    if (res != null && mounted) _loadHistory();
  }

  Color _scoreColor(int score) {
    return AppTheme.scoreColor(score);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _showOnlyFavorites
        ? _history.where((h) => h.isFavorite).toList()
        : _history;

    return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.bgOffWhite,
        title: const Text("Scan History"),
        actions: [
          if (_auth.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadHistory,
            ),
        ],
      ),
      body: SafeArea(
        child: !_auth.isAuthenticated
            ? _buildGuestView()
            : _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryPink,
                    ),
                  )
                : Column(
                    children: [
                      // ── Filter Bar ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                        child: Row(
                          children: [
                            _FilterPill(
                              label: "All (${_history.length})",
                              selected: !_showOnlyFavorites,
                              onTap: () => setState(() => _showOnlyFavorites = false),
                            ),
                            const SizedBox(width: 10),
                            _FilterPill(
                              label:
                                  "⭐ Favorites (${_history.where((h) => h.isFavorite).length})",
                              selected: _showOnlyFavorites,
                              onTap: () => setState(() => _showOnlyFavorites = true),
                            ),
                          ],
                        ),
                      ),

                      // ── List ─────────────────────────────────────────
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                                itemCount: filtered.length,
                                itemBuilder: (context, idx) {
                                  final item = filtered[idx];
                                  final col = _scoreColor(item.riskScore);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border:
                                          Border.all(color: AppTheme.cardBorder),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 12,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Score Circle
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: col.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                            border:
                                                Border.all(color: col, width: 2.5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${item.riskScore}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: col,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                item.category,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  if (item.flaggedCount > 0)
                                                    Container(
                                                      margin: const EdgeInsets.only(right: 8),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppTheme.alertOrangeBg,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                8),
                                                      ),
                                                      child: Text(
                                                        "⚠️ ${item.flaggedCount} flagged",
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              AppTheme.watchOrange,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  if (item.fssaiNumber != null)
                                                    const Text(
                                                      "✓ FSSAI",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: AppTheme.cleanGreen,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Bookmark
                                        IconButton(
                                          icon: Icon(
                                            item.isFavorite
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            color: item.isFavorite
                                                ? AppTheme.watchOrange
                                                : AppTheme.textMuted,
                                          ),
                                          onPressed: () =>
                                              _toggleBookmark(item),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryPinkBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 40,
                color: AppTheme.primaryPink,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Sync Your Scans",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryPink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sign in to securely store your product scan history and favorite health swaps.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginScreen(onLoginSuccess: _loadHistory),
                  ),
                );
              },
              child: const Text("Sign In or Register"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              _showOnlyFavorites ? "No saved favorites yet" : "No scans found",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Scan any packaged food product from the scanner tab to see it here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryPink : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryPink : AppTheme.cardBorder,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPink.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
