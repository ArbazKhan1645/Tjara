// ignore_for_file: unused_catch_clause, avoid_print, use_build_context_synchronously, depend_on_referenced_packages
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/modules/my_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/services/auth/apis.dart';
import '../../../services/app/app_service.dart';
import '../../../services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DeviceActivationController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool hasError = false;
  RxString loginError = ''.obs;
  void onTogglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  setLoginError(String val) {
    loginError.value = val;
    update();
  }

  Future<void> onLogin(BuildContext context) async {
    try {
      String email = emailController.text;
      String password = passwordController.text;
      setLoginError('');
      if (!formKey.currentState!.validate()) return;
      setIsLogin(true);
      final res = await AuthenticationApiService.loginUser(email, password);
      if (res is LoginResponse) {
        _authService.saveAuthState(res);
        CartService cartService = Get.find<CartService>();
        cartService.initcall();
        Get.back();
        Get.snackbar('Success', 'User Login Sucessfully',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        hasError = true;
        Get.snackbar('Error', res,
            backgroundColor: Colors.red, colorText: Colors.white);
        setLoginError(res.toString());
      }
    } catch (e) {
      Get.snackbar('Error', 'User Login failed',
          backgroundColor: Colors.red, colorText: Colors.white);
      hasError = true;
      setLoginError(e.toString());
    } finally {
      setIsLogin(false);
    }
  }

  setIsLogin(bool val) {
    isLoggingIn.value = val;
    update();
  }

  final formKey = GlobalKey<FormState>();

  ///////////////////////////////////////////login///////////////////
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController signupemailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController sinuppasswordController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  Future<void> onregister(BuildContext context) async {
    try {
      await AuthenticationApiService.registerUser(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          context: context,
          email: signupemailController.text,
          phone: phoneController.text,
          password: sinuppasswordController.text,
          role: '0');
    } catch (e) {
      Get.snackbar('Error', 'User Register failed',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  ///////////////////////////////////////////////signup///////////////////////
  Future<String> uploadImage(File? image) async {
    try {
      if (image != null) {
        String filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';

        String imageurl =
            'https://oboeejxzmorurvvwocsd.supabase.co/storage/v1/object/public/merchants/locations/$filename';

        return imageurl;
      } else {
        return "";
      }
    } on TimeoutException catch (e) {
      print("Timeout Error: $e");
      return "";
    } on SocketException catch (e) {
      print("Internet Connection Error: $e");
      return ""; // Handle connection errors
    } on Exception catch (e) {
      print("Unknown Error: $e");
      return ""; // Handle any other errors
    } finally {
      update(); // Ensure update is called regardless of outcome
    }
  }

  final GlobalKey<FormState> formKeysLocation = GlobalKey<FormState>();
  removeImagelistitems(var image) {
    imageslist.remove(image);

    update();
  }

  String locationAddingerror = '';
  setlocationAddingerror(String error) {
    locationAddingerror = error;
    update();
  }

  File? selectedImage;
  pickimagefromstorage(BuildContext context) async {
    selectedImage = await pickImage();
    print(selectedImageLocation);
    addimagetoImagelist(selectedImage as File, context);
    update();
  }

  Future pickImage() async {
    File? selectedImage;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      selectedImage = File(result.files.single.path!);
      return selectedImage;
    }
  }

  String errormessage = '';
  bool isValidUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.isScheme("http") || uri.isScheme("https");
  }

  bool loadedimagevalidation = false;
  setloadingofImageValidationCheck() {
    loadedimagevalidation = !loadedimagevalidation;
    update();
  }

  Future<bool> validateAndAddImage(
      String imageUrl, BuildContext context) async {
    setloadingofImageValidationCheck();
    bool pictureloaded = false;
    errormessage = '';
    try {
      http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        String contentType = response.headers['content-type'] ?? '';
        if (contentType.startsWith('image/')) {
          pictureloaded = true;
        } else {
          errormessage = 'Invalid Content Type';
        }
      } else {
        errormessage = 'Failed to Load Image';
      }
    } catch (error) {
      errormessage = 'Error: $error';
    }
    setloadingofImageValidationCheck();
    return pictureloaded;
  }

  addimagetoImagelist(var image, BuildContext context) async {
    if (image is String) {
      if (isValidUrl(image)) {
        bool pictureloaded;
        pictureloaded = await validateAndAddImage(image, context);
        if (pictureloaded == true) {
          imageslist.add(image);
        }
      } else {
        errormessage = 'Invalid URLS';
      }
    } else {
      imageslist.add(image);
    }
    update();
  }

  List<dynamic> imageslist = [];

  RxString selectedImageLocation = ''.obs;
  setSelectedImage(String val) {
    selectedImageLocation.value = val;
    update();
  }

  final _appService = Get.find<AppService>();
  final _authService = Get.find<AuthService>();

  var isLoading = false.obs;
  setIsloading() {
    isLoading.value = !isLoading.value;
    update();
  }

  XFile? image;

  var logoUrl = ''.obs;
  var isLoggingIn = false.obs;

  var isSignInVisible = false.obs;
  var isSignInVisible2 = false.obs;
  RxString selectedPage = ''.obs;
}
