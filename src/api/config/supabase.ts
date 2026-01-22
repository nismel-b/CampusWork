/// src/api/config/supabase.ts
import { createClient } from '@supabase/supabase-js';

/**
 * CONFIGURATION SUPABASE
 * Remplacez par vos propres credentials
 */

const SUPABASE_URL =  'https://tzcowyscbrhilmkmpisy.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6Y293eXNjYnJoaWxta21waXN5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg0NDk4ODMsImV4cCI6MjA4NDAyNTg4M30.aPoDswvc9Umhj4avllzyzEcm_K0kMSciRd9KDISTexc';

// Créer le client Supabase
export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    persistSession: false, // Firebase Auth gère déjà les sessions
  }
});

/**
 * NOMS DES TABLES SUPABASE
 * Convention: snake_case (standard SQL)
 */
export const TABLES = {
  USERS: 'users',
  PROJECTS: 'projects',
  POSTS: 'posts',
  NOTIFICATIONS: 'notifications',
} as const;

/**
 * NOMS DES BUCKETS STORAGE
 */
export const STORAGE_BUCKETS = {
  AVATARS: 'avatars',
  COVERS: 'project-covers',        
  VIDEOS: 'project-videos',        
  FILES: 'project-files',          
} as const;

/**
 * SCHÉMA SQL POUR CRÉATION DES TABLES
 * À exécuter dans l'éditeur SQL Supabase
 */
export const SQL_SCHEMA = `
-- Table utilisateurs
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY, -- UID Firebase
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  avatar TEXT,
  role TEXT DEFAULT 'student',
  matricule TEXT,
  level TEXT,
  department TEXT,
  status TEXT,
  cycle TEXT,
  bio TEXT,
  pending BOOLEAN DEFAULT true,
  banned BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table projets
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  author_name TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  subject TEXT,
  status TEXT DEFAULT 'in_progress',
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
  technologies TEXT[] DEFAULT '{}',
  tags TEXT[] DEFAULT '{}',
  attached_file JSONB,
  reviews JSONB DEFAULT '[]',
  likes INTEGER DEFAULT 0,
  liked_by TEXT[] DEFAULT '{}',
  is_evaluated BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table posts/discussions
CREATE TABLE IF NOT EXISTS posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  author_name TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT DEFAULT 'Discussion',
  likes INTEGER DEFAULT 0,
  liked_by TEXT[] DEFAULT '{}',
  comments INTEGER DEFAULT 0,
  replies JSONB DEFAULT '[]',
  blocked BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table notifications
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour performances
CREATE INDEX IF NOT EXISTS idx_projects_author ON projects(author_id);
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_posts_author ON posts(author_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, read);

-- Activer Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Politiques RLS (à adapter selon vos besoins)
CREATE POLICY "Users publics en lecture" ON users FOR SELECT USING (NOT banned);
CREATE POLICY "Projets publics en lecture" ON projects FOR SELECT USING (true);
CREATE POLICY "Posts publics en lecture" ON posts FOR SELECT USING (NOT blocked);
CREATE POLICY "Notifications privées" ON notifications FOR SELECT USING (auth.uid()::text = user_id);

-- Fonctions trigger pour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
`;

/**
 * CONFIGURATION DES BUCKETS STORAGE
 * À créer manuellement dans l'interface Supabase ou via API
 */
export const STORAGE_CONFIG = {
  avatars: {
    public: true,
    fileSizeLimit: 5 * 1024 * 1024, // 5MB
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
  },
  'project-covers': {
    public: true,
    fileSizeLimit: 10 * 1024 * 1024, // 10MB
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp']
  },
  'project-videos': {
    public: true,
    fileSizeLimit: 100 * 1024 * 1024, // 100MB
    allowedMimeTypes: ['video/mp4', 'video/webm', 'video/quicktime']
  },
  'project-files': {
    public: false,
    fileSizeLimit: 100 * 1024 * 1024, // 50MB
    allowedMimeTypes: [
      'application/pdf',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'application/zip',
      'application/x-rar-compressed'
    ]
  }
};