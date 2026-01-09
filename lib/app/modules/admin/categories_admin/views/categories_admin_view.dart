import 'dart:developer';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';

import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/core/widgets/search_text_field_widget.dart';
import 'package:tjara/app/modules/admin/categories_admin/controllers/categories_admin_controller.dart';

class CategoriesAdminView extends StatefulWidget {
  const CategoriesAdminView({super.key});

  @override
  State<CategoriesAdminView> createState() => _CategoriesAdminViewState();
}

class _CategoriesAdminViewState extends State<CategoriesAdminView> {
  final bool _isAppBarExpanded = true;
  late CategoriesAdminController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CategoriesAdminController>();
    controller.fetchCategories(loaderType: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CategoriesPageWidget(isAppBarExpanded: _isAppBarExpanded),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class CategoriesPageWidget extends StatefulWidget {
  final bool isAppBarExpanded;
  const CategoriesPageWidget({super.key, required this.isAppBarExpanded});

  @override
  State<CategoriesPageWidget> createState() => _CategoriesPageWidgetState();
}

class _CategoriesPageWidgetState extends State<CategoriesPageWidget> {
  final addCategoryNameController = TextEditingController();
  String? selectedParentCategory;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriesAdminController>();
    return CustomScrollView(
      slivers: [
        AdminSliverAppBarWidget(
          title: 'Dashboard',
          isAppBarExpanded: widget.isAppBarExpanded,
          actions: const [AdminAppBarActions()],
        ),
        SliverToBoxAdapter(
          child: Obx(
            () =>
                controller.isLoading.value
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      ),
                    )
                    : Stack(
                      children: [
                        AdminHeaderAnimatedBackgroundWidget(
                          isAppBarExpanded: widget.isAppBarExpanded,
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "${Get.arguments ?? 'Product'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      letterSpacing: 1.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 5.0,
                                      right: 5,
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    "Categories",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                width: MediaQuery.sizeOf(context).width,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width:
                                            MediaQuery.sizeOf(context).width -
                                            70,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            width: 1,
                                            color: const Color(0xFFe8edf3),
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: SingleChildScrollView(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                "Attribute Item Name",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller:
                                                    addCategoryNameController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Attribute item Name',
                                                  filled: true,
                                                  fillColor:
                                                      Colors.grey.shade100,
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12,
                                                      ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        borderSide: const BorderSide(
                                                          color: Color(
                                                            0xFF0D9488,
                                                          ),
                                                          width: 2,
                                                        ),
                                                      ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                ),
                                              ),

                                              const SizedBox(height: 20),
                                              const Text(
                                                "Parent Category:",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Obx(() {
                                                print(
                                                  'Categories list length: ${controller.categoriesList.length}',
                                                );
                                                if (controller
                                                    .isLoading
                                                    .value) {
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                              ),
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          'Loading categories...',
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton<
                                                      String?
                                                    >(
                                                      value:
                                                          selectedParentCategory,
                                                      isExpanded: true,
                                                      hint: Text(
                                                        'select Parent',
                                                        style: TextStyle(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade600,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      items: [
                                                        const DropdownMenuItem<
                                                          String
                                                        >(
                                                          value: null,
                                                          child: Text(
                                                            'No Parent',
                                                          ),
                                                        ),
                                                        ...controller
                                                            .categoriesList
                                                            .map(
                                                              (
                                                                category,
                                                              ) => DropdownMenuItem<
                                                                String
                                                              >(
                                                                value:
                                                                    category.id,
                                                                child: Text(
                                                                  category.name ??
                                                                      '',
                                                                ),
                                                              ),
                                                            ),
                                                      ],
                                                      onChanged: (
                                                        String? newValue,
                                                      ) {
                                                        setState(() {
                                                          selectedParentCategory =
                                                              newValue;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                );
                                              }),

                                              const SizedBox(height: 20),
                                              const Text(
                                                "Categories item image:",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              InkWell(
                                                onTap: () {
                                                  controller.pickImage();
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.image_outlined,
                                                        color: Colors.black,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        'Upload a File',
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              SizedBox(
                                                width: double.infinity,
                                                child: Obx(
                                                  () => ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(
                                                        0xFF4CAF50,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              25,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 32,
                                                            vertical: 12,
                                                          ),
                                                    ),
                                                    onPressed:
                                                        controller
                                                                .loadingButton
                                                                .value
                                                            ? null
                                                            : () {
                                                              if (addCategoryNameController
                                                                  .text
                                                                  .isNotEmpty) {
                                                                controller
                                                                    .addCategory(
                                                                      name:
                                                                          addCategoryNameController
                                                                              .text,
                                                                      thumbnailId:
                                                                          controller
                                                                              .thumbnailId
                                                                              .value,
                                                                      parentId:
                                                                          null, // Set based on selectedParentCategory if needed
                                                                      context:
                                                                          context,
                                                                    )
                                                                    .then((_) {
                                                                      // Clear form after successful submission
                                                                      addCategoryNameController
                                                                          .clear();
                                                                      selectedParentCategory =
                                                                          null;
                                                                      setState(
                                                                        () {},
                                                                      );
                                                                    });
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                      'Please fill all required fields and upload an image',
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                    child:
                                                        controller
                                                                .loadingButton
                                                                .value
                                                            ? const SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            )
                                                            : const Text(
                                                              "Save",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 12),

                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    side: BorderSide(
                                                      color: Colors.grey
                                                          .withAlpha(80),
                                                      width: 1,
                                                    ),
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            25,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 32,
                                                          vertical: 12,
                                                        ),
                                                  ),
                                                  onPressed: () {
                                                    addCategoryNameController
                                                        .clear();
                                                    selectedParentCategory =
                                                        null;
                                                    controller.clearForm();
                                                    setState(() {});
                                                  },
                                                  child: const Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 15,
                                      left: 20,
                                      child: Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 4.0,
                                        ),
                                        child: const Text(
                                          "ADD CATEGORIES ITEM",
                                          style: TextStyle(
                                            color: Color(0xFF64738b),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 30,
                              width: MediaQuery.sizeOf(context).width - 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(200),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0,
                                          vertical: 20,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0,
                                            vertical: 15,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              width: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SearchTextFieldWidget(
                                                controller:
                                                    controller
                                                        .textEditingController,
                                                searchBy: 'Search Categories',
                                                searchByStaticText: '',
                                              ),
                                              SizedBox(
                                                width:
                                                    MediaQuery.sizeOf(
                                                      context,
                                                    ).width,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    side: BorderSide(
                                                      color: Colors.grey
                                                          .withAlpha(80),
                                                      width: 1,
                                                    ),
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    controller.searchCategories(
                                                      controller
                                                          .textEditingController
                                                          .text,
                                                    );
                                                  },
                                                  child: const Text(
                                                    "Search",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                alignment: Alignment.centerLeft,
                                                width:
                                                    MediaQuery.sizeOf(
                                                      context,
                                                    ).width,
                                                height: 60,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFF97316),
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          20,
                                                        ),
                                                      ),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Name",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "Actions",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Obx(
                                                () => Column(
                                                  children:
                                                      List.generate(
                                                        controller
                                                            .filteredList
                                                            .length,
                                                        (index) {
                                                          final category =
                                                              controller
                                                                  .filteredList[index];
                                                          return Column(
                                                            children: [
                                                              if (index == 0)
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                              ListTile(
                                                                title: Text(
                                                                  category.name
                                                                      .toString(),
                                                                ),
                                                                trailing: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    IconButton(
                                                                      icon: const Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color:
                                                                            Colors.blue,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                      onPressed: () {
                                                                        _showEditDialog(
                                                                          context,
                                                                          category,
                                                                        );
                                                                      },
                                                                    ),
                                                                    IconButton(
                                                                      icon: const Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color:
                                                                            Colors.red,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                      onPressed: () {
                                                                        controller.showDeleteConfirmation(
                                                                          categoryId:
                                                                              category.id.toString(),
                                                                          categoryName:
                                                                              category.name!,
                                                                          context:
                                                                              context,
                                                                        );
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              const DottedLine(
                                                                dashColor:
                                                                    Colors.grey,
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 70,
                                  child: Container(
                                    color: Colors.white,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5.0,
                                      ),
                                      child: Text(
                                        "CATEGORIES LIST",
                                        style: TextStyle(
                                          color: Color(0xFF64738b),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, dynamic category) {
    final controller = Get.find<CategoriesAdminController>();
    final nameController = TextEditingController(text: category.name);
    String? selectedParent;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Category Name",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter category name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Parent Category",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    selectedParent ?? 'Select Parent Category',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Update Image (Optional)",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    controller.pickImage();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          "Choose new image",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                Obx(
                  () =>
                      controller.files.isNotEmpty
                          ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "New image selected: ${controller.files.first.path.split('/').last}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          )
                          : const SizedBox(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isUpdating.value
                        ? null
                        : () {
                          if (nameController.text.isNotEmpty) {
                            controller.updateCategory(
                              categoryId: category.id.toString(),
                              name: nameController.text,
                              thumbnailId:
                                  controller.thumbnailId.value.isNotEmpty
                                      ? controller.thumbnailId.value
                                      : category.thumbnailId ?? '',
                              parentId: category.parentId ?? '',
                              context: context,
                            );
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter category name'),
                              ),
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child:
                    controller.isUpdating.value
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }
}

const _list = [
  'Pakistani',
  'Indian',
  'Middle Eastern',
  'Western',
  'Chinese',
  'Italian',
  'Italian2',
  'Italian3',
];

class SearchDropdown extends StatefulWidget {
  final Function(String?)? onChanged;
  const SearchDropdown({super.key, this.onChanged});

  @override
  State<SearchDropdown> createState() => _SearchDropdownState();
}

class _SearchDropdownState extends State<SearchDropdown> {
  String? selectedItem;
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>.search(
      closedHeaderPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: CustomDropdownDecoration(
        closedBorderRadius: BorderRadius.circular(8),
        expandedBorder: Border.all(color: Colors.white, width: 1),
        closedBorder: Border.all(
          color: Colors.grey.shade300,
          width: isVisible ? 1 : 0,
        ),
      ),
      hintText: 'Select cuisines',
      items: _list,
      initialItem: selectedItem,
      visibility: (isVisible) {
        if (isVisible) {
          isVisible = true;
          setState(() {});
        } else {
          isVisible = false;
          setState(() {});
        }
      },
      overlayHeight: 342,
      onChanged: (value) {
        log('SearchDropdown onChanged value: $value');
        setState(() {
          selectedItem = value;
        });
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
    );
  }
}

class DottedContainerExample extends StatelessWidget {
  const DottedContainerExample({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriesAdminController>();
    final size = MediaQuery.sizeOf(context);

    return Center(
      child: InkWell(
        onTap: () {
          controller.pickImage();
        },
        child: DottedBorder(
          options: RectDottedBorderOptions(
            color: Colors.grey.shade500,
            strokeWidth: 1,
            dashPattern: [6, 3],
          ),
          child: Container(
            width: size.width,
            height: 55,
            alignment: Alignment.center,
            child: Obx(
              () =>
                  controller.files.isNotEmpty
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Selected: ${controller.files.first.path.split('/').last}",
                              style: const TextStyle(color: Colors.green),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                      : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            "Upload a file ",
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(width: 2),
                          Text("or Drag and Drop"),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
