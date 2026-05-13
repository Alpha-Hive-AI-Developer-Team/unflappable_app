import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/features/Auth/models/user.dart';
import 'package:unflappable/features/Auth/providers/user_state.dart';
import 'package:unflappable/service/settings_service.dart';
import 'package:unflappable/service/subscription_service.dart';

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  /// Called after successful login
  /// Typically receives user data from API response
  void setUserInfo({
    required String id,
    required String email,
    required String name,
    required bool isPro,
    String? proProductId,
  }) {
    final user = User(
      id: id,
      email: email,
      name: name,
      isPro: isPro,
      createdAt: DateTime.now(),
      proProductId: proProductId,
    );

    state = state.copyWith(status: UserStatus.authenticated, user: user);
  }

  /// Refreshes `isPro` from `GET /api/subscription/status` (no loading state).
  Future<void> syncSubscriptionFromApi() async {
    if (state.user == null) return;

    try {
      final subStatus = await SubscriptionService.fetchStatus();
      final updatedUser = state.user!.copyWith(
        isPro: subStatus.isPro,
        proSubscribedAt: subStatus.isPro
            ? (state.user!.proSubscribedAt ?? DateTime.now())
            : null,
        proProductId: subStatus.isPro
            ? (subStatus.proProductId ?? state.user!.proProductId)
            : null,
        clearProProductId: !subStatus.isPro,
      );
      state = state.copyWith(
        status: UserStatus.authenticated,
        user: updatedUser,
        errorMessage: null,
      );
    } catch (_) {
      // Non-blocking: login and home stay usable if status fails.
    }
  }

  /// Syncs `isPro` from APIs that return it on reset/history payloads so the
  /// shell matches the server even before the next subscription/status poll.
  void syncIsProFromAuxiliaryApi(bool isPro) {
    if (state.user == null) return;
    state = state.copyWith(
      status: UserStatus.authenticated,
      user: state.user!.copyWith(
        isPro: isPro,
        proSubscribedAt: isPro
            ? (state.user!.proSubscribedAt ?? DateTime.now())
            : null,
        clearProProductId: !isPro,
      ),
      errorMessage: null,
    );
  }

  /// Called on logout
  void clearUser() {
    state = state.copyWith(status: UserStatus.unauthenticated, clearUser: true);
  }

  /// After cold start, [LocalStorage.accessToken] may exist while Riverpod
  /// still has no user — splash only checks storage. Restores profile + Pro
  /// so flows like IAP see [UserState.isAuthenticated] as true.
  Future<void> restoreSessionIfNeeded() async {
    if (state.isAuthenticated) return;
    final token = LocalStorage.getData(LocalStorage.accessToken)?.trim();
    if (token == null || token.isEmpty) return;

    try {
      final accountResponse = await SettingsService.getAccount();
      final accountMap = _accountPayload(accountResponse.data);
      final email = _firstNonEmptyString(accountMap, const [
        'email',
        'userEmail',
      ]);
      final name =
          _firstNonEmptyString(accountMap, const ['fullName', 'name']) ??
          (email != null ? _deriveNameFromEmail(email) : null);
      final id = _firstUserId(accountMap) ?? email;

      if (id == null || id.isEmpty) return;

      final subStatus = await SubscriptionService.fetchStatus();

      setUserInfo(
        id: id,
        email: email ?? id,
        name: name ?? _deriveNameFromEmail(email ?? id),
        isPro: subStatus.isPro,
        proProductId: subStatus.proProductId,
      );
    } on DioException catch (_) {
      // Token may be expired; leave state unchanged — splash still uses storage.
    } catch (_) {}
  }

  /// Update any user field (called when user updates profile)
  void updateUserInfo({String? name, String? email}) {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(name: name, email: email);

    state = state.copyWith(user: updatedUser);
  }
}

Map<String, dynamic> _accountPayload(dynamic data) {
  if (data is Map<String, dynamic>) {
    final inner = data['data'];
    if (inner is Map<String, dynamic>) return inner;
    return data;
  }
  return <String, dynamic>{};
}

String? _firstNonEmptyString(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

String? _firstUserId(Map<String, dynamic> source) {
  for (final key in const ['_id', 'id', 'userId']) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is num) return value.toString();
  }
  return null;
}

String _deriveNameFromEmail(String email) {
  final localPart = email.split('@').first;
  if (localPart.isEmpty) return 'User';
  final segments = localPart.split(RegExp(r'[._\- ]+'));
  return segments
      .map(
        (part) =>
            part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .where((part) => part.isNotEmpty)
      .join(' ');
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>(
  (_) => UserNotifier(),
);
