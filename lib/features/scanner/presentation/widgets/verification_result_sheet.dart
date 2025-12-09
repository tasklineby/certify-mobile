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
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

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
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Scanned at ${widget.result.timestamp.hour}:${widget.result.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
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
}
