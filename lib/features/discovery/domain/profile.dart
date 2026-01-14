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
  ];
}
