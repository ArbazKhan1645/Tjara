// main_email_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/modules/admin/emails/analytics.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class EmailMainScreen extends StatefulWidget {
  const EmailMainScreen({super.key});

  @override
  _EmailMainScreenState createState() => _EmailMainScreenState();
}

class _EmailMainScreenState extends State<EmailMainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const AllEmailsScreen(),
    const SendEmailScreen(),
    EmailAnalyticsWidget(
      userId: AuthService.instance.authCustomer?.user?.id ?? '',
      shopId: '0000c539-9857-3456-bc53-2bbdc1474f1a',
    ),
  ];
  static const _expandedStackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF165E28), Colors.red],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF165E28),
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Gradient background for upper half
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(gradient: _expandedStackGradient),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          'Bulk Emails',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Navigation Card
                  Container(
                    height: 250,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [],
                    ),
                    child: Column(
                      children: [
                        _buildNavItem(
                          icon: Icons.analytics,
                          title: 'Emails Analytics',
                          isSelected: _selectedIndex == 2,
                          onTap: () => setState(() => _selectedIndex = 2),
                        ),
                        const SizedBox(height: 8),
                        _buildNavItem(
                          icon: Icons.email,
                          title: 'All Emails',
                          isSelected: _selectedIndex == 0,
                          onTap: () => setState(() => _selectedIndex = 0),
                        ),
                        const SizedBox(height: 8),
                        _buildNavItem(
                          icon: Icons.send,
                          title: 'Send Emails',
                          isSelected: _selectedIndex == 1,
                          onTap: () => setState(() => _selectedIndex = 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Content Area
                  Container(
                    height: _selectedIndex == 2 ? 1000 : 600,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: _screens[_selectedIndex],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFE91E63).withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE91E63) : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFFE91E63) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _userEmailController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.libanbuy.com/api/emails/insert'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain, */*',
          'X-Request-From': 'Dashboard',
        },
        body: json.encode({
          'subject': _subjectController.text,
          'description': _descriptionController.text,
          'email_type': 'single',
          'user_email': _userEmailController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();
      } else {
        throw Exception('Failed to send email');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _subjectController.clear();
    _descriptionController.clear();
    _userEmailController.clear();
  }

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
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // From field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('From', style: TextStyle(color: Colors.grey[600])),
                        const Spacer(),
                        Text(
                          'logiceditor456.com',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),

                  // To field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('To', style: TextStyle(color: Colors.grey[600])),
                        const Spacer(),
                        Expanded(
                          child: TextFormField(
                            controller: _userEmailController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter recipient email',
                            ),
                            textAlign: TextAlign.right,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Recipient email is required';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),

                  // Subject field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Subject',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            controller: _subjectController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Compose email',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email subject is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email content area
                  Expanded(
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Write your email content here...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email content is required';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Send button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send),
                                  SizedBox(width: 8),
                                  Text(
                                    'Send Email',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
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
  final DateTime createdAt;
  final DateTime updatedAt;

  Email({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      id: json['id'],
      subject: json['subject'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _userEmailController = TextEditingController();
  bool _isLoading = false;

  // Email fetching variables with pagination support
  List<Email> emails = [];
  bool _isLoadingEmails = true;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  int _perPage = 10;
  int _totalEmails = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _userEmailController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String getMonthName(int monthNumber) {
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

    if (monthNumber < 1 || monthNumber > 12) {
      return 'Invalid month';
    }

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
          'Accept': 'application/json',
          'X-Request-From': 'Application',
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
        // Handle case when no emails are found for search query
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1; // Reset to first page when searching
    });
    _fetchEmails();
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      _fetchEmails();
    }
  }

  void _goToFirstPage() {
    _goToPage(1);
  }

  void _goToPreviousPage() {
    _goToPage(_currentPage - 1);
  }

  void _goToNextPage() {
    _goToPage(_currentPage + 1);
  }

  void _goToLastPage() {
    _goToPage(_totalPages);
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.libanbuy.com/api/emails'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Application',
        },
        body: json.encode({
          'subject': _subjectController.text,
          'description': _descriptionController.text,
          'email_type': 'single',
          'user_email': _userEmailController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();
        // Refresh the email list after sending
        _fetchEmails();
      } else {
        throw Exception('Failed to send email');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _subjectController.clear();
    _descriptionController.clear();
    _userEmailController.clear();
  }

  Widget _buildPaginationControls() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          // Pagination info
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Showing ${((_currentPage - 1) * _perPage) + 1} to ${(_currentPage * _perPage > _totalEmails) ? _totalEmails : _currentPage * _perPage} of $_totalEmails emails',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),

          // Pagination buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First page button
              IconButton(
                onPressed: _currentPage > 1 ? _goToFirstPage : null,
                icon: const Icon(Icons.first_page),
                tooltip: 'First Page',
                color: _currentPage > 1 ? const Color(0xFFE91E63) : Colors.grey[400],
              ),

              // Previous page button
              IconButton(
                onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous Page',
                color: _currentPage > 1 ? const Color(0xFFE91E63) : Colors.grey[400],
              ),

              // Page numbers (show current page and nearby pages)
              ..._buildPageNumbers(),

              // Next page button
              IconButton(
                onPressed: _currentPage < _totalPages ? _goToNextPage : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next Page',
                color:
                    _currentPage < _totalPages
                        ? const Color(0xFFE91E63)
                        : Colors.grey[400],
              ),

              // Last page button
              IconButton(
                onPressed: _currentPage < _totalPages ? _goToLastPage : null,
                icon: const Icon(Icons.last_page),
                tooltip: 'Last Page',
                color:
                    _currentPage < _totalPages
                        ? const Color(0xFFE91E63)
                        : Colors.grey[400],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> pageNumbers = [];
    final int startPage = (_currentPage - 2).clamp(1, _totalPages);
    final int endPage = (_currentPage + 2).clamp(1, _totalPages);

    // Show first page if not in range
    if (startPage > 1) {
      pageNumbers.add(_buildPageButton(1));
      if (startPage > 2) {
        pageNumbers.add(Text('...', style: TextStyle(color: Colors.grey[600])));
      }
    }

    // Show page numbers in range
    for (int i = startPage; i <= endPage; i++) {
      pageNumbers.add(_buildPageButton(i));
    }

    // Show last page if not in range
    if (endPage < _totalPages) {
      if (endPage < _totalPages - 1) {
        pageNumbers.add(Text('...', style: TextStyle(color: Colors.grey[600])));
      }
      pageNumbers.add(_buildPageButton(_totalPages));
    }

    return pageNumbers;
  }

  Widget _buildPageButton(int page) {
    final bool isCurrentPage = page == _currentPage;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: isCurrentPage ? null : () => _goToPage(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrentPage ? const Color(0xFFE91E63) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrentPage ? const Color(0xFFE91E63) : Colors.grey[300]!,
            ),
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              color: isCurrentPage ? Colors.white : Colors.grey[700],
              fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

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
        children: [
          // Search bar with functional search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search in emails',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pagination controls
          _buildPaginationControls(),

          // Table content
          Expanded(
            child:
                _isLoadingEmails
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(_errorMessage, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchEmails,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : emails.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No emails found'),
                        ],
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          // Table header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Subject',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Description',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Date Sent',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Table rows from fetched emails
                          ...emails.asMap().entries.map((entry) {
                            final index = entry.key;
                            final email = entry.value;
                            final isLastItem = index == emails.length - 1;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  left: BorderSide(color: Colors.grey[200]!),
                                  right: BorderSide(color: Colors.grey[200]!),
                                  bottom: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: isLastItem ? 1 : 0.5,
                                  ),
                                ),
                                borderRadius:
                                    isLastItem
                                        ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        )
                                        : null,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      email.subject,
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      email.description,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${email.createdAt.day} ${getMonthName(email.createdAt.month)} ${email.createdAt.year}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
