import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/jobs/jobs_model.dart';
import 'package:tjara/app/modules/tjara_jobs/controllers/tjara_jobs_controller.dart';
import 'package:tjara/app/modules/tjara_jobs/views/tjara_jobs_view.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class JobApplicationScreen extends StatelessWidget {
  final String jobId;
  final Job job;

  const JobApplicationScreen({
    super.key,
    required this.jobId,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final TjaraJobsController controller = Get.find<TjaraJobsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFfda730),
        title: const Text(
          'Apply Application',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              Form(
                key: controller.formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildJobHeader(),

                    const SizedBox(height: 20),

                    Text(
                      'Job Application Form',
                      style: defaultTextStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // First Name
                    TextFormField(
                      controller: controller.firstNameController,
                      style: defaultTextStyle,
                      decoration: InputDecoration(
                        labelText: 'First Name *',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name is required';
                        }
                        if (value.length > 255) {
                          return 'First name must be less than 255 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Last Name
                    TextFormField(
                      controller: controller.lastNameController,
                      style: defaultTextStyle,
                      decoration: InputDecoration(
                        labelText: 'Last Name *',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last name is required';
                        }
                        if (value.length > 255) {
                          return 'Last name must be less than 255 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Email
                    TextFormField(
                      controller: controller.emailController,
                      style: defaultTextStyle,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!GetUtils.isEmail(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Date of Birth
                    GestureDetector(
                      onTap:
                          () => controller.selectDate(
                            context,
                            controller.dateOfBirth,
                          ),
                      child: AbsorbPointer(
                        child: TextFormField(
                          style: defaultTextStyle,
                          decoration: InputDecoration(
                            labelText: 'Date of Birth *',
                            labelStyle: defaultTextStyle.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF0D9488),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                          controller: TextEditingController(
                            text:
                                controller.dateOfBirth.value != null
                                    ? DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(controller.dateOfBirth.value!)
                                    : '',
                          ),
                          validator: (value) {
                            if (controller.dateOfBirth.value == null) {
                              return 'Date of birth is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Phone
                    TextFormField(
                      controller: controller.phoneController,
                      style: defaultTextStyle,
                      decoration: InputDecoration(
                        labelText: 'Phone *',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (value.length > 255) {
                          return 'Phone number must be less than 255 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.linkedinController,
                      style: defaultTextStyle,
                      decoration: InputDecoration(
                        labelText: 'LinkedIn URL',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: 'Optional',
                        hintStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),

                    // Address Section
                    Text(
                      'Address Information',
                      style: defaultTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Street Address
                    TextFormField(
                      controller: controller.streetAddressController,
                      style: defaultTextStyle,
                      decoration: InputDecoration(
                        labelText: 'Street Address *',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Street address is required';
                        }
                        if (value.length > 255) {
                          return 'Street address must be less than 255 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Country
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Country',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: 'Select Country',
                        hintStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      initialValue: controller.countryId.value,
                      items:
                          controller.countries.map((country) {
                            return DropdownMenuItem<String>(
                              value: country['id'].toString(),
                              child: Text(
                                country['name'],
                                style: defaultTextStyle,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        controller.countryId.value = value;
                        if (value != null) {
                          controller.stateId.value = null;
                          controller.cityId.value = null;
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // State
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'State',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: 'Select State',
                        hintStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      initialValue: controller.stateId.value,
                      items:
                          controller.states.map((state) {
                            return DropdownMenuItem<String>(
                              value: state['id'].toString(),
                              child: Text(
                                state['name'],
                                style: defaultTextStyle,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        controller.stateId.value = value;
                        if (value != null) {
                          controller.cityId.value = null;
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // City
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'City',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: 'Select City',
                        hintStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      initialValue: controller.cityId.value,
                      items:
                          controller.cities.map((city) {
                            return DropdownMenuItem<String>(
                              value: city['id'].toString(),
                              child: Text(
                                city['name'],
                                style: defaultTextStyle,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        controller.cityId.value = value;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Zip Code
                    TextFormField(
                      controller: controller.zipCodeController,
                      style: defaultTextStyle,
                      decoration: InputDecoration(
                        labelText: 'Zip Code *',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Zip code is required';
                        }
                        if (value.length > 255) {
                          return 'Zip code must be less than 255 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Employment Information Section
                    Text(
                      'Employment Information',
                      style: defaultTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Employment Status
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Employment Status',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: 'Select Employment Status',
                        hintStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      initialValue: controller.employmentStatus.value,
                      items:
                          controller.employmentStatusOptions.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status, style: defaultTextStyle),
                            );
                          }).toList(),
                      onChanged: (value) {
                        controller.employmentStatus.value = value;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Start Date
                    GestureDetector(
                      onTap:
                          () => controller.selectDate(
                            context,
                            controller.startDate,
                          ),
                      child: AbsorbPointer(
                        child: TextFormField(
                          style: defaultTextStyle,
                          decoration: InputDecoration(
                            labelText: 'Available Start Date',
                            labelStyle: defaultTextStyle.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF0D9488),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF0D9488),
                            ),
                            hintText: 'Optional',
                            hintStyle: defaultTextStyle.copyWith(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                          controller: TextEditingController(
                            text:
                                controller.startDate.value != null
                                    ? DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(controller.startDate.value!)
                                    : '',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Desired Start Date
                    GestureDetector(
                      onTap:
                          () => controller.selectDate(
                            context,
                            controller.desiredDate,
                          ),
                      child: AbsorbPointer(
                        child: TextFormField(
                          style: defaultTextStyle,
                          decoration: InputDecoration(
                            labelText: 'Desired Start Date',
                            labelStyle: defaultTextStyle.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF0D9488),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF0D9488),
                            ),
                            hintText: 'Optional',
                            hintStyle: defaultTextStyle.copyWith(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                          controller: TextEditingController(
                            text:
                                controller.desiredDate.value != null
                                    ? DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(controller.desiredDate.value!)
                                    : '',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Source of Landing
                    TextFormField(
                      controller: controller.sourceOfLandingController,
                      style: defaultTextStyle,
                      decoration: InputDecoration(
                        labelText: 'How did you hear about us?',
                        labelStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: 'Optional',
                        hintStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Application Materials Section
                    Text(
                      'Application Materials',
                      style: defaultTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CV Upload
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CV/Resume *',
                          style: defaultTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: controller.pickCVFile,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.upload_file,
                                  color: Color(0xFF0D9488),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.cvFileName.value.isEmpty
                                        ? 'Upload CV/Resume (PDF, DOC, DOCX)'
                                        : controller.cvFileName.value,
                                    style: defaultTextStyle.copyWith(
                                      color:
                                          controller.cvFileName.value.isEmpty
                                              ? Colors.grey.shade600
                                              : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (controller.cvFile.value == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'CV/Resume is required',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Cover Letter
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: controller.coverLetterController,
                        style: defaultTextStyle,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(16),
                          labelText: 'Cover Letter *',
                          labelStyle: defaultTextStyle.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Cover letter is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (controller.errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          controller.errorMessage.value,
                          style: defaultTextStyle.copyWith(
                            color: Colors.red.shade900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    MaterialButton(
                      onPressed:
                          controller.isLoadingApplying.value
                              ? null
                              : () => controller.submitApplication(jobId),
                      color: const Color(0xFFfda730),
                      minWidth: double.infinity,
                      height: 56,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          controller.isLoadingApplying.value
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                'Submit Application',
                                style: defaultTextStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
    final imageUrl =
        job.thumbnail.media?.optimizedMediaUrl ?? job.thumbnail.media?.url;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedImageWidget(imageUrl: imageUrl ?? ''),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: defaultTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.country.name}, ${job.city.name}',
                        style: defaultTextStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, // Light grey background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${job.country.currencyCode}${job.salary} ',
                    style: defaultTextStyle.copyWith(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE7EA), // Light pink background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Full Time',
                    style: defaultTextStyle.copyWith(
                      color: const Color(0xFF0D9488),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
