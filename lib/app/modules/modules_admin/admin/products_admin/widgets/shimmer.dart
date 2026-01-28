import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductShimmerCard extends StatelessWidget {
  const ProductShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      height: 100,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Product ID
              _buildShimmerColumn(width: 80),
              const SizedBox(width: 20),
              
              // Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 30),
              
              // Product Name
              _buildShimmerColumn(width: 150),
              const SizedBox(width: 30),
              
              // Shop Name
              _buildShimmerColumn(width: 120),
              const SizedBox(width: 30),
              
              // Price
              _buildShimmerColumn(width: 80),
              const SizedBox(width: 30),
              
              // Stock
              _buildShimmerColumn(width: 60),
              const SizedBox(width: 30),
              
              // Published At
              _buildShimmerColumn(width: 100),
              const SizedBox(width: 30),
              
              // Status
              _buildShimmerColumn(width: 80),
              const SizedBox(width: 30),
              
              // Actions
              Row(
                children: [
                  _buildShimmerButton(),
                  const SizedBox(width: 8),
                  _buildShimmerButton(),
                  const SizedBox(width: 8),
                  _buildShimmerButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerColumn({required double width}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: width * 0.7,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: width,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerButton() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class ProductsShimmerList extends StatelessWidget {
  final int itemCount;
  
  const ProductsShimmerList({
    super.key, 
    this.itemCount = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: ProductShimmerCard(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search fields
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            
            // Filter buttons row
            Row(
              children: [
                _buildFilterButton(80),
                const SizedBox(width: 12),
                _buildFilterButton(100),
                const SizedBox(width: 12),
                _buildFilterButton(120),
                const SizedBox(width: 12),
                _buildFilterButton(90),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(double width) {
    return Container(
      width: width,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class PaginationShimmer extends StatelessWidget {
  const PaginationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(5, (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          )),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}