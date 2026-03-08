import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  String? _currentImageUrl;
  String? _newBase64Image;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    String firstName = '';
    String lastName = '';
    if (user?['name'] != null) {
      final parts = user!['name'].toString().split(' ');
      firstName = parts.first;
      if (parts.length > 1) {
        lastName = parts.sublist(1).join(' ');
      }
    }

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: user?['email'] ?? '');
    _addressController = TextEditingController(text: user?['address'] ?? '');
    _currentImageUrl = user?['profileImage'];
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 20,
        maxWidth: 400,
        maxHeight: 400,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _newBase64Image = "data:image/jpeg;base64,$base64String";
        });
      }
    } catch (e) {
      print('Şəkil seçərkən xəta: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    }
  }

  void _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
    
    final success = await authProvider.updateProfile(
      fullName,
      _emailController.text.trim(),
      _addressController.text.trim(),
      profileImage: _newBase64Image ?? _currentImageUrl,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil uğurla yeniləndi'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeniləmə zamanı xəta baş verdi'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Redaktə Et'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _newBase64Image != null
                        ? Image.memory(base64Decode(_newBase64Image!.split(',').last), fit: BoxFit.cover)
                        : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                            ? (_currentImageUrl!.startsWith('http')
                                ? Image.network(
                                    _currentImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 60, color: Colors.white),
                                  )
                                : Image.memory(base64Decode(_currentImageUrl!.split(',').last), fit: BoxFit.cover))
                            : const Icon(Icons.person, size: 60, color: Colors.white)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 18,
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Ad',
                    hint: 'Adınız',
                    controller: _firstNameController,
                    prefixIcon: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Soyad',
                    hint: 'Soyadınız',
                    controller: _lastNameController,
                    prefixIcon: Icons.person_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Email',
              hint: 'Emailinizi daxil edin',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Ünvan',
              hint: 'Ünvanınızı daxil edin',
              controller: _addressController,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 40),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return CustomButton(
                  text: 'Yadda Saxla',
                  isLoading: auth.isLoading,
                  onPressed: _saveProfile,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
