import 'package:certify_client/core/theme/app_colors.dart';
import 'package:certify_client/core/di/injection.dart';
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
  // I will assume it's provided, or I will wrap it here for simplicity given the context.
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

    // Listen for errors or success if needed (usually via listener/stream, but simple state check works for now)
    // For success navigation, usually ViewModel triggers a callback or we listen to a stream.
    // Given the simple boolean return in submit(), let's handle it in the button callback actually.

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Document'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter document details below.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              _buildLabel('Document Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: viewModel.nameController,
                decoration: _buildInputDecoration('e.g. Service Agreement'),
              ),
              const SizedBox(height: 24),

              // Summary Field
              _buildLabel('Summary'),
              const SizedBox(height: 8),
              TextFormField(
                controller: viewModel.summaryController,
                maxLines: 3,
                decoration: _buildInputDecoration('Brief description...'),
              ),
              const SizedBox(height: 24),

              // Type Selector
              _buildLabel('Document Type'),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: viewModel.documentTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final type = viewModel.documentTypes[index];
                    final isSelected = viewModel.selectedType == type;
                    return GestureDetector(
                      onTap: () => viewModel.setType(type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context).colorScheme.surface,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            toBeginningOfSentenceCase(type) ?? type,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Expiration Date
              _buildLabel('Expiration Date'),
              const SizedBox(height: 8),
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
                          colorScheme: theme.colorScheme.copyWith(
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
                decoration: _buildInputDecoration('Select Date').copyWith(
                  suffixIcon: const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.textSecondaryLight,
                  ),
                  hintText: viewModel.selectedDate != null
                      ? DateFormat.yMMMd().format(viewModel.selectedDate!)
                      : 'Select Date',
                ),
              ),

              const SizedBox(height: 24),
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FloatingActionButton.extended(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    final success = await viewModel.submit();
                    if (success && context.mounted) {
                      context.pop(); // Go back on success
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Document created successfully'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
            backgroundColor: AppColors.primary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            label: viewModel.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Create Document',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
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
