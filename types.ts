/*
export enum UserRole {
  STUDENT = 'STUDENT',
  LECTURER = 'LECTURER',
  ADMIN = 'ADMIN'
}

export enum ProjectStatus {
  IN_PROGRESS = 'En cours',
  COMPLETED = 'Terminé'
}

export type LetterGrade = 'A' | 'B+' | 'B' | 'C+' | 'C' | 'D+' | 'D' | 'F';

export type PostCategory = 'Aide' | 'Discussion' | 'Annonce' | 'Exercices';

export interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  avatar?: string;
  matricule?: string;
  level?: string;
  pending?: boolean;
  banned?: boolean;
  bio?: string;
  status?: string; // e.g., 'Diplômé', 'Étudiant', 'Ancien'
  cycle?: string;  // e.g., 'Licence', 'Master', 'Doctorat'
}

export interface Collaborator {
  name: string;
  email: string;
  level?: string;
}

export interface Review {
  id: string;
  authorId: string;
  authorName: string;
  rating: number; // 0-20
  comment: string;
  createdAt: string;
}

export interface Project {
  id: string;
  title: string;
  description: string;
  category: string; 
  subject: string;
  status: ProjectStatus;
  isEvaluated?: boolean;
  authorId: string;
  authorName: string;
  members: number;
  collaborators: Collaborator[];
  githubLink?: string;
  linkedinLink?: string;
  otherLink?: string;
  lecturerName?: string;
  lecturerEmail?: string;
  studentLevel?: string;
  grade?: LetterGrade;
  tags: string[];
  createdAt: string;
  likes?: number;
  likedBy?: string[];
  reviews?: Review[];
}

export interface Post {
  id: string;
  authorId: string;
  authorName: string;
  title: string;
  content: string;
  category: PostCategory;
  likes: number;
  likedBy?: string[];
  comments: number;
  createdAt: string;
  replies?: Comment[];
  deadline?: string;
  blocked?: boolean;
}

export interface Comment {
  id: string;
  authorId: string;
  authorName: string;
  content: string;
  createdAt: string;
  likes?: number;
  likedBy?: string[];
  replies?: Comment[];
}

export type View = 'dashboard' | 'projects' | 'users' | 'posts' | 'settings' | 'discussion_detail' | 'project_detail' | 'project_edit';
export type Language = 'FR' | 'EN';
*/

export enum UserRole {
  STUDENT = 'STUDENT',
  LECTURER = 'LECTURER',
  ADMIN = 'ADMIN'
}

export enum ProjectStatus {
  IN_PROGRESS = 'En cours',
  COMPLETED = 'Terminé'
}

export type LetterGrade = 'A' | 'B+' | 'B' | 'C+' | 'C' | 'D+' | 'D' | 'F';

export type PostCategory = 'Aide' | 'Discussion' | 'Annonce' | 'Exercices';

export interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  avatar?: string;
  matricule?: string;
  level?: string;
  pending?: boolean;
  banned?: boolean;
  bio?: string;
  status?: string;
  cycle?: string;
}

export interface Collaborator {
  name: string;
  email: string;
  level?: string;
}

export interface Review {
  id: string;
  authorId: string;
  authorName: string;
  rating: number;
  comment: string;
  createdAt: string;
}

export interface Project {
  id: string;
  title: string;
  description: string;
  category: string; 
  subject: string;
  status: ProjectStatus;
  isEvaluated?: boolean;
  authorId: string;
  authorName: string;
  members: number;
  collaborators: Collaborator[];
  githubLink?: string;
  linkedinLink?: string;
  otherLink?: string;
  lecturerName?: string;
  lecturerEmail?: string;
  studentLevel?: string;
  grade?: LetterGrade;
  tags: string[];
  createdAt: string;
  likes?: number;
  likedBy?: string[];
  reviews?: Review[];
  
  // 🆕 NOUVEAUX CHAMPS MÉDIA
  coverImage?: string;      // URL de l'image de couverture (Cloudinary)
  demoVideo?: string;       // URL de la vidéo de démo (Cloudinary ou YouTube/Vimeo)
  videoType?: 'upload' | 'youtube' | 'vimeo'; // Type de vidéo
}

export interface Post {
  id: string;
  authorId: string;
  authorName: string;
  title: string;
  content: string;
  category: PostCategory;
  likes: number;
  likedBy?: string[];
  comments: number;
  createdAt: string;
  replies?: Comment[];
  deadline?: string;
  blocked?: boolean;
}

export interface Comment {
  id: string;
  authorId: string;
  authorName: string;
  content: string;
  createdAt: string;
  likes?: number;
  likedBy?: string[];
  replies?: Comment[];
}

export type View = 'dashboard' | 'projects' | 'users' | 'posts' | 'settings' | 'discussion_detail' | 'project_detail' | 'project_edit';
export type Language = 'FR' | 'EN';