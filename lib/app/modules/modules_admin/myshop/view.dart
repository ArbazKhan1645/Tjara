// shop_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/modules/modules_admin/myshop/controller.dart';
import 'package:tjara/app/modules/modules_admin/myshop/info_tab.dart';
import 'package:tjara/app/modules/modules_admin/myshop/shipping.dart';
import 'package:tjara/app/modules/modules_admin/myshop/shop_shimmer.dart';

class MyShopScreen extends StatelessWidget {
  const MyShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MyShopController controller = Get.put(MyShopController());
    PreferredSizeWidget buildAppBar() {
      return AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with balance and profile
            Container(
              decoration: const BoxDecoration(color: Colors.teal),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Section
                    Row(
                      children: [
                        Obx(() {
                          final shop = controller.shop.value;
                          return CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                shop?.thumbnail?.message?.url != null
                                    ? NetworkImage(
                                      shop!.thumbnail!.message!.url!,
                                    )
                                    : null,
                            child:
                                shop?.thumbnail?.message?.url == null
                                    ? const Icon(
                                      Icons.store,
                                      size: 30,
                                      color: Color(0xFFF97316),
                                    )
                                    : null,
                          );
                        }),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() {
                                if (controller.isLoading) {
                                  return Container(
                                    height: 20,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                }
                                return Text(
                                  controller.shop.value?.name ?? 'Shop Name',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.teal,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Obx(
                                      () => Text(
                                        controller.shop.value?.status
                                                ?.toUpperCase() ??
                                            'ACTIVE',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Obx(() {
                              if (controller.isLoading) {
                                return Container(
                                  height: 20,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }
                              return Text(
                                '\$${controller.shop.value?.balance ?? 0}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: controller.tabController,
                labelColor: Colors.teal,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.teal,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline), text: 'Shop Info'),
                  Tab(
                    icon: Icon(Icons.local_shipping_outlined),
                    text: 'Shipping Settings',
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: Obx(() {
                if (controller.hasError) {
                  return _buildErrorWidget(controller);
                }

                if (controller.isLoading) {
                  return const ShopShimmer();
                }

                return TabBarView(
                  controller: controller.tabController,
                  children: const [ShopInfoTab(), ShippingSettingsTab()],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(MyShopController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.retryFetch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
