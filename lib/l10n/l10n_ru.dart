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
  String get language_code => 'ru';

  @override
  String get language_display_code => 'РУС';

  @override
  String get language_title => 'Язык';

  @override
  String get theme_light => 'Светлая';

  @override
  String get theme_dark => 'Тёмная';

  @override
  String get continue_ => 'Продолжить';

  @override
  String get greeting =>
      'Пройдите быструю регистрацию\nи найдите клиентов уже сегодня';

  @override
  String get login => 'Войти';

  @override
  String get register => 'Регистрация';

  @override
  String get signin => 'Войти';

  @override
  String get welcome => 'Добро пожаловать в Selo';

  @override
  String get withoutregistor => 'Продолжить без регистрации';

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
  String get no_ads_found => 'Объявления не найдены';

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
  String get max_price => 'Макс. цена';

  @override
  String get max_price_required => 'Укажите максимальную цену';

  @override
  String get negotiable => 'Договорная';

  @override
  String get price => 'Цена';

  @override
  String get price_hint => 'Введите цену';

  @override
  String get price_per_unit => 'Цена за единицу';

  @override
  String get price_range => 'Ценовой диапазон';

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
  String get add_appbar_pick_category => 'Выберите категорию объявления';

  @override
  String get add_appbar_title => 'Создание объявления';

  @override
  String get create_advert => 'Создать объявление';

  @override
  String get description => 'Описание';

  @override
  String get description_hint => 'Подробно опишите объявление';

  @override
  String get description_required => 'Описание обязательно';

  @override
  String get label_new_advert => 'НОВОЕ!';

  @override
  String get title_of_ad => 'Заголовок объявления';

  @override
  String get title_of_ad_hint => 'Введите заголовок';

  @override
  String get title_of_ad_required => 'Заголовок обязателен';

  @override
  String get address => 'Адрес';

  @override
  String get address_hint => 'Введите адрес';

  @override
  String get company => 'Компания';

  @override
  String get company_hint => 'Пример: ТОО \'WWW\'';

  @override
  String get company_required => 'Укажите компанию';

  @override
  String get contact_person => 'Контактное лицо';

  @override
  String get contact_person_hint => 'Пример: Иван Иванов';

  @override
  String get contact_person_required => 'Контактное лицо обязательно';

  @override
  String get district => 'Район';

  @override
  String get district_required => 'Район обязателен';

  @override
  String get district_select => 'Выберите район';

  @override
  String get location => 'Местоположение';

  @override
  String get location_hint => 'Введите местоположение';

  @override
  String get phone_number => 'Телефон';

  @override
  String get phone_number_hint => 'Введите номер телефона';

  @override
  String get phone_number_invalid => 'Неверный номер телефона';

  @override
  String get phone_number_required => 'Телефон обязателен';

  @override
  String get region => 'Регион';

  @override
  String get region_required => 'Регион обязателен';

  @override
  String get region_select => 'Выберите регион';

  @override
  String get your_phone_number => 'Ваш номер телефона';

  @override
  String get add_photo => 'Добавить фото';

  @override
  String get gallery => 'Галерея';

  @override
  String get camera => 'Камера';

  @override
  String get image_picker_error => 'Ошибка выбора изображения';

  @override
  String get image_upload_error => 'Ошибка загрузки изображения';

  @override
  String get images => 'Изображения';

  @override
  String get images_hint => 'Добавьте изображения';

  @override
  String get images_optional => 'необязательно';

  @override
  String get select_image_source => 'Выберите источник изображения';

  @override
  String get condition => 'Состояние';

  @override
  String get condition_new => 'Новое';

  @override
  String get condition_used => 'Б/у';

  @override
  String get max_quantity => 'Макс. количество';

  @override
  String get max_quantity_hint => 'Введите макс. количество';

  @override
  String get max_quantity_required => 'Макс. количество обязательно';

  @override
  String get quantity => 'Количество';

  @override
  String get quantity_hint => 'Введите количество';

  @override
  String get quantity_required => 'Количество обязательно';

  @override
  String get unit => 'Единица';

  @override
  String get unit_kg => 'кг';

  @override
  String get unit_ton => 'тонна';

  @override
  String get volume_quantity => 'Объём / Количество';

  @override
  String get year_of_release => 'Год выпуска';

  @override
  String get change_profile_photo => 'Изменить фото профиля';

  @override
  String get change_saved => 'Изменения успешно сохранены';

  @override
  String get lastname => 'Фамилия';

  @override
  String get lastname_hint => 'Введите фамилию';

  @override
  String get name => 'Имя';

  @override
  String get name_hint => 'Введите имя';

  @override
  String get profile_title => 'Профиль';

  @override
  String get profile_update_error => 'Ошибка обновления профиля';

  @override
  String get favourites_anonymous_window =>
      'Войдите, чтобы просматривать избранное';

  @override
  String get favourites_empty => 'У вас нет избранных объявлений';

  @override
  String get favourites_title => 'Избранные объявления';

  @override
  String get my_ads => 'Мои объявления';

  @override
  String get my_ads_empty => 'У вас нет объявлений';

  @override
  String get my_ads_title => 'Ваши объявления';

  @override
  String get account_deleted => 'Аккаунт удалён';

  @override
  String get anonymous_user => 'Гость';

  @override
  String get delete_account => 'Удалить аккаунт';

  @override
  String get delete_account_confirmation =>
      'Вы уверены, что хотите удалить аккаунт?';

  @override
  String get logged_out => 'Вы вышли из аккаунта';

  @override
  String get logout => 'Выйти';

  @override
  String get terms_and_conditions => 'Условия и соглашения';

  @override
  String get add_anonymous_window => 'Войдите, чтобы создать объявление';

  @override
  String get edit_anonymous_window => 'Войдите, чтобы изменить профиль';

  @override
  String get no_phone_number => '+7 (XXX) XXX XXXX';

  @override
  String get apply => 'Применить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get details => 'Детали';

  @override
  String get edit_profile => 'Редактировать профиль';

  @override
  String get fill_all_fields => 'Заполните все обязательные поля';

  @override
  String get item_details => 'Дополнительная информация';

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
  String get no_internet_connection => 'Нет подключения к интернету';

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
}
