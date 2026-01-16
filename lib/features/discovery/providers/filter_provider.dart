import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FilterState {
  final RangeValues ageRange;
  final double distance;
  final String gender;
  final bool verifiedOnly;

  const FilterState({
    this.ageRange = const RangeValues(18, 50),
    this.distance = 50,
    this.gender = 'Everyone',
    this.verifiedOnly = false,
  });

  FilterState copyWith({
    RangeValues? ageRange,
    double? distance,
    String? gender,
    bool? verifiedOnly,
  }) {
    return FilterState(
      ageRange: ageRange ?? this.ageRange,
      distance: distance ?? this.distance,
      gender: gender ?? this.gender,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('discovery_preferences')
          .eq('id', userId)
          .single();

      final prefs = response['discovery_preferences'];
      if (prefs != null) {
        state = FilterState(
          ageRange: RangeValues(
            (prefs['ageRange']['start'] as num).toDouble(),
            (prefs['ageRange']['end'] as num).toDouble(),
          ),
          distance: (prefs['distance'] as num).toDouble(),
          gender: prefs['gender'] as String,
          verifiedOnly: prefs['verifiedOnly'] as bool,
        );
      }
    } catch (e) {
      // Fallback to default or log error
      print('Error loading preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final prefs = {
      'ageRange': {'start': state.ageRange.start, 'end': state.ageRange.end},
      'distance': state.distance,
      'gender': state.gender,
      'verifiedOnly': state.verifiedOnly,
    };

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'discovery_preferences': prefs})
          .eq('id', userId);
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  void setAgeRange(RangeValues range) {
    state = state.copyWith(ageRange: range);
    _savePreferences();
  }

  void setDistance(double distance) {
    state = state.copyWith(distance: distance);
    _savePreferences();
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
    _savePreferences();
  }

  void setVerifiedOnly(bool verified) {
    state = state.copyWith(verifiedOnly: verified);
    _savePreferences();
  }

  void reset() {
    state = const FilterState();
    _savePreferences();
  }
}

final filterProvider =
    StateNotifierProvider.autoDispose<FilterNotifier, FilterState>((ref) {
      return FilterNotifier();
    });
