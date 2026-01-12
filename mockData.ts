
import { User, Project, ProjectStatus, UserRole, Post } from './types';

export const INITIAL_USERS: User[] = [
  { 
    id: '1', 
    name: 'Admin System', 
    email: 'admin@school.edu', 
    role: UserRole.ADMIN, 
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Admin',
    bio: "Administrateur principal de la plateforme CampusWork.",
    status: "Staff",
    cycle: "Administration"
  },
  { 
    id: '2', 
    name: 'Marie Dubois', 
    email: 'marie.dubois@school.edu', 
    role: UserRole.STUDENT, 
    matricule: '20210001', 
    level: 'Licence 3', 
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Marie',
    bio: "Passionnée par le développement Web et l'Intelligence Artificielle. Actuellement en dernière année de licence.",
    status: "Undergraduate",
    cycle: "Licence"
  },
  { 
    id: '3', 
    name: 'Jean Martin', 
    email: 'jean.martin@school.edu', 
    role: UserRole.STUDENT, 
    matricule: '20210002', 
    level: 'Master 1', 
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jean',
    bio: "Spécialiste en Analyse de Données et Statistiques. Curieux de découvrir de nouvelles technologies.",
    status: "Graduate",
    cycle: "Master"
  },
  { 
    id: '4', 
    name: 'Dr. Robert Smith', 
    email: 'r.smith@school.edu', 
    role: UserRole.LECTURER, 
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Robert',
    bio: "Professeur de Génie Logiciel avec plus de 15 ans d'expérience dans l'industrie.",
    status: "Faculty",
    cycle: "Doctorat"
  },
  { 
    id: '5', 
    name: 'Sophie Laurent', 
    email: 'sophie.laurent@school.edu', 
    role: UserRole.STUDENT, 
    pending: true, 
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophie',
    bio: "Nouvelle étudiante intéressée par le design UX/UI.",
    status: "Undergraduate",
    cycle: "Licence"
  } as any,
  { 
    id: '6', 
    name: 'Thomas Bernard', 
    email: 'thomas.bernard@school.edu', 
    role: UserRole.LECTURER, 
    pending: true, 
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Thomas',
    bio: "Intervenant professionnel en Cybersécurité.",
    status: "Faculty",
    cycle: "Expertise"
  } as any,
];

export const INITIAL_PROJECTS: Project[] = [
  {
    id: 'p1',
    title: 'Système de Gestion Bibliothèque',
    description: 'Application web pour gérer les emprunts et les retours de livres dans une bibliothèque universitaire. Le projet inclut une interface pour les bibliothécaires et une pour les étudiants, permettant la réservation en ligne et le suivi des amendes.',
    category: 'Génie Logiciel',
    subject: 'Génie Logiciel Avancé',
    status: ProjectStatus.IN_PROGRESS,
    isEvaluated: false,
    authorId: '2',
    authorName: 'Marie Dubois',
    members: 2,
    collaborators: [{ name: 'Jean Martin', email: 'jean.martin@school.edu' }],
    githubLink: 'https://github.com/marie/biblio-manager',
    coverImage: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800',
    demoVideo: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    videoType: 'youtube',
    lecturerName: 'Dr. Robert Smith',
    lecturerEmail: 'r.smith@school.edu',
    tags: ['Web Development', 'SQL', 'React'],
    createdAt: '2024-11-01',
    likes: 5,
    likedBy: []
  },
  {
    id: 'p2',
    title: 'Système de Détection de Fraude',
    description: 'Modèle de machine learning pour détecter les transactions frauduleuses en utilisant des algorithmes de classification comme Random Forest et XGBoost. Analyse de plus de 100 000 transactions simulées.',
    category: 'Intelligence Artificielle',
    subject: 'Machine Learning & Big Data',
    status: ProjectStatus.COMPLETED,
    isEvaluated: true,
    authorId: '2',
    authorName: 'Marie Dubois',
    members: 1,
    collaborators: [],
    grade: 'A',
    linkedinLink: 'https://linkedin.com/in/mariedubois',
    githubLink: 'https://github.com/marie/fraud-detection',
    lecturerName: 'Dr. Robert Smith',
    lecturerEmail: 'r.smith@school.edu',
    tags: ['AI/ML', 'Python', 'Pandas'],
    createdAt: '2024-10-15',
    likes: 12,
    likedBy: [],
    reviews: [
      { id: 'rev1', authorId: '4', authorName: 'Dr. Robert Smith', rating: 19, comment: "Excellent travail sur les algorithmes. La structure du code est exemplaire.", createdAt: '2024-10-20' }
    ]
  },
  {
    id: 'p3',
    title: 'Analyse des Réseaux Sociaux',
    description: 'Étude comportementale des utilisateurs sur les plateformes de micro-blogging via une analyse de sentiment automatisée et une visualisation des graphes de connexions.',
    category: 'Data Science',
    subject: 'Analyse de Données Complexes',
    status: ProjectStatus.COMPLETED,
    isEvaluated: false,
    authorId: '3',
    authorName: 'Jean Martin',
    members: 3,
    collaborators: [{ name: 'Marie Dubois', email: 'marie.dubois@school.edu' }, { name: 'Thomas B.', email: 'thomas.b@school.edu' }],
    githubLink: 'https://github.com/jean/social-analysis',
    otherLink: 'https://social-analysis-demo.com',
    tags: ['R', 'Statistics', 'NLP'],
    createdAt: '2024-11-10',
    likes: 8,
    likedBy: []
  }
];

export const INITIAL_POSTS: Post[] = [
  {
    id: 'post1',
    authorId: '2',
    authorName: 'Marie Dubois',
    title: 'Besoin d\'aide sur React Hooks',
    content: 'Je travaille sur mon projet et j\'ai du mal à comprendre useEffect. Quelqu\'un peut m\'expliquer?',
    category: 'Aide',
    likes: 1,
    likedBy: [],
    comments: 1,
    createdAt: '2024-11-27',
    replies: [
      {
        id: 'c1',
        authorId: '3',
        authorName: 'Jean Martin',
        content: 'useEffect est comme componentDidMount et componentDidUpdate combinés. Je peux te montrer des exemples si tu veux.',
        createdAt: '2024-11-28'
      }
    ]
  }
];
