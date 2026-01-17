import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider to manage search history
final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
      return SearchHistoryNotifier();
    });

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) {
    _loadHistory();
  }

  static const _historyKey = 'search_history';

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    final CleanedQuery = query.trim();
    // Remove if exists to move to top
    final currentList = List<String>.from(state)..remove(CleanedQuery);

    // Add to front
    currentList.insert(0, CleanedQuery);

    // Limit to 10
    if (currentList.length > 10) {
      currentList.removeLast();
    }

    state = currentList;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, currentList);
  }

  Future<void> clearHistory() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> removeSearch(String query) async {
    final currentList = List<String>.from(state)..remove(query);
    state = currentList;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, currentList);
  }
}
