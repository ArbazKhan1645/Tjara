import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';
import 'package:tjara/app/modules/modules_admin/admin/surveys/add_screen.dart';
import 'package:tjara/app/modules/modules_admin/admin/surveys/controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/surveys/model.dart';

class SurveyListScreen extends GetView<SurveyController> {
  const SurveyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SurveyController>(
      init: SurveyController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AdminTheme.bgColor,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildSearchAndFilters(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.surveys.isEmpty) {
                    return _buildShimmerLoading();
                  }
                  if (controller.surveys.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildSurveyList();
                }),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToAddEdit(null),
            backgroundColor: AdminTheme.primaryColor,
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            label: const Text(
              'Create Survey',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            elevation: 2,
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AdminTheme.primaryColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      title: Row(
        children: [
          const Text(
            'Surveys',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final total = controller.paginationMeta.value?.total ?? 0;
            if (total == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
          onPressed: () => controller.fetchSurveys(isRefresh: true),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AdminTheme.borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          SizedBox(
            height: 40,
            child: TextField(
              onChanged: (value) {
                controller.searchQuery.value = value;
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (controller.searchQuery.value == value) {
                    controller.searchSurveys(value);
                  }
                });
              },
              style: const TextStyle(
                fontSize: 13,
                color: AdminTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search surveys...',
                hintStyle: const TextStyle(
                  color: AdminTheme.textMuted,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AdminTheme.textMuted,
                  size: 18,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                filled: true,
                fillColor: AdminTheme.bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AdminTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AdminTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AdminTheme.primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Status filters
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.statusOptions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = controller.statusOptions[index];
                return Obx(() {
                  final isSelected =
                      controller.selectedStatus.value == status ||
                      (controller.selectedStatus.value.isEmpty &&
                          status == 'all');
                  return _buildFilterChip(status, isSelected);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status, bool isSelected) {
    final statusLabels = {
      'all': 'All',
      'draft': 'Draft',
      'published': 'Published',
      'closed': 'Closed',
    };

    final statusColors = {
      'all': AdminTheme.primaryColor,
      'draft': AdminTheme.warningColor,
      'published': AdminTheme.successColor,
      'closed': AdminTheme.errorColor,
    };

    final color = statusColors[status] ?? AdminTheme.textMuted;

    return GestureDetector(
      onTap: () => controller.filterByStatus(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AdminTheme.borderColor,
          ),
        ),
        child: Text(
          statusLabels[status] ?? status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AdminTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200 &&
            controller.hasMorePages.value &&
            !controller.isLoadingMore.value) {
          controller.loadMore();
        }
        return false;
      },
      child: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
          itemCount:
              controller.surveys.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.surveys.length) {
              return _buildLoadingMore();
            }
            final survey = controller.surveys[index];
            return _SurveyCard(
              survey: survey,
              onTap: () => _navigateToAddEdit(survey),
              onEdit: () => _navigateToAddEdit(survey),
              onDelete: () => controller.deleteSurvey(survey.id, survey.title),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AdminTheme.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AdminTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.poll_outlined,
                size: 48,
                color: AdminTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final hasFilters =
                  controller.searchQuery.value.isNotEmpty ||
                  (controller.selectedStatus.value.isNotEmpty &&
                      controller.selectedStatus.value != 'all');
              return Column(
                children: [
                  Text(
                    hasFilters ? 'No results found' : 'No surveys yet',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AdminTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasFilters
                        ? 'Try adjusting your filters'
                        : 'Create your first survey to get started',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AdminTheme.textMuted,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _navigateToAddEdit(SurveyModel? survey) {
    Get.to(
      () => AddEditSurveyScreen(existingSurvey: survey),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}

// ─── SURVEY CARD ───
class _SurveyCard extends StatelessWidget {
  final SurveyModel survey;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SurveyCard({
    required this.survey,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (survey.thumbnail != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      survey.thumbnail!.optimizedMediaUrl ??
                          survey.thumbnail!.url,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, _, _) => Container(
                            width: double.infinity,
                            height: 150,
                            color: AdminTheme.bgColor,
                            child: const Icon(
                              Icons.image_outlined,
                              size: 36,
                              color: AdminTheme.textMuted,
                            ),
                          ),
                    ),
                    // Status badge on image
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _statusBadge(survey.status),
                    ),
                  ],
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Menu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              survey.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AdminTheme.textPrimary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (survey.titleAr.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                survey.titleAr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AdminTheme.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (survey.thumbnail == null) _statusBadge(survey.status),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: const Icon(
                          Icons.more_vert,
                          size: 18,
                          color: AdminTheme.textMuted,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                height: 38,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: AdminTheme.primaryColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Edit',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                height: 38,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: AdminTheme.errorColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AdminTheme.errorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
                  // Description
                  if (survey.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _stripHtml(survey.description),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AdminTheme.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AdminTheme.borderColor),
                  const SizedBox(height: 10),
                  // Bottom stats row
                  Row(
                    children: [
                      _statItem(
                        Icons.quiz_outlined,
                        '${survey.questions.length} Questions',
                        AdminTheme.primaryColor,
                      ),
                      const SizedBox(width: 14),
                      if (survey.startTime != null)
                        _statItem(
                          Icons.schedule,
                          _formatDate(survey.startTime!),
                          AdminTheme.accentColor,
                        ),
                      const Spacer(),
                      if (survey.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AdminTheme.warningColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: AdminTheme.warningColor,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Featured',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AdminTheme.warningColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final colors = {
      'draft': AdminTheme.warningColor,
      'published': AdminTheme.successColor,
      'closed': AdminTheme.errorColor,
    };
    final color = colors[status] ?? AdminTheme.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
