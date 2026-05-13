/// Placeholder used when Apple Sign-In does not return a display name
/// (see `LoginNotifier._composeAppleFullName`).
const String kGenericApplePlaceholderDisplayName = 'Apple User';

bool isGenericApplePlaceholderName(String? value) {
  if (value == null) return false;
  return value.trim().toLowerCase() == 'apple user';
}

/// Prefer the signed-in session name when the server only has the generic
/// "Apple User" label — e.g. email/password account after receipt verify
/// overwrote [fullName] on the backend.
String mergeAccountFullNameForDisplay({
  required String? apiFullName,
  required String sessionUserName,
  String fallbackDraftFullName = '',
}) {
  final api = apiFullName?.trim() ?? '';
  final session = sessionUserName.trim();
  final draft = fallbackDraftFullName.trim();

  if (api.isNotEmpty &&
      isGenericApplePlaceholderName(api) &&
      session.isNotEmpty &&
      !isGenericApplePlaceholderName(session)) {
    return session;
  }
  if (api.isNotEmpty) return api;
  if (session.isNotEmpty) return session;
  if (draft.isNotEmpty) return draft;
  return '';
}
