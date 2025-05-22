import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/theme/theme_provider.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/shared/widgets/customtextfield.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../widgets/search_appbar.dart';
import '../widgets/banners_body.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final searchQuery = TextEditingController();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SearchAppBarWidget(
            theme: theme,
            mediaQuery: mediaQuery,
            searchQuery: searchQuery,
          ),

          // BannersBodyWidget(
          //   theme: theme,
          //   mediaQuery: mediaQuery,
          //   searchQuery: searchQuery,
          //   banners: banners,
          // ),
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              background: Expanded(child: )
            ),
          ),
          SliverFillRemaining(),
        ],
      ),
    );
  }
}
