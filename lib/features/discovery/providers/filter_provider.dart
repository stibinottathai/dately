import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FilterState {
  final RangeValues ageRange;
  final List<String> motherTongues;
  final String gender;
  final bool verifiedOnly;
  final String searchQuery;

  const FilterState({
    this.ageRange = const RangeValues(18, 50),
    this.motherTongues = const [],
    this.gender = 'Everyone',
    this.verifiedOnly = false,
    this.searchQuery = '',
  });

  FilterState copyWith({
    RangeValues? ageRange,
    List<String>? motherTongues,
    String? gender,
    bool? verifiedOnly,
    String? searchQuery,
  }) {
    return FilterState(
      ageRange: ageRange ?? this.ageRange,
      motherTongues: motherTongues ?? this.motherTongues,
      gender: gender ?? this.gender,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      searchQuery: searchQuery ?? this.searchQuery,
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
          .maybeSingle();

      if (response == null) return;

      final prefs = response['discovery_preferences'];
      if (prefs != null) {
        state = FilterState(
          ageRange: RangeValues(
            (prefs['ageRange']['start'] as num).toDouble(),
            (prefs['ageRange']['end'] as num).toDouble(),
          ),
          motherTongues: List<String>.from(prefs['motherTongues'] ?? []),
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
      'motherTongues': state.motherTongues,
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

  void setMotherTongues(List<String> tongues) {
    state = state.copyWith(motherTongues: tongues);
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

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    // Don't save search query to preferences
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
