import 'package:flutter/material.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';

Future<T?> showBottomPicker<T>({
  required BuildContext context,
  required List<T> items,
  required Widget Function(BuildContext, T) itemBuilder,
  required void Function(T) onItemSelected,
  Color Function(T)? itemColor,
  String? title,
  bool reverse = false,
  TextAlign itemAlignment = TextAlign.start,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colorScheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (title != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(title, style: contrastBoldM(context)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // Ограничиваем максимальную высоту
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    reverse: reverse,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return ListTile(
                        title: Align(
                          alignment:
                              {
                                TextAlign.start: Alignment.centerLeft,
                                TextAlign.center: Alignment.center,
                                TextAlign.end: Alignment.centerRight,
                              }[itemAlignment]!,
                          child: DefaultTextStyle.merge(
                            style: contrastBoldM(context),
                            child: itemBuilder(context, item),
                          ),
                        ),
                        onTap: () {
                          onItemSelected(item);
                          Navigator.pop(context, item);
                        },
                      );
                    },
                    separatorBuilder:
                        (_, __) => Divider(
                          color: colorScheme.secondary,
                          height: 1,
                          thickness: 1,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
