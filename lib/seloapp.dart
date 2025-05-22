import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/routes/router.dart';

import 'package:selo/core/theme/theme_provider.dart';
import 'package:selo/generated/l10n.dart';

class SeloApp extends ConsumerWidget {
  const SeloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp.router(
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: theme,
    );
  }
}
