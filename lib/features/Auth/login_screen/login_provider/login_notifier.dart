import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:unflappable/core/notifications/notification_manager.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/features/Auth/login_screen/login_provider/login_state.dart';
import 'package:unflappable/service/auth_service.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  static const String _appleServiceId = String.fromEnvironment(
    'APPLE_SERVICE_ID',
  );
  static const String _appleRedirectUri = String.fromEnvironment(
    'APPLE_REDIRECT_URI',
  );

  // ── Field setters with real-time validation ──────────────────────────────

  void setEmail(String v) {
    final error = _validateEmail(v);
    state = state.copyWith(
      email: v,
      emailError: error,
      status: LoginStatus.idle,
    );
  }

  void setPassword(String v) {
    final error = _validatePassword(v);
    state = state.copyWith(
      password: v,
      passwordError: error,
      status: LoginStatus.idle,
    );
  }

  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void clearError() =>
      state = state.copyWith(status: LoginStatus.idle, authErrorMessage: null);

  // ── Per-field validators ─────────────────────────────────────────────────

  String? _validateEmail(String v) {
    if (v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String v) {
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> submit() async {
    final emailError = _validateEmail(state.email);
    final passwordError = _validatePassword(state.password);

    final hasErrors = emailError != null || passwordError != null;

    if (hasErrors) {
      state = state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
        authErrorMessage:
            'Please fix the highlighted fields before continuing.',
        status: LoginStatus.validationError,
      );
      return;
    }

    state = state.copyWith(status: LoginStatus.loading, authErrorMessage: null);

    try {
      final response = await AuthService.login(
        fullName: _deriveNameFromEmail(state.email),
        email: state.email.trim(),
        password: state.password,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = _extractAuthToken(response.data);
        if (token != null) {
          await LocalStorage.saveData(LocalStorage.accessToken, token);
          await NotificationManager.registerDeviceToken();
        }
        final email = _extractUserEmail(response.data) ?? state.email.trim();
        final name =
            _extractUserName(response.data) ?? _deriveNameFromEmail(email);
        final id = _extractUserId(response.data) ?? email;
        state = state.copyWith(
          status: LoginStatus.success,
          authenticatedEmail: email,
          authenticatedName: name,
          authenticatedUserId: id,
        );
      } else {
        final message =
            _extractMessage(response) ??
            "Email or password didn't match. Please try again.";
        state = state.copyWith(
          status: LoginStatus.authError,
          authErrorMessage: message,
        );
      }
    } on DioException catch (e) {
      final message = e.response != null
          ? _extractMessage(e.response!) ??
                "Email or password didn't match. Please try again."
          : 'Unable to connect to the server. Please try again.';
      state = state.copyWith(
        status: LoginStatus.authError,
        authErrorMessage: message,
      );
    } catch (e) {
      state = state.copyWith(
        status: LoginStatus.authError,
        authErrorMessage: "Email or password didn't match. Please try again.",
      );
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: LoginStatus.loading, authErrorMessage: null);

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: _buildAppleWebOptions(),
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        state = state.copyWith(
          status: LoginStatus.authError,
          authErrorMessage:
              'Apple did not return an identity token. Please try again.',
        );
        return;
      }

      final fullName = _composeAppleFullName(credential);
      final response = await AuthService.signInWithApple(
        identityToken: identityToken,
        fullName: fullName,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = _extractAuthToken(response.data);
        if (token != null) {
          await LocalStorage.saveData(LocalStorage.accessToken, token);
          await NotificationManager.registerDeviceToken();
        }

        final email =
            _extractUserEmail(response.data) ?? credential.email ?? '';
        final name = _extractUserName(response.data) ?? fullName;
        final id = _extractUserId(response.data) ?? credential.userIdentifier ?? email;

        state = state.copyWith(
          status: LoginStatus.success,
          authenticatedEmail: email,
          authenticatedName: name,
          authenticatedUserId: id,
        );
      } else {
        final message =
            _extractMessage(response) ??
            'Unable to sign in with Apple. Please try again.';
        state = state.copyWith(
          status: LoginStatus.authError,
          authErrorMessage: message,
        );
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        state = state.copyWith(status: LoginStatus.idle);
        return;
      }
      state = state.copyWith(
        status: LoginStatus.authError,
        authErrorMessage: 'Apple sign-in failed. Please try again.',
      );
    } on DioException catch (e) {
      final message = e.response != null
          ? _extractMessage(e.response!) ??
                'Unable to sign in with Apple. Please try again.'
          : 'Unable to connect to the server. Please try again.';
      state = state.copyWith(
        status: LoginStatus.authError,
        authErrorMessage: message,
      );
    } catch (e) {
      state = state.copyWith(
        status: LoginStatus.authError,
        authErrorMessage: _appleConfigurationMessage(e),
      );
    }
  }

  WebAuthenticationOptions? _buildAppleWebOptions() {
    if (_appleServiceId.isEmpty || _appleRedirectUri.isEmpty) {
      return null;
    }

    return WebAuthenticationOptions(
      clientId: _appleServiceId,
      redirectUri: Uri.parse(_appleRedirectUri),
    );
  }

  String _composeAppleFullName(AuthorizationCredentialAppleID credential) {
    final name = [
      credential.givenName,
      credential.familyName,
    ].whereType<String>().map((part) => part.trim()).where((part) => part.isNotEmpty).join(' ');

    return name.isEmpty ? 'Apple User' : name;
  }

  String _appleConfigurationMessage(Object error) {
    final raw = error.toString();
    if (raw.contains('webAuthenticationOptions') ||
        raw.contains('clientId') ||
        raw.contains('redirectUri')) {
      return 'Apple sign-in needs APPLE_SERVICE_ID and APPLE_REDIRECT_URI configured for this platform.';
    }
    return 'Unable to sign in with Apple. Please try again.';
  }

  String _deriveNameFromEmail(String email) {
    final localPart = email.split('@').first;
    if (localPart.isEmpty) return 'User';
    final segments = localPart.split(RegExp(r'[._\- ]+'));
    return segments
        .map(
          (part) => part.isEmpty
              ? ''
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .where((part) => part.isNotEmpty)
        .join(' ');
  }

  String? _extractMessage(Response response) {
    if (response.data is Map<String, dynamic>) {
      final body = response.data as Map<String, dynamic>;
      return body['message']?.toString() ??
          body['error']?.toString() ??
          body['errors']?.toString();
    }
    return null;
  }

  String? _extractAuthToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      final token = data['accessToken'] ?? data['token'] ?? data['authToken'];
      if (token != null) return token.toString();
      if (data['data'] is Map<String, dynamic>) {
        final nested = data['data'] as Map<String, dynamic>;
        return nested['accessToken']?.toString() ??
            nested['token']?.toString() ??
            nested['authToken']?.toString();
      }
    }
    return null;
  }

  String? _extractUserEmail(dynamic data) =>
      _extractUserField(data, const ['email', 'userEmail']);

  String? _extractUserName(dynamic data) =>
      _extractUserField(data, const ['fullName', 'name', 'userName']);

  String? _extractUserId(dynamic data) =>
      _extractUserField(data, const ['id', '_id', 'userId']);

  String? _extractUserField(dynamic data, List<String> keys) {
    if (data is! Map<String, dynamic>) return null;

    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    for (final containerKey in const ['data', 'user']) {
      final nested = data[containerKey];
      if (nested is Map<String, dynamic>) {
        final value = _extractUserField(nested, keys);
        if (value != null) return value;
      }
    }

    return null;
  }
}
