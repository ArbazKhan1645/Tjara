// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/store_page/controllers/store_page_controller.dart';
import 'package:tjara/app/modules/store_page/pages/products_grid.dart';

class StorePageSectionForm extends StatefulWidget {
  const StorePageSectionForm({super.key});

  @override
  _StorePageSectionFormState createState() => _StorePageSectionFormState();
}

class _StorePageSectionFormState extends State<StorePageSectionForm> {
  int _selectedIndex = 0;
  Timer? _searchDebounceTimer;

  late final List<Widget> _screens = [
    StoreProductGrid(
      scrollController: Get.find<StorePageController>().scrollController,
    ),
    const ShopDescriptionWidget(),
  ];

  var shopController = Get.find<StorePageController>();

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();

    if (value.trim().isEmpty) {
      shopController.searchController.clear();
      shopController.searchQuery.value = '';
      shopController.isSearching.value = false;
      shopController.fetchInitialProducts(shopController.currentSHop?.id ?? '');
      return;
    }

    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      shopController.searchProducts(value.trim());
    });
  }

  void _onSearchSubmitted() {
    _searchDebounceTimer?.cancel();

    final searchText = shopController.searchController.text.trim();
    if (searchText.isEmpty) {
      shopController.searchController.clear();
      shopController.searchQuery.value = '';
      shopController.isSearching.value = false;
      shopController.fetchInitialProducts(shopController.currentSHop?.id ?? '');
    } else {
      shopController.searchProducts(searchText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✨ Premium Store Header
        _StoreHeader(shopController: shopController),

        const SizedBox(height: 16),

        // ✨ Search Bar
        _SearchBar(
          controller: shopController.searchController,
          onChanged: _onSearchChanged,
          onSubmitted: _onSearchSubmitted,
        ),

        const SizedBox(height: 16),

        // ✨ Tab Buttons
        _TabButtons(
          selectedIndex: _selectedIndex,
          onTabSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),

        // Content
        _screens[_selectedIndex],
      ],
    );
  }
}

// ========================================
// ✨ Premium Store Header
// ========================================
class _StoreHeader extends StatelessWidget {
  final StorePageController shopController;

  const _StoreHeader({required this.shopController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFfda730)),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Store Avatar with gradient border
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: CachedNetworkImage(
                imageUrl:
                    shopController
                        .currentSHop
                        ?.thumbnail
                        ?.message
                        ?.optimizedMediaUrl ??
                    '',
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Icon(
                          Icons.store,
                          color: Colors.grey.shade600,
                          size: 28,
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00897B), Color(0xFF004D40)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          shopController.currentSHop!.name!
                              .toString()
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Store Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shopController.currentSHop?.name ?? 'Tjara Store',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '95% Positive',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.people_outline,
                      color: Colors.white.withOpacity(0.9),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '9.2k Followers',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // SizedBox(width: 12),

          // // Follow Button
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(20),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.1),
          //         blurRadius: 8,
          //         offset: Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(Icons.add, color: Color(0xFFfea52d), size: 18),
          //       SizedBox(width: 4),
          //       Text(
          //         'Follow',
          //         style: TextStyle(
          //           color: Color(0xFFfea52d),
          //           fontWeight: FontWeight.bold,
          //           fontSize: 14,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Premium Search Bar
// ========================================
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: (_) => onSubmitted(),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Color(0xFFfea52d), size: 22),
            hintText: 'Search in store...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}

// ========================================
// ✨ Modern Tab Buttons
// ========================================
class _TabButtons extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _TabButtons({required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'All Products',
              isSelected: selectedIndex == 0,
              onTap: () => onTabSelected(0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TabButton(
              label: 'About Store',
              isSelected: selectedIndex == 1,
              onTap: () => onTabSelected(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFfda730) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFFfea52d).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// ✨ Premium Shop Description
// ========================================
class ShopDescriptionWidget extends StatelessWidget {
  const ShopDescriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final shopController = Get.find<StorePageController>();

    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Title Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFfea52d), Color(0xFFf97316)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.store, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        shopController.currentSHop?.name ??
                            'Stylish Collection Wholesalers',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 16),

                // Description
                if (shopController.currentSHop?.description?.isNotEmpty ??
                    false)
                  Html(
                    data: shopController.currentSHop!.description!,
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(14),
                        color: Colors.grey.shade700,
                        lineHeight: const LineHeight(1.6),
                      ),
                    },
                  )
                else
                  Text(
                    'At Fetchy Aura, we bring elegance and charm to your jewelry collection. Our carefully crafted pieces blend timeless beauty with modern designs, ensuring you shine on every occasion.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),

                const SizedBox(height: 20),

                // Info Row
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member since',
                  value:
                      shopController.currentSHop?.createdAt
                          ?.toString()
                          .substring(0, 10) ??
                      'N/A',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value:
                      shopController.currentSHop?.meta?.country?.toString() ??
                      'United Kingdom',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Reviews Section
          const _ReviewsSection(),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Info Row Component
// ========================================
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFfea52d)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }
}

// ========================================
// ✨ Reviews Section
// ========================================
class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reviews Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.rate_review, color: Color(0xFFfea52d), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Customer Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFfea52d).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFfea52d),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Review Cards
        const _ReviewCard(
          name: 'Munaima Azhar',
          date: 'Jan 15, 2025',
          rating: 5,
          purchased: 'Black Handbag',
          review:
              'According to price quality is good and size is perfect. Pretty nice box type handbag, overall excellent!',
          isVerified: true,
        ),
        const SizedBox(height: 12),

        const _ReviewCard(
          name: 'Sara Azhar',
          date: 'Feb 25, 2025',
          rating: 5,
          purchased: 'White Handbag',
          review:
              'Handy for my holiday, absolutely beautiful, good quality product, really amazing piece!',
          isVerified: true,
        ),
        const SizedBox(height: 12),

        const _ReviewCard(
          name: 'Amna Syed',
          date: 'Mar 05, 2025',
          rating: 4,
          purchased: 'White Handbag',
          review: 'Perfect piece, quality is very good, very happy with item!',
          isVerified: false,
        ),

        const SizedBox(height: 16),

        // View All Reviews Button
        Center(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              side: const BorderSide(color: Color(0xFFfea52d), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All Reviews',
                  style: TextStyle(
                    color: Color(0xFFfea52d),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Color(0xFFfea52d), size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================
// ✨ Premium Review Card
// ========================================
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.name,
    required this.date,
    required this.rating,
    required this.purchased,
    required this.review,
    this.isVerified = false,
  });

  final String name;
  final String date;
  final int rating;
  final String purchased;
  final String review;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFfea52d), Color(0xFFf97316)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF00897B),
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$rating.0',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Purchased Item
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 14,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  'Purchased: $purchased',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Review Text
          Text(
            review,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),

          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 10),

          // Action Buttons
          Row(
            children: [
              const _ActionButton(
                icon: Icons.thumb_up_outlined,
                label: 'Helpful (12)',
                color: Color(0xFFfea52d),
              ),
              const SizedBox(width: 20),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Action Button Component
// ========================================
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
