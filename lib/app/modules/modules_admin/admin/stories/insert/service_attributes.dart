// // ignore_for_file: library_private_types_in_public_api

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as path;
// import 'package:tjara/app/modules/admin/services_admin/insert/attributes_model.dart';

// class ServiceAttributesScreen extends StatefulWidget {
//   const ServiceAttributesScreen({super.key});

//   @override
//   _ServiceAttributesScreenState createState() =>
//       _ServiceAttributesScreenState();
// }

// class _ServiceAttributesScreenState extends State<ServiceAttributesScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   List<ServiceAttribute> _attributes = [];
//   List<ServiceAttributeItem> _parentAttributes = [];
//   ServiceAttributeItem? _selectedParent;
//   bool _isLoading = true;
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _fetchAttributes();
//   }

//   Future<void> _fetchAttributes() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('https://api.libanbuy.com/api/service-attributes'),
//         headers: {
//           'X-Request-From': 'Application',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         List<ServiceAttribute> attributes = [];
//         List<ServiceAttributeItem> parentAttributes = [];

//         for (var item in jsonData['service_attributes']) {
//           final attribute = ServiceAttribute.fromJson(item);
//           attributes.add(attribute);

//           // Add to parent list if it can be a parent
//           parentAttributes
//               .addAll(attribute.attributeItems!.serviceAttributeItems!);
//         }

//         setState(() {
//           _attributes = attributes;
//           _parentAttributes = parentAttributes;
//           _isLoading = false;
//         });
//       } else {
//         _showErrorSnackbar('Failed to load attributes');
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       _showErrorSnackbar('Error: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _selectedImage = File(image.path);
//       });
//     }
//   }

//   Future<String?> _uploadMedia(File file) async {
//     try {
//       var uri = Uri.parse('https://api.libanbuy.com/api/media/insert');
//       var request = http.MultipartRequest('POST', uri);

//       request.headers.addAll({
//         'X-Request-From': 'Application',
//         'Accept': 'application/json',
//       });

//       var stream = http.ByteStream(file.openRead());
//       var length = await file.length();

//       var multipartFile = http.MultipartFile(
//         'media[]',
//         stream,
//         length,
//         filename: path.basename(file.path),
//       );

//       request.files.add(multipartFile);

//       var response = await request.send();

//       if (response.statusCode == 302 || response.statusCode == 301) {
//         var redirectUrl = response.headers['location'];
//         if (redirectUrl != null) {
//           // Handle redirect if needed
//           return null;
//         }
//       }

//       if (response.statusCode == 200) {
//         var responseBody = await response.stream.bytesToString();
//         var jsonData = jsonDecode(responseBody);
//         return jsonData['media'][0]['id'];
//       } else {
//         _showErrorSnackbar('Failed to upload image: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       _showErrorSnackbar('Error uploading image: $e');
//       return null;
//     }
//   }

//   Future<void> _submitAttribute() async {
//     if (_nameController.text.isEmpty) {
//       _showErrorSnackbar('Name is required');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // First upload image if selected
//       String? thumbnailId;
//       if (_selectedImage != null) {
//         thumbnailId = await _uploadMedia(_selectedImage!);
//         if (thumbnailId == null) {
//           setState(() {
//             _isLoading = false;
//           });
//           return;
//         }
//       }

//       // Then create the attribute
//       final response = await http.post(
//         Uri.parse('https://api.libanbuy.com/api/service-attribute-items/insert'),
//         headers: {
//           'X-Request-From': 'Application',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'name': _nameController.text,
//           'parent_id': _selectedParent?.id,
//           'thumbnail_id': thumbnailId,
//           'attribute_id': _attributes[0].id
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         _showSuccessSnackbar('Attribute created successfully');
//         _nameController.clear();
//         setState(() {
//           _selectedParent = null;
//           _selectedImage = null;
//         });
//         _fetchAttributes();
//       } else {
//         _showErrorSnackbar(
//             'Failed to create attribute: ${response.statusCode}');
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       _showErrorSnackbar('Error creating attribute: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Services Categories'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Column(
//                 children: [
//                   _buildAddAttributeWidget(),
//                   const SizedBox(height: 16),
//                   _buildAttributesListWidget(),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildAddAttributeWidget() {
//     return Card(
//       margin: const EdgeInsets.all(16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'ADD CATEGORIES ITEM',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text('Categories Item Name'),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 hintText: 'Attribute Item Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text('Parent Categories'),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<ServiceAttributeItem>(
//               decoration: const InputDecoration(
//                 hintText: 'Select Parent',
//                 border: OutlineInputBorder(),
//               ),
//               value: _selectedParent,
//               items: [
//                 const DropdownMenuItem<ServiceAttributeItem>(
//                   value: null,
//                   child: Text('None'),
//                 ),
//                 ..._parentAttributes.map((attribute) {
//                   return DropdownMenuItem<ServiceAttributeItem>(
//                     value: attribute,
//                     child: Text(attribute.name.toString()),
//                   );
//                 }),
//               ],
//               onChanged: (ServiceAttributeItem? value) {
//                 setState(() {
//                   _selectedParent = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 16),
//             const Text('Categories Item Image'),
//             const SizedBox(height: 8),
//             GestureDetector(
//               onTap: _pickImage,
//               child: Container(
//                 height: 120,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: _selectedImage != null
//                     ? Image.file(
//                         _selectedImage!,
//                         fit: BoxFit.cover,
//                       )
//                     : Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(Icons.file_upload),
//                           SizedBox(height: 8),
//                           Text('Upload a file or drag and drop'),
//                         ],
//                       ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 onPressed: _submitAttribute,
//                 child: const Text(
//                   'Submit',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 onPressed: () {
//                   _nameController.clear();
//                   setState(() {
//                     _selectedParent = null;
//                     _selectedImage = null;
//                   });
//                 },
//                 child: const Text('Cancel'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttributesListWidget() {
//     return Card(
//       margin: const EdgeInsets.all(16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'CATEGORIES ITEMS',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Column(
//               children: [
//                 // Header
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(4),
//                       topRight: Radius.circular(4),
//                     ),
//                   ),
//                   child: Row(
//                     children: const [
//                       Expanded(
//                         flex: 2,
//                         child: Text(
//                           'Name',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 1,
//                         child: Text(
//                           'Parent',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       SizedBox(width: 40),
//                     ],
//                   ),
//                 ),
//                 // List items
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: _attributes[0]
//                           .attributeItems
//                           ?.serviceAttributeItems
//                           ?.length ??
//                       0,
//                   itemBuilder: (context, index) {
//                     final attribute = _attributes[0]
//                         .attributeItems
//                         ?.serviceAttributeItems?[index];
//                     return Container(
//                       decoration: BoxDecoration(
//                         border: Border(
//                           bottom: BorderSide(color: Colors.grey[300]!),
//                         ),
//                       ),
//                       child: ListTile(
//                         leading: Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: attribute?.thumbnail?.media?.localUrl != null
//                                 ? null
//                                 : Colors
//                                     .primaries[index % Colors.primaries.length],
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: attribute?.thumbnail?.media?.localUrl != null
//                               ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(4),
//                                   child: Image.network(
//                                     attribute?.thumbnail?.media?.localUrl ?? '',
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )
//                               : Center(
//                                   child: Text(
//                                     attribute!.name.toString().isNotEmpty
//                                         ? attribute.name.toString()[0]
//                                         : '',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                         ),
//                         title: Text(attribute!.name.toString()),
//                         trailing: Text(
//                           'None',
//                           style: TextStyle(color: Colors.grey[600]),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }
// }
