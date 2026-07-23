/// Sendgo API 호출 실패 시 발생하는 예외.
class SendgoException implements Exception {
  final String message;
  final int statusCode;
  final String? errorCode;
  final String endpoint;
  final String apiVersion;
  final Map<String, dynamic> responseBody;

  const SendgoException({
    required this.message,
    this.statusCode = 0,
    this.errorCode,
    this.endpoint = '',
    this.apiVersion = '',
    this.responseBody = const {},
  });

  factory SendgoException.fromResponse(
    int status,
    Map<String, dynamic> body,
    String endpoint,
    String apiVersion,
  ) {
    final errorCode = body['code'] as String?;
    final errorMessage = (body['message'] as String?) ?? 'Unknown error';
    final msg = 'HTTP $status${errorCode != null ? ' [$errorCode]' : ''} $errorMessage';
    return SendgoException(
      message: msg,
      statusCode: status,
      errorCode: errorCode,
      endpoint: endpoint,
      apiVersion: apiVersion,
      responseBody: body,
    );
  }

  @override
  String toString() => 'SendgoException(status: $statusCode, code: $errorCode, message: $message)';
}
