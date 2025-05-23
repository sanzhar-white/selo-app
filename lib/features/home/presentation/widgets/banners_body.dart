// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:selo/shared/widgets/customtextfield.dart';
// import 'package:selo/core/theme/text_styles.dart';
// import 'package:flutter/cupertino.dart';

// class BannersBodyWidget extends StatefulWidget {
//   const BannersBodyWidget({
//     super.key,
//     required this.searchQuery,
//     required this.banners,
//     this.autoPlayInterval = const Duration(seconds: 10),
//   });

//   final TextEditingController searchQuery;
//   final List<BannerModel> banners;
//   final Duration autoPlayInterval;

//   @override
//   State<BannersBodyWidget> createState() => _BannersBodyWidgetState();
// }

// class _BannersBodyWidgetState extends State<BannersBodyWidget> {
//   int _current = 0;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context).colorScheme;
//     final mediaQuery = MediaQuery.of(context);
//     return SliverAppBar(
//       flexibleSpace: FlexibleSpaceBar(
//         background: Column(
//           children: [
//             CarouselSlider(
//               items: [],
//               options: CarouselOptions(
//                 aspectRatio: 10 / 6, // Force 4:3 aspect ratio
//                 viewportFraction: 0.9,
//                 autoPlay: true,
//                 autoPlayInterval: widget.autoPlayInterval,
//                 enlargeCenterPage: true,
//                 onPageChanged: (index, reason) {
//                   setState(() {
//                     _current = index;
//                   });
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       expandedHeight: mediaQuery.size.height * 0.08,
//     );
//   }
// }
