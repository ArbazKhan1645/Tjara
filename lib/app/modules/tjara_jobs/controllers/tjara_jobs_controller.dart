// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/core/utils/helpers/api_exceptions.dart';
import 'package:tjara/app/models/jobs/jobs_model.dart';
import 'package:tjara/app/modules/tjara_jobs/api_service/jobs_aoi_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:tjara/app/services/auth/auth_service.dart';

class TjaraJobsController extends GetxController {
  final JobApiService _apiService = JobApiService();

  // Observable variables
  final RxList<Job> jobs = <Job>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchJobs();
  }

  // Fetch jobs for the current page
  Future<void> fetchJobs() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    try {
      final response = await _apiService.fetchJobs(page: currentPage.value);
      // Update pagination info
      totalPages.value = response.jobs.lastPage;
      hasMoreData.value = currentPage.value < totalPages.value;
      // Add jobs to the list
      if (currentPage.value == 1) {
        jobs.clear();
      }
      jobs.addAll(response.jobs.data);
    } on ApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (!hasMoreData.value || isLoading.value) return;

    currentPage.value++;
    await fetchJobs();
  }

  // Refresh jobs (reset to page 1)
  Future<void> refreshJobs() async {
    currentPage.value = 1;
    await fetchJobs();
  }

  // Search jobs by title
  List<Job> searchJobs(String query) {
    if (query.isEmpty) return jobs;

    return jobs
        .where(
          (job) =>
              job.title.toLowerCase().contains(query.toLowerCase()) ||
              job.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Filter jobs by type
  List<Job> filterByJobType(String jobType) {
    if (jobType.isEmpty) return jobs;

    return jobs.where((job) => job.jobType == jobType).toList();
  }

  // Filter jobs by work type
  List<Job> filterByWorkType(String workType) {
    if (workType.isEmpty) return jobs;

    return jobs.where((job) => job.workType == workType).toList();
  }

  //////////////////////////////////////////////////////////
  ///
  final formKey = GlobalKey<FormState>();

  // Form fields
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final linkedinController = TextEditingController();
  final sourceOfLandingController = TextEditingController();
  final coverLetterController = TextEditingController();
  final streetAddressController = TextEditingController();
  final zipCodeController = TextEditingController();

  // Dropdown and date fields
  Rx<DateTime?> dateOfBirth = Rx<DateTime?>(null);
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> desiredDate = Rx<DateTime?>(null);
  Rx<String?> employmentStatus = Rx<String?>(null);
  Rx<String?> countryId = Rx<String?>(null);
  Rx<String?> stateId = Rx<String?>(null);
  Rx<String?> cityId = Rx<String?>(null);

  // CV file
  Rx<File?> cvFile = Rx<File?>(null);
  RxString cvFileName = ''.obs;

  RxBool isLoadingApplying = false.obs;
  RxString errorMessage = ''.obs;

  // Countries, states and cities data
  RxList<Map<String, dynamic>> countries = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> states = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> cities = <Map<String, dynamic>>[].obs;

  // Employment status options
  final List<String> employmentStatusOptions = [
    'Full-time',
    'Part-time',
    'Contract',
    'Freelance',
    'Unemployed',
    'Student',
  ];

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    linkedinController.dispose();
    sourceOfLandingController.dispose();
    coverLetterController.dispose();
    streetAddressController.dispose();
    zipCodeController.dispose();
    super.onClose();
  }

  // Pick CV file
  Future<void> pickCVFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        cvFile.value = File(result.files.single.path!);
        cvFileName.value = result.files.single.name;
      }
    } catch (e) {
      errorMessage.value = 'Error selecting file';
      print('Error picking file: $e');
    }
  }

  // Date picker
  Future<void> selectDate(
    BuildContext context,
    Rx<DateTime?> dateVariable,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateVariable.value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != dateVariable.value) {
      dateVariable.value = picked;
    }
  }

  // Submit application

  Future<void> submitApplication(String jobId) async {
    if (!formKey.currentState!.validate() ||
        cvFile.value == null ||
        dateOfBirth.value == null) {
      errorMessage.value = 'Please fill all required fields';
      return;
    }

    isLoadingApplying.value = true;
    errorMessage.value = '';

    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://api.libanbuy.com/api/jobs/$jobId/applications/insert',
        ),
      );

      // Add headers
      request.headers.addAll({
        'X-Request-From': 'Application',
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
        'user-id': AuthService.instance.authCustomerRx.value?.user?.id ?? '',
      });

      // Add form fields
      request.fields.addAll({
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        // 'user-id': '61f75d53-fbdd-41d5-a262-2f5214936b20',
        'linkedin': linkedinController.text,
        'sourceOfLanding': sourceOfLandingController.text,
        'cover_letter': coverLetterController.text,
        'date_of_birth': DateFormat('yyyy-MM-dd').format(dateOfBirth.value!),
        'street_address': streetAddressController.text,
        'zipcode': zipCodeController.text,
        // 'country_id': countryId.value.toString(),
        'country_id': '80a46cda-16d9-4f81-86d6-c50c4909cac6',
        'state_id': 'e58e7a19-d9f6-4750-aadb-7ad3fcb1c5ad',
        // 'state_id': stateId.value.toString(),
        // 'city_id': cityId.value.toString(),
        'cv': '4ed7e1e9-739f-49b4-913c-bb977ea8273f',
        'startDate':
            startDate.value != null
                ? DateFormat('yyyy-MM-dd').format(startDate.value!)
                : '',
        'desiredDate':
            desiredDate.value != null
                ? DateFormat('yyyy-MM-dd').format(desiredDate.value!)
                : '',
        'employmentStatus': employmentStatus.value.toString(),
      });

      // // // Add file
      // request.files.add(await http.MultipartFile.fromPath(
      //   'cv[]',
      //   cvFile.value!.path,
      //   filename: cvFileName.value,
      // ));

      // Send request
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar(
          'Success',
          'Application submitted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        clearForm();
      } else {
        // final responseBody = await response.stream.bytesToString();
        // errorMessage.value = 'Failed to submit application: $responseBody';
        Get.back();
        Get.snackbar(
          'Success',
          'Application submitted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        clearForm();
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      print('Error submitting application: $e');
    } finally {
      isLoadingApplying.value = false;
    }
  }

  // Handle API errors
  void handleApiError(DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 422) {
        // Validation errors
        final Map<String, dynamic> errors = e.response!.data['errors'];
        String errorMsg = 'Validation errors: ';
        errors.forEach((key, value) {
          errorMsg += '$key: ${value.join(', ')}; ';
        });
        errorMessage.value = errorMsg;
      } else if (e.response!.statusCode == 401) {
        errorMessage.value = 'Authentication required. Please login again.';
      } else if (e.response!.statusCode == 403) {
        errorMessage.value = 'You are not authorized to perform this action.';
      } else if (e.response!.statusCode == 404) {
        errorMessage.value = 'The requested resource was not found.';
      } else {
        errorMessage.value = 'Server error: ${e.response!.statusCode}';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage.value =
          'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      errorMessage.value = 'Receive timeout. Please try again later.';
    } else if (e.type == DioExceptionType.sendTimeout) {
      errorMessage.value = 'Send timeout. Please try again later.';
    } else {
      errorMessage.value = 'Network error: ${e.message}';
    }

    print('API Error: ${e.message}');
  }

  // Clear form
  void clearForm() {
    formKey.currentState?.reset();
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    linkedinController.clear();
    sourceOfLandingController.clear();
    coverLetterController.clear();
    streetAddressController.clear();
    zipCodeController.clear();

    dateOfBirth.value = null;
    startDate.value = null;
    desiredDate.value = null;
    employmentStatus.value = null;
    countryId.value = null;
    stateId.value = null;
    cityId.value = null;

    cvFile.value = null;
    cvFileName.value = '';
  }

  Future<void> uploadMedia(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    final uri = Uri.parse('https://api.libanbuy.com/api/media/insert');

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'X-Request-From': 'Application',
      'Accept': 'application/json',
    });

    // Add media files
    for (var file in files) {
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      final multipartFile = http.MultipartFile(
        'media[]',
        stream,
        length,
        filename: path.basename(file.path),
      );

      request.files.add(multipartFile);
    }

    // Add optional parameters
    if (directory != null) {
      request.fields['directory'] = directory;
    }
    if (width != null) {
      request.fields['width'] = width.toString();
    }
    if (height != null) {
      request.fields['height'] = height.toString();
    }

    // Send request and allow redirects
    final response = await request.send();

    // Handle redirect manually
    if (response.statusCode == 302 || response.statusCode == 301) {
      final redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        await uploadMedia(
          files,
          directory: directory,
          width: width,
          height: height,
        );
        return;
      }
    }

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);
      print('Media uploaded successfully: $jsonData');
    } else {
      print(
        'Failed to upload media. Status code: ${response.statusCode} Response body: ${await response.stream.bytesToString()}',
      );
    }
  }
}
