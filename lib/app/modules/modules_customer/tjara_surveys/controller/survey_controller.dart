// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_customer/tjara_surveys/model/surveys_model.dart';
import 'package:tjara/app/modules/modules_customer/tjara_surveys/service/survey_api.dart';

class SurveyController extends GetxController {
  final SurveyApiService _apiService = SurveyApiService();

  RxList<SurveyData> surveys = <SurveyData>[].obs;
  RxInt totalSurveys = 0.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  TextEditingController searchController = TextEditingController();
  RxList<SurveyData> filteredSurveys = <SurveyData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSurveys();

    // Listen to search changes
    searchController.addListener(() {
      filterSurveys(searchController.text);
    });
  }

  Future<void> fetchSurveys() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final surveysData = await _apiService.fetchSurveys();
      update();
      surveys.value = surveysData.surveys?.data ?? [];
      totalSurveys.value = surveysData.surveys?.total ?? 0;
      filteredSurveys.value = surveys;
      update();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterSurveys(String query) {
    if (query.isEmpty) {
      filteredSurveys.value = surveys;
    } else {
      filteredSurveys.value =
          surveys
              .where(
                (survey) => (survey.title ?? '').toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    }
  }

  void showSurveyDetails(SurveyData survey) {
    Get.to(() => SurveyDetailScreen(survey: survey));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class SurveyDetailScreen extends StatefulWidget {
  final SurveyData survey;

  const SurveyDetailScreen({super.key, required this.survey});

  @override
  State<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends State<SurveyDetailScreen> {
  final SurveyApiService _apiService = SurveyApiService();
  final Map<String, dynamic> _answers = {};
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  SurveySubmitResponse? _submitResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFFFF8C00),
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Survey Image
                  widget.survey.thumbnail?.media?.url != null
                      ? Image.network(
                        widget.survey.thumbnail!.media!.url!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFF8C00),
                                    Color(0xFFFF8C00),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.poll_outlined,
                                size: 80,
                                color: Colors.white24,
                              ),
                            ),
                      )
                      : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF8C00), Color(0xFFFF8C00)],
                          ),
                        ),
                        child: const Icon(
                          Icons.poll_outlined,
                          size: 80,
                          color: Colors.white24,
                        ),
                      ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // Title at bottom
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      widget.survey.title ?? 'Survey',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child:
                _submitResult != null
                    ? _buildResultsView()
                    : _buildSurveyForm(),
          ),
        ],
      ),

      // Submit Button
      bottomSheet:
          _submitResult == null
              ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitSurvey,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C00),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Submit Survey',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildSurveyForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Card
            if (widget.survey.description != null &&
                widget.survey.description!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFFF8C00),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'About this Survey',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Html(
                      data: widget.survey.description ?? '',
                      style: {
                        'p': Style(
                          fontSize: FontSize(14),
                          color: Colors.grey.shade700,
                          margin: Margins.zero,
                        ),
                      },
                    ),
                  ],
                ),
              ),

            // Questions Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.quiz_outlined,
                      color: Color(0xFFFF8C00),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Questions (${widget.survey.questions?.length ?? 0})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Questions List
            ...?widget.survey.questions?.asMap().entries.map(
              (entry) => _buildQuestionCard(entry.key + 1, entry.value),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, SurveyQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.questionText ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (question.isRequired == true)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          '* Required',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Answer Input based on question type
          _buildAnswerInput(question),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(SurveyQuestion question) {
    switch (question.questionType) {
      case 'text':
        return TextFormField(
          decoration: InputDecoration(
            hintText: question.placeholder ?? 'Enter your answer',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF8C00)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (question.isRequired == true &&
                (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          onChanged: (value) {
            _answers[question.id ?? ''] = value;
          },
        );

      case 'textarea':
        return TextFormField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: question.placeholder ?? 'Enter your detailed answer',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF8C00)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (question.isRequired == true &&
                (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          onChanged: (value) {
            _answers[question.id ?? ''] = value;
          },
        );

      case 'select':
      case 'radio':
        return Column(
          children:
              question.options?.map((option) {
                final isSelected =
                    _answers[question.id ?? ''] ==
                    (option.value ?? option.label);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _answers[question.id ?? ''] =
                          option.value ?? option.label;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFFF8C00).withOpacity(0.1)
                              : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFFFF8C00)
                                : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(0xFFFF8C00)
                                      : Colors.grey.shade400,
                              width: 2,
                            ),
                            color:
                                isSelected
                                    ? const Color(0xFFFF8C00)
                                    : Colors.transparent,
                          ),
                          child:
                              isSelected
                                  ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          option.label ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color:
                                isSelected
                                    ? const Color(0xFFFF8C00)
                                    : Colors.black87,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList() ??
              [],
        );

      case 'checkbox':
        return Column(
          children:
              question.options?.map((option) {
                final selectedList =
                    (_answers[question.id ?? ''] as List<String>?) ?? [];
                final isSelected = selectedList.contains(
                  option.value ?? option.label,
                );
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      final currentList =
                          (_answers[question.id ?? ''] as List<String>?) ?? [];
                      if (isSelected) {
                        currentList.remove(option.value ?? option.label);
                      } else {
                        currentList.add(option.value ?? option.label ?? '');
                      }
                      _answers[question.id ?? ''] = currentList;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFFF8C00).withOpacity(0.1)
                              : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFFFF8C00)
                                : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(0xFFFF8C00)
                                      : Colors.grey.shade400,
                              width: 2,
                            ),
                            color:
                                isSelected
                                    ? const Color(0xFFFF8C00)
                                    : Colors.transparent,
                          ),
                          child:
                              isSelected
                                  ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          option.label ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color:
                                isSelected
                                    ? const Color(0xFFFF8C00)
                                    : Colors.black87,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList() ??
              [],
        );

      case 'number':
        return TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: question.placeholder ?? 'Enter a number',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF8C00)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (question.isRequired == true &&
                (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          onChanged: (value) {
            _answers[question.id ?? ''] = value;
          },
        );

      default:
        // Default to text input
        return TextFormField(
          decoration: InputDecoration(
            hintText: question.placeholder ?? 'Enter your answer',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF8C00)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (question.isRequired == true &&
                (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          onChanged: (value) {
            _answers[question.id ?? ''] = value;
          },
        );
    }
  }

  Future<void> _submitSurvey() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Error',
        'Please fill in all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _apiService.submitSurvey(
        surveyId: widget.survey.id ?? '',
        answers: _answers,
      );

      setState(() {
        _submitResult = result;
        _isSubmitting = false;
      });

      Get.snackbar(
        'Success',
        result.thankYouMessage ?? 'Survey submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      Get.snackbar(
        'Error',
        'Failed to submit survey. $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Widget _buildResultsView() {
    final results = _submitResult?.results?.original;
    final stats = results?.survey?.statistics;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thank You Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF8C00), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _submitResult?.thankYouMessage ?? 'Thank you!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your response has been recorded',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Statistics Card
          if (stats != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart, color: Color(0xFFFF8C00), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Survey Statistics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total Responses',
                        '${stats.totalResponses ?? 0}',
                        Icons.people_outline,
                      ),
                      _buildStatCard(
                        'Questions',
                        '${stats.totalQuestions ?? 0}',
                        Icons.quiz_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Results per question
          if (results?.results != null && results!.results!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.analytics_outlined, color: Color(0xFFFF8C00)),
                  SizedBox(width: 8),
                  Text(
                    'Response Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...results.results!.map(
              (result) => _buildQuestionResultCard(result),
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8C00).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFFF8C00), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF8C00),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildQuestionResultCard(QuestionResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.questionText ?? '',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${result.analytics?.totalResponses ?? 0} responses',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),

          // Answer bars
          ...?result.analytics?.answers?.take(5).map((answer) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${answer.answer}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${answer.percentage?.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF8C00),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (answer.percentage ?? 0) / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF8C00),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
