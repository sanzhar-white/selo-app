// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `English`
  String get language {
    return Intl.message(
      'English',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `ENG`
  String get language_display_code {
    return Intl.message(
      'ENG',
      name: 'language_display_code',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language_title {
    return Intl.message(
      'Language',
      name: 'language_title',
      desc: '',
      args: [],
    );
  }

  /// `en`
  String get language_code {
    return Intl.message(
      'en',
      name: 'language_code',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme_title {
    return Intl.message(
      'Theme',
      name: 'theme_title',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get theme_light {
    return Intl.message(
      'Light',
      name: 'theme_light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get theme_dark {
    return Intl.message(
      'Dark',
      name: 'theme_dark',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message(
      'Register',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signup {
    return Intl.message(
      'Sign up',
      name: 'signup',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get signin {
    return Intl.message(
      'Sign in',
      name: 'signin',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get signout {
    return Intl.message(
      'Sign out',
      name: 'signout',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signup_title {
    return Intl.message(
      'Sign up',
      name: 'signup_title',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get signin_title {
    return Intl.message(
      'Sign in',
      name: 'signin_title',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get optional {
    return Intl.message(
      'Optional',
      name: 'optional',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get required {
    return Intl.message(
      'Required',
      name: 'required',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Views`
  String get views {
    return Intl.message(
      'Views',
      name: 'views',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Trade possible`
  String get trade_possible {
    return Intl.message(
      'Trade possible',
      name: 'trade_possible',
      desc: '',
      args: [],
    );
  }

  /// `Trade not possible`
  String get trade_not_possible {
    return Intl.message(
      'Trade not possible',
      name: 'trade_not_possible',
      desc: '',
      args: [],
    );
  }

  /// `All ads`
  String get all_ads {
    return Intl.message(
      'All ads',
      name: 'all_ads',
      desc: '',
      args: [],
    );
  }

  /// `All categories`
  String get all_categories {
    return Intl.message(
      'All categories',
      name: 'all_categories',
      desc: '',
      args: [],
    );
  }

  /// `No ads found`
  String get no_ads_found {
    return Intl.message(
      'No ads found',
      name: 'no_ads_found',
      desc: '',
      args: [],
    );
  }

  /// `Search in Kazakhstan`
  String get search_hint {
    return Intl.message(
      'Search in Kazakhstan',
      name: 'search_hint',
      desc: '',
      args: [],
    );
  }

  /// `Call`
  String get call {
    return Intl.message(
      'Call',
      name: 'call',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `Sort`
  String get sort {
    return Intl.message(
      'Sort',
      name: 'sort',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get sort_by {
    return Intl.message(
      'Sort by',
      name: 'sort_by',
      desc: '',
      args: [],
    );
  }

  /// `Price from`
  String get sort_by_price_from {
    return Intl.message(
      'Price from',
      name: 'sort_by_price_from',
      desc: '',
      args: [],
    );
  }

  /// `Price to`
  String get sort_by_price_to {
    return Intl.message(
      'Price to',
      name: 'sort_by_price_to',
      desc: '',
      args: [],
    );
  }

  /// `Newest`
  String get sort_by_date_newest {
    return Intl.message(
      'Newest',
      name: 'sort_by_date_newest',
      desc: '',
      args: [],
    );
  }

  /// `Oldest`
  String get sort_by_date_oldest {
    return Intl.message(
      'Oldest',
      name: 'sort_by_date_oldest',
      desc: '',
      args: [],
    );
  }

  /// `Lowest`
  String get sort_by_price_from_lowest {
    return Intl.message(
      'Lowest',
      name: 'sort_by_price_from_lowest',
      desc: '',
      args: [],
    );
  }

  /// `Highest`
  String get sort_by_price_highest {
    return Intl.message(
      'Highest',
      name: 'sort_by_price_highest',
      desc: '',
      args: [],
    );
  }

  /// `Negotiable`
  String get price_negotiable {
    return Intl.message(
      'Negotiable',
      name: 'price_negotiable',
      desc: '',
      args: [],
    );
  }

  /// `Fixed`
  String get price_fixed {
    return Intl.message(
      'Fixed',
      name: 'price_fixed',
      desc: '',
      args: [],
    );
  }

  /// `Price range`
  String get price_range {
    return Intl.message(
      'Price range',
      name: 'price_range',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get price_range_from {
    return Intl.message(
      'From',
      name: 'price_range_from',
      desc: '',
      args: [],
    );
  }

  /// `To`
  String get price_range_to {
    return Intl.message(
      'To',
      name: 'price_range_to',
      desc: '',
      args: [],
    );
  }

  /// `Creating a new advert`
  String get add_appbar_title {
    return Intl.message(
      'Creating a new advert',
      name: 'add_appbar_title',
      desc: '',
      args: [],
    );
  }

  /// `Choose category of your advert`
  String get add_appbar_pick_category {
    return Intl.message(
      'Choose category of your advert',
      name: 'add_appbar_pick_category',
      desc: '',
      args: [],
    );
  }

  /// `Title of advert`
  String get title_of_ad {
    return Intl.message(
      'Title of advert',
      name: 'title_of_ad',
      desc: '',
      args: [],
    );
  }

  /// `Enter title of advert`
  String get title_of_ad_hint {
    return Intl.message(
      'Enter title of advert',
      name: 'title_of_ad_hint',
      desc: '',
      args: [],
    );
  }

  /// `Title is required`
  String get title_of_ad_required {
    return Intl.message(
      'Title is required',
      name: 'title_of_ad_required',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Describe your advert in detail`
  String get description_hint {
    return Intl.message(
      'Describe your advert in detail',
      name: 'description_hint',
      desc: '',
      args: [],
    );
  }

  /// `Description is required`
  String get description_required {
    return Intl.message(
      'Description is required',
      name: 'description_required',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get phone_number {
    return Intl.message(
      'Phone number',
      name: 'phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Enter your phone number`
  String get phone_number_hint {
    return Intl.message(
      'Enter your phone number',
      name: 'phone_number_hint',
      desc: '',
      args: [],
    );
  }

  /// `Phone number is required`
  String get phone_number_required {
    return Intl.message(
      'Phone number is required',
      name: 'phone_number_required',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  /// `Enter your location`
  String get location_hint {
    return Intl.message(
      'Enter your location',
      name: 'location_hint',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `Enter your address`
  String get address_hint {
    return Intl.message(
      'Enter your address',
      name: 'address_hint',
      desc: '',
      args: [],
    );
  }

  /// `Images`
  String get images {
    return Intl.message(
      'Images',
      name: 'images',
      desc: '',
      args: [],
    );
  }

  /// `optional`
  String get images_optional {
    return Intl.message(
      'optional',
      name: 'images_optional',
      desc: '',
      args: [],
    );
  }

  /// `Add images`
  String get images_hint {
    return Intl.message(
      'Add images',
      name: 'images_hint',
      desc: '',
      args: [],
    );
  }

  /// `Add photo`
  String get add_photo {
    return Intl.message(
      'Add photo',
      name: 'add_photo',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message(
      'Price',
      name: 'price',
      desc: '',
      args: [],
    );
  }

  /// `Enter price`
  String get price_hint {
    return Intl.message(
      'Enter price',
      name: 'price_hint',
      desc: '',
      args: [],
    );
  }

  /// `Price is required`
  String get price_required {
    return Intl.message(
      'Price is required',
      name: 'price_required',
      desc: '',
      args: [],
    );
  }

  /// `Max price`
  String get max_price {
    return Intl.message(
      'Max price',
      name: 'max_price',
      desc: '',
      args: [],
    );
  }

  /// `Max price is required`
  String get max_price_required {
    return Intl.message(
      'Max price is required',
      name: 'max_price_required',
      desc: '',
      args: [],
    );
  }

  /// `Negotiable`
  String get negotiable {
    return Intl.message(
      'Negotiable',
      name: 'negotiable',
      desc: '',
      args: [],
    );
  }

  /// `Fixed`
  String get fixed {
    return Intl.message(
      'Fixed',
      name: 'fixed',
      desc: '',
      args: [],
    );
  }

  /// `Volume / Quantity`
  String get volume_quantity {
    return Intl.message(
      'Volume / Quantity',
      name: 'volume_quantity',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message(
      'Quantity',
      name: 'quantity',
      desc: '',
      args: [],
    );
  }

  /// `Max quantity`
  String get max_quantity {
    return Intl.message(
      'Max quantity',
      name: 'max_quantity',
      desc: '',
      args: [],
    );
  }

  /// `Enter max quantity`
  String get max_quantity_hint {
    return Intl.message(
      'Enter max quantity',
      name: 'max_quantity_hint',
      desc: '',
      args: [],
    );
  }

  /// `Max quantity is required`
  String get max_quantity_required {
    return Intl.message(
      'Max quantity is required',
      name: 'max_quantity_required',
      desc: '',
      args: [],
    );
  }

  /// `Quantity is required`
  String get quantity_required {
    return Intl.message(
      'Quantity is required',
      name: 'quantity_required',
      desc: '',
      args: [],
    );
  }

  /// `Enter quantity`
  String get quantity_hint {
    return Intl.message(
      'Enter quantity',
      name: 'quantity_hint',
      desc: '',
      args: [],
    );
  }

  /// `Condition`
  String get condition {
    return Intl.message(
      'Condition',
      name: 'condition',
      desc: '',
      args: [],
    );
  }

  /// `Year of release`
  String get year_of_release {
    return Intl.message(
      'Year of release',
      name: 'year_of_release',
      desc: '',
      args: [],
    );
  }

  /// `Region`
  String get region {
    return Intl.message(
      'Region',
      name: 'region',
      desc: '',
      args: [],
    );
  }

  /// `Region is required`
  String get region_required {
    return Intl.message(
      'Region is required',
      name: 'region_required',
      desc: '',
      args: [],
    );
  }

  /// `District`
  String get district {
    return Intl.message(
      'District',
      name: 'district',
      desc: '',
      args: [],
    );
  }

  /// `District is required`
  String get district_required {
    return Intl.message(
      'District is required',
      name: 'district_required',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get condition_new {
    return Intl.message(
      'New',
      name: 'condition_new',
      desc: '',
      args: [],
    );
  }

  /// `Used`
  String get condition_used {
    return Intl.message(
      'Used',
      name: 'condition_used',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get from {
    return Intl.message(
      'From',
      name: 'from',
      desc: '',
      args: [],
    );
  }

  /// `To`
  String get to {
    return Intl.message(
      'To',
      name: 'to',
      desc: '',
      args: [],
    );
  }

  /// `Price per unit`
  String get price_per_unit {
    return Intl.message(
      'Price per unit',
      name: 'price_per_unit',
      desc: '',
      args: [],
    );
  }

  /// `Company`
  String get company {
    return Intl.message(
      'Company',
      name: 'company',
      desc: '',
      args: [],
    );
  }

  /// `Company is required`
  String get company_required {
    return Intl.message(
      'Company is required',
      name: 'company_required',
      desc: '',
      args: [],
    );
  }

  /// `Example: TOO 'WWW'`
  String get company_hint {
    return Intl.message(
      'Example: TOO \'WWW\'',
      name: 'company_hint',
      desc: '',
      args: [],
    );
  }

  /// `Contact person`
  String get contact_person {
    return Intl.message(
      'Contact person',
      name: 'contact_person',
      desc: '',
      args: [],
    );
  }

  /// `Contact person is required`
  String get contact_person_required {
    return Intl.message(
      'Contact person is required',
      name: 'contact_person_required',
      desc: '',
      args: [],
    );
  }

  /// `Example: John Doe`
  String get contact_person_hint {
    return Intl.message(
      'Example: John Doe',
      name: 'contact_person_hint',
      desc: '',
      args: [],
    );
  }

  /// `kg`
  String get unit_kg {
    return Intl.message(
      'kg',
      name: 'unit_kg',
      desc: '',
      args: [],
    );
  }

  /// `ton`
  String get unit_ton {
    return Intl.message(
      'ton',
      name: 'unit_ton',
      desc: '',
      args: [],
    );
  }

  /// `Unit`
  String get unit {
    return Intl.message(
      'Unit',
      name: 'unit',
      desc: '',
      args: [],
    );
  }

  /// `Your favourites ads`
  String get favourites_title {
    return Intl.message(
      'Your favourites ads',
      name: 'favourites_title',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any favourites ads yet`
  String get favourites_empty {
    return Intl.message(
      'You don\'t have any favourites ads yet',
      name: 'favourites_empty',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get nav_home {
    return Intl.message(
      'Home',
      name: 'nav_home',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get nav_add {
    return Intl.message(
      'Add',
      name: 'nav_add',
      desc: '',
      args: [],
    );
  }

  /// `Favourites`
  String get nav_favourites {
    return Intl.message(
      'Favourites',
      name: 'nav_favourites',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get nav_profile {
    return Intl.message(
      'Profile',
      name: 'nav_profile',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile_title {
    return Intl.message(
      'Profile',
      name: 'profile_title',
      desc: '',
      args: [],
    );
  }

  /// `Edit profile`
  String get edit_profile {
    return Intl.message(
      'Edit profile',
      name: 'edit_profile',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `My ads`
  String get my_ads {
    return Intl.message(
      'My ads',
      name: 'my_ads',
      desc: '',
      args: [],
    );
  }

  /// `Terms and conditions`
  String get terms_and_conditions {
    return Intl.message(
      'Terms and conditions',
      name: 'terms_and_conditions',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logout {
    return Intl.message(
      'Log out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Your ads`
  String get my_ads_title {
    return Intl.message(
      'Your ads',
      name: 'my_ads_title',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any ads yet`
  String get my_ads_empty {
    return Intl.message(
      'You don\'t have any ads yet',
      name: 'my_ads_empty',
      desc: '',
      args: [],
    );
  }

  /// `Create Advert`
  String get create_advert {
    return Intl.message(
      'Create Advert',
      name: 'create_advert',
      desc: '',
      args: [],
    );
  }

  /// `NEW!`
  String get label_new_advert {
    return Intl.message(
      'NEW!',
      name: 'label_new_advert',
      desc: '',
      args: [],
    );
  }

  /// `Please login to create an advert`
  String get add_anonymous_window {
    return Intl.message(
      'Please login to create an advert',
      name: 'add_anonymous_window',
      desc: '',
      args: [],
    );
  }

  /// `Please login to edit your profile`
  String get edit_anonymous_window {
    return Intl.message(
      'Please login to edit your profile',
      name: 'edit_anonymous_window',
      desc: '',
      args: [],
    );
  }

  /// `Please login to view your favourites ads`
  String get favourites_anonymous_window {
    return Intl.message(
      'Please login to view your favourites ads',
      name: 'favourites_anonymous_window',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get default_sorting {
    return Intl.message(
      'Default',
      name: 'default_sorting',
      desc: '',
      args: [],
    );
  }

  /// `Cheapest first`
  String get cheapest_first {
    return Intl.message(
      'Cheapest first',
      name: 'cheapest_first',
      desc: '',
      args: [],
    );
  }

  /// `Most expensive first`
  String get most_expensive_first {
    return Intl.message(
      'Most expensive first',
      name: 'most_expensive_first',
      desc: '',
      args: [],
    );
  }

  /// `Newest first`
  String get newest_first {
    return Intl.message(
      'Newest first',
      name: 'newest_first',
      desc: '',
      args: [],
    );
  }

  /// `Oldest first`
  String get oldest_first {
    return Intl.message(
      'Oldest first',
      name: 'oldest_first',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in all required fields`
  String get fill_all_fields {
    return Intl.message(
      'Please fill in all required fields',
      name: 'fill_all_fields',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: '',
      args: [],
    );
  }

  /// `Item details`
  String get item_details {
    return Intl.message(
      'Item details',
      name: 'item_details',
      desc: '',
      args: [],
    );
  }

  /// `Likes`
  String get likes {
    return Intl.message(
      'Likes',
      name: 'likes',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'kk'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
