// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/modules/modules_admin/admin_jobs/models/attributes_model.dart';
import 'package:tjara/app/repo/network_repository.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/main.dart';

class JobAttributeController extends GetxController {
  final RxList<JobAttribute> jobAttributes = <JobAttribute>[].obs;
  final Rx<JobAttributeState> state = JobAttributeState.loading.obs;
  final RxString errorMessage = ''.obs;

  // Form fields
  final nameController = TextEditingController();
  final Rx<JobAttributeItem?> selectedParent = Rx<JobAttributeItem?>(null);
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isUploading = false.obs;
  final RxString thumbnailId = ''.obs;

  // Edit mode variables
  final RxBool isEditMode = false.obs;
  final Rx<JobAttributeItem?> editingAttribute = Rx<JobAttributeItem?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchJobAttributes();
  }

  final NetworkRepository _repository = NetworkRepository();

  Future<void> fetchJobAttributes() async {
    try {
      state.value = JobAttributeState.loading;

      final result = await _repository.fetchData<JobAttributesResponse>(
        url:
            'https://api.libanbuy.com/api/job-attributes?slug=${DateTime.now().millisecondsSinceEpoch}_t=${DateTime.now().millisecondsSinceEpoch}',
        fromJson: (json) => JobAttributesResponse.fromJson(json),
      );

      jobAttributes.assignAll(result.jobAttributes ?? []);

      state.value = JobAttributeState.loaded;
    } catch (e) {
      state.value = JobAttributeState.error;
      errorMessage.value = 'Failed to load job attributes: ${e.toString()}';
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> insertJobAttribute() async {
    const String apiUrl =
        'https://api.libanbuy.com/api/job-attribute-items/insert';

    if (selectedImage.value != null) {
      await uploadMedia([selectedImage.value!]);
    }

    final Map<String, dynamic> body = {
      'name': nameController.text,
      'attribute_id': jobAttributes.first.id,
      'parent_id': selectedParent.value?.id,
      'thumbnail_id': thumbnailId.value.isNotEmpty ? thumbnailId.value : null,
    };

    try {
      isUploading.value = true;

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "X-Request-From": "Application",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Job attribute created successfully');
        resetForm();
        fetchJobAttributes();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          'Failed to insert: ${error['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('API Error: $e');
      Get.snackbar('Error', 'Failed to create job attribute: ${e.toString()}');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> updateJobAttribute() async {
    if (editingAttribute.value == null) return;

    final String apiUrl =
        'https://api.libanbuy.com/api/job-attribute-items/${editingAttribute.value!.id}/update';

    if (selectedImage.value != null) {
      await uploadMedia([selectedImage.value!]);
    }

    final Map<String, dynamic> body = {
      'name': nameController.text,
      'attribute_id': jobAttributes.first.id,
      'parent_id': selectedParent.value?.id,
      'thumbnail_id':
          thumbnailId.value.isNotEmpty
              ? thumbnailId.value
              : editingAttribute.value?.thumbnailId,
    };

    try {
      isUploading.value = true;

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "X-Request-From": "Application",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Job attribute updated successfully');
        resetForm();
        fetchJobAttributes();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          'Failed to update: ${error['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('API Error: $e');
      Get.snackbar('Error', 'Failed to update job attribute: ${e.toString()}');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deleteJobAttribute(JobAttributeItem attribute) async {
    final String apiUrl =
        'https://api.libanbuy.com/api/job-attribute-items/${attribute.id}/delete';

    try {
      isUploading.value = true;

      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          "X-Request-From": "Application",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar('Success', 'Job attribute deleted successfully');
        fetchJobAttributes();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          'Failed to delete: ${error['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('API Error: $e');
      Get.snackbar('Error', 'Failed to delete job attribute: ${e.toString()}');
    } finally {
      isUploading.value = false;
    }
  }

  void editAttribute(JobAttributeItem attribute) {
    isEditMode.value = true;
    editingAttribute.value = attribute;
    nameController.text = attribute.name ?? '';

    // Find parent if exists
    final items =
        jobAttributes.isNotEmpty
            ? jobAttributes.first.attributeItems?.jobAttributeItems ?? []
            : <JobAttributeItem>[];

    selectedParent.value =
        items.where((parent) => parent.id == attribute.parentId).firstOrNull;

    selectedImage.value = null;
    thumbnailId.value = '';
  }

  Future<void> submitAttribute() async {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Name is required');
      return;
    }

    if (isEditMode.value) {
      await updateJobAttribute();
    } else {
      await insertJobAttribute();
    }
  }

  Future<void> showDeleteConfirmation(JobAttributeItem attribute) async {
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${attribute.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteJobAttribute(attribute);
    }
  }

  void resetForm() {
    nameController.clear();
    selectedParent.value = null;
    selectedImage.value = null;
    thumbnailId.value = '';
    isEditMode.value = false;
    editingAttribute.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

enum JobAttributeState { loading, loaded, error }
