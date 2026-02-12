import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/modules/modules_customer/tjara_contests/model/contest_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

// Add your ContestModel and related classes here if not imported
// import 'package:your_app/models/contest_model.dart';

class QuizForm extends StatefulWidget {
  final ContestModel? contestModel; // Add this parameter for edit mode
  final String? contestId; // Add this parameter for edit mode with just ID

  const QuizForm({super.key, this.contestModel, this.contestId});

  @override
  State<QuizForm> createState() => _QuizFormState();
}

class _QuizFormState extends State<QuizForm> {
  late final QuizController controller;
  final _formKey = GlobalKey<FormState>();
  String? thumbnailId;
  File? thumbnailFile;
  bool _isUploading = false;
  bool _isSubmitting = false;
  bool _isLoadingContest = false;
  bool get isEditMode =>
      widget.contestModel != null || widget.contestId != null;
  ContestModel? _currentContestModel;

  // Form focus nodes for better navigation
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _winnerIdFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    if (widget.contestId != null) {
      // If only contestId is provided, fetch the full contest data
      await _fetchContestData(widget.contestId!);
    } else {
      _currentContestModel = widget.contestModel;
    }

    // Initialize controller with contest model if in edit mode
    controller = Get.put(QuizController(contestModel: _currentContestModel));

    if (!isEditMode) {
      // Initialize date/time pickers with default values for create mode
      controller.startTime.text = DateFormat(
        'yyyy-MM-dd HH:mm',
      ).format(DateTime.now().add(const Duration(days: 1)));
      controller.endTime.text = DateFormat(
        'yyyy-MM-dd HH:mm',
      ).format(DateTime.now().add(const Duration(days: 8)));
    } else {
      // In edit mode, thumbnail info is already loaded from the model
      thumbnailId = _currentContestModel?.thumbnailId;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetchContestData(String contestId) async {
    try {
      setState(() => _isLoadingContest = true);

      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/contests/$contestId'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _currentContestModel = ContestModel.fromJson(responseData['contest']);
      } else {
        throw Exception('Failed to load contest');
      }
    } catch (e) {
      _showErrorSnackBar('Error loading contest: $e');
      // Navigate back if we can't load the contest
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      setState(() => _isLoadingContest = false);
    }
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    _winnerIdFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isUploading = true);

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);

        // Validate file size (max 5MB)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          _showErrorSnackBar(
            'Image too large. Please select an image under 5MB',
          );
          setState(() => _isUploading = false);
          return;
        }

        // Upload file
        await _uploadMedia([file]).then((mediaIds) {
          if (mediaIds.isNotEmpty) {
            setState(() {
              thumbnailFile = file;
              thumbnailId = mediaIds.first;
            });
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showMediaPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _mediaSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _mediaSourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _mediaSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF196A30)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<String> uploadMedia(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    try {
      final uri = Uri.parse('https://api.libanbuy.com/api/media/insert');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'X-Request-From': 'Application',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
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

      // Check internet connectivity
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw Exception('No internet connection');
      }

      // Send request and allow redirects
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Connection timed out. Please try again.');
        },
      );

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

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonData = jsonDecode(responseBody);
        return jsonData['media'][0]['id'];
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'Failed to upload media. Status code: ${response.statusCode} Response: $errorBody',
        );
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception(
          'Network error. Please check your connection and try again.',
        );
      } else if (e is TimeoutException) {
        throw Exception('Connection timed out. Please try again.');
      } else {
        throw Exception('Error uploading media: $e');
      }
    }
  }

  Future<List<String>> _uploadMedia(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    final List<String> mediaIds = [];
    try {
      final String id = await uploadMedia(
        files,
        directory: directory,
        width: width,
        height: height,
      );
      mediaIds.add(id);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
    return mediaIds;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _showDateTimePicker({
    required BuildContext context,
    required TextEditingController controller,
    required String title,
    DateTime? initialDate,
    DateTime? firstDate,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF196A30),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF196A30),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        controller.text = DateFormat(
          'yyyy-MM-dd HH:mm',
        ).format(combinedDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.teal, Color(0xFFFACC15)],
    );

    // Show loading screen while fetching contest data
    if (_isLoadingContest) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Loading...',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF196A30)),
              const SizedBox(height: 16),
              Text(
                'Loading contest data...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Show error screen if controller is not initialized yet
    if (!Get.isRegistered<QuizController>()) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Error', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load quiz data',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

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
                        isEditMode ? 'Edit Quiz' : 'Create New Quiz',
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
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Info Card
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Quiz Information',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    isEditMode
                                        ? 'Update your quiz details, questions, and settings.'
                                        : 'Create a new quiz to engage your audience. Add questions, set a timeline, and make it featured if needed.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Basic Information Card
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.title,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Basic Information',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: controller.name,
                                        focusNode: _nameFocus,
                                        decoration: InputDecoration(
                                          labelText: "Quiz Name",
                                          prefixIcon: const Icon(Icons.title),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a quiz name';
                                          }
                                          if (value.length < 3) {
                                            return 'Name must be at least 3 characters';
                                          }
                                          return null;
                                        },
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) {
                                          FocusScope.of(
                                            context,
                                          ).requestFocus(_descriptionFocus);
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: controller.description,
                                        focusNode: _descriptionFocus,
                                        decoration: InputDecoration(
                                          labelText: "Description",
                                          prefixIcon: const Icon(
                                            Icons.description,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        maxLines: 3,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) {
                                          FocusScope.of(
                                            context,
                                          ).requestFocus(_winnerIdFocus);
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: controller.winnerId,
                                        focusNode: _winnerIdFocus,
                                        decoration: InputDecoration(
                                          labelText: "Winner ID (Optional)",
                                          prefixIcon: const Icon(
                                            Icons.emoji_events,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          hintText:
                                              "Leave empty for no winner yet",
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Obx(
                                        () => SwitchListTile(
                                          value: controller.isFeatured.value,
                                          title: const Text("Featured Quiz"),
                                          subtitle: const Text(
                                            "Featured quizzes appear on the home page",
                                          ),
                                          secondary: Icon(
                                            Icons.star,
                                            color:
                                                controller.isFeatured.value
                                                    ? Colors.amber
                                                    : Colors.grey,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            side: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          onChanged:
                                              (val) =>
                                                  controller.isFeatured.value =
                                                      val,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Media Upload Card
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Quiz Thumbnail',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'A high-quality image can significantly impact your quiz\'s appeal. Upload a clear, engaging thumbnail that represents your quiz content.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      GestureDetector(
                                        onTap:
                                            _isUploading
                                                ? null
                                                : _showMediaPickerBottomSheet,
                                        child: Container(
                                          height: 180,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  (thumbnailFile == null &&
                                                              !isEditMode) ||
                                                          (isEditMode &&
                                                              thumbnailId ==
                                                                  null)
                                                      ? Colors.grey.shade300
                                                      : Colors.transparent,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color:
                                                (thumbnailFile == null &&
                                                            !isEditMode) ||
                                                        (isEditMode &&
                                                            thumbnailId == null)
                                                    ? Colors.grey.shade100
                                                    : null,
                                            boxShadow:
                                                (thumbnailFile != null ||
                                                        (isEditMode &&
                                                            thumbnailId !=
                                                                null))
                                                    ? [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ]
                                                    : null,
                                          ),
                                          child:
                                              _isUploading
                                                  ? const Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        CircularProgressIndicator(),
                                                        SizedBox(height: 16),
                                                        Text(
                                                          'Uploading image...',
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  : (thumbnailFile == null &&
                                                      (!isEditMode ||
                                                          thumbnailId == null))
                                                  ? Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .cloud_upload_rounded,
                                                          size: 48,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade400,
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        Text(
                                                          isEditMode
                                                              ? 'Tap to change thumbnail'
                                                              : 'Tap to upload thumbnail',
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade600,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          'Recommended size: 1200 × 630 pixels',
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade500,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  : Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        child:
                                                            thumbnailFile !=
                                                                    null
                                                                ? Image.file(
                                                                  thumbnailFile!,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                )
                                                                : (isEditMode &&
                                                                    _currentContestModel
                                                                            ?.thumbnail
                                                                            ?.media
                                                                            ?.url !=
                                                                        null)
                                                                ? Image.network(
                                                                  _currentContestModel!
                                                                      .thumbnail!
                                                                      .media!
                                                                      .url!,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                  errorBuilder: (
                                                                    context,
                                                                    error,
                                                                    stackTrace,
                                                                  ) {
                                                                    return Container(
                                                                      color:
                                                                          Colors
                                                                              .grey
                                                                              .shade200,
                                                                      child: Icon(
                                                                        Icons
                                                                            .broken_image,
                                                                        size:
                                                                            48,
                                                                        color:
                                                                            Colors.grey.shade400,
                                                                      ),
                                                                    );
                                                                  },
                                                                )
                                                                : Container(
                                                                  color:
                                                                      Colors
                                                                          .grey
                                                                          .shade200,
                                                                  child: Icon(
                                                                    Icons.image,
                                                                    size: 48,
                                                                    color:
                                                                        Colors
                                                                            .grey
                                                                            .shade400,
                                                                  ),
                                                                ),
                                                      ),
                                                      Positioned(
                                                        top: 8,
                                                        right: 8,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                      0.5,
                                                                    ),
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed:
                                                                _showMediaPickerBottomSheet,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                        ),
                                      ),
                                      if ((thumbnailFile == null &&
                                              !isEditMode) ||
                                          (isEditMode && thumbnailId == null))
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            'Thumbnail image is required',
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Date Time Section Card
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Quiz Schedule',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            () => _showDateTimePicker(
                                              context: context,
                                              controller: controller.startTime,
                                              title: 'Select Start Date & Time',
                                              initialDate: DateTime.now().add(
                                                const Duration(days: 1),
                                              ),
                                              firstDate: DateTime.now(),
                                            ),
                                        child: AbsorbPointer(
                                          child: TextFormField(
                                            controller: controller.startTime,
                                            decoration: InputDecoration(
                                              labelText: "Start Date & Time",
                                              prefixIcon: const Icon(
                                                Icons.event,
                                              ),
                                              suffixIcon: const Icon(
                                                Icons.arrow_drop_down,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please select start date and time';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      GestureDetector(
                                        onTap: () {
                                          DateTime? startDateTime;
                                          try {
                                            if (controller
                                                .startTime
                                                .text
                                                .isNotEmpty) {
                                              startDateTime = DateFormat(
                                                'yyyy-MM-dd HH:mm',
                                              ).parse(
                                                controller.startTime.text,
                                              );
                                            }
                                          } catch (e) {
                                            startDateTime = DateTime.now().add(
                                              const Duration(days: 1),
                                            );
                                          }

                                          _showDateTimePicker(
                                            context: context,
                                            controller: controller.endTime,
                                            title: 'Select End Date & Time',
                                            initialDate:
                                                startDateTime?.add(
                                                  const Duration(days: 7),
                                                ) ??
                                                DateTime.now().add(
                                                  const Duration(days: 8),
                                                ),
                                            firstDate:
                                                startDateTime ??
                                                DateTime.now().add(
                                                  const Duration(days: 1),
                                                ),
                                          );
                                        },
                                        child: AbsorbPointer(
                                          child: TextFormField(
                                            controller: controller.endTime,
                                            decoration: InputDecoration(
                                              labelText: "End Date & Time",
                                              prefixIcon: const Icon(
                                                Icons.event_available,
                                              ),
                                              suffixIcon: const Icon(
                                                Icons.arrow_drop_down,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please select end date and time';
                                              }

                                              try {
                                                final DateTime start =
                                                    DateFormat(
                                                      'yyyy-MM-dd HH:mm',
                                                    ).parse(
                                                      controller.startTime.text,
                                                    );
                                                final DateTime end = DateFormat(
                                                  'yyyy-MM-dd HH:mm',
                                                ).parse(value);

                                                if (end.isBefore(start)) {
                                                  return 'End time must be after start time';
                                                }
                                              } catch (e) {
                                                return 'Invalid date format';
                                              }

                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Questions Section Card
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final bool isNarrow =
                                          constraints.maxWidth < 500;
                                      const Widget left = Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.quiz,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Quiz Questions',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ],
                                      );
                                      final Widget addBtn = ElevatedButton.icon(
                                        onPressed: controller.addQuestion,
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text("Add Question"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(
                                            0xFFF97316,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                      if (isNarrow) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            left,
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: addBtn,
                                            ),
                                          ],
                                        );
                                      }
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Flexible(child: left),
                                          addBtn,
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Obx(
                                    () =>
                                        controller.questions.isEmpty
                                            ? SizedBox(
                                              height: 200,
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.quiz,
                                                      size: 64,
                                                      color: Colors.grey[400],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'No questions added yet',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      isEditMode
                                                          ? 'Add questions to update your quiz!'
                                                          : 'Add your first question to get started!',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            : ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  controller.questions.length,
                                              itemBuilder: (_, index) {
                                                return _buildQuestionCard(
                                                  index,
                                                );
                                              },
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: controller.requiredtrue,

                                    decoration: InputDecoration(
                                      labelText:
                                          "Required Number of Correct Answers",
                                      prefixIcon: const Icon(
                                        Icons.emoji_events,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      hintText:
                                          "Required Number of Correct Answers",
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: controller.prize,

                                    decoration: InputDecoration(
                                      labelText: "Contest Prize",
                                      prefixIcon: const Icon(
                                        Icons.emoji_events,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      hintText: "contest Prize",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Submit Button
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF0D9488,
                                ), // Teal color
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  _isSubmitting
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            isEditMode
                                                ? "Updating..."
                                                : "Submitting...",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )
                                      : Text(
                                        isEditMode
                                            ? "Update Quiz"
                                            : "Submit Quiz",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                            ),
                          ),
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

  Widget _buildQuestionCard(int index) {
    final q = controller.questions[index];
    final bool isExpanded = controller.expandedQuestions[index] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Question ${index + 1}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      q.question.text.isEmpty
                          ? "No question text yet"
                          : q.question.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: const Color(0xFF196A30),
                    ),
                    onPressed: () => controller.toggleQuestionExpanded(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteQuestionDialog(index),
                  ),
                ],
              ),
            ],
          ),
          Obx(() {
            final isExpanded = controller.expandedQuestions[index] ?? false;
            return AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                height: isExpanded ? null : 0,
                child:
                    isExpanded
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: q.question,
                              decoration: InputDecoration(
                                labelText: "Question",
                                hintText: "Enter your question here",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.help_outline),
                              ),
                              maxLines: null,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Question text is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildOptionField(
                              q.option1,
                              "Option 1",
                              Icons.looks_one,
                            ),
                            const SizedBox(height: 12),
                            _buildOptionField(
                              q.option2,
                              "Option 2",
                              Icons.looks_two,
                            ),
                            const SizedBox(height: 12),
                            _buildOptionField(
                              q.option3,
                              "Option 3",
                              Icons.looks_3,
                            ),
                            const SizedBox(height: 12),
                            _buildOptionField(
                              q.option4,
                              "Option 4",
                              Icons.looks_4,
                            ),
                            const SizedBox(height: 16),
                            FormField<String>(
                              initialValue: q.correctAnswer.text,
                              validator: (value) {
                                if (q.correctAnswer.text.isEmpty) {
                                  return 'Please select the correct answer';
                                }
                                return null;
                              },
                              builder: (FormFieldState<String> field) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Correct Answer',
                                    errorText: field.errorText,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.check_circle_outline,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value:
                                          q.correctAnswer.text.isEmpty
                                              ? null
                                              : q.correctAnswer.text,
                                      isDense: true,
                                      isExpanded: true,
                                      hint: const Text("Select correct answer"),
                                      items: [
                                        if (q.option1.text.isNotEmpty)
                                          DropdownMenuItem(
                                            value: q.option1.text,
                                            child: Text(
                                              "Option 1: ${q.option1.text}",
                                            ),
                                          ),
                                        if (q.option2.text.isNotEmpty)
                                          DropdownMenuItem(
                                            value: q.option2.text,
                                            child: Text(
                                              "Option 2: ${q.option2.text}",
                                            ),
                                          ),
                                        if (q.option3.text.isNotEmpty)
                                          DropdownMenuItem(
                                            value: q.option3.text,
                                            child: Text(
                                              "Option 3: ${q.option3.text}",
                                            ),
                                          ),
                                        if (q.option4.text.isNotEmpty)
                                          DropdownMenuItem(
                                            value: q.option4.text,
                                            child: Text(
                                              "Option 4: ${q.option4.text}",
                                            ),
                                          ),
                                      ],
                                      onChanged: (newValue) {
                                        if (newValue != null) {
                                          q.correctAnswer.text = newValue;
                                          field.didChange(newValue);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  void _showDeleteQuestionDialog(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Question'),
            content: Text(
              'Are you sure you want to delete Question ${index + 1}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.removeQuestion(index);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );
  }

  Future<void> _submitQuiz() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please correct the errors in the form');
      return;
    }

    // Check if thumbnail is selected (for create mode) or exists (for edit mode)
    if (!isEditMode && (thumbnailId == null || thumbnailFile == null)) {
      _showErrorSnackBar('Thumbnail image is required');
      return;
    }

    if (isEditMode && thumbnailId == null) {
      _showErrorSnackBar('Thumbnail image is required');
      return;
    }

    // Check if questions are added
    if (controller.questions.isEmpty) {
      _showErrorSnackBar('Please add at least one question');
      return;
    }

    // Validate all questions
    for (int i = 0; i < controller.questions.length; i++) {
      final q = controller.questions[i];
      if (!q.isValid()) {
        _showErrorSnackBar('Question ${i + 1} is incomplete');
        controller.expandedQuestions[i] = true;
        return;
      }
    }

    try {
      setState(() => _isSubmitting = true);

      // Validate date format
      DateTime? startDateTime;
      DateTime? endDateTime;
      try {
        startDateTime = DateFormat(
          'yyyy-MM-dd HH:mm',
        ).parse(controller.startTime.text);
        endDateTime = DateFormat(
          'yyyy-MM-dd HH:mm',
        ).parse(controller.endTime.text);

        if (endDateTime.isBefore(startDateTime)) {
          throw Exception('End time must be after start time');
        }
      } catch (e) {
        _showErrorSnackBar('Invalid date format: $e');
        setState(() => _isSubmitting = false);
        return;
      }

      if (isEditMode) {
        await controller.updates(_currentContestModel!.id!, thumbnailId!);
      } else {
        await controller.submit(thumbnailId!);
      }

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Success'),
                ],
              ),
              content: Text(
                isEditMode
                    ? 'Your quiz has been successfully updated!'
                    : 'Your quiz has been successfully created!',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF196A30),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      _showErrorSnackBar(
        isEditMode ? 'Error updating quiz: $e' : 'Error submitting quiz: $e',
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

class QuizController extends GetxController {
  final ContestModel? contestModel;

  final name = TextEditingController();
  final prize = TextEditingController();
  final requiredtrue = TextEditingController();
  final description = TextEditingController();
  final winnerId = TextEditingController();
  final startTime = TextEditingController();
  final endTime = TextEditingController();
  final isFeatured = false.obs;
  final questions = <QuestionForm>[].obs;
  final expandedQuestions = <int, bool>{}.obs;

  QuizController({this.contestModel}) {
    if (contestModel != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    if (contestModel == null) return;

    // Populate basic information
    name.text = contestModel!.name ?? '';
    description.text = contestModel!.description ?? '';
    winnerId.text = contestModel!.winnerId ?? '';
    isFeatured.value = contestModel!.isFeatured ?? false;

    // Populate date/time fields
    if (contestModel!.startTime != null) {
      try {
        final DateTime startDateTime = DateTime.parse(contestModel!.startTime!);
        startTime.text = DateFormat('yyyy-MM-dd HH:mm').format(startDateTime);
      } catch (e) {
        startTime.text = '';
      }
    }

    if (contestModel!.endTime != null) {
      try {
        final DateTime endDateTime = DateTime.parse(contestModel!.endTime!);
        endTime.text = DateFormat('yyyy-MM-dd HH:mm').format(endDateTime);
      } catch (e) {
        endTime.text = '';
      }
    }

    // Populate questions
    if (contestModel!.questions != null &&
        contestModel!.questions!.isNotEmpty) {
      questions.clear();
      for (var question in contestModel!.questions!) {
        final questionForm = QuestionForm();
        questionForm.question.text = question.question ?? '';
        questionForm.option1.text = question.option1 ?? '';
        questionForm.option2.text = question.option2 ?? '';
        questionForm.option3.text = question.option3 ?? '';
        questionForm.option4.text = question.option4 ?? '';
        questionForm.correctAnswer.text = question.correctAnswer ?? '';
        questions.add(questionForm);
      }
    }
  }

  void addQuestion() {
    final index = questions.length;
    questions.add(QuestionForm());
    expandedQuestions[index] = true;
  }

  void removeQuestion(int index) {
    if (questions.isNotEmpty) {
      questions.removeAt(index);
      // Update expandedQuestions map
      for (int i = index; i < questions.length; i++) {
        expandedQuestions[i] = expandedQuestions[i + 1] ?? false;
      }
      expandedQuestions.remove(questions.length);
    }
  }

  void toggleQuestionExpanded(int index) {
    expandedQuestions[index] = !(expandedQuestions[index] ?? false);
  }

  Future<void> submit(String thumbnailId) async {
    await _performRequest(
      url: 'https://api.libanbuy.com/api/contests/insert',
      method: 'POST',
      thumbnailId: thumbnailId,
    );
  }

  Future<void> updates(String contestId, String thumbnailId) async {
    await _performRequest(
      url: 'https://api.libanbuy.com/api/contests/$contestId/update',
      method: 'PUT',
      thumbnailId: thumbnailId,
    );
  }

  Future<void> _performRequest({
    required String url,
    required String method,
    required String thumbnailId,
  }) async {
    try {
      // Validate input
      if (name.text.isEmpty ||
          questions.isEmpty ||
          questions.any((q) => !q.isValid())) {
        throw Exception("Please complete all required fields");
      }

      // Check network connection
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (!connectivityResult.contains(ConnectivityResult.none)) {
        throw Exception('No internet connection');
      }

      final payload = {
        "name": name.text,
        "description": description.text,
        "thumbnail_id": thumbnailId,
        "winner_id": winnerId.text.isEmpty ? null : winnerId.text,
        "is_featured": isFeatured.value,
        "start_time": startTime.text,
        "end_time": endTime.text,
        "questions": questions.map((q) => q.toJson()).toList(),
        "meta": [
          {"required_correct_answers": requiredtrue.text},
          {"contest_prize_details": prize.text},
        ],
      };

      http.Response response;
      if (method == 'POST') {
        response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'shop-id':
                    AuthService.instance.authCustomer?.user?.shop?.shop?.id ??
                    '',
                'X-Request-From': 'Application',
              },
              body: jsonEncode(payload),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw TimeoutException(
                  'Connection timed out. Please try again.',
                );
              },
            );
      } else {
        // PUT request for update
        response = await http
            .put(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'shop-id':
                    AuthService.instance.authCustomer?.user?.shop?.shop?.id ??
                    '',
                'X-Request-From': 'Application',
              },
              body: jsonEncode(payload),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw TimeoutException(
                  'Connection timed out. Please try again.',
                );
              },
            );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        return;
      } else {
        // Try to parse error message
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Unknown error occurred';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception(
            'Failed to ${method == 'POST' ? 'submit' : 'update'} quiz. Status code: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception(
          'Network error. Please check your connection and try again.',
        );
      } else if (e is TimeoutException) {
        throw Exception('Connection timed out. Please try again.');
      } else {
        rethrow;
      }
    }
  }

  @override
  void onClose() {
    name.dispose();
    description.dispose();
    winnerId.dispose();
    startTime.dispose();
    endTime.dispose();
    for (var question in questions) {
      question.dispose();
    }
    super.onClose();
  }
}

class QuestionForm {
  final question = TextEditingController();
  final option1 = TextEditingController();
  final option2 = TextEditingController();
  final option3 = TextEditingController();
  final option4 = TextEditingController();
  final correctAnswer = TextEditingController();

  void dispose() {
    question.dispose();
    option1.dispose();
    option2.dispose();
    option3.dispose();
    option4.dispose();
    correctAnswer.dispose();
  }

  bool isValid() {
    return question.text.isNotEmpty &&
        option1.text.isNotEmpty &&
        option2.text.isNotEmpty &&
        option3.text.isNotEmpty &&
        option4.text.isNotEmpty &&
        correctAnswer.text.isNotEmpty;
  }

  Map<String, String> toJson() {
    return {
      "question": question.text,
      "option_1": option1.text,
      "option_2": option2.text,
      "option_3": option3.text,
      "option_4": option4.text,
      "correct_answer": correctAnswer.text,
    };
  }
}

// Extension for TimeoutException
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
