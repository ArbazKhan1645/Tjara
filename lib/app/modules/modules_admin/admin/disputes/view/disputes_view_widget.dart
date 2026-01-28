import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/disputes/view/content.dart';
import 'package:tjara/app/modules/modules_admin/admin/disputes/view/header.dart';

import 'package:tjara/app/services/dashbopard_services/disputes_service.dart';

class DisputesViewWidget extends StatelessWidget {
  final bool isAppBarExpanded;
  final AdminDisputesService adminDisputesService;

  const DisputesViewWidget({
    super.key,
    required this.isAppBarExpanded,
    required this.adminDisputesService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          AdminSliverAppBarWidget(
            title: 'Disputes Management',
            isAppBarExpanded: isAppBarExpanded,
            actions: const [AdminAppBarActions()],
          ),

          SliverToBoxAdapter(
            child: Stack(
              children: [
                AdminHeaderAnimatedBackgroundWidget(
                  isAppBarExpanded: isAppBarExpanded,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      DisputesHeaderWidget(
                        service: adminDisputesService,
                        isUserSpecific: Get.arguments != null,
                      ),

                      const SizedBox(height: 30),

                      DisputesContentWidget(service: adminDisputesService),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
