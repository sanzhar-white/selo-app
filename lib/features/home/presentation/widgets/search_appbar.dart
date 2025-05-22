import 'package:flutter/material.dart';
import 'package:selo/shared/widgets/customtextfield.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:flutter/cupertino.dart';

class SearchAppBarWidget extends StatelessWidget {
  const SearchAppBarWidget({
    super.key,
    required this.theme,
    required this.mediaQuery,
    required this.searchQuery,
  });

  final ColorScheme theme;
  final MediaQueryData mediaQuery;
  final TextEditingController searchQuery;

  @override
  Widget build(BuildContext context) {
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
                        controller: searchQuery,
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
