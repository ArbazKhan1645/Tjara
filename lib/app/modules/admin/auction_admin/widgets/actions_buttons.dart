// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class ProductActionButtons extends StatelessWidget {
//   final String productId;
//   final String productName;
//   final String productSku;
//   final bool isActive;
//   final bool isFeatured;
//   final bool isDeal;
//   final VoidCallback? onActiveChanged;
//   final VoidCallback? onFeaturedChanged;
//   final VoidCallback? onDealChanged;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;

//   const ProductActionButtons({
//     Key? key,
//     required this.productId,
//     required this.productName,
//     required this.productSku,
//     this.isActive = false,
//     this.isFeatured = false,
//     this.isDeal = false,
//     this.onActiveChanged,
//     this.onFeaturedChanged,
//     this.onDealChanged,
//     this.onEdit,
//     this.onDelete,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // QR Code Button
//         IconButton(
//           onPressed: () => _showQRCodeDialog(context),
//           icon: const Icon(Icons.qr_code, size: 24),
//           tooltip: 'Show QR Code',
//         ),
        
//         // Active Status Button
//         IconButton(
//           onPressed: () => _showActiveDialog(context),
//           icon: Icon(
//             isActive ? Icons.visibility : Icons.visibility_off,
//             size: 24,
//             color: isActive ? Colors.green : Colors.grey,
//           ),
//           tooltip: isActive ? 'Product Active' : 'Product Inactive',
//         ),
        
//         // Featured Button
//         IconButton(
//           onPressed: () => _showFeaturedDialog(context),
//           icon: Icon(
//             Icons.star,
//             size: 24,
//             color: isFeatured ? Colors.amber : Colors.grey,
//           ),
//           tooltip: isFeatured ? 'Featured Product' : 'Not Featured',
//         ),
        
//         // Deal Button
//         IconButton(
//           onPressed: () => _showDealDialog(context),
//           icon: Icon(
//             Icons.local_offer,
//             size: 24,
//             color: isDeal ? Colors.red : Colors.grey,
//           ),
//           tooltip: isDeal ? 'Deal Product' : 'Not on Deal',
//         ),
        
//         // More Options Button
//         PopupMenuButton<String>(
//           onSelected: _handleMenuSelection,
//           icon: const Icon(Icons.more_vert, size: 28),
//           itemBuilder: (BuildContext context) => [
//             const PopupMenuItem<String>(
//               value: 'edit',
//               child: Row(
//                 children: [
//                   Icon(Icons.edit, size: 20, color: Colors.blue),
//                   SizedBox(width: 8),
//                   Text('Edit'),
//                 ],
//               ),
//             ),
//             const PopupMenuItem<String>(
//               value: 'delete',
//               child: Row(
//                 children: [
//                   Icon(Icons.delete, size: 20, color: Colors.red),
//                   SizedBox(width: 8),
//                   Text('Delete'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   void _showQRCodeDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             width: 350,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Inventory QR Code',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       icon: const Icon(Icons.close),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   productName,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'SKU: $productSku',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: QrImageView(
//                     data: productId,
//                     version: QrVersions.auto,
//                     size: 200.0,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text('Close'),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => _printQRCode(),
//                         icon: const Icon(Icons.print, color: Colors.white),
//                         label: const Text('Print QR Code'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.pink,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showActiveDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Product Status'),
//           content: Text(
//             isActive
//                 ? 'Do you want to make this product inactive?'
//                 : 'Do you want to make this product active?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 onActiveChanged?.call();
//               },
//               child: Text(isActive ? 'Make Inactive' : 'Make Active'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showFeaturedDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Featured Product'),
//           content: Text(
//             isFeatured
//                 ? 'Do you want to remove this product from featured?'
//                 : 'Do you want to make this product featured?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 onFeaturedChanged?.call();
//               },
//               child: Text(isFeatured ? 'Remove Featured' : 'Make Featured'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showDealDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Deal Product'),
//           content: Text(
//             isDeal
//                 ? 'Do you want to remove this product from deals?'
//                 : 'Do you want to add this product to deals?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 onDealChanged?.call();
//               },
//               child: Text(isDeal ? 'Remove from Deal' : 'Add to Deal'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _handleMenuSelection(String value) {
//     switch (value) {
//       case 'edit':
//         onEdit?.call();
//         break;
//       case 'delete':
//         _showDeleteConfirmation();
//         break;
//     }
//   }

//   void _showDeleteConfirmation() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Delete Product'),
//         content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               onDelete?.call();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _printQRCode() {
//     // Implement your print functionality here
//     // You might want to use packages like printing or pdf
//     Get.snackbar(
//       'Print QR Code',
//       'QR Code sent to printer',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }
// }

// // Usage Example:
// class ProductListItem extends StatefulWidget {
//   final Map<String, dynamic> product;

//   const ProductListItem({Key? key, required this.product}) : super(key: key);

//   @override
//   State<ProductListItem> createState() => _ProductListItemState();
// }

// class _ProductListItemState extends State<ProductListItem> {
//   late bool isActive;
//   late bool isFeatured;
//   late bool isDeal;

//   @override
//   void initState() {
//     super.initState();
//     isActive = widget.product['isActive'] ?? false;
//     isFeatured = widget.product['isFeatured'] ?? false;
//     isDeal = widget.product['isDeal'] ?? false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         title: Text(widget.product['name'] ?? 'Product Name'),
//         subtitle: Text('SKU: ${widget.product['sku'] ?? 'N/A'}'),
//         trailing: ProductActionButtons(
//           productId: widget.product['id'] ?? '',
//           productName: widget.product['name'] ?? 'Product Name',
//           productSku: widget.product['sku'] ?? 'N/A',
//           isActive: isActive,
//           isFeatured: isFeatured,
//           isDeal: isDeal,
//           onActiveChanged: () {
//             setState(() {
//               isActive = !isActive;
//             });
//             // Call your API to update status
//             _updateProductStatus('active', isActive);
//           },
//           onFeaturedChanged: () {
//             setState(() {
//               isFeatured = !isFeatured;
//             });
//             // Call your API to update featured status
//             _updateProductStatus('featured', isFeatured);
//           },
//           onDealChanged: () {
//             setState(() {
//               isDeal = !isDeal;
//             });
//             // Call your API to update deal status
//             _updateProductStatus('deal', isDeal);
//           },
//           onEdit: () {
//             // Navigate to edit page
//             Get.toNamed('/edit-product', arguments: widget.product);
//           },
//           onDelete: () {
//             // Call delete API
//             _deleteProduct();
//           },
//         ),
//       ),
//     );
//   }

//   void _updateProductStatus(String type, bool value) {
//     // Implement your API call here
//     print('Updating $type status to $value for product ${widget.product['id']}');
//   }

//   void _deleteProduct() {
//     // Implement your delete API call here
//     print('Deleting product ${widget.product['id']}');
//   }
// }