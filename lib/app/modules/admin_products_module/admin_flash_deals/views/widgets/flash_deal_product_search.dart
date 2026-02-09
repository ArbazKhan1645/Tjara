import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals/controller/flash_deal_controller.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals/model/flash_deal_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_templates/model/template_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';

class FlashDealProductSearch extends StatefulWidget {
  const FlashDealProductSearch({super.key});

  @override
  State<FlashDealProductSearch> createState() => _FlashDealProductSearchState();
}

class _FlashDealProductSearchState extends State<FlashDealProductSearch> {
  final controller = Get.find<FlashDealController>();
  final searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Filter state
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String _stockFilter = 'all'; // 'all', 'in_stock', 'low_stock'
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    controller.loadInitialProducts();
    controller.fetchTemplates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchFocusNode.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  List<FlashDealProduct> _applyFilters(List<FlashDealProduct> products) {
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);

    return products.where((p) {
      // Date filter
      if (_dateFrom != null && p.createdAt != null) {
        if (p.createdAt!.isBefore(_dateFrom!)) return false;
      }
      if (_dateTo != null && p.createdAt != null) {
        final endOfDay = _dateTo!.add(const Duration(days: 1));
        if (p.createdAt!.isAfter(endOfDay)) return false;
      }
      // Price filter
      final price = double.tryParse(p.price ?? '0') ?? 0;
      if (minPrice != null && price < minPrice) return false;
      if (maxPrice != null && price > maxPrice) return false;
      // Stock filter
      if (_stockFilter == 'in_stock' && p.stock <= 5) return false;
      if (_stockFilter == 'low_stock' && p.stock > 5) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AdminTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Product to Flash Deals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Search and select products to add',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildRestoreTemplateSection(),
          _buildSearchField(),
          _buildFilterToggle(),
          if (_showFilters) _buildFiltersSection(),
          Expanded(child: _buildProductsList()),
        ],
      ),
    );
  }

  Widget _buildRestoreTemplateSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.restore, color: AdminTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Restore Template',
                style: TextStyle(
                  color: AdminTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingTemplates.value) {
                    return Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AdminTheme.bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AdminTheme.borderColor),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AdminTheme.primaryColor),
                          ),
                          SizedBox(width: 10),
                          Text('Loading templates...', style: TextStyle(color: AdminTheme.textMuted, fontSize: 13)),
                        ],
                      ),
                    );
                  }
                  return Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AdminTheme.bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminTheme.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedTemplateId.value,
                        isExpanded: true,
                        hint: Text(
                          controller.templates.isEmpty
                              ? 'No templates available'
                              : 'Select a template',
                          style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down, color: AdminTheme.textSecondary),
                        items: controller.templates.map((Template t) {
                          return DropdownMenuItem<String>(
                            value: t.id,
                            child: Text(
                              t.name,
                              style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: controller.templates.isEmpty
                            ? null
                            : (value) {
                                controller.selectedTemplateId.value = value;
                              },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 10),
              Obx(() => SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: controller.isRestoringTemplate.value ||
                          controller.selectedTemplateId.value == null
                      ? null
                      : () => controller.restoreTemplate(controller.selectedTemplateId.value!),
                  icon: controller.isRestoringTemplate.value
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.restore, size: 18),
                  label: Text(
                    controller.isRestoringTemplate.value ? 'Restoring...' : 'Restore',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AdminTheme.primaryColor.withValues(alpha: 0.5),
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search products by name...',
          hintStyle: const TextStyle(color: AdminTheme.textMuted),
          prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary),
          suffixIcon: Obx(() {
            if (controller.isSearchingProducts.value) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AdminTheme.primaryColor),
                ),
              );
            }
            if (searchController.text.isNotEmpty) {
              return IconButton(
                onPressed: () {
                  searchController.clear();
                  controller.loadInitialProducts();
                },
                icon: const Icon(Icons.clear, color: AdminTheme.textMuted),
              );
            }
            return const SizedBox.shrink();
          }),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminTheme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminTheme.primaryColor, width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.length >= 2) {
            controller.searchProducts(value);
          } else if (value.isEmpty) {
            controller.loadInitialProducts();
          }
        },
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _showFilters ? AdminTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _showFilters ? AdminTheme.primaryColor : AdminTheme.borderColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune,
                    size: 16,
                    color: _showFilters ? Colors.white : AdminTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filters',
                    style: TextStyle(
                      color: _showFilters ? Colors.white : AdminTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_hasActiveFilters()) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: _showFilters ? Colors.white : AdminTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AdminTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: AdminTheme.errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _dateFrom != null ||
        _dateTo != null ||
        _minPriceController.text.isNotEmpty ||
        _maxPriceController.text.isNotEmpty ||
        _stockFilter != 'all';
  }

  void _clearFilters() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      _stockFilter = 'all';
    });
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date filter
          const Text(
            'Date Created',
            style: TextStyle(
              color: AdminTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildDateButton('From', _dateFrom, (date) {
                setState(() => _dateFrom = date);
              })),
              const SizedBox(width: 10),
              Expanded(child: _buildDateButton('To', _dateTo, (date) {
                setState(() => _dateTo = date);
              })),
            ],
          ),
          const SizedBox(height: 14),
          // Price filter
          const Text(
            'Price Range',
            style: TextStyle(
              color: AdminTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSmallTextField(_minPriceController, 'Min Price'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSmallTextField(_maxPriceController, 'Max Price'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Stock filter
          const Text(
            'Stock Level',
            style: TextStyle(
              color: AdminTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStockChip('All Stock', 'all'),
              const SizedBox(width: 8),
              _buildStockChip('In Stock (>5)', 'in_stock'),
              const SizedBox(width: 8),
              _buildStockChip('Low Stock', 'low_stock'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, ValueChanged<DateTime?> onPicked) {
    final text = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
        : label;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: AdminTheme.primaryColor),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AdminTheme.bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AdminTheme.borderColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: date != null ? AdminTheme.primaryColor : AdminTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: date != null ? AdminTheme.textPrimary : AdminTheme.textMuted,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: () => onPicked(null),
                child: const Icon(Icons.close, size: 14, color: AdminTheme.textMuted),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTextField(TextEditingController ctrl, String hint) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 13, color: AdminTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AdminTheme.textMuted, fontSize: 12),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 10, right: 4),
            child: Text('\$', style: TextStyle(color: AdminTheme.textMuted, fontSize: 14)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          filled: true,
          fillColor: AdminTheme.bgColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
            borderSide: const BorderSide(color: AdminTheme.primaryColor, width: 1.5),
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildStockChip(String label, String value) {
    final isSelected = _stockFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _stockFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AdminTheme.primaryColor : AdminTheme.bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AdminTheme.primaryColor : AdminTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AdminTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return Obx(() {
      final Set<String> existingProductIds = {
        ...controller.activeProductIds,
        ...controller.skippedProductIds,
        ...controller.expiredProductIds,
        ...controller.soldProductIds,
      };

      final allProducts = controller.searchedProducts
          .where((p) => !existingProductIds.contains(p.id))
          .toList();

      final products = _applyFilters(allProducts);

      if (controller.isSearchingProducts.value && products.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AdminTheme.primaryColor),
        );
      }

      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_outlined, size: 48, color: AdminTheme.textMuted),
              const SizedBox(height: 12),
              Text(
                allProducts.isNotEmpty && _hasActiveFilters()
                    ? 'No products match the applied filters'
                    : controller.searchedProducts.isNotEmpty
                        ? 'All matching products are already in flash deals'
                        : 'No products found',
                style: const TextStyle(color: AdminTheme.textMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductItem(product);
        },
      );
    });
  }

  Widget _buildProductItem(FlashDealProduct product) {
    return GestureDetector(
      onTap: () {
        controller.addProductToActiveDeals(product);
        Get.back();
        AdminSnackbar.success(
          'Product Added',
          '${product.name} added to flash deals',
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AdminTheme.borderColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 56,
                height: 56,
                color: AdminTheme.bgColor,
                child: product.image != null && product.image!.isNotEmpty
                    ? Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: AdminTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (product.price != null)
                        Text(
                          '\$${product.price}',
                          style: TextStyle(
                            color: product.salePrice != null
                                ? AdminTheme.textMuted
                                : AdminTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            decoration: product.salePrice != null
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      if (product.salePrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${product.salePrice}',
                          style: const TextStyle(
                            color: AdminTheme.errorColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.stock > 5
                              ? const Color(0xFFE8F5E9)
                              : product.stock > 0
                                  ? const Color(0xFFFFF3E0)
                                  : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Stock: ${product.stock}',
                          style: TextStyle(
                            color: product.stock > 5
                                ? const Color(0xFF2E7D32)
                                : product.stock > 0
                                    ? const Color(0xFFE65100)
                                    : AdminTheme.errorColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AdminTheme.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add, size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AdminTheme.bgColor,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AdminTheme.textMuted,
          size: 24,
        ),
      ),
    );
  }
}
