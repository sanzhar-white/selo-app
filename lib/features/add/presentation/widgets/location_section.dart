import 'package:flutter/material.dart';
import 'package:selo/core/constants/regions_districts.dart';
import 'package:selo/shared/widgets/location_picker.dart';

class LocationSection extends StatelessWidget {
  final String region;
  final String district;
  final ValueChanged<String> onRegionChanged;
  final ValueChanged<String> onDistrictChanged;
  final bool regionError;
  final bool districtError;

  const LocationSection({
    super.key,
    required this.region,
    required this.district,
    required this.onRegionChanged,
    required this.onDistrictChanged,
    this.regionError = false,
    this.districtError = false,
  });

  @override
  Widget build(BuildContext context) {
    return LocationPicker(
      region: region,
      district: district,
      locations: regions,
      onRegionChanged: onRegionChanged,
      onDistrictChanged: onDistrictChanged,
      regionLabel: 'Region',
      districtLabel: 'District',
      regionError: regionError,
      districtError: districtError,
      regionErrorText: 'Region is required',
      districtErrorText: 'District is required',
    );
  }
}
