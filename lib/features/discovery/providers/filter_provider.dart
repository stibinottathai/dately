import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  FilterNotifier() : super(const FilterState());

  void setAgeRange(RangeValues range) =>
      state = state.copyWith(ageRange: range);
  void setDistance(double distance) =>
      state = state.copyWith(distance: distance);
  void setGender(String gender) => state = state.copyWith(gender: gender);
  void setVerifiedOnly(bool verified) =>
      state = state.copyWith(verifiedOnly: verified);

  void reset() => state = const FilterState();
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((
  ref,
) {
  return FilterNotifier();
});
