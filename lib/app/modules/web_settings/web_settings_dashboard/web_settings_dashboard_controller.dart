import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/modules/web_settings/web_settings_dashboard/web_settings_dashboard_service.dart';

class WebSettingsDashboardController extends GetxController {
  // Loading states
  var isLoading = true.obs;
  var isSaving = false.obs;
  var isUploadingLogo = false.obs;

  // Error message
  var errorMessage = Rxn<String>();

  // Settings data
  var websiteName = 'Tjara'.obs;
  var websiteStatus = 'active'.obs;
  var websiteLogoUrl = ''.obs;
  var websiteLogoId = ''.obs;

  // Server time
  var serverTime = DateTime.now().obs;
  Timer? _serverTimeTimer;

  // Status options
  final statusOptions = [
    {'value': 'active', 'label': 'Active'},
    {'value': 'inactive', 'label': 'Inactive'},
  ];

  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
    _startServerTimeTimer();
  }

  @override
  void onClose() {
    _serverTimeTimer?.cancel();
    super.onClose();
  }

  /// Start timer to update server time every second
  void _startServerTimeTimer() {
    _serverTimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      serverTime.value = serverTime.value.add(const Duration(seconds: 1));
    });
  }

  /// Fetch all data (settings + server time)
  Future<void> fetchAllData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Fetch settings and server time in parallel
      final results = await Future.wait([
        WebSettingsDashboardService.fetchSettings(),
        WebSettingsDashboardService.fetchServerTime(),
      ]);

      final settingsResponse = results[0] as DashboardSettingsResponse;
      final serverTimeResponse = results[1] as ServerTimeResponse;

      if (settingsResponse.success && settingsResponse.settings != null) {
        final s = settingsResponse.settings!;
        websiteName.value = s.websiteName;
        websiteStatus.value = s.websiteStatus;
        websiteLogoUrl.value = s.websiteLogoUrl;
        websiteLogoId.value = s.websiteLogoId;
      } else {
        errorMessage.value = settingsResponse.error;
      }

      if (serverTimeResponse.success) {
        serverTime.value = serverTimeResponse.serverTime;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh server time from API
  Future<void> refreshServerTime() async {
    try {
      final response = await WebSettingsDashboardService.fetchServerTime();
      if (response.success) {
        serverTime.value = response.serverTime;
      }
    } catch (e) {
      // Silently fail, timer will continue
    }
  }

  /// Update website status
  Future<void> updateStatus(String newStatus) async {
    if (isSaving.value) return;

    final oldStatus = websiteStatus.value;
    websiteStatus.value = newStatus;
    isSaving.value = true;

    try {
      final response = await WebSettingsDashboardService.updateSettings({
        'website_status': newStatus,
      });

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        websiteStatus.value = oldStatus;
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      websiteStatus.value = oldStatus;
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Pick and upload new logo
  Future<void> pickAndUploadLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (image == null) return;

      isUploadingLogo.value = true;

      final file = File(image.path);
      final response = await WebSettingsDashboardService.uploadMediaAndGetUrl(
        [file],
        directory: 'settings',
        width: 200,
        height: 200,
      );

      if (response.success && response.url != null) {
        // Update the settings with new logo URL
        final updateResponse = await WebSettingsDashboardService.updateSettings({
          'website_logo_url': response.url!,
          if (response.id != null) 'website_logo_id': response.id!,
        });

        if (updateResponse.success) {
          websiteLogoUrl.value = response.url!;
          if (response.id != null) {
            websiteLogoId.value = response.id!;
          }
          Get.snackbar(
            'Success',
            'Logo updated successfully',
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        } else {
          Get.snackbar(
            'Error',
            updateResponse.message,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.error ?? 'Failed to upload logo',
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick/upload image: $e',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isUploadingLogo.value = false;
    }
  }

  /// Get formatted server time string
  String get formattedServerTime {
    final time = serverTime.value;
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $period';
  }

  /// Get formatted server date string
  String get formattedServerDate {
    final time = serverTime.value;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return '${days[time.weekday % 7]}, ${months[time.month - 1]} ${time.day}, ${time.year}';
  }
}
