import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/theme/theme_provider.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/theme/text_styles.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            ref.read(themeProvider.notifier).toggleTheme();
          },
          child: Container(
            width: 200,
            height: 200,
            color: theme.primary,
            child: Text(S.of(context).hello, style: titleStyle1(context)),
          ),
        ),
      ),
    );
  }
}
