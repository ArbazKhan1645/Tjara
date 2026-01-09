import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/core/widgets/buttons/gardient_button_with_left_arrow_and_text.dart';
import 'package:tjara/app/modules/admin/admin_contexts/insert.dart';
import 'package:tjara/app/modules/admin/admin_contexts/view/datatable.dart';
import 'package:tjara/app/modules/admin/admin_contexts/view/filters.dart';
import 'package:tjara/app/modules/admin/admin_contexts/view/pagination.dart';
import 'package:tjara/app/modules/admin/admin_contexts/view/search-bar.dart';
import 'package:tjara/app/services/dashbopard_services/contests_service.dart';

class ContestsViewWidget extends StatelessWidget {
  final bool isAppBarExpanded;
  final ContestsService contestsService;

  const ContestsViewWidget({
    super.key,
    required this.isAppBarExpanded,
    required this.contestsService,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        AdminSliverAppBarWidget(
          title: 'Contests',
          isAppBarExpanded: isAppBarExpanded,
          actions: const [],
        ),
        SliverToBoxAdapter(
          child: Stack(
            children: [
              AdminHeaderAnimatedBackgroundWidget(
                isAppBarExpanded: isAppBarExpanded,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildMainContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contests Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        GradientButtonWithLeftArrowAndText(
          label: 'Add New Contest',
          icon: Icons.add,
          onPressed: () => _handleAddContest(),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildContentHeader(),
          const Divider(height: 1),
          // _buildStatsCards(),
          const Divider(height: 1),
          _buildFiltersSection(),
          const Divider(height: 1),
          _buildDataTable(),
          const Divider(height: 1),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildContentHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Contests Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Obx(() {
            return Row(
              children: [
                if (contestsService.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => contestsService.refreshContests(),
                    tooltip: 'Refresh',
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return ContestsStatsCards(contestsService: contestsService);
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ContestsSearchBar(contestsService: contestsService),
          const SizedBox(height: 16),
          ContestsFilters(contestsService: contestsService),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return ContestsDataTable(contestsService: contestsService);
  }

  Widget _buildPagination() {
    return ContestsPagination(contestsService: contestsService);
  }

  void _handleAddContest() {
    // Navigate to add contest page
    Get.to(() => const QuizForm())?.then((val) {
      contestsService.refreshContests();
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _handleExport();
        break;
      case 'settings':
        _handleSettings();
        break;
    }
  }

  void _handleExport() {
    // Implement export functionality
    Get.snackbar(
      'Export',
      'Export functionality will be implemented',
      snackPosition: SnackPosition.TOP,
    );
  }

  void _handleSettings() {
    // Navigate to settings page
    Get.toNamed('/admin/contests/settings');
  }
}
