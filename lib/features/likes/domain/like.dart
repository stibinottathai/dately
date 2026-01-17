import 'package:dately/features/discovery/domain/profile.dart';
import 'package:equatable/equatable.dart';

enum LikeType { regular, superLike }

enum LikeDirection {
  received, // Someone liked me
  sent, // I liked someone
}

class Like extends Equatable {
  final String id;
  final Profile profile;
  final LikeType type;
  final LikeDirection direction;
  final DateTime timestamp;
  final bool isMatched;
  final String? matchId;

  const Like({
    required this.id,
    required this.profile,
    required this.type,
    required this.direction,
    required this.timestamp,
    this.isMatched = false,
    this.matchId,
  });

  Like copyWith({
    String? id,
    Profile? profile,
    LikeType? type,
    LikeDirection? direction,
    DateTime? timestamp,
    bool? isMatched,
    String? matchId,
  }) {
    return Like(
      id: id ?? this.id,
      profile: profile ?? this.profile,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      timestamp: timestamp ?? this.timestamp,
      isMatched: isMatched ?? this.isMatched,
      matchId: matchId ?? this.matchId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    profile,
    type,
    direction,
    timestamp,
    isMatched,
    matchId,
  ];
}
