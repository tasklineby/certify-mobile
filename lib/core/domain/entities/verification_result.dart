enum VerificationStatus {
  valid,
  warning,
  invalid;

  bool get isValid => this == VerificationStatus.valid;
  bool get isWarning => this == VerificationStatus.warning;
  bool get isInvalid => this == VerificationStatus.invalid;
}

class VerificationResult {
  final VerificationStatus status;
  final String documentId;
  final DateTime timestamp;
  final String message;

  const VerificationResult({
    required this.status,
    required this.documentId,
    required this.timestamp,
    required this.message,
  });
}
