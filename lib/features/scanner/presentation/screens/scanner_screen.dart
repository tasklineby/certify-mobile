import 'package:certify_client/core/theme/app_colors.dart';
import 'package:certify_client/core/domain/entities/verification_result.dart';
import 'package:certify_client/features/scanner/presentation/viewmodels/scanner_view_model.dart';
import 'package:certify_client/features/scanner/presentation/widgets/verification_result_sheet.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui'; // For BoxFilter

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScannerViewModel>().init();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showResultSheet(BuildContext context, VerificationResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Important for custom rounded styling
      builder: (context) => VerificationResultSheet(
        result: result,
        onScanAgain: () {
          context.read<ScannerViewModel>().resetScanner();
        },
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white.withValues(alpha: 0.1),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y == -1
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            bottom: alignment.y == 1
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            left: alignment.x == -1
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            right: alignment.x == 1
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ScannerViewModel>();
    final scanWindowSize = MediaQuery.of(context).size.width * 0.75;
    final topOffset = MediaQuery.of(context).size.height * 0.2;

    // React to result changes
    if (viewModel.result != null && !viewModel.isProcessing) {
      // Using addPostFrameCallback to avoid build-phase navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.isCurrent == true) {
          // Check if sheet is not already open
          _showResultSheet(context, viewModel.result!);
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Layer
          MobileScanner(
            controller: viewModel.controller,
            onDetect: viewModel.onDetect,
          ),

          // 2. Custom Dark Overlay (Cutout)
          // Top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topOffset,
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),
          // Bottom
          Positioned(
            top: topOffset + scanWindowSize,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),
          // Left
          Positioned(
            top: topOffset,
            left: 0,
            width: (MediaQuery.of(context).size.width - scanWindowSize) / 2,
            height: scanWindowSize,
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),
          // Right
          Positioned(
            top: topOffset,
            right: 0,
            width: (MediaQuery.of(context).size.width - scanWindowSize) / 2,
            height: scanWindowSize,
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),

          // 3. Scan Border & Laser Animation
          Positioned(
            top: topOffset,
            left: (MediaQuery.of(context).size.width - scanWindowSize) / 2,
            width: scanWindowSize,
            height: scanWindowSize,
            child: Stack(
              children: [
                // Corners
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                // Glowing Corners
                _buildCorner(Alignment.topLeft),
                _buildCorner(Alignment.topRight),
                _buildCorner(Alignment.bottomLeft),
                _buildCorner(Alignment.bottomRight),

                // Laser
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Positioned(
                      top: _animation.value * (scanWindowSize - 4),
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 4. Top App Bar (Custom)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Placeholder
                    SizedBox(width: 40, height: 1),
                    const Text(
                      'Scan Document',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildGlassIconButton(
                      icon: Icons.history_rounded,
                      onTap: () => context.push('/history'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Bottom Instructions & Flash
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Align QR code within the frame',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                // Flashlight Button
                GestureDetector(
                  onTap: () => viewModel.controller.toggleTorch(),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.flashlight_on_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 6. Loading Indicator
          if (viewModel.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),

          // 7. Error Message
          if (viewModel.errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => viewModel.init(),
                      child: const Text('Retry Permission'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
