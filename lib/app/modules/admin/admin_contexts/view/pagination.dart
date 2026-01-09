import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/services/dashbopard_services/contests_service.dart';

class ContestsPagination extends StatelessWidget {
  final ContestsService contestsService;

  const ContestsPagination({super.key, required this.contestsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!contestsService.hasData) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaginationInfo(),
            const SizedBox(height: 16),
            _buildPaginationControls(),
          ],
        ),
      );
    });
  }

  Widget _buildPaginationInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          contestsService.getPaginationInfo(),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        // _buildPerPageSelector(),
      ],
    );
  }

  Widget _buildPerPageSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Items per page:',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: contestsService.perPage,
              isDense: true,
              items:
                  [5, 10, 20, 50, 100].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        value.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  contestsService.updatePerPage(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For very small screens, show minimal controls
        if (constraints.maxWidth < 400) {
          return _buildCompactPaginationControls();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFirstPageButton(),
              const SizedBox(width: 8),
              _buildPreviousButton(),
              const SizedBox(width: 16),
              _buildPageNumbers(),
              const SizedBox(width: 16),
              _buildNextButton(),
              const SizedBox(width: 8),
              _buildLastPageButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPreviousButton(),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            '${contestsService.currentPage} / ${contestsService.totalPages}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildNextButton(),
      ],
    );
  }

  Widget _buildFirstPageButton() {
    return IconButton(
      onPressed:
          contestsService.currentPage > 1
              ? () => contestsService.goToPage(1)
              : null,
      icon: const Icon(Icons.first_page, size: 20),
      tooltip: 'First Page',
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor:
            contestsService.currentPage > 1
                ? Colors.white
                : Colors.grey.shade200,
        foregroundColor:
            contestsService.currentPage > 1
                ? Colors.blue
                : Colors.grey.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        minimumSize: const Size(36, 36),
      ),
    );
  }

  Widget _buildPreviousButton() {
    return IconButton(
      onPressed:
          contestsService.hasPreviousPage
              ? () => contestsService.previousPage()
              : null,
      icon: const Icon(Icons.chevron_left, size: 20),
      tooltip: 'Previous',
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor:
            contestsService.hasPreviousPage
                ? Colors.white
                : Colors.grey.shade200,
        foregroundColor:
            contestsService.hasPreviousPage
                ? Colors.blue
                : Colors.grey.shade400,
        elevation: 0,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(36, 36),
      ),
    );
  }

  Widget _buildPageNumbers() {
    final visiblePages = contestsService.getVisiblePageNumbers();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          visiblePages.map((page) {
            final isCurrentPage = page == contestsService.currentPage;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: TextButton(
                onPressed:
                    isCurrentPage ? null : () => contestsService.goToPage(page),
                style: TextButton.styleFrom(
                  backgroundColor:
                      isCurrentPage ? const Color(0xFFF97316) : Colors.white,
                  foregroundColor:
                      isCurrentPage ? Colors.white : const Color(0xFFF97316),
                  side: BorderSide(
                    color:
                        isCurrentPage
                            ? const Color(0xFFF97316)
                            : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(36, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  page.toString(),
                  style: TextStyle(
                    fontWeight:
                        isCurrentPage ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildNextButton() {
    return IconButton(
      onPressed:
          contestsService.hasNextPage ? () => contestsService.nextPage() : null,
      icon: const Icon(Icons.chevron_right, size: 20),
      tooltip: 'Next',
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor:
            contestsService.hasNextPage ? Colors.white : Colors.grey.shade200,
        foregroundColor:
            contestsService.hasNextPage ? Colors.blue : Colors.grey.shade400,
        elevation: 0,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(36, 36),
      ),
    );
  }

  Widget _buildLastPageButton() {
    return IconButton(
      onPressed:
          contestsService.currentPage < contestsService.totalPages
              ? () => contestsService.goToPage(contestsService.totalPages)
              : null,
      icon: const Icon(Icons.last_page, size: 20),
      tooltip: 'Last Page',
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor:
            contestsService.currentPage < contestsService.totalPages
                ? Colors.white
                : Colors.grey.shade200,
        foregroundColor:
            contestsService.currentPage < contestsService.totalPages
                ? Colors.blue
                : Colors.grey.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        minimumSize: const Size(36, 36),
      ),
    );
  }
}
