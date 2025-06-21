import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_kk.dart';
import 'l10n_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
  /// In ru, this message translates to:
  /// **'Русский'**
  String get language;

  /// No description provided for @language_code.
  ///
  /// In ru, this message translates to:
  /// **'ru'**
  String get language_code;

  /// No description provided for @language_display_code.
  ///
  /// In ru, this message translates to:
  /// **'RUS'**
  String get language_display_code;

  /// No description provided for @language_title.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language_title;

  /// No description provided for @theme_light.
  ///
  /// In ru, this message translates to:
  /// **'Светлая тема'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная тема'**
  String get theme_dark;

  /// No description provided for @continue_.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continue_;

  /// No description provided for @greeting.
  ///
  /// In ru, this message translates to:
  /// **'Пройди быструю регистрацию\nи начинай находить клиентов уже сегодня'**
  String get greeting;

  /// No description provided for @login.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get register;

  /// No description provided for @signin.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signin;

  /// No description provided for @welcome.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать в Selo'**
  String get welcome;

  /// No description provided for @withoutregistor.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить без регистрации'**
  String get withoutregistor;

  /// No description provided for @error_verification.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка во время проверки'**
  String get error_verification;

  /// No description provided for @nav_add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get nav_add;

  /// No description provided for @nav_favourites.
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get nav_favourites;

  /// No description provided for @nav_home.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get nav_home;

  /// No description provided for @nav_profile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get nav_profile;

  /// No description provided for @all_ads.
  ///
  /// In ru, this message translates to:
  /// **'Все объявления'**
  String get all_ads;

  /// No description provided for @all_categories.
  ///
  /// In ru, this message translates to:
  /// **'Все категории'**
  String get all_categories;

  /// No description provided for @category.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get category;

  /// No description provided for @no_ads_found.
  ///
  /// In ru, this message translates to:
  /// **'Объявлений не найдено'**
  String get no_ads_found;

  /// No description provided for @search_hint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по Казахстану'**
  String get search_hint;

  /// No description provided for @sort.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get sort;

  /// No description provided for @sort_by.
  ///
  /// In ru, this message translates to:
  /// **'Сортировать по'**
  String get sort_by;

  /// No description provided for @sort_by_price_from.
  ///
  /// In ru, this message translates to:
  /// **'Цена от'**
  String get sort_by_price_from;

  /// No description provided for @sort_by_price_to.
  ///
  /// In ru, this message translates to:
  /// **'Цена до'**
  String get sort_by_price_to;

  /// No description provided for @default_sorting.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию'**
  String get default_sorting;

  /// No description provided for @newest_first.
  ///
  /// In ru, this message translates to:
  /// **'Сначала новые'**
  String get newest_first;

  /// No description provided for @oldest_first.
  ///
  /// In ru, this message translates to:
  /// **'Сначала старые'**
  String get oldest_first;

  /// No description provided for @cheapest_first.
  ///
  /// In ru, this message translates to:
  /// **'Сначала дешёвые'**
  String get cheapest_first;

  /// No description provided for @most_expensive_first.
  ///
  /// In ru, this message translates to:
  /// **'Сначала дорогие'**
  String get most_expensive_first;

  /// No description provided for @filter.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр'**
  String get filter;

  /// No description provided for @fixed.
  ///
  /// In ru, this message translates to:
  /// **'Фиксированная'**
  String get fixed;

  /// No description provided for @from.
  ///
  /// In ru, this message translates to:
  /// **'От'**
  String get from;

  /// No description provided for @max_price.
  ///
  /// In ru, this message translates to:
  /// **'Максимальная цена'**
  String get max_price;

  /// No description provided for @max_price_required.
  ///
  /// In ru, this message translates to:
  /// **'Укажи максимальную цену'**
  String get max_price_required;

  /// No description provided for @negotiable.
  ///
  /// In ru, this message translates to:
  /// **'Договорная'**
  String get negotiable;

  /// No description provided for @price.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get price;

  /// No description provided for @price_hint.
  ///
  /// In ru, this message translates to:
  /// **'Укажи цену'**
  String get price_hint;

  /// No description provided for @price_per_unit.
  ///
  /// In ru, this message translates to:
  /// **'Цена за единицу'**
  String get price_per_unit;

  /// No description provided for @price_range.
  ///
  /// In ru, this message translates to:
  /// **'Диапазон цен'**
  String get price_range;

  /// No description provided for @price_required.
  ///
  /// In ru, this message translates to:
  /// **'Цена обязательна'**
  String get price_required;

  /// No description provided for @salary.
  ///
  /// In ru, this message translates to:
  /// **'Зарплата'**
  String get salary;

  /// No description provided for @to.
  ///
  /// In ru, this message translates to:
  /// **'До'**
  String get to;

  /// No description provided for @trade_not_possible.
  ///
  /// In ru, this message translates to:
  /// **'Обмен невозможен'**
  String get trade_not_possible;

  /// No description provided for @trade_possible.
  ///
  /// In ru, this message translates to:
  /// **'Обмен возможен'**
  String get trade_possible;

  /// No description provided for @add_appbar_pick_category.
  ///
  /// In ru, this message translates to:
  /// **'Выбери категорию'**
  String get add_appbar_pick_category;

  /// No description provided for @add_appbar_title.
  ///
  /// In ru, this message translates to:
  /// **'Новое объявление'**
  String get add_appbar_title;

  /// No description provided for @create_advert.
  ///
  /// In ru, this message translates to:
  /// **'Создать объявление'**
  String get create_advert;

  /// No description provided for @description.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get description;

  /// No description provided for @description_hint.
  ///
  /// In ru, this message translates to:
  /// **'Подробно опиши объявление'**
  String get description_hint;

  /// No description provided for @description_required.
  ///
  /// In ru, this message translates to:
  /// **'Описание обязательно'**
  String get description_required;

  /// No description provided for @label_new_advert.
  ///
  /// In ru, this message translates to:
  /// **'НОВОЕ!'**
  String get label_new_advert;

  /// No description provided for @title_of_ad.
  ///
  /// In ru, this message translates to:
  /// **'Заголовок'**
  String get title_of_ad;

  /// No description provided for @title_of_ad_hint.
  ///
  /// In ru, this message translates to:
  /// **'Введи заголовок'**
  String get title_of_ad_hint;

  /// No description provided for @title_of_ad_required.
  ///
  /// In ru, this message translates to:
  /// **'Заголовок обязателен'**
  String get title_of_ad_required;

  /// No description provided for @address.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get address;

  /// No description provided for @address_hint.
  ///
  /// In ru, this message translates to:
  /// **'Введи адрес'**
  String get address_hint;

  /// No description provided for @company.
  ///
  /// In ru, this message translates to:
  /// **'Компания'**
  String get company;

  /// No description provided for @company_hint.
  ///
  /// In ru, this message translates to:
  /// **'Пример: ТОО \'WWW\''**
  String get company_hint;

  /// No description provided for @company_required.
  ///
  /// In ru, this message translates to:
  /// **'Укажи компанию'**
  String get company_required;

  /// No description provided for @contact_person.
  ///
  /// In ru, this message translates to:
  /// **'Контактное лицо'**
  String get contact_person;

  /// No description provided for @contact_person_hint.
  ///
  /// In ru, this message translates to:
  /// **'Пример: Иван Иванов'**
  String get contact_person_hint;

  /// No description provided for @contact_person_required.
  ///
  /// In ru, this message translates to:
  /// **'Контакт обязателен'**
  String get contact_person_required;

  /// No description provided for @district.
  ///
  /// In ru, this message translates to:
  /// **'Район'**
  String get district;

  /// No description provided for @district_required.
  ///
  /// In ru, this message translates to:
  /// **'Укажи район'**
  String get district_required;

  /// No description provided for @district_select.
  ///
  /// In ru, this message translates to:
  /// **'Выбери район'**
  String get district_select;

  /// No description provided for @location.
  ///
  /// In ru, this message translates to:
  /// **'Местоположение'**
  String get location;

  /// No description provided for @location_hint.
  ///
  /// In ru, this message translates to:
  /// **'Укажи местоположение'**
  String get location_hint;

  /// No description provided for @phone_number.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get phone_number;

  /// No description provided for @phone_number_hint.
  ///
  /// In ru, this message translates to:
  /// **'Введи номер'**
  String get phone_number_hint;

  /// No description provided for @phone_number_invalid.
  ///
  /// In ru, this message translates to:
  /// **'Неверный номер'**
  String get phone_number_invalid;

  /// No description provided for @phone_number_required.
  ///
  /// In ru, this message translates to:
  /// **'Номер обязателен'**
  String get phone_number_required;

  /// No description provided for @region.
  ///
  /// In ru, this message translates to:
  /// **'Регион'**
  String get region;

  /// No description provided for @region_required.
  ///
  /// In ru, this message translates to:
  /// **'Регион обязателен'**
  String get region_required;

  /// No description provided for @region_select.
  ///
  /// In ru, this message translates to:
  /// **'Выбери регион'**
  String get region_select;

  /// No description provided for @your_phone_number.
  ///
  /// In ru, this message translates to:
  /// **'Твой номер телефона'**
  String get your_phone_number;

  /// No description provided for @add_photo.
  ///
  /// In ru, this message translates to:
  /// **'Добавить фото'**
  String get add_photo;

  /// No description provided for @gallery.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get camera;

  /// No description provided for @image_picker_error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка при выборе фото'**
  String get image_picker_error;

  /// No description provided for @image_upload_error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки фото'**
  String get image_upload_error;

  /// No description provided for @images.
  ///
  /// In ru, this message translates to:
  /// **'Фотографии'**
  String get images;

  /// No description provided for @images_hint.
  ///
  /// In ru, this message translates to:
  /// **'Добавь фото'**
  String get images_hint;

  /// No description provided for @images_optional.
  ///
  /// In ru, this message translates to:
  /// **'необязательно'**
  String get images_optional;

  /// No description provided for @select_image_source.
  ///
  /// In ru, this message translates to:
  /// **'Выбери источник'**
  String get select_image_source;

  /// No description provided for @image_less_size.
  ///
  /// In ru, this message translates to:
  /// **'Размер до 25 МБ'**
  String get image_less_size;

  /// No description provided for @max_images.
  ///
  /// In ru, this message translates to:
  /// **'Максимум 10 фото'**
  String get max_images;

  /// No description provided for @condition.
  ///
  /// In ru, this message translates to:
  /// **'Состояние'**
  String get condition;

  /// No description provided for @condition_new.
  ///
  /// In ru, this message translates to:
  /// **'Новое'**
  String get condition_new;

  /// No description provided for @condition_used.
  ///
  /// In ru, this message translates to:
  /// **'Б/у'**
  String get condition_used;

  /// No description provided for @max_quantity.
  ///
  /// In ru, this message translates to:
  /// **'Макс. количество'**
  String get max_quantity;

  /// No description provided for @max_quantity_hint.
  ///
  /// In ru, this message translates to:
  /// **'Введи максимум'**
  String get max_quantity_hint;

  /// No description provided for @max_quantity_required.
  ///
  /// In ru, this message translates to:
  /// **'Укажи макс. количество'**
  String get max_quantity_required;

  /// No description provided for @quantity.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get quantity;

  /// No description provided for @quantity_hint.
  ///
  /// In ru, this message translates to:
  /// **'Введи количество'**
  String get quantity_hint;

  /// No description provided for @quantity_required.
  ///
  /// In ru, this message translates to:
  /// **'Укажи количество'**
  String get quantity_required;

  /// No description provided for @unit.
  ///
  /// In ru, this message translates to:
  /// **'Единица'**
  String get unit;

  /// No description provided for @unit_kg.
  ///
  /// In ru, this message translates to:
  /// **'кг'**
  String get unit_kg;

  /// No description provided for @unit_ton.
  ///
  /// In ru, this message translates to:
  /// **'тонна'**
  String get unit_ton;

  /// No description provided for @volume_quantity.
  ///
  /// In ru, this message translates to:
  /// **'Объём / Кол-во'**
  String get volume_quantity;

  /// No description provided for @year_of_release.
  ///
  /// In ru, this message translates to:
  /// **'Год выпуска'**
  String get year_of_release;

  /// No description provided for @change_profile_photo.
  ///
  /// In ru, this message translates to:
  /// **'Сменить фото профиля'**
  String get change_profile_photo;

  /// No description provided for @change_saved.
  ///
  /// In ru, this message translates to:
  /// **'Изменения сохранены'**
  String get change_saved;

  /// No description provided for @lastname.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия'**
  String get lastname;

  /// No description provided for @lastname_hint.
  ///
  /// In ru, this message translates to:
  /// **'Введи фамилию'**
  String get lastname_hint;

  /// No description provided for @name.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get name;

  /// No description provided for @name_hint.
  ///
  /// In ru, this message translates to:
  /// **'Введи имя'**
  String get name_hint;

  /// No description provided for @profile_title.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile_title;

  /// No description provided for @profile_update_error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка обновления профиля'**
  String get profile_update_error;

  /// No description provided for @favourites_anonymous_window.
  ///
  /// In ru, this message translates to:
  /// **'Войди, чтобы видеть избранное'**
  String get favourites_anonymous_window;

  /// No description provided for @favourites_empty.
  ///
  /// In ru, this message translates to:
  /// **'У тебя пока нет избранного'**
  String get favourites_empty;

  /// No description provided for @favourites_title.
  ///
  /// In ru, this message translates to:
  /// **'Избранные объявления'**
  String get favourites_title;

  /// No description provided for @my_ads.
  ///
  /// In ru, this message translates to:
  /// **'Мои объявления'**
  String get my_ads;

  /// No description provided for @my_ads_empty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет объявлений'**
  String get my_ads_empty;

  /// No description provided for @my_ads_title.
  ///
  /// In ru, this message translates to:
  /// **'Мои объявления'**
  String get my_ads_title;

  /// No description provided for @account_deleted.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт удалён'**
  String get account_deleted;

  /// No description provided for @anonymous_user.
  ///
  /// In ru, this message translates to:
  /// **'Гость'**
  String get anonymous_user;

  /// No description provided for @delete_account.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get delete_account;

  /// No description provided for @delete_account_confirmation.
  ///
  /// In ru, this message translates to:
  /// **'Точно хочешь удалить аккаунт?'**
  String get delete_account_confirmation;

  /// No description provided for @logged_out.
  ///
  /// In ru, this message translates to:
  /// **'Ты вышел из аккаунта'**
  String get logged_out;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @terms_and_conditions.
  ///
  /// In ru, this message translates to:
  /// **'Условия использования'**
  String get terms_and_conditions;

  /// No description provided for @add_anonymous_window.
  ///
  /// In ru, this message translates to:
  /// **'Войди, чтобы создать объявление'**
  String get add_anonymous_window;

  /// No description provided for @edit_anonymous_window.
  ///
  /// In ru, this message translates to:
  /// **'Войди, чтобы изменить профиль'**
  String get edit_anonymous_window;

  /// No description provided for @no_phone_number.
  ///
  /// In ru, this message translates to:
  /// **'+7 (XXX) XXX XXXX'**
  String get no_phone_number;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @details.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get details;

  /// No description provided for @edit_profile.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать профиль'**
  String get edit_profile;

  /// No description provided for @fill_all_fields.
  ///
  /// In ru, this message translates to:
  /// **'Заполни все поля'**
  String get fill_all_fields;

  /// No description provided for @item_details.
  ///
  /// In ru, this message translates to:
  /// **'Доп. информация'**
  String get item_details;

  /// No description provided for @likes.
  ///
  /// In ru, this message translates to:
  /// **'Лайки'**
  String get likes;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;

  /// No description provided for @no_internet_connection.
  ///
  /// In ru, this message translates to:
  /// **'Нет соединения'**
  String get no_internet_connection;

  /// No description provided for @optional.
  ///
  /// In ru, this message translates to:
  /// **'Необязательно'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In ru, this message translates to:
  /// **'Обязательно'**
  String get required;

  /// No description provided for @unknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестно'**
  String get unknown;

  /// No description provided for @call.
  ///
  /// In ru, this message translates to:
  /// **'Позвонить'**
  String get call;

  /// No description provided for @views.
  ///
  /// In ru, this message translates to:
  /// **'Просмотры'**
  String get views;

  /// No description provided for @advertisement_created.
  ///
  /// In ru, this message translates to:
  /// **'Объявление создано'**
  String get advertisement_created;

  /// No description provided for @failed_to_created_advertisement.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать объявление'**
  String get failed_to_created_advertisement;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'kk':
      return SKk();
    case 'ru':
      return SRu();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
