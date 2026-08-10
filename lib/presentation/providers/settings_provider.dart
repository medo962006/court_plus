import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── State ───

final class SettingsState {
  final bool notificationsEnabled;
  final String language;
  final List<bool> notificationPrefs;

  const SettingsState({
    this.notificationsEnabled = true,
    this.language = 'en',
    this.notificationPrefs = const [true, true, true, true, true, true],
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    String? language,
    List<bool>? notificationPrefs,
  }) => SettingsState(
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    language: language ?? this.language,
    notificationPrefs: notificationPrefs ?? this.notificationPrefs,
  );
}

// ─── Providers ───

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

final notificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).notificationsEnabled;
});

final languageProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).language;
});

final notificationPrefsProvider = NotifierProvider<NotificationPrefsNotifier, List<bool>>(
  NotificationPrefsNotifier.new,
);

// ─── Notifier ───

final class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      language: prefs.getString('language') ?? 'en',
    );
  }

  Future<void> toggleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.notificationsEnabled;
    await prefs.setBool('notifications_enabled', newValue);
    state = state.copyWith(notificationsEnabled: newValue);
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    state = state.copyWith(language: lang);
  }
}

final class NotificationPrefsNotifier extends Notifier<List<bool>> {
  @override
  List<bool> build() {
    return const [true, true, true, true, true, true];
  }

  Future<void> set(int index, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final next = List<bool>.from(state);
    next[index] = value;
    await prefs.setBool('notification_pref_$index', value);
    state = next;
  }
}