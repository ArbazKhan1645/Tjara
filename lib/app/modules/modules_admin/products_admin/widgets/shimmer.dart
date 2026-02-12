import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/widgets/admin_products_theme.dart';

class ProductShimmerCard extends StatelessWidget {
  const ProductShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AdminProductsTheme.cardDecoration,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminProductsTheme.spacingLg,
        vertical: AdminProductsTheme.spacingMd,
      ),
      child: Shimmer.fromColors(
        baseColor: AdminProductsTheme.surfaceSecondary,
        highlightColor: AdminProductsTheme.surface,
        child: Row(
          children: [
            // Product ID
            _buildShimmerColumn(width: 100),

            // Image
            _buildShimmerImage(),

            // Product Name
            _buildShimmerColumn(width: 180),

            // Shop Name
            _buildShimmerColumn(width: 150),

            // Price
            _buildShimmerBadge(width: 80),

            // Stock
            _buildShimmerBadge(width: 60),

            // Published At
            _buildShimmerColumn(width: 120),

            // Status
            _buildShimmerBadge(width: 80),

            // Actions
            const SizedBox(width: AdminProductsTheme.spacingMd),
            _buildShimmerActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerColumn({required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminProductsTheme.spacingSm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.5,
            height: 10,
            decoration: BoxDecoration(
              color: AdminProductsTheme.surface,
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: width * 0.8,
            height: 14,
            decoration: BoxDecoration(
              color: AdminProductsTheme.surface,
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerImage() {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminProductsTheme.spacingSm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 10,
            decoration: BoxDecoration(
              color: AdminProductsTheme.surface,
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AdminProductsTheme.surface,
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBadge({required double width}) {
    return Container(
      width: width + 20,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminProductsTheme.spacingSm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.5,
            height: 10,
            decoration: BoxDecoration(
              color: AdminProductsTheme.surface,
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: width,
            height: 28,
            decoration: BoxDecoration(
              color: AdminProductsTheme.surface,
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerActions() {
    return Row(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AdminProductsTheme.surface,
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductsShimmerList extends StatelessWidget {
  final int itemCount;

  const ProductsShimmerList({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header shimmer
        _buildHeaderShimmer(),
        const SizedBox(height: AdminProductsTheme.spacingSm),
        // Product cards shimmer
        ...List.generate(
          itemCount,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: AdminProductsTheme.spacingSm),
            child: ProductShimmerCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderShimmer() {
    return Container(
      height: 48,
      decoration: AdminProductsTheme.tableHeaderDecoration,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminProductsTheme.spacingLg,
      ),
      child: Shimmer.fromColors(
        baseColor: AdminProductsTheme.surfaceSecondary,
        highlightColor: AdminProductsTheme.surface,
        child: Row(
          children: [
            _buildHeaderCell(100),
            _buildHeaderCell(80),
            _buildHeaderCell(180),
            _buildHeaderCell(150),
            _buildHeaderCell(100),
            _buildHeaderCell(80),
            _buildHeaderCell(120),
            _buildHeaderCell(100),
            _buildHeaderCell(200),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminProductsTheme.spacingSm,
      ),
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: AdminProductsTheme.surface,
          borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
        ),
      ),
    );
  }
}

class FilterShimmer extends StatelessWidget {
  const FilterShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminProductsTheme.spacingXl),
      decoration: AdminProductsTheme.cardDecoration,
      child: Shimmer.fromColors(
        baseColor: AdminProductsTheme.surfaceSecondary,
        highlightColor: AdminProductsTheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search section title
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusSm,
                    ),
                  ),
                ),
                const SizedBox(width: AdminProductsTheme.spacingSm),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusSm,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminProductsTheme.spacingMd),

            // Main search field
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AdminProductsTheme.surface,
                borderRadius: BorderRadius.circular(
                  AdminProductsTheme.radiusMd,
                ),
              ),
            ),
            const SizedBox(height: AdminProductsTheme.spacingMd),

            // ID and SKU fields
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AdminProductsTheme.surface,
                      borderRadius: BorderRadius.circular(
                        AdminProductsTheme.radiusMd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AdminProductsTheme.spacingMd),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AdminProductsTheme.surface,
                      borderRadius: BorderRadius.circular(
                        AdminProductsTheme.radiusMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminProductsTheme.spacingXl),

            // Filter section title
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusSm,
                    ),
                  ),
                ),
                const SizedBox(width: AdminProductsTheme.spacingSm),
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusSm,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminProductsTheme.spacingMd),

            // Status chips
            Wrap(
              spacing: AdminProductsTheme.spacingSm,
              runSpacing: AdminProductsTheme.spacingSm,
              children: [
                _buildChipShimmer(60),
                _buildChipShimmer(70),
                _buildChipShimmer(80),
                _buildChipShimmer(75),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipShimmer(double width) {
    return Container(
      width: width,
      height: 36,
      decoration: BoxDecoration(
        color: AdminProductsTheme.surface,
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusLg),
      ),
    );
  }
}

class PaginationShimmer extends StatelessWidget {
  const PaginationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminProductsTheme.spacingLg),
      decoration: AdminProductsTheme.cardDecoration,
      child: Shimmer.fromColors(
        baseColor: AdminProductsTheme.surfaceSecondary,
        highlightColor: AdminProductsTheme.surface,
        child: Column(
          children: [
            // Page info
            Container(
              width: 100,
              height: 24,
              decoration: BoxDecoration(
                color: AdminProductsTheme.surface,
                borderRadius: BorderRadius.circular(
                  AdminProductsTheme.radiusSm,
                ),
              ),
            ),
            const SizedBox(height: AdminProductsTheme.spacingMd),

            // Pagination controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusSm,
                    ),
                  ),
                ),
                const SizedBox(width: AdminProductsTheme.spacingSm),
                ...List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AdminProductsTheme.surface,
                        borderRadius: BorderRadius.circular(
                          AdminProductsTheme.radiusSm,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AdminProductsTheme.spacingSm),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusSm,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsSummaryShimmer extends StatelessWidget {
  const ResultsSummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminProductsTheme.spacingLg,
        vertical: AdminProductsTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AdminProductsTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusMd),
        border: Border.all(color: AdminProductsTheme.border),
      ),
      child: Shimmer.fromColors(
        baseColor: AdminProductsTheme.border,
        highlightColor: AdminProductsTheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusSm,
                    ),
                  ),
                ),
                const SizedBox(width: AdminProductsTheme.spacingMd),
                Container(
                  width: 180,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusSm,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AdminProductsTheme.surface,
                borderRadius: BorderRadius.circular(
                  AdminProductsTheme.radiusSm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
