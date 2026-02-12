// main_email_screen.dart
// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/modules/modules_admin/emails/analytics.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class EmailMainScreen extends StatefulWidget {
  const EmailMainScreen({super.key});

  @override
  _EmailMainScreenState createState() => _EmailMainScreenState();
}

class _EmailMainScreenState extends State<EmailMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const AllEmailsScreen(),
    const SendEmailScreen(),
    EmailAnalyticsWidget(
      userId: AuthService.instance.authCustomer?.user?.id ?? '',
      shopId: AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
    ),
  ];

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.email_outlined, label: 'All Emails'),
    _TabItem(icon: Icons.send_outlined, label: 'Send Email'),
    _TabItem(icon: Icons.analytics_outlined, label: 'Analytics'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Bulk Emails', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.teal,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.teal.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedIndex == index;
                  final tab = _tabs[index];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tab.icon,
                              size: 18,
                              color: isSelected ? Colors.teal : Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                color:
                                    isSelected ? Colors.teal : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Content area - takes remaining space
          Expanded(
            child: Container(
              color: Colors.white,

              padding: const EdgeInsets.all(16),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

// send_email_screen.dart
class SendEmailScreen extends StatefulWidget {
  const SendEmailScreen({super.key});

  @override
  _SendEmailScreenState createState() => _SendEmailScreenState();
}

class _SendEmailScreenState extends State<SendEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _userEmailController = TextEditingController();

  // Options state
  String _emailType = 'single'; // single | bulk
  String _action = 'send_now'; // send_now | draft | schedule
  String _targetAudience = 'all'; // all | vendor | customers | admins
  String _verifiedFilter = 'all'; // all | verified | not_verified
  DateTime? _scheduledAt;

  // Loading & polling state
  bool _isLoading = false;
  bool _isMonitoring = false;
  String? _monitoringEmailId;
  Timer? _pollTimer;
  Map<String, dynamic>? _emailStatus;
  bool _isCancelling = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _userEmailController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String url;
      final Map<String, dynamic> payload = {
        'subject': _subjectController.text,
        'description': '<p>${_descriptionController.text}</p>',
        'email_type': _emailType,
      };

      if (_emailType == 'single') {
        payload['user_email'] = _userEmailController.text;
      } else {
        payload['send_to'] = _targetAudience;
        payload['verified'] = _verifiedFilter;
      }

      if (_action == 'schedule' && _scheduledAt != null) {
        payload['scheduled_at'] = _scheduledAt!.toIso8601String();
      }

      if (_action == 'draft') {
        url = 'https://api.libanbuy.com/api/emails/draft';
      } else if (_action == 'schedule') {
        url = 'https://api.libanbuy.com/api/emails/schedule';
      } else {
        url = 'https://api.libanbuy.com/api/emails/insert';
      }

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'x-request-from': 'Dashboard',
              'shop-id':
                  AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
              'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
              'Content-Type': 'application/json',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 1000));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (_action == 'draft') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email saved as draft successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
          _clearForm();
        } else {
          final emailId = data['email_id'];
          if (emailId != null) {
            _startMonitoring(emailId);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email queued for delivery'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            _clearForm();
          }
        }
      } else {
        throw Exception('Failed to process email');
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request timed out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startMonitoring(String emailId) {
    setState(() {
      _isMonitoring = true;
      _monitoringEmailId = emailId;
      _emailStatus = null;
    });
    _pollStatus();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _pollStatus(),
    );
  }

  Future<void> _pollStatus() async {
    if (_monitoringEmailId == null) return;
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/emails/$_monitoringEmailId/status',
        ),
        headers: {
          'x-request-from': 'Dashboard',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        setState(() => _emailStatus = data);
        final status = (data['status'] ?? '').toString().toLowerCase();
        if (status != 'queued' && status != 'sending') {
          _stopMonitoring();
        }
      }
    } catch (_) {}
  }

  void _stopMonitoring() {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (mounted) {
      setState(() {
        _isMonitoring = false;
        _monitoringEmailId = null;
        _emailStatus = null;
      });
      _clearForm();
    }
  }

  Future<void> _cancelMonitoredEmail() async {
    if (_monitoringEmailId == null) return;
    setState(() => _isCancelling = true);
    try {
      final response = await http.post(
        Uri.parse(
          'https://api.libanbuy.com/api/emails/$_monitoringEmailId/cancel',
        ),
        headers: {
          'x-request-from': 'Dashboard',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email campaign cancelled'),
            backgroundColor: Colors.green,
          ),
        );
        _stopMonitoring();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  Future<void> _pickScheduleDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Colors.teal),
            ),
            child: child!,
          ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Colors.teal),
            ),
            child: child!,
          ),
    );
    if (time == null || !mounted) return;

    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _scheduledAt = scheduled);
  }

  void _clearForm() {
    _subjectController.clear();
    _descriptionController.clear();
    _userEmailController.clear();
    setState(() {
      _emailType = 'single';
      _action = 'send_now';
      _targetAudience = 'all';
      _verifiedFilter = 'all';
      _scheduledAt = null;
    });
  }

  // ── UI Helpers ──

  Widget _buildSectionLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          if (required) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Required',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
    );
  }

  Widget _buildChipOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.teal.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.teal : Colors.grey[300]!,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.teal : Colors.grey[500],
              ),
              const SizedBox(width: 6),
            ],
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.teal : Colors.transparent,
                border: Border.all(
                  color: selected ? Colors.teal : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child:
                  selected
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.teal : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          items:
              items.map((item) {
                return DropdownMenuItem(
                  value: item['value'],
                  child: Text(item['label']!),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── Campaign Progress Widget ──

  Widget _buildCampaignProgress() {
    final stats = _emailStatus?['stats'] as Map<String, dynamic>? ?? {};
    final status = (_emailStatus?['status'] ?? 'queued').toString();
    final progress = (_emailStatus?['progress'] ?? 0).toDouble();
    final total = stats['total_recipients'] ?? 0;
    final sent = stats['sent'] ?? 0;
    final failed = stats['failed'] ?? 0;
    final pending = stats['pending'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Campaign Progress',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.grey[850],
            ),
          ),
          SizedBox(height: 10),
          // Header
          Row(
            children: [
              _buildProgressStatusBadge(status),
              const Spacer(),
              if (status.toLowerCase() == 'queued' ||
                  status.toLowerCase() == 'sending')
                _isCancelling
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFEF4444),
                      ),
                    )
                    : OutlinedButton.icon(
                      onPressed: _cancelMonitoredEmail,
                      icon: const Icon(Icons.cancel_outlined, size: 15),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: BorderSide(
                          color: const Color(0xFFEF4444).withOpacity(0.4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[100],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFDC2626),
              ),
              minHeight: 10,
            ),
          ),

          const SizedBox(height: 20),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  'Total',
                  total.toString(),
                  const Color(0xFFEFF6FF),
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  'Sent',
                  sent.toString(),
                  const Color(0xFFECFDF5),
                  const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  'Failed',
                  failed.toString(),
                  const Color(0xFFFEF2F2),
                  const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  'Pending',
                  pending.toString(),
                  const Color(0xFFFFFBEB),
                  const Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'queued':
        color = const Color(0xFFF59E0B);
        icon = Icons.schedule;
        break;
      case 'sending':
        color = const Color(0xFF3B82F6);
        icon = Icons.send;
        break;
      case 'sent':
        color = const Color(0xFF22C55E);
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        color = const Color(0xFFEF4444);
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.circle_outlined;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Main Build ──

  @override
  Widget build(BuildContext context) {
    if (_isMonitoring) {
      return _emailStatus == null
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(child: _buildCampaignProgress());
    }

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          // Compose header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compose Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[850],
                  ),
                ),
                const SizedBox(height: 20),

                // Subject
                _buildSectionLabel('Email Subject', required: true),
                _buildInputField(
                  controller: _subjectController,
                  hint: 'Enter email subject',
                  validator:
                      (v) =>
                          (v == null || v.isEmpty)
                              ? 'Subject is required'
                              : null,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 20),

                // Content
                _buildSectionLabel('Email Content', required: true),
                _buildInputField(
                  controller: _descriptionController,
                  hint: 'Write your email content here...',
                  maxLines: 6,
                  validator:
                      (v) =>
                          (v == null || v.isEmpty)
                              ? 'Content is required'
                              : null,
                  enabled: !_isLoading,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Options card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Type
                _buildSectionLabel('Email Type'),
                Text(
                  'Single recipient or bulk send',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: [
                    _buildChipOption(
                      label: 'Single',
                      selected: _emailType == 'single',
                      onTap:
                          _isLoading
                              ? () {}
                              : () => setState(() => _emailType = 'single'),
                    ),
                    _buildChipOption(
                      label: 'Bulk',
                      selected: _emailType == 'bulk',
                      onTap:
                          _isLoading
                              ? () {}
                              : () => setState(() => _emailType = 'bulk'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action
                _buildSectionLabel('Action'),
                Text(
                  'What to do with this email',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _buildChipOption(
                      label: 'Send Now',
                      icon: Icons.send,
                      selected: _action == 'send_now',
                      onTap:
                          _isLoading
                              ? () {}
                              : () => setState(() => _action = 'send_now'),
                    ),
                    _buildChipOption(
                      label: 'Save Draft',
                      icon: Icons.drafts_outlined,
                      selected: _action == 'draft',
                      onTap:
                          _isLoading
                              ? () {}
                              : () => setState(() => _action = 'draft'),
                    ),
                    _buildChipOption(
                      label: 'Schedule',
                      icon: Icons.schedule,
                      selected: _action == 'schedule',
                      onTap:
                          _isLoading
                              ? () {}
                              : () {
                                setState(() => _action = 'schedule');
                                _pickScheduleDateTime();
                              },
                    ),
                  ],
                ),

                // Schedule time picker
                if (_action == 'schedule') ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _isLoading ? null : _pickScheduleDateTime,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _scheduledAt != null
                                ? '${_scheduledAt!.day}/${_scheduledAt!.month}/${_scheduledAt!.year}  ${_scheduledAt!.hour.toString().padLeft(2, '0')}:${_scheduledAt!.minute.toString().padLeft(2, '0')}'
                                : 'Select date & time',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  _scheduledAt != null
                                      ? Colors.grey[800]
                                      : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Bulk options
                if (_emailType == 'bulk') ...[
                  const SizedBox(height: 20),
                  _buildSectionLabel('Target Audience'),
                  Text(
                    'Which users to send to',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    value: _targetAudience,
                    items: const [
                      {'label': 'All Users', 'value': 'all'},
                      {'label': 'Sellers Only', 'value': 'vendor'},
                      {'label': 'Customers Only', 'value': 'customers'},
                      {'label': 'Admin Only', 'value': 'admins'},
                    ],
                    onChanged:
                        _isLoading
                            ? (_) {}
                            : (v) =>
                                setState(() => _targetAudience = v ?? 'all'),
                  ),

                  const SizedBox(height: 20),
                  _buildSectionLabel('Verification Filter'),
                  Text(
                    'Filter by email verification status',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    value: _verifiedFilter,
                    items: const [
                      {'label': 'All Users', 'value': 'all'},
                      {'label': 'Verified Only', 'value': 'verified'},
                      {'label': 'Non-Verified Only', 'value': 'not_verified'},
                    ],
                    onChanged:
                        _isLoading
                            ? (_) {}
                            : (v) =>
                                setState(() => _verifiedFilter = v ?? 'all'),
                  ),
                ],

                // Recipient email (single only)
                if (_emailType == 'single') ...[
                  const SizedBox(height: 20),
                  _buildSectionLabel('Recipient Email', required: true),
                  _buildInputField(
                    controller: _userEmailController,
                    hint: 'Enter recipient email address',
                    enabled: !_isLoading,
                    validator: (v) {
                      if (_emailType != 'single') return null;
                      if (v == null || v.isEmpty)
                        return 'Recipient email is required';
                      if (!RegExp(
                        r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                      ).hasMatch(v)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Send button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _emailType == 'bulk'
                                ? 'Sending bulk email, please wait...'
                                : 'Sending...',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _action == 'draft'
                                ? Icons.save_outlined
                                : _action == 'schedule'
                                ? Icons.schedule_send
                                : Icons.send,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _action == 'draft'
                                ? 'Save Draft'
                                : _action == 'schedule'
                                ? 'Schedule Email'
                                : 'Send Email',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// email_analytics_screen.dart
class EmailAnalyticsScreen extends StatelessWidget {
  const EmailAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard('Total Emails', '156', Icons.email, Colors.blue),
                _buildStatCard('Sent Today', '23', Icons.send, Colors.green),
                _buildStatCard(
                  'Open Rate',
                  '68%',
                  Icons.open_in_new,
                  Colors.orange,
                ),
                _buildStatCard('Click Rate', '12%', Icons.mouse, Colors.purple),
                _buildStatCard(
                  'Bounce Rate',
                  '3%',
                  Icons.trending_down,
                  Colors.red,
                ),
                _buildStatCard(
                  'Subscribers',
                  '1.2K',
                  Icons.people,
                  Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[500]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// email_model.dart
class Email {
  final String id;
  final String subject;
  final String description;
  final String status;
  final String emailType;
  final String? sendTo;
  final String? singleRecipient;
  final int totalRecipients;
  final int sentCount;
  final int failedCount;
  final int pendingCount;
  final int deliveredCount;
  final int openedCount;
  final int clickedCount;
  final int bouncedCount;
  final int totalBatches;
  final int completedBatches;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  Email({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.emailType,
    this.sendTo,
    this.singleRecipient,
    required this.totalRecipients,
    required this.sentCount,
    required this.failedCount,
    required this.pendingCount,
    required this.deliveredCount,
    required this.openedCount,
    required this.clickedCount,
    required this.bouncedCount,
    required this.totalBatches,
    required this.completedBatches,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      id: json['id'],
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      emailType: json['email_type'] ?? '',
      sendTo: json['send_to'],
      singleRecipient: json['single_recipient'],
      totalRecipients: json['total_recipients'] ?? 0,
      sentCount: json['sent_count'] ?? 0,
      failedCount: json['failed_count'] ?? 0,
      pendingCount: json['pending_count'] ?? 0,
      deliveredCount: json['delivered_count'] ?? 0,
      openedCount: json['opened_count'] ?? 0,
      clickedCount: json['clicked_count'] ?? 0,
      bouncedCount: json['bounced_count'] ?? 0,
      totalBatches: json['total_batches'] ?? 0,
      completedBatches: json['completed_batches'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      completedAt:
          json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
    );
  }
}

// all_emails_screen.dart
class AllEmailsScreen extends StatefulWidget {
  const AllEmailsScreen({super.key});

  @override
  _AllEmailsScreenState createState() => _AllEmailsScreenState();
}

class _AllEmailsScreenState extends State<AllEmailsScreen> {
  List<Email> emails = [];
  bool _isLoadingEmails = true;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  int _perPage = 10;
  int _totalEmails = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _cancellingId;

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getMonthName(int monthNumber) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (monthNumber < 1 || monthNumber > 12) return '';
    return monthNames[monthNumber - 1];
  }

  Future<void> _fetchEmails() async {
    setState(() {
      _isLoadingEmails = true;
      _errorMessage = '';
    });

    try {
      String url =
          'https://api.libanbuy.com/api/emails?page=$_currentPage&per_page=$_perPage';
      if (_searchQuery.isNotEmpty) {
        url += '&search=$_searchQuery';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-request-from': 'Dashboard',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final emailsData = data['emails']['data'] as List;
        final paginationData = data['emails'];

        setState(() {
          emails = emailsData.map((email) => Email.fromJson(email)).toList();
          _currentPage = paginationData['current_page'] ?? 1;
          _totalPages = paginationData['last_page'] ?? 1;
          _totalEmails = paginationData['total'] ?? 0;
          _perPage = paginationData['per_page'] ?? 10;
          _isLoadingEmails = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          emails = [];
          _currentPage = 1;
          _totalPages = 1;
          _totalEmails = 0;
          _isLoadingEmails = false;
        });
      } else {
        throw Exception('Failed to load emails');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading emails: ${e.toString()}';
        _isLoadingEmails = false;
      });
    }
  }

  Future<void> _cancelEmail(String emailId) async {
    setState(() => _cancellingId = emailId);

    try {
      final response = await http.post(
        Uri.parse('https://api.libanbuy.com/api/emails/$emailId/cancel'),
        headers: {
          'x-request-from': 'Dashboard',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email campaign cancelled'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _fetchEmails();
      } else {
        throw Exception('Failed to cancel email');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _cancellingId = null);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
    _fetchEmails();
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      setState(() => _currentPage = page);
      _fetchEmails();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return const Color(0xFF22C55E);
      case 'queued':
        return const Color(0xFFF97316);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'sending':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
    }
  }

  double _getProgress(Email email) {
    if (email.totalRecipients == 0) return 0;
    return email.sentCount / email.totalRecipients;
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return Icons.check_circle_outline;
      case 'queued':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'sending':
        return Icons.send;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildPaginationControls() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    final start = ((_currentPage - 1) * _perPage) + 1;
    final end =
        (_currentPage * _perPage > _totalEmails)
            ? _totalEmails
            : _currentPage * _perPage;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$start - $end of $_totalEmails',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              _buildPaginationButton(
                icon: Icons.chevron_left,
                enabled: _currentPage > 1,
                onTap: () => _goToPage(_currentPage - 1),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFFFB923C)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildPaginationButton(
                icon: Icons.chevron_right,
                enabled: _currentPage < _totalPages,
                onTap: () => _goToPage(_currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? Colors.grey[300]! : Colors.grey[200]!,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? const Color(0xFFF97316) : Colors.grey[350],
        ),
      ),
    );
  }

  Widget _buildEmailCard(Email email) {
    final progress = _getProgress(email);
    final statusColor = _getStatusColor(email.status);
    final isQueued = email.status.toLowerCase() == 'queued';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Subject + Status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                // Subject text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email.subject,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[850],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${email.createdAt.day} ${_getMonthName(email.createdAt.month)} ${email.createdAt.year}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(email.status),
              ],
            ),

            const SizedBox(height: 14),

            // Progress section
            Row(
              children: [
                // Progress bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sent',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${email.sentCount} / ${email.totalRecipients}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Percentage
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    email.totalRecipients > 0
                        ? '${(progress * 100).toStringAsFixed(0)}%'
                        : '0%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            // Cancel button for queued emails
            if (isQueued) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 36,
                child:
                    _cancellingId == email.id
                        ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        )
                        : OutlinedButton.icon(
                          onPressed: () => _cancelEmail(email.id),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text('Cancel Campaign'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: BorderSide(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[400], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search emails...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              if (_searchQuery.isNotEmpty)
                InkWell(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.clear, color: Colors.grey[400], size: 18),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Email cards list
        Expanded(
          child:
              _isLoadingEmails
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFF97316)),
                  )
                  : _errorMessage.isNotEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _fetchEmails,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                  )
                  : emails.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No emails found',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: emails.length,
                    itemBuilder: (context, index) {
                      return _buildEmailCard(emails[index]);
                    },
                  ),
        ),

        // Pagination at bottom
        _buildPaginationControls(),
      ],
    );
  }
}
