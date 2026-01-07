import 'package:flutter/material.dart';
import 'package:store_buy/service/theme_service.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:store_buy/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StoreSettingsScreen extends StatefulWidget {
  final String? storeId;
  const StoreSettingsScreen({super.key, this.storeId});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final ThemeService _themeService = ThemeService();
  final StoreService _storeService = StoreService();
  final ImagePicker _picker = ImagePicker();
  
  String? _selectedStoreId;
  String? _primaryColor;
  String? _secondaryColor;
  String? _fontFamily;
  String? _logoPath;
  String? _bannerPath;
  bool _isLoading = true;

  final List<String> _fonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Raleway',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (widget.storeId != null) {
      _selectedStoreId = widget.storeId;
    } else if (authProvider.currentUser != null) {
      final stores = await _storeService.getStoresByUserId(
        authProvider.currentUser!.userId,
      );
      if (stores.isNotEmpty) {
        _selectedStoreId = stores.first['storeId'];
      }
    }

    if (_selectedStoreId != null) {
      final theme = await _themeService.getThemeByStore(_selectedStoreId!);
      if (theme != null) {
        setState(() {
          _primaryColor = theme['primaryColor'];
          _secondaryColor = theme['secondaryColor'];
          _fontFamily = theme['fontFamily'];
          _logoPath = theme['logo'];
          _bannerPath = theme['banner'];
        });
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickLogo() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _logoPath = image.path);
    }
  }

  Future<void> _pickBanner() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _bannerPath = image.path);
    }
  }

  Future<void> _saveTheme() async {
    if (_selectedStoreId == null) return;

    await _themeService.saveTheme(
      storeId: _selectedStoreId!,
      primaryColor: _primaryColor,
      secondaryColor: _secondaryColor,
      fontFamily: _fontFamily,
      logo: _logoPath,
      banner: _bannerPath,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thème enregistré avec succès'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Prévisualiser',
            textColor: Colors.white,
            onPressed: () {
              if (_selectedStoreId != null) {
                Navigator.pushNamed(
                  context,
                  '/vendor-home',
                  arguments: {'storeId': _selectedStoreId!},
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnalisation'),
        backgroundColor: AppColors.primaryDark,
        actions: [
          if (_selectedStoreId != null)
            IconButton(
              icon: const Icon(Icons.preview),
              tooltip: 'Prévisualiser',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/store-preview',
                  arguments: {'storeId': _selectedStoreId!},
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personnalisez votre magasin',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  // Logo
                  const Text(
                    'Logo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickLogo,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _logoPath != null && _logoPath!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _logoPath!.startsWith('http')
                                  ? Image.network(_logoPath!, fit: BoxFit.cover)
                                  : Image.file(File(_logoPath!), fit: BoxFit.cover),
                            )
                          : const Icon(Icons.image, size: 50),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Banner
                  const Text(
                    'Bannière',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickBanner,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _bannerPath != null && _bannerPath!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _bannerPath!.startsWith('http')
                                  ? Image.network(_bannerPath!, fit: BoxFit.cover)
                                  : Image.file(File(_bannerPath!), fit: BoxFit.cover),
                            )
                          : const Icon(Icons.image, size: 50),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Primary Color
                  const Text(
                    'Couleur principale',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Code couleur (ex: #3B82F6)',
                      border: const OutlineInputBorder(),
                      prefixIcon: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryColor != null
                              ? Color(int.parse(_primaryColor!.replaceFirst('#', '0xFF')))
                              : Colors.blue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    onChanged: (value) => setState(() => _primaryColor = value),
                  ),
                  const SizedBox(height: 20),
                  // Secondary Color
                  const Text(
                    'Couleur secondaire',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Code couleur (ex: #2563EB)',
                      border: const OutlineInputBorder(),
                      prefixIcon: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _secondaryColor != null
                              ? Color(int.parse(_secondaryColor!.replaceFirst('#', '0xFF')))
                              : Colors.blue[700],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    onChanged: (value) => setState(() => _secondaryColor = value),
                  ),
                  const SizedBox(height: 20),
                  // Font Family
                  const Text(
                    'Police de caractères',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _fontFamily,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _fonts.map((font) {
                      return DropdownMenuItem(
                        value: font,
                        child: Text(font),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _fontFamily = value),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveTheme,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Enregistrer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

