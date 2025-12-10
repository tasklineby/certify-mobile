import 'package:certify_client/core/theme/app_colors.dart';
import 'package:certify_client/core/di/injection.dart';
import 'package:certify_client/core/utils/ui_utils.dart';
import 'package:certify_client/features/scanner/presentation/viewmodels/create_document_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateDocumentScreen extends StatefulWidget {
  const CreateDocumentScreen({super.key});

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen> {
  // We'll provide the ViewModel manually here or in the router.
  // Ideally, if using get_it, we can instantiate it here if not provided by router.
  // But standard pattern is Provider in the widget tree.
  // The user asked to register in DI, so I will use getIt to create it.

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<CreateDocumentViewModel>(),
      child: const _CreateDocumentContent(),
    );
  }
}

class _CreateDocumentContent extends StatelessWidget {
  const _CreateDocumentContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateDocumentViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'New Document',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 24, // Matches padding requirement
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Text(
                'Enter document details below.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              _buildLabel('Document Name', colorScheme),
              const SizedBox(height: 12),
              TextFormField(
                controller: viewModel.nameController,
                decoration: _buildInputDecoration(
                  context,
                  'e.g. Service Agreement',
                  colorScheme,
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 20),

              // Summary Field
              _buildLabel('Summary', colorScheme),
              const SizedBox(height: 12),
              TextFormField(
                controller: viewModel.summaryController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  context,
                  'Brief description...',
                  colorScheme,
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 20),

              // Type Selector
              _buildLabel('Document Type', colorScheme),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: viewModel.documentTypes.map((type) {
                    final isSelected = viewModel.selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ChoiceChip(
                        label: Text(
                          toBeginningOfSentenceCase(type) ?? type,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide.none,
                        ),
                        onSelected: (_) => viewModel.setType(type),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Expiration Date
              _buildLabel('Expiration Date', colorScheme),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: theme.copyWith(
                          colorScheme: colorScheme.copyWith(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    viewModel.setDate(picked);
                  }
                },
                decoration:
                    _buildInputDecoration(
                      context,
                      'Select Date',
                      colorScheme,
                    ).copyWith(
                      suffixIcon: Icon(
                        Icons.calendar_today_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      hintText: viewModel.selectedDate != null
                          ? DateFormat.yMMMd().format(viewModel.selectedDate!)
                          : 'Select Date',
                      hintStyle: TextStyle(
                        color: viewModel.selectedDate != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                style: TextStyle(color: colorScheme.onSurface),
              ),

              const SizedBox(height: 20),
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),

              const SizedBox(height: 32),

              // Custom Submit Button
              GestureDetector(
                onTap: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.submit();
                        if (success && context.mounted) {
                          context.pop();
                          UiUtils.showCustomSnackBar(
                            context,
                            'Document created successfully',
                          );
                        }
                      },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Create Document',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context,
    String hint,
    ColorScheme colorScheme,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
