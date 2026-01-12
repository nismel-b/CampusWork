
import { User, Project, Post, UserRole, ProjectStatus } from '../types';
import { INITIAL_PROJECTS, INITIAL_POSTS, INITIAL_USERS } from '../mockData';

import { authService } from './services/authService';
import { storageService } from './services/storageService';
import { codeService } from './services/codeService';
import { multimediaService } from './services/multimediaService';
import { collaborationService } from './services/collaborationService';
import { firestoreService } from './services/firestoreService';
import { notificationService } from './services/notificationService';

/**
 * CAMPUSWORK UNIFIED API GATEWAY
 * Architecture : Firebase Auth (Identity), Firestore (Database), Novu (Notifications).
 * Ce point d'entrée centralise tous les services métier.
 */
export const apiGateway = {
  // Service d'authentification (Désormais basé sur l'architecture Firebase Auth)
  auth: authService,
  
  // Stockage de fichiers (Via Cloudinary pour les assets multimédia)
  storage: storageService,
  
  // Services spécialisés
  code: codeService,
  multimedia: multimediaService,
  collaboration: collaborationService,
  notifications: notificationService,

  // Opérations de données (Persistance Firestore)
  db: {
    projects: {
      getAll: async (): Promise<Project[]> => {
        const remote = await firestoreService.getCollection('projects');
        return remote.length > 0 ? (remote as Project[]) : INITIAL_PROJECTS;
      },
      save: async (project: Partial<Project>, author: User): Promise<Project> => {
        let savedProject: Project;
        if (project.id) {
          savedProject = await firestoreService.updateDocument('projects', project.id, project) as Project;
          
          // Déclenchement notification Novu si une évaluation est ajoutée par un enseignant
          if (project.grade) {
            notificationService.notifyEvaluation(savedProject.authorId, savedProject.title, project.grade);
          }
        } else {
          const newProj = {
            ...project,
            authorId: author.id,
            authorName: author.name,
            createdAt: new Date().toISOString().split('T')[0],
            status: project.status || ProjectStatus.IN_PROGRESS,
            likes: 0,
            likedBy: [],
            reviews: []
          };
          savedProject = await firestoreService.addDocument('projects', newProj) as Project;
          
          // Notification Novu aux admins lors de la création d'un nouveau projet
          notificationService.notifyNewProject(author.name, savedProject.title);
        }
        return savedProject;
      },
      delete: async (id: string): Promise<void> => {
        await firestoreService.deleteDocument('projects', id);
      }
    },
    posts: {
      getAll: async (): Promise<Post[]> => {
        const remote = await firestoreService.getCollection('posts');
        return remote.length > 0 ? (remote as Post[]) : INITIAL_POSTS;
      },
      save: async (post: Partial<Post>, author: User): Promise<Post> => {
        if (post.id) {
          return await firestoreService.updateDocument('posts', post.id, post) as Post;
        }
        const newPost = {
          ...post,
          authorId: author.id,
          authorName: author.name,
          createdAt: new Date().toLocaleDateString(),
          likes: 0,
          likedBy: [],
          comments: 0,
          replies: []
        };
        const savedPost = await firestoreService.addDocument('posts', newPost) as Post;
        return savedPost;
      }
    },
    users: {
      getAll: async (): Promise<User[]> => {
        const remote = await firestoreService.getCollection('users');
        return remote.length > 0 ? (remote as User[]) : INITIAL_USERS;
      },
      update: async (id: string, updates: Partial<User>): Promise<User> => {
        return await firestoreService.updateDocument('users', id, updates) as User;
      }
    }
  }
};
