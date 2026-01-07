import 'package:flutter/material.dart';

/// Localisations de l'application (Français/Anglais)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'app_title': 'Campus Work',
      'welcome': 'Bienvenue',
      'login': 'Se connecter',
      'register': 'Créer un compte',
      'home': 'Accueil',
      'project': 'Projet',
      'favorites': 'Favoris',
      'messages': 'Messages',
      'profile': 'Profil',
      'search': 'Rechercher',
      'add_to_favorites': 'Ajouter au favoris',
      'reviews': 'Avis',
      'rating': 'Note',
      'comment': 'Commentaire',
      'submit': 'Envoyer',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'add': 'Ajouter',
      'remove': 'Retirer',
      'confirm': 'Confirmer',
      'stories': 'Stories',
      'support': 'Support',
      'report': 'Signaler',
      'settings': 'Paramètres',
      'language': 'Langue',
      'french': 'Français',
      'english': 'Anglais',
      'offline_mode': 'Mode hors connexion',
      'no_internet': 'Pas de connexion Internet',
      'sync': 'Synchroniser',
    },
    'en': {
      'app_title': 'Campus Work',
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Create account',
      'home': 'Home',
      'project': 'Project',
      'favorites': 'Favorites',
      'messages': 'Messages',
      'profile': 'Profile',
      'search': 'Search',
      'add_to_favorite': 'Add to favorite',
      'reviews': 'Reviews',
      'rating': 'Rating',
      'comment': 'Comment',
      'submit': 'Submit',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'remove': 'Remove',
      'confirm': 'Confirm',
      'stories': 'Stories',
      'support': 'Support',
      'report': 'Report',
      'settings': 'Settings',
      'language': 'Language',
      'french': 'French',
      'english': 'English',
      'offline_mode': 'Offline mode',
      'no_internet': 'No Internet connection',
      'sync': 'Sync',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appTitle => translate('app_title');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get register => translate('register');
  String get home => translate('home');
  String get project => translate('project');
  String get favorites => translate('favorites');
  String get messages => translate('messages');
  String get profile => translate('profile');
  String get search => translate('search');
  String get addToFavorite => translate('add_to_favorite');
  String get reviews => translate('reviews');
  String get rating => translate('rating');
  String get comment => translate('comment');
  String get submit => translate('submit');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get remove => translate('remove');
  String get confirm => translate('confirm');
  String get stories => translate('stories');
  String get support => translate('support');
  String get report => translate('report');
  String get settings => translate('settings');
  String get language => translate('language');
  String get french => translate('french');
  String get english => translate('english');
  String get offlineMode => translate('offline_mode');
  String get noInternet => translate('no_internet');
  String get sync => translate('sync');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}


