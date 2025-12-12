import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:certify_client/core/theme/app_theme.dart';
import '../viewmodels/local_auth_view_model.dart';

class LocalAuthScreen extends StatefulWidget {
  const LocalAuthScreen({super.key});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize Auth capabilities
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocalAuthViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LocalAuthViewModel>();

    // Listen for auth success to navigate
    if (viewModel.isAuthenticated) {
      // We handle navigation in the router redirection logic mostly,
      // but explicit navigation can also work.
      // For GoRouter redirection, the state change triggers it.
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.security,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                viewModel.isSetupMode ? 'Создайте PIN' : 'Введите PIN',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (viewModel.isLoading)
                const CircularProgressIndicator()
              else if (viewModel.errorMessage != null)
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Theme.of(context).statusError),
                )
              else
                const Text('Защитите свои цифровые документы'),

              const SizedBox(height: 32),

              // PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(LocalAuthViewModel.pinLength, (index) {
                  final isFilled = index < viewModel.pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: isFilled
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  );
                }),
              ),

              const Spacer(flex: 1),

              // Numpad
              Expanded(
                flex: 4,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    // Mapping index to keypad buttons:
                    // 0-8 -> 1-9
                    // 9 -> Biometrics or Empty
                    // 10 -> 0
                    // 11 -> Backspace

                    if (index == 9) {
                      if (!viewModel.isSetupMode &&
                          viewModel.canCheckBiometrics) {
                        return IconButton(
                          onPressed: viewModel.authenticateWithBiometrics,
                          icon: const Icon(Icons.fingerprint, size: 32),
                        );
                      }
                      return const SizedBox();
                    }

                    if (index == 11) {
                      return IconButton(
                        onPressed: viewModel.removeDigit,
                        icon: const Icon(Icons.backspace_outlined),
                      );
                    }

                    if (index == 10) {
                      return _NumberButton(
                        number: '0',
                        onJob: viewModel.addDigit,
                      );
                    }

                    final number = (index + 1).toString();
                    return _NumberButton(
                      number: number,
                      onJob: viewModel.addDigit,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String number;
  final Function(String) onJob;

  const _NumberButton({required this.number, required this.onJob});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onJob(number),
      customBorder: const CircleBorder(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Text(number, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
