import 'package:flutter/material.dart';
import '../../../core/widgets/base.dart';
import '../widgets/categories.dart';
import '../widgets/catnavbar.dart';
import '../widgets/notice_promotion.dart';
import '../widgets/prodnavbar.dart';
import '../widgets/products_grid.dart';
import '../widgets/super_deals.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return CommonBaseBodyScreen(scrollController: scrollController, screens: [
      CategoryNavBar(),
      // PromoBanner(),
      SafePaymentButton(),
      CategorySection(),
      SuperDealsWidget(),
      ProductNavBar(),
      ProductGrid(),
      // OfferBannerWidget(),
      // JobSearchBox(),
      // ServicesScreen(),
      // ContestScreen(),
      // SizedBox(height: 150),
    ]);
  }
}
