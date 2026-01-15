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
  });

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
  ];
}
