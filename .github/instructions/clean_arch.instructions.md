# 📘 PROJECT_GUIDELINES.md

## 🧠 Цель проекта
Создать масштабируемое Flutter-приложение с использованием **Clean Architecture**, **Hive** для локального хранения, **Firebase Authentication** для аутентификации и **Riverpod** для управления состоянием.

---


## 📂 Структура проекта

```plaintext
lib/
├── core/                  # Базовые компоненты приложения
│   ├── bloc/              # Общие базовые блоки
│   ├── cache/             # Работа с кешем (Hive и др.)
│   ├── constants/         # Константы приложения
│   ├── di/                # Dependency Injection (get_it)
│   ├── error/             # Классы ошибок, обработка исключений
│   ├── extensions/        # Расширения для типов
│   ├── network/           # API-клиенты, интерцепторы и т.п.
│   ├── theme/             # Темизация (TextTheme, ColorScheme и др.)
│   └── utils/             # Утилиты и вспомогательные методы
│
├── features/              # Разделение по фичам
│   ├── auth/              # Аутентификация
│   │   ├── data/          # Источники и модели данных
│   │   ├── domain/        # UseCases, Entities, репозитории
│   │   └── presentation/  # UI: bloc, pages, widgets
│
│   ├── home_screen/       # Главный экран
│   └── ...                # Остальные фичи
│
├── shared/                # Общие модули и компоненты
│   ├── components/        # Универсальные переиспользуемые виджеты
│   ├── models/            # Общие модели (напр., User)
│   └── utils/             # Общие функции/расширения
│
├── services/              # Сервисы уровня приложения
│   ├── analytics/         # Firebase Analytics и пр.
│   ├── notifications/     # Уведомления
│   └── logging/           # Talker, логирование
│
├── config/
│   ├── routes/            # GoRouter конфигурация
│   └── env/               # Окружение
│
├── generated/             # Автогенерируемые файлы (intl и др.)
├── firebase_options.dart  # Firebase инициализация
└── main.dart              # Точка входа
```


---

## 🔐 Аутентификация (Firebase)

- Используется Firebase Auth с поддержкой:
  - Анонимной авторизации
  - Авторизации по номеру телефона (OTP)
  - Поддержка логики `isNewUser` при логине/регистрации

---

## 🗃 Локальное хранилище (Hive)

- Используется Hive для хранения:
  - Информации о пользователе
  - Локальных настроек и токенов
- Адаптеры генерируются с помощью `build_runner`
- Все боксы и ключи обернуты в `HiveStorageService`, доступный через `Provider`

---

## 🧪 Управление состоянием (Riverpod)

- Используется `flutter_riverpod`:
  - Все состояния и репозитории оформлены как `Provider`, `StateNotifierProvider`, `FutureProvider`
  - Чистый и предсказуемый поток данных
  - Разделение `Provider` по слоям: domain/usecases, data/repositories, presentation/providers

---

## 🧹 Clean Architecture

Разделение по слоям:
- **Data Layer** – модели, реализации репозиториев, datasources
- **Domain Layer** – usecases, entities, интерфейсы репозиториев
- **Presentation Layer** – UI, State Notifiers, Providers

Каждый слой зависит **только от слоя ниже** (вниз по стрелке):
UI ➡ UseCase ➡ Repository ➡ Remote/DataSource


---

## ✅ Соглашения по коду

- Именование:
  - `camelCase` для переменных и методов
  - `PascalCase` для классов и типов
- Структура UI:
  - Только `StatelessWidget` или `HookWidget` (без `setState`)
  - Выносить логику во `StateNotifier` / `UseCase`
- Стиль:
  - Использовать дизайн-систему (например, `textStyles`, `colorScheme`)
  - UI-элементы переиспользуемы
- Hive:
  - Все ключи и боксы хранятся централизованно в `HiveBoxes`/`HiveKeys`
- Testable:
  - Все UseCase и Repositories покрываются unit-тестами

---

## 🧪 Тестирование

- Юнит-тесты:
  - UseCases
  - Repositories (через мок)
- Widget-тесты:
  - Основные страницы (ввод номера, подтверждение кода, профиль)
- Используются:
  - `mocktail`, `flutter_test`, `riverpod_test`

---

## 🧱 Пример UI-флоу: Аутентификация по телефону

PhoneNumberPage
➡ phoneAuthNotifier.sendCode()
➡ FirebaseAuth
➡ Подтверждение кода
➡ phoneAuthNotifier.verifyCode()
➡ Логика: isNewUser ? register() : login()
➡ Сохранение user в Hive


---

## ⚙️ Dev-инструкции

### Запуск:
```bash
flutter run
Генерация адаптеров:
bash
Копировать
Редактировать
flutter packages pub run build_runner build --delete-conflicting-outputs
Hive init:
dart
Копировать
Редактировать
await Hive.initFlutter();
Hive.registerAdapter(UserModelAdapter());
Firebase init:
В main.dart: WidgetsFlutterBinding.ensureInitialized();

await Firebase.initializeApp();

