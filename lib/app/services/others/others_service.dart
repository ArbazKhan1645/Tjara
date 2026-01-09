// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tjara/app/models/others/country_model.dart';
import 'package:tjara/app/models/others/state_model.dart';

import 'package:tjara/app/models/others/cities_model.dart';

class CountryService extends GetxService {
  static CountryService get instance => Get.find<CountryService>();
  final _box = GetStorage();
  var countryList = <Countries>[].obs;
  var stateList = <States>[].obs;
  var cityList = <City>[].obs;

  Future<CountryService> init() async {
    await GetStorage.init();
    // loadCountries();
    return this;
  }

  void loadCountries() async {
    final cachedData = _box.read('countries');
    if (cachedData != null) {
      try {
        countryList.value =
            CountryModel.fromJson(json.decode(cachedData)).countries ?? [];
      } catch (e) {
        await fetchCountries();
      }
    } else {
      await fetchCountries();
    }
  }

  Future<void> fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/countries'),
        headers: {"X-Request-From": "Application"},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body); // Decode once
        countryList.value = CountryModel.fromJson(jsonData).countries ?? [];
        _box.write('countries', json.encode(jsonData)); // Store correctly
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  // void loadStates(String countryID) {
  //   var cachedData = _box.read('states_$countryID');
  //   if (cachedData != null) {
  //     try {
  //       stateList.value =
  //           StatesModel.fromJson(json.decode(cachedData)).states ?? [];
  //     } catch (e) {
  //       fetchStates(countryID);
  //     }
  //   } else {
  //     fetchStates(countryID);
  //   }
  // }

  Future<void> fetchStates(String countryID) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/countries/$countryID/states'),
        headers: {"X-Request-From": "Application"},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        stateList.value = StatesModel.fromJson(jsonData).states ?? [];
        // _box.write('states_$countryID', json.encode(jsonData));
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  Future<void> fetchCities(String stateId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/states/$stateId/cities'),
        headers: {"X-Request-From": "Application"},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        cityList.value =
            (jsonData['cities'] as List)
                .map((e) => City.fromJson(e as Map<String, dynamic>))
                .toList();

        // _box.write('states_$stateId', json.encode(jsonData));
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
  }
}
