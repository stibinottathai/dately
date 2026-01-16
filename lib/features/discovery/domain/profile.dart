import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String name;
  final int age;
  final String bio;
  final String location;
  final int distanceMiles;
  final List<String> imageUrls;
  final List<String> interests;
  final bool isVerified;

  // New Fields
  final String? occupation;
  final String? education;
  final String? petPreference;
  final String? drinkingHabit;
  final String? religion;
  final String? height;
  final String gender;

  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.location,
    required this.distanceMiles,
    required this.imageUrls,
    required this.interests,
    this.isVerified = false,
    this.occupation,
    this.education,
    this.petPreference,
    this.drinkingHabit,
    this.religion,
    this.height,
    this.gender = 'Everyone',
  });

  @override
  List<Object?> get props => [
    id,
    name,
    age,
    bio,
    location,
    distanceMiles,
    imageUrls,
    interests,
    isVerified,
    occupation,
    education,
    petPreference,
    drinkingHabit,
    religion,
    height,
    gender,
  ];
}
