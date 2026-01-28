import 'package:flutter/material.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
// Don't forget to import Timer
import 'dart:async';

class CustomSearchDropdown extends StatefulWidget {
  final String hintText;
  final Future<List<ProductAttributeItems>> Function() initialItemsLoader;
  final Future<List<ProductAttributeItems>> Function(String) searchItemsLoader;
  final ProductAttributeItems? selectedItem;
  final ValueChanged<ProductAttributeItems?>? onChanged;

  const CustomSearchDropdown({
    super.key,
    required this.hintText,
    required this.initialItemsLoader,
    required this.searchItemsLoader,
    this.selectedItem,
    this.onChanged,
  });

  @override
  State<CustomSearchDropdown> createState() => _CustomSearchDropdownState();
}

class _CustomSearchDropdownState extends State<CustomSearchDropdown> {
  final TextEditingController _displayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateDisplayText();
  }

  @override
  void didUpdateWidget(CustomSearchDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItem != widget.selectedItem) {
      _updateDisplayText();
    }
  }

  void _updateDisplayText() {
    _displayController.text = widget.selectedItem?.name ?? '';
  }

  Future<void> _showSearchDialog() async {
    final result = await showDialog<ProductAttributeItems>(
      context: context,
      builder: (BuildContext context) => SearchDialog(
        initialItemsLoader: widget.initialItemsLoader,
        searchItemsLoader: widget.searchItemsLoader,
        selectedItem: widget.selectedItem,
      ),
    );

    if (result != null) {
      widget.onChanged?.call(result);
    }
  }

  @override
  void dispose() {
    _displayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSearchDialog,
      child: AbsorbPointer(
        child: TextField(
          controller: _displayController,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ),
    );
  }
}

class SearchDialog extends StatefulWidget {
  final Future<List<ProductAttributeItems>> Function() initialItemsLoader;
  final Future<List<ProductAttributeItems>> Function(String) searchItemsLoader;
  final ProductAttributeItems? selectedItem;

  const SearchDialog({
    super.key,
    required this.initialItemsLoader,
    required this.searchItemsLoader,
    this.selectedItem,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductAttributeItems> _items = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialItems();
  }

  Future<void> _loadInitialItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await widget.initialItemsLoader();
      if (mounted) {
        setState(() {
          _items = items;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchItems(query);
    });
  }

  Future<void> _searchItems(String query) async {
    if (!mounted) return;

    if (query.trim().isEmpty) {
      await _loadInitialItems();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await widget.searchItemsLoader(query);
      if (mounted) {
        setState(() {
          _items = items;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Field
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _loadInitialItems();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.isEmpty) {
                  _loadInitialItems();
                } else {
                  _searchItems(_searchController.text);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_isLoading && _items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading categories...'),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _items[index];
        final isSelected = widget.selectedItem?.id == item.id;

        return ListTile(
          title: Text(
            item.name ?? '',
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check,
                  color: Theme.of(context).primaryColor,
                )
              : null,
          onTap: () {
            Navigator.of(context).pop(item);
          },
        );
      },
    );
  }
}

