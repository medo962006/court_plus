import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:court_plus/services/models.dart';
import 'package:court_plus/services/supabase_service.dart';
import 'supabase_provider.dart';

// ─── Providers ───

final invitationsProvider = FutureProvider<List<Invitation>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getInvitations();
  return result.fold(
    (invitations) => invitations,
    (e) => throw e,
  );
});

// ─── Notifier for actions ───

final invitationsNotifierProvider =
    StateNotifierProvider<InvitationsNotifier, AsyncValue<List<Invitation>>>(
  (ref) => InvitationsNotifier(ref.read(supabaseServiceProvider)),
);

class InvitationsNotifier extends StateNotifier<AsyncValue<List<Invitation>>> {
  final SupabaseService _supabase;

  InvitationsNotifier(this._supabase) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    final result = await _supabase.getInvitations();
    state = result.fold(
      (invitations) => AsyncValue.data(invitations),
      (e) => AsyncValue.error(e, StackTrace.current),
    );
  }

  Future<String?> respondToInvitation(String id, String status) async {
    final result = await _supabase.respondToInvitation(id, status);
    return result.fold(
      (_) {
        _load();
        return null;
      },
      (e) => e.message,
    );
  }

  Future<String?> sendInvitation(Map<String, dynamic> data) async {
    final result = await _supabase.sendInvitation(data);
    return result.fold(
      (_) => null,
      (e) => e.message,
    );
  }

  void refresh() => _load();
}