import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
import 'package:selo/generated/l10n.dart';

class SearchAppBarWidget extends StatefulWidget {
  const SearchAppBarWidget({
    super.key,
    required this.searchQuery,
    required this.onSearchSubmitted,
    required this.onFilterPressed,
    this.pinned = false,
    this.backIcon = false,
    this.floating = false,
  });

  final TextEditingController searchQuery;
  final bool pinned;
  final bool backIcon;
  final Function(String) onSearchSubmitted;
  final Function(String) onFilterPressed;
  final bool floating;

  @override
  State<SearchAppBarWidget> createState() => _SearchAppBarWidgetState();
}

class _SearchAppBarWidgetState extends State<SearchAppBarWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: widget.pinned,
      floating: widget.floating,
      collapsedHeight: screenSize.height * 0.08,
      flexibleSpace: FlexibleSpaceBar(
        background: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding:
                widget.backIcon
                    ? EdgeInsets.only(
                      right: screenSize.width * 0.04,
                      top: screenSize.height * 0.01,
                      bottom: screenSize.height * 0.01,
                    )
                    : EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.03,
                      vertical: screenSize.height * 0.01,
                    ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.backIcon)
                  SizedBox(
                    width: screenSize.width * 0.15,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        CupertinoIcons.left_chevron,
                        size: screenSize.height * 0.04,
                        color: theme.secondary,
                      ),
                    ),
                  ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.onSurface,
                      borderRadius: ResponsiveRadius.screenBased(context),
                    ),
                    height: screenSize.height * 0.06,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.03,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.search,
                            size: screenSize.height * 0.03,
                            color: theme.secondary,
                          ),
                          Expanded(
                            child: CustomTextField(
                              controller: widget.searchQuery,
                              theme: theme,
                              style: greenM(context),
                              hintText: S.of(context).search_hint,
                              border: false,
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  widget.onSearchSubmitted(value);
                                }
                              },
                            ),
                          ),
                          IconButton(
                            onPressed:
                                () => widget.onFilterPressed(
                                  widget.searchQuery.text,
                                ),
                            icon: Icon(
                              CupertinoIcons.slider_horizontal_3,
                              size: screenSize.height * 0.036,
                              color: theme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      expandedHeight: screenSize.height * 0.08,
    );
  }
}
