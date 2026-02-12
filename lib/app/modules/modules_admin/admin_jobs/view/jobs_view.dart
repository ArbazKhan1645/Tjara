import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/controller/job_attributes_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/view/insert_job.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/view/jobs_list_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/widgets/jobs_admin_theme.dart';
import 'package:tjara/app/services/dashbopard_services/adminJobs_service.dart';

class AdminJobsView extends StatefulWidget {
  const AdminJobsView({super.key});

  @override
  State<AdminJobsView> createState() => _AdminJobsViewState();
}

class _AdminJobsViewState extends State<AdminJobsView> {
  late AdminJobsService _adminJobsService;

  @override
  void initState() {
    super.initState();
    _adminJobsService = Get.find<AdminJobsService>();
    _adminJobsService.fetchProducts(loaderType: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JobsAdminTheme.background,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => _adminJobsService.fetchProducts(loaderType: false),
        color: JobsAdminTheme.primary,
        backgroundColor: JobsAdminTheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(JobsAdminTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              const SizedBox(height: JobsAdminTheme.spacingLg),

              // Jobs List
              AdminJobsList(adminProductsService: _adminJobsService),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: JobsAdminTheme.primary,
      foregroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [JobsAdminTheme.primary, JobsAdminTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: const [AdminAppBarActionsSimple()],
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Row(
        children: [
          Icon(Icons.work_rounded, size: 22),
          SizedBox(width: JobsAdminTheme.spacingSm),
          Text(
            'Jobs Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
      elevation: 0,
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(JobsAdminTheme.spacingLg),
      decoration: JobsAdminTheme.sectionHeaderDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(JobsAdminTheme.spacingSm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
            ),
            child: const Icon(
              Icons.business_center_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: JobsAdminTheme.spacingMd),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Listings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Manage your job postings',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: JobsAdminTheme.spacingMd,
                vertical: JobsAdminTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(JobsAdminTheme.radiusXl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.list_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_adminJobsService.adminProducts?.length ?? 0} jobs',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Get.to(const InsertJobScreen())?.then((value) {
          final JobAttributeController controller = Get.put(
            JobAttributeController(),
          );
          controller.resetForm();
          _adminJobsService.fetchProducts(loaderType: true);
        });
      },
      backgroundColor: JobsAdminTheme.accent,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Add Job',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
