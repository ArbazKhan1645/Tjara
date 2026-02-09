import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'dart:convert';

import 'package:tjara/app/models/posts/posts_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/blogs_categories/blogs_categories.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/main.dart';

// Common Banner Controller
class BannerController extends GetxController {
  var banners = <PostModel>[].obs;
  var isLoading = false.obs;
  var isDeleting = false.obs;
  var searchQuery = ''.obs;

  final String baseUrl = 'https://api.libanbuy.com/api';
  late String postType;
  late String displayName;

  BannerController({required this.postType}) {
    _setDisplayName();
  }

  void _setDisplayName() {
    switch (postType) {
      case 'sale_banners':
        displayName = 'Sale Banners';
        break;
      case 'hero_banners':
        displayName = 'Hero Banners';
        break;
      case 'discount_banners':
        displayName = 'Discount Banners';
        break;
      case 'blogs':
        displayName = 'Blogs';
        break;
      default:
        displayName = 'Banners';
    }
  }

  final RxString selectedStatusFilter = 'all'.obs;
  List<PostModel> get filteredBanners {
    List<PostModel> filtered = banners;

    // Apply status filter first
    if (selectedStatusFilter.value != 'all') {
      filtered =
          filtered
              .where(
                (banner) =>
                    banner.status.toLowerCase() ==
                    selectedStatusFilter.value.toLowerCase(),
              )
              .toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered =
          filtered
              .where(
                (banner) =>
                    banner.name.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ||
                    (banner.description.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    )),
              )
              .toList();
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse(
          '$baseUrl/posts?with=thumbnail,shop&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=status&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][0][value]=active&filterByColumns[columns][1][column]=post_type&filterByColumns[columns][1][operator]=%3D&filterByColumns[columns][1][value]=$postType&_t=${DateTime.now().millisecondsSinceEpoch}',
        ),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['posts'] != null) {
          final List<dynamic> bannerList = data['posts']['data'];
          banners.value =
              bannerList.map((json) => PostModel.fromJson(json)).toList();
        } else {
          banners.value = [];
        }

        // Get.snackbar(
        //   'Success',
        //   '$displayName loaded successfully',
        //   backgroundColor: Colors.green[100],
        //   colorText: Colors.green[800],
        //   snackPosition: SnackPosition.TOP,
        //   duration: Duration(seconds: 1),
        // );
      } else if (response.statusCode == 404) {
        banners.value = [];
      } else {
        throw Exception('Failed to load $displayName: ${response.statusCode}');
      }
    } catch (e) {
      String errorMessage = 'Failed to load $displayName';

      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      isDeleting.value = true;

      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$id/delete'),
        headers: {
          'Accept': 'application/json',
          'X-Request-From': 'Application',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        banners.removeWhere((banner) => banner.id == id);

        Get.snackbar(
          'Success',
          'Banner deleted successfully',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          snackPosition: SnackPosition.TOP,
          duration: const Duration(microseconds: 500),
        );
      } else {
        throw Exception('Failed to delete banner: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete banner',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
    } finally {
      isDeleting.value = false;
    }
  }

  void showDeleteConfirmation(PostModel banner) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Banner'),
        content: Text('Are you sure you want to delete "${banner.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteBanner(banner.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData get bannerIcon {
    switch (postType) {
      case 'sale_banners':
        return Icons.local_offer;
      case 'hero_banners':
        return Icons.star;
      case 'discount_banners':
        return Icons.percent;
      case 'blogs':
        return Icons.article;
      default:
        return Icons.image;
    }
  }
}

// Common Banner List Screen
class BannerListScreen extends StatelessWidget {
  final String postType;
  final String? title;

  const BannerListScreen({super.key, required this.postType, this.title});

  @override
  Widget build(BuildContext context) {
    final BannerController controller = Get.put(
      BannerController(postType: postType),
      tag: postType,
    );
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.teal, Colors.teal],
    );
    final displayTitle = title ?? controller.displayName;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Gradient background for upper half
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        displayTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Add New Button Card
                        GestureDetector(
                          onTap:
                              () => Get.to(
                                () => BannerFormScreen(postType: postType),
                              ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Add New Button
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Add New',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Data Table Container
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Search and Filter Section
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    // Search Input
                                    TextFormField(
                                      decoration: InputDecoration(
                                        hintText:
                                            'Search ${displayTitle.toLowerCase()}',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.grey[600],
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[300],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                      ),
                                      onChanged: (value) {
                                        controller.searchQuery.value = value;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Filter Row
                                    Row(
                                      children: [
                                        Icon(
                                          controller.bannerIcon,
                                          color: Colors.grey[700],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const SizedBox(width: 200),
                                        const Spacer(),
                                        // Status Filter Dropdown
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Obx(
                                            () => SizedBox(
                                              height: 28, // Very small height
                                              child: DropdownButton<String>(
                                                value:
                                                    controller
                                                        .selectedStatusFilter
                                                        .value,
                                                underline: const SizedBox(),
                                                hint: const Text(
                                                  'Status',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ), // Shorter text
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black,
                                                ),
                                                isDense: true,
                                                icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  size: 16,
                                                ), // Smaller icon
                                                items: [
                                                  const DropdownMenuItem(
                                                    value: 'all',
                                                    child: Text(
                                                      'All',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                  const DropdownMenuItem(
                                                    value: 'active',
                                                    child: Text(
                                                      'Active',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                  const DropdownMenuItem(
                                                    value: 'inactive',
                                                    child: Text(
                                                      'Inactive',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                onChanged: (value) {
                                                  controller
                                                      .selectedStatusFilter
                                                      .value = value ?? 'all';
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Data Table
                              Obx(() {
                                if (controller.isLoading.value) {
                                  return const SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: LinearProgressIndicator(
                                        color: Color(0xFFF97316),
                                      ),
                                    ),
                                  );
                                }

                                if (controller.filteredBanners.isEmpty) {
                                  return SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            controller.bannerIcon,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No ${displayTitle.toLowerCase()} found',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width > 800
                                            ? MediaQuery.of(
                                                  context,
                                                ).size.width -
                                                32
                                            : 800,
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(
                                        Colors.teal,
                                      ),
                                      headingTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      dataRowColor: WidgetStateProperty.all(
                                        Colors.white,
                                      ),
                                      columns: [
                                        const DataColumn(label: Text('Image')),
                                        const DataColumn(label: Text('Title')),
                                        const DataColumn(
                                          label: Text('Published At'),
                                        ),
                                        const DataColumn(label: Text('Status')),
                                        const DataColumn(
                                          label: Text('Actions'),
                                        ),
                                      ],
                                      rows:
                                          controller.filteredBanners.map((
                                            banner,
                                          ) {
                                            return DataRow(
                                              cells: [
                                                // Image Cell
                                                DataCell(
                                                  Container(
                                                    width: 60,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      color: Colors.grey[200],
                                                    ),
                                                    child:
                                                        banner
                                                                        .thumbnail
                                                                        ?.media
                                                                        ?.url !=
                                                                    null &&
                                                                (banner
                                                                            .thumbnail
                                                                            ?.media
                                                                            ?.url ??
                                                                        '')
                                                                    .isNotEmpty
                                                            ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              child: Image.network(
                                                                banner
                                                                        .thumbnail
                                                                        ?.media
                                                                        ?.url ??
                                                                    '',
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                errorBuilder: (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  return Icon(
                                                                    Icons.image,
                                                                    color:
                                                                        Colors
                                                                            .grey[400],
                                                                  );
                                                                },
                                                              ),
                                                            )
                                                            : Icon(
                                                              Icons.image,
                                                              color:
                                                                  Colors
                                                                      .grey[400],
                                                            ),
                                                  ),
                                                ),
                                                // Title Cell
                                                DataCell(
                                                  SizedBox(
                                                    width: 200,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          banner.name,

                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors
                                                                    .grey[800],
                                                          ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        // if (banner
                                                        //     .description
                                                        //     .isNotEmpty) ...[
                                                        //   SizedBox(height: 4),
                                                        //   Text(
                                                        //     banner.description,
                                                        //     style: TextStyle(
                                                        //       fontSize: 12,
                                                        //       color:
                                                        //           Colors
                                                        //               .grey[600],
                                                        //     ),
                                                        //     maxLines: 1,
                                                        //     overflow:
                                                        //         TextOverflow
                                                        //             .ellipsis,
                                                        //   ),
                                                        // ],
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Published At Cell
                                                DataCell(
                                                  Text(
                                                    DateFormat(
                                                      'MMM dd, yyyy',
                                                    ).format(banner.createdAt),
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                // Status Cell
                                                DataCell(
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          banner.status ==
                                                                  'active'
                                                              ? Colors
                                                                  .green[100]
                                                              : Colors
                                                                  .orange[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      banner.status
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            banner.status ==
                                                                    'active'
                                                                ? Colors
                                                                    .green[700]
                                                                : Colors
                                                                    .orange[700],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Actions Cell
                                                DataCell(
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          color: Colors.blue,
                                                          size: 18,
                                                        ),
                                                        onPressed:
                                                            () => Get.to(
                                                              () =>
                                                                  BannerFormScreen(
                                                                    postType:
                                                                        postType,
                                                                    banner:
                                                                        banner,
                                                                  ),
                                                            ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                          size: 18,
                                                        ),
                                                        onPressed:
                                                            () => controller
                                                                .showDeleteConfirmation(
                                                                  banner,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        // Pagination button
                        // Container(
                        //   width: double.infinity,
                        //   margin: EdgeInsets.only(bottom: 20),
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       // Add pagination logic here
                        //       controller.fetchBanners();
                        //     },
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.black,
                        //       foregroundColor: Colors.white,
                        //       padding: EdgeInsets.symmetric(vertical: 16),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //     ),
                        //     child: Text(
                        //       '1/1',
                        //       style: TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BannerFormController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final buttonText = TextEditingController();
  final subHeading = TextEditingController();
  final buttonUrl = TextEditingController();

  final descriptionController = TextEditingController();

  var isLoading = false.obs;
  var isImageUploading = false.obs;
  var isCategoriesLoading = false.obs;
  var selectedImage = Rxn<File>();
  var selectedImageMobile = Rxn<File>();
  var thumbnailId = Rxn<String>();
  var selectedCategoryId = Rxn<String>();
  var categories = <CategoryModel>[].obs;

  PostModel? editingBanner;
  late String postType;
  late String displayName;
  final ImagePicker _picker = ImagePicker();

  final String baseUrl = 'https://api.libanbuy.com/api';

  BannerFormController({required this.postType}) {
    _setDisplayName();
    // Fetch categories if this is a blog post
    if (postType == 'blogs') {
      fetchCategories();
    }
  }

  void _setDisplayName() {
    switch (postType) {
      case 'sale_banners':
        displayName = 'Sale Banner';
        break;
      case 'blogs':
        displayName = 'Blog';
        break;
      case 'hero_banners':
        displayName = 'Hero Banner';
        break;
      case 'discount_banners':
        displayName = 'Discount Banner';
        break;
      default:
        displayName = 'Banner';
    }
  }

  void setEditingBanner(PostModel? banner) {
    editingBanner = banner;
    if (banner != null) {
      nameController.text = banner.name;
      descriptionController.text = banner.description ?? '';
      thumbnailId.value =
          banner.thumbnailId; // Assuming your PostModel has thumbnailId field
      buttonText.text = banner.meta?.buttonText ?? '';
      buttonUrl.text = banner.meta?.buttonUrl ?? '';
      // Set selected category if editing a blog and it has categories
      // if (postType == 'blogs' &&
      //     banner. != null &&
      //     banner.categories!.isNotEmpty) {
      //   selectedCategoryId.value = banner.categories!.first.id;
      // }
    }
  }

  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;
      final response = await http.get(
        Uri.parse('$baseUrl/post-attributes/categories'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final categoryResponse = CategoryResponse.fromJson(jsonData);
        categories.value = categoryResponse.postAttribute.attributeItems;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch categories: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await uploadSelectedImage();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> pickImageMobile() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImageMobile.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> uploadSelectedImage() async {
    if (selectedImage.value == null) return;

    try {
      isImageUploading.value = true;

      // Call your uploadmedia function from main.dart
      final uploadedId = await uploadMedia([selectedImage.value!]);

      thumbnailId.value = uploadedId;
      Get.snackbar(
        'Success',
        'Image uploaded successfully!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      selectedImage.value = null;
    } finally {
      isImageUploading.value = false;
    }
  }

  void removeImage() {
    selectedImage.value = null;
    thumbnailId.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Color selectedColor = Colors.blue;
  final TextEditingController _controller = TextEditingController();

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  void _openColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor = color;
                _controller.text = colorToHex(color);
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitBanner() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate that thumbnail is selected
    if (thumbnailId.value == null) {
      Get.snackbar(
        'Error',
        'Please select a thumbnail image',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Validate category selection for blogs
    if (postType == 'blogs' && selectedCategoryId.value == null) {
      Get.snackbar(
        'Error',
        'Please select a category for the blog',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      isLoading.value = true;

      final Map<String, dynamic> requestData = {
        'name': nameController.text.trim(),
        'post_type': postType,
        'description': descriptionController.text.trim(),
        'thumbnail_id': thumbnailId.value,
      };

      // Add categories array for blog posts
      if (postType == 'blogs' && selectedCategoryId.value != null) {
        requestData['categories'] = [selectedCategoryId.value];
      }
      if (postType == 'sale_banners' || postType == 'hero_banners') {
        requestData['meta'] = [
          {"button_text": buttonText.text.trim()},
          {"button_url": buttonUrl.text.trim()},
        ];
      }

      http.Response response;

      if (editingBanner != null) {
        // Update existing banner
        response = await http.put(
          Uri.parse('$baseUrl/posts/${editingBanner!.id}/update'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Request-From': 'Application',
          },
          body: json.encode(requestData),
        );
      } else {
        // Create new banner
        response = await http.post(
          Uri.parse('$baseUrl/posts/insert'),
          headers: {
            'Content-Type': 'application/json',
            'X-Request-From': 'Application',
            'Accept': 'application/json',
            'shop-id':
                AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          },
          body: json.encode(requestData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh banner list
        if (Get.isRegistered<BannerController>(tag: postType)) {
          Get.find<BannerController>(tag: postType).fetchBanners();
        }

        // Go back to list
        Get.back();
        Get.snackbar(
          'Success',
          editingBanner != null
              ? '$displayName updated successfully!'
              : '$displayName created successfully!',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1),
        );
      } else {
        final errorData = json.decode(response.body);
        String errorMessage =
            editingBanner != null
                ? 'Failed to update $displayName'
                : 'Failed to create $displayName';

        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first.first ?? errorMessage;
        }

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please try again';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void cancelForm() {
    nameController.clear();
    descriptionController.clear();
    selectedImage.value = null;
    thumbnailId.value = null;
    selectedCategoryId.value = null;
    Get.back();
  }

  String get hintText {
    switch (postType) {
      case 'sale_banners':
        return 'Enter sale banner title (e.g., "Summer Sale 50% Off")';
      case 'hero_banners':
        return 'Enter hero banner title (e.g., "Welcome to Our Store")';
      case 'discount_banners':
        return 'Enter discount banner title (e.g., "Special Discount 30% Off")';
      case 'blogs':
        return 'Enter blog title';
      default:
        return 'Enter banner title';
    }
  }

  String get descriptionHint {
    switch (postType) {
      case 'sale_banners':
        return 'Describe the sale details, duration, and terms.';
      case 'hero_banners':
        return 'Provide compelling content for your main banner.';
      case 'discount_banners':
        return 'Detail the discount offer, conditions, and validity.';
      case 'blogs':
        return 'Write your blog content here.';
      default:
        return 'Provide banner description and details.';
    }
  }
}

// Common Banner Form Screen
class BannerFormScreen extends StatelessWidget {
  final String postType;
  final PostModel? banner;

  const BannerFormScreen({super.key, required this.postType, this.banner});

  @override
  Widget build(BuildContext context) {
    final BannerFormController controller = Get.put(
      BannerFormController(postType: postType),
      tag: postType,
    );

    // Set editing banner if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setEditingBanner(banner);
    });

    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.teal, Colors.teal],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Gradient background for upper half
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        banner != null
                            ? 'Edit ${controller.displayName}'
                            : 'Add ${controller.displayName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          // Thumbnail Card
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Header - Separate container with padding from all sides
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.image,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        postType == 'hero_banners'
                                            ? 'Banner Image Desktop'
                                            : (postType == 'discount_banners' ||
                                                postType == 'blogs')
                                            ? 'Featured Image'
                                            : 'Thumbnail Image',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Image content
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Obx(() {
                                    if (controller.isImageUploading.value) {
                                      return Container(
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Color(0xFF4CAF50)),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Uploading image...',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    if (controller.selectedImage.value !=
                                        null) {
                                      return Column(
                                        children: [
                                          Container(
                                            height: 200,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(
                                                controller.selectedImage.value!,
                                                width: double.infinity,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed:
                                                      controller.pickImage,
                                                  icon: const Icon(
                                                    Icons.refresh,
                                                  ),
                                                  label: const Text(
                                                    'Change Image',
                                                  ),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                        foregroundColor:
                                                            const Color(
                                                              0xFFF97316,
                                                            ),
                                                        side: const BorderSide(
                                                          color: Color(
                                                            0xFFF97316,
                                                          ),
                                                        ),
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed:
                                                      controller.removeImage,
                                                  icon: const Icon(
                                                    Icons.delete,
                                                  ),
                                                  label: const Text('Remove'),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.red,
                                                        side: const BorderSide(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }

                                    return GestureDetector(
                                      onTap: controller.pickImage,
                                      child: Container(
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                size: 48,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Tap to select image',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Recommended: 1920x1080px',
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                if (postType == 'hero_banners')
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF97316),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.image,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Banner Image Mobile',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (postType == 'hero_banners')
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Obx(() {
                                      if (controller.isImageUploading.value) {
                                        return Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Color(0xFFF97316)),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Uploading image...',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      if (controller
                                              .selectedImageMobile
                                              .value !=
                                          null) {
                                        return Column(
                                          children: [
                                            Container(
                                              height: 200,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.file(
                                                  controller
                                                      .selectedImageMobile
                                                      .value!,
                                                  width: double.infinity,
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed:
                                                        controller
                                                            .pickImageMobile,
                                                    icon: const Icon(
                                                      Icons.refresh,
                                                    ),
                                                    label: const Text(
                                                      'Change Image',
                                                    ),
                                                    style:
                                                        OutlinedButton.styleFrom(
                                                          foregroundColor:
                                                              const Color(
                                                                0xFFF97316,
                                                              ),
                                                          side:
                                                              const BorderSide(
                                                                color: Color(
                                                                  0xFFF97316,
                                                                ),
                                                              ),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }

                                      return GestureDetector(
                                        onTap: controller.pickImage,
                                        child: Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add_photo_alternate,
                                                  size: 48,
                                                  color: Colors.grey[400],
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Tap to select image',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Recommended: 1920x1080px',
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                              ],
                            ),
                          ),

                          // Category Dropdown for Blogs
                          if (postType == 'blogs') ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Header - Separate container with padding from all sides
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.all(12),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF97316),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.category,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Blog Category',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Category dropdown content
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Obx(() {
                                      if (controller
                                          .isCategoriesLoading
                                          .value) {
                                        return Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Color(0xFF4CAF50)),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Loading categories...',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      return DropdownButtonFormField<String>(
                                        initialValue:
                                            controller.selectedCategoryId.value,
                                        decoration: InputDecoration(
                                          hintText: 'Select a category',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFF97316),
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.all(
                                            16,
                                          ),
                                        ),
                                        items:
                                            controller.categories.map((
                                              category,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: category.id,
                                                child: Text(
                                                  category.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          controller.selectedCategoryId.value =
                                              newValue;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select a category';
                                          }
                                          return null;
                                        },
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.grey[600],
                                        ),
                                        isExpanded: true,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Title Card
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Header - Separate container with padding from all sides
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    children: [
                                      Text(
                                        'Banner Title',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Title content
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: TextFormField(
                                    controller: controller.nameController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: controller.hintText,
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFF97316),
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Title is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                if (postType == 'hero_banners') ...[
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: TextFormField(
                                      controller: controller.subHeading,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: 'Sub Heading',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder:
                                            const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: TextFormField(
                                      readOnly: true,
                                      onTap: () {
                                        controller._openColorPicker(context);
                                      },
                                      controller: controller._controller,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: 'Button Color',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder:
                                            const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                                if (postType == 'sale_banners' ||
                                    postType == 'hero_banners') ...[
                                  Builder(
                                    builder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: TextFormField(
                                          controller: controller.buttonText,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            hintText: 'Button text',
                                            hintStyle: TextStyle(
                                              color: Colors.grey[400],
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF4CAF50),
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.all(16),
                                          ),
                                          validator: (value) {
                                            return null;
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  Builder(
                                    builder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: TextFormField(
                                          controller: controller.buttonUrl,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            hintText: 'Button Url',
                                            hintStyle: TextStyle(
                                              color: Colors.grey[400],
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF4CAF50),
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.all(16),
                                          ),
                                          validator: (value) {
                                            return null;
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Banner Status Card
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Header - Separate container with padding from all sides
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.toggle_on,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Banner Management',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Status Toggle content
                                BannerStatusToggle(
                                  initialStatus: true,
                                  onChanged: (value) {
                                    print(
                                      "Banner is now ${value ? "enabled" : "disabled"}",
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Action buttons
                          Column(
                            children: [
                              // Save button
                              Obx(
                                () => SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed:
                                        (controller.isLoading.value ||
                                                controller
                                                    .isImageUploading
                                                    .value)
                                            ? null
                                            : controller.submitBanner,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF97316),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 2,
                                    ),
                                    child:
                                        controller.isLoading.value
                                            ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  banner != null
                                                      ? 'Updating...'
                                                      : 'Saving...',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            )
                                            : Text(
                                              banner != null
                                                  ? 'Update'
                                                  : 'Save',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Cancel button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: TextButton(
                                  onPressed: controller.cancelForm,
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.grey[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Usage Examples:

// For Sale Banners
class SaleBannersScreen extends StatelessWidget {
  const SaleBannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BannerListScreen(
      postType: 'sale_banners',
      title: 'Sale Banners', // Optional custom title
    );
  }
}

// For Hero Banners
class HeroBannersScreen extends StatelessWidget {
  const HeroBannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BannerListScreen(
      postType: 'hero_banners',
      title: 'Club Page Hero Banners',
    );
  }
}

// For Hero Banners
class homeHeroBannersScreen extends StatelessWidget {
  const homeHeroBannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BannerListScreen(
      title: 'Home Page Hero Banners',
      postType: 'home_page_hero_banners',
    );
  }
}

// For Discount Banners
class DiscountBannersScreen extends StatelessWidget {
  const DiscountBannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BannerListScreen(postType: 'discount_banners');
  }
}

// For Blogs
class BlogsBannersScreen extends StatelessWidget {
  const BlogsBannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BannerListScreen(postType: 'blogs');
  }
}

class BannerStatusToggle extends StatefulWidget {
  final bool initialStatus;
  final ValueChanged<bool>? onChanged;

  const BannerStatusToggle({
    super.key,
    this.initialStatus = false,
    this.onChanged,
  });

  @override
  State<BannerStatusToggle> createState() => _BannerStatusToggleState();
}

class _BannerStatusToggleState extends State<BannerStatusToggle> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Banner Status',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose the status that best reflects the availability of this banner for customers.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }
                },
                activeThumbColor: const Color(0xFFF97316),
                inactiveThumbColor: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
