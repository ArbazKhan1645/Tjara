import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';

// Model classes
class Country {
  final String id;
  final String name;
  final String? countryCode;
  final String? currency;
  final String? currencyCode;

  Country({
    required this.id,
    required this.name,
    this.countryCode,
    this.currency,
    this.currencyCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      countryCode: json['country_code'],
      currency: json['currency'],
      currencyCode: json['currency_code'],
    );
  }
}

class State {
  final String id;
  final String countryId;
  final String name;
  final String? isoCode;

  State({
    required this.id,
    required this.countryId,
    required this.name,
    this.isoCode,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'],
      countryId: json['country_id'],
      name: json['name'],
      isoCode: json['iso_code'],
    );
  }
}

class City {
  final String id;
  final String stateId;
  final String name;

  City({required this.id, required this.stateId, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: json['id'], stateId: json['state_id'], name: json['name']);
  }
}

// Extension to AddProductAdminController for location functionality
extension LocationExtension on AddProductAdminController {
  // Location data lists
  List<Country> get countries => _countries;
  List<State> get states => _states;
  List<City> get cities => _cities;

  // Selected values
  Country? get selectedCountry => _selectedCountry.value;
  State? get selectedState => _selectedState.value;
  City? get selectedCity => _selectedCity.value;

  // Loading states
  bool get isLoadingCountries => _isLoadingCountries.value;
  bool get isLoadingStates => _isLoadingStates.value;
  bool get isLoadingCities => _isLoadingCities.value;

  // Private reactive variables (add these to your AddProductAdminController)
  static final RxList<Country> _countries = <Country>[].obs;
  static final RxList<State> _states = <State>[].obs;
  static final RxList<City> _cities = <City>[].obs;

  static final Rx<Country?> _selectedCountry = Rx<Country?>(null);
  static final Rx<State?> _selectedState = Rx<State?>(null);
  static final Rx<City?> _selectedCity = Rx<City?>(null);

  static final RxBool _isLoadingCountries = false.obs;
  static final RxBool _isLoadingStates = false.obs;
  static final RxBool _isLoadingCities = false.obs;

  // Initialize location data
  void initializeLocationData() {
    if (_countries.isEmpty && !_isLoadingCountries.value) {
      // Defer fetching until after the current build to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchCountries();
      });
    }
  }

  // Preload location selections based on meta IDs when editing
  Future<void> preloadLocationFromMeta(
    String? countryId,
    String? stateId,
    String? cityId,
  ) async {
    try {
      if (countryId == null || countryId.isEmpty) return;
      // Ensure countries loaded
      if (_countries.isEmpty) {
        await fetchCountries();
      }
      final Country? foundCountry = _countries.firstWhereOrNull(
        (c) => c.id == countryId,
      );
      if (foundCountry != null) {
        _selectedCountry.value = foundCountry;
        update();
        await fetchStates(foundCountry.id);
      }

      if (stateId != null && stateId.isNotEmpty) {
        final State? foundState = _states.firstWhereOrNull(
          (s) => s.id == stateId,
        );
        if (foundState != null) {
          _selectedState.value = foundState;
          update();
          await fetchCities(foundState.id);
        }
      }

      if (cityId != null && cityId.isNotEmpty) {
        final City? foundCity = _cities.firstWhereOrNull((c) => c.id == cityId);
        if (foundCity != null) {
          _selectedCity.value = foundCity;
          update();
        }
      }
    } catch (_) {
      // Ignore preload errors to not block editing
    }
  }

  Future<void> fetchCountries() async {
    try {
      _isLoadingCountries.value = true;
      update();
      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/countries'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Dashboard',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> countriesJson = data['countries'];
        _countries.value =
            countriesJson.map((json) => Country.fromJson(json)).toList();
        // Rebind selection to instance from the latest list to satisfy DropdownButton identity
        if (_selectedCountry.value != null) {
          final String selId = _selectedCountry.value!.id;
          final Country? rebound = _countries.firstWhereOrNull(
            (c) => c.id == selId,
          );
          _selectedCountry.value = rebound;
        }
        update();
      } else {
        Get.snackbar('Error', 'Failed to fetch countries');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch countries: $e');
    } finally {
      _isLoadingCountries.value = false;
      update();
    }
  }

  Future<void> fetchStates(String countryId) async {
    try {
      _isLoadingStates.value = true;
      _states.clear();
      _cities.clear();
      _selectedState.value = null;
      _selectedCity.value = null;
      update();

      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/countries/$countryId/states'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Dashboard',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> statesJson = data['states'];
        _states.value = statesJson.map((json) => State.fromJson(json)).toList();
        if (_selectedState.value != null) {
          final String selId = _selectedState.value!.id;
          final State? rebound = _states.firstWhereOrNull((s) => s.id == selId);
          _selectedState.value = rebound;
        }
        update();
      } else {
        Get.snackbar('Error', 'Failed to fetch states');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch states: $e');
    } finally {
      _isLoadingStates.value = false;
      update();
    }
  }

  Future<void> fetchCities(String stateId) async {
    try {
      _isLoadingCities.value = true;
      _cities.clear();
      _selectedCity.value = null;
      update();

      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/states/$stateId/cities'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Dashboard',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> citiesJson = data['cities'];
        _cities.value = citiesJson.map((json) => City.fromJson(json)).toList();
        if (_selectedCity.value != null) {
          final String selId = _selectedCity.value!.id;
          final City? rebound = _cities.firstWhereOrNull((c) => c.id == selId);
          _selectedCity.value = rebound;
        }
        update();
      } else {
        Get.snackbar('Error', 'Failed to fetch cities');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch cities: $e');
    } finally {
      _isLoadingCities.value = false;
      update();
    }
  }

  void selectCountry(Country country) {
    _selectedCountry.value = country;
    fetchStates(country.id);
    update(); // Trigger UI rebuild
  }

  void selectState(State state) {
    _selectedState.value = state;
    fetchCities(state.id);
    update(); // Trigger UI rebuild
  }

  void selectCity(City city) {
    _selectedCity.value = city;
    update(); // Trigger UI rebuild
  }

  // Reset location data
  void resetLocationData() {
    _selectedCountry.value = null;
    _selectedState.value = null;
    _selectedCity.value = null;
    _states.clear();
    _cities.clear();
  }
}

// Main widget
class SellingAreaWidget extends StatelessWidget {
  final AddProductAdminController controller;

  const SellingAreaWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Initialize location data when widget is built
    controller.initializeLocationData();

    return GetBuilder<AddProductAdminController>(
      builder: (controller) {
        return ProductFieldsCardCustomWidget(
          column: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Selling Area'),
              const SizedBox(height: 20),

              // Country Section
              _buildCountrySection(controller),
              const SizedBox(height: 20),

              // State Section
              _buildStateSection(controller),
              const SizedBox(height: 20),

              // City Section
              _buildCitySection(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xffF97316),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildCountrySection(AddProductAdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Country',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Add country here.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child:
              controller.isLoadingCountries
                  ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : DropdownButtonHideUnderline(
                    child: DropdownButton<Country>(
                      value:
                          controller.countries.any(
                                (c) => c.id == controller.selectedCountry?.id,
                              )
                              ? controller.selectedCountry
                              : null,
                      hint: const Text(
                        'Country',
                        style: TextStyle(color: Colors.grey),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items:
                          controller.countries.map((Country country) {
                            return DropdownMenuItem<Country>(
                              value: country,
                              child: Text(country.name),
                            );
                          }).toList(),
                      onChanged: (Country? newValue) {
                        if (newValue != null) {
                          controller.selectCountry(newValue);
                        }
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildStateSection(AddProductAdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'State/Governorate',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Add state/governorate here.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color:
                controller.selectedCountry == null
                    ? Colors.grey.shade50
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child:
              controller.isLoadingStates
                  ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : DropdownButtonHideUnderline(
                    child: DropdownButton<State>(
                      value:
                          controller.states.any(
                                (s) => s.id == controller.selectedState?.id,
                              )
                              ? controller.selectedState
                              : null,
                      hint: const Text(
                        'Select State/Governorate',
                        style: TextStyle(color: Colors.grey),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items:
                          controller.selectedCountry == null
                              ? []
                              : controller.states.map((State state) {
                                return DropdownMenuItem<State>(
                                  value: state,
                                  child: Text(state.name),
                                );
                              }).toList(),
                      onChanged:
                          controller.selectedCountry == null
                              ? null
                              : (State? newValue) {
                                if (newValue != null) {
                                  controller.selectState(newValue);
                                }
                              },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildCitySection(AddProductAdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'City',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Add city here.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color:
                controller.selectedState == null
                    ? Colors.grey.shade50
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child:
              controller.isLoadingCities
                  ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : DropdownButtonHideUnderline(
                    child: DropdownButton<City>(
                      value:
                          controller.cities.any(
                                (c) => c.id == controller.selectedCity?.id,
                              )
                              ? controller.selectedCity
                              : null,
                      hint: const Text(
                        'Select a City',
                        style: TextStyle(color: Colors.grey),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items:
                          controller.selectedState == null
                              ? []
                              : controller.cities.map((City city) {
                                return DropdownMenuItem<City>(
                                  value: city,
                                  child: Text(city.name),
                                );
                              }).toList(),
                      onChanged:
                          controller.selectedState == null
                              ? null
                              : (City? newValue) {
                                if (newValue != null) {
                                  controller.selectCity(newValue);
                                }
                              },
                    ),
                  ),
        ),
      ],
    );
  }
}

class ProductFieldsCardCustomWidget extends StatelessWidget {
  final Widget column;
  const ProductFieldsCardCustomWidget({super.key, required this.column});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: column,
            ),
            const SizedBox(height: 15),
          ],
        ),
        const Positioned(
          bottom: 0,
          left: 20,
          right: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: SizedBox(height: 15),
          ),
        ),
      ],
    );
  }
}
