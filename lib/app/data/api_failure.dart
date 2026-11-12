enum ApiFailureKind { network, timeout, badStatus, parsing, unknown }

final class ApiFailure implements Exception {
  const ApiFailure(this.kind, this.message, [this.statusCode]);

  final ApiFailureKind kind;
  final String message;
  final int? statusCode;

  String get userMessage => switch (kind) {
    ApiFailureKind.network => 'Could not reach the server. Check your connection and try again.',
    ApiFailureKind.timeout => 'Request timed out. Try again.',
    ApiFailureKind.parsing => 'Unexpected server response. Try again.',
    ApiFailureKind.unknown => 'Something went wrong. Try again.',
    ApiFailureKind.badStatus => switch (statusCode) {
      400 || 422 => message.isNotEmpty ? message : 'Invalid request. Check your input.',
      401 || 403 => 'You are not authorized. Try again.',
      final int code when code >= 500 => 'Server error. Try again later.',
      _ => 'Request failed. Try again.',
    },
  };
}
