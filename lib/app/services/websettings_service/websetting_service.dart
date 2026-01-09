// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:tjara/app/models/website_settings/website_model.dart';
import 'package:tjara/app/repo/network_repository.dart';

class WebsiteOptionsService extends GetxService {
  // Observable variable to store website options
  final Rx<WebsiteOptions?> _websiteOptions = Rx<WebsiteOptions?>(null);

  // Getter for website options
  WebsiteOptions? get websiteOptions => _websiteOptions.value;

  final NetworkRepository _repository = NetworkRepository();

  // Function to fetch options from API
  Future<WebsiteOptions?> fetchWebsiteOptions() async {
    try {
      if (_websiteOptions.value != null) {
        return _websiteOptions.value;
      }
      final result = await _repository.fetchData<WebsiteResponse>(
        url: 'https://api.libanbuy.com/api/global-settings',
        fromJson: (json) => WebsiteResponse.fromJson(json),
        forceRefresh: true,
      );

      _websiteOptions.value = result.options;
      return result.options;
    } catch (e) {
      return null;
    }
  }

  // Method to initialize the service
  Future<WebsiteOptionsService> init() async {
    await fetchWebsiteOptions();
    return this;
  }

  // Method to clear the cached options (useful for refreshing)
  void clearCache() {
    _websiteOptions.value = null;
  }

  // Helper method to easily access a specific option with a default value
  String getOption(
    String Function(WebsiteOptions options) getter, {
    String defaultValue = '',
  }) {
    try {
      if (_websiteOptions.value == null) {
        // Trigger fetch if options are not loaded yet
        fetchWebsiteOptions();
        return defaultValue;
      }

      final value = getter(_websiteOptions.value!);
      return value ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
}
