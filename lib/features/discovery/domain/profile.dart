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
  final String? motherTongue;
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
    this.motherTongue,
    this.gender = 'Everyone',
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    // Calculate Age from DOB
    final dobStr = map['date_of_birth'] as String?;
    int age = 24; // Default if null
    if (dobStr != null) {
      final dob = DateTime.parse(dobStr);
      final now = DateTime.now();
      age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
    }

    return Profile(
      id: map['id'],
      name: map['first_name'] ?? 'User',
      age: age,
      bio: map['bio'] ?? '',
      location: 'Nearby', // Future: Calculate real distance
      distanceMiles: 5,
      imageUrls: List<String>.from(map['photos'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      isVerified: false, // Future: Add verified status to DB
      occupation: map['occupation'],
      education: map['education'],
      petPreference: map['pet_preference'],
      drinkingHabit: map['drinking_habit'],
      religion: map['religion'],
      height: map['height'],
      motherTongue: map['mother_tongue'],
      gender: map['gender'] ?? 'Other',
    );
  }

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
    motherTongue,
    gender,
  ];
}
