import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/controller/job_attributes_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/view/insert_job.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/widgets/jobs_admin_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/widgets/jobs_shimmer.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/dashbopard_services/adminJobs_service.dart';
import 'package:http/http.dart' as http;

class AdminJobsList extends StatelessWidget {
  final AdminJobsService adminProductsService;

  const AdminJobsList({super.key, required this.adminProductsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Column(
          children: [
            _buildContent(),
            if (!adminProductsService.isLoading.value &&
                adminProductsService.adminProducts!.isNotEmpty)
              _JobsPagination(adminProductsService: adminProductsService),
          ],
        ),
      );
    });
  }

  Widget _buildContent() {
    // Loading state - show shimmer
    if (adminProductsService.isLoading.value) {
      return const JobsTableShimmer(rowCount: 6);
    }

    // Empty state
    if (adminProductsService.adminProducts == null ||
        adminProductsService.adminProducts!.isEmpty) {
      return const _JobsEmptyState();
    }

    // Jobs table
    return Container(
      decoration: JobsAdminTheme.cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(JobsAdminTheme.radiusMd),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table Header
              const _JobsTableHeader(),

              // Table Rows
              ...adminProductsService.adminProducts!.asMap().entries.map(
                (entry) => _JobDataRow(
                  job: entry.value,
                  index: entry.key,
                  onRefresh:
                      () =>
                          adminProductsService.fetchProducts(loaderType: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Jobs Table Header
class _JobsTableHeader extends StatelessWidget {
  const _JobsTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: JobsAdminTheme.tableHeaderDecoration,
      padding: const EdgeInsets.symmetric(horizontal: JobsAdminTheme.spacingLg),
      child: const Row(
        children: [
          _HeaderCell(title: 'Job Title', width: 220),
          _HeaderCell(title: 'Salary', width: 100),
          _HeaderCell(title: 'Work Type', width: 100),
          _HeaderCell(title: 'Proposals', width: 80),
          _HeaderCell(title: 'Country', width: 120),
          _HeaderCell(title: 'Created At', width: 120),
          _HeaderCell(title: 'Status', width: 100),
          _HeaderCell(title: 'Actions', width: 100),
        ],
      ),
    );
  }
}

/// Header Cell
class _HeaderCell extends StatelessWidget {
  final String title;
  final double width;

  const _HeaderCell({required this.title, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        title.toUpperCase(),
        style: JobsAdminTheme.labelMedium.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: JobsAdminTheme.textOnPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Job Data Row
class _JobDataRow extends StatelessWidget {
  final dynamic job;
  final int index;
  final VoidCallback onRefresh;

  const _JobDataRow({
    required this.job,
    required this.index,
    required this.onRefresh,
  });

  String get _title => job.title ?? 'Untitled Job';
  String get _salary => job.salary ?? '---';
  String get _workType => job.workType ?? '---';
  String get _country => job.country?.name ?? '---';
  String get _status => job.status?.toString() ?? 'unknown';
  String? get _thumbnailUrl => job.thumbnail?.media?.cdnUrl;

  String _formatDate(DateTime? date) {
    if (date == null) return '---';
    return DateFormat('MMM d, y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: JobsAdminTheme.spacingLg),
      decoration: BoxDecoration(
        color:
            index % 2 == 0
                ? JobsAdminTheme.surface
                : JobsAdminTheme.surfaceSecondary,
        border: Border(bottom: BorderSide(color: JobsAdminTheme.borderLight)),
      ),
      child: Row(
        children: [
          // Job Title with Image
          SizedBox(
            width: 220,
            child: Row(
              children: [
                _JobAvatar(thumbnailUrl: _thumbnailUrl),
                const SizedBox(width: JobsAdminTheme.spacingMd),
                Expanded(
                  child: Text(
                    _title,
                    style: JobsAdminTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: JobsAdminTheme.accent,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Salary
          SizedBox(width: 100, child: _SalaryBadge(salary: _salary)),
          // Work Type
          SizedBox(width: 100, child: _WorkTypeBadge(workType: _workType)),
          // Proposals
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: JobsAdminTheme.spacingSm,
                vertical: JobsAdminTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: JobsAdminTheme.surfaceSecondary,
                borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
              ),
              child: Text(
                '0',
                style: JobsAdminTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Country
          SizedBox(
            width: 120,
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: JobsAdminTheme.textTertiary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _country,
                    style: JobsAdminTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Created At
          SizedBox(
            width: 120,
            child: _DateBadge(dateString: _formatDate(job.createdAt)),
          ),
          // Status
          SizedBox(width: 100, child: _StatusBadge(status: _status)),
          // Actions
          SizedBox(
            width: 100,
            child: _JobActions(job: job, onRefresh: onRefresh),
          ),
        ],
      ),
    );
  }
}

/// Job Avatar
class _JobAvatar extends StatelessWidget {
  final String? thumbnailUrl;

  const _JobAvatar({this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: JobsAdminTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: JobsAdminTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child:
            thumbnailUrl != null
                ? CachedNetworkImage(
                  imageUrl: thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildPlaceholder(),
                  errorWidget: (context, url, error) => _buildPlaceholder(),
                )
                : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: JobsAdminTheme.primaryLight,
      child: const Icon(
        Icons.work_rounded,
        color: JobsAdminTheme.primary,
        size: 18,
      ),
    );
  }
}

/// Salary Badge
class _SalaryBadge extends StatelessWidget {
  final String salary;

  const _SalaryBadge({required this.salary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: JobsAdminTheme.spacingSm,
        vertical: JobsAdminTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: JobsAdminTheme.secondaryLight,
        borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
      ),
      child: Text(
        salary,
        style: JobsAdminTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: JobsAdminTheme.secondary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Work Type Badge
class _WorkTypeBadge extends StatelessWidget {
  final String workType;

  const _WorkTypeBadge({required this.workType});

  @override
  Widget build(BuildContext context) {
    final color = JobsAdminTheme.getWorkTypeColor(workType);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: JobsAdminTheme.spacingSm,
        vertical: JobsAdminTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(JobsAdminTheme.radiusXl),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        workType,
        style: JobsAdminTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Date Badge
class _DateBadge extends StatelessWidget {
  final String dateString;

  const _DateBadge({required this.dateString});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 12,
          color: JobsAdminTheme.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          dateString,
          style: JobsAdminTheme.bodySmall.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

/// Status Badge
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = JobsAdminTheme.getStatusColor(status);
    final isActive = status.toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: JobsAdminTheme.spacingSm,
        vertical: JobsAdminTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(JobsAdminTheme.radiusXl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status.capitalizeFirst ?? status,
            style: JobsAdminTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Job Actions
class _JobActions extends StatelessWidget {
  final dynamic job;
  final VoidCallback onRefresh;

  const _JobActions({required this.job, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Button
        _ActionIconButton(
          icon: Icons.edit_rounded,
          color: JobsAdminTheme.info,
          tooltip: 'Edit',
          onTap: () {
            Get.to(const InsertJobScreen(), arguments: {'job': job})?.then((
              value,
            ) {
              final JobAttributeController controller = Get.put(
                JobAttributeController(),
              );
              controller.resetForm();
              onRefresh();
            });
          },
        ),
        const SizedBox(width: JobsAdminTheme.spacingSm),
        // Delete Button
        _ActionIconButton(
          icon: Icons.delete_rounded,
          color: JobsAdminTheme.error,
          tooltip: 'Delete',
          onTap: () => _showDeleteDialog(context),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JobsAdminTheme.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(JobsAdminTheme.spacingSm),
              decoration: BoxDecoration(
                color: JobsAdminTheme.errorLight,
                borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: JobsAdminTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: JobsAdminTheme.spacingMd),
            const Text('Delete Job', style: JobsAdminTheme.headingMedium),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this job? This action cannot be undone.',
          style: JobsAdminTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: JobsAdminTheme.bodyMedium.copyWith(
                color: JobsAdminTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(
                'https://api.libanbuy.com/api/jobs/${job.id}/delete',
              );

              final response = await http.delete(
                uri,
                headers: {
                  'Accept': 'application/json',
                  'X-Request-From': 'Application',
                  'shop-id':
                      AuthService.instance.authCustomer?.user?.shop?.shop?.id ??
                      '',
                },
              );

              if (response.statusCode == 200 ||
                  response.statusCode == 204 ||
                  response.statusCode == 201) {
                Get.back();
                Get.snackbar(
                  'Success',
                  'Job deleted successfully',
                  backgroundColor: JobsAdminTheme.success,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(JobsAdminTheme.spacingLg),
                  borderRadius: JobsAdminTheme.radiusMd,
                );
                onRefresh();
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to delete job',
                  backgroundColor: JobsAdminTheme.error,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(JobsAdminTheme.spacingLg),
                  borderRadius: JobsAdminTheme.radiusMd,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: JobsAdminTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(JobsAdminTheme.radiusMd),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Action Icon Button
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
          child: Container(
            padding: const EdgeInsets.all(JobsAdminTheme.spacingSm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}

/// Jobs Empty State
class _JobsEmptyState extends StatelessWidget {
  const _JobsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JobsAdminTheme.spacing2Xl),
      decoration: JobsAdminTheme.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(JobsAdminTheme.spacingXl),
            decoration: const BoxDecoration(
              color: JobsAdminTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.work_off_rounded,
              size: 48,
              color: JobsAdminTheme.primary,
            ),
          ),
          const SizedBox(height: JobsAdminTheme.spacingXl),
          const Text('No Jobs Found', style: JobsAdminTheme.headingMedium),
          const SizedBox(height: JobsAdminTheme.spacingSm),
          Text(
            'Click "Add Job" to create your first job posting',
            textAlign: TextAlign.center,
            style: JobsAdminTheme.bodyMedium.copyWith(
              color: JobsAdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Jobs Pagination Widget
class _JobsPagination extends StatelessWidget {
  final AdminJobsService adminProductsService;

  const _JobsPagination({required this.adminProductsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (adminProductsService.totalPages.value <= 1) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: JobsAdminTheme.spacingLg),
        padding: const EdgeInsets.all(JobsAdminTheme.spacingLg),
        decoration: JobsAdminTheme.cardDecoration,
        child: Column(
          children: [
            // Pagination info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: JobsAdminTheme.spacingMd,
                vertical: JobsAdminTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: JobsAdminTheme.primaryLight,
                borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
              ),
              child: Text(
                'Page ${adminProductsService.currentPage.value} of ${adminProductsService.totalPages.value}',
                style: JobsAdminTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: JobsAdminTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: JobsAdminTheme.spacingMd),

            // Pagination controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous
                _PaginationNavButton(
                  icon: Icons.chevron_left_rounded,
                  onTap:
                      adminProductsService.currentPage.value > 1
                          ? adminProductsService.previousPage
                          : null,
                  tooltip: 'Previous',
                ),
                const SizedBox(width: JobsAdminTheme.spacingSm),

                // Page numbers
                ...adminProductsService.visiblePageNumbers().map(
                  (page) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: JobsAdminTheme.spacingXs,
                    ),
                    child: _PageNumberButton(
                      page: page,
                      isCurrentPage:
                          page == adminProductsService.currentPage.value,
                      onTap: () => adminProductsService.goToPage(page),
                    ),
                  ),
                ),

                const SizedBox(width: JobsAdminTheme.spacingSm),

                // Next
                _PaginationNavButton(
                  icon: Icons.chevron_right_rounded,
                  onTap:
                      adminProductsService.currentPage.value <
                              adminProductsService.totalPages.value
                          ? adminProductsService.nextPage
                          : null,
                  tooltip: 'Next',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// Pagination Navigation Button
class _PaginationNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _PaginationNavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  isEnabled
                      ? JobsAdminTheme.surfaceSecondary
                      : JobsAdminTheme.surfaceSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
              border: Border.all(
                color:
                    isEnabled
                        ? JobsAdminTheme.border
                        : JobsAdminTheme.borderLight,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color:
                  isEnabled
                      ? JobsAdminTheme.textPrimary
                      : JobsAdminTheme.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Page Number Button
class _PageNumberButton extends StatelessWidget {
  final int page;
  final bool isCurrentPage;
  final VoidCallback onTap;

  const _PageNumberButton({
    required this.page,
    required this.isCurrentPage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
                isCurrentPage ? JobsAdminTheme.primary : JobsAdminTheme.surface,
            borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
            border: Border.all(
              color:
                  isCurrentPage
                      ? JobsAdminTheme.primary
                      : JobsAdminTheme.border,
            ),
            boxShadow:
                isCurrentPage
                    ? JobsAdminTheme.shadowColored(JobsAdminTheme.primary)
                    : null,
          ),
          child: Center(
            child: Text(
              page.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.w500,
                color:
                    isCurrentPage
                        ? JobsAdminTheme.textOnPrimary
                        : JobsAdminTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
