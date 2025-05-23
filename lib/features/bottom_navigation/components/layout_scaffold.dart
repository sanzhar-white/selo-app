import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination_model.dart';

class LayoutScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const LayoutScaffold({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    final mediaQuery = MediaQuery.of(context);

    final destinations = [
      Destination(label: 'Главная', icon: CupertinoIcons.home),
      Destination(label: 'Избранное', icon: CupertinoIcons.heart),
      Destination(label: 'Добавить', icon: CupertinoIcons.add_circled),
      Destination(label: 'Профиль', icon: CupertinoIcons.person_crop_circle),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        height: mediaQuery.size.height * 0.07,
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
                          size: mediaQuery.size.width * 0.06,
                        ),
                      ),
                      SizedBox(height: mediaQuery.size.height * 0.005),
                      AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 200),
                        style: TextStyle(
                          color:
                              isSelected ? theme.primary : theme.inversePrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: mediaQuery.size.width * 0.03,
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
