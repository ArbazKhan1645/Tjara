import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/modules/modules_admin/admin/websettings/websettings.dart';

class WebViewWidget extends StatefulWidget {
  final bool isAppBarExpanded;

  const WebViewWidget({super.key, required this.isAppBarExpanded});

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Web Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFFF97316),
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Website\nSettings'),
                        Tab(text: 'Content \nSettings'),
                        Tab(text: 'Website \nVisitor Popup Settings'),
                      ],
                    ),
                  ),
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        const WebsiteOptionsScreen(),
                        const WebsiteSettingsTab(),
                        const WebsiteVisitorPopupTab(),
                      ],
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

// First Tab - Website Settings
class WebsiteSettingsTab extends StatefulWidget {
  const WebsiteSettingsTab({super.key});

  @override
  State<WebsiteSettingsTab> createState() => _WebsiteSettingsTabState();
}

class _WebsiteSettingsTabState extends State<WebsiteSettingsTab> {
  String selectedLanguage = 'English';
  String selectedLanguage2 = 'English';
  List<String> categories = ['Used Cars', 'Kitchen & Dining'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // All Categories Image Section
              _buildSectionTitle(
                'All Categories Image (Home Page)',
                isRequired: true,
              ),
              const Text(
                'This sets the image for all categories circle in featured categories section on home page.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              _buildImageUploadSection(),
              const SizedBox(height: 32),

              // Website Features Promos Section
              _buildSectionTitle(
                'Website Features Promos (Home Page)',
                isRequired: true,
              ),
              const Text(
                'This sets the promotions section texts on home page.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Responsive language selector
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 500) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Language:'),
                        const SizedBox(height: 8),
                        _buildLanguageSelector(selectedLanguage, (value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        }),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        const Text('Language:'),
                        const SizedBox(width: 16),
                        _buildLanguageSelector(selectedLanguage, (value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        }),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              _buildPromoFields(),
              const SizedBox(height: 32),

              // All Products Notice Section
              _buildSectionTitle('All Products Notice', isRequired: true),
              const Text(
                'This sets the notice for all products under each product card.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Responsive language selector
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 500) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Language:'),
                        const SizedBox(height: 8),
                        _buildLanguageSelector(selectedLanguage2, (value) {
                          setState(() {
                            selectedLanguage2 = value;
                          });
                        }),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        const Text('Language:'),
                        const SizedBox(width: 16),
                        _buildLanguageSelector(selectedLanguage2, (value) {
                          setState(() {
                            selectedLanguage2 = value;
                          });
                        }),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              _buildNoticeTextField(),
              const SizedBox(height: 16),

              _buildCategoriesList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF97316).withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Required',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Upload a file or drag and drop',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    String selectedValue,
    Function(String) onChanged,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          return Column(
            children: [
              _buildLanguageButton(
                'English',
                selectedValue == 'English',
                () => onChanged('English'),
              ),
              const SizedBox(height: 8),
              _buildLanguageButton(
                'العربية',
                selectedValue == 'العربية',
                () => onChanged('العربية'),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              _buildLanguageButton(
                'English',
                selectedValue == 'English',
                () => onChanged('English'),
              ),
              const SizedBox(width: 8),
              _buildLanguageButton(
                'العربية',
                selectedValue == 'العربية',
                () => onChanged('العربية'),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildLanguageButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.red,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPromoFields() {
    return Column(
      children: [
        _buildPromoField('Promo 1', 'بدء مع تكوين زمني'),
        const SizedBox(height: 12),
        _buildPromoField('Promo 2', 'عبر منزل قيمة وسط في فترة متنوعة'),
        const SizedBox(height: 12),
        _buildPromoField('Promo 3', 'ما نحو الفرد من التبعيين'),
        const SizedBox(height: 12),
        _buildPromoField('Promo 4', 'على الثراء بصيص همكم خطل...'),
      ],
    );
  }

  Widget _buildPromoField(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildNoticeTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notice Text',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Text(
            '<span class="line-breaker">Reseller Deal:</span> Get 15-25% Discount',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList() {
    return Column(
      children:
          categories
              .map(
                (category) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_indicator, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(category)),
                      const Icon(Icons.close, color: Colors.grey),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}

// Second Tab - Website Visitor Popup Settings
class WebsiteVisitorPopupTab extends StatefulWidget {
  const WebsiteVisitorPopupTab({super.key});

  @override
  State<WebsiteVisitorPopupTab> createState() => _WebsiteVisitorPopupTabState();
}

class _WebsiteVisitorPopupTabState extends State<WebsiteVisitorPopupTab> {
  String popupType = 'Image Banner Popup';
  DateTime startDate = DateTime(2025, 1, 30, 20, 20);
  DateTime expiryDate = DateTime(2025, 2, 1, 20, 20);
  String bannerLink = 'https://chat.whatsapp.com/DiFWtNClQZaCxXNOVJYkq';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Popup Start Date
              _buildSectionTitle('Popup Start Date', isRequired: true),
              const Text(
                'Select when the popup should start displaying',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _buildDateTimeField(startDate, 'Start Date'),
              const SizedBox(height: 24),

              // Popup Expiry Date
              _buildSectionTitle('Popup Expiry Date', isRequired: true),
              const Text(
                'Select when the popup should stop displaying',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _buildDateTimeField(expiryDate, 'Expiry Date'),
              const SizedBox(height: 24),

              // Popup Type
              _buildSectionTitle('Popup Type', isRequired: true),
              const Text(
                'Select type of popup',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _buildPopupTypeSelector(),
              const SizedBox(height: 24),

              // Popup Banner Image
              _buildSectionTitle('Popup Banner Image', isRequired: true),
              const Text(
                'This sets the current banner image of the popup.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _buildPopupImageSection(),
              const SizedBox(height: 24),

              // Popup Banner Image Link
              _buildSectionTitle('Popup Banner Image Link', isRequired: true),
              const Text(
                'Add the link where the user will be redirected, when user click on the popup banner image.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _buildLinkTextField(),
              const SizedBox(height: 32),

              // Responsive Save Button
              LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: Container(
                      width:
                          constraints.maxWidth < 400 ? double.infinity : null,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF97316), Color(0xFFF97316)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF97316).withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle save
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth < 400 ? 16 : 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF97316).withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Required',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField(DateTime dateTime, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 14),
              ),
              const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopupTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popup Type',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Image Banner Popup'),
                value: 'Image Banner Popup',
                groupValue: popupType,
                onChanged: (value) {
                  setState(() {
                    popupType = value!;
                  });
                },
                dense: true,
                activeColor: const Color(0xFFF97316),
              ),
              RadioListTile<String>(
                title: const Text('Lead Capturing Form Popup'),
                value: 'Lead Capturing Form Popup',
                groupValue: popupType,
                onChanged: (value) {
                  setState(() {
                    popupType = value!;
                  });
                },
                dense: true,
                activeColor: const Color(0xFFF97316),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopupImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Banner Image',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Upload a file or drag and drop',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Banner Link',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(bannerLink, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}

// Third Tab - Additional Settings (placeholder)
class AdditionalSettingsTab extends StatelessWidget {
  const AdditionalSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Additional Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'This section can be customized with additional website settings.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Keep the existing widgets for backward compatibility
class PopupActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final void Function(MenuItem menuItem) onSelected;

  const PopupActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuItem>(
      position: PopupMenuPosition.under,
      color: Colors.white,
      icon: ReusableContainerWithIcon(label: label, icon: icon),
      onSelected: onSelected,
      offset: const Offset(1, 0),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<MenuItem>>[
          PopupMenuItem<MenuItem>(
            value: MenuItem.XLSV,
            child: Container(
              color: Colors.white,
              child: const Row(
                children: [
                  Icon(
                    Icons.file_present,
                    color: AppColors.adminGreyColorText,
                    size: 16,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Excel (XLSX)',
                    style: TextStyle(color: AppColors.adminGreyColorText),
                  ),
                ],
              ),
            ),
          ),
          const PopupMenuItem<MenuItem>(
            value: MenuItem.CSV,
            child: Row(
              children: [
                Icon(
                  Icons.file_present,
                  color: AppColors.adminGreyColorText,
                  size: 16,
                ),
                SizedBox(width: 10),
                Text(
                  'CSV',
                  style: TextStyle(color: AppColors.adminGreyColorText),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}

enum MenuItem { XLSV, CSV }

class ReusableContainerWithIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget? trailingIcon;
  final Color containerBorderColor;
  final List<Color> containerGradientColors;

  const ReusableContainerWithIcon({
    super.key,
    required this.label,
    required this.icon,
    this.trailingIcon = const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: Colors.black,
    ),
    this.containerBorderColor = Colors.grey,
    this.containerGradientColors = const [Colors.white, Colors.white],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: containerGradientColors,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: containerBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.black)),
              ],
            ),
            trailingIcon ?? Container(),
          ],
        ),
      ),
    );
  }
}

class OrderColumnWidget extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;
  final Color textColor;
  final bool hasIcon;
  final IconData icon;
  final Color iconColor;
  final String hasImage;
  final TextAlign textAlign;

  const OrderColumnWidget({
    super.key,
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textColor = Colors.black,
    this.hasIcon = false,
    this.icon = Icons.open_in_new,
    this.iconColor = Colors.red,
    this.hasImage = '',
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey), maxLines: 2),
        if (hasImage.isEmpty)
          SizedBox(
            height: 50,
            width: 100,
            child: Row(
              children: [
                if (hasIcon) Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(color: textColor),
                    maxLines: 2,
                    textAlign: textAlign,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        if (hasImage.isNotEmpty)
          Image.network(value, height: 50, width: 50, fit: BoxFit.contain),
      ],
    );
  }
}
