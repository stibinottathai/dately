import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/profile/domain/user_profile.dart';
import 'package:dately/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _occupationController;
  late TextEditingController _heightController;
  late TextEditingController _educationController;
  late TextEditingController _religionController;
  late TextEditingController _petController;
  late TextEditingController _drinkingController;

  final ImagePicker _picker = ImagePicker();

  List<String> _currentPhotos = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentPhotos = List.from(widget.profile.photos);
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.bio);
    _occupationController = TextEditingController(
      text: widget.profile.occupation ?? '',
    );
    _heightController = TextEditingController(
      text: widget.profile.height ?? '',
    );
    _educationController = TextEditingController(
      text: widget.profile.education ?? '',
    );
    _religionController = TextEditingController(
      text: widget.profile.religion ?? '',
    );
    _petController = TextEditingController(
      text: widget.profile.petPreference ?? '',
    );
    _drinkingController = TextEditingController(
      text: widget.profile.drinkingHabit ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _heightController.dispose();
    _educationController.dispose();
    _religionController.dispose();
    _petController.dispose();
    _drinkingController.dispose();
    super.dispose();
  }

  Future<void> _removePhoto(int index) async {
    setState(() {
      if (index < _currentPhotos.length) {
        _currentPhotos.removeAt(index);
      }
    });
  }

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // 1. Upload to Supabase
      try {
        final bytes = await image.readAsBytes();
        final fileExt = image.path.split('.').last;
        final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final filePath = 'user_photos/$userId/$fileName';

        await Supabase.instance.client.storage
            .from('photos')
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(contentType: image.mimeType),
            );

        final imageUrl = Supabase.instance.client.storage
            .from('photos')
            .getPublicUrl(filePath);

        setState(() {
          if (index < _currentPhotos.length) {
            _currentPhotos[index] = imageUrl;
          } else {
            _currentPhotos.add(imageUrl);
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updates = {
        'first_name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'occupation': _occupationController.text.trim(),
        'height': _heightController.text.trim(),
        'education': _educationController.text.trim(),
        'religion': _religionController.text.trim(),
        'pet_preference': _petController.text.trim(),
        'drinking_habit': _drinkingController.text.trim(),
        'photos': _currentPhotos, // Save photo URLs
      };

      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', widget.profile.id);

      ref.invalidate(userProfileProvider); // Refresh profile data
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotosSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('About Me'),
            const SizedBox(height: 16),
            _buildTextField('Name', _nameController),
            const SizedBox(height: 16),
            _buildTextField('Bio', _bioController, maxLines: 4),
            const SizedBox(height: 16),
            _buildTextField('Occupation', _occupationController),
            const SizedBox(height: 16),
            _buildSectionTitle('Details'),
            const SizedBox(height: 16),
            _buildTextField(
              'Height',
              _heightController,
              icon: Icons.straighten,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Education',
              _educationController,
              icon: Icons.school,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Religion',
              _religionController,
              icon: Icons.church,
            ),
            const SizedBox(height: 16),
            _buildTextField('Pet Preference', _petController, icon: Icons.pets),
            const SizedBox(height: 16),
            _buildTextField(
              'Drinking',
              _drinkingController,
              icon: Icons.wine_bar,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        final photoUrl = index < _currentPhotos.length
            ? _currentPhotos[index]
            : null;

        return GestureDetector(
          onTap: () => _pickImage(index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: photoUrl == null
                ? Icon(Icons.add_a_photo, color: Colors.grey.shade400)
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
