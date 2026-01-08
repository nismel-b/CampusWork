# campuswork

CampusWork

CampusWork est une application mobile développée avec Flutter, d
ont l’objectif est de proposer une plateforme simple permettant de centraliser 
et gérer des activités académiques (travaux, projets, informations) dans un contexte universitaire.

Ce projet a été réalisé dans un cadre académique, avec un focus sur 
la structuration d’une application mobile multiplateforme,
l’ergonomie et les bonnes pratiques de développement Flutter.

🎯 Objectifs du projet

Mettre en œuvre une application mobile Flutter fonctionnelle

Comprendre la structure d’un projet Flutter professionnel

Implémenter une navigation multi-écrans

Manipuler des données (saisie, affichage, stockage, gestion des permissions, changement d'état)

Respecter les exigences d’un projet académique mobile

📱 Fonctionnalités principales

Interface utilisateur simple et intuitive

Navigation entre plusieurs écrans

Gestion de contenu académique (ex. informations, travaux, projets – selon l’implémentation)

Structure de code claire et maintenable

Le projet peut être étendu pour inclure des fonctionnalités supplémentaires telles que :
la gestion des projets (intégration meme de git au sein de l'application)
un détecteur de plagiat pour s'assurer de l'originalité d'un projet


🛠️ Technologies utilisées

Flutter

Dart

Android SDK

Material Design

📂 Structure du projet
CampusWork/
│
├── android/              # Configuration Android
├── lib/                  # Code source Dart
│   ├── main.dart         # Point d’entrée de l’application
│   └── ...               # Widgets et écrans
├── test/                 # Tests (à compléter)
├── pubspec.yaml          # Dépendances et configuration
├── analysis_options.yaml # Règles d’analyse statique
└── README.md             # Documentation du projet

▶️ Lancer le projet
Prérequis

Flutter SDK installé

Android Studio ou VS Code

Un émulateur Android ou un appareil physique

Étapes
git clone https://github.com/nismel-b/CampusWork_.git
cd CampusWork_
flutter pub get
flutter run

🧪 Tests

Les tests unitaires et tests de widgets peuvent être ajoutés dans le dossier test/.
Cette partie est prévue pour les évolutions futures du projet.

📌 Améliorations possibles

Ajout d’une base de données locale (SQLite, Hive)

Authentification utilisateur

Notifications

Architecture plus avancée (Provider, Bloc, Clean Architecture)

Support iOS

Tests automatisés

👨‍🎓 Auteur

Projet réalisé par :
TSAFACK NGOUFACK Ernis Merkel 
Gloria CHIKOAM TCHAKOUNTE

Dans le cadre d’un projet académique en développement mobile avec Flutter.

📄 Licence

Ce projet est destiné à un usage éducatif.
