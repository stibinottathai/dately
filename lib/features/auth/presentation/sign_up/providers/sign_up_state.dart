import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_up_state.freezed.dart';
part 'sign_up_state.g.dart';

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState({
    @Default('') String firstName,
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
    // TODO: Implement API call
    print('Submitting Sign Up: $state');
  }
}
