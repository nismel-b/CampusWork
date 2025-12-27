# Project Upload Service – CampusWork

Ce projet est un microservice backend permettant aux étudiants de déposer et gérer des projets universitaires dans une bibliothèque numérique.

Le service est conçu pour être indépendant des autres composants (authentification, frontend) et respecte une architecture orientée microservices.

---

## Fonctionnalités principales

- Création de projets universitaires
- Upload de fichiers (PDF, images, vidéos, archives ZIP)
- Gestion des métadonnées (titre, université, année, mots-clés, etc.)
- Association d’un lien GitHub à un projet
- Accès public aux fichiers uploadés via URL
- Vérification de l’utilisateur via un service d’authentification externe
- Stockage persistant via Docker volumes

---

## Stack technique

- Node.js (Express)
- MongoDB
- Multer (gestion des fichiers)
- Docker / Docker Compose
- Nginx (reverse proxy)
- HTTPS via Let’s Encrypt

---

## Architecture

Client (Frontend)
|
v
Nginx (HTTPS)
|
v
Upload Service (Express)
|
v
MongoDB

Les fichiers uploadés sont stockés localement sur le serveur via un volume Docker.

---

## Installation (développement local)

### Prérequis
- Docker
- Docker Compose

### Lancer le service

```bash
docker-compose up --build

Le service est accessible sur :
http://localhost:4001

## Endpoints principaux
POST /projects

Permet à un étudiant authentifié de créer un projet et uploader des fichiers.

Authentification : Bearer Token

Type : multipart/form-data

Champs principaux :

title

abstract

university

department

year

githubUrl (optionnel)

keywords (séparés par virgule)

files (1 à 10 fichiers)

Sécurité

Le service ne gère pas directement l’authentification

Les tokens sont vérifiés auprès d’un service externe

Seuls les utilisateurs avec le rôle student peuvent uploader

Évolutions possibles

Modération des projets

Recherche avancée

Stockage cloud

Statistiques et téléchargements