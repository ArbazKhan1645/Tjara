import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/services/dashbopard_services/contests_service.dart';

class ContestsSearchBar extends StatelessWidget {
  final ContestsService contestsService;

  const ContestsSearchBar({
    super.key,
    required this.contestsService,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildSearchField(),
        ),
        const SizedBox(width: 12),
        _buildSearchButton(),
        const SizedBox(width: 8),
        _buildClearButton(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: TextField(
        controller: contestsService.searchController,
        decoration: InputDecoration(
          hintText: 'Search contests by title, description, or category...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: Obx(() {
            return contestsService.isSearching
                ? Container(
                    padding: const EdgeInsets.all(12),
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                    size: 20,
                  );
          }),
          suffixIcon: Obx(() {
            return contestsService.searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: () => contestsService.clearSearch(),
                    tooltip: 'Clear search',
                  )
                : const SizedBox.shrink();
          }),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 14),
        onSubmitted: (_) => _performSearch(),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildSearchButton() {
    return Obx(() {
      return ElevatedButton.icon(
        onPressed: contestsService.isSearching ? null : _performSearch,
        icon: contestsService.isSearching
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.search, size: 18),
        label: const Text('Search'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  Widget _buildClearButton() {
    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: contestsService.searchQuery.isNotEmpty
            ? OutlinedButton.icon(
                onPressed: () => contestsService.clearSearch(),
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      );
    });
  }

  void _performSearch() {
    if (contestsService.searchController.text.trim().isNotEmpty) {
      // The search will be triggered automatically by the listener in the service
      FocusScope.of(Get.context!).unfocus();
    }
  }
}