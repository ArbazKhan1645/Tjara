// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/others/cities_model.dart' show City;
import 'package:tjara/app/models/others/country_model.dart';
import 'package:tjara/app/models/others/state_model.dart';
import 'package:tjara/app/modules/admin/services_admin/insert/attributes_model.dart';
import 'package:tjara/app/modules/services/model/sevices_model.dart'
    show ServiceData;
import 'package:tjara/app/services/others/others_service.dart';
import 'package:tjara/main.dart';

class InsertServiceScreen extends StatefulWidget {
  final ServiceData? serviceData; // Add this parameter for edit mode

  const InsertServiceScreen({super.key, this.serviceData});

  @override
  State<InsertServiceScreen> createState() => _InsertServiceScreenState();
}

class _InsertServiceScreenState extends State<InsertServiceScreen> {
  List<ServiceAttributeItem> _parentAttributes = [];

  // Check if it's edit mode
  bool get isEditMode => widget.serviceData != null;

  Future<void> _fetchAttributes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/service-attributes'),
        headers: {
          'X-Request-From': 'Application',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<ServiceAttribute> attributes = [];
        final List<ServiceAttributeItem> parentAttributes = [];

        for (var item in jsonData['service_attributes']) {
          final attribute = ServiceAttribute.fromJson(item);
          attributes.add(attribute);

          // Add to parent list if it can be a parent
          parentAttributes.addAll(
            attribute.attributeItems!.serviceAttributeItems!,
          );
        }

        setState(() {
          _parentAttributes = parentAttributes;
          _isLoading = false;
        });

        // Initialize form with existing data if in edit mode
        if (isEditMode) {
          _initializeFormWithData();
        }
      } else {
        _showErrorSnackbar('Failed to load attributes');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeFormWithData() async {
    if (widget.serviceData != null) {
      final data = widget.serviceData!;

      // Initialize text controllers
      _nameController.text = data.name ?? '';
      _descriptionController.text = data.description ?? '';
      _priceController.text = data.price?.toString() ?? '';
      _salePriceController.text = data.salePrice?.toString() ?? '';

      // Initialize selections
      _selectedCategory = _parentAttributes.firstWhereOrNull(
        (parent) =>
            parent.id == data.categories?.serviceAttributeItems?.first.id,
      );
      _selectedCountry = CountryService.instance.countryList.firstWhereOrNull(
        (country) => country.id.toString() == data.countryId.toString(),
      );
      await CountryService.instance.fetchStates(
        _selectedCountry!.id.toString(),
      );
      _selectedState = CountryService.instance.stateList.firstWhereOrNull(
        (state) => state.id.toString() == data.stateId.toString(),
      );
      setState(() {});

      _selectedTags = [];

      // Initialize media IDs
      thumbnailId = data.thumbnailId;
      videoId = data.thumbnail?.media?.id;
      galleryIds = [];
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _salePriceController = TextEditingController();

  // Selection values
  ServiceAttributeItem? _selectedCategory;
  Countries? _selectedCountry;
  States? _selectedState;
  City? _selectedCity;
  List<String> _selectedTags = [];

  // Media IDs
  String? thumbnailId;
  String? videoId;
  List<String> galleryIds = [];

  // Media files
  File? thumbnailFile;
  File? videoFile;
  List<File> galleryFiles = [];

  // Form sections expanded state
  bool _serviceInfoExpanded = true;
  bool _uploadServiceExpanded = true;
  bool _serviceDetailsExpanded = true;

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    _fetchAttributes();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, {bool isGallery = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);

        setState(() {
          if (isGallery) {
            galleryFiles.add(file);
            _uploadMedia([file]).then((mediaIds) {
              if (mediaIds.isNotEmpty) {
                galleryIds.addAll(mediaIds);
              }
            });
          } else {
            thumbnailFile = file;
            _uploadMedia([file]).then((mediaIds) {
              if (mediaIds.isNotEmpty) {
                thumbnailId = mediaIds.first;
              }
            });
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);

        setState(() {
          videoFile = file;
        });

        final List<String> mediaIds = await _uploadMedia([file]);
        if (mediaIds.isNotEmpty) {
          videoId = mediaIds.first;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking video: $e')));
    }
  }

  Future<List<String>> _uploadMedia(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    final List<String> mediaIds = [];
    final String id = await uploadMedia(
      files,
      directory: directory,
      width: width,
      height: height,
    );
    if (!id.contains('Failed to upload media')) {
      mediaIds.add(id);
    }
    return mediaIds;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (thumbnailId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a thumbnail image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> body = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'thumbnail_id': thumbnailId,
        'is_featured': false,
        'shop_id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
        'price':
            _priceController.text.isNotEmpty
                ? double.tryParse(_priceController.text) ?? 0
                : 0,
        'sale_price':
            _salePriceController.text.isNotEmpty
                ? double.tryParse(_salePriceController.text) ?? 0
                : 0,
      };

      // Add country, state, city if selected
      if (_selectedCountry != null) {
        body['country_id'] = _selectedCountry!.id.toString();
      }

      if (_selectedState != null) {
        body['state_id'] = _selectedState!.id ?? '';
      }

      // Add gallery images if any
      if (galleryIds.isNotEmpty) {
        body['gallery'] = galleryIds;
      }

      // Add video if any
      if (videoId != null) {
        body['video_id'] = videoId;
      }

      // Add categories if any
      if (_selectedCategory != null) {
        body['categories'] = [_selectedCategory!.id];
      }

      // Add tags if any
      if (_selectedTags.isNotEmpty) {
        final List<int> tagIds =
            _selectedTags.map((tag) => [].indexOf(tag) + 1).toList();
        body['tags'] = tagIds;
      }

      print(body);

      // Choose API endpoint based on mode
      String apiUrl;
      String method;
      http.Response response;

      if (isEditMode) {
        apiUrl =
            'https://api.libanbuy.com/api/services/${widget.serviceData!.id}/update';
        method = 'PUT';
        response = await http.put(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'shop-id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
            'X-Request-From': 'Application',
          },
          body: jsonEncode(body),
        );
      } else {
        apiUrl = 'https://api.libanbuy.com/api/services/insert/';
        method = 'POST';
        response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'shop-id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
            'X-Request-From': 'Application',
          },
          body: jsonEncode(body),
        );
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Service updated successfully'
                  : 'Service created successfully',
            ),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage =
            isEditMode
                ? 'Failed to update service'
                : 'Failed to create service';

        if (errorData != null && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEditMode ? 'Edit Service' : 'Add Service', // Dynamic title
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: const BoxDecoration(gradient: expandedStackGradient),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 16,
                      right: 16,
                    ),
                    child: Container(
                      color: Colors.white,
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            // Service Information Section
                            _buildSectionHeader(
                              'Service Information',
                              isExpanded: _serviceInfoExpanded,
                              onTap: () {
                                setState(() {
                                  _serviceInfoExpanded = !_serviceInfoExpanded;
                                });
                              },
                            ),
                            if (_serviceInfoExpanded) ...[
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Service Name',
                                controller: _nameController,
                                isRequired: true,
                                hintText: 'Service name',
                                helperText:
                                    'Enter the unique name of your service. Make it descriptive and easy to remember for customers.',
                              ),
                              const SizedBox(height: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Category'),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xffEAEAEA),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonFormField<
                                      ServiceAttributeItem
                                    >(
                                      initialValue:
                                          _selectedCategory, // Set initial value for edit mode
                                      decoration: const InputDecoration(
                                        labelText: 'Select Category',
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      items:
                                          _parentAttributes.map((
                                            ServiceAttributeItem value,
                                          ) {
                                            return DropdownMenuItem<
                                              ServiceAttributeItem
                                            >(
                                              value: value,
                                              child: Text(
                                                value.name.toString(),
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedCategory = newValue;
                                        });
                                      },
                                      validator:
                                          (value) =>
                                              value == null
                                                  ? 'Please select a Category'
                                                  : null,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),

                              const SizedBox(height: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Countries'),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xffEAEAEA),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonFormField<Countries>(
                                      initialValue:
                                          _selectedCountry, // Set initial value for edit mode
                                      decoration: const InputDecoration(
                                        labelText: 'Select Country',
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      items:
                                          CountryService.instance.countryList
                                              .map((Countries value) {
                                                return DropdownMenuItem<
                                                  Countries
                                                >(
                                                  value: value,
                                                  child: Text(
                                                    value.name.toString(),
                                                  ),
                                                );
                                              })
                                              .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedCountry = newValue;
                                          _selectedCity = null;
                                          _selectedState = null;
                                          CountryService.instance.stateList
                                              .clear();
                                          CountryService.instance.fetchStates(
                                            newValue!.id.toString(),
                                          );
                                        });
                                      },
                                      validator:
                                          (value) =>
                                              value == null
                                                  ? 'Please select a country'
                                                  : null,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                              // State Dropdown
                              Obx(() {
                                final List<States> states =
                                    CountryService.instance.stateList;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('States'),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xffEAEAEA),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonFormField<States>(
                                        initialValue:
                                            _selectedState, // Set initial value for edit mode
                                        decoration: const InputDecoration(
                                          labelText: 'Select a State',
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                        items:
                                            states.map((States value) {
                                              return DropdownMenuItem<States>(
                                                value: value,
                                                child: Text(
                                                  value.name.toString(),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedState = newValue;
                                          });
                                        },
                                        validator:
                                            (value) =>
                                                value == null
                                                    ? 'Please select a state'
                                                    : null,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              }),

                              const SizedBox(height: 24),
                              // _buildDropdown(
                              //   label: 'City',
                              //   value: _selectedCity,
                              //   items: [],
                              //   hintText: 'Select a city',
                              //   helperText: 'Add city here.',
                              //   onChanged: (value) {
                              //     setState(() {
                              //       _selectedCity = value;
                              //     });
                              //   },
                              // ),
                            ],

                            const SizedBox(height: 24),

                            // Upload Service Section
                            _buildSectionHeader(
                              'Upload Service',
                              isExpanded: _uploadServiceExpanded,
                              onTap: () {
                                setState(() {
                                  _uploadServiceExpanded =
                                      !_uploadServiceExpanded;
                                });
                              },
                            ),
                            if (_uploadServiceExpanded) ...[
                              const SizedBox(height: 16),
                              _buildMediaUpload(
                                label: 'Thumbnail Image',
                                isRequired: true,
                                helperText:
                                    'High-quality image can significantly impact your service\'s appeal. Upload clear, well-lit photos that showcase your item from different angles and perspectives.',
                                file: thumbnailFile,
                                onUpload: () => _pickImage(ImageSource.gallery),
                              ),
                              const SizedBox(height: 24),
                              _buildMediaUpload(
                                label: 'Service Video',
                                isRequired: false,
                                helperText:
                                    'High-quality video can significantly impact your service\'s appeal. Upload clear, well-lit photos that showcase your item from different angles and perspectives.',
                                file: videoFile,
                                onUpload: _pickVideo,
                                isVideo: true,
                              ),
                              const SizedBox(height: 24),
                              _buildGalleryUpload(
                                label: 'Service Gallery Images',
                                isRequired: false,
                                helperText:
                                    'High-quality images can significantly impact your service\'s appeal. Upload clear, well-lit photos that showcase your item from different angles and perspectives.',
                                files: galleryFiles,
                                onUpload:
                                    () => _pickImage(
                                      ImageSource.gallery,
                                      isGallery: true,
                                    ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Service Details Section
                            _buildSectionHeader(
                              'Service Details',
                              isExpanded: _serviceDetailsExpanded,
                              onTap: () {
                                setState(() {
                                  _serviceDetailsExpanded =
                                      !_serviceDetailsExpanded;
                                });
                              },
                            ),
                            if (_serviceDetailsExpanded) ...[
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Description',
                                controller: _descriptionController,
                                isRequired: false,
                                maxLines: 5,
                                hintText: 'Service description',
                                helperText:
                                    'Provide a detailed description of your service.',
                              ),
                              const SizedBox(height: 24),
                              _buildTextField(
                                label: 'Price',
                                controller: _priceController,
                                isRequired: false,
                                keyboardType: TextInputType.number,
                                hintText: 'Service price',
                                helperText:
                                    'Enter the regular price for your service.',
                              ),
                              const SizedBox(height: 24),
                              _buildTextField(
                                label: 'Sale Price',
                                controller: _salePriceController,
                                isRequired: false,
                                keyboardType: TextInputType.number,
                                hintText: 'Discounted price',
                                helperText:
                                    'Enter the sale price if your service is on discount.',
                              ),
                              const SizedBox(height: 24),
                            ],

                            const SizedBox(height: 32),

                            // Submit Button (themed container)
                            SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                onTap: _isLoading ? null : _submitForm,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _isLoading
                                        ? (isEditMode
                                            ? 'Updating...'
                                            : 'Saving...')
                                        : (isEditMode
                                            ? 'Update Service'
                                            : 'Save Service'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
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
    );
  }

  Widget _buildSectionHeader(
    String title, {
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isRequired,
    String? hintText,
    String? helperText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            if (isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hintText,
    required String helperText,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          helperText,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(hintText),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(8),
              onChanged: onChanged,
              items:
                  items.map<DropdownMenuItem<String>>((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaUpload({
    required String label,
    required bool isRequired,
    required String helperText,
    required File? file,
    required VoidCallback onUpload,
    bool isVideo = false,
  }) {
    // Show existing media if in edit mode and no new file selected
    final bool hasExistingMedia =
        isEditMode &&
        ((isVideo && videoId != null) || (!isVideo && thumbnailId != null));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            if (isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          helperText,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onUpload,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                file == null && !hasExistingMedia
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload a file or drag and drop',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : file != null
                    ? (isVideo
                        ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.video_library,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const Text(
                              'Video Selected',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    videoFile = null;
                                    videoId = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                        : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(file, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    thumbnailFile = null;
                                    thumbnailId = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ))
                    : Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isVideo)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_library,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Existing Video',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        else
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Existing Image',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (isVideo) {
                                  videoFile = null;
                                  videoId = null;
                                } else {
                                  thumbnailFile = null;
                                  thumbnailId = null;
                                }
                              });
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryUpload({
    required String label,
    required bool isRequired,
    required String helperText,
    required List<File> files,
    required VoidCallback onUpload,
  }) {
    // Show existing gallery images if in edit mode
    final bool hasExistingGallery = isEditMode && galleryIds.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          helperText,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (files.isNotEmpty || hasExistingGallery) ...[
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        files.length +
                        (hasExistingGallery ? galleryIds.length : 0),
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      // Show new files first, then existing images
                      if (index < files.length) {
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(files[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    galleryFiles.removeAt(index);
                                    if (index < galleryIds.length) {
                                      galleryIds.removeAt(index);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Show existing gallery images
                        final int existingIndex = index - files.length;
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 32,
                                    color: Colors.grey[400],
                                  ),
                                  const Text(
                                    'Existing',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    galleryIds.removeAt(existingIndex);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
              InkWell(
                onTap: onUpload,
                child: Container(
                  height: (files.isEmpty && !hasExistingGallery) ? 150 : 80,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 32,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload a file or drag and drop',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipSelection({
    required String label,
    required List<String> items,
    required List<String> selectedItems,
    required String helperText,
    required Function(List<String>) onSelectionChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          helperText,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              items.map((item) {
                final isSelected = selectedItems.contains(item);
                return FilterChip(
                  label: Text(item),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newSelection = List<String>.from(selectedItems);
                    if (selected) {
                      newSelection.add(item);
                    } else {
                      newSelection.remove(item);
                    }
                    onSelectionChanged(newSelection);
                  },
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                );
              }).toList(),
        ),
      ],
    );
  }
}
