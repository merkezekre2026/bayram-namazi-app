import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];

  String? _selectedCountryId;
  String? _selectedCountryName;
  String? _selectedStateId;
  String? _selectedStateName;
  String? _selectedDistrictId;
  String? _selectedDistrictName;

  // Search filter terms
  String _stateSearchQuery = '';
  String _districtSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final countries = await _apiService.getCountries();
      setState(() {
        _countries = countries;
        // Default to Turkey (Id: 2) if present
        final turkey = countries.firstWhere((c) => c['name'] == 'TÜRKİYE', orElse: () => countries.first);
        _selectedCountryId = turkey['id'];
        _selectedCountryName = turkey['name'];
        _isLoading = false;
      });
      if (_selectedCountryId != null) {
        _loadStates(_selectedCountryId!);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ülkeler yüklenirken hata oluştu. Lütfen internetinizi kontrol edin.';
      });
    }
  }

  Future<void> _loadStates(String countryId) async {
    setState(() {
      _isLoading = true;
      _states = [];
      _districts = [];
      _selectedStateId = null;
      _selectedStateName = null;
      _selectedDistrictId = null;
      _selectedDistrictName = null;
    });

    try {
      final states = await _apiService.getStates(countryId);
      setState(() {
        _states = states;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Şehirler yüklenirken hata oluştu. Lütfen tekrar deneyin.';
      });
    }
  }

  Future<void> _loadDistricts(String stateId) async {
    setState(() {
      _isLoading = true;
      _districts = [];
      _selectedDistrictId = null;
      _selectedDistrictName = null;
    });

    try {
      final districts = await _apiService.getDistricts(stateId);
      setState(() {
        _districts = districts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'İlçeler yüklenirken hata oluştu. Lütfen tekrar deneyin.';
      });
    }
  }

  Future<void> _saveLocation() async {
    if (_selectedCountryId == null ||
        _selectedStateId == null ||
        _selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ülke, şehir ve ilçe seçimi yapın.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('country_id', _selectedCountryId!);
      await prefs.setString('country_name', _selectedCountryName!);
      await prefs.setString('state_id', _selectedStateId!);
      await prefs.setString('state_name', _selectedStateName!);
      await prefs.setString('district_id', _selectedDistrictId!);
      await prefs.setString('district_name', _selectedDistrictName!);

      // Clear cached prayer times of other districts to save space
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('cached_prayer_times_') && key != 'cached_prayer_times_${_selectedDistrictId}') {
          await prefs.remove(key);
        }
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Konum kaydedilirken bir hata oluştu.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter states
    final filteredStates = _states.where((state) {
      final name = (state['name'] as String).toLowerCase();
      final query = _stateSearchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    // Filter districts
    final filteredDistricts = _districts.where((district) {
      final name = (district['name'] as String).toLowerCase();
      final query = _districtSearchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KONUM SEÇİMİ'),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading && _countries.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4AF37),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0x33FF0000),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red, width: 0.5),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    const Text(
                      'Bayram namazı ve ezan vakitlerini görüntülemek istediğiniz konumu seçin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Country dropdown
                    if (_countries.isNotEmpty) ...[
                      const Text(
                        'Ülke Seçin',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D2D23),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x33D4AF37)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryId,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF0D2D23),
                            items: _countries.map((country) {
                              return DropdownMenuItem<String>(
                                value: country['id'],
                                child: Text(country['name']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final country = _countries.firstWhere((c) => c['id'] == val);
                                setState(() {
                                  _selectedCountryId = val;
                                  _selectedCountryName = country['name'];
                                });
                                _loadStates(val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // State / City Selection
                    if (_states.isNotEmpty) ...[
                      const Text(
                        'Şehir Seçin',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Şehir Ara...',
                          prefixIcon: const Icon(Icons.search, color: Color(0x88D4AF37)),
                          filled: true,
                          fillColor: const Color(0xFF0D2D23),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0x33D4AF37)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0x33D4AF37)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _stateSearchQuery = val;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D2D23),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x33D4AF37)),
                          ),
                          child: filteredStates.isEmpty
                              ? const Center(child: Text('Şehir bulunamadı.'))
                              : ListView.builder(
                                  itemCount: filteredStates.length,
                                  itemBuilder: (context, index) {
                                    final state = filteredStates[index];
                                    final isSelected = _selectedStateId == state['id'];
                                    return ListTile(
                                      title: Text(
                                        state['name'],
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                                        ),
                                      ),
                                      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFD4AF37)) : null,
                                      onTap: () {
                                        setState(() {
                                          _selectedStateId = state['id'];
                                          _selectedStateName = state['name'];
                                        });
                                        _loadDistricts(state['id']);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // District Selection
                    if (_selectedStateId != null && _districts.isNotEmpty) ...[
                      const Text(
                        'İlçe Seçin',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'İlçe Ara...',
                          prefixIcon: const Icon(Icons.search, color: Color(0x88D4AF37)),
                          filled: true,
                          fillColor: const Color(0xFF0D2D23),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0x33D4AF37)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0x33D4AF37)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _districtSearchQuery = val;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D2D23),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x33D4AF37)),
                          ),
                          child: filteredDistricts.isEmpty
                              ? const Center(child: Text('İlçe bulunamadı.'))
                              : ListView.builder(
                                  itemCount: filteredDistricts.length,
                                  itemBuilder: (context, index) {
                                    final dist = filteredDistricts[index];
                                    final isSelected = _selectedDistrictId == dist['id'];
                                    return ListTile(
                                      title: Text(
                                        dist['name'],
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                                        ),
                                      ),
                                      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFD4AF37)) : null,
                                      onTap: () {
                                        setState(() {
                                          _selectedDistrictId = dist['id'];
                                          _selectedDistrictName = dist['name'];
                                        });
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (_isLoading) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                        ),
                      ),
                    ] else if (_selectedDistrictId != null) ...[
                      ElevatedButton(
                        onPressed: _saveLocation,
                        child: const Text('KONUMU KAYDET VE DEVAM ET'),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
