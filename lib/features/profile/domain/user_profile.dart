import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final int age;
  final String bio;
  final List<String> photos;
  final String? mbtiType;
  final bool isVerified;
  final bool isOnline;

  // Personality prompts
  final String? spontaneousPrompt;
  final String? idealSundayPrompt;

  // About me details
  final String? occupation;
  final String? height;
  final String? education;
  final String? religion;
  final String? petPreference;
  final String? drinkingHabit;

  // Spotify
  final List<String>? topArtistImages;
  final String? musicTaste;
  final String? artistsList;
  final bool isVisible;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.photos,
    this.mbtiType,
    this.isVerified = false,
    this.isOnline = false,
    this.spontaneousPrompt,
    this.idealSundayPrompt,
    this.occupation,
    this.height,
    this.education,
    this.religion,
    this.petPreference,
    this.drinkingHabit,
    this.topArtistImages,
    this.musicTaste,
    this.artistsList,
    this.isVisible = true,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Calculate age from date_of_birth
    int age = 18;
    if (map['date_of_birth'] != null) {
      final dob = DateTime.parse(map['date_of_birth']);
      final now = DateTime.now();
      age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
    }

    // Parse photos safely
    List<String> photos = [];
    if (map['photos'] != null) {
      photos = List<String>.from(map['photos']);
    }

    // Parse prompts
    String? prompt1;
    String? prompt2;
    if (map['prompts'] != null) {
      final prompts = map['prompts'] as Map<String, dynamic>;
      prompt1 = prompts['prompt_1'] as String?;
      prompt2 = prompts['prompt_2'] as String?;
    }

    return UserProfile(
      id: map['id'] ?? '',
      name: map['first_name'] ?? 'User',
      age: age,
      bio: map['bio'] ?? '',
      photos: photos,
      // Map other fields that might be present or default them
      spontaneousPrompt: prompt1,
      idealSundayPrompt: prompt2,
      mbtiType: map['mbti_type'] as String?,
      occupation: map['occupation'] as String?,
      height: map['height'] as String?,
      education: map['education'] as String?,
      religion: map['religion'] as String?,
      petPreference: map['pet_preference'] as String?,
      drinkingHabit: map['drinking_habit'] as String?,
      isVisible: map['is_visible'] ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    age,
    bio,
    photos,
    mbtiType,
    isVerified,
    isOnline,
    spontaneousPrompt,
    idealSundayPrompt,
    occupation,
    height,
    education,
    religion,
    petPreference,
    drinkingHabit,
    topArtistImages,
    musicTaste,
    artistsList,
    isVisible,
  ];
}
