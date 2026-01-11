import 'app_localizations.dart';

class AppLocalizationsFr extends AppLocalizations {
  // Navigation
  @override
  String get home => 'Accueil';
  @override
  String get dashboard => 'Tableau de bord';
  @override
  String get projects => 'Projets';
  @override
  String get groups => 'Groupes';
  @override
  String get profile => 'Profil';
  @override
  String get settings => 'Paramètres';
  @override
  String get notifications => 'Notifications';

  // Authentication
  @override
  String get login => 'Connexion';
  @override
  String get register => 'Inscription';
  @override
  String get logout => 'Déconnexion';
  @override
  String get email => 'Email';
  @override
  String get password => 'Mot de passe';
  @override
  String get confirmPassword => 'Confirmer le mot de passe';
  @override
  String get firstName => 'Prénom';
  @override
  String get lastName => 'Nom';
  @override
  String get username => 'Nom d\'utilisateur';
  @override
  String get phoneNumber => 'Numéro de téléphone';
  @override
  String get forgotPassword => 'Mot de passe oublié ?';
  @override
  String get createAccount => 'Créer un compte';
  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';
  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  // Common actions
  @override
  String get save => 'Enregistrer';
  @override
  String get cancel => 'Annuler';
  @override
  String get delete => 'Supprimer';
  @override
  String get edit => 'Modifier';
  @override
  String get add => 'Ajouter';
  @override
  String get remove => 'Retirer';
  @override
  String get search => 'Rechercher';
  @override
  String get filter => 'Filtrer';
  @override
  String get sort => 'Trier';
  @override
  String get refresh => 'Actualiser';
  @override
  String get loading => 'Chargement...';
  @override
  String get error => 'Erreur';
  @override
  String get success => 'Succès';
  @override
  String get warning => 'Attention';
  @override
  String get info => 'Information';

  // Projects
  @override
  String get createProject => 'Créer un projet';
  @override
  String get projectName => 'Nom du projet';
  @override
  String get projectDescription => 'Description du projet';
  @override
  String get courseName => 'Nom du cours';
  @override
  String get category => 'Catégorie';
  @override
  String get resources => 'Ressources';
  @override
  String get prerequisites => 'Prérequis';
  @override
  String get collaborators => 'Collaborateurs';
  @override
  String get status => 'Statut';
  @override
  String get grade => 'Note';
  @override
  String get comments => 'Commentaires';
  @override
  String get likes => 'J\'aime';
  @override
  String get myProjects => 'Mes projets';
  @override
  String get allProjects => 'Tous les projets';
  @override
  String get projectDetails => 'Détails du projet';
  @override
  String get addToGroup => 'Ajouter au groupe';
  @override
  String get removeFromGroup => 'Retirer du groupe';

  // Groups
  @override
  String get createGroup => 'Créer un groupe';
  @override
  String get groupName => 'Nom du groupe';
  @override
  String get groupDescription => 'Description du groupe';
  @override
  String get groupType => 'Type de groupe';
  @override
  String get members => 'Membres';
  @override
  String get maxMembers => 'Nombre maximum de membres';
  @override
  String get joinGroup => 'Rejoindre le groupe';
  @override
  String get leaveGroup => 'Quitter le groupe';
  @override
  String get groupProject => 'Groupe de projet';
  @override
  String get groupStudy => 'Groupe d\'étude';
  @override
  String get groupCollaboration => 'Groupe de collaboration';
  @override
  String get openGroup => 'Groupe ouvert';
  @override
  String get closedGroup => 'Groupe fermé';
  @override
  String get evaluationCriteria => 'Critères d\'évaluation';

  // Comments
  @override
  String get addComment => 'Ajouter un commentaire';
  @override
  String get reply => 'Répondre';
  @override
  String get writeComment => 'Écrivez votre commentaire...';
  @override
  String get writeReply => 'Écrivez votre réponse...';
  @override
  String get noComments => 'Aucun commentaire';
  @override
  String get commentAdded => 'Commentaire ajouté';
  @override
  String get replyAdded => 'Réponse ajoutée';

  // Stories & Surveys
  @override
  String get createStory => 'Créer une story';
  @override
  String get createSurvey => 'Créer un sondage';
  @override
  String get storyTitle => 'Titre de la story';
  @override
  String get surveyQuestion => 'Question du sondage';
  @override
  String get options => 'Options';
  @override
  String get vote => 'Voter';
  @override
  String get results => 'Résultats';
  @override
  String get expires => 'Expire';

  // Settings
  @override
  String get language => 'Langue';
  @override
  String get theme => 'Thème';
  @override
  String get darkMode => 'Mode sombre';
  @override
  String get lightMode => 'Mode clair';
  @override
  String get systemMode => 'Mode système';
  @override
  String get accountSettings => 'Paramètres du compte';
  @override
  String get privacySettings => 'Paramètres de confidentialité';
  @override
  String get deleteAccount => 'Supprimer le compte';

  // Messages
  @override
  String get welcomeMessage => 'Bienvenue sur CampusWork !';
  @override
  String get noProjectsFound => 'Aucun projet trouvé';
  @override
  String get noGroupsFound => 'Aucun groupe trouvé';
  @override
  String get noCommentsFound => 'Aucun commentaire trouvé';
  @override
  String get projectCreatedSuccessfully => 'Projet créé avec succès';
  @override
  String get groupCreatedSuccessfully => 'Groupe créé avec succès';
  @override
  String get commentAddedSuccessfully => 'Commentaire ajouté avec succès';
  @override
  String get errorOccurred => 'Une erreur s\'est produite';
  @override
  String get confirmDelete => 'Confirmer la suppression';
  @override
  String get itemDeleted => 'Élément supprimé';

  // Validation
  @override
  String get fieldRequired => 'Ce champ est requis';
  @override
  String get emailInvalid => 'Email invalide';
  @override
  String get passwordTooShort => 'Mot de passe trop court';
  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';
  @override
  String get nameTooShort => 'Nom trop court';

  // Time
  @override
  String get now => 'Maintenant';
  @override
  String get today => 'Aujourd\'hui';
  @override
  String get yesterday => 'Hier';
  @override
  String get daysAgo => 'Il y a {} jours';
  @override
  String get hoursAgo => 'Il y a {} heures';
  @override
  String get minutesAgo => 'Il y a {} minutes';
  @override
  String get secondsAgo => 'Il y a {} secondes';

  // File types
  @override
  String get document => 'Document';
  @override
  String get video => 'Vidéo';
  @override
  String get image => 'Image';
  @override
  String get link => 'Lien';
  @override
  String get code => 'Code';
  @override
  String get presentation => 'Présentation';
  @override
  String get other => 'Autre';

  // User roles
  @override
  String get student => 'Étudiant';
  @override
  String get lecturer => 'Enseignant';
  @override
  String get admin => 'Administrateur';

  // Project states
  @override
  String get inProgress => 'En cours';
  @override
  String get completed => 'Terminé';
  @override
  String get graded => 'Noté';
}