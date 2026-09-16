import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/food_item.dart';

class WillowHomeScreen extends StatefulWidget {
  const WillowHomeScreen({Key? key}) : super(key: key);

  @override
  State<WillowHomeScreen> createState() => _WillowHomeScreenState();
}

class _WillowHomeScreenState extends State<WillowHomeScreen> {
  int _selectedCategoryIndex = 0;
  int _bottomNavIndex = 2; // Center Scan active by default

  final List<String> _categories = [
    "🥣 Namkeen & Bhujia",
    "🍬 Mithai & Sweets",
    "🍪 Bakery & Rusks",
    "☕ Masalas & Tea",
  ];

  final List<FoodItem> _popularFoods = const [
    FoodItem(
      id: "1",
      category: "NAMKEEN",
      title: "Haldiram's Aloo...",
      subtitle: "INS 330, Palm Oil, TBHQ",
      price: 40.0,
      rating: 3.2,
      imageUrl:
          "https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80",
      tagText: "⚠️ Palm Oil Alert",
      tagType: TagType.alert,
    ),
    FoodItem(
      id: "2",
      category: "MITHAI",
      title: "The Whole Truth Kaj...",
      subtitle: "Only Cashews + Khand...",
      price: 120.0,
      rating: 4.9,
      imageUrl:
          "https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?auto=format&fit=crop&w=400&q=80",
      tagText: "🛡️ 100% Clean",
      tagType: TagType.clean,
    ),
    FoodItem(
      id: "3",
      category: "INSTANT FOODS",
      title: "Maggi Masala 2-Min",
      subtitle: "INS 635 Enhancer, High...",
      price: 14.0,
      rating: 2.8,
      imageUrl:
          "https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=400&q=80",
      tagText: "⚠️ 3 Flagged INS",
      tagType: TagType.alert,
    ),
    FoodItem(
      id: "4",
      category: "CLEAN CRUNCH",
      title: "Farmley Pink Salt...",
      subtitle: "Olive Oil Roasted, 0g...",
      price: 99.0,
      rating: 4.8,
      imageUrl:
          "https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=400&q=80",
      tagText: "✨ Healthy Swap",
      tagType: TagType.swap,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMint,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 16),
                  _buildLiveStatusPill(),
                  const SizedBox(height: 8),
                  _buildHeroHeading(),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildCategoriesSection(),
                  const SizedBox(height: 18),
                  _buildAiEngineBanner(),
                  const SizedBox(height: 24),
                  _buildPopularScannedHeader(),
                  const SizedBox(height: 12),
                  _buildProductsGrid(),
                  const SizedBox(height: 16),
                  _buildLooseHalwaiCard(),
                  const SizedBox(height: 20),
                  _buildSafetyPromiseCard(),
                ],
              ),
            ),
            _buildFloatingBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.leaf_arrow_circlepath,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "WILLOW INDIA",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.primary.withOpacity(0.7),
                ),
              ),
              const Text(
                "Pantry",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: const [
                Icon(Icons.location_on_outlined,
                    size: 16, color: Color(0xFFCA8A04)),
                SizedBox(width: 4),
                Text("Mumbai",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                Icon(Icons.keyboard_arrow_down,
                    size: 16, color: Colors.black54),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history, color: AppTheme.textPrimary),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusPill() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFD97706),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                "LIVE PANTRY INTELLIGENCE",
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Color(0xFF92400E)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "📍 New Delhi 🇮🇳",
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeading() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "What are we checking\ntoday?",
        style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            height: 1.15),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.search, color: Colors.grey, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Search 500+ additives, INS 621, Haldirams...",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppTheme.bgMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, color: AppTheme.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("Categories",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text("FSSAI Indexed",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF166534))),
                  )
                ],
              ),
              const Text("View all",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF854D0E))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final isSelected = index == _selectedCategoryIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategoryIndex = index),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildAiEngineBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.camera_alt_outlined,
                      size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text("VISUAL AI ENGINE",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "No Barcode? No Problem!",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              "Scan loose halwai mithai, unpackaged rusks, or street namkeen. Willow estimates chemical safety, hidden vanaspati, and shelf limits instantly.",
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.crop_free,
                      size: 16, color: AppTheme.primary),
                  label: const Text(
                    "Snap Loose Item",
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Takes 1.2s",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPopularScannedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Popular Scanned\nFoods",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                height: 1.2),
          ),
          Row(
            children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: Color(0xFFD97706), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text("Verified by Indian Pantry\nGuild",
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      height: 1.2)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: _popularFoods.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.74,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (context, index) {
          final item = _popularFoods[index];
          return _buildProductCard(item);
        },
      ),
    );
  }

  Widget _buildProductCard(FoodItem item) {
    Color tagBg;
    Color tagText;
    switch (item.tagType) {
      case TagType.alert:
        tagBg = AppTheme.alertRedBg;
        tagText = AppTheme.alertRedText;
        break;
      case TagType.clean:
        tagBg = AppTheme.cleanGreenBg;
        tagText = AppTheme.cleanGreenText;
        break;
      case TagType.swap:
        tagBg = AppTheme.swapTealBg;
        tagText = AppTheme.swapTealText;
        break;
      default:
        tagBg = AppTheme.alertOrangeBg;
        tagText = AppTheme.alertOrangeText;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    item.imageUrl,
                    height: 105,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.heart,
                        size: 14, color: AppTheme.textSecondary),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: tagBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.tagText,
                      style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: tagText),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.category,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary),
            ),
            Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: item.tagType == TagType.alert
                    ? AppTheme.alertRedText
                    : AppTheme.textSecondary,
                fontWeight: item.tagType == TagType.alert
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₹${item.price.toInt()}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF9C3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star,
                          size: 11, color: AppTheme.starYellow),
                      const SizedBox(width: 2),
                      Text(
                        "${item.rating}",
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF713F12)),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLooseHalwaiCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?auto=format&fit=crop&w=200&q=80",
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text("LOOSE",
                        style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.w800)),
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "LOCAL HALWAI ANALYSIS",
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFC2410C)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.star,
                                size: 10, color: Color(0xFFC2410C)),
                            SizedBox(width: 2),
                            Text("3.8",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFC2410C))),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Bengali Rasgulla (Fresh Chhena)",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary),
                  ),
                  const Text(
                    "Pure dairy chhena base, but estimated...",
                    style:
                        TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("₹60 / 2 pcs",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary)),
                      Text("Tap for sugar breakdown",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D9488),
                              decoration: TextDecoration.underline)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyPromiseCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE2F4EC),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.shield_outlined,
                        size: 18, color: AppTheme.primary),
                    SizedBox(width: 6),
                    Text("Willow Safety Promise",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC1E7D7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("100% Independent",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary)),
                )
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildPromiseMetric("3,420+", "Indian INS Rules"),
                const SizedBox(width: 8),
                _buildPromiseMetric("0%", "Brand Sponsored"),
                const SizedBox(width: 8),
                _buildPromiseMetric("Simple", "Kitchen Plain Talk"),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              "Aligned with the Food Safety and Standards Authority of India (FSSAI) Labelling & Display Regulations 2020.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5,
                  color: AppTheme.primary.withOpacity(0.8),
                  height: 1.3),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPromiseMetric(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary)),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBottomNav() {
    return Positioned(
      bottom: 12,
      left: 20,
      right: 20,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, CupertinoIcons.leaf_arrow_circlepath, "Pantry"),
            _buildNavItem(1, Icons.menu_book_outlined, "Harm Wiki"),
            GestureDetector(
              onTap: () => setState(() => _bottomNavIndex = 2),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDark.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(CupertinoIcons.barcode_viewfinder,
                        color: Colors.white, size: 24),
                  ],
                ),
              ),
            ),
            _buildNavItem(3, CupertinoIcons.square_stack_3d_up, "Swaps"),
            _buildNavItem(4, CupertinoIcons.person_crop_circle, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _bottomNavIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            ),
          )
        ],
      ),
    );
  }
}
