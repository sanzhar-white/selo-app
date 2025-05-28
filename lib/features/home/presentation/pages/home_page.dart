import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/providers/theme_provider.dart';
import 'package:selo/generated/l10n.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/shared/widgets/custom_text_field.dart';
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
    final screenSize = MediaQuery.of(context).size;
    final searchQuery = TextEditingController();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SearchAppBarWidget(searchQuery: searchQuery),

          // BannersBodyWidget(
          //   searchQuery: searchQuery,
          //   banners: banners,
          // ),
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              background: Row(
                children: [
                  Expanded(child: Column(children: const [])),
                  Expanded(child: Column(children: const [])),
                ],
              ),
            ),
          ),
          const SliverFillRemaining(),
        ],
      ),
    );
  }
}
