// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/global_errorwidget.dart';
import 'package:tjara/app/core/utils/helpers/logger.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorLine = extractLineNumber(details.stack);

    AppLogger.error('''
ERROR: ${details.exception}
LINE: $errorLine
''');
  };

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return GlobalErrorWidget(errorDetails: errorDetails);
  };

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

String extractLineNumber(StackTrace? stack) {
  if (stack == null) return 'Unknown';

  final lines = stack.toString().split('\n');
  for (var line in lines) {
    if (line.contains('lib/')) {
      return line.trim();
    }
  }
  return 'Unknown';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // navigatorObservers: [RouteTracker()],
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.rightToLeft,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      title: 'TJARA',
      builder: (context, widget) {
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.0,
          child: widget!,
        );
      },
      // theme: lightThemeData(context),
      themeMode: ThemeMode.light,
      transitionDuration: const Duration(milliseconds: 200),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<String> uploadMedia(
  List<File> files, {
  String? directory,
  int? width,
  int? height,
}) async {
  final uri = Uri.parse('https://api.libanbuy.com/api/media/insert');

  final request = http.MultipartRequest('POST', uri);

  request.headers.addAll({
    'X-Request-From': 'Application',
    'Accept': 'application/json',
  });

  // Add media files
  for (var file in files) {
    final stream = http.ByteStream(file.openRead());
    final length = await file.length();

    final multipartFile = http.MultipartFile(
      'media[]',
      stream,
      length,
      filename: path.basename(file.path),
    );

    request.files.add(multipartFile);
  }

  // Add optional parameters
  if (directory != null) {
    request.fields['directory'] = directory;
  }

  if (width != null) {
    request.fields['width'] = width.toString();
  }

  if (height != null) {
    request.fields['height'] = height.toString();
  }

  // Send request and allow redirects
  final response = await request.send();

  // Handle redirect manually
  if (response.statusCode == 302 || response.statusCode == 301) {
    final redirectUrl = response.headers['location'];
    if (redirectUrl != null) {
      return await uploadMedia(
        files,
        directory: directory,
        width: width,
        height: height,
      );
    }
  }

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    final jsonData = jsonDecode(responseBody);
    return jsonData['media'][0]['id'];
  } else {
    return 'Failed to upload media. Status code: ${response.statusCode} Response body: ${await response.stream.bytesToString()}';
  }
}
