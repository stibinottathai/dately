import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/profile/data/current_user.dart';
import 'package:dately/features/profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  late TextEditingController _mbtiController;
  late TextEditingController _spontaneousController;
  late TextEditingController _sundayController;
  late TextEditingController _occupationController;
  late TextEditingController _heightController;
  late TextEditingController _educationController;
  late TextEditingController _religionController;
  late TextEditingController _petController;
  late TextEditingController _drinkingController;

  List<String> _photos = [];
  bool _isVerified = false;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    final profile = currentUserProfile;

    _nameController = TextEditingController(text: profile.name);
    _ageController = TextEditingController(text: profile.age.toString());
    _bioController = TextEditingController(text: profile.bio);
    _mbtiController = TextEditingController(text: profile.mbtiType ?? '');
    _spontaneousController = TextEditingController(
      text: profile.spontaneousPrompt ?? '',
    );
    _sundayController = TextEditingController(
      text: profile.idealSundayPrompt ?? '',
    );
    _occupationController = TextEditingController(
      text: profile.occupation ?? '',
    );
    _heightController = TextEditingController(text: profile.height ?? '');
    _educationController = TextEditingController(text: profile.education ?? '');
    _religionController = TextEditingController(text: profile.religion ?? '');
    _petController = TextEditingController(text: profile.petPreference ?? '');
    _drinkingController = TextEditingController(
      text: profile.drinkingHabit ?? '',
    );

    _photos = List.from(profile.photos);
    _isVerified = profile.isVerified;
    _isOnline = profile.isOnline;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _mbtiController.dispose();
    _spontaneousController.dispose();
    _sundayController.dispose();
    _occupationController.dispose();
    _heightController.dispose();
    _educationController.dispose();
    _religionController.dispose();
    _petController.dispose();
    _drinkingController.dispose();
    super.dispose();
  }

  void _addPhoto() {
    // In a real app, this would open image picker
    setState(() {
      _photos.add(
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=1200&fit=crop',
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Photo added! In production, this would open image picker.',
        ),
      ),
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _saveProfile() {
    // In production, this would save to database/API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved successfully! ✓'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Top App Bar
          _buildTopAppBar(),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotosSection(),
                  const SizedBox(height: 24),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildPromptsSection(),
                  const SizedBox(height: 24),
                  _buildAboutMeSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSaveButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Edit Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Add at least 2 photos',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: _photos.length + 1,
          itemBuilder: (context, index) {
            if (index == _photos.length) {
              return _buildAddPhotoButton();
            }
            return _buildPhotoItem(_photos[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(String photoUrl, int index) {
    return Stack(
      children: [
        Container(
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
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Main',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTextField('Name', _nameController),
        const SizedBox(height: 12),
        _buildTextField(
          'Age',
          _ageController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField('MBTI Type', _mbtiController, hint: 'e.g., ENFP'),
        const SizedBox(height: 12),
        _buildTextField(
          'Bio',
          _bioController,
          maxLines: 4,
          hint: 'Tell us about yourself...',
        ),
      ],
    );
  }

  Widget _buildPromptsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personality Prompts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'The most spontaneous thing I\'ve done',
          _spontaneousController,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        _buildTextField('My ideal Sunday', _sundayController, maxLines: 3),
      ],
    );
  }

  Widget _buildAboutMeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Me',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTextField('Occupation', _occupationController),
        const SizedBox(height: 12),
        _buildTextField('Height', _heightController, hint: 'e.g., 6\'1"'),
        const SizedBox(height: 12),
        _buildTextField('Education', _educationController),
        const SizedBox(height: 12),
        _buildTextField('Religion', _religionController),
        const SizedBox(height: 12),
        _buildTextField(
          'Pet Preference',
          _petController,
          hint: 'e.g., Dog Lover',
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Drinking Habit',
          _drinkingController,
          hint: 'e.g., Social Drinker',
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 8,
            shadowColor: AppColors.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check),
              SizedBox(width: 8),
              Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
