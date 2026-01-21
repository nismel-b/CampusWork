# 🎓 CampusWork - Plateforme de Gestion de Projets Universitaires

![CampusWork Banner](./docs/banner.png)

**CampusWork** est une plateforme collaborative conçue pour faciliter le catalogage, la gestion et l'évaluation des projets académiques. Elle permet aux étudiants de publier leurs travaux, aux enseignants de les évaluer, et aux administrateurs de superviser l'ensemble du système.

---

## 📋 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Technologies](#-technologies)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Utilisation](#-utilisation)
- [Structure du projet](#-structure-du-projet)
- [API Gateway](#-api-gateway)
- [Système de notifications](#-système-de-notifications)
- [Gestion des rôles](#-gestion-des-rôles)
- [Déploiement](#-déploiement)
- [Contribution](#-contribution)
- [Support](#-support)
- [Licence](#-licence)

---

## ✨ Fonctionnalités

### 👥 Gestion des utilisateurs
- **Authentification sécurisée** avec Firebase Auth
- **Connexion Google** OAuth 2.0
- **3 types de rôles** : Étudiant, Enseignant, Administrateur
- **Profils personnalisables** avec avatar, bio, cycle académique
- **Système d'approbation** pour nouveaux comptes

### 📚 Gestion des projets
- **Création de projets** avec informations détaillées
- **Upload de médias** : images de couverture, vidéos de démonstration
- **Documents annexes** : PDF, DOCX, XLSX
- **Technologies & tags** pour catégorisation
- **Collaborateurs** : gestion d'équipe projet
- **Statuts** : En cours / Terminé
- **Évaluations** : notation par les enseignants
- **Système de likes** et interactions sociales

### 💬 Forum de discussion
- **Création de posts** avec catégories (Discussion, Aide, Annonces)
- **Système de commentaires** hiérarchique avec réponses
- **Likes** sur posts et commentaires
- **Édition et suppression** avec permissions
- **Modération** pour administrateurs

### 🔔 Notifications en temps réel
- **Notifications in-app** persistantes
- **8 types de notifications** :
  - Likes (posts et projets)
  - Commentaires et réponses
  - Évaluations de projets
  - Nouveaux projets (pour enseignants)
  - Suppressions (modération)
- **Badge de notifications** non lues
- **Panel interactif** avec actions (marquer lu, supprimer)
- **Polling automatique** toutes les 30 secondes

### 🎨 Interface utilisateur
- **Design moderne** avec Tailwind CSS
- **Mode sombre** compatible
- **Responsive** mobile, tablette, desktop
- **Animations fluides** et transitions
- **Navigation intuitive** avec sidebar collapsible

### 📊 Tableaux de bord
- **Dashboard étudiant** : mes projets, statistiques
- **Dashboard enseignant** : tous les projets, évaluations
- **Dashboard admin** : gestion complète, statistiques globales

### 🔐 Sécurité
- **Row Level Security** (RLS) Supabase
- **Validation côté serveur**
- **Protection CSRF**
- **Sanitization des inputs**
- **Gestion des permissions** par rôle

---

## 🛠 Technologies

### Frontend
- **React 18** avec TypeScript
- **Vite** - Build tool ultra-rapide
- **Tailwind CSS** - Framework CSS utility-first
- **Lucide React** - Bibliothèque d'icônes

### Backend & Services
- **Firebase Authentication** - Gestion des utilisateurs
- **Supabase Database** - PostgreSQL avec RLS
- **Supabase Storage** - Stockage de fichiers (avatars, médias)

### Outils de développement
- **TypeScript** - Typage statique
- **ESLint** - Linter JavaScript/TypeScript
- **Prettier** - Formatteur de code
- **Git** - Contrôle de version

### Déploiement
- **Vercel / Netlify** - Hébergement frontend
- **Vps** 

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       FRONTEND (React)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Components  │  │     Views    │  │    Hooks     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                            │                                 │
│                    ┌───────▼────────┐                        │
│                    │  API Gateway   │                        │
│                    └───────┬────────┘                        │
└────────────────────────────┼──────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
┌───────▼────────┐  ┌────────▼────────┐  ┌───────▼────────┐
│    Firebase    │  │    Supabase     │  │    Supabase    │
│      Auth      │  │    Database     │  │    Storage     │
│                │  │                 │  │                │
│ • Login        │  │ • Users         │  │ • Avatars      │
│ • Register     │  │ • Projects      │  │ • Covers       │
│ • OAuth Google │  │ • Posts         │  │ • Videos       │
│ • Reset Pass   │  │ • Notifications │  │ • Files        │
└────────────────┘  └─────────────────┘  └────────────────┘
```

### Flux de données

1. **L'utilisateur** interagit avec les composants React
2. **Les composants** appellent les méthodes de l'**API Gateway**
3. **L'API Gateway** orchestre les appels aux services :
   - `authService` pour l'authentification
   - `supabaseDatabaseService` pour les données
   - `supabaseStorageService` pour les fichiers
   - `notificationService` pour les notifications
4. **Les services** communiquent avec Firebase/Supabase
5. **Les données** remontent via l'API Gateway vers React
6. **L'interface** se met à jour automatiquement

---

## 📋 Prérequis

- **Node.js** >= 16.x
- **npm** >= 8.x ou **yarn** >= 1.22.x
- **Compte Firebase** (gratuit)
- **Compte Supabase** (gratuit)
- **Git**

---

## 🚀 Installation

### 1. Cloner le repository

```bash
git clone https://github.com/nismel-b/CampusWork_.git
cd campuswork
```

### 2. Installer les dépendances

```bash
npm install
# ou
yarn install
```

### 3. Configuration Firebase

1. Créer un projet sur [Firebase Console](https://console.firebase.google.com)
2. Activer **Authentication** → **Email/Password** et **Google**
3. Copier les credentials dans `.env`

### 4. Configuration Supabase

1. Créer un projet sur [Supabase](https://supabase.com)
2. Exécuter les migrations SQL (voir `/docs/supabase-schema.sql`)
3. Créer les buckets storage : `avatars`, `covers`, `videos`, `files`
4. Copier les credentials dans `.env`

### 5. Variables d'environnement

Créer un fichier `.env` à la racine :

```env
# Firebase
VITE_FIREBASE_API_KEY=your_firebase_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=123456789
VITE_FIREBASE_APP_ID=1:123456789:web:abcdef

# Supabase
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 6. Lancer le serveur de développement

```bash
npm run dev
# ou
yarn dev
```

L'application sera accessible sur **http://localhost:5173**

---

## ⚙️ Configuration

### Configuration Supabase (Base de données)

#### Tables principales

```sql
-- users
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  role TEXT CHECK (role IN ('student', 'lecturer', 'admin')),
  avatar TEXT,
  bio TEXT,
  cycle TEXT,
  status TEXT,
  department TEXT,
  level TEXT,
  matricule TEXT,
  pending BOOLEAN DEFAULT true,
  banned BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- projects
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  author_name TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  subject TEXT,
  status TEXT,
  grade TEXT,
  cover_image TEXT,
  demo_video TEXT,
  video_type TEXT,
  github_link TEXT,
  linkedin_link TEXT,
  other_link TEXT,
  lecturer_name TEXT,
  lecturer_email TEXT,
  student_level TEXT,
  collaborators JSONB DEFAULT '[]',
  technologies JSONB DEFAULT '[]',
  tags JSONB DEFAULT '[]',
  attached_file JSONB,
  reviews JSONB DEFAULT '[]',
  likes INTEGER DEFAULT 0,
  liked_by JSONB DEFAULT '[]',
  is_evaluated BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- posts
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  author_name TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT,
  likes INTEGER DEFAULT 0,
  liked_by JSONB DEFAULT '[]',
  comments INTEGER DEFAULT 0,
  replies JSONB DEFAULT '[]',
  blocked BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  link TEXT,
  related_id UUID,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

Voir `/docs/supabase-schema.sql` pour le schéma complet avec index et RLS.

### Configuration Storage (Buckets)

Créer 4 buckets dans Supabase Storage :

1. **avatars** - Photos de profil (public)
2. **covers** - Images de couverture projets (public)
3. **videos** - Vidéos de démonstration (public)
4. **files** - Documents annexes (public)

Politiques de sécurité recommandées :
- **Upload** : Authentifié seulement
- **Download** : Public
- **Delete** : Propriétaire seulement

---

## 📖 Utilisation

### Créer un compte

1. Cliquer sur **"Créer mon profil"**
2. Remplir le formulaire (nom, email, mot de passe, rôle)
3. Attendre l'approbation d'un administrateur

### Connexion Google

1. Cliquer sur **"Se connecter avec Google"**
2. Choisir un compte Google
3. Sélectionner le rôle (Étudiant/Enseignant)
4. Attendre l'approbation

### Créer un projet (Étudiant)

1. Aller dans **"Projets"**
2. Cliquer sur **"Nouveau Projet"**
3. Remplir les informations :
   - Titre, description
   - Catégorie, matière
   - Image de couverture (optionnel)
   - Vidéo de démo (optionnel)
   - Technologies utilisées
   - Tags
   - Collaborateurs
   - Liens (GitHub, LinkedIn, etc.)
4. Cliquer sur **"Diffuser mon projet"**

### Évaluer un projet (Enseignant)

1. Consulter un projet
2. Dans la section **"Nouvelle Évaluation"**
3. Entrer une note sur 20
4. Ajouter un commentaire
5. Cliquer sur **"Publier l'évaluation"**

### Créer une discussion

1. Aller dans **"Discussions"**
2. Cliquer sur **"Nouvelle Discussion"**
3. Entrer un titre et contenu
4. Choisir une catégorie
5. Publier

### Gérer les notifications

1. Cliquer sur l'icône **🔔** (en haut à droite)
2. Voir les notifications non lues (badge)
3. Cliquer sur une notification pour y accéder
4. Actions disponibles :
   - Marquer comme lu
   - Tout marquer comme lu
   - Supprimer
   - Tout supprimer

---

## 📁 Structure du projet

```
campuswork/
├── src/
│   ├── api/
│   │   ├── config/
│   │   │   ├── firebase.ts          # Config Firebase
│   │   │   └── supabase.ts          # Config Supabase
│   │   ├── services/
│   │   │   ├── authService-supabase.ts       # Authentification
│   │   │   ├── supabaseDatabaseService.ts    # Base de données
│   │   │   ├── supabaseStorageService.ts     # Stockage fichiers
│   │   │   └── notificationService.ts        # Notifications
│   │   ├── utils/
│   │   │   └── mappers.ts           # Conversion snake_case ↔ camelCase
│   │   └── gateway-supabase.ts      # API Gateway unifiée
│   ├── components/
│   │   ├── Sidebar.tsx              # Menu latéral
│   │   ├── Header.tsx               # En-tête
│   │   ├── DashboardStats.tsx       # Statistiques
│   │   ├── ProjectList.tsx          # Liste projets
│   │   ├── DiscussionBoard.tsx      # Forum discussions
│   │   ├── AdminPanel.tsx           # Panel admin
│   │   ├── NotificationPanel.tsx    # Panel notifications
│   │   ├── MediaUploader.tsx        # Upload images/vidéos
│   │   ├── FileUploader.tsx         # Upload documents
│   │   ├── TechTagsInput.tsx        # Input technologies/tags
│   │   └── PDFPreviewModal.tsx      # Prévisualisation PDF
│   ├── types/
│   │   └── index.ts                 # Types TypeScript
│   ├── constants/
│   │   └── index.ts                 # Constantes (icônes, etc.)
│   ├── translations/
│   │   └── index.ts                 # Traductions (FR/EN)
│   ├── assets/
│   │   └── logo.png
│   ├── App.tsx                      # Composant principal
│   ├── index.html                     # Point d'entrée
│   └── index.tsx                    # Styles globaux
├── docs/
│   ├── supabase-schema.sql          # Schéma base de données
│   ├── api-documentation.md         # Doc API Gateway
│   └── deployment-guide.md          # Guide déploiement
├── .env.example                     # Variables d'environnement exemple
├── .gitignore
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

---

## 🔌 API Gateway

Toutes les interactions avec les services backend passent par l'API Gateway unifiée.

### Authentification

```typescript
import { apiGateway } from './api/gateway-supabase';

// Connexion
const user = await apiGateway.auth.login(email, password);

// Inscription
const newUser = await apiGateway.auth.register(userData);

// Connexion Google
const user = await apiGateway.auth.loginWithGoogle();

// Déconnexion
await apiGateway.auth.logout();

// Reset password
await apiGateway.auth.resetPassword(email);
```

### Projets

```typescript
// Récupérer tous les projets
const projects = await apiGateway.db.projects.getAll();

// Sauvegarder un projet
const savedProject = await apiGateway.db.projects.save(projectData, currentUser);

// Supprimer un projet
await apiGateway.db.projects.delete(projectId);
```

### Posts

```typescript
// Récupérer tous les posts
const posts = await apiGateway.db.posts.getAll();

// Sauvegarder un post
const savedPost = await apiGateway.db.posts.save(postData, currentUser);

// Supprimer un post
await apiGateway.db.posts.delete(postId);
```

### Notifications

```typescript
// Récupérer les notifications d'un utilisateur
const notifications = await apiGateway.notifications.getUserNotifications(userId);

// Créer une notification
await apiGateway.notifications.notifyPostLike(authorId, likerName, postTitle, postId);

// Marquer comme lu
await apiGateway.notifications.markAsRead(notificationId);

// Tout marquer comme lu
await apiGateway.notifications.markAllAsRead(userId);

// Supprimer
await apiGateway.notifications.delete(notificationId);
```

### Storage

```typescript
// Upload avatar
const avatarUrl = await apiGateway.storage.uploadAvatar(file);

// Upload image de couverture
const coverUrl = await apiGateway.storage.uploadCover(file);

// Upload vidéo
const videoUrl = await apiGateway.storage.uploadVideo(file);

// Upload document
const fileUrl = await apiGateway.storage.uploadFile(file);

// Supprimer un fichier
await apiGateway.storage.delete(filePath);
```

---

## 🔔 Système de notifications

### Types de notifications

| Type | Description | Déclencheur |
|------|-------------|------------|
| `post_like` | Quelqu'un a liké un post | Like sur post |
| `post_reply` | Nouveau commentaire sur un post | Commentaire |
| `comment_reply` | Réponse à un commentaire | Réponse |
| `project_like` | Quelqu'un a liké un projet | Like sur projet |
| `project_evaluation` | Projet évalué | Évaluation |
| `new_project` | Nouveau projet publié | Création projet |
| `post_deleted` | Post supprimé par admin | Suppression |
| `project_deleted` | Projet supprimé par admin | Suppression |

### Fonctionnement

1. **Événement** déclenché (ex: like sur post)
2. **Service de notification** crée une entrée en base
3. **Polling** (30s) ou **Realtime** détecte la nouvelle notification
4. **Badge** se met à jour
5. **Utilisateur** clique sur la notification
6. **Redirection** vers le contenu concerné

### Persistance

Les notifications sont stockées dans Supabase et persistent :
- Entre les sessions
- Sur plusieurs appareils
- Même après déconnexion/reconnexion

---

## 👥 Gestion des rôles

### Étudiant (`student`)

**Permissions :**
- ✅ Créer/Modifier/Supprimer ses propres projets
- ✅ Créer/Commenter des discussions
- ✅ Liker des projets et posts
- ✅ Voir tous les projets
- ❌ Évaluer des projets
- ❌ Voir les comptes en attente
- ❌ Actions de modération

### Enseignant (`lecturer`)

**Permissions :**
- ✅ Toutes les permissions étudiant
- ✅ Voir tous les projets de tous les étudiants
- ✅ Évaluer les projets
- ✅ Créer des annonces
- ❌ Gérer les utilisateurs
- ❌ Actions administratives

### Administrateur (`admin`)

**Permissions :**
- ✅ Toutes les permissions enseignant
- ✅ Approuver/Rejeter les nouveaux comptes
- ✅ Bannir/Débannir des utilisateurs
- ✅ Promouvoir des utilisateurs
- ✅ Supprimer n'importe quel projet/post
- ✅ Bloquer/Débloquer des posts
- ✅ Accès au panel d'administration

---

## 🚀 Déploiement

### Déploiement sur Vercel

1. **Fork** le repository
2. Connecter à **Vercel**
3. Importer le projet
4. Ajouter les **variables d'environnement** :
   ```
   VITE_FIREBASE_API_KEY=...
   VITE_FIREBASE_AUTH_DOMAIN=...
   VITE_SUPABASE_URL=...
   VITE_SUPABASE_ANON_KEY=...
   ```
5. **Deploy** !

### Déploiement sur Netlify

1. Connecter à **Netlify**
2. Nouveau site depuis Git
3. Build command: `npm run build`
4. Publish directory: `dist`
5. Ajouter les **environment variables**
6. **Deploy** !

### Build de production

```bash
npm run build
# Le dossier dist/ contient les fichiers statiques
```

---

## 🤝 Contribution

Les contributions sont les bienvenues !

### Comment contribuer

1. **Fork** le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une **Pull Request**

### Guidelines

- Utiliser **TypeScript** pour tout nouveau code
- Suivre les conventions de nommage existantes
- Ajouter des tests si applicable
- Mettre à jour la documentation
- Respecter le style de code (Prettier/ESLint)

### Rapporter un bug

Ouvrir une **issue** avec :
- Description claire du problème
- Étapes pour reproduire
- Comportement attendu vs observé
- Captures d'écran si pertinent
- Environnement (OS, navigateur, version)

---

## 💬 Support

- **Documentation** : Voir `/docs`
- **Issues** : [GitHub Issues](https://github.com/nismel-b/CampusWork_/issues)
- **Email** : support@campuswork.com


---

## 📄 Licence

Ce projet est sous licence **MIT** - voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👏 Remerciements

- **React** - Framework UI
- **Vite** - Build tool
- **Tailwind CSS** - Framework CSS
- **Firebase** - Authentication
- **Supabase** - Backend as a Service
- **Lucide** - Icônes
- Tous les contributeurs du projet !

---

## 📊 Statistiques

![GitHub stars](https://img.shields.io/github/stars/votre-username/campuswork?style=social)
![GitHub forks](https://img.shields.io/github/forks/votre-username/campuswork?style=social)
![GitHub issues](https://img.shields.io/github/issues/votre-username/campuswork)
![GitHub license](https://img.shields.io/github/license/votre-username/campuswork)

---

<div align="center">
  
**Fait par l'équipe CampusWork**

[Site web](https://campuswork.com) • [Documentation](https://docs.campuswork.com) • [Blog](https://blog.campuswork.com)

</div>