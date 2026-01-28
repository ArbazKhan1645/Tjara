import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/models/products/products_model.dart';

import 'package:tjara/app/modules/modules_customer/app_home/widgets/home_products_grid.dart';

class CommonProductGrid extends StatefulWidget {
  final List<ProductDatum> products; // Pass products directly as a parameter
  final bool isLoading; // Optional: To show shimmer effect while loading

  const CommonProductGrid({
    super.key,
    required this.products,
    this.isLoading = false,
  });

  @override
  State<CommonProductGrid> createState() => _CommonProductGridState();
}

class _CommonProductGridState extends State<CommonProductGrid>
    with AutomaticKeepAliveClientMixin {
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageStorage(
      bucket: _bucket,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: MasonryGridView.count(
          key: PageStorageKey<String>(
            'productGridKeycommon_${widget.products.length}',
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10,
          itemCount: widget.isLoading ? 6 : widget.products.length,
          itemBuilder: (context, index) {
            if (widget.isLoading) {
              return _buildShimmerCard();
            }

            if (widget.products.isEmpty) {
              return const Center(child: Text('No products available'));
            }

            final product = widget.products[index];
            return SizedBox(
              height: 320,
              child: ProductCard(
                key: PageStorageKey('product_${product.id}'),
                product: product,
                index: index,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
