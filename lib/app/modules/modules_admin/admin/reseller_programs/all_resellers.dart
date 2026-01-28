// screens/reseller_program_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/resseller_programs_my/model.dart';
import 'package:tjara/app/modules/modules_admin/admin/reseller_programs/controller.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/const/appColors.dart';

class AllResellerProgramScreen extends StatelessWidget {
  const AllResellerProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AllResellerController controller = Get.put(AllResellerController());
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),

          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: LinearProgressIndicator(color: Color(0xFFF97316)),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load data',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.refreshData(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Team Section
                  _buildMyTeamSection(controller),

                  // Pagination info and controls
                  const SizedBox(height: 16),
                  // _buildPaginationControls(controller),÷
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMyTeamSection(AllResellerController controller) {
    final ScrollController horizontalScrollController = ScrollController();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with pagination info
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Team',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              // Obx(
              //   () => Text(
              //     controller.getPaginationInfo(),
              //     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 20),

          // Horizontal scrollable table
          Obx(() {
            if (controller.isLoadingReferrals.value &&
                controller.referralMembers.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFF97316)),
                ),
              );
            }

            if (controller.referralMembers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No referral members yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share your referral code to invite members',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Table Header (scrolls horizontally with content)

                // Team Members List (scrolls horizontally with header)
                Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 200, // Fixed width for first column
                                child: Text(
                                  'Referral Name',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: appcolors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 200, // Fixed width for second column
                                child: Text(
                                  'Rewards From Member',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: appcolors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 150, // Fixed width for third column
                                child: Text(
                                  'Recent Order',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: appcolors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...controller.referralMembers.map(
                          (member) => _buildTeamMemberRow(member),
                        ),

                        // Loading more indicator
                        if (controller.isLoadingMore.value)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFE91E63),
                              ),
                            ),
                          ),

                        // Load more button (alternative to infinite scroll)
                        if (controller.hasMorePages.value &&
                            !controller.isLoadingMore.value)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: OutlinedButton(
                                onPressed:
                                    () => controller.loadMoreReferralMembers(),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFE91E63),
                                  ),
                                ),
                                child: const Text(
                                  'Load More',
                                  style: TextStyle(color: Color(0xFFE91E63)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTeamMemberRow(ResellerProgramModel member) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 200, // Match header column width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${member.owner.user.firstName} ${member.owner.user.lastName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (member.owner.user.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    member.owner.user.email,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
                if (member.owner.user.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    member.owner.user.phone,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 200, // Match header column width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pending : \$${member.status}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 12,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Available : \$${member.balance}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150, // Match header column width
            child: Builder(
              builder: (context) {
                if (member.teamMemberOrders == null ||
                    member.teamMemberOrders!.isEmpty) {
                  return Text(
                    'No recent order',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  );
                }
                return Text(
                  'Order ID: ${member.teamMemberOrders?.first.id ?? ''}',

                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(AllResellerController controller) {
    return Obx(() {
      if (controller.totalPages.value <= 1) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            IconButton(
              onPressed:
                  controller.currentPage.value > 1
                      ? () =>
                          controller.loadPage(controller.currentPage.value - 1)
                      : null,
              icon: const Icon(Icons.arrow_back_ios),
              color:
                  controller.currentPage.value > 1
                      ? const Color(0xFFE91E63)
                      : Colors.grey,
            ),

            // Page numbers
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageNumbers(controller),
              ),
            ),

            // Next button
            IconButton(
              onPressed:
                  controller.hasMorePages.value
                      ? () =>
                          controller.loadPage(controller.currentPage.value + 1)
                      : null,
              icon: const Icon(Icons.arrow_forward_ios),
              color:
                  controller.hasMorePages.value
                      ? const Color(0xFFE91E63)
                      : Colors.grey,
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildPageNumbers(AllResellerController controller) {
    final List<Widget> pageNumbers = [];
    final int currentPage = controller.currentPage.value;
    final int totalPages = controller.totalPages.value;

    // Show max 5 page numbers
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (currentPage + 2).clamp(1, totalPages);

    if (endPage - startPage < 4) {
      if (startPage == 1) {
        endPage = (startPage + 4).clamp(1, totalPages);
      } else {
        startPage = (endPage - 4).clamp(1, totalPages);
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageNumbers.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => controller.loadPage(i),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    i == currentPage
                        ? const Color(0xFFE91E63)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      i == currentPage
                          ? const Color(0xFFE91E63)
                          : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  i.toString(),
                  style: TextStyle(
                    color: i == currentPage ? Colors.white : Colors.grey[700],
                    fontWeight:
                        i == currentPage ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return pageNumbers;
  }
}
