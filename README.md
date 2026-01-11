# CampusWork - Plateforme de Gestion de Projets Académiques

Une application Flutter complète pour la gestion de projets académiques permettant aux étudiants, enseignants et administrateurs de collaborer efficacement.

## 🚀 Fonctionnalités

### Pour les Étudiants
- ✅ Création et gestion de projets
- ✅ Upload de fichiers et ressources
- ✅ Système de likes et commentaires
- ✅ Collaboration sur les projets
- ✅ Profil personnalisé avec liens sociaux
- ✅ Notifications en temps réel
- ✅ Navigation par cours et catégories

### Pour les Enseignants
- ✅ Évaluation des projets
- ✅ Attribution de notes
- ✅ Commentaires détaillés
- ✅ Gestion des cours

### Pour les Administrateurs
- ✅ Approbation des comptes
- ✅ Modération du contenu
- ✅ Gestion des utilisateurs

## 🏗️ Architecture

Le projet suit une architecture modulaire avec :

- **Modèles de données** : User, Student, Lecturer, Admin, Project, Comment, Like, Notification
- **Services** : AuthService, ProjectService, CommentService, LikeService, NotificationService, UserService
- **Écrans** : Dashboards spécialisés par rôle, pages de création/édition, profils
- **Navigation** : GoRouter avec redirection basée sur les rôles
- **Stockage** : SQLite avec SharedPreferences pour le cache
- **Thème** : Design professionnel monochrome avec mode sombre

## 📱 Écrans Disponibles

### Authentification
- Page de connexion
- Page d'inscription avec validation

### Étudiant
- Dashboard avec statistiques
- Création de projets (8 étapes)
- Liste de mes projets
- Détails des projets
- Profil personnel
- Paramètres
- Équipe étudiante
- Navigation par cours
- Notifications

### Enseignant
- Dashboard enseignant
- Évaluation des projets
- Gestion des notes

### Administrateur
- Dashboard admin
- Gestion des utilisateurs
- Approbation des comptes

## 🛠️ Technologies Utilisées

- **Flutter** 3.38.3
- **Dart** 
- **SQLite** pour la base de données
- **SharedPreferences** pour le cache
- **GoRouter** pour la navigation
- **Provider** pour la gestion d'état
- **Material Design 3**

### Packages Principaux
- `sqflite` - Base de données locale
- `shared_preferences` - Stockage local
- `go_router` - Navigation
- `provider` - Gestion d'état
- `image_picker` - Sélection d'images
- `file_picker` - Sélection de fichiers
- `uuid` - Génération d'identifiants
- `intl` - Internationalisation
- `crypto` - Chiffrement
- `google_fonts` - Polices Google

## 🚀 Installation et Lancement

### Prérequis
- Flutter SDK 3.38.3 ou supérieur
- Dart SDK
- Android Studio / VS Code
- Émulateur Android ou appareil physique

### Installation
```bash
# Cloner le projet
git clone <repository-url>
cd campuswork

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Compilation
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Web
flutter build web
```

## 👥 Comptes de Test

L'application crée automatiquement des comptes de test :

### Administrateur/Enseignant
- **Username:** admin
- **Password:** admin123

### Étudiant
- **Username:** student  
- **Password:** student123

## 📊 Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée
├── navigation/
│   └── app_route.dart       # Configuration des routes
├── theme/
│   └── theme.dart           # Thèmes light/dark
├── model/                   # Modèles de données
│   ├── user.dart
│   ├── student.dart
│   ├── lecturer.dart
│   ├── admin.dart
│   ├── project.dart
│   ├── comments.dart
│   ├── like.dart
│   └── notification.dart
├── services/                # Logique métier
│   ├── auth_service.dart
│   ├── project_service.dart
│   ├── comment-service.dart
│   ├── like-services.dart
│   ├── notification_services.dart
│   └── user_service.dart
├── auth/                    # Authentification
│   ├── auth_service.dart
│   ├── login_page.dart
│   └── register_page.dart
├── screen/                  # Écrans de l'app
│   ├── screen_student/
│   ├── screen_lecturer/
│   ├── screen_admin/
│   └── common_screen/
├── components/              # Composants réutilisables
├── database/               # Base de données
├── utils/                  # Utilitaires
└── storage/               # Stockage local
```

## 🔒 Sécurité

- Hachage des mots de passe avec SHA-256
- Validation des entrées utilisateur
- Chiffrement des données sensibles
- Gestion des permissions

## 🎨 Design

- **Style** : Monochrome professionnel académique
- **Mode clair** : Fond blanc avec accents bleu-gris
- **Mode sombre** : Bleu profond avec élévations bleu-gris
- **Couleur principale** : Bleu profond (#2563EB)
- **Layout** : Design basé sur des cartes avec espacement généreux
- **Icônes** : Material Icons uniquement
- **Typographie** : Hiérarchie claire avec bon contraste

## 📈 Fonctionnalités Avancées

### Système de Projets
- Création en 8 étapes guidées
- Upload de fichiers multiples
- Gestion des collaborateurs
- États : En cours, Terminé, Noté
- Visibilité : Public/Privé
- Catégorisation par cours

### Interactions Sociales
- Système de likes
- Commentaires avec notifications
- Profils utilisateur détaillés
- Équipe étudiante

### Notifications
- Notifications push
- Notifications par email
- Types : Like, Commentaire, Évaluation, Approbation

## 🔄 État du Projet

### ✅ Complété
- Architecture complète
- Tous les modèles de données
- Services fonctionnels
- Écrans principaux
- Système d'authentification
- Navigation complète
- Thème professionnel
- Base de données SQLite

### 🚧 En Cours / À Améliorer
- Tests unitaires
- Tests d'intégration
- Optimisations de performance
- Fonctionnalités de messagerie
- Synchronisation cloud
- Mode hors ligne

## 👨‍🎓 Auteurs

Projet réalisé par :
- **TSAFACK NGOUFACK Ernis Merkel**
- **Gloria CHIKOAM TCHAKOUNTE**

Dans le cadre d'un projet académique en développement mobile avec Flutter.

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est destiné à un usage éducatif et académique.

## 📞 Support

Pour toute question ou support, contactez l'équipe de développement.

---

**CampusWork** - Révolutionner la gestion de projets académiques 🎓