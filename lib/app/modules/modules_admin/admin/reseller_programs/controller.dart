// controllers/reseller_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/resseller_programs_my/model.dart';
import 'package:tjara/app/modules/modules_admin/admin/reseller_programs/service.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class ResellerController extends GetxController {
  final ResellerService _resellerService = ResellerService();

  // Observable variables
  var isLoading = false.obs;
  var isLoadingReferrals = false.obs;
  var resellerProgram = Rxn<ResellerProgramModel>();
  var referralMembers = <ResellerProgramModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkUserId();
    fetchResellerProgram();
  }

  void checkUserId() {
    final args = Get.arguments;

    if (args != null && args is Map && args.containsKey('userId')) {
      final id = args['userId'];
      userIdArguement.value = id;
    } else {
      // Handle null case if needed
      userIdArguement.value = '';
    }
  }

  RxString userIdArguement = RxString('');

  Future<void> fetchResellerProgram() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId =
          userIdArguement.value.isNotEmpty
              ? userIdArguement.value
              : AuthService.instance.authCustomer?.user?.id ??
                  '121d6d13-a26f-49ff-8786-a3b203dc3068';

      final program = await _resellerService.getResellerProgram(userId);
      resellerProgram.value = program;

      print(program.id);

      // After getting the reseller program, fetch referral members
      if (program.id.isNotEmpty) {
        await fetchReferralMembers(program.id);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load reseller program data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReferralMembers(String resellerProgramId) async {
    try {
      isLoadingReferrals.value = true;

      final members = await _resellerService.getReferralMembers(
        resellerProgramId,
      );
      referralMembers.value = members;
    } catch (e) {
      print('Error fetching referral members: $e');
      // Don't show error for referral members if main data loads successfully
    } finally {
      isLoadingReferrals.value = false;
    }
  }

  void copyToClipboard(String text) {
    // Copy functionality would be implemented here
    Get.snackbar(
      'Copied',
      'Referral code copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void copyLinkToClipboard(String link) {
    // Copy functionality would be implemented here
    Get.snackbar(
      'Copied',
      'Referral link copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Helper method to get display name for referral member
  String getReferralMemberName(ResellerProgramModel member) {
    return '${member.owner.user.firstName} ${member.owner.user.lastName}'
        .trim();
  }

  // Helper method to get display email for referral member
  String getReferralMemberEmail(ResellerProgramModel member) {
    return member.owner.user.email;
  }

  // Helper method to get display phone for referral member
  String getReferralMemberPhone(ResellerProgramModel member) {
    return member.owner.user.phone;
  }

  // Helper method to calculate pending rewards (you can implement your logic here)
  double getPendingRewards(ResellerProgramModel member) {
    // Implement your logic to calculate pending rewards
    return 0.0;
  }

  // Helper method to calculate available rewards (you can implement your logic here)
  double getAvailableRewards(ResellerProgramModel member) {
    // Implement your logic to calculate available rewards
    return member.balance;
  }

  // Helper method to check if member has orders
  bool memberHasOrders(ResellerProgramModel member) {
    // Implement your logic to check if member has orders
    return member.owner.user.shop != null;
  }

  // Helper method to get order ID (implement your logic)
  String? getMemberOrderId(ResellerProgramModel member) {
    // Implement your logic to get order ID
    return memberHasOrders(member) ? '1351' : null;
  }

  void refreshData() {
    print(AuthService.instance.authCustomer?.user?.id);
    fetchResellerProgram();
  }
}

class AllResellerController extends GetxController {
  final ResellerService _resellerService = ResellerService();

  // Observable variables
  var isLoading = false.obs;
  var isLoadingReferrals = false.obs;
  var isLoadingMore = false.obs; // For pagination loading
  var resellerProgram = Rxn<ResellerProgramModel>();
  var referralMembers = <ResellerProgramModel>[].obs;
  var errorMessage = ''.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var perPage = 15.obs;
  var totalPages = 1.obs;
  var totalMembers = 0.obs;
  var hasMorePages = false.obs;

  // Scroll controller for pagination
  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    fetchResellerProgram();
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  // Scroll listener for infinite scroll pagination
  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (hasMorePages.value && !isLoadingMore.value) {
        loadMoreReferralMembers();
      }
    }
  }

  Future<void> fetchResellerProgram() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await fetchReferralMembers(refresh: true);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load reseller program data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReferralMembers({bool refresh = false}) async {
    try {
      if (refresh) {
        isLoadingReferrals.value = true;
        currentPage.value = 1;
        referralMembers.clear();
      }

      final response = await _resellerService.getAllReferralMembersPaginated(
        page: currentPage.value,
        perPage: perPage.value,
      );

      if (refresh) {
        referralMembers.value = response.data;
      } else {
        referralMembers.addAll(response.data);
      }

      // Update pagination info
      currentPage.value = response.currentPage;
      totalPages.value = response.lastPage;
      totalMembers.value = response.total;
      hasMorePages.value = response.hasMorePages;
    } catch (e) {
      print('Error fetching referral members: $e');
      if (refresh) {
        errorMessage.value = e.toString();
      }
    } finally {
      if (refresh) {
        isLoadingReferrals.value = false;
      }
    }
  }

  Future<void> loadMoreReferralMembers() async {
    if (!hasMorePages.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await _resellerService.getAllReferralMembersPaginated(
        page: currentPage.value,
        perPage: perPage.value,
      );

      referralMembers.addAll(response.data);
      hasMorePages.value = response.hasMorePages;
    } catch (e) {
      print('Error loading more referral members: $e');
      currentPage.value--; // Revert page increment on error
      Get.snackbar(
        'Error',
        'Failed to load more members',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Load specific page (for manual pagination)
  Future<void> loadPage(int page) async {
    try {
      isLoadingReferrals.value = true;
      currentPage.value = page;

      final response = await _resellerService.getAllReferralMembersPaginated(
        page: page,
        perPage: perPage.value,
      );

      referralMembers.value = response.data;
      currentPage.value = response.currentPage;
      totalPages.value = response.lastPage;
      totalMembers.value = response.total;
      hasMorePages.value = response.hasMorePages;
    } catch (e) {
      print('Error loading page $page: $e');
      Get.snackbar(
        'Error',
        'Failed to load page $page',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingReferrals.value = false;
    }
  }

  // Change items per page
  Future<void> changePerPage(int newPerPage) async {
    perPage.value = newPerPage;
    await fetchReferralMembers(refresh: true);
  }

  // Helper method to get display name for referral member
  String getReferralMemberName(ResellerProgramModel member) {
    return '${member.owner.user.firstName} ${member.owner.user.lastName}'
        .trim();
  }

  // Helper method to get display email for referral member
  String getReferralMemberEmail(ResellerProgramModel member) {
    return member.owner.user.email;
  }

  // Helper method to get display phone for referral member
  String getReferralMemberPhone(ResellerProgramModel member) {
    return member.owner.user.phone;
  }

  // Helper method to calculate pending rewards (you can implement your logic here)
  double getPendingRewards(ResellerProgramModel member) {
    // Implement your logic to calculate pending rewards
    return 0.0;
  }

  // Helper method to calculate available rewards (you can implement your logic here)
  double getAvailableRewards(ResellerProgramModel member) {
    // Implement your logic to calculate available rewards
    return member.balance;
  }

  // Helper method to check if member has orders
  bool memberHasOrders(ResellerProgramModel member) {
    // Implement your logic to check if member has orders
    return member.owner.user.shop != null;
  }

  // Helper method to get order ID (implement your logic)
  String? getMemberOrderId(ResellerProgramModel member) {
    // Implement your logic to get order ID
    return memberHasOrders(member) ? '1351' : null;
  }

  void refreshData() {
    fetchResellerProgram();
  }

  // Get pagination info text
  String getPaginationInfo() {
    if (totalMembers.value == 0) return 'No members found';

    final start = ((currentPage.value - 1) * perPage.value) + 1;
    final end = (currentPage.value * perPage.value).clamp(
      0,
      totalMembers.value,
    );

    return 'Showing $start-$end of ${totalMembers.value} members';
  }
}
