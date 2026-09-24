import 'package:dio/dio.dart';

/// Maps a [DioException] that carries **no HTTP response** to a user-facing
/// message.
///
/// A `DioException` with `response == null` is not always "server unreachable":
/// it also covers connect/send/receive timeouts and TLS failures. Surfacing the
/// same "unable to connect" line for all of them hides the common case where the
/// backend is just slow to wake (e.g. a free-tier host cold start) and a retry
/// would succeed.
///
/// [fallback] is used for a genuine connection failure (host down, no network,
/// DNS/TLS error) so each caller can keep its own wording.
String describeConnectionError(
  DioException e, {
  String fallback = 'Unable to connect to the server. Please try again.',
}) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'The server is taking too long to respond. '
          'It may be waking up — please try again in a moment.';
    case DioExceptionType.badCertificate:
      return 'Could not establish a secure connection to the server.';
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
    case DioExceptionType.cancel:
    case DioExceptionType.badResponse:
      return fallback;
  }
}
