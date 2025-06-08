import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination_model.dart';
import 'package:selo/generated/l10n.dart';

class LayoutScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const LayoutScaffold({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    final screenSize = MediaQuery.of(context).size;

    final destinations = [
      Destination(label: S.of(context).nav_home, icon: CupertinoIcons.home),
      Destination(
        label: S.of(context).nav_favourites,
        icon: CupertinoIcons.heart,
      ),
      Destination(
        label: S.of(context).nav_add,
        icon: CupertinoIcons.add_circled,
      ),
      Destination(
        label: S.of(context).nav_profile,
        icon: CupertinoIcons.person_crop_circle,
      ),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: theme.surface,
        height: screenSize.height * 0.07,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              destinations.asMap().entries.map((entry) {
                final index = entry.key;
                final destination = entry.value;
                final isSelected = index == navigationShell.currentIndex;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          destination.icon,
                          key: ValueKey<bool>(isSelected),
                          color:
                              isSelected ? theme.primary : theme.inversePrimary,
                          size: screenSize.width * 0.06,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.005),
                      AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 200),
                        style: TextStyle(
                          color:
                              isSelected ? theme.primary : theme.inversePrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: screenSize.width * 0.03,
                        ),
                        child: Text(destination.label),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
