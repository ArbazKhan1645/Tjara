import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/core/widgets/gardient_button_with_left_arrow_and_text.dart';
import 'package:tjara/app/modules/modules_admin/services_admin/insert/insert_service.dart';
import 'package:tjara/app/modules/modules_admin/services_admin/view/services_list_widget.dart';
import 'package:tjara/app/services/dashbopard_services/services_service.dart';

class ServicesViewWidget extends StatelessWidget {
  final bool isAppBarExpanded;
  final ServicesService adminProductsService;

  const ServicesViewWidget({
    super.key,
    required this.isAppBarExpanded,
    required this.adminProductsService,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => adminProductsService.refreshData(),
      child: CustomScrollView(
        slivers: [
          AdminSliverAppBarWidget(
            title: 'Dashboard',
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 12),
                      _buildSearchSection(context),
                      const SizedBox(height: 16),
                      ServicesContextsList(
                        adminProductsService: adminProductsService,
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Services',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            Obx(
              () => Text(
                '${adminProductsService.totalItems.value} services',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GradientButtonWithLeftArrowAndText(
                label: 'Add New Service',
                icon: Icons.add_circle_outline,
                onPressed: () {
                  Get.to(() => const InsertServiceScreen())?.then((result) {
                    adminProductsService.refreshData();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            _buildExportButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return Obx(
      () => PopupMenuButton<String>(
        enabled: !adminProductsService.isExporting.value,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child:
              adminProductsService.isExporting.value
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Icon(Icons.download, color: Colors.white, size: 20),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder:
            (context) => [
              PopupMenuItem<String>(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green[600], size: 20),
                    const SizedBox(width: 12),
                    const Text('Export as Excel'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.description, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 12),
                    const Text('Export as CSV'),
                  ],
                ),
              ),
            ],
        onSelected: (value) {
          if (value == 'excel') {
            adminProductsService.exportData(context: context);
          } else if (value == 'csv') {
            adminProductsService.saveCsv(context: context);
          }
        },
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Search Services',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSearchField()),
              const SizedBox(width: 12),
              _buildSearchButton(),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => _buildSearchStatus()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: TextField(
        controller: adminProductsService.searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, category, or provider...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(
            Icons.search_outlined,
            color: Colors.grey[500],
            size: 20,
          ),
          suffixIcon: Obx(
            () =>
                adminProductsService.searchQuery.value.isNotEmpty
                    ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[500],
                        size: 18,
                      ),
                      onPressed: adminProductsService.clearSearch,
                    )
                    : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed:
              adminProductsService.isSearching.value
                  ? null
                  : () {
                    if (adminProductsService.searchController.text.isNotEmpty) {
                      adminProductsService.searchServices(
                        query:
                            adminProductsService.searchController.text.trim(),
                      );
                    }
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9488),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey[300],
          ),
          child:
              adminProductsService.isSearching.value
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Icon(Icons.search, size: 18),
        ),
      ),
    );
  }

  Widget _buildSearchStatus() {
    return adminProductsService.searchQuery.value.isNotEmpty
        ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 14,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                'Searching: "${adminProductsService.searchQuery.value}"',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: adminProductsService.clearSearch,
                child: Icon(Icons.close, size: 14, color: Colors.blue.shade700),
              ),
            ],
          ),
        )
        : const SizedBox.shrink();
  }
}
