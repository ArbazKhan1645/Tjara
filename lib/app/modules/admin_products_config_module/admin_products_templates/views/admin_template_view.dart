import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_templates/controller/admin_template_controller.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_templates/views/widgets/template_list_widget.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_templates/views/widgets/template_form_dialog.dart';

class AdminTemplateView extends StatelessWidget {
  const AdminTemplateView({super.key});

  static const Color primaryTeal = Color(0xFF009688);
  static const Color accentTeal = Color(0xFF4DB6AC);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminTemplateController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Templates',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryTeal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => _showCreateDialog(context, controller),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              tooltip: 'Create Template',
            ),
          ),
        ],
      ),
      body: TemplateListWidget(controller: controller),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, controller),
        backgroundColor: primaryTeal,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Template',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showCreateDialog(
    BuildContext context,
    AdminTemplateController controller,
  ) {
    controller.clearForm();
    controller.loadInitialProducts();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TemplateFormDialog(controller: controller),
    );
  }
}
