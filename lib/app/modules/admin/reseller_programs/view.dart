// screens/reseller_program_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/resseller_programs_my/model.dart';
import 'package:tjara/app/modules/admin/reseller_programs/analytics.dart';
import 'package:tjara/app/modules/admin/reseller_programs/controller.dart';
import 'package:tjara/app/modules/admin/reseller_programs/qr.dart';

class ResellerProgramScreen extends StatelessWidget {
  const ResellerProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ResellerController controller = Get.put(ResellerController());
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
                child: CircularProgressIndicator(color: Color(0xFFFFFFFF)),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QRRewardsWidget(
                    qrData:
                        '\$${controller.resellerProgram.value?.referralCode ?? 0}',
                    statusText: 'Active',
                    balanceAmount:
                        '\$${controller.resellerProgram.value?.balance ?? 0}',
                  ),
                  const ResellerAnalyticsWidget(),
                  // Bonus and Commission Cards
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _buildBonusCard(
                  //         'Available Bonus',
                  //         '\$${controller.resellerProgram.value?.balance ?? 249.87}',
                  //         const Color(0xFFE91E63),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: _buildBonusCard(
                  //         'Pending Bonus',
                  //         '\$130',
                  //         const Color(0xFFE91E63),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 12),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _buildBonusCard(
                  //         'Available Commission',
                  //         '\$0',
                  //         const Color(0xFF4CAF50),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: _buildBonusCard(
                  //         'Pending Commission',
                  //         '\$0',
                  //         const Color(0xFF4CAF50),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 24),

                  // Share & Invite Section
                  _buildShareInviteSection(controller),
                  const SizedBox(height: 24),

                  // My Team Section
                  _buildMyTeamSection(controller),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBonusCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareInviteSection(ResellerController controller) {
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
          const Text(
            'Share & Invite',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D9488),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Share the link below with your friends and family to earn commission on their purchases.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Referral Link
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'https://tjara.com?invited_by=${controller.resellerProgram.value?.referralCode ?? 'pbKcWogwRy'}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            'https://tjara.com?invited_by=${controller.resellerProgram.value?.referralCode ?? 'pbKcWogwRy'}',
                      ),
                    );
                    controller.copyLinkToClipboard('');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Or, Share the code below with your friends and family to earn commission on their purchases.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Referral Code
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.resellerProgram.value?.referralCode ??
                        'pbKcWogwRy',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            controller.resellerProgram.value?.referralCode ??
                            'pbKcWogwRy',
                      ),
                    );
                    controller.copyToClipboard('');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTeamSection(ResellerController controller) {
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D9488),
                ),
              ),
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
                  child: CircularProgressIndicator(color: Color(0xFFE91E63)),
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
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 200, // Fixed width for first column
                                child: Text(
                                  'Referral Name',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              SizedBox(
                                width: 200, // Fixed width for second column
                                child: Text(
                                  'Rewards From Member',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              SizedBox(
                                width: 150, // Fixed width for third column
                                child: Text(
                                  'Recent Order',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              SizedBox(
                                width: 150, // Fixed width for third column
                                child: Text(
                                  'membership Status',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              SizedBox(
                                width: 150, // Fixed width for third column
                                child: Text(
                                  'Registered Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...controller.referralMembers.map(
                          (member) => _buildTeamMemberRow(member),
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
                  return const Text(
                    'No recent order',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: ${member.teamMemberOrders?.first.meta.orderId ?? ''}',

                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${member.teamMemberOrders?.first.createdAt != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(member.teamMemberOrders!.first.createdAt)) : ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 4),
                    Text(
                      'Total: \$${member.teamMemberOrders?.first.orderTotal ?? ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150, // Match header column width
            child: Builder(
              builder: (context) {
                return Text(
                  member.verified_member == 'verified'
                      ? 'Verified'
                      : 'Not Verified',

                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150, // Match header column width
            child: Builder(
              builder: (context) {
                return Text(
                  member.createdAt != null
                      ? DateFormat(
                        'dd MMM yyyy',
                      ).format(DateTime.parse(member.createdAt.toString()))
                      : '',

                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
