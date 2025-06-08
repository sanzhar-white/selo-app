import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/routes/router.dart';
import 'package:selo/core/providers/locale_provider.dart';
import 'package:selo/core/providers/theme_provider.dart';
import 'package:selo/generated/l10n.dart';

class SeloApp extends ConsumerWidget {
  const SeloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final theme = ref.watch(themeProvider);
    return MaterialApp.router(
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('kk')],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: theme,
    );
  }
}
