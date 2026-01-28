import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';
import 'package:tjara/app/services/orders_service.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class OrdersDisputeOverview extends StatefulWidget {
  const OrdersDisputeOverview({super.key});

  @override
  State<OrdersDisputeOverview> createState() => _OrdersDisputeOverviewState();
}

class _OrdersDisputeOverviewState extends State<OrdersDisputeOverview> {
  final OrderService _orderService = Get.find<OrderService>();
  final OrdersDashboardController controller =
      Get.find<OrdersDashboardController>();
  String? selectedReason;
  TextEditingController descriptionController = TextEditingController();
  final List<String> reasons = [
    "Damaged Item",
    "Wrong Item Sent",
    "Late Delivery",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Dispute',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: 30,
                    bottom: -10,
                    left: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.05,
                            ), // Shadow color
                            blurRadius: 1, // Softness of shadow
                            spreadRadius: 1, // How much the shadow expands
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const SizedBox(
                        height: 100,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // Shadow color
                          blurRadius: 1, // Softness of shadow
                          spreadRadius: 1, // How much the shadow expands
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                "Dispute Information",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          const Text(
                            "Reason",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Required",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Enter the unique name of your dispute. Make it descriptive and easy to remember for customers.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: selectedReason,
                            hint: const Text("Select a Reason"),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items:
                                reasons.map((String reason) {
                                  return DropdownMenuItem<String>(
                                    value: reason,
                                    child: Text(reason),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedReason = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: 30,
                    bottom: -10,
                    left: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.05,
                            ), // Shadow color
                            blurRadius: 1, // Softness of shadow
                            spreadRadius: 1, // How much the shadow expands
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const SizedBox(
                        height: 100,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // Shadow color
                          blurRadius: 1, // Softness of shadow
                          spreadRadius: 1, // How much the shadow expands
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                "Dispute Details",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          const Text(
                            "Dispute Details",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Required",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Craft a comprehensive and detailed description of the issue you're facing. This will help us understand your concerns and provide a clear understanding of the situation.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: descriptionController,
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 10),
            Material(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(11),
              child: MaterialButton(
                height: 52,
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () async {
                  await controller.addOrderDispute(
                    controller.selectedOrder.value?.id ?? '',
                    context,
                    AuthService.instance.authCustomer?.user?.id?.toString() ??
                        '',
                    selectedReason ?? '',
                    descriptionController.text,
                  );
                  setState(() {});
                },
                child: Text(
                  "Save Dispute",
                  style: defaultTextStyle.copyWith(color: Colors.white),
                ),
              ),
            ),
            Container(height: 200),
          ],
        ),
      ],
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
