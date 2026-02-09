import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_attributes_group/controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_attributes_group/model.dart';

class AddEditAttributeGroupScreen extends StatefulWidget {
  final AttributeGroupModel? existingGroup;

  const AddEditAttributeGroupScreen({super.key, this.existingGroup});

  @override
  State<AddEditAttributeGroupScreen> createState() =>
      _AddEditAttributeGroupScreenState();
}

class _AddEditAttributeGroupScreenState
    extends State<AddEditAttributeGroupScreen> {
  final controller = Get.find<AttributeGroupController>();
  final TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get isEditMode => widget.existingGroup != null;

  @override
  void initState() {
    super.initState();
    controller.selectedItemIds.clear();

    if (isEditMode) {
      nameController.text = widget.existingGroup!.name;
      controller.loadGroupForEdit(widget.existingGroup!);
    }

    controller.fetchProductAttributes();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          isEditMode ? 'Edit Attribute Group' : 'Add Attribute Group',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF009688),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildGroupNameSection(), _buildAttributesSection()],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildGroupNameSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF009688).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.label,
                    color: Color(0xFF009688),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Group Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
                prefixIcon: const Icon(Icons.drive_file_rename_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF009688),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a group name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributesSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF009688).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.checklist,
                  color: Color(0xFF009688),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Select Attributes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const Spacer(),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF009688),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.selectedItemIds.length} selected',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingAttributes.value) {
              return _buildAttributesShimmer();
            }

            if (controller.productAttributes.isEmpty) {
              return _buildEmptyAttributes();
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.productAttributes.length,
              itemBuilder: (context, index) {
                final attribute = controller.productAttributes[index];
                return _buildAttributeTile(attribute);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAttributeTile(ProductAttribute attribute) {
    final hasItems = attribute.attributeItems?.items.isNotEmpty ?? false;

    if (!hasItems) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final allSelected = controller.areAllSelectedInAttribute(attribute);
      final someSelected = controller.areSomeSelectedInAttribute(attribute);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                someSelected
                    ? const Color(0xFF009688).withOpacity(0.3)
                    : Colors.grey[300]!,
            width: someSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            leading: Checkbox(
              value: allSelected,
              tristate: true,
              activeColor: const Color(0xFF009688),
              onChanged: (value) {
                controller.selectAllInAttribute(attribute);
              },
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    attribute.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        someSelected
                            ? const Color(0xFF009688)
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${attribute.attributeItems!.items.where((item) => controller.selectedItemIds.contains(item.id)).length}/${attribute.attributeItems!.items.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: someSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attribute.attributeItems!.items.length,
                itemBuilder: (context, index) {
                  final item = attribute.attributeItems!.items[index];
                  final isSelected = controller.selectedItemIds.contains(
                    item.id,
                  );

                  return InkWell(
                    onTap: () => controller.toggleItemSelection(item.id),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF009688).withOpacity(0.08)
                                : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFF009688).withOpacity(0.3)
                                  : Colors.grey[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            activeColor: const Color(0xFF009688),
                            onChanged: (value) {
                              controller.toggleItemSelection(item.id);
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                color:
                                    isSelected
                                        ? const Color(0xFF009688)
                                        : const Color(0xFF212121),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF009688),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAttributesShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyAttributes() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No attributes available',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isSaving.value ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009688),
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                controller.isSaving.value
                    ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
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
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEditMode ? 'Update Group' : 'Create Group',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool success;
    if (isEditMode) {
      success = await controller.updateAttributeGroup(
        widget.existingGroup!.slug,
        nameController.text.trim(),
      );
    } else {
      success = await controller.createAttributeGroup(
        nameController.text.trim(),
      );
    }

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Attribute group ${isEditMode ? 'updated' : 'inserted'} successfully',
        colorText: Colors.white,
      );
    }
  }
}
