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
import 'package:tjara/app/services/others/others_service.dart';
import 'package:tjara/app/models/others/country_model.dart';
import 'package:tjara/app/models/others/state_model.dart';
import 'package:tjara/app/models/others/cities_model.dart' as location;

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

  // Countries, states and cities data (typed)
  RxList<Countries> countriesList = <Countries>[].obs;
  RxList<States> statesList = <States>[].obs;
  RxList<location.City> citiesList = <location.City>[].obs;

  // Selected location objects
  Rxn<Countries> selectedCountry = Rxn<Countries>();
  Rxn<States> selectedState = Rxn<States>();
  Rxn<location.City> selectedCity = Rxn<location.City>();

  // Loading states for location dropdowns
  RxBool isLoadingCountries = false.obs;
  RxBool isLoadingStates = false.obs;
  RxBool isLoadingCities = false.obs;

  // Legacy Map-based lists (for backward compatibility)
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
      // Step 1: Upload CV file first
      String? cvMediaId;
      if (cvFile.value != null) {
        debugPrint('Uploading CV file...');
        cvMediaId = await uploadMedia([cvFile.value!], directory: 'cv');
        if (cvMediaId == null) {
          errorMessage.value = 'Failed to upload CV. Please try again.';
          isLoadingApplying.value = false;
          return;
        }
        debugPrint('CV uploaded successfully. Media ID: $cvMediaId');
      }

      // Step 2: Create multipart request for application
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
        'linkedin': linkedinController.text,
        'sourceOfLanding': sourceOfLandingController.text,
        'cover_letter': coverLetterController.text,
        'date_of_birth': DateFormat('yyyy-MM-dd').format(dateOfBirth.value!),
        'street_address': streetAddressController.text,
        'zipcode': zipCodeController.text,
        'country_id': countryId.value ?? '',
        'state_id': stateId.value ?? '',
        'city_id': cityId.value ?? '',
        'cv': cvMediaId ?? '',
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

      // Send request
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar(
          'Success',
          'Application submitted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        clearForm();
      } else {
        // Parse error response
        final responseBody = await response.stream.bytesToString();
        String errorMsg = 'Failed to submit application';

        try {
          final jsonResponse = jsonDecode(responseBody);
          if (jsonResponse['message'] != null) {
            errorMsg = jsonResponse['message'].toString();
          } else if (jsonResponse['error'] != null) {
            errorMsg = jsonResponse['error'].toString();
          } else if (jsonResponse['errors'] != null) {
            final errors = jsonResponse['errors'];
            if (errors is Map) {
              final errorList = <String>[];
              errors.forEach((key, value) {
                if (value is List) {
                  errorList.add('$key: ${value.join(', ')}');
                } else {
                  errorList.add('$key: $value');
                }
              });
              errorMsg = errorList.join('\n');
            }
          }
        } catch (_) {
          // If response is not JSON, use the raw response
          if (responseBody.isNotEmpty) {
            errorMsg = responseBody;
          }
        }

        errorMessage.value = errorMsg;
        debugPrint('Submit application failed. Status: ${response.statusCode}, Body: $responseBody');

        Get.snackbar(
          'Submission Failed',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      const errorMsg = 'An unexpected error occurred. Please try again.';
      errorMessage.value = errorMsg;
      debugPrint('Error submitting application: $e');

      Get.snackbar(
        'Error',
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
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
    selectedCountry.value = null;
    selectedState.value = null;
    selectedCity.value = null;

    cvFile.value = null;
    cvFileName.value = '';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATION DATA LOADING METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> loadCountries() async {
    try {
      isLoadingCountries.value = true;

      // Check cache first
      if (CountryService.instance.countryList.isNotEmpty) {
        countriesList.value = CountryService.instance.countryList;
      } else {
        await CountryService.instance.fetchCountries();
        countriesList.value = CountryService.instance.countryList;
      }
    } catch (e) {
      debugPrint('Error loading countries: $e');
    } finally {
      isLoadingCountries.value = false;
    }
  }

  Future<void> onCountryChanged(Countries? country) async {
    if (country == null) return;

    selectedCountry.value = country;
    countryId.value = country.id.toString();

    // Clear state and city
    selectedState.value = null;
    selectedCity.value = null;
    stateId.value = null;
    cityId.value = null;
    statesList.clear();
    citiesList.clear();

    // Load states for selected country
    await loadStates(country.id.toString());
  }

  Future<void> loadStates(String countryId) async {
    try {
      isLoadingStates.value = true;
      statesList.clear();

      await CountryService.instance.fetchStates(countryId);
      statesList.value = CountryService.instance.stateList;
    } catch (e) {
      debugPrint('Error loading states: $e');
    } finally {
      isLoadingStates.value = false;
    }
  }

  Future<void> onStateChanged(States? state) async {
    if (state == null) return;

    selectedState.value = state;
    stateId.value = state.id.toString();

    // Clear city
    selectedCity.value = null;
    cityId.value = null;
    citiesList.clear();

    // Load cities for selected state
    await loadCities(state.id.toString());
  }

  Future<void> loadCities(String stateId) async {
    try {
      isLoadingCities.value = true;
      citiesList.clear();

      await CountryService.instance.fetchCities(stateId);
      citiesList.value = CountryService.instance.cityList;
    } catch (e) {
      debugPrint('Error loading cities: $e');
    } finally {
      isLoadingCities.value = false;
    }
  }

  void onCityChanged(location.City? city) {
    if (city == null) return;

    selectedCity.value = city;
    cityId.value = city.id.toString();
  }

  /// Uploads media file and returns the media ID on success, null on failure
  Future<String?> uploadMedia(
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
        return await uploadMedia(
          files,
          directory: directory,
          width: width,
          height: height,
        );
      }
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);
      debugPrint('Media uploaded successfully: $jsonData');

      // Extract media ID from response
      // Response format: {"data": [{"id": "uuid-here", ...}]} or {"data": {"id": "uuid-here", ...}}
      if (jsonData['data'] != null) {
        if (jsonData['data'] is List && (jsonData['data'] as List).isNotEmpty) {
          return jsonData['data'][0]['id']?.toString();
        } else if (jsonData['data'] is Map) {
          return jsonData['data']['id']?.toString();
        }
      }
      // Try direct id field
      if (jsonData['id'] != null) {
        return jsonData['id'].toString();
      }
      return null;
    } else {
      debugPrint(
        'Failed to upload media. Status code: ${response.statusCode} Response body: ${await response.stream.bytesToString()}',
      );
      return null;
    }
  }
}
