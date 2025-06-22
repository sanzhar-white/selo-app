// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class L10nRu extends L10n {
  L10nRu([String locale = 'ru']) : super(locale);

  @override
  String get language => 'Русский';

  @override
  String get language_code => 'en';

  @override
  String get language_display_code => 'ENG';

  @override
  String get language_title => 'Язык';

  @override
  String get theme_light => 'Светлая тема';

  @override
  String get theme_dark => 'Тёмная тема';

  @override
  String get continue_ => 'Продолжить';

  @override
  String get greeting =>
      'Пройди быструю регистрацию\nи начинай находить клиентов уже сегодня';

  @override
  String get login => 'Вход';

  @override
  String get register => 'Регистрация';

  @override
  String get signin => 'Войти';

  @override
  String get welcome => 'Добро пожаловать в Selo';

  @override
  String get withoutregistor => 'Продолжить без регистрации';

  @override
  String get error_verification => 'Ошибка во время проверки';

  @override
  String get nav_add => 'Добавить';

  @override
  String get nav_favourites => 'Избранное';

  @override
  String get nav_home => 'Главная';

  @override
  String get nav_profile => 'Профиль';

  @override
  String get all_ads => 'Все объявления';

  @override
  String get all_categories => 'Все категории';

  @override
  String get category => 'Категория';

  @override
  String get no_ads_found => 'Объявлений не найдено';

  @override
  String get search_hint => 'Поиск по Казахстану';

  @override
  String get sort => 'Сортировка';

  @override
  String get sort_by => 'Сортировать по';

  @override
  String get sort_by_price_from => 'Цена от';

  @override
  String get sort_by_price_to => 'Цена до';

  @override
  String get default_sorting => 'По умолчанию';

  @override
  String get newest_first => 'Сначала новые';

  @override
  String get oldest_first => 'Сначала старые';

  @override
  String get cheapest_first => 'Сначала дешёвые';

  @override
  String get most_expensive_first => 'Сначала дорогие';

  @override
  String get filter => 'Фильтр';

  @override
  String get fixed => 'Фиксированная';

  @override
  String get from => 'От';

  @override
  String get max_price => 'Максимальная цена';

  @override
  String get max_price_required => 'Укажи максимальную цену';

  @override
  String get negotiable => 'Договорная';

  @override
  String get price => 'Цена';

  @override
  String get price_hint => 'Укажи цену';

  @override
  String get price_per_unit => 'Цена за единицу';

  @override
  String get price_range => 'Диапазон цен';

  @override
  String get price_required => 'Цена обязательна';

  @override
  String get salary => 'Зарплата';

  @override
  String get to => 'До';

  @override
  String get trade_not_possible => 'Обмен невозможен';

  @override
  String get trade_possible => 'Обмен возможен';

  @override
  String get add_appbar_pick_category => 'Выбери категорию';

  @override
  String get add_appbar_title => 'Новое объявление';

  @override
  String get create_advert => 'Создать объявление';

  @override
  String get description => 'Описание';

  @override
  String get description_hint => 'Подробно опиши объявление';

  @override
  String get description_required => 'Описание обязательно';

  @override
  String get label_new_advert => 'НОВОЕ!';

  @override
  String get title_of_ad => 'Заголовок';

  @override
  String get title_of_ad_hint => 'Введи заголовок';

  @override
  String get title_of_ad_required => 'Заголовок обязателен';

  @override
  String get address => 'Адрес';

  @override
  String get address_hint => 'Введи адрес';

  @override
  String get company => 'Компания';

  @override
  String get company_hint => 'Пример: ТОО \'WWW\'';

  @override
  String get company_required => 'Укажи компанию';

  @override
  String get contact_person => 'Контактное лицо';

  @override
  String get contact_person_hint => 'Пример: Иван Иванов';

  @override
  String get contact_person_required => 'Контакт обязателен';

  @override
  String get district => 'Район';

  @override
  String get district_required => 'Укажи район';

  @override
  String get district_select => 'Выбери район';

  @override
  String get location => 'Местоположение';

  @override
  String get location_hint => 'Укажи местоположение';

  @override
  String get phone_number => 'Телефон';

  @override
  String get phone_number_hint => 'Введи номер';

  @override
  String get phone_number_invalid => 'Неверный номер';

  @override
  String get phone_number_required => 'Номер обязателен';

  @override
  String get region => 'Регион';

  @override
  String get region_required => 'Регион обязателен';

  @override
  String get region_select => 'Выбери регион';

  @override
  String get your_phone_number => 'Твой номер телефона';

  @override
  String get add_photo => 'Добавить фото';

  @override
  String get gallery => 'Галерея';

  @override
  String get camera => 'Камера';

  @override
  String get image_picker_error => 'Ошибка при выборе фото';

  @override
  String get image_upload_error => 'Ошибка загрузки фото';

  @override
  String get images => 'Фотографии';

  @override
  String get images_hint => 'Добавь фото';

  @override
  String get images_optional => 'необязательно';

  @override
  String get select_image_source => 'Выбери источник';

  @override
  String get image_less_size => 'Размер до 25 МБ';

  @override
  String get max_images => 'Максимум 10 фото';

  @override
  String get condition => 'Состояние';

  @override
  String get condition_new => 'Новое';

  @override
  String get condition_used => 'Б/у';

  @override
  String get max_quantity => 'Макс. количество';

  @override
  String get max_quantity_hint => 'Введи максимум';

  @override
  String get max_quantity_required => 'Укажи макс. количество';

  @override
  String get quantity => 'Количество';

  @override
  String get quantity_hint => 'Введи количество';

  @override
  String get quantity_required => 'Укажи количество';

  @override
  String get unit => 'Единица';

  @override
  String get unit_kg => 'кг';

  @override
  String get unit_ton => 'тонна';

  @override
  String get volume_quantity => 'Объём / Кол-во';

  @override
  String get year_of_release => 'Год выпуска';

  @override
  String get change_profile_photo => 'Сменить фото профиля';

  @override
  String get change_saved => 'Изменения сохранены';

  @override
  String get lastname => 'Фамилия';

  @override
  String get lastname_hint => 'Введи фамилию';

  @override
  String get name => 'Имя';

  @override
  String get name_hint => 'Введи имя';

  @override
  String get profile_title => 'Профиль';

  @override
  String get profile_update_error => 'Ошибка обновления профиля';

  @override
  String get favourites_anonymous_window => 'Войди, чтобы видеть избранное';

  @override
  String get favourites_empty => 'У тебя пока нет избранного';

  @override
  String get favourites_title => 'Избранные объявления';

  @override
  String get my_ads => 'Мои объявления';

  @override
  String get my_ads_empty => 'Пока нет объявлений';

  @override
  String get my_ads_title => 'Мои объявления';

  @override
  String get account_deleted => 'Аккаунт удалён';

  @override
  String get anonymous_user => 'Гость';

  @override
  String get delete_account => 'Удалить аккаунт';

  @override
  String get delete_account_confirmation => 'Точно хочешь удалить аккаунт?';

  @override
  String get logged_out => 'Ты вышел из аккаунта';

  @override
  String get logout => 'Выйти';

  @override
  String get terms_and_conditions => 'Условия использования';

  @override
  String get add_anonymous_window => 'Войди, чтобы создать объявление';

  @override
  String get edit_anonymous_window => 'Войди, чтобы изменить профиль';

  @override
  String get no_phone_number => '+7 (XXX) XXX XXXX';

  @override
  String get apply => 'Применить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get details => 'Подробнее';

  @override
  String get edit_profile => 'Редактировать профиль';

  @override
  String get fill_all_fields => 'Заполни все поля';

  @override
  String get item_details => 'Доп. информация';

  @override
  String get likes => 'Лайки';

  @override
  String get reset => 'Сбросить';

  @override
  String get retry => 'Повторить';

  @override
  String get save => 'Сохранить';

  @override
  String get error => 'Ошибка';

  @override
  String get no_internet_connection => 'Нет соединения';

  @override
  String get optional => 'Необязательно';

  @override
  String get required => 'Обязательно';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get call => 'Позвонить';

  @override
  String get views => 'Просмотры';

  @override
  String get advertisement_created => 'Объявление создано';

  @override
  String get failed_to_created_advertisement => 'Не удалось создать объявление';
}
