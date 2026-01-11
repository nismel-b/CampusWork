import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
  ];

  // Navigation
  String get home;
  String get dashboard;
  String get projects;
  String get groups;
  String get profile;
  String get settings;
  String get notifications;

  // Authentication
  String get login;
  String get register;
  String get logout;
  String get email;
  String get password;
  String get confirmPassword;
  String get firstName;
  String get lastName;
  String get username;
  String get phoneNumber;
  String get forgotPassword;
  String get createAccount;
  String get alreadyHaveAccount;
  String get dontHaveAccount;

  // Common actions
  String get save;
  String get cancel;
  String get delete;
  String get edit;
  String get add;
  String get remove;
  String get search;
  String get filter;
  String get sort;
  String get refresh;
  String get loading;
  String get error;
  String get success;
  String get warning;
  String get info;

  // Projects
  String get createProject;
  String get projectName;
  String get projectDescription;
  String get courseName;
  String get category;
  String get resources;
  String get prerequisites;
  String get collaborators;
  String get status;
  String get grade;
  String get comments;
  String get likes;
  String get myProjects;
  String get allProjects;
  String get projectDetails;
  String get addToGroup;
  String get removeFromGroup;

  // Groups
  String get createGroup;
  String get groupName;
  String get groupDescription;
  String get groupType;
  String get members;
  String get maxMembers;
  String get joinGroup;
  String get leaveGroup;
  String get groupProject;
  String get groupStudy;
  String get groupCollaboration;
  String get openGroup;
  String get closedGroup;
  String get evaluationCriteria;

  // Comments
  String get addComment;
  String get reply;
  String get writeComment;
  String get writeReply;
  String get noComments;
  String get commentAdded;
  String get replyAdded;

  // Stories & Surveys
  String get createStory;
  String get createSurvey;
  String get storyTitle;
  String get surveyQuestion;
  String get options;
  String get vote;
  String get results;
  String get expires;

  // Settings
  String get language;
  String get theme;
  String get darkMode;
  String get lightMode;
  String get systemMode;
  String get accountSettings;
  String get privacySettings;
  String get deleteAccount;

  // Messages
  String get welcomeMessage;
  String get noProjectsFound;
  String get noGroupsFound;
  String get noCommentsFound;
  String get projectCreatedSuccessfully;
  String get groupCreatedSuccessfully;
  String get commentAddedSuccessfully;
  String get errorOccurred;
  String get confirmDelete;
  String get itemDeleted;

  // Validation
  String get fieldRequired;
  String get emailInvalid;
  String get passwordTooShort;
  String get passwordsDoNotMatch;
  String get nameTooShort;

  // Time
  String get now;
  String get today;
  String get yesterday;
  String get daysAgo;
  String get hoursAgo;
  String get minutesAgo;
  String get secondsAgo;

  // File types
  String get document;
  String get video;
  String get image;
  String get link;
  String get code;
  String get presentation;
  String get other;

  // User roles
  String get student;
  String get lecturer;
  String get admin;

  // Project states
  String get inProgress;
  String get completed;
  String get graded;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'fr':
        return AppLocalizationsFr();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}