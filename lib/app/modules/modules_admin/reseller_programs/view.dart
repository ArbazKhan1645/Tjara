// screens/reseller_program_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/resseller_programs_my/model.dart';
import 'package:tjara/app/modules/modules_admin/reseller_programs/analytics.dart';
import 'package:tjara/app/modules/modules_admin/reseller_programs/controller.dart';
import 'package:tjara/app/modules/modules_admin/reseller_programs/qr.dart';

class ResellerProgramScreen extends StatelessWidget {
  const ResellerProgramScreen({super.key});

  // Theme Colors
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color lightTeal = Color(0xFF14B8A6);
  static const Color darkTeal = Color(0xFF0F766E);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final ResellerController controller = Get.put(ResellerController());

    return Scaffold(
      backgroundColor: surfaceColor,
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(innerBoxIsScrolled),
            ],
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoading();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _buildErrorState(controller);
          }

          return _buildContent(controller);
        }),
      ),
    );
  }

  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 150,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryTeal,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: const [AdminAppBarActionsSimple()],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: AnimatedOpacity(
          opacity: innerBoxIsScrolled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: const Text(
            'Reseller Club',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [darkTeal, primaryTeal, lightTeal],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'My Tjara Reseller Club',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Earn rewards by referring friends',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // QR Card Shimmer
          _buildShimmerCard(height: 200),
          const SizedBox(height: 16),
          // Analytics Shimmer
          _buildShimmerCard(height: 120),
          const SizedBox(height: 16),
          // Share Section Shimmer
          _buildShimmerCard(height: 250),
          const SizedBox(height: 16),
          // Team Section Shimmer
          _buildShimmerCard(height: 300),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildErrorState(ResellerController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load your reseller data',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ResellerController controller) {
    return RefreshIndicator(
      onRefresh: () async => controller.refreshData(),
      color: primaryTeal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR & Balance Card
            QRRewardsWidget(
              qrData:
                  '\$${controller.resellerProgram.value?.referralCode ?? 0}',
              statusText: 'Active',
              balanceAmount:
                  '\$${controller.resellerProgram.value?.balance ?? 0}',
            ),
            const SizedBox(height: 20),

            // Analytics Section
            const ResellerAnalyticsWidget(),
            const SizedBox(height: 20),

            // Share & Invite Section
            _buildShareInviteSection(controller),
            const SizedBox(height: 20),

            // My Team Section
            _buildMyTeamSection(controller),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildShareInviteSection(ResellerController controller) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryTeal, lightTeal],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share & Invite',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Earn commission on referrals',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Referral Link
                _buildSectionTitle('Your Referral Link', Icons.link_rounded),
                const SizedBox(height: 12),
                _buildCopyableField(
                  value:
                      'https://tjara.com?invited_by=${controller.resellerProgram.value?.referralCode ?? 'pbKcWogwRy'}',
                  onCopy: () {
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            'https://tjara.com?invited_by=${controller.resellerProgram.value?.referralCode ?? 'pbKcWogwRy'}',
                      ),
                    );
                    controller.copyLinkToClipboard('');
                  },
                ),

                const SizedBox(height: 24),

                // Referral Code
                _buildSectionTitle('Your Referral Code', Icons.qr_code_rounded),
                const SizedBox(height: 12),
                _buildCopyableField(
                  value:
                      controller.resellerProgram.value?.referralCode ??
                      'pbKcWogwRy',
                  isCode: true,
                  onCopy: () {
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryTeal),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCopyableField({
    required String value,
    required VoidCallback onCopy,
    bool isCode = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isCode ? 18 : 14,
                fontWeight: isCode ? FontWeight.w700 : FontWeight.w500,
                color: isCode ? primaryTeal : Colors.black87,
                letterSpacing: isCode ? 2 : 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: primaryTeal,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.copy_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTeamSection(ResellerController controller) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.teal],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'My Team',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Team Content
          Obx(() {
            if (controller.isLoadingReferrals.value &&
                controller.referralMembers.isEmpty) {
              return _buildTeamShimmer();
            }

            if (controller.referralMembers.isEmpty) {
              return _buildEmptyTeamState();
            }

            return _buildTeamList(controller);
          }),
        ],
      ),
    );
  }

  Widget _buildTeamShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTeamState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No team members yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your referral code to build your team',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamList(ResellerController controller) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: controller.referralMembers.length,
      itemBuilder: (context, index) {
        return _TeamMemberExpandableCard(
          member: controller.referralMembers[index],
        );
      },
    );
  }
}

class _TeamMemberExpandableCard extends StatefulWidget {
  final ResellerProgramModel member;
  const _TeamMemberExpandableCard({required this.member});

  @override
  State<_TeamMemberExpandableCard> createState() =>
      _TeamMemberExpandableCardState();
}

class _TeamMemberExpandableCardState extends State<_TeamMemberExpandableCard> {
  bool _isExpanded = false;

  static const Color _teal = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final user = member.owner.user;
    final isVerified = member.verified_member == 'verified';
    final orders = member.teamMemberOrders ?? [];
    final summary = member.transactionsSummary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Avatar + Name/Email + Status
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: _teal,
                      child: Text(
                        (user.firstName.isNotEmpty ? user.firstName[0] : 'U')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (user.email.isNotEmpty)
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (user.phone.isNotEmpty)
                            Text(
                              user.phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVerified
                                ? Icons.verified
                                : Icons.schedule,
                            size: 13,
                            color: isVerified
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isVerified ? 'Active' : 'Pending',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isVerified
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Row 2: Info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip(
                      Icons.schedule,
                      'Pending: \$${summary?.pendingAmount.toStringAsFixed(2) ?? '0'}',
                      Colors.orange,
                    ),
                    _infoChip(
                      Icons.check_circle,
                      'Available: \$${summary?.availableAmount.toStringAsFixed(2) ?? member.balance.toStringAsFixed(2)}',
                      Colors.green,
                    ),
                    if (orders.isNotEmpty)
                      _infoChip(
                        Icons.receipt_long,
                        'Order #${orders.first.meta.orderId ?? '-'}',
                        _teal,
                      ),
                    _infoChip(
                      Icons.calendar_today,
                      member.createdAt != null
                          ? DateFormat('dd MMM, yyyy').format(
                              DateTime.parse(member.createdAt!))
                          : '-',
                      Colors.grey[600]!,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Expand/Collapse button
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _teal.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isExpanded ? 'Hide Details' : 'Show Details',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _teal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: _teal,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expanded details
          if (_isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent Orders
                  _detailSectionHeader(Icons.receipt_long, 'Recent Orders'),
                  const SizedBox(height: 10),
                  if (orders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    )
                  else
                    ...orders.map((order) => _buildOrderItem(order)),

                  const SizedBox(height: 20),

                  // Rewards Summary & Member Info side by side on wide, stacked on narrow
                  _detailSectionHeader(Icons.monetization_on, 'Rewards Summary'),
                  const SizedBox(height: 10),
                  _buildRewardsSummaryCard(member, summary),

                  const SizedBox(height: 20),

                  _detailSectionHeader(Icons.person, 'Member Information'),
                  const SizedBox(height: 10),
                  _buildMemberInfoCard(member, user),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _teal),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(TeamMemberOrder order) {
    final statusColor = _getOrderStatusColor(order.status);
    final commission = order.meta.referralEarnings;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order ID : ${order.meta.orderId ?? '-'}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _teal,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.capitalizeFirst ?? order.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (commission != null && commission.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Referral Commission: \$$commission',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Order Date : ${_formatOrderDate(order.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Order Total : \$${order.orderTotal}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSummaryCard(
    ResellerProgramModel member,
    TransactionsSummary? summary,
  ) {
    final available = summary?.availableAmount ?? member.balance;
    final pending = summary?.pendingAmount ?? 0;
    final total = summary?.totalAmount ?? (available + pending);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _rewardRow('Available Rewards', '\$${available.toStringAsFixed(2)}', Colors.green),
          Divider(height: 20, color: Colors.grey.shade200),
          _rewardRow('Pending Rewards', '\$${pending.toStringAsFixed(2)}', Colors.orange),
          Divider(height: 20, color: Colors.grey.shade200),
          _rewardRow('Total Rewards', '\$${total.toStringAsFixed(2)}', const Color(0xFF1A202C), bold: true),
        ],
      ),
    );
  }

  Widget _rewardRow(String label, String value, Color valueColor, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberInfoCard(ResellerProgramModel member, User user) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _memberInfoRow(
            'Joined',
            member.createdAt != null
                ? DateFormat('dd MMM, yyyy').format(DateTime.parse(member.createdAt!))
                : '-',
          ),
          const SizedBox(height: 10),
          _memberInfoRow(
            'Status',
            member.verified_member == 'verified' ? 'Active Member' : 'Pending',
          ),
          const SizedBox(height: 10),
          _memberInfoRow('Contact', user.phone.isNotEmpty ? user.phone : '-'),
        ],
      ),
    );
  }

  Widget _memberInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A202C),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatOrderDate(String dateStr) {
    try {
      return DateFormat('dd MMM, yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }
}
