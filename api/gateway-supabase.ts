// src/api/gateway-supabase.ts
/*import { User, Project, Post, ProjectStatus } from '../types';
import { authService } from './services/authService-supabase'; // Firebase Auth (inchangé)
import { supabaseDatabaseService } from './services/supabaseDatabaseService';
import { supabaseStorageService } from './services/supabaseStorageService';
import { notificationService } from './services/notificationService'; // FCM (inchangé)
import { TABLES } from './config/supabase';*/

// src/api/gateway-supabase.ts
import { User, Project, Post, ProjectStatus } from '../types';
import { authService } from './services/authService-supabase';
import { supabaseDatabaseService } from './services/supabaseDatabaseService';
import { supabaseStorageService } from './services/supabaseStorageService';
import { notificationService } from './services/notificationService';
import { TABLES } from './config/supabase';
import { normalizeProject, 
  denormalizeProject, 
  normalizePost, 
  denormalizePost 
} from './utils/mappers';
/**
 * 🔄 HELPERS DE CONVERSION snake_case ↔ camelCase
 */

// Convertir un projet Supabase (snake_case) → Frontend (camelCase)
/*const normalizeProject = (proj: any): Project => {
  if (!proj) return proj;
  
  return {
    id: proj.id,
    authorId: proj.author_id || proj.authorId,
    authorName: proj.author_name || proj.authorName,
    title: proj.title,
    description: proj.description,
    category: proj.category,
    subject: proj.subject,
    status: proj.status,
    grade: proj.grade,
    coverImage: proj.cover_image || proj.coverImage,
    demoVideo: proj.demo_video || proj.demoVideo,
    videoType: proj.video_type || proj.videoType,
    githubLink: proj.github_link || proj.githubLink,
    linkedinLink: proj.linkedin_link || proj.linkedinLink,
    otherLink: proj.other_link || proj.otherLink,
    lecturerName: proj.lecturer_name || proj.lecturerName,
    lecturerEmail: proj.lecturer_email || proj.lecturerEmail,
    studentLevel: proj.student_level || proj.studentLevel,
    collaborators: proj.collaborators || [],
    technologies: proj.technologies || [],
    tags: proj.tags || [],
    attachedFile: proj.attached_file || proj.attachedFile, // ✅ Conversion ici
    reviews: proj.reviews || [],
    likes: proj.likes || 0,
    likedBy: proj.liked_by || proj.likedBy || [],
    isEvaluated: proj.is_evaluated ?? proj.isEvaluated ?? false,
    createdAt: proj.created_at || proj.createdAt,
  };
};

// Convertir un projet Frontend (camelCase) → Supabase (snake_case)
const denormalizeProject = (proj: Partial<Project>): any => {
  const result: any = {};
  
  if (proj.authorId !== undefined) result.author_id = proj.authorId;
  if (proj.authorName !== undefined) result.author_name = proj.authorName;
  if (proj.title !== undefined) result.title = proj.title;
  if (proj.description !== undefined) result.description = proj.description;
  if (proj.category !== undefined) result.category = proj.category;
  if (proj.subject !== undefined) result.subject = proj.subject;
  if (proj.status !== undefined) result.status = proj.status;
  if (proj.grade !== undefined) result.grade = proj.grade;
  if (proj.coverImage !== undefined) result.cover_image = proj.coverImage;
  if (proj.demoVideo !== undefined) result.demo_video = proj.demoVideo;
  if (proj.videoType !== undefined) result.video_type = proj.videoType;
  if (proj.githubLink !== undefined) result.github_link = proj.githubLink;
  if (proj.linkedinLink !== undefined) result.linkedin_link = proj.linkedinLink;
  if (proj.otherLink !== undefined) result.other_link = proj.otherLink;
  if (proj.lecturerName !== undefined) result.lecturer_name = proj.lecturerName;
  if (proj.lecturerEmail !== undefined) result.lecturer_email = proj.lecturerEmail;
  if (proj.studentLevel !== undefined) result.student_level = proj.studentLevel;
  if (proj.collaborators !== undefined) result.collaborators = proj.collaborators;
  if (proj.technologies !== undefined) result.technologies = proj.technologies;
  if (proj.tags !== undefined) result.tags = proj.tags;
  if (proj.attachedFile !== undefined) result.attached_file = proj.attachedFile; // ✅ Conversion ici
  if (proj.reviews !== undefined) result.reviews = proj.reviews;
  if (proj.likes !== undefined) result.likes = proj.likes;
  if (proj.likedBy !== undefined) result.liked_by = proj.likedBy;
  if (proj.isEvaluated !== undefined) result.is_evaluated = proj.isEvaluated;
  
  return result;
};

// Convertir un post Supabase → Frontend
const normalizePost = (post: any): Post => {
  if (!post) return post;
  
  return {
    id: post.id,
    authorId: post.author_id || post.authorId,
    authorName: post.author_name || post.authorName,
    title: post.title,
    content: post.content,
    category: post.category,
    likes: post.likes || 0,
    likedBy: post.liked_by || post.likedBy || [],
    comments: post.comments || 0,
    replies: post.replies || [],
    blocked: post.blocked || false,
    createdAt: post.created_at || post.createdAt,
  };
};

// Convertir un post Frontend → Supabase
const denormalizePost = (post: Partial<Post>): any => {
  const result: any = {};
  
  if (post.authorId !== undefined) result.author_id = post.authorId;
  if (post.authorName !== undefined) result.author_name = post.authorName;
  if (post.title !== undefined) result.title = post.title;
  if (post.content !== undefined) result.content = post.content;
  if (post.category !== undefined) result.category = post.category;
  if (post.likes !== undefined) result.likes = post.likes;
  if (post.likedBy !== undefined) result.liked_by = post.likedBy;
  if (post.comments !== undefined) result.comments = post.comments;
  if (post.replies !== undefined) result.replies = post.replies;
  if (post.blocked !== undefined) result.blocked = post.blocked;
  
  return result;
};*/

/**
 * CAMPUSWORK UNIFIED API GATEWAY (SUPABASE VERSION)
 */
export const apiGateway = {
  // ✅ Service d'authentification (FIREBASE)
  auth: authService,

  // 🆕 Stockage de fichiers (SUPABASE STORAGE)
  storage: {
    uploadAvatar: supabaseStorageService.uploadAvatar,
    uploadCover: supabaseStorageService.uploadCover,
    uploadVideo: supabaseStorageService.uploadVideo,
    uploadFile: supabaseStorageService.uploadFile,
    delete: supabaseStorageService.delete,
  },

  // ✅ Notifications (FCM)
  notifications: notificationService,

  // 🆕 Opérations de données (SUPABASE DATABASE)
  db: {
    projects: {
      /**
       * Récupère tous les projets
       */
      getAll: async (): Promise<Project[]> => {
        try {
          const rawProjects = await supabaseDatabaseService.getCollection<any>(TABLES.PROJECTS);
          // ✅ Convertir snake_case → camelCase
          return rawProjects.map(normalizeProject);
        } catch (error: any) {
          console.error('Erreur getAll projects:', error);
          return [];
        }
      },

      /**
       * Sauvegarde ou met à jour un projet
       */
      save: async (project: Partial<Project>, author: User): Promise<Project> => {
        try {
          let savedProject: any;

          // ✅ Convertir camelCase → snake_case avant d'envoyer à Supabase
          const supabaseProject = denormalizeProject(project);

          if (project.id) {
            // Mise à jour
            savedProject = await supabaseDatabaseService.updateDocument<any>(
              TABLES.PROJECTS,
              project.id,
              {
                ...supabaseProject,
                updated_at: new Date().toISOString(),
              }
            );

            // Notification si évaluation ajoutée
            if (project.grade && project.isEvaluated) {
              await notificationService.notifyEvaluation(
                savedProject.author_id,
                savedProject.title,
                project.grade
              );
            }
          } else {
            // Création
            const newProj = {
              ...supabaseProject,
              author_id: author.id,
              author_name: author.name,
              status: project.status || ProjectStatus.IN_PROGRESS,
              likes: 0,
              liked_by: [],
              is_evaluated: false,
            };

            savedProject = await supabaseDatabaseService.addDocument<any>(
              TABLES.PROJECTS,
              newProj
            );

            // Notification nouveau projet
            await notificationService.notifyNewProject(author.name, savedProject.title);
          }

          // ✅ Convertir snake_case → camelCase avant de retourner
          return normalizeProject(savedProject);
        } catch (error: any) {
          console.error('Erreur save project:', error);
          throw new Error(error.message || 'Impossible de sauvegarder le projet');
        }
      },

      /**
       * Supprime un projet
       */
      delete: async (id: string): Promise<void> => {
        try {
          await supabaseDatabaseService.deleteDocument(TABLES.PROJECTS, id);
        } catch (error: any) {
          console.error('Erreur delete project:', error);
          throw new Error('Impossible de supprimer le projet');
        }
      },
    },

    posts: {
      /**
       * Récupère tous les posts
       */
      getAll: async (): Promise<Post[]> => {
        try {
          const rawPosts = await supabaseDatabaseService.getCollection<any>(TABLES.POSTS);
          // ✅ Convertir snake_case → camelCase
          return rawPosts.map(normalizePost);
        } catch (error: any) {
          console.error('Erreur getAll posts:', error);
          return [];
        }
      },


      /**
       * Sauvegarde ou met à jour un post
       */
      save: async (post: Partial<Post>, author: User): Promise<Post> => {
        try {
          let savedPost: any;
          
          // ✅ Convertir camelCase → snake_case
          const supabasePost = denormalizePost(post);

          if (post.id) {
            // Mise à jour
            savedPost = await supabaseDatabaseService.updateDocument<any>(
              TABLES.POSTS,
              post.id,
              supabasePost
            );
          } else {
            // Création
            const newPost = {
              ...supabasePost,
              author_id: author.id,
              author_name: author.name,
              likes: 0,
              liked_by: [],
              comments: 0,
              blocked: false,
            };

            savedPost = await supabaseDatabaseService.addDocument<any>(
              TABLES.POSTS, 
              newPost
            );
          }

          // ✅ Convertir snake_case → camelCase avant de retourner
          return normalizePost(savedPost);
        } catch (error: any) {
          console.error('Erreur save post:', error);
          throw new Error(error.message || 'Impossible de sauvegarder le post');
        }
      },

      /**
       * Supprime un post
       */
      delete: async (id: string): Promise<void> => {
        try {
          await supabaseDatabaseService.deleteDocument(TABLES.POSTS, id);
        } catch (error: any) {
          console.error('Erreur delete post:', error);
          throw new Error('Impossible de supprimer le post');
        }
      },
    },

    users: {
      /**
       * Récupère tous les utilisateurs
       */
      getAll: async (): Promise<User[]> => {
        try {
          return await supabaseDatabaseService.getCollection<User>(TABLES.USERS);
        } catch (error: any) {
          console.error('Erreur getAll users:', error);
          return [];
        }
      },

      /**
       * Récupère un utilisateur par ID
       */
      getById: async (id: string): Promise<User | null> => {
        try {
          return await supabaseDatabaseService.getDocument<User>(TABLES.USERS, id);
        } catch (error: any) {
          console.error('Erreur getById user:', error);
          return null;
        }
      },

      /**
       * Crée un utilisateur (avec UID Firebase)
       */
      create: async (id: string, userData: Partial<User>): Promise<void> => {
        try {
          await supabaseDatabaseService.setDocument(TABLES.USERS, id, userData);
        } catch (error: any) {
          console.error('Erreur create user:', error);
          throw new Error('Impossible de créer l\'utilisateur');
        }
      },

      /**
       * Met à jour un utilisateur
       */
      update: async (id: string, updates: Partial<User>): Promise<User> => {
        try {
          return await supabaseDatabaseService.updateDocument<User>(
            TABLES.USERS,
            id,
            updates
          );
        } catch (error: any) {
          console.error('Erreur update user:', error);
          throw new Error('Impossible de mettre à jour l\'utilisateur');
        }
      },

      /**
       * Supprime un utilisateur
       */
      delete: async (id: string): Promise<void> => {
        try {
          await supabaseDatabaseService.deleteDocument(TABLES.USERS, id);
        } catch (error: any) {
          console.error('Erreur delete user:', error);
          throw new Error('Impossible de supprimer l\'utilisateur');
        }
      },
    },
  },
};