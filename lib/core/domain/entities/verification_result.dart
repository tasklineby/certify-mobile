enum VerificationStatus {
  valid,
  warning,
  invalid,
  unknown;

  bool get isValid => this == VerificationStatus.valid;
  bool get isWarning => this == VerificationStatus.warning;
  bool get isInvalid => this == VerificationStatus.invalid;
}

class VerificationResult {
  final VerificationStatus status;
  final String? documentId;
  final DateTime? timestamp;
  final String message;
  final String? rawStatus;
  final Map<String, dynamic>? metadata;

  const VerificationResult({
    required this.status,
    this.documentId,
    this.timestamp,
    required this.message,
    this.rawStatus,
    this.metadata,
  });
}
