import 'package:flutter/material.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import 'package:certify_client/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class VerificationResultSheet extends StatefulWidget {
  final VerificationResult result;
  final VoidCallback onScanAgain;

  const VerificationResultSheet({
    super.key,
    required this.result,
    required this.onScanAgain,
  });

  @override
  State<VerificationResultSheet> createState() =>
      _VerificationResultSheetState();
}

class _VerificationResultSheetState extends State<VerificationResultSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.result.status) {
      case VerificationStatus.valid:
        return AppColors.success;
      case VerificationStatus.warning:
        return AppColors.warning;
      case VerificationStatus.invalid:
        return AppColors.error;
      case VerificationStatus.unknown:
        return AppColors.textSecondaryLight;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.result.status) {
      case VerificationStatus.valid:
        return Icons.verified_user_rounded;
      case VerificationStatus.warning:
        return Icons.warning_rounded;
      case VerificationStatus.invalid:
        return Icons.error_rounded;
      case VerificationStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusTitle() {
    switch (widget.result.status) {
      case VerificationStatus.valid:
        return 'Authentic Document';
      case VerificationStatus.warning:
        return 'Verification Warning';
      case VerificationStatus.invalid:
        return 'Invalid Document';
      case VerificationStatus.unknown:
        return 'Unknown Status';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    // Filter metadata to ignore nulls
    final validMetadata = widget.result.metadata ?? {};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getStatusIcon(), size: 64, color: statusColor),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              _getStatusTitle(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Info Card
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Message
                  Text(
                    'Verification Message',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.result.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimaryLight,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 16),

                  // Document Details
                  _buildDetailRow(
                    context,
                    label: 'Document ID',
                    value: '#${widget.result.documentId}',
                    icon: Icons.tag,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    label: 'Scanned at',
                    value:
                        '${widget.result.timestamp?.day}/${widget.result.timestamp?.month}/${widget.result.timestamp?.year} ${widget.result.timestamp?.hour}:${widget.result.timestamp?.minute.toString().padLeft(2, '0')}',
                    icon: Icons.access_time_rounded,
                  ),

                  // Metadata Section (Dynamic)
                  if (validMetadata.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Document Metadata',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...validMetadata.entries
                        .where((e) => e.key != "document_id")
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 16,
                                  color: AppColors.textSecondaryLight,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_formatKey(e.key)}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    e.key == "expiration_date"
                                        ? '${(DateTime.parse(e.value as String)).day}/${(DateTime.parse(e.value as String)).month}/${(DateTime.parse(e.value as String)).year}'
                                        : e.value.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Scan Again Button
          FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  widget.onScanAgain();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.textPrimaryLight, // Dark button for contrast
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text('Scan Next Document'),
              ),
            ),
          ),
          const SizedBox(height: 16), // Bottom safe area buffer
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryLight),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.textSecondaryLight,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimaryLight,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatKey(String key) {
    // Convert snake_case to Title Case
    return key
        .split('_')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }
}
