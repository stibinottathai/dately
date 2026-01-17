import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'sign_up_state.freezed.dart';
part 'sign_up_state.g.dart';

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState({
    @Default('') String firstName,
    @Default('') String email,
    @Default('') String password,
    @Default('') String motherTongue,
    @Default('') String gender,
    @Default('') String sexualOrientation,
    DateTime? dateOfBirth,
    @Default('') String bio,
    @Default([]) List<String> interests,
    @Default([]) List<String> photos, // Paths or URLs
    @Default('All') String genderPreference,
    @Default(18) int ageRangeStart,
    @Default(32) int ageRangeEnd,
    @Default('') String prompt1,
    @Default('') String prompt2,
    @Default('') String prompt3,
  }) = _SignUpState;
}

@riverpod
class SignUpNotifier extends _$SignUpNotifier {
  @override
  SignUpState build() {
    return const SignUpState();
  }

  void updateFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }

  void updateMotherTongue(String value) {
    state = state.copyWith(motherTongue: value);
  }

  void updateGender(String value) {
    state = state.copyWith(gender: value);
  }

  void updateSexualOrientation(String value) {
    state = state.copyWith(sexualOrientation: value);
  }

  void updateDateOfBirth(DateTime value) {
    state = state.copyWith(dateOfBirth: value);
  }

  void updateBio(String value) {
    state = state.copyWith(bio: value);
  }

  void toggleInterest(String interest) {
    final currentInterests = List<String>.from(state.interests);
    if (currentInterests.contains(interest)) {
      currentInterests.remove(interest);
    } else {
      currentInterests.add(interest);
    }
    state = state.copyWith(interests: currentInterests);
  }

  void addPhoto(String path) {
    print('DEBUG: Adding photo path: $path');
    final currentPhotos = List<String>.from(state.photos);
    if (currentPhotos.length < 6) {
      currentPhotos.add(path);
      state = state.copyWith(photos: currentPhotos);
      print('DEBUG: Updated photos list: $currentPhotos');
    }
  }

  void removePhoto(int index) {
    final currentPhotos = List<String>.from(state.photos);
    if (index >= 0 && index < currentPhotos.length) {
      currentPhotos.removeAt(index);
      state = state.copyWith(photos: currentPhotos);
    }
  }

  void updateGenderPreference(String value) {
    state = state.copyWith(genderPreference: value);
  }

  void updateAgeRange(int start, int end) {
    state = state.copyWith(ageRangeStart: start, ageRangeEnd: end);
  }

  void updatePrompt1(String value) {
    state = state.copyWith(prompt1: value);
  }

  void updatePrompt2(String value) {
    state = state.copyWith(prompt2: value);
  }

  void updatePrompt3(String value) {
    state = state.copyWith(prompt3: value);
  }

  // Placeholder for submission
  Future<void> submit() async {
    try {
      final supabase = Supabase.instance.client;

      final authResponse = await supabase.auth.signUp(
        email: state.email,
        password: state.password,
      );

      final userId = authResponse.user?.id;
      if (userId == null) {
        throw Exception('Sign up failed: User ID is null');
      }

      if (authResponse.session == null) {
        // Email confirmation is required.
        // We cannot insert into 'profiles' yet because RLS requires an authenticated user.
        print('Sign up successful, but email confirmation required.');
        // You might want to show a dialog here or navigate to a "Check Email" screen.
        // For development, recommend disabling "Confirm Email" in Supabase to skip this.
        throw Exception(
          'Please confirm your email address before continuing. (Hint: Disable "Confirm Email" in Supabase for dev)',
        );
      }

      // 2. Create Profile
      await supabase.from('profiles').insert({
        'id': userId,
        'first_name': state.firstName,
        'email': state.email,
        'mother_tongue': state.motherTongue,
        'gender': state.gender,
        'sexual_orientation': state.sexualOrientation,
        'date_of_birth': state.dateOfBirth?.toIso8601String(),
        'bio': state.bio,
        'interests': state.interests,
        'photos': state.photos,
        'gender_preference': state.genderPreference,
        'age_range_start': state.ageRangeStart,
        'age_range_end': state.ageRangeEnd,
        'prompts': {
          'prompt_1': state.prompt1,
          'prompt_2': state.prompt2,
          'prompt_3': state.prompt3,
        },
        'created_at': DateTime.now().toIso8601String(),
      });

      print('Sign Up Successful: $userId');
    } catch (e) {
      print('Sign Up Error: $e');
      // Rethrow to allow UI to handle or show snackbar
      rethrow;
    }
  }
}
