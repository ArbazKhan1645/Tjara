import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/admin_ui_components.dart';
import 'package:tjara/app/modules/modules_admin/surveys/controller.dart';
import 'package:tjara/app/modules/modules_admin/surveys/model.dart';

class AddEditSurveyScreen extends StatefulWidget {
  final SurveyModel? existingSurvey;

  const AddEditSurveyScreen({super.key, this.existingSurvey});

  @override
  State<AddEditSurveyScreen> createState() => _AddEditSurveyScreenState();
}

class _AddEditSurveyScreenState extends State<AddEditSurveyScreen> {
  final controller = Get.find<SurveyController>();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  // Text controllers
  late TextEditingController titleController;
  late TextEditingController titleArController;
  late TextEditingController descriptionController;
  late TextEditingController descriptionArController;
  late TextEditingController thankYouController;
  late TextEditingController thankYouArController;

  // Form values
  File? selectedImage;
  String? existingImageUrl;
  String selectedStatus = 'draft';
  DateTime? startTime;
  DateTime? endTime;
  bool isFeatured = false;
  bool allowMultipleSubmissions = false;
  bool showResultsAfterSubmit = false;
  List<QuestionModel> questions = [];
  int _qKeyCounter = 0;
  final List<int> _qKeys = [];
  int _oKeyCounter = 0;
  final Map<int, List<int>> _oKeys = {};

  // Fixed shop ID (you can make this dynamic if needed)
  final String shopId = '0000c539-9857-3456-bc53-2bbdc1474f1a';

  bool get isEditMode => widget.existingSurvey != null;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    titleArController = TextEditingController();
    descriptionController = TextEditingController();
    descriptionArController = TextEditingController();
    thankYouController = TextEditingController(
      text: 'Thank you for your submission!',
    );
    thankYouArController = TextEditingController(text: 'شكرا لك على إرسالك!');

    if (isEditMode) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final survey = widget.existingSurvey!;
    titleController.text = survey.title;
    titleArController.text = survey.titleAr;
    descriptionController.text = _stripHtmlTags(survey.description);
    descriptionArController.text = _stripHtmlTags(survey.descriptionAr);
    thankYouController.text = survey.thankYouMessage;
    thankYouArController.text = survey.thankYouMessageAr;
    selectedStatus = survey.status;
    startTime = survey.startTime;
    endTime = survey.endTime;
    isFeatured = survey.isFeatured;
    allowMultipleSubmissions = survey.allowMultipleSubmissions;
    showResultsAfterSubmit = survey.showResultsAfterSubmit;

    if (survey.thumbnail != null) {
      existingImageUrl =
          survey.thumbnail!.optimizedMediaUrl ?? survey.thumbnail!.url;
    }

    questions = List<QuestionModel>.from(survey.questions);
    for (int i = 0; i < questions.length; i++) {
      final qKey = _qKeyCounter++;
      _qKeys.add(qKey);
      _oKeys[qKey] = List.generate(
        questions[i].options.length,
        (_) => _oKeyCounter++,
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    titleArController.dispose();
    descriptionController.dispose();
    descriptionArController.dispose();
    thankYouController.dispose();
    thankYouArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AdminTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          isEditMode ? 'Edit Survey' : 'Create Survey',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildImagePicker(),
            const SizedBox(height: 12),
            _buildBasicInfoCard(),
            const SizedBox(height: 12),
            _buildDescriptionCard(),
            const SizedBox(height: 12),
            _buildQuestionsCard(),
            const SizedBox(height: 12),
            _buildSettingsCard(),
            const SizedBox(height: 12),
            _buildDateTimeCard(),
            const SizedBox(height: 12),
            _buildThankYouCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─── IMAGE PICKER ───
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.borderColor),
        ),
        child: Stack(
          children: [
            if (selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  selectedImage!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else if (existingImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  existingImageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AdminTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 36,
                        color: AdminTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap to add thumbnail',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Recommended: 1200x600px',
                      style: TextStyle(
                        fontSize: 11,
                        color: AdminTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            if (selectedImage != null || existingImageUrl != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── BASIC INFO CARD ───
  Widget _buildBasicInfoCard() {
    return _sectionCard(
      icon: Icons.title,
      title: 'Basic Information',
      children: [
        _buildFormField(
          controller: titleController,
          label: 'Survey Title *',
          hint: 'Enter survey title in English',
          icon: Icons.text_fields,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        _buildFormField(
          controller: titleArController,
          label: 'Survey Title (Arabic)',
          hint: 'أدخل عنوان الاستطلاع بالعربية',
          icon: Icons.text_fields,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 16),
        _buildStatusSelector(),
      ],
    );
  }

  // ─── DESCRIPTION CARD ───
  Widget _buildDescriptionCard() {
    return _sectionCard(
      icon: Icons.description_outlined,
      title: 'Description',
      children: [
        _buildFormField(
          controller: descriptionController,
          label: 'Description *',
          hint: 'Enter survey description',
          icon: Icons.notes,
          maxLines: 3,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        _buildFormField(
          controller: descriptionArController,
          label: 'Description (Arabic)',
          hint: 'أدخل وصف الاستطلاع',
          icon: Icons.notes,
          maxLines: 3,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  // ─── QUESTIONS CARD ───
  Widget _buildQuestionsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AdminTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.quiz_outlined,
                  color: AdminTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Questions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AdminTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (questions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AdminTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${questions.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AdminTheme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(
            questions.length,
            (index) => _buildQuestionItem(index),
          ),
          GestureDetector(
            onTap: _addQuestion,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AdminTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AdminTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: AdminTheme.primaryColor,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add Question',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AdminTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(int index) {
    final question = questions[index];
    final qKey = _qKeys[index];
    final hasOptions = [
      'radio',
      'checkbox',
      'dropdown',
    ].contains(question.questionType);

    return Container(
      key: ValueKey('question_$qKey'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminTheme.bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminTheme.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AdminTheme.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: question.questionType,
                      isDense: true,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AdminTheme.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'text', child: Text('Text')),
                        DropdownMenuItem(
                          value: 'textarea',
                          child: Text('Textarea'),
                        ),
                        DropdownMenuItem(value: 'radio', child: Text('Radio')),
                        DropdownMenuItem(
                          value: 'checkbox',
                          child: Text('Checkbox'),
                        ),
                        DropdownMenuItem(
                          value: 'dropdown',
                          child: Text('Dropdown'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            questions[index] = questions[index].copyWith(
                              questionType: value,
                            );
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    questions[index] = questions[index].copyWith(
                      isRequired: !question.isRequired,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        question.isRequired
                            ? AdminTheme.errorColor.withValues(alpha: 0.1)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          question.isRequired
                              ? AdminTheme.errorColor
                              : AdminTheme.borderColor,
                    ),
                  ),
                  child: Text(
                    'Required',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          question.isRequired
                              ? AdminTheme.errorColor
                              : AdminTheme.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _removeQuestion(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AdminTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AdminTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: ValueKey('q_${qKey}_text'),
            initialValue: question.questionText,
            style: const TextStyle(fontSize: 13, color: AdminTheme.textPrimary),
            decoration: _questionInputDecoration(
              'Question Text *',
              'Enter question in English',
            ),
            onChanged: (value) {
              questions[index] = questions[index].copyWith(questionText: value);
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey('q_${qKey}_textAr'),
            initialValue: question.questionTextAr,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 13, color: AdminTheme.textPrimary),
            decoration: _questionInputDecoration(
              'Question Text (Arabic)',
              'أدخل السؤال بالعربية',
            ),
            onChanged: (value) {
              questions[index] = questions[index].copyWith(
                questionTextAr: value,
              );
            },
          ),
          if (hasOptions) ...[
            const SizedBox(height: 10),
            _buildOptionsSection(index),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionsSection(int qIndex) {
    final question = questions[qIndex];
    final qKey = _qKeys[qIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.list, size: 16, color: AdminTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Options (${question.options.length})',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AdminTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(question.options.length, (oIndex) {
          final option = question.options[oIndex];
          final oKey = _oKeys[qKey]![oIndex];
          return Padding(
            key: ValueKey('opt_${qKey}_$oKey'),
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('opt_${qKey}_${oKey}_label'),
                    initialValue: option.label ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminTheme.textPrimary,
                    ),
                    decoration: _optionInputDecoration('Label (EN)'),
                    onChanged: (value) {
                      final opts = List<QuestionOption>.from(
                        questions[qIndex].options,
                      );
                      opts[oIndex] = QuestionOption(
                        label: value,
                        value: value,
                        labelAr: opts[oIndex].labelAr,
                      );
                      questions[qIndex] = questions[qIndex].copyWith(
                        options: opts,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('opt_${qKey}_${oKey}_ar'),
                    initialValue: option.labelAr ?? '',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminTheme.textPrimary,
                    ),
                    decoration: _optionInputDecoration('Label (AR)'),
                    onChanged: (value) {
                      final opts = List<QuestionOption>.from(
                        questions[qIndex].options,
                      );
                      opts[oIndex] = QuestionOption(
                        label: opts[oIndex].label,
                        value: opts[oIndex].label,
                        labelAr: value,
                      );
                      questions[qIndex] = questions[qIndex].copyWith(
                        options: opts,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _removeOption(qIndex, oIndex),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AdminTheme.errorColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        GestureDetector(
          onTap: () => _addOption(qIndex),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AdminTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 14, color: AdminTheme.primaryColor),
                SizedBox(width: 4),
                Text(
                  'Add Option',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AdminTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _questionInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        fontSize: 12,
        color: AdminTheme.textSecondary,
      ),
      hintStyle: const TextStyle(fontSize: 12, color: AdminTheme.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AdminTheme.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AdminTheme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AdminTheme.primaryColor),
      ),
    );
  }

  InputDecoration _optionInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: AdminTheme.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AdminTheme.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AdminTheme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AdminTheme.primaryColor),
      ),
    );
  }

  // ─── SETTINGS CARD ───
  Widget _buildSettingsCard() {
    return _sectionCard(
      icon: Icons.settings_outlined,
      title: 'Settings',
      children: [
        _buildToggle(
          'Featured Survey',
          'Display this survey prominently',
          Icons.star_outline,
          isFeatured,
          (v) => setState(() => isFeatured = v),
        ),
        const Divider(height: 20, color: AdminTheme.borderColor),
        _buildToggle(
          'Allow Multiple Submissions',
          'Users can submit multiple times',
          Icons.repeat,
          allowMultipleSubmissions,
          (v) => setState(() => allowMultipleSubmissions = v),
        ),
        const Divider(height: 20, color: AdminTheme.borderColor),
        _buildToggle(
          'Show Results After Submit',
          'Display results to users after submission',
          Icons.poll_outlined,
          showResultsAfterSubmit,
          (v) => setState(() => showResultsAfterSubmit = v),
        ),
      ],
    );
  }

  // ─── DATE TIME CARD ───
  Widget _buildDateTimeCard() {
    return _sectionCard(
      icon: Icons.calendar_today_outlined,
      title: 'Schedule',
      children: [
        _buildDateTimePicker(
          label: 'Start Time',
          value: startTime,
          icon: Icons.play_circle_outline,
          onTap: () => _selectDateTime(true),
        ),
        const SizedBox(height: 12),
        _buildDateTimePicker(
          label: 'End Time',
          value: endTime,
          icon: Icons.stop_circle_outlined,
          onTap: () => _selectDateTime(false),
        ),
      ],
    );
  }

  // ─── THANK YOU CARD ───
  Widget _buildThankYouCard() {
    return _sectionCard(
      icon: Icons.favorite_outline,
      title: 'Thank You Message',
      children: [
        _buildFormField(
          controller: thankYouController,
          label: 'Thank You Message',
          hint: 'Message shown after submission',
          icon: Icons.message_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _buildFormField(
          controller: thankYouArController,
          label: 'Thank You Message (Arabic)',
          hint: 'رسالة تظهر بعد الإرسال',
          icon: Icons.message_outlined,
          maxLines: 2,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  // ─── REUSABLE: SECTION CARD ───
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AdminTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AdminTheme.primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AdminTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ─── REUSABLE: FORM FIELD ───
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextDirection? textDirection,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textDirection: textDirection,
      style: const TextStyle(fontSize: 13, color: AdminTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: AdminTheme.textSecondary,
        ),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AdminTheme.textMuted),
        prefixIcon: Icon(icon, color: AdminTheme.textMuted, size: 18),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        filled: true,
        fillColor: AdminTheme.bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminTheme.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminTheme.errorColor),
        ),
      ),
      validator: validator,
    );
  }

  // ─── STATUS SELECTOR ───
  Widget _buildStatusSelector() {
    final statuses = [
      {'value': 'draft', 'label': 'Draft', 'color': AdminTheme.warningColor},
      {
        'value': 'published',
        'label': 'Published',
        'color': AdminTheme.successColor,
      },
      {'value': 'closed', 'label': 'Closed', 'color': AdminTheme.errorColor},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AdminTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children:
              statuses.map((status) {
                final isSelected = selectedStatus == status['value'];
                final color = status['color'] as Color;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap:
                          () => setState(
                            () => selectedStatus = status['value'] as String,
                          ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? color.withValues(alpha: 0.1)
                                  : AdminTheme.bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : AdminTheme.borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            status['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? color : AdminTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  // ─── TOGGLE SWITCH ───
  Widget _buildToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: value ? AdminTheme.primaryColor : AdminTheme.textMuted,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AdminTheme.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AdminTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 28,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AdminTheme.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  // ─── DATE TIME PICKER ───
  Widget _buildDateTimePicker({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AdminTheme.bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AdminTheme.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: AdminTheme.primaryColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AdminTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value != null
                        ? '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                        : 'Not set',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          value != null
                              ? AdminTheme.textPrimary
                              : AdminTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: AdminTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM BAR ───
  Widget _buildBottomBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AdminTheme.borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Obx(
          () => GestureDetector(
            onTap: controller.isSaving.value ? null : _handleSave,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color:
                    controller.isSaving.value
                        ? AdminTheme.textMuted
                        : AdminTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  controller.isSaving.value
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditMode ? Icons.check : Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditMode ? 'Update Survey' : 'Create Survey',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── ACTIONS ───
  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 600,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        existingImageUrl = null;
      });
    }
  }

  Future<void> _selectDateTime(bool isStart) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AdminTheme.primaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          if (isStart) {
            startTime = dateTime;
          } else {
            endTime = dateTime;
          }
        });
      }
    }
  }

  void _addQuestion() {
    setState(() {
      questions.add(
        QuestionModel(
          questionText: '',
          questionTextAr: '',
          questionType: 'text',
          order: questions.length + 1,
        ),
      );
      final qKey = _qKeyCounter++;
      _qKeys.add(qKey);
      _oKeys[qKey] = [];
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      final qKey = _qKeys[index];
      questions.removeAt(index);
      _qKeys.removeAt(index);
      _oKeys.remove(qKey);
      for (int i = 0; i < questions.length; i++) {
        questions[i] = questions[i].copyWith(order: i + 1);
      }
    });
  }

  void _addOption(int qIndex) {
    setState(() {
      final qKey = _qKeys[qIndex];
      final opts = List<QuestionOption>.from(questions[qIndex].options);
      opts.add(QuestionOption(label: '', value: '', labelAr: ''));
      questions[qIndex] = questions[qIndex].copyWith(options: opts);
      _oKeys[qKey]!.add(_oKeyCounter++);
    });
  }

  void _removeOption(int qIndex, int oIndex) {
    setState(() {
      final qKey = _qKeys[qIndex];
      final opts = List<QuestionOption>.from(questions[qIndex].options);
      opts.removeAt(oIndex);
      questions[qIndex] = questions[qIndex].copyWith(options: opts);
      _oKeys[qKey]!.removeAt(oIndex);
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool success;
    if (isEditMode) {
      success = await controller.updateSurvey(
        surveyId: widget.existingSurvey!.id,
        shopId: shopId,
        title: titleController.text.trim(),
        titleAr: titleArController.text.trim(),
        description: '<p>${descriptionController.text.trim()}</p>',
        descriptionAr: '<p>${descriptionArController.text.trim()}</p>',
        thumbnailFile: selectedImage,
        existingThumbnailId: widget.existingSurvey!.thumbnailId,
        startTime: startTime,
        endTime: endTime,
        isFeatured: isFeatured,
        allowMultipleSubmissions: allowMultipleSubmissions,
        showResultsAfterSubmit: showResultsAfterSubmit,
        thankYouMessage: thankYouController.text.trim(),
        thankYouMessageAr: thankYouArController.text.trim(),
        questions: questions,
        status: selectedStatus,
      );
    } else {
      success = await controller.createSurvey(
        shopId: shopId,
        title: titleController.text.trim(),
        titleAr: titleArController.text.trim(),
        description: '<p>${descriptionController.text.trim()}</p>',
        descriptionAr: '<p>${descriptionArController.text.trim()}</p>',
        thumbnailFile: selectedImage,
        startTime: startTime,
        endTime: endTime,
        isFeatured: isFeatured,
        allowMultipleSubmissions: allowMultipleSubmissions,
        showResultsAfterSubmit: showResultsAfterSubmit,
        thankYouMessage: thankYouController.text.trim(),
        thankYouMessageAr: thankYouArController.text.trim(),
        questions: questions,
        status: selectedStatus,
      );
    }

    print(success);
  }

  String _stripHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
