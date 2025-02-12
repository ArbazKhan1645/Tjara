import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/helpers/logger.dart';

class AppService extends GetxService {
  static AppService get instance => Get.find<AppService>();
  // late final Stream<List<ConnectivityResult>> _connectivityResultStream;
  late final SharedPreferences _sharedPreferences;
  // final _currentConnectivity = Rx<ConnectivityResult>(ConnectivityResult.none);
  late final FlutterSecureStorage _secureStorage;
  Future<AppService> init() async {
    await _init();
    return this;
  }

  Future<void> _init() async {
    // _connectivityResultStream =
    //     Connectivity().onConnectivityChanged.asBroadcastStream();
    _sharedPreferences = await SharedPreferences.getInstance();

    _secureStorage = const FlutterSecureStorage();
    // await dotenv.load(fileName: ".env");
    // _connectivityResultStream.listen((results) {
    //   if (results.contains(ConnectivityResult.mobile) ||
    //       results.contains(ConnectivityResult.wifi) ||
    //       results.contains(ConnectivityResult.ethernet)) {
    //     _currentConnectivity.value = results.firstWhere(
    //       (result) =>
    //           result == ConnectivityResult.mobile ||
    //           result == ConnectivityResult.wifi ||
    //           result == ConnectivityResult.ethernet,
    //       orElse: () => ConnectivityResult.none,
    //     );
    //   } else {
    //     _currentConnectivity.value = ConnectivityResult.none;
    //   }
    // });
  }

  Future<FilePickerResult?> pickFile({
    FileType type = FileType.any,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: type,
          allowMultiple: allowMultiple,
          allowedExtensions: allowedExtensions);
      if (result != null) {
        AppLogger.info("File(s) picked: ${result.paths}");
      } else {
        AppLogger.warning("File picking cancelled by user.");
      }
      return result;
    } catch (e) {
      AppLogger.error("Error picking file: $e");
      return null;
    }
  }

  // Stream<List<ConnectivityResult>> get connectivityResultStream =>
  //     _connectivityResultStream;

  // ConnectivityResult get currentConnectivity => _currentConnectivity.value;

  // bool get isInternetConnected =>
  //     currentConnectivity == ConnectivityResult.mobile ||
  //     currentConnectivity == ConnectivityResult.wifi ||
  //     currentConnectivity == ConnectivityResult.ethernet;

  SharedPreferences get sharedPreferences => _sharedPreferences;

  FlutterSecureStorage get secureStorage => _secureStorage;

  String? getEnv(String key) => dotenv.env[key];
}
