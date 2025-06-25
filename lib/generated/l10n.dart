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

  /// `en`
  String get language_code {
    return Intl.message(
      'en',
      name: 'language_code',
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

  /// `Continue`
  String get continue_ {
    return Intl.message(
      'Continue',
      name: 'continue_',
      desc: '',
      args: [],
    );
  }

  /// `Complete quick registration\nand find clients today`
  String get greeting {
    return Intl.message(
      'Complete quick registration\nand find clients today',
      name: 'greeting',
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

  /// `Sign in`
  String get signin {
    return Intl.message(
      'Sign in',
      name: 'signin',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Selo`
  String get welcome {
    return Intl.message(
      'Welcome to Selo',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Continue without registration`
  String get withoutregistor {
    return Intl.message(
      'Continue without registration',
      name: 'withoutregistor',
      desc: '',
      args: [],
    );
  }

  /// `Error during verification`
  String get error_verification {
    return Intl.message(
      'Error during verification',
      name: 'error_verification',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get nav_create {
    return Intl.message(
      'Create',
      name: 'nav_create',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get nav_favourites {
    return Intl.message(
      'Favorites',
      name: 'nav_favourites',
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

  /// `Profile`
  String get nav_profile {
    return Intl.message(
      'Profile',
      name: 'nav_profile',
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

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
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

  /// `Default sorting`
  String get default_sorting {
    return Intl.message(
      'Default sorting',
      name: 'default_sorting',
      desc: '',
      args: [],
    );
  }

  /// `Newest`
  String get newest_first {
    return Intl.message(
      'Newest',
      name: 'newest_first',
      desc: '',
      args: [],
    );
  }

  /// `Oldest`
  String get oldest_first {
    return Intl.message(
      'Oldest',
      name: 'oldest_first',
      desc: '',
      args: [],
    );
  }

  /// `Cheapest`
  String get cheapest_first {
    return Intl.message(
      'Cheapest',
      name: 'cheapest_first',
      desc: '',
      args: [],
    );
  }

  /// `Most expensive`
  String get most_expensive_first {
    return Intl.message(
      'Most expensive',
      name: 'most_expensive_first',
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

  /// `Fixed`
  String get fixed {
    return Intl.message(
      'Fixed',
      name: 'fixed',
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

  /// `Price`
  String get price {
    return Intl.message(
      'Price',
      name: 'price',
      desc: '',
      args: [],
    );
  }

  /// `Enter the price`
  String get price_hint {
    return Intl.message(
      'Enter the price',
      name: 'price_hint',
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

  /// `Price range`
  String get price_range {
    return Intl.message(
      'Price range',
      name: 'price_range',
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

  /// `Salary`
  String get salary {
    return Intl.message(
      'Salary',
      name: 'salary',
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

  /// `Exchange not possible`
  String get trade_not_possible {
    return Intl.message(
      'Exchange not possible',
      name: 'trade_not_possible',
      desc: '',
      args: [],
    );
  }

  /// `Exchange possible`
  String get trade_possible {
    return Intl.message(
      'Exchange possible',
      name: 'trade_possible',
      desc: '',
      args: [],
    );
  }

  /// `Select ad category`
  String get add_appbar_pick_category {
    return Intl.message(
      'Select ad category',
      name: 'add_appbar_pick_category',
      desc: '',
      args: [],
    );
  }

  /// `Create a new ad`
  String get add_appbar_title {
    return Intl.message(
      'Create a new ad',
      name: 'add_appbar_title',
      desc: '',
      args: [],
    );
  }

  /// `Create ad`
  String get create_advert {
    return Intl.message(
      'Create ad',
      name: 'create_advert',
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

  /// `Describe your ad in detail`
  String get description_hint {
    return Intl.message(
      'Describe your ad in detail',
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

  /// `NEW!`
  String get label_new_advert {
    return Intl.message(
      'NEW!',
      name: 'label_new_advert',
      desc: '',
      args: [],
    );
  }

  /// `Ad title`
  String get title_of_ad {
    return Intl.message(
      'Ad title',
      name: 'title_of_ad',
      desc: '',
      args: [],
    );
  }

  /// `Enter the title of the ad`
  String get title_of_ad_hint {
    return Intl.message(
      'Enter the title of the ad',
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

  /// `Company`
  String get company {
    return Intl.message(
      'Company',
      name: 'company',
      desc: '',
      args: [],
    );
  }

  /// `Example: LLP 'WWW'`
  String get company_hint {
    return Intl.message(
      'Example: LLP \'WWW\'',
      name: 'company_hint',
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

  /// `Contact person`
  String get contact_person {
    return Intl.message(
      'Contact person',
      name: 'contact_person',
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

  /// `Contact person is required`
  String get contact_person_required {
    return Intl.message(
      'Contact person is required',
      name: 'contact_person_required',
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

  /// `Select district`
  String get district_select {
    return Intl.message(
      'Select district',
      name: 'district_select',
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

  /// `Invalid phone number`
  String get phone_number_invalid {
    return Intl.message(
      'Invalid phone number',
      name: 'phone_number_invalid',
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

  /// `Select region`
  String get region_select {
    return Intl.message(
      'Select region',
      name: 'region_select',
      desc: '',
      args: [],
    );
  }

  /// `Your phone number`
  String get your_phone_number {
    return Intl.message(
      'Your phone number',
      name: 'your_phone_number',
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

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Failed to pick image`
  String get image_picker_error {
    return Intl.message(
      'Failed to pick image',
      name: 'image_picker_error',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload image`
  String get image_upload_error {
    return Intl.message(
      'Failed to upload image',
      name: 'image_upload_error',
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

  /// `Add images`
  String get images_hint {
    return Intl.message(
      'Add images',
      name: 'images_hint',
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

  /// `Select Image Source`
  String get select_image_source {
    return Intl.message(
      'Select Image Source',
      name: 'select_image_source',
      desc: '',
      args: [],
    );
  }

  /// `Image size should be less than 25MB`
  String get image_less_size {
    return Intl.message(
      'Image size should be less than 25MB',
      name: 'image_less_size',
      desc: '',
      args: [],
    );
  }

  /// `Maximum 10 images allowed`
  String get max_images {
    return Intl.message(
      'Maximum 10 images allowed',
      name: 'max_images',
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

  /// `Quantity`
  String get quantity {
    return Intl.message(
      'Quantity',
      name: 'quantity',
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

  /// `Quantity is required`
  String get quantity_required {
    return Intl.message(
      'Quantity is required',
      name: 'quantity_required',
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

  /// `Volume / Quantity`
  String get volume_quantity {
    return Intl.message(
      'Volume / Quantity',
      name: 'volume_quantity',
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

  /// `Change profile photo`
  String get change_profile_photo {
    return Intl.message(
      'Change profile photo',
      name: 'change_profile_photo',
      desc: '',
      args: [],
    );
  }

  /// `The changes have been successfully saved`
  String get change_saved {
    return Intl.message(
      'The changes have been successfully saved',
      name: 'change_saved',
      desc: '',
      args: [],
    );
  }

  /// `Last name`
  String get lastname {
    return Intl.message(
      'Last name',
      name: 'lastname',
      desc: '',
      args: [],
    );
  }

  /// `Enter your lastname`
  String get lastname_hint {
    return Intl.message(
      'Enter your lastname',
      name: 'lastname_hint',
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

  /// `Enter your name`
  String get name_hint {
    return Intl.message(
      'Enter your name',
      name: 'name_hint',
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

  /// `Failed to update profile`
  String get profile_update_error {
    return Intl.message(
      'Failed to update profile',
      name: 'profile_update_error',
      desc: '',
      args: [],
    );
  }

  /// `Please sign in to view your favorite ads`
  String get favourites_anonymous_window {
    return Intl.message(
      'Please sign in to view your favorite ads',
      name: 'favourites_anonymous_window',
      desc: '',
      args: [],
    );
  }

  /// `You have no favorite ads yet`
  String get favourites_empty {
    return Intl.message(
      'You have no favorite ads yet',
      name: 'favourites_empty',
      desc: '',
      args: [],
    );
  }

  /// `Your favorite ads`
  String get favourites_title {
    return Intl.message(
      'Your favorite ads',
      name: 'favourites_title',
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

  /// `You have no ads yet`
  String get my_ads_empty {
    return Intl.message(
      'You have no ads yet',
      name: 'my_ads_empty',
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

  /// `Account deleted`
  String get account_deleted {
    return Intl.message(
      'Account deleted',
      name: 'account_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Guest`
  String get anonymous_user {
    return Intl.message(
      'Guest',
      name: 'anonymous_user',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get delete_account {
    return Intl.message(
      'Delete account',
      name: 'delete_account',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete the account?`
  String get delete_account_confirmation {
    return Intl.message(
      'Are you sure you want to delete the account?',
      name: 'delete_account_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Logged out`
  String get logged_out {
    return Intl.message(
      'Logged out',
      name: 'logged_out',
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

  /// `Terms and Conditions`
  String get terms_and_conditions {
    return Intl.message(
      'Terms and Conditions',
      name: 'terms_and_conditions',
      desc: '',
      args: [],
    );
  }

  /// `Please sign in to create an ad`
  String get add_anonymous_window {
    return Intl.message(
      'Please sign in to create an ad',
      name: 'add_anonymous_window',
      desc: '',
      args: [],
    );
  }

  /// `Please sign in to edit your profile`
  String get edit_anonymous_window {
    return Intl.message(
      'Please sign in to edit your profile',
      name: 'edit_anonymous_window',
      desc: '',
      args: [],
    );
  }

  /// `+7 (XXX) XXX XXXX`
  String get no_phone_number {
    return Intl.message(
      '+7 (XXX) XXX XXXX',
      name: 'no_phone_number',
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

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
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

  /// `Edit profile`
  String get edit_profile {
    return Intl.message(
      'Edit profile',
      name: 'edit_profile',
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

  /// `Additional information`
  String get item_details {
    return Intl.message(
      'Additional information',
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

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
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

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
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

  /// `no_internet_connection`
  String get no_internet_connection {
    return Intl.message(
      'no_internet_connection',
      name: 'no_internet_connection',
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

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
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

  /// `Views`
  String get views {
    return Intl.message(
      'Views',
      name: 'views',
      desc: '',
      args: [],
    );
  }

  /// `Advertisement created successfully`
  String get advertisement_created {
    return Intl.message(
      'Advertisement created successfully',
      name: 'advertisement_created',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create advertisement`
  String get failed_to_created_advertisement {
    return Intl.message(
      'Failed to create advertisement',
      name: 'failed_to_created_advertisement',
      desc: '',
      args: [],
    );
  }

  /// `Critical error when launching the application`
  String get critical_error_when_launching_app {
    return Intl.message(
      'Critical error when launching the application',
      name: 'critical_error_when_launching_app',
      desc: '',
      args: [],
    );
  }

  /// `Error creating advert`
  String get error_creating_advert {
    return Intl.message(
      'Error creating advert',
      name: 'error_creating_advert',
      desc: '',
      args: [],
    );
  }

  /// `Selected image file not found`
  String get selected_image_file_not_found {
    return Intl.message(
      'Selected image file not found',
      name: 'selected_image_file_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Error selecting image`
  String get error_selecting_image {
    return Intl.message(
      'Error selecting image',
      name: 'error_selecting_image',
      desc: '',
      args: [],
    );
  }

  /// `Failed to log in anonymously`
  String get failed_to_log_in_anonymously {
    return Intl.message(
      'Failed to log in anonymously',
      name: 'failed_to_log_in_anonymously',
      desc: '',
      args: [],
    );
  }

  /// `Code resent`
  String get code_resent {
    return Intl.message(
      'Code resent',
      name: 'code_resent',
      desc: '',
      args: [],
    );
  }

  /// `Verification failed - please check the code and try again`
  String get verification_failed {
    return Intl.message(
      'Verification failed - please check the code and try again',
      name: 'verification_failed',
      desc: '',
      args: [],
    );
  }

  /// `Verification error`
  String get verification_error {
    return Intl.message(
      'Verification error',
      name: 'verification_error',
      desc: '',
      args: [],
    );
  }

  /// `Invalid code entered`
  String get invalid_code_entered {
    return Intl.message(
      'Invalid code entered',
      name: 'invalid_code_entered',
      desc: '',
      args: [],
    );
  }

  /// `Error during verification`
  String get error_during_verification {
    return Intl.message(
      'Error during verification',
      name: 'error_during_verification',
      desc: '',
      args: [],
    );
  }

  /// `Enter verification code`
  String get enter_verification_code {
    return Intl.message(
      'Enter verification code',
      name: 'enter_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `Enter the 6-digit code sent to your phone`
  String get enter_code_sent_to_your_phone {
    return Intl.message(
      'Enter the 6-digit code sent to your phone',
      name: 'enter_code_sent_to_your_phone',
      desc: '',
      args: [],
    );
  }

  /// `Resend Code`
  String get resend_code {
    return Intl.message(
      'Resend Code',
      name: 'resend_code',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message(
      'Verify',
      name: 'verify',
      desc: '',
      args: [],
    );
  }

  /// `Share functionality coming soon!`
  String get share_functionality_coming_soon {
    return Intl.message(
      'Share functionality coming soon!',
      name: 'share_functionality_coming_soon',
      desc: '',
      args: [],
    );
  }

  /// `Show less`
  String get show_less {
    return Intl.message(
      'Show less',
      name: 'show_less',
      desc: '',
      args: [],
    );
  }

  /// `Show more`
  String get show_more {
    return Intl.message(
      'Show more',
      name: 'show_more',
      desc: '',
      args: [],
    );
  }

  /// `Verification code resent successfully`
  String get code_resent_success {
    return Intl.message(
      'Verification code resent successfully',
      name: 'code_resent_success',
      desc: '',
      args: [],
    );
  }

  /// `Failed to resend verification code`
  String get code_resent_error {
    return Intl.message(
      'Failed to resend verification code',
      name: 'code_resent_error',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the verification code`
  String get otp_empty_error {
    return Intl.message(
      'Please enter the verification code',
      name: 'otp_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `Verification successful!`
  String get otp_verification_success {
    return Intl.message(
      'Verification successful!',
      name: 'otp_verification_success',
      desc: '',
      args: [],
    );
  }

  /// `Verification failed. Please try again.`
  String get otp_verification_failed {
    return Intl.message(
      'Verification failed. Please try again.',
      name: 'otp_verification_failed',
      desc: '',
      args: [],
    );
  }

  /// `Error resending code`
  String get resend_code_error {
    return Intl.message(
      'Error resending code',
      name: 'resend_code_error',
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
