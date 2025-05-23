import 'package:flutter/material.dart';
import 'package:selo/shared/widgets/customtextfield.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:flutter/cupertino.dart';

class SearchAppBarWidget extends StatefulWidget {
  const SearchAppBarWidget({super.key, required this.searchQuery});
  final TextEditingController searchQuery;

  @override
  State<SearchAppBarWidget> createState() => _SearchAppBarWidgetState();
}

class _SearchAppBarWidgetState extends State<SearchAppBarWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    return SliverAppBar(
      flexibleSpace: FlexibleSpaceBar(
        background: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: theme.onSurface,
                borderRadius: BorderRadius.circular(10.0),
              ),
              height: mediaQuery.size.height * 0.06,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: mediaQuery.size.width * 0.03,
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      size: mediaQuery.size.height * 0.03,
                      color: theme.secondary,
                    ),
                    Expanded(
                      child: CustomTextField(
                        controller: widget.searchQuery,
                        theme: theme,
                        style: GreenM(context),
                        hintText: 'Поиск по Казахстану',
                        border: false,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.slider_horizontal_3,
                        size: mediaQuery.size.height * 0.036,
                        color: theme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      expandedHeight: mediaQuery.size.height * 0.08,
    );
  }
}
