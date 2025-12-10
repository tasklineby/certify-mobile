import 'package:flutter/material.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import 'package:certify_client/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:certify_client/features/scanner/presentation/widgets/comparison_result_sheet.dart';
import 'package:certify_client/features/scanner/presentation/viewmodels/scanner_view_model.dart';

class VerificationResultSheet extends StatefulWidget {
  final VerificationResult result;
  final ScannerViewModel viewModel;
  final VoidCallback onScanAgain;

  const VerificationResultSheet({
    super.key,
    required this.result,
    required this.viewModel,
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
      height: MediaQuery.of(context).size.height * 0.92,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
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
            const SizedBox(height: 24),

            // Compare with Physical Copy Button
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _showCompareOptions(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.compare_arrows,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Compare with Physical Copy',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

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
      ),
    );
  }

  void _showCompareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose Comparison Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 24),
            _buildCompareOption(
              context,
              icon: Icons.camera_alt_outlined,
              title: 'Take Photos',
              subtitle: 'Capture physical document',
              onTap: () async {
                Navigator.pop(context);

                // Capture photo
                await widget.viewModel.capturePhoto();

                // If at least one photo, compare
                if (widget.viewModel.capturedPhotos.isNotEmpty) {
                  await widget.viewModel.compareWithPhotos();

                  // Show result if available
                  if (widget.viewModel.comparisonResult != null &&
                      context.mounted) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ComparisonResultSheet(
                        result: widget.viewModel.comparisonResult!,
                        onClose: () {
                          Navigator.pop(context);
                          context.pop(); // Close main sheet
                          widget.onScanAgain();
                        },
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            _buildCompareOption(
              context,
              icon: Icons.picture_as_pdf_outlined,
              title: 'Upload PDF',
              subtitle: 'Choose PDF from files',
              onTap: () async {
                Navigator.pop(context);

                // Call PDF comparison
                await widget.viewModel.compareWithPdf();

                // Show result if available
                if (widget.viewModel.comparisonResult != null &&
                    context.mounted) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ComparisonResultSheet(
                      result: widget.viewModel.comparisonResult!,
                      onClose: () {
                        Navigator.pop(context);
                        context.pop(); // Close main sheet
                        widget.onScanAgain();
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondaryLight,
            ),
          ],
        ),
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
