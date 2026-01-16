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

  const Like({
    required this.id,
    required this.profile,
    required this.type,
    required this.direction,
    required this.timestamp,
    this.isMatched = false,
  });

  @override
  List<Object?> get props => [
    id,
    profile,
    type,
    direction,
    timestamp,
    isMatched,
  ];
}
