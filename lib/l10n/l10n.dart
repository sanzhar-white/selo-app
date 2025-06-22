import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_kk.dart';
import 'l10n_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n? of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @language_code.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get language_code;

  /// No description provided for @language_display_code.
  ///
  /// In en, this message translates to:
  /// **'ENG'**
  String get language_display_code;

  /// No description provided for @language_title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_title;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Complete quick registration\nand find clients today'**
  String get greeting;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @signin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signin;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Selo'**
  String get welcome;

  /// No description provided for @withoutregistor.
  ///
  /// In en, this message translates to:
  /// **'Continue without registration'**
  String get withoutregistor;

  /// No description provided for @error_verification.
  ///
  /// In en, this message translates to:
  /// **'Error during verification'**
  String get error_verification;

  /// No description provided for @nav_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get nav_add;

  /// No description provided for @nav_favourites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get nav_favourites;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @all_ads.
  ///
  /// In en, this message translates to:
  /// **'All ads'**
  String get all_ads;

  /// No description provided for @all_categories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get all_categories;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @no_ads_found.
  ///
  /// In en, this message translates to:
  /// **'No ads found'**
  String get no_ads_found;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search in Kazakhstan'**
  String get search_hint;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sort_by.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sort_by;

  /// No description provided for @sort_by_price_from.
  ///
  /// In en, this message translates to:
  /// **'Price from'**
  String get sort_by_price_from;

  /// No description provided for @sort_by_price_to.
  ///
  /// In en, this message translates to:
  /// **'Price to'**
  String get sort_by_price_to;

  /// No description provided for @default_sorting.
  ///
  /// In en, this message translates to:
  /// **'Default sorting'**
  String get default_sorting;

  /// No description provided for @newest_first.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest_first;

  /// No description provided for @oldest_first.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest_first;

  /// No description provided for @cheapest_first.
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get cheapest_first;

  /// No description provided for @most_expensive_first.
  ///
  /// In en, this message translates to:
  /// **'Most expensive'**
  String get most_expensive_first;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixed;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @max_price.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get max_price;

  /// No description provided for @max_price_required.
  ///
  /// In en, this message translates to:
  /// **'Max price is required'**
  String get max_price_required;

  /// No description provided for @negotiable.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get negotiable;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @price_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the price'**
  String get price_hint;

  /// No description provided for @price_per_unit.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get price_per_unit;

  /// No description provided for @price_range.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get price_range;

  /// No description provided for @price_required.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get price_required;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @trade_not_possible.
  ///
  /// In en, this message translates to:
  /// **'Exchange not possible'**
  String get trade_not_possible;

  /// No description provided for @trade_possible.
  ///
  /// In en, this message translates to:
  /// **'Exchange possible'**
  String get trade_possible;

  /// No description provided for @add_appbar_pick_category.
  ///
  /// In en, this message translates to:
  /// **'Select ad category'**
  String get add_appbar_pick_category;

  /// No description provided for @add_appbar_title.
  ///
  /// In en, this message translates to:
  /// **'Create a new ad'**
  String get add_appbar_title;

  /// No description provided for @create_advert.
  ///
  /// In en, this message translates to:
  /// **'Create ad'**
  String get create_advert;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @description_hint.
  ///
  /// In en, this message translates to:
  /// **'Describe your ad in detail'**
  String get description_hint;

  /// No description provided for @description_required.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get description_required;

  /// No description provided for @label_new_advert.
  ///
  /// In en, this message translates to:
  /// **'NEW!'**
  String get label_new_advert;

  /// No description provided for @title_of_ad.
  ///
  /// In en, this message translates to:
  /// **'Ad title'**
  String get title_of_ad;

  /// No description provided for @title_of_ad_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the title of the ad'**
  String get title_of_ad_hint;

  /// No description provided for @title_of_ad_required.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get title_of_ad_required;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @address_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get address_hint;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @company_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: LLP \'WWW\''**
  String get company_hint;

  /// No description provided for @company_required.
  ///
  /// In en, this message translates to:
  /// **'Company is required'**
  String get company_required;

  /// No description provided for @contact_person.
  ///
  /// In en, this message translates to:
  /// **'Contact person'**
  String get contact_person;

  /// No description provided for @contact_person_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: John Doe'**
  String get contact_person_hint;

  /// No description provided for @contact_person_required.
  ///
  /// In en, this message translates to:
  /// **'Contact person is required'**
  String get contact_person_required;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @district_required.
  ///
  /// In en, this message translates to:
  /// **'District is required'**
  String get district_required;

  /// No description provided for @district_select.
  ///
  /// In en, this message translates to:
  /// **'Select district'**
  String get district_select;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @location_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your location'**
  String get location_hint;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone_number;

  /// No description provided for @phone_number_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phone_number_hint;

  /// No description provided for @phone_number_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get phone_number_invalid;

  /// No description provided for @phone_number_required.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phone_number_required;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @region_required.
  ///
  /// In en, this message translates to:
  /// **'Region is required'**
  String get region_required;

  /// No description provided for @region_select.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get region_select;

  /// No description provided for @your_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get your_phone_number;

  /// No description provided for @add_photo.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get add_photo;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @image_picker_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get image_picker_error;

  /// No description provided for @image_upload_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get image_upload_error;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @images_hint.
  ///
  /// In en, this message translates to:
  /// **'Add images'**
  String get images_hint;

  /// No description provided for @images_optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get images_optional;

  /// No description provided for @select_image_source.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get select_image_source;

  /// No description provided for @image_less_size.
  ///
  /// In en, this message translates to:
  /// **'Image size should be less than 25MB'**
  String get image_less_size;

  /// No description provided for @max_images.
  ///
  /// In en, this message translates to:
  /// **'Maximum 10 images allowed'**
  String get max_images;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @condition_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get condition_new;

  /// No description provided for @condition_used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get condition_used;

  /// No description provided for @max_quantity.
  ///
  /// In en, this message translates to:
  /// **'Max quantity'**
  String get max_quantity;

  /// No description provided for @max_quantity_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter max quantity'**
  String get max_quantity_hint;

  /// No description provided for @max_quantity_required.
  ///
  /// In en, this message translates to:
  /// **'Max quantity is required'**
  String get max_quantity_required;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantity_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get quantity_hint;

  /// No description provided for @quantity_required.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get quantity_required;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @unit_kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unit_kg;

  /// No description provided for @unit_ton.
  ///
  /// In en, this message translates to:
  /// **'ton'**
  String get unit_ton;

  /// No description provided for @volume_quantity.
  ///
  /// In en, this message translates to:
  /// **'Volume / Quantity'**
  String get volume_quantity;

  /// No description provided for @year_of_release.
  ///
  /// In en, this message translates to:
  /// **'Year of release'**
  String get year_of_release;

  /// No description provided for @change_profile_photo.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get change_profile_photo;

  /// No description provided for @change_saved.
  ///
  /// In en, this message translates to:
  /// **'The changes have been successfully saved'**
  String get change_saved;

  /// No description provided for @lastname.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastname;

  /// No description provided for @lastname_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your lastname'**
  String get lastname_hint;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get name_hint;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_update_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profile_update_error;

  /// No description provided for @favourites_anonymous_window.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view your favorite ads'**
  String get favourites_anonymous_window;

  /// No description provided for @favourites_empty.
  ///
  /// In en, this message translates to:
  /// **'You have no favorite ads yet'**
  String get favourites_empty;

  /// No description provided for @favourites_title.
  ///
  /// In en, this message translates to:
  /// **'Your favorite ads'**
  String get favourites_title;

  /// No description provided for @my_ads.
  ///
  /// In en, this message translates to:
  /// **'My ads'**
  String get my_ads;

  /// No description provided for @my_ads_empty.
  ///
  /// In en, this message translates to:
  /// **'You have no ads yet'**
  String get my_ads_empty;

  /// No description provided for @my_ads_title.
  ///
  /// In en, this message translates to:
  /// **'Your ads'**
  String get my_ads_title;

  /// No description provided for @account_deleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get account_deleted;

  /// No description provided for @anonymous_user.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get anonymous_user;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get delete_account;

  /// No description provided for @delete_account_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the account?'**
  String get delete_account_confirmation;

  /// No description provided for @logged_out.
  ///
  /// In en, this message translates to:
  /// **'Logged out'**
  String get logged_out;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms_and_conditions;

  /// No description provided for @add_anonymous_window.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to create an ad'**
  String get add_anonymous_window;

  /// No description provided for @edit_anonymous_window.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to edit your profile'**
  String get edit_anonymous_window;

  /// No description provided for @no_phone_number.
  ///
  /// In en, this message translates to:
  /// **'+7 (XXX) XXX XXXX'**
  String get no_phone_number;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get edit_profile;

  /// No description provided for @fill_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get fill_all_fields;

  /// No description provided for @item_details.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get item_details;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @no_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'no_internet_connection'**
  String get no_internet_connection;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @advertisement_created.
  ///
  /// In en, this message translates to:
  /// **'Advertisement created successfully'**
  String get advertisement_created;

  /// No description provided for @failed_to_created_advertisement.
  ///
  /// In en, this message translates to:
  /// **'Failed to create advertisement'**
  String get failed_to_created_advertisement;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'kk':
      return L10nKk();
    case 'ru':
      return L10nRu();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
