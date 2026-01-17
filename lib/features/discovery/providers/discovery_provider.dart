import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/discovery/providers/filter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider for fetching raw profiles from Supabase (Unfiltered)
final rawProfilesProvider = FutureProvider.autoDispose<List<Profile>>((
  ref,
) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];

  // Fetch all profiles except current user
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .neq('id', userId)
      .eq('is_visible', true);

  final data = response as List<dynamic>;

  final profiles = data.map((map) {
    // Calculate Age
    final dobStr = map['date_of_birth'] as String?;
    int age = 24; // Default
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
      location: 'Nearby', // Default location
      distanceMiles: 5, // Default distance
      imageUrls: List<String>.from(map['photos'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      isVerified: false,
      occupation: map['occupation'],
      education: map['education'],
      petPreference: map['pet_preference'],
      drinkingHabit: map['drinking_habit'],
      religion: map['religion'],
      height: map['height'],
      gender: map['gender'] ?? 'Other',
    );
  }).toList();

  profiles.shuffle();
  return profiles;
});

// Provider that applies filters to the raw profiles
final discoveryProvider = FutureProvider.autoDispose<List<Profile>>((
  ref,
) async {
  final filters = ref.watch(filterProvider);
  final rawProfiles = await ref.watch(rawProfilesProvider.future);

  return rawProfiles.where((profile) {
    // 0. Search Filter (Initial overrides others)
    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      final matchesName = profile.name.toLowerCase().contains(query);
      return matchesName;
    }

    // 1. Age Filter
    if (profile.age < filters.ageRange.start ||
        profile.age > filters.ageRange.end) {
      return false;
    }

    // 2. Gender Filter
    if (filters.gender != 'Everyone') {
      final targetGender = filters.gender == 'Men' ? 'Man' : 'Woman';
      if (profile.gender != targetGender) {
        return false;
      }
    }

    if (filters.verifiedOnly && !profile.isVerified) {
      return false;
    }

    return true;
  }).toList();
});
