import 'package:flutter/material.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import 'package:certify_client/core/theme/app_colors.dart';
import 'package:certify_client/core/theme/app_theme.dart';

class HistoryCard extends StatelessWidget {
  final VerificationResult result;

  const HistoryCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getStatusColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getStatusIcon(),
              color: _getStatusColor(context),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.documentId ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(result.timestamp ?? DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Chevron
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (result.status) {
      case VerificationStatus.valid:
        return Theme.of(context).statusSuccess;
      case VerificationStatus.warning:
        return Theme.of(context).statusWarning;
      case VerificationStatus.invalid:
        return Theme.of(context).statusError;
      case VerificationStatus.unknown:
        return AppColors.textSecondaryLight;
    }
  }

  IconData _getStatusIcon() {
    switch (result.status) {
      case VerificationStatus.valid:
        return Icons.verified_user_rounded;
      case VerificationStatus.warning:
        return Icons.warning_rounded;
      case VerificationStatus.invalid:
        return Icons.error_outline_rounded;
      case VerificationStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  String _formatDate(DateTime date) {
    // Simple formatter, can be improved with intl package
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
