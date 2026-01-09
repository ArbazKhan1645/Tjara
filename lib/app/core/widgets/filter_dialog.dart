// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key, this.selectedFilter});
  final String? selectedFilter;

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String selectedOption = "Default";

  final List<FilterOption> filterOptions = [
    FilterOption(
      title: "Default",
      subtitle: "Original order from server",
      icon: Icons.sort_rounded,
      value: "Default",
    ),
    FilterOption(
      title: "Most Recent",
      subtitle: "Show newest products first",
      icon: Icons.access_time_rounded,
      value: "Most Recent",
    ),
    FilterOption(
      title: "Featured Products",
      subtitle: "Highlighted recommendations",
      icon: Icons.star_rounded,
      value: "Featured Products",
    ),
    FilterOption(
      title: "Low to High (Price)",
      subtitle: "Cheapest products first",
      icon: Icons.trending_up_rounded,
      value: "Low to high (price)",
    ),
    FilterOption(
      title: "High to Low (Price)",
      subtitle: "Most expensive first",
      icon: Icons.trending_down_rounded,
      value: "High to low (price)",
    ),
  ];

  @override
  void initState() {
    if (widget.selectedFilter != null && widget.selectedFilter!.isNotEmpty) {
      selectedOption = widget.selectedFilter.toString();
    } else {
      // If no filter is provided or filter is empty, select "Default"
      selectedOption = "Default";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16), // Add consistent padding
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight:
              MediaQuery.of(context).size.height * 0.8, // Prevent overflow
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(child: SingleChildScrollView(child: _buildContent())),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.sort_rounded,
              color: Color(0xFFF97316),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sort By",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Choose how to organize results",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF666666),
              size: 24,
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children:
            filterOptions.map((option) => _buildFilterOption(option)).toList(),
      ),
    );
  }

  Widget _buildFilterOption(FilterOption option) {
    final isSelected = selectedOption == option.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFFF97316) : const Color(0xFFE8E8E8),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected ? const Color(0xFFF97316).withOpacity(0.05) : Colors.white,
      ),
      child: InkWell(
        onTap: () {
          setState(() => selectedOption = option.value);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0xFFF97316).withOpacity(0.1)
                          : const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  option.icon,
                  color:
                      isSelected ? const Color(0xFFF97316) : const Color(0xFF666666),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected
                                ? const Color(0xFFF97316)
                                : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isSelected
                                ? const Color(0xFFF97316).withOpacity(0.8)
                                : const Color(0xFF888888),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFFF97316)
                            : const Color(0xFFD0D0D0),
                    width: 2,
                  ),
                  color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      width: double.infinity, // Ensure full width
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Always use column layout for consistency
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    selectedOption.isEmpty
                        ? null
                        : () => Navigator.pop(context, selectedOption),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: const Color(0xFFF97316).withOpacity(0.3),
                  disabledBackgroundColor: const Color(0xFFE8E8E8),
                  disabledForegroundColor: const Color(0xFFAAAAAA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color:
                          selectedOption.isEmpty
                              ? const Color(0xFFAAAAAA)
                              : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Apply Sort",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;

  FilterOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
  });
}

Future<dynamic> showFilterBottomSheet(BuildContext context) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (context) {
      return const FilterScreen();
    },
  );
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final double _minPrice = 0;
  final double _maxPrice = 300;
  double _selectedMinPrice = 0;
  double _selectedMaxPrice = 300;

  void _closeSheet() {
    Navigator.pop(context);
  }

  Future<void> _showPriceInputDialog(bool isMinPrice) async {
    final TextEditingController controller = TextEditingController(
      text: (isMinPrice ? _selectedMinPrice : _selectedMaxPrice)
          .toStringAsFixed(2),
    );

    final result = await showDialog<double>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isMinPrice ? 'Set Min Price' : 'Set Max Price'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixText: '\$',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    helperText: 'Enter price with decimals (e.g., 10.50)',
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    // Allow real-time validation
                    final parsedValue = double.tryParse(value);
                    if (parsedValue != null) {
                      // Visual feedback could be added here
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = double.tryParse(controller.text);
                  if (value != null &&
                      value >= _minPrice &&
                      value <= _maxPrice) {
                    Navigator.pop(context, value);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter a valid price between \$${_minPrice.toStringAsFixed(2)} and \$${_maxPrice.toStringAsFixed(2)}',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                ),
                child: const Text(
                  'Set Price',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (result != null) {
      setState(() {
        if (isMinPrice) {
          _selectedMinPrice = result;
          // Ensure min is not greater than max
          if (_selectedMinPrice > _selectedMaxPrice) {
            _selectedMaxPrice = _selectedMinPrice;
          }
        } else {
          _selectedMaxPrice = result;
          // Ensure max is not less than min
          if (_selectedMaxPrice < _selectedMinPrice) {
            _selectedMinPrice = _selectedMaxPrice;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                spreadRadius: 5,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(child: SingleChildScrollView(child: _buildContent())),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        children: [
          // Drag handle
          Expanded(
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Close button
          IconButton(
            onPressed: _closeSheet,
            icon: const Icon(Icons.close, color: Color(0xFF666666), size: 24),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Filter Options",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Price Range Section
          _buildPriceRangeSection(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                color: Color(0xFFF97316),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Price Range",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2A2A2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Price display cards
          Row(
            children: [
              Expanded(
                child: _buildPriceCard(
                  "Min Price",
                  _selectedMinPrice,
                  Icons.keyboard_arrow_down,
                  onTap: () => _showPriceInputDialog(true),
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 20, height: 2, color: const Color(0xFFE0E0E0)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceCard(
                  "Max Price",
                  _selectedMaxPrice,
                  Icons.keyboard_arrow_up,
                  onTap: () => _showPriceInputDialog(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Helper text
          Center(
            child: Text(
              'Tap price cards above to set custom decimal values',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Custom slider
          FlutterSlider(
            values: [_selectedMinPrice, _selectedMaxPrice],
            rangeSlider: true,
            min: _minPrice,
            max: _maxPrice,
            step: const FlutterSliderStep(
              step: 0.25,
            ), // Allow quarter steps for precise control
            trackBar: FlutterSliderTrackBar(
              inactiveTrackBar: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFE8E8E8),
              ),
              activeTrackBar: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFF97316)],
                ),
              ),
            ),
            handler: FlutterSliderHandler(
              decoration: const BoxDecoration(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF97316).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.drag_indicator,
                  color: Color(0xFFF97316),
                  size: 16,
                ),
              ),
            ),
            rightHandler: FlutterSliderHandler(
              decoration: const BoxDecoration(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF97316).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.drag_indicator,
                  color: Color(0xFFF97316),
                  size: 16,
                ),
              ),
            ),
            tooltip: FlutterSliderTooltip(
              textStyle: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              boxStyle: const FlutterSliderTooltipBox(
                decoration: BoxDecoration(
                  color: Color(0xFF1F8C3B),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
              ),
            ),
            onDragging: (handlerIndex, lowerValue, upperValue) {
              setState(() {
                _selectedMinPrice = lowerValue;
                _selectedMaxPrice = upperValue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(
    String label,
    double value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.edit_outlined, color: Colors.grey[400], size: 14),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "\$${value.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F8C3B),
                  ),
                ),
                const Spacer(),
                Icon(icon, color: const Color(0xFFF97316), size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Apply button (primary action first)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'min': _selectedMinPrice,
                    'max': _selectedMaxPrice,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: const Color(0xFFF97316).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Apply Filter",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Reset button (secondary action)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedMinPrice = _minPrice;
                    _selectedMaxPrice = _maxPrice;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF97316), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Reset",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF97316),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
