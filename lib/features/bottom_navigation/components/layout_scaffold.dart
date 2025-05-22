import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:selo/generated/l10n.dart';
import '../models/destination.dart';

class LayoutScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const LayoutScaffold({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey<String>('LayoutScaffold'));

  void _onTap(int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final destinations = [
      Destination(label: S.of(context).home, icon: CupertinoIcons.home),
      Destination(label: S.of(context).favourites, icon: CupertinoIcons.heart),
      Destination(label: S.of(context).add, icon: CupertinoIcons.add_circled),
      Destination(
        label: S.of(context).profile,
        icon: CupertinoIcons.person_crop_circle,
      ),
    ];
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        indicatorColor: theme.primary,
        destinations:
            destinations
                .map(
                  (e) =>
                      NavigationDestination(icon: Icon(e.icon), label: e.label),
                )
                .toList(),
      ),
    );
  }
}
