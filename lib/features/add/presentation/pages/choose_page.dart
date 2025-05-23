import 'package:flutter/material.dart';

class ChoosePage extends StatelessWidget {
  const ChoosePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final crossAxisCount = screenSize.width > 600 ? 3 : 2;
    final crossAxisSpacing = screenSize.width * 0.03;
    final mainAxisSpacing = screenSize.height * 0.03;
    final childAspectRatio = 1.0; // Задай своё значение

    // Пример данных
    final items = List.generate(6, (index) => 'Item $index');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == items.length) {
                return const Placeholder(); // Заглушка
              }
              return Card(child: Center(child: Text(items[index])));
            }, childCount: items.length + 1),
          ),
        ],
      ),
    );
  }
}
