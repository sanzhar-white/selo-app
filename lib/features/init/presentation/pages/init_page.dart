import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/features/init/presentation/provider/init_provider.dart';

class InitPage extends ConsumerWidget {
  const InitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(initStateProvider);

    // Listen for initialization state changes
    ref.listen(initStateProvider, (previous, next) {
      if (next.isInitialized) {
        if (next.user != null) {
          context.go(Routes.homePage);
        } else {
          context.go(Routes.authenticationPage);
        }
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or branding
            const FlutterLogo(size: 100),
            const SizedBox(height: 24),

            if (initState.isLoading)
              const CircularProgressIndicator()
            else if (initState.error != null)
              Column(
                children: [
                  SelectableText(
                    'Error: ${initState.error}, ${initState.stackTrace?.toString()}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(initStateProvider.notifier).initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
