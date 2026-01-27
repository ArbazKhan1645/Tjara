// ignore_for_file: deprecated_member_use, empty_catches, avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';
import 'package:tjara/app/modules/home/views/product.dart';

class RelatedProductGrid extends StatefulWidget {
  const RelatedProductGrid({
    super.key,
    this.search = '',
    this.isshownfromcategories = false,
    this.isdealsection = false,
  });
  final String search;
  final isshownfromcategories;
  final isdealsection;

  @override
  State<RelatedProductGrid> createState() => _RelatedProductGridState();
}

class _RelatedProductGridState extends State<RelatedProductGrid> {
  late Future<List<ProductDatum>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchRelatedProducts();
  }

  @override
  void didUpdateWidget(RelatedProductGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.search != widget.search) {
      _productsFuture = _fetchRelatedProducts();
    }
  }

  Future<List<ProductDatum>> _fetchRelatedProducts() async {
    try {
      final controller = Get.find<HomeController>();
      final result = await controller.searchRelatedProducts(
        widget.search,
        isCategoryUUID: widget.isshownfromcategories,
        isDealsection: widget.isdealsection,
      );
      final products = result.products?.data ?? [];

      // Filter out products whose name matches the search parameter
      return products
          .where(
            (product) =>
                product.name?.toLowerCase() != widget.search.toLowerCase(),
          )
          .toList();
    } catch (e) {
      // Handle errors here to avoid crashing
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductDatum>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildProductGrid(isLoading: true);
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('No related products found.')),
          );
        }

        return _buildProductGrid(products: products);
      },
    );
  }

  Widget _buildProductGrid({
    List<ProductDatum>? products,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 10,
        itemCount: isLoading ? 6 : products!.length,
        itemBuilder: (context, index) {
          if (isLoading) {
            return const ShimmerProductCard();
          }

          final product = products![index];
          return TemuProductCard(
            isshownfromcategories: widget.isshownfromcategories,
            key: ValueKey('product_${products[index].id}'),
            product: products[index],
          );
        },
      ),
    );
  }
}

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 200,
        width: double.infinity,
      ),
    );
  }
}
