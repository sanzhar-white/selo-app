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

  /// `Profile Settings`
  String get profile_settings {
    return Intl.message(
      'Profile Settings',
      name: 'profile_settings',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get profile_logout {
    return Intl.message(
      'Log out',
      name: 'profile_logout',
      desc: '',
      args: [],
    );
  }

  /// `Create Ad`
  String get add_form_title {
    return Intl.message(
      'Create Ad',
      name: 'add_form_title',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get add_form_submit {
    return Intl.message(
      'Submit',
      name: 'add_form_submit',
      desc: '',
      args: [],
    );
  }

  /// `Hello {userName}!`
  String greeting_user(Object userName) {
    return Intl.message(
      'Hello $userName!',
      name: 'greeting_user',
      desc: '',
      args: [userName],
    );
  }

  /// `Kg`
  String get label_kg {
    return Intl.message(
      'Kg',
      name: 'label_kg',
      desc: '',
      args: [],
    );
  }

  /// `Ton`
  String get label_ton {
    return Intl.message(
      'Ton',
      name: 'label_ton',
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
