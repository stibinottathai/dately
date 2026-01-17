import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/auth/presentation/sign_up/providers/sign_up_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SignUpStep1Screen extends ConsumerStatefulWidget {
  const SignUpStep1Screen({super.key});

  @override
  ConsumerState<SignUpStep1Screen> createState() => _SignUpStep1ScreenState();
}

class _SignUpStep1ScreenState extends ConsumerState<SignUpStep1Screen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Watch state to prepopulate fields if needed (e.g. on back navigation)
    final state = ref.watch(signUpNotifierProvider);
    final notifier = ref.read(signUpNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 24), // Balance spacing
                  ],
                ),
                const SizedBox(height: 24),

                // Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Basic Info',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    // Removed 'Step 1 of 4' text
                  ],
                ),
                // Removed progress bar container
                const SizedBox(height: 32),

                // Headline
                const Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your name and age will be visible on your profile to help others get to know you.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Form Fields
                _buildLabel('Email'),
                const SizedBox(height: 8),
                TextField(
                  onChanged: notifier.updateEmail,
                  keyboardType: TextInputType.emailAddress,
                  controller: TextEditingController(text: state.email)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: state.email.length),
                    ),
                  decoration: _inputDecoration('Enter your email'),
                ),
                const SizedBox(height: 24),

                _buildLabel('Password'),
                const SizedBox(height: 8),
                TextField(
                  onChanged: notifier.updatePassword,
                  obscureText: true,
                  controller: TextEditingController(text: state.password)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: state.password.length),
                    ),
                  decoration: _inputDecoration('Enter your password'),
                ),
                const SizedBox(height: 24),

                _buildLabel('First Name'),
                const SizedBox(height: 8),
                TextField(
                  onChanged: notifier.updateFirstName,
                  controller: TextEditingController(text: state.firstName)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: state.firstName.length),
                    ),
                  decoration: _inputDecoration('What\'s your name?'),
                ),
                const SizedBox(height: 24),

                _buildLabel('Gender'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: ['Woman', 'Man', 'Other'].map((gender) {
                      final isSelected = state.gender == gender;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => notifier.updateGender(gender),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              gender,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel('Sexual Orientation'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    _showSexualOrientationPicker(context, notifier);
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                        text: state.sexualOrientation.isEmpty
                            ? ''
                            : state.sexualOrientation,
                      ),
                      decoration: _inputDecoration(
                        'Select',
                      ).copyWith(suffixIcon: const Icon(Icons.expand_more)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel('Date of Birth'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now().subtract(
                        const Duration(days: 365 * 18),
                      ),
                    );
                    if (picked != null) {
                      notifier.updateDateOfBirth(picked);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                        text: state.dateOfBirth != null
                            ? DateFormat(
                                'yyyy-MM-dd',
                              ).format(state.dateOfBirth!)
                            : '',
                      ),
                      decoration: _inputDecoration('YYYY-MM-DD').copyWith(
                        suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      ),
                    ),
                  ),
                ),
                if (state.dateOfBirth != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8),
                    child: Text(
                      'You must be 18+ to join Dately.',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 48),

                // Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _submit(context, notifier, state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSexualOrientationPicker(
    BuildContext context,
    SignUpNotifier notifier,
  ) {
    final orientations = [
      'Straight',
      'Gay',
      'Lesbian',
      'Bisexual',
      'Pansexual',
      'Asexual',
      'Queer',
      'Questioning',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sexual Orientation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: orientations.length,
                itemBuilder: (context, index) {
                  final orientation = orientations[index];
                  return ListTile(
                    title: Text(
                      orientation,
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      notifier.updateSexualOrientation(orientation);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> _submit(
    BuildContext context,
    SignUpNotifier notifier,
    SignUpState state,
  ) async {
    if (state.email.isEmpty ||
        state.password.isEmpty ||
        state.firstName.isEmpty ||
        state.gender.isEmpty ||
        state.sexualOrientation.isEmpty ||
        state.dateOfBirth == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await notifier.submit();
      if (context.mounted) {
        context.go('/counter');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
            ), // Basic cleaning
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
