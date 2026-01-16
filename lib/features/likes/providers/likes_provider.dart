import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/likes/domain/like.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// State to hold both sent and received likes
class LikesState {
  final List<Like> receivedLikes;
  final List<Like> sentLikes;
  final bool isLoading;

  LikesState({
    this.receivedLikes = const [],
    this.sentLikes = const [],
    this.isLoading = false,
  });

  LikesState copyWith({
    List<Like>? receivedLikes,
    List<Like>? sentLikes,
    bool? isLoading,
  }) {
    return LikesState(
      receivedLikes: receivedLikes ?? this.receivedLikes,
      sentLikes: sentLikes ?? this.sentLikes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LikesNotifier extends StateNotifier<LikesState> {
  LikesNotifier() : super(LikesState()) {
    _fetchLikes();
    _subscribeToRealtime();
  }

  Future<void> _fetchLikes() async {
    state = state.copyWith(isLoading: true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      // Fetch Sent Likes first to filter efficiently
      // Fetch Matches to exclude/mark as matched
      final matchesResponse = await Supabase.instance.client
          .from('matches')
          .select('user1_id, user2_id')
          .or('user1_id.eq.$userId,user2_id.eq.$userId');

      final matchedUserIds = (matchesResponse as List).map((m) {
        return m['user1_id'] == userId ? m['user2_id'] : m['user1_id'];
      }).toSet();

      // Fetch Sent Likes
      final sentResponse = await Supabase.instance.client
          .from('likes')
          .select('*, profiles!to_user_id(*)')
          .eq('from_user_id', userId);

      final sentLikes = (sentResponse as List).map((data) {
        final profileData = data['profiles'];
        final profile = Profile.fromMap(profileData);
        return Like(
          id: data['id'],
          profile: profile,
          type: LikeType.regular,
          direction: LikeDirection.sent,
          timestamp: DateTime.parse(data['created_at']),
          isMatched: matchedUserIds.contains(profile.id),
        );
      }).toList();

      final sentUserIds = sentLikes.map((l) => l.profile.id).toSet();
      final excludedIds = {...sentUserIds, ...matchedUserIds};

      // Fetch Received Likes
      final receivedResponse = await Supabase.instance.client
          .from('likes')
          .select('*, profiles!from_user_id(*)')
          .eq('to_user_id', userId);

      final receivedLikes = (receivedResponse as List)
          .map((data) {
            final profileData = data['profiles'];
            final profile = Profile.fromMap(profileData);
            return Like(
              id: data['id'],
              profile: profile,
              type: LikeType.regular,
              direction: LikeDirection.received,
              timestamp: DateTime.parse(data['created_at']),
            );
          })
          .where((like) => !excludedIds.contains(like.profile.id))
          .toList();

      state = state.copyWith(
        receivedLikes: receivedLikes,
        sentLikes: sentLikes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error cleanly or log
      print('Error fetching likes: $e');
    }
  }

  Future<void> refreshLikes() => _fetchLikes();

  Future<String?> likeUser(String targetUserId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      try {
        await Supabase.instance.client.from('likes').insert({
          'from_user_id': userId,
          'to_user_id': targetUserId,
        });
      } catch (e) {
        // Ignore duplicate key error, proceed to check match
        // But if other error, return null?
        // Best to just log and proceed, assuming we might have liked them.
        print('Like insert error (possibly duplicate): $e');
      }

      // Check for mutual like
      final mutualLikeResponse = await Supabase.instance.client
          .from('likes')
          .select('id')
          .eq('from_user_id', targetUserId)
          .eq('to_user_id', userId)
          .maybeSingle();

      String? matchId;
      if (mutualLikeResponse != null) {
        // Check if match already exists
        final existingMatch = await Supabase.instance.client
            .from('matches')
            .select('id')
            .or(
              'and(user1_id.eq.$userId,user2_id.eq.$targetUserId),and(user1_id.eq.$targetUserId,user2_id.eq.$userId)',
            )
            .maybeSingle();

        if (existingMatch != null) {
          matchId = existingMatch['id'];
        } else {
          // Create Match
          final matchResponse = await Supabase.instance.client
              .from('matches')
              .insert({'user1_id': userId, 'user2_id': targetUserId})
              .select('id')
              .single();
          matchId = matchResponse['id'];
        }
      }

      // Refresh list to update "Sent Likes"
      _fetchLikes();
      return matchId;
    } catch (e) {
      // General error
      print('Error liking user/creating match: $e');
      return null;
    }
  }

  Future<void> unlikeUser(String likeId) async {
    try {
      await Supabase.instance.client.from('likes').delete().eq('id', likeId);
      _fetchLikes();
    } catch (e) {
      print('Error unliking user: $e');
    }
  }

  RealtimeChannel? _subscription;

  void _subscribeToRealtime() {
    _subscription = Supabase.instance.client.channel(
      'public:likes_matches_updates',
    );

    _subscription!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'likes',
          callback: (payload) {
            final toUserId = payload.newRecord['to_user_id'];
            final myId = Supabase.instance.client.auth.currentUser?.id;
            if (toUserId == myId) {
              _fetchLikes();
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'matches',
          callback: (payload) {
            final u1 = payload.newRecord['user1_id'];
            final u2 = payload.newRecord['user2_id'];
            final myId = Supabase.instance.client.auth.currentUser?.id;
            if (u1 == myId || u2 == myId) {
              _fetchLikes();
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}

final likesProvider =
    StateNotifierProvider.autoDispose<LikesNotifier, LikesState>((ref) {
      return LikesNotifier();
    });
