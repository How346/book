import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'database.dart';

final dbProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final partiesProvider = StateNotifierProvider<PartiesNotifier, AsyncValue<List<Party>>>((ref) {
  return PartiesNotifier(ref.watch(dbProvider));
});

class PartiesNotifier extends StateNotifier<AsyncValue<List<Party>>> {
  final DatabaseHelper db;
  PartiesNotifier(this.db) : super(const AsyncValue.loading()) {
    loadParties();
  }

  Future<void> loadParties() async {
    try {
      final parties = await db.getAllParties();
      state = AsyncValue.data(parties);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addParty(Party party) async {
    await db.insertParty(party);
    await loadParties();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    await db.insertTransaction(tx);
    await loadParties();
  }
}

final transactionsProvider = FutureProvider.family<List<TransactionModel>, String>((ref, partyId) async {
  final db = ref.watch(dbProvider);
  return await db.getTransactionsForParty(partyId);
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, Map<String, dynamic>>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  SettingsNotifier() : super({'isDark': false, 'locale': 'en', 'isLocked': false}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = {
      'isDark': prefs.getBool('isDark') ?? false,
      'locale': prefs.getString('locale') ?? 'en',
      'isLocked': prefs.getBool('isLocked') ?? false,
    };
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newDark = !(state['isDark'] as bool);
    await prefs.setBool('isDark', newDark);
    state = {...state, 'isDark': newDark};
  }
}
