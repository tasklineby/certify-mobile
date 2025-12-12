import 'dart:io';
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
          'Новый документ',
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
              const SizedBox(height: 32),

              // File Upload Section
              _buildLabel('Прикрепить файл *', colorScheme),
              const SizedBox(height: 12),
              _buildFileUploadSection(context, viewModel, colorScheme),
              const SizedBox(height: 24),

              // Name Field
              _buildLabel('Название документа', colorScheme),
              const SizedBox(height: 12),
              TextFormField(
                controller: viewModel.nameController,
                decoration: _buildInputDecoration(
                  context,
                  'напр. Договор на оказание услуг',
                  colorScheme,
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 20),

              // Summary Field
              _buildLabel('Описание', colorScheme),
              const SizedBox(height: 12),
              TextFormField(
                controller: viewModel.summaryController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  context,
                  'Краткое описание...',
                  colorScheme,
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 20),

              // Type Selector
              _buildLabel('Тип документа', colorScheme),
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
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        checkmarkColor: colorScheme.onSurface,
                        onSelected: (_) => viewModel.setType(type),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Expiration Date
              _buildLabel('Дата истечения', colorScheme),
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
                      'Выбрать дату',
                      colorScheme,
                    ).copyWith(
                      suffixIcon: Icon(
                        Icons.calendar_today_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      hintText: viewModel.selectedDate != null
                          ? DateFormat.yMMMd().format(viewModel.selectedDate!)
                          : 'Выбрать дату',
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
                            'Документ успешно создан',
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
                                'Создать документ',
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

  Widget _buildFileUploadSection(
    BuildContext context,
    CreateDocumentViewModel viewModel,
    ColorScheme colorScheme,
  ) {
    if (viewModel.selectedFile != null) {
      return _buildFilePreview(context, viewModel, colorScheme);
    }
    return _buildFileUploadEmpty(context, viewModel, colorScheme);
  }

  Widget _buildFileUploadEmpty(
    BuildContext context,
    CreateDocumentViewModel viewModel,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () => _showFileSourceSheet(context, viewModel),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignCenter,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Нажмите, чтобы прикрепить файл или сделать фото',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Поддерживается: JPG, PNG, PDF',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(
    BuildContext context,
    CreateDocumentViewModel viewModel,
    ColorScheme colorScheme,
  ) {
    final file = viewModel.selectedFile!;
    final fileName = file.path.split('/').last;
    final isImage =
        fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(file, width: 60, height: 60, fit: BoxFit.cover),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: AppColors.primary,
                size: 32,
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: viewModel.removeFile,
            icon: Icon(Icons.close, color: colorScheme.error),
          ),
        ],
      ),
    );
  }

  void _showFileSourceSheet(
    BuildContext context,
    CreateDocumentViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Выберите источник файла',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildSourceOption(
              context,
              icon: Icons.camera_alt_outlined,
              title: 'Камера',
              subtitle: 'Сделать фото',
              onTap: () {
                Navigator.pop(context);
                viewModel.pickImageFromCamera();
              },
            ),
            const SizedBox(height: 12),
            _buildSourceOption(
              context,
              icon: Icons.photo_library_outlined,
              title: 'Галерея',
              subtitle: 'Выбрать из фотографий',
              onTap: () {
                Navigator.pop(context);
                viewModel.pickImageFromGallery();
              },
            ),
            const SizedBox(height: 12),
            _buildSourceOption(
              context,
              icon: Icons.insert_drive_file_outlined,
              title: 'Файлы',
              subtitle: 'Выбрать документ',
              onTap: () {
                Navigator.pop(context);
                viewModel.pickDocument();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
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
