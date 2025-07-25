import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/shared/widgets/show_bottom_picker.dart';
import 'package:selo/core/models/category.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({
    required this.locations,
    super.key,
    this.region,
    this.district,
    this.onRegionChanged,
    this.onDistrictChanged,
    this.regionHint = 'Select region',
    this.districtHint = 'Select district',
    this.regionLabel,
    this.districtLabel,
    this.showLabels = true,
    this.showDistrict = true,
    this.padding,
    this.spacing,
    this.regionError = false,
    this.districtError = false,
    this.regionErrorText,
    this.districtErrorText,
  });
  final String? region;
  final String? district;
  final List<PlaceCategory> locations;
  final ValueChanged<String>? onRegionChanged;
  final ValueChanged<String>? onDistrictChanged;
  final String regionHint;
  final String districtHint;
  final String? regionLabel;
  final String? districtLabel;
  final bool showLabels;
  final bool showDistrict;
  final EdgeInsets? padding;
  final double? spacing;
  final bool regionError;
  final bool districtError;
  final String? regionErrorText;
  final String? districtErrorText;

  bool get _isRegionSelected => region != null && region!.isNotEmpty;

  List<String> get _districts {
    if (!_isRegionSelected) return [];
    final selectedRegion = locations.firstWhere(
      (e) => e.name == region,
      orElse: () => locations.first,
    );
    return selectedRegion.subcategories?.map((e) => e.name).toList() ?? [];
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(message, style: contrastBoldM(context)),
      ),
    );
  }

  void _onDistrictTap(BuildContext context) {
    if (!_isRegionSelected) {
      _showSnackBar(context, 'Please select region first');
      return;
    }
    if (_districts.isEmpty) {
      _showSnackBar(context, 'No districts available for this region');
      return;
    }

    showBottomPicker<String>(
      context: context,
      items: _districts,
      itemBuilder: (context, item) => Text(item),
      itemAlignment: TextAlign.center,
      onItemSelected: onDistrictChanged ?? (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final verticalSpacing = spacing ?? 12.0;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        children: [
          _buildLocationField(
            context,
            title: regionLabel,
            value: region,
            hint: regionHint,
            error: regionError,
            errorText: regionErrorText,
            onTap: () {
              showBottomPicker<String>(
                context: context,
                items: locations.map((e) => e.name).toList(),
                itemBuilder: (context, item) => Text(item),
                itemAlignment: TextAlign.center,
                onItemSelected: onRegionChanged ?? (_) {},
              );
            },
          ),
          if (showDistrict) ...[
            SizedBox(height: verticalSpacing),
            _buildLocationField(
              context,
              title: districtLabel,
              value: district,
              hint: districtHint,
              error: districtError,
              errorText: districtErrorText,
              onTap: () => _onDistrictTap(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationField(
    BuildContext context, {
    required String hint,
    required VoidCallback onTap,
    String? title,
    String? value,
    bool error = false,
    String? errorText,
    bool enabled = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    final textStyle =
        error
            ? contrastM(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.error)
            : contrastM(context);

    final effectiveTextStyle =
        enabled
            ? textStyle
            : textStyle.copyWith(color: colorScheme.onSurface.withOpacity(0.5));

    final iconColor =
        error
            ? Theme.of(context).colorScheme.error
            : (enabled
                ? colorScheme.inversePrimary
                : colorScheme.onSurface.withOpacity(0.5));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels && title != null) ...[
          Text(title, style: contrastBoldM(context)),
          SizedBox(height: screenSize.height * 0.015),
        ],
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(screenSize.width, screenSize.height * 0.06),
            backgroundColor: colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: ResponsiveRadius.screenBased(context),
            ),
            side:
                error
                    ? BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    )
                    : BorderSide.none,
            disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.1),
          ),
          onPressed: enabled ? onTap : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value ?? hint, style: effectiveTextStyle),
              Icon(CupertinoIcons.chevron_down, color: iconColor),
            ],
          ),
        ),
        if (error && errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
