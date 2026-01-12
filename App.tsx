
import React, { useState, useMemo, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import Header from './components/Header';
import DashboardStats from './components/DashboardStats';
import ProjectList from './components/ProjectList';
import AdminPanel from './components/AdminPanel';
import DiscussionBoard from './components/DiscussionBoard';
import { User, Project, UserRole, View, Post, ProjectStatus, Language, PostCategory, Comment, Review, LetterGrade } from './types';
import { INITIAL_USERS, INITIAL_PROJECTS, INITIAL_POSTS } from './mockData';
import { ICONS } from './constants';
import { translations } from './translations';
import { apiGateway } from './api/gateway';
import MediaUploader from './components/MediaUploader';

const LETTER_GRADES: LetterGrade[] = ['A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];

const App: React.FC = () => {
  // Auth state
  const [currentUser, setCurrentUser] = useState<User | null>(null); 
  const [authMode, setAuthMode] = useState<'login' | 'signup' | 'forgot'>('login');
  const [loginEmail, setLoginEmail] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [forgotEmail, setForgotEmail] = useState('');
  const [signupData, setSignupData] = useState({
    name: '',
    email: '',
    role: UserRole.STUDENT,
    password: '',
    matricule: '',
    level: '',
  });

  const [view, setView] = useState<View>('dashboard');
  const [language, setLanguage] = useState<Language>('FR');
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [dashboardTab, setDashboardTab] = useState<'all' | 'in_progress' | 'completed'>('all');
  
  const [users, setUsers] = useState<User[]>(INITIAL_USERS);
  const [projects, setProjects] = useState<Project[]>(INITIAL_PROJECTS);
  const [posts, setPosts] = useState<Post[]>(INITIAL_POSTS);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedPost, setSelectedPost] = useState<Post | null>(null);
  
  const [editingProject, setEditingProject] = useState<Partial<Project> | null>(null);
  const [consultingProject, setConsultingProject] = useState<Project | null>(null);
  const [newReview, setNewReview] = useState({ rating: 0, comment: '' });
  
  const [isPostModalOpen, setIsPostModalOpen] = useState(false);
  const [newPost, setNewPost] = useState<Partial<Post>>({ title: '', content: '', category: 'Discussion' });

  // Comment management state
  const [commentInput, setCommentInput] = useState('');
  const [replyingTo, setReplyingTo] = useState<{ commentId: string; authorName: string } | null>(null);
  const [editingCommentId, setEditingCommentId] = useState<string | null>(null);

  // Settings / Profile Form State
  const [profileForm, setProfileForm] = useState<Partial<User>>({});

  const t = translations[language];

  // Sync with ApiGateway on Mount
  useEffect(() => {
    const fetchAllData = async () => {
      try {
        const [proj, psts, usrs] = await Promise.all([
          apiGateway.db.projects.getAll(),
          apiGateway.db.posts.getAll(),
          apiGateway.db.users.getAll()
        ]);
        setProjects(proj);
        setPosts(psts);
        setUsers(usrs);
      } catch (error) {
        console.error("Erreur de synchronisation ApiGateway:", error);
      }
    };
    fetchAllData();
  }, []);

  useEffect(() => {
    setSearchQuery('');
    if (view === 'settings' && currentUser) {
      setProfileForm({
        name: currentUser.name,
        email: currentUser.email,
        status: currentUser.status || '',
        cycle: currentUser.cycle || '',
        bio: currentUser.bio || ''
      });
    }
  }, [view, currentUser]);

  const stats = useMemo(() => {
    if (!currentUser) return { totalUsers: 0, students: 0, lecturers: 0, pending: 0, totalProjectsCount: 0, inProgressCount: 0, completedCount: 0 };
    
    if (currentUser.role === UserRole.ADMIN) {
      return {
        totalUsers: users.filter(u => !u.pending).length,
        students: users.filter(u => u.role === UserRole.STUDENT && !u.pending).length,
        lecturers: users.filter(u => u.role === UserRole.LECTURER && !u.pending).length,
        pending: users.filter(u => u.pending).length,
      };
    }
    
    const contextProjects = projects.filter(p => 
      currentUser.role === UserRole.LECTURER || 
      p.authorId === currentUser.id || 
      p.collaborators?.some(c => c.name === currentUser.name)
    );
    
    return {
      totalProjectsCount: contextProjects.length,
      inProgressCount: contextProjects.filter(p => p.status === ProjectStatus.IN_PROGRESS).length,
      completedCount: contextProjects.filter(p => p.status === ProjectStatus.COMPLETED).length,
    };
  }, [users, projects, currentUser]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const user = await apiGateway.auth.login(loginEmail, loginPassword);
      setCurrentUser(user);
      // Re-fetch database to ensure we have the latest after login
      const [dbProj, dbPosts] = await Promise.all([
        apiGateway.db.projects.getAll(),
        apiGateway.db.posts.getAll()
      ]);
      setProjects(dbProj);
      setPosts(dbPosts);
    } catch (error: any) {
      alert(error.message);
    }
  };

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!signupData.name || !signupData.email || !signupData.password) return alert("Veuillez remplir les champs obligatoires.");
    
    try {
      const newUser = await apiGateway.auth.register(signupData);
      setUsers(prev => [...prev, newUser]);
      alert("Compte créé avec succès ! Votre accès est en attente d'approbation par un administrateur.");
      setAuthMode('login');
      setLoginEmail(signupData.email);
    } catch (error: any) {
      alert(error.message);
    }
  };

  const handleForgotPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await apiGateway.auth.resetPassword(forgotEmail);
      alert(`Un lien de réinitialisation a été envoyé à ${forgotEmail} (Simulation).`);
      setAuthMode('login');
    } catch (error: any) {
      alert(error.message);
    }
  };

  const handleAvatarChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !currentUser) return;

    try {
      // 1. Upload to Cloudinary
      const imageUrl = await apiGateway.storage.upload(file, 'avatars');
      // 2. Update Firestore profile
      const updatedUser = await apiGateway.db.users.update(currentUser.id, { avatar: imageUrl });
      // 3. Update UI states
      setCurrentUser(updatedUser);
      setUsers(prev => prev.map(u => u.id === currentUser.id ? updatedUser : u));
    } catch (error: any) {
      alert("Erreur lors de la mise à jour de la photo : " + error.message);
    }
  };

  const handleLike = (postId: string) => {
    if (!currentUser) return;
    setPosts(prev => prev.map(p => {
      if (p.id !== postId) return p;
      const likedBy = p.likedBy || [];
      const hasLiked = likedBy.includes(currentUser.id);
      const newLikedBy = hasLiked ? likedBy.filter(id => id !== currentUser.id) : [...likedBy, currentUser.id];
      const updatedPost = { ...p, likedBy: newLikedBy, likes: hasLiked ? Math.max(0, p.likes - 1) : p.likes + 1 };
      if (selectedPost && selectedPost.id === postId) setSelectedPost(updatedPost);
      return updatedPost;
    }));
  };

  const handleProjectLike = (projectId: string) => {
    if (!currentUser) return;
    setProjects(prev => prev.map(p => {
      if (p.id !== projectId) return p;
      const likedBy = p.likedBy || [];
      const hasLiked = likedBy.includes(currentUser.id);
      const newLikedBy = hasLiked ? likedBy.filter(id => id !== currentUser.id) : [...likedBy, currentUser.id];
      return { ...p, likedBy: newLikedBy, likes: hasLiked ? Math.max(0, (p.likes || 0) - 1) : (p.likes || 0) + 1 };
    }));
  };

  const filteredProjects = useMemo(() => {
    if (!currentUser) return [];
    let base = projects;
    if (currentUser.role === UserRole.STUDENT && view === 'projects') {
      base = projects.filter(p => p.authorId === currentUser.id || p.collaborators?.some(c => c.name === currentUser.name));
    }
    if (view === 'dashboard' || view === 'projects') {
      if (view === 'dashboard') {
        if (dashboardTab === 'in_progress') base = base.filter(p => p.status === ProjectStatus.IN_PROGRESS);
        else if (dashboardTab === 'completed') base = base.filter(p => p.status === ProjectStatus.COMPLETED);
      }
      if (searchQuery) {
        const query = searchQuery.toLowerCase();
        base = base.filter(p => 
          p.title.toLowerCase().includes(query) || 
          p.authorName.toLowerCase().includes(query) ||
          p.subject?.toLowerCase().includes(query) ||
          p.category.toLowerCase().includes(query)
        );
      }
      base = [...base].sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
    }
    return base;
  }, [projects, currentUser, searchQuery, view, dashboardTab]);

  const mainPosts = useMemo(() => {
    if (currentUser?.role === UserRole.ADMIN) return posts;
    return posts.filter(p => !p.blocked);
  }, [posts, currentUser]);

  const handleSavePost = async () => {
    if (!newPost.title || !newPost.content || !currentUser) return;
    
    try {
      const savedPost = await apiGateway.db.posts.save(newPost, currentUser);
      if (newPost.id) {
        setPosts(prev => prev.map(p => p.id === savedPost.id ? savedPost : p));
        if (selectedPost?.id === savedPost.id) setSelectedPost(savedPost);
      } else {
        setPosts(prev => [savedPost, ...prev]);
      }
      setIsPostModalOpen(false);
    } catch (error: any) {
      alert(error.message);
    }
  };

  const handleEditPost = (post: Post) => {
    setNewPost({ ...post });
    setIsPostModalOpen(true);
  };

  const handleDeletePost = (postId: string) => {
    if (window.confirm("Voulez-vous vraiment supprimer ce post ?")) {
      setPosts(prev => prev.filter(p => p.id !== postId));
      if (selectedPost?.id === postId) {
        setView('posts');
        setSelectedPost(null);
      }
    }
  };

  const handleCommentAction = () => {
    if (!commentInput.trim() || !currentUser || !selectedPost) return;

    const newComment: Comment = {
      id: `comment-${Date.now()}`,
      authorId: currentUser.id,
      authorName: currentUser.name,
      content: commentInput,
      createdAt: new Date().toLocaleDateString(),
      likes: 0,
      likedBy: [],
      replies: []
    };

    const updateComments = (comments: Comment[]): Comment[] => {
      if (replyingTo) {
        return comments.map(c => {
          if (c.id === replyingTo.commentId) {
            return { ...c, replies: [...(c.replies || []), newComment] };
          }
          if (c.replies) return { ...c, replies: updateComments(c.replies) };
          return c;
        });
      }
      return [...comments, newComment];
    };

    const updatedReplies = updateComments(selectedPost.replies || []);
    const updatedPost = { ...selectedPost, replies: updatedReplies, comments: selectedPost.comments + 1 };
    
    setPosts(prev => prev.map(p => p.id === selectedPost.id ? updatedPost : p));
    setSelectedPost(updatedPost);
    setCommentInput('');
    setReplyingTo(null);
  };

  const handleEditComment = (commentId: string, content: string) => {
    setCommentInput(content);
    setEditingCommentId(commentId);
  };

  const handleUpdateComment = () => {
    if (!editingCommentId || !currentUser || !selectedPost) return;

    const updateRecursive = (comments: Comment[]): Comment[] => {
      return comments.map(c => {
        if (c.id === editingCommentId) return { ...c, content: commentInput };
        if (c.replies) return { ...c, replies: updateRecursive(c.replies) };
        return c;
      });
    };

    const updatedReplies = updateRecursive(selectedPost.replies || []);
    const updatedPost = { ...selectedPost, replies: updatedReplies };
    
    setPosts(prev => prev.map(p => p.id === selectedPost.id ? updatedPost : p));
    setSelectedPost(updatedPost);
    setCommentInput('');
    setEditingCommentId(null);
  };

  const handleDeleteComment = (commentId: string) => {
    if (!selectedPost || !window.confirm("Supprimer ce commentaire ?")) return;

    let removedCount = 0;
    const deleteRecursive = (comments: Comment[]): Comment[] => {
      return comments.filter(c => {
        if (c.id === commentId) {
          removedCount += 1 + (c.replies?.length || 0);
          return false;
        }
        if (c.replies) c.replies = deleteRecursive(c.replies);
        return true;
      });
    };

    const updatedReplies = deleteRecursive(selectedPost.replies || []);
    const updatedPost = { ...selectedPost, replies: updatedReplies, comments: Math.max(0, selectedPost.comments - removedCount) };
    
    setPosts(prev => prev.map(p => p.id === selectedPost.id ? updatedPost : p));
    setSelectedPost(updatedPost);
  };

  const handleLikeComment = (commentId: string) => {
    if (!selectedPost || !currentUser) return;

    const likeRecursive = (comments: Comment[]): Comment[] => {
      return comments.map(c => {
        if (c.id === commentId) {
          const likedBy = c.likedBy || [];
          const hasLiked = likedBy.includes(currentUser.id);
          const newLikedBy = hasLiked ? likedBy.filter(id => id !== currentUser.id) : [...likedBy, currentUser.id];
          return { ...c, likedBy: newLikedBy, likes: hasLiked ? Math.max(0, (c.likes || 0) - 1) : (c.likes || 0) + 1 };
        }
        if (c.replies) return { ...c, replies: likeRecursive(c.replies) };
        return c;
      });
    };

    const updatedReplies = likeRecursive(selectedPost.replies || []);
    const updatedPost = { ...selectedPost, replies: updatedReplies };
    
    setPosts(prev => prev.map(p => p.id === selectedPost.id ? updatedPost : p));
    setSelectedPost(updatedPost);
  };

  const handleSaveProject = async () => {
    if (!editingProject || !currentUser) return;
    try {
      const savedProject = await apiGateway.db.projects.save(editingProject, currentUser);
      if (editingProject.id) {
        setProjects(prev => prev.map(p => p.id === savedProject.id ? savedProject : p));
      } else {
        setProjects(prev => [savedProject, ...prev]);
      }
      setView('projects');
      setEditingProject(null);
    } catch (error: any) {
      alert(error.message);
    }
  };

  const handleSaveProfile = async () => {
    if (!currentUser || !profileForm.name || !profileForm.email) return;
    
    try {
      const updatedUser = await apiGateway.db.users.update(currentUser.id, profileForm);
      setCurrentUser(updatedUser);
      setUsers(prev => prev.map(u => u.id === currentUser.id ? updatedUser : u));
      setProjects(prev => prev.map(p => p.authorId === currentUser.id ? { ...p, authorName: profileForm.name! } : p));
      setView('dashboard');
    } catch (error: any) {
      alert(error.message);
    }
  };

  const handleAddReview = () => {
    if (!consultingProject || !currentUser || (currentUser.role !== UserRole.ADMIN && currentUser.role !== UserRole.LECTURER)) return;
    const review: Review = {
      id: `rev-${Date.now()}`,
      authorId: currentUser.id,
      authorName: currentUser.name,
      rating: newReview.rating,
      comment: newReview.comment,
      createdAt: new Date().toLocaleDateString()
    };
    const updatedProject = {
      ...consultingProject,
      reviews: [...(consultingProject.reviews || []), review],
      isEvaluated: true 
    };
    setProjects(prev => prev.map(p => p.id === consultingProject.id ? updatedProject : p));
    setConsultingProject(updatedProject);
    setNewReview({ rating: 0, comment: '' });
  };

  const handleConsult = (project: Project) => {
    setConsultingProject(project);
    setView('project_detail');
  };

  const handleEdit = (project: Project) => {
    setEditingProject({ ...project });
    setView('project_edit');
  };

  const handleCreateProject = () => {
    setEditingProject({
      title: '',
      description: '',
      category: 'Génie Logiciel',
      subject: '',
      status: ProjectStatus.IN_PROGRESS,
      githubLink: '',
      linkedinLink: '',
      otherLink: '',
      coverImage: undefined,
      demoVideo: undefined,
      videoType: undefined,
      lecturerName: '',
      lecturerEmail: '',
      studentLevel: currentUser?.level || '',
      collaborators: [],
      tags: [],
      grade: undefined
    });
    setView('project_edit');
  };

  const authorData = useMemo(() => {
    if (!consultingProject) return null;
    return users.find(u => u.id === consultingProject.authorId) || null;
  }, [consultingProject, users]);

  const averageRating = useMemo(() => {
    if (!consultingProject || !consultingProject.reviews?.length) return null;
    return (consultingProject.reviews.reduce((acc, r) => acc + r.rating, 0) / consultingProject.reviews.length).toFixed(1);
  }, [consultingProject]);

  const CommentItem: React.FC<{ comment: Comment; isReply?: boolean }> = ({ comment, isReply }) => (
    <div className={`group animate-fadeIn ${isReply ? 'ml-12 mt-4' : 'mb-6'}`}>
      <div className={`p-6 rounded-[2rem] border transition-all ${comment.authorId === currentUser?.id ? 'bg-blue-50/30 border-blue-100 shadow-sm' : 'bg-white border-slate-100 shadow-sm'}`}>
        <div className="flex justify-between items-start mb-4">
          <div className="flex items-center gap-3">
             <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center text-slate-500 font-black text-[10px]">{comment.authorName.charAt(0)}</div>
             <div>
               <p className="font-black text-slate-900 text-xs">{comment.authorName}</p>
               <p className="text-[9px] text-slate-500 font-black uppercase tracking-widest">{comment.createdAt}</p>
             </div>
          </div>
          <div className="flex gap-2">
            <button 
              onClick={() => handleLikeComment(comment.id)}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl transition-all ${comment.likedBy?.includes(currentUser?.id || '') ? 'bg-red-500 text-white shadow-lg shadow-red-100' : 'bg-slate-50 text-slate-400 hover:text-red-500 hover:bg-red-50'}`}
            >
              <svg className={`w-3 h-3 ${comment.likedBy?.includes(currentUser?.id || '') ? 'fill-current' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>
              <span className="text-[10px] font-black">{comment.likes || 0}</span>
            </button>
            <button 
              onClick={() => setReplyingTo({ commentId: comment.id, authorName: comment.authorName })}
              className="px-3 py-1.5 bg-slate-50 text-slate-400 rounded-xl hover:text-blue-600 hover:bg-blue-50 transition-all text-[10px] font-black uppercase tracking-widest"
            >
              Répondre
            </button>
            {comment.authorId === currentUser?.id && (
              <>
                <button 
                  onClick={() => handleEditComment(comment.id, comment.content)}
                  className="p-1.5 text-slate-300 hover:text-blue-600 transition-all"
                  title="Modifier"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" /></svg>
                </button>
                <button 
                  onClick={() => handleDeleteComment(comment.id)}
                  className="p-1.5 text-slate-300 hover:text-red-600 transition-all"
                  title="Supprimer"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                </button>
              </>
            )}
          </div>
        </div>
        <p className="text-slate-600 text-sm font-medium leading-relaxed italic border-l-4 border-slate-100 pl-4">
          {comment.content}
        </p>
      </div>
      {comment.replies?.map(reply => (
        <CommentItem key={reply.id} comment={reply} isReply />
      ))}
    </div>
  );

  if (!currentUser) return (
    <div className="min-h-screen bg-[#0f172a] flex items-center justify-center p-6 selection:bg-blue-100 selection:text-blue-900 overflow-hidden relative">
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none">
        <div className="absolute top-[-10%] left-[-5%] w-[40%] h-[40%] bg-blue-600/20 blur-[120px] rounded-full"></div>
        <div className="absolute bottom-[-10%] right-[-5%] w-[40%] h-[40%] bg-blue-900/40 blur-[120px] rounded-full"></div>
        <div className="absolute top-[20%] right-[10%] w-[15%] h-[15%] bg-purple-600/10 blur-[80px] rounded-full"></div>
      </div>

      <div className="w-full max-w-5xl z-10 grid grid-cols-1 lg:grid-cols-2 gap-0 shadow-[0_35px_100px_-15px_rgba(0,0,0,0.6)] rounded-[4rem] overflow-hidden bg-white/5 backdrop-blur-sm border border-white/10 animate-fadeIn">
        <div className="hidden lg:flex flex-col justify-center p-16 bg-[#1e40af] text-white relative overflow-hidden">
          <div className="absolute top-0 left-0 w-full h-full opacity-10 pointer-events-none">
            <div className="absolute top-10 left-10 w-20 h-20 border-4 border-white rounded-full"></div>
            <div className="absolute bottom-20 right-10 w-40 h-40 border-8 border-white/30 rounded-[3rem] rotate-12"></div>
          </div>
          <div className="relative z-10 space-y-8">
            <div className="bg-white p-4 w-20 h-20 rounded-[2rem] shadow-2xl flex items-center justify-center">
              <svg className="w-12 h-12 text-blue-700" fill="currentColor" viewBox="0 0 20 20">
                <path d="M9 4.804A7.993 7.993 0 002 12a5 5 0 005 5 5 5 0 005-5V4.804z" />
                <path fillRule="evenodd" d="M2 10a8 8 0 1116 0 8 8 0 01-16 0zm8-7a7 7 0 00-7 7 7 7 0 1114 0 7 7 0 00-7-7z" clipRule="evenodd" />
              </svg>
            </div>
            <div>
              <h1 className="text-6xl font-black tracking-tighter italic uppercase leading-none mb-2">Campus<br/>Work</h1>
              <div className="h-1.5 w-24 bg-blue-400 rounded-full mb-8"></div>
              <p className="text-xl font-medium text-blue-100 max-w-sm leading-relaxed">La plateforme d'excellence pour le catalogage et la gestion des projets universitaires.</p>
            </div>
            <div className="space-y-4 pt-10">
              <div className="flex items-center gap-4 text-sm font-bold text-blue-200"><div className="w-8 h-8 rounded-full bg-blue-500/30 flex items-center justify-center">✓</div>Gestion multi-utilisateurs</div>
              <div className="flex items-center gap-4 text-sm font-bold text-blue-200"><div className="w-8 h-8 rounded-full bg-blue-500/30 flex items-center justify-center">✓</div>Collaboration simplifiée</div>
              <div className="flex items-center gap-4 text-sm font-bold text-blue-200"><div className="w-8 h-8 rounded-full bg-blue-500/30 flex items-center justify-center">✓</div>Catalogue interactif</div>
            </div>
          </div>
        </div>

        <div className="bg-white p-10 md:p-16 flex flex-col justify-center">
          <div className="mb-10 text-center lg:text-left">
            <h2 className="text-4xl font-black text-slate-900 tracking-tight italic uppercase">{authMode === 'login' ? 'Bon retour !' : authMode === 'signup' ? 'Rejoindre CampusWork' : 'Mot de passe oublié'}</h2>
            <p className="text-slate-500 font-bold text-sm tracking-wide mt-2">{authMode === 'login' ? 'Identifiez-vous pour accéder à votre dashboard.' : authMode === 'signup' ? 'Créez votre compte pour commencer à publier vos projets.' : 'Entrez votre email pour réinitialiser votre accès.'}</p>
          </div>

          {authMode === 'login' ? (
            <form onSubmit={handleLogin} className="space-y-6 animate-fadeIn">
              <div className="space-y-2">
                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 block">Email Académique</label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-6 flex items-center pointer-events-none text-slate-400"><svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.206" /></svg></div>
                  <input type="email" value={loginEmail} onChange={e => setLoginEmail(e.target.value)} className="w-full pl-14 pr-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 focus:bg-white transition-all shadow-sm" placeholder="marie.dubois@school.edu" />
                </div>
              </div>
              <div className="space-y-2">
                <div className="flex justify-between items-center px-4">
                  <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest block">Code d'accès</label>
                  <button type="button" onClick={() => setAuthMode('forgot')} className="text-[9px] font-black text-blue-600 uppercase tracking-widest hover:underline">Oublié ?</button>
                </div>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-6 flex items-center pointer-events-none text-slate-400"><svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 00-2 2zm10-10V7a4 4 0 00-8 0v4h8z" /></svg></div>
                  <input type="password" value={loginPassword} onChange={e => setLoginPassword(e.target.value)} className="w-full pl-14 pr-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 focus:bg-white transition-all shadow-sm" placeholder="••••••••" />
                </div>
              </div>
              <div className="pt-4">
                <button type="submit" className="w-full py-6 bg-blue-600 text-white rounded-[2rem] font-black uppercase tracking-[0.2em] text-xs shadow-2xl shadow-blue-200 hover:bg-blue-700 active:scale-95 transition-all mb-8">Connexion Immédiate</button>
                <div className="text-center"><span className="text-slate-400 font-bold text-sm">Pas encore membre ?</span><button type="button" onClick={() => setAuthMode('signup')} className="text-blue-600 font-black text-sm hover:underline decoration-2 underline-offset-4 ml-1">Créer mon profil</button></div>
              </div>
            </form>
          ) : authMode === 'signup' ? (
            <form onSubmit={handleSignup} className="space-y-6 animate-fadeIn overflow-y-auto max-h-[60vh] pr-4 custom-scrollbar-auth">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 block">Nom Complet</label>
                  <input type="text" value={signupData.name} onChange={e => setSignupData({...signupData, name: e.target.value})} className="w-full px-6 py-4 bg-slate-50 border-2 border-slate-100 rounded-2xl font-bold text-slate-900 outline-none focus:border-blue-500 transition-all" placeholder="Jean Dupont" />
                </div>
                <div className="space-y-2">
                  <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 block">Email Académique</label>
                  <input type="email" value={signupData.email} onChange={e => setSignupData({...signupData, email: e.target.value})} className="w-full px-6 py-4 bg-slate-50 border-2 border-slate-100 rounded-2xl font-bold text-slate-900 outline-none focus:border-blue-500 transition-all" placeholder="jean@school.edu" />
                </div>
              </div>
              <div className="space-y-3">
                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 block text-center lg:text-left">Choisir votre statut</label>
                <div className="grid grid-cols-2 gap-4">
                  <button type="button" onClick={() => setSignupData({...signupData, role: UserRole.STUDENT})} className={`p-4 rounded-2xl border-2 transition-all flex items-center gap-3 ${signupData.role === UserRole.STUDENT ? 'bg-blue-600 text-white border-blue-600 shadow-xl shadow-blue-100' : 'bg-white text-slate-500 border-slate-100 hover:border-blue-200'}`}><div className={`p-2 rounded-lg ${signupData.role === UserRole.STUDENT ? 'bg-white/20' : 'bg-slate-100'}`}><ICONS.Users /></div><span className="font-black text-[10px] uppercase tracking-widest">Étudiant</span></button>
                  <button type="button" onClick={() => setSignupData({...signupData, role: UserRole.LECTURER})} className={`p-4 rounded-2xl border-2 transition-all flex items-center gap-3 ${signupData.role === UserRole.LECTURER ? 'bg-blue-600 text-white border-blue-600 shadow-xl shadow-blue-100' : 'bg-white text-slate-500 border-slate-100 hover:border-blue-200'}`}><div className={`p-2 rounded-lg ${signupData.role === UserRole.LECTURER ? 'bg-white/20' : 'bg-slate-100'}`}><ICONS.Dashboard /></div><span className="font-black text-[10px] uppercase tracking-widest">Enseignant</span></button>
                </div>
              </div>
              {signupData.role === UserRole.STUDENT && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 p-5 bg-slate-50 rounded-3xl border border-slate-100 animate-fadeIn">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 block">Matricule</label>
                    <input type="text" value={signupData.matricule} onChange={e => setSignupData({...signupData, matricule: e.target.value})} className="w-full px-6 py-4 bg-white border-2 border-slate-100 rounded-xl font-bold text-slate-900 outline-none focus:border-blue-500 transition-all" placeholder="2024XXXX" />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 block">Niveau</label>
                    <input type="text" value={signupData.level} onChange={e => setSignupData({...signupData, level: e.target.value})} className="w-full px-6 py-4 bg-white border-2 border-slate-100 rounded-xl font-bold text-slate-900 outline-none focus:border-blue-500 transition-all" placeholder="Licence 3" />
                  </div>
                </div>
              )}
              <div className="space-y-2">
                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 block">Mot de passe</label>
                <input type="password" value={signupData.password} onChange={e => setSignupData({...signupData, password: e.target.value})} className="w-full px-6 py-4 bg-slate-50 border-2 border-slate-100 rounded-2xl font-bold text-slate-900 outline-none focus:border-blue-500 transition-all" placeholder="••••••••" />
              </div>
              <div className="pt-4 space-y-4">
                <button type="submit" className="w-full py-5 bg-blue-600 text-white rounded-2xl font-black uppercase tracking-[0.2em] text-[10px] shadow-2xl shadow-blue-200 hover:bg-blue-700 active:scale-95 transition-all">Valider mon inscription</button>
                <button type="button" onClick={() => setAuthMode('login')} className="w-full py-4 bg-slate-100 text-slate-500 rounded-2xl font-black uppercase tracking-widest text-[9px] hover:bg-slate-200 transition-all">Annuler et revenir à la connexion</button>
              </div>
            </form>
          ) : (
            <form onSubmit={handleForgotPassword} className="space-y-6 animate-fadeIn">
              <div className="space-y-2">
                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 block">Email Académique</label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-6 flex items-center pointer-events-none text-slate-400"><svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.206" /></svg></div>
                  <input type="email" value={forgotEmail} onChange={e => setForgotEmail(e.target.value)} className="w-full pl-14 pr-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 focus:bg-white transition-all shadow-sm" placeholder="marie.dubois@school.edu" />
                </div>
              </div>
              <div className="pt-4 space-y-4">
                <button type="submit" className="w-full py-6 bg-blue-600 text-white rounded-[2rem] font-black uppercase tracking-[0.2em] text-xs shadow-2xl shadow-blue-200 hover:bg-blue-700 active:scale-95 transition-all">Envoyer les instructions</button>
                <button type="button" onClick={() => setAuthMode('login')} className="w-full py-4 bg-slate-100 text-slate-500 rounded-2xl font-black uppercase tracking-widest text-[9px] hover:bg-slate-200 transition-all">Retour à la connexion</button>
              </div>
            </form>
          )}
        </div>
      </div>
      <style>{`.custom-scrollbar-auth::-webkit-scrollbar { width: 4px; } .custom-scrollbar-auth::-webkit-scrollbar-track { background: transparent; } .custom-scrollbar-auth::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 10px; }`}</style>
    </div>
  );

  return (
    <div className="flex bg-[#f8fafc] min-h-screen selection:bg-blue-100 selection:text-blue-900">
      <Sidebar currentView={view} setView={setView} role={currentUser.role} isCollapsed={isCollapsed} setIsCollapsed={setIsCollapsed} />
      <main className={`flex-1 transition-all duration-500 ease-[cubic-bezier(0.4,0,0.2,1)] ${isCollapsed ? 'ml-24' : 'ml-72'} min-h-screen flex flex-col`}>
        <Header user={currentUser} onLogout={() => setCurrentUser(null)} />
        <div className="p-10 max-w-7xl mx-auto w-full flex-1">
          <div className="animate-fadeIn">
            {view === 'dashboard' && (
              <div className="space-y-16">
                <DashboardStats role={currentUser.role} stats={stats} />
                <div className="grid grid-cols-1 lg:grid-cols-4 gap-12">
                  <div className="lg:col-span-3 space-y-8">
                    <div className="flex flex-col md:flex-row gap-6 items-start md:items-center justify-between">
                      <div className="flex bg-white/50 p-2 rounded-[1.5rem] border border-slate-100 w-fit">
                        {['all', 'in_progress', 'completed'].map(tab => (
                          <button key={tab} onClick={() => setDashboardTab(tab as any)} className={`px-8 py-3 rounded-2xl text-[10px] font-black uppercase tracking-widest transition-all ${dashboardTab === tab ? 'bg-blue-600 text-white shadow-lg' : 'text-slate-400 hover:text-slate-600'}`}>{tab === 'all' ? 'Tous' : tab === 'in_progress' ? 'En cours' : 'Terminés'}</button>
                        ))}
                      </div>
                      <div className="w-full md:max-w-md relative group">
                        <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none"><ICONS.Search /></div>
                        <input type="text" placeholder="Rechercher..." value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} className="w-full pl-12 pr-6 py-3.5 bg-white border border-slate-100 rounded-[1.5rem] shadow-sm outline-none focus:ring-4 focus:ring-blue-100 focus:border-blue-300 transition-all font-medium text-sm text-gray-900" />
                      </div>
                    </div>
                    <ProjectList projects={filteredProjects} role={currentUser.role} onEdit={handleEdit} onConsult={handleConsult} onDelete={(id) => setProjects(prev => prev.filter(p => p.id !== id))} onLike={handleProjectLike} isDashboard={true} currentUser={currentUser} />
                  </div>
                  <div className="space-y-10">
                    <div className="flex items-center justify-between px-2">
                      <h3 className="text-2xl font-black text-gray-900 tracking-tight uppercase italic">{t.discussions}</h3>
                      <button onClick={() => setView('posts')} className="text-[10px] font-black text-blue-600 uppercase tracking-widest hover:underline decoration-2 underline-offset-4">Voir tout</button>
                    </div>
                    <DiscussionBoard posts={mainPosts.slice(0, 3)} onPostClick={(p) => {setSelectedPost(p); setView('discussion_detail');}} onLike={handleLike} userRole={currentUser.role} currentUserId={currentUser.id} t={t} />
                  </div>
                </div>
              </div>
            )}
            {view === 'projects' && <ProjectList projects={filteredProjects} role={currentUser.role} onEdit={handleEdit} onConsult={handleConsult} onDelete={(id) => setProjects(prev => prev.filter(p => p.id !== id))} onLike={handleProjectLike} onCreate={currentUser.role === UserRole.STUDENT ? handleCreateProject : undefined} currentUser={currentUser} searchQuery={searchQuery} setSearchQuery={setSearchQuery} />}
            {view === 'project_edit' && editingProject && (
              <div className="max-w-5xl mx-auto animate-fadeIn space-y-10 pb-20">
                <div className="flex items-center justify-between">
                   <button onClick={() => setView('projects')} className="flex items-center gap-3 text-slate-400 font-black uppercase tracking-widest text-xs hover:text-blue-600 transition-colors"><svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M15 19l-7-7 7-7" /></svg>Annuler les modifications</button>
                  <h2 className="text-3xl font-black text-slate-900 uppercase italic tracking-tighter">{editingProject.id ? 'Modifier le projet' : 'Initialiser un projet'}</h2>
                </div>
                <div className="bg-white rounded-[4rem] border border-slate-100 shadow-2xl p-12 space-y-12">
                   <div className="grid grid-cols-1 md:grid-cols-2 gap-10">
                      <div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">Titre du Projet</label><input type="text" value={editingProject.title} onChange={e => setEditingProject({...editingProject, title: e.target.value})} className="w-full px-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 transition-all" placeholder="ex: Système de gestion..." /></div>
                      <div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">Matière / Cours</label><input type="text" value={editingProject.subject} onChange={e => setEditingProject({...editingProject, subject: e.target.value})} className="w-full px-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 transition-all" placeholder="ex: Génie Logiciel" /></div>
                   </div>
                   <div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">Description Détaillée</label><textarea rows={6} value={editingProject.description} onChange={e => setEditingProject({...editingProject, description: e.target.value})} className="w-full px-8 py-6 bg-slate-50 border-2 border-slate-100 rounded-[2.5rem] font-medium text-slate-700 outline-none focus:border-blue-500 transition-all resize-none" placeholder="Décrivez les objectifs et technologies..." /></div>
                   <div className="grid grid-cols-1 md:grid-cols-4 gap-8 p-10 bg-slate-50 rounded-[3rem] border border-slate-100">
                      <div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">Note Académique</label><select value={editingProject.grade || ''} onChange={e => setEditingProject({...editingProject, grade: e.target.value as LetterGrade})} className="w-full px-8 py-5 bg-white border-2 border-slate-200 rounded-2xl font-black text-blue-600 outline-none"><option value="">Non noté</option>{LETTER_GRADES.map(g => <option key={g} value={g}>{g}</option>)}</select></div>
                      <div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">Statut</label><select value={editingProject.status || ProjectStatus.IN_PROGRESS} onChange={e => setEditingProject({...editingProject, status: e.target.value as ProjectStatus})} className="w-full px-8 py-5 bg-white border-2 border-slate-200 rounded-2xl font-bold text-slate-900 outline-none"><option value={ProjectStatus.IN_PROGRESS}>En cours</option><option value={ProjectStatus.COMPLETED}>Terminé</option></select></div>
                      <div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">Niveau Étudiant</label><input type="text" value={editingProject.studentLevel} onChange={e => setEditingProject({...editingProject, studentLevel: e.target.value})} className="w-full px-8 py-5 bg-white border-2 border-slate-200 rounded-2xl font-bold text-slate-900 outline-none" placeholder="ex: Licence 3" /></div>
                      <div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">Catégorie</label><input type="text" value={editingProject.category} onChange={e => setEditingProject({...editingProject, category: e.target.value})} className="w-full px-8 py-5 bg-white border-2 border-slate-200 rounded-2xl font-bold text-slate-900 outline-none" placeholder="ex: Web, IA, Mobile..." /></div>
                   </div>
                  {/* ajout images et videos*/}
                   <div className="space-y-8">
                    <h3 className="text-xl font-black text-slate-900 uppercase italic tracking-tighter px-4 border-l-4 border-pink-500">
                        Médias du Projet
                    </h3>
  
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    {/* Image de couverture */}
                    <MediaUploader
                      type="image"
                      label="Image de Couverture"
                      currentUrl={editingProject.coverImage}
                      onUploadComplete={(url) => setEditingProject({...editingProject, coverImage: url})}
                      onRemove={() => setEditingProject({...editingProject, coverImage: undefined})}
                      maxSize={5}
                    />
    
                    {/* Vidéo de démonstration */}
                    <MediaUploader 
                    type="video" 
                    label="Vidéo de Démonstration (Optionnel)" 
                    currentUrl={editingProject.demoVideo} 
                    onUploadComplete={(url, videoType) => setEditingProject({ ...editingProject, demoVideo: url, videoType: videoType})}
                    onRemove={() => setEditingProject({ ...editingProject, demoVideo: undefined, videoType: undefined })}
                    maxSize={100}
                    />
                  </div>
  
                  <div className="bg-blue-50 border-2 border-blue-200 rounded-2xl p-6">
                    <div className="flex items-start gap-3">
                      <svg className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      <div className="space-y-1">
                        <p className="text-sm font-bold text-blue-800">Conseils pour vos médias</p>
                        <ul className="text-xs text-blue-700 space-y-1 font-medium">
                          <li>• <strong>Image :</strong> Résolution recommandée 1920x1080px (ratio 16:9)</li>
                          <li>• <strong>Vidéo :</strong> Durée idéale 2-5 minutes pour une démo efficace</li>
                          <li>• <strong>Formats :</strong> MP4 pour vidéos uploadées, ou liens YouTube/Vimeo</li>
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
                {/* fin ajout image video*/}

                   <div className="space-y-8"><h3 className="text-xl font-black text-slate-900 uppercase italic tracking-tighter px-4 border-l-4 border-blue-600">Informations Enseignant</h3><div className="grid grid-cols-1 md:grid-cols-2 gap-10"><div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">Nom de l'Enseignant</label><input type="text" value={editingProject.lecturerName} onChange={e => setEditingProject({...editingProject, lecturerName: e.target.value})} className="w-full px-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 transition-all" placeholder="Dr. Dupont" /></div><div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">Email Académique</label><input type="email" value={editingProject.lecturerEmail} onChange={e => setEditingProject({...editingProject, lecturerEmail: e.target.value})} className="w-full px-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 transition-all" placeholder="prof@school.edu" /></div></div></div>
                   <div className="space-y-8"><h3 className="text-xl font-black text-slate-900 uppercase italic tracking-tighter px-4 border-l-4 border-emerald-500">Ressources & Liens</h3><div className="grid grid-cols-1 md:grid-cols-3 gap-8"><div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">GitHub</label><input type="text" value={editingProject.githubLink} onChange={e => setEditingProject({...editingProject, githubLink: e.target.value})} className="w-full px-8 py-4 bg-slate-50 border-2 border-slate-100 rounded-2xl font-bold text-slate-600 outline-none" placeholder="https://..." /></div><div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">LinkedIn</label><input type="text" value={editingProject.linkedinLink} onChange={e => setEditingProject({...editingProject, linkedinLink: e.target.value})} className="w-full px-8 py-4 bg-slate-50 border-2 border-slate-100 rounded-2xl font-bold text-slate-600 outline-none" placeholder="https://..." /></div><div className="space-y-2"><label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4">Autre (Demo, PDF...)</label><input type="text" value={editingProject.otherLink} onChange={e => setEditingProject({...editingProject, otherLink: e.target.value})} className="w-full px-8 py-4 bg-slate-50 border-2 border-slate-100 rounded-2xl font-bold text-slate-600 outline-none" placeholder="https://..." /></div></div></div>
                   <div className="space-y-8"><div className="flex items-center justify-between px-4"><h3 className="text-xl font-black text-slate-900 uppercase italic tracking-tighter border-l-4 border-purple-500 pl-4">Équipe Collaboratrice</h3><button onClick={() => setEditingProject({...editingProject, collaborators: [...(editingProject.collaborators || []), {name:'', email:'', level:''}]})} className="bg-purple-50 text-purple-600 px-6 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest hover:bg-purple-600 hover:text-white transition-all">+ Ajouter</button></div><div className="space-y-4">{(editingProject.collaborators || []).map((collab, idx) => (<div key={idx} className="grid grid-cols-1 md:grid-cols-10 gap-4 p-6 bg-slate-50 rounded-[2rem] border border-slate-200 animate-fadeIn items-end"><div className="md:col-span-3 space-y-2"><label className="text-[9px] font-black text-slate-400 uppercase px-2">Nom complet</label><input type="text" value={collab.name} onChange={e => { const list = [...(editingProject.collaborators || [])]; list[idx].name = e.target.value; setEditingProject({...editingProject, collaborators: list}); }} className="w-full bg-white px-5 py-3 rounded-xl border border-slate-200 font-bold text-sm" /></div><div className="md:col-span-3 space-y-2"><label className="text-[9px] font-black text-slate-400 uppercase px-2">Email</label><input type="email" value={collab.email} onChange={e => { const list = [...(editingProject.collaborators || [])]; list[idx].email = e.target.value; setEditingProject({...editingProject, collaborators: list}); }} className="w-full bg-white px-5 py-3 rounded-xl border border-slate-200 font-bold text-sm" /></div><div className="md:col-span-3 space-y-2"><label className="text-[9px] font-black text-slate-400 uppercase px-2">Niveau</label><input type="text" value={collab.level} onChange={e => { const list = [...(editingProject.collaborators || [])]; list[idx].level = e.target.value; setEditingProject({...editingProject, collaborators: list}); }} className="w-full bg-white px-5 py-3 rounded-xl border border-slate-200 font-bold text-sm" /></div><div className="md:col-span-1"><button onClick={() => { const list = (editingProject.collaborators || []).filter((_, i) => i !== idx); setEditingProject({...editingProject, collaborators: list}); }} className="w-full h-[46px] flex items-center justify-center bg-red-50 text-red-500 rounded-xl hover:bg-red-500 hover:text-white transition-all">×</button></div></div>))} {(!editingProject.collaborators || editingProject.collaborators.length === 0) && (<div className="py-12 text-center border-4 border-dashed border-slate-100 rounded-[2.5rem] text-slate-300 font-bold italic text-sm">Pas encore de collaborateurs ajoutés.</div>)}</div></div>
                   <div className="pt-12 border-t border-slate-100 flex flex-col md:flex-row gap-6"><button onClick={handleSaveProject} className="flex-1 py-6 bg-blue-600 text-white rounded-[2rem] font-black uppercase tracking-[0.2em] text-xs shadow-2xl shadow-blue-200 hover:bg-blue-700 active:scale-95 transition-all">{editingProject.id ? 'Mettre à jour le projet' : 'Diffuser mon projet'}</button><button onClick={() => setView('projects')} className="px-12 py-6 bg-slate-100 text-slate-400 rounded-[2rem] font-black uppercase tracking-widest text-xs hover:bg-slate-200 transition-all">Annuler</button></div>
                </div>
              </div>
            )}

            {view === 'project_detail' && consultingProject && (
              <div className="max-w-6xl mx-auto animate-fadeIn space-y-12 pb-20">
                <button onClick={() => setView('projects')} className="group flex items-center gap-3 text-blue-600 font-black uppercase tracking-widest text-xs hover:-translate-x-2 transition-transform"><svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M15 19l-7-7 7-7" /></svg>Retour au catalogue</button>
                {/* 🆕 Section Média Hero */}
                {(consultingProject.coverImage || consultingProject.demoVideo) && (
                  <div className="bg-white rounded-[4rem] border border-slate-100 overflow-hidden shadow-2xl">
                    {consultingProject.demoVideo ? (
                      <div className="w-full aspect-video bg-black">
                        {consultingProject.demoVideo.includes('cloudinary') ? (
                          <video 
                            src={consultingProject.demoVideo} 
                            controls 
                            poster={consultingProject.coverImage}
                            className="w-full h-full"
                          >
                            Votre navigateur ne supporte pas la lecture vidéo.
                          </video>
                        ) : (
                          <iframe
                            src={
                              consultingProject.videoType === 'youtube' 
                                ? consultingProject.demoVideo.replace('watch?v=', 'embed/').split('&')[0]
                                : consultingProject.videoType === 'vimeo'
                                ? consultingProject.demoVideo.replace('vimeo.com/', 'player.vimeo.com/video/')
                                : consultingProject.demoVideo
                            }
                            className="w-full h-full"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                            allowFullScreen
                          />
                        )}
                      </div>
                    ) : consultingProject.coverImage ? (
                      <img 
                        src={consultingProject.coverImage} 
                        alt={consultingProject.title}
                        className="w-full h-96 object-cover"
                      />
                    ) : null}
                  </div>
                )}
            
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
                  <div className="lg:col-span-2 space-y-12">
                    <div className="bg-white p-12 rounded-[4rem] border border-slate-100 shadow-2xl shadow-slate-200/50">
                      <div className="flex flex-wrap items-center gap-4 mb-6"><span className="bg-blue-50 text-blue-600 px-5 py-2 rounded-2xl text-[10px] font-black uppercase tracking-widest border border-blue-100">{consultingProject.subject || consultingProject.category}</span>{consultingProject.grade && (<span className="bg-purple-600 text-white px-5 py-2 rounded-2xl text-[10px] font-black uppercase tracking-widest shadow-lg shadow-purple-100">Grade: {consultingProject.grade}</span>)}<span className={`px-5 py-2 rounded-2xl text-[10px] font-black uppercase tracking-widest border ${consultingProject.status === ProjectStatus.COMPLETED ? 'bg-emerald-50 text-emerald-600 border-emerald-100' : 'bg-orange-50 text-orange-600 border-orange-100'}`}>{consultingProject.status}</span></div>
                      <h1 className="text-5xl font-black text-slate-900 tracking-tighter italic mb-8 leading-tight">{consultingProject.title}</h1>
                      <div className="bg-slate-50 p-10 rounded-[3rem] border border-slate-100 shadow-inner mb-10"><p className="text-slate-700 text-xl font-medium leading-relaxed">{consultingProject.description}</p></div>
                      <div className="flex items-center gap-6"><span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Ressources & Liens :</span><div className="flex gap-4">{consultingProject.githubLink && (<a href={consultingProject.githubLink} target="_blank" rel="noreferrer" className="w-14 h-14 bg-slate-900 text-white rounded-2xl flex items-center justify-center hover:scale-110 transition-transform shadow-xl"><svg className="w-7 h-7" fill="currentColor" viewBox="0 0 24 24"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.042-1.416-4.042-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg></a>)}{consultingProject.linkedinLink && (<a href={consultingProject.linkedinLink} target="_blank" rel="noreferrer" className="w-14 h-14 bg-blue-600 text-white rounded-2xl flex items-center justify-center hover:scale-110 transition-transform shadow-xl"><svg className="w-7 h-7" fill="currentColor" viewBox="0 0 24 24"><path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/></svg></a>)}{consultingProject.otherLink && (<a href={consultingProject.otherLink} target="_blank" rel="noreferrer" className="w-14 h-14 bg-emerald-500 text-white rounded-2xl flex items-center justify-center hover:scale-110 transition-transform shadow-xl"><svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg></a>)}</div></div>
                    </div>
                    <div className="space-y-8">
                      <div className="flex items-center justify-between px-4"><h2 className="text-3xl font-black text-slate-900 uppercase italic tracking-tighter">Évaluations Académiques</h2>{averageRating && (<div className="flex items-center gap-3"><span className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Score Moyen :</span><span className="text-4xl font-black text-blue-600">{averageRating}<span className="text-lg text-slate-300">/20</span></span></div>)}</div>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                        <div className="bg-slate-900 p-10 rounded-[3.5rem] text-white shadow-2xl relative overflow-hidden h-fit"><div className="absolute top-0 right-0 w-32 h-32 bg-blue-600/20 blur-3xl"></div><h4 className="font-black uppercase tracking-tighter italic mb-8 relative z-10">Encadrement</h4><div className="space-y-6 relative z-10"><div><p className="text-blue-100 text-[10px] font-black uppercase tracking-widest mb-1">Enseignant</p><p className="text-xl font-bold">{consultingProject.lecturerName || "Non spécifié"}</p></div><div><p className="text-blue-100 text-[10px] font-black uppercase tracking-widest mb-1">Email de Contact</p><p className="text-sm font-medium text-blue-300">{consultingProject.lecturerEmail || "N/A"}</p></div></div></div>
                        <div className="space-y-6">
                          {consultingProject.reviews?.map(r => (<div key={r.id} className="bg-white p-8 rounded-[3rem] border-2 border-slate-50 shadow-sm relative group hover:border-blue-200 transition-colors"><div className="absolute -top-4 -right-4 bg-blue-600 text-white w-12 h-12 rounded-2xl flex items-center justify-center font-black shadow-xl shadow-blue-100">{r.rating}</div><div className="flex items-center gap-4 mb-4"><div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600 font-black text-xs">{r.authorName.charAt(0)}</div><div><p className="font-black text-slate-900 text-sm leading-none">{r.authorName}</p><span className="text-[9px] text-slate-500 font-black uppercase tracking-widest">{r.createdAt}</span></div></div><p className="text-slate-900 text-sm leading-relaxed font-bold pl-2 border-l-4 border-slate-200 group-hover:border-blue-500 transition-colors italic">"{r.comment}"</p></div>))}
                          {(!consultingProject.reviews || consultingProject.reviews.length === 0) && (<div className="py-20 text-center border-4 border-dashed border-slate-100 rounded-[3rem] text-slate-400 font-black uppercase text-xs">Aucune évaluation enregistrée.</div>)}
                        </div>
                      </div>
                      {(currentUser.role === UserRole.ADMIN || currentUser.role === UserRole.LECTURER) && (
                        <div className="bg-white p-10 rounded-[3.5rem] border-2 border-slate-100 shadow-lg"><h5 className="font-black text-slate-900 uppercase tracking-tighter italic mb-8 border-b-2 border-blue-600 w-fit pb-1">Nouvel Avis Académique</h5><div className="grid grid-cols-1 md:grid-cols-4 gap-8"><div className="md:col-span-1 space-y-2"><label className="text-[9px] font-black text-slate-600 uppercase px-2">Note (/20)</label><input type="number" min="0" max="20" value={newReview.rating} onChange={e => setNewReview({...newReview, rating: Number(e.target.value)})} className="w-full px-6 py-4 rounded-2xl bg-slate-50 border-2 border-slate-200 font-black text-xl text-blue-700 focus:border-blue-500 outline-none" /></div><div className="md:col-span-3 space-y-2"><label className="text-[9px] font-black text-slate-600 uppercase px-2">Commentaire</label><textarea rows={1} value={newReview.comment} onChange={e => setNewReview({...newReview, comment: e.target.value})} className="w-full px-6 py-4 rounded-2xl bg-slate-50 border-2 border-slate-200 font-bold text-slate-900 text-sm focus:border-blue-500 outline-none resize-none placeholder:text-slate-400" placeholder="Qualité du rendu..." /></div></div><button onClick={handleAddReview} className="mt-8 w-full py-4 bg-blue-600 text-white rounded-2xl font-black uppercase tracking-widest text-[10px] shadow-xl shadow-blue-100 hover:bg-blue-700 active:scale-95 transition-all">Publier l'évaluation</button></div>
                      )}
                    </div>
                  </div>
                  <div className="space-y-12">
                    {authorData && (
                      <div className="bg-white p-10 rounded-[4rem] border border-slate-100 shadow-2xl shadow-slate-200/50 flex flex-col items-center text-center"><div className="relative mb-6">{authorData.avatar ? <img src={authorData.avatar} className="w-32 h-32 rounded-[2.5rem] border-8 border-slate-50 shadow-inner object-cover" /> : <div className="w-32 h-32 rounded-[2.5rem] bg-blue-100 flex items-center justify-center text-blue-600 text-4xl font-black">{authorData.name.charAt(0)}</div>}<div className="absolute -bottom-2 -right-2 bg-emerald-500 w-8 h-8 rounded-full border-4 border-white"></div></div><h3 className="text-3xl font-black text-slate-900 tracking-tighter uppercase italic mb-1">{authorData.name}</h3><p className="text-slate-500 font-bold text-sm mb-6">{authorData.email}</p><div className="grid grid-cols-2 gap-3 w-full mb-8"><div className="bg-slate-50 p-4 rounded-[1.5rem] border border-slate-100"><span className="block text-[8px] font-black text-slate-500 uppercase mb-1">Cycle</span><span className="font-bold text-slate-800 text-xs">{authorData.cycle || "N/A"}</span></div><div className="bg-slate-50 p-4 rounded-[1.5rem] border border-slate-100"><span className="block text-[8px] font-black text-slate-500 uppercase mb-1">Status</span><span className="font-bold text-slate-800 text-xs">{authorData.status || "N/A"}</span></div><div className="bg-slate-50 p-4 rounded-[1.5rem] border border-slate-100 col-span-2"><span className="block text-[8px] font-black text-slate-500 uppercase mb-1">Niveau</span><span className="font-bold text-slate-800 text-xs">{authorData.level || "N/A"}</span></div></div><div className="text-left w-full space-y-3"><span className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-4">Biographie :</span><p className="bg-slate-50/50 p-6 rounded-[2rem] border border-slate-100 text-slate-700 font-medium text-sm leading-relaxed italic">{authorData.bio || "Aucune biographie disponible."}</p></div></div>
                    )}
                    <div className="space-y-6"><h4 className="text-xl font-black text-slate-900 uppercase italic tracking-tighter px-4">Équipe Collaboratrice</h4><div className="space-y-4">{consultingProject.collaborators?.map((c, i) => (<div key={i} className="bg-white p-6 rounded-[2rem] border border-slate-100 shadow-sm flex items-center gap-4 hover:border-blue-300 transition-colors"><div className="w-12 h-12 rounded-2xl bg-slate-50 flex items-center justify-center text-slate-500 font-black text-xs border border-slate-100">{c.name.charAt(0)}</div><div className="flex-1 overflow-hidden"><p className="font-black text-slate-900 text-sm truncate">{c.name}</p><p className="text-[10px] text-slate-500 font-bold truncate">{c.email}</p>{c.level && <p className="text-[9px] text-blue-600 font-black uppercase mt-1">{c.level}</p>}</div></div>))}{(!consultingProject.collaborators || consultingProject.collaborators.length === 0) && (<div className="py-10 text-center border-2 border-dashed border-slate-100 rounded-[2.5rem] text-slate-400 font-bold italic text-xs">Projet individuel.</div>)}</div></div>
                  </div>
                </div>
              </div>
            )}
            {view === 'posts' && <DiscussionBoard posts={mainPosts} onPostClick={(p) => {setSelectedPost(p); setView('discussion_detail');}} onLike={handleLike} onEditPost={handleEditPost} onDeletePost={handleDeletePost} userRole={currentUser.role} currentUserId={currentUser.id} onCreatePost={() => {setNewPost({ title: '', content: '', category: 'Discussion' }); setIsPostModalOpen(true);}} searchQuery={searchQuery} setSearchQuery={setSearchQuery} t={t} />}
            {view === 'discussion_detail' && selectedPost && (
              <div className="max-w-5xl mx-auto animate-fadeIn pb-20 space-y-12">
                <div className="bg-white rounded-[3.5rem] p-12 shadow-2xl shadow-slate-200/50 border border-slate-100 relative overflow-hidden"><div className="absolute top-0 left-0 w-2 h-full bg-blue-600"></div><button onClick={() => setView('posts')} className="mb-8 flex items-center gap-3 text-blue-600 font-black uppercase tracking-widest text-[10px] hover:-translate-x-2 transition-transform"><svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M15 19l-7-7 7-7" /></svg>Retour au flux</button>
                  <div className="flex items-center gap-4 mb-6"><span className={`px-4 py-1.5 rounded-xl font-black uppercase tracking-[0.2em] text-[10px] bg-blue-50 text-blue-700 border border-blue-100`}>{selectedPost.category}</span><span className="text-[11px] text-slate-500 font-black uppercase tracking-widest">{selectedPost.createdAt} par {selectedPost.authorName}</span></div>
                  <h1 className="text-5xl font-black text-gray-900 mb-8 leading-[1.1] tracking-tighter italic">{selectedPost.title}</h1>
                  <div className="bg-slate-50 p-10 rounded-[2.5rem] border border-slate-100 mb-10"><p className="text-slate-800 leading-relaxed text-xl font-medium whitespace-pre-wrap">{selectedPost.content}</p></div>
                  <div className="flex items-center justify-between px-4"><button onClick={() => !selectedPost.blocked && handleLike(selectedPost.id)} disabled={selectedPost.blocked} className={`flex items-center gap-3 px-8 py-4 transition-all hover:scale-105 active:scale-95 ${selectedPost.likedBy?.includes(currentUser.id) ? 'bg-red-500 text-white shadow-red-200' : 'bg-red-50 text-red-600 hover:bg-red-100 shadow-red-100'} rounded-[1.5rem] font-black uppercase tracking-widest text-[10px] shadow-lg`}><svg className={`w-6 h-6 transition-all ${selectedPost.likedBy?.includes(currentUser.id) ? 'fill-current' : ''}`} viewBox="0 0 24 24"><path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg><span>{selectedPost.likes} {t.like}</span></button>
                    {selectedPost.authorId === currentUser.id && (<div className="flex gap-4"><button onClick={() => handleEditPost(selectedPost)} className="px-6 py-4 bg-slate-50 text-slate-600 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-blue-600 hover:text-white transition-all shadow-sm">Modifier le post</button><button onClick={() => handleDeletePost(selectedPost.id)} className="px-6 py-4 bg-red-50 text-red-500 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-red-600 hover:text-white transition-all shadow-sm">Supprimer</button></div>)}
                  </div>
                </div>
                <div className="space-y-10"><div className="flex items-center justify-between px-6"><h3 className="text-3xl font-black text-slate-900 uppercase italic tracking-tighter">Échanges & Réponses ({selectedPost.comments})</h3></div>
                  <div className="bg-white p-10 rounded-[3rem] border border-slate-100 shadow-xl shadow-slate-200/50">{replyingTo && (<div className="mb-4 flex items-center justify-between bg-blue-50 px-6 py-3 rounded-2xl border border-blue-100"><p className="text-[11px] font-black text-blue-700 uppercase tracking-widest">En réponse à {replyingTo.authorName}</p><button onClick={() => setReplyingTo(null)} className="text-blue-500 hover:text-blue-700 font-black">×</button></div>)}{editingCommentId && (<div className="mb-4 flex items-center justify-between bg-purple-50 px-6 py-3 rounded-2xl border border-purple-100"><p className="text-[11px] font-black text-purple-700 uppercase tracking-widest">Modification du commentaire</p><button onClick={() => { setEditingCommentId(null); setCommentInput(''); }} className="text-purple-500 hover:text-purple-700 font-black">×</button></div>)}<div className="flex flex-col md:flex-row gap-6 items-end"><textarea value={commentInput} onChange={e => setCommentInput(e.target.value)} placeholder="Votre analyse ou question..." className="flex-1 w-full bg-slate-50 border-2 border-slate-100 rounded-[2rem] p-6 font-bold text-slate-900 outline-none focus:border-blue-500 transition-all resize-none min-h-[120px]" /><button onClick={editingCommentId ? handleUpdateComment : handleCommentAction} className="w-full md:w-auto px-12 py-6 bg-blue-600 text-white rounded-[2rem] font-black uppercase tracking-widest text-[10px] shadow-2xl shadow-blue-100 hover:bg-blue-700 active:scale-95 transition-all">{editingCommentId ? 'Mettre à jour' : replyingTo ? 'Répondre' : 'Publier'}</button></div></div>
                  <div className="space-y-8">{selectedPost.replies && selectedPost.replies.length > 0 ? (selectedPost.replies.map(comment => <CommentItem key={comment.id} comment={comment} />)) : (<div className="py-20 text-center border-4 border-dashed border-slate-100 rounded-[3rem] text-slate-400 font-black uppercase text-xs tracking-widest">Soyez le premier à contribuer à cette discussion.</div>)}</div>
                </div>
              </div>
            )}
            {view === 'users' && currentUser.role === UserRole.ADMIN && (
              <AdminPanel users={users} posts={posts} onApprove={(id) => setUsers(prev => prev.map(u => u.id === id ? {...u, pending: false} : u))} onReject={(id) => setUsers(prev => prev.filter(u => u.id !== id))} onDeleteUser={(id) => setUsers(prev => prev.filter(u => u.id !== id))} onBanUser={(id) => setUsers(prev => prev.map(u => u.id === id ? {...u, banned: !u.banned} : u))} onPromoteUser={(id) => setUsers(prev => prev.map(u => u.id === id ? {...u, role: UserRole.ADMIN} : u))} onDeletePost={(id) => setPosts(prev => prev.filter(p => p.id !== id))} onBlockPost={(id) => setPosts(prev => prev.map(p => p.id === id ? {...p, blocked: !p.blocked} : p))} />
            )}
            {view === 'settings' && (
              <div className="space-y-12 max-w-5xl mx-auto animate-fadeIn pb-20">
                <div className="bg-white p-12 rounded-[4rem] border border-slate-100 flex flex-col items-center gap-10 shadow-2xl relative overflow-hidden"><div className="absolute top-0 left-0 w-full h-32 bg-slate-900/5 -z-10"></div><div className="relative group mt-8">{currentUser.avatar ? <img src={currentUser.avatar} className="w-40 h-40 rounded-[3rem] border-8 border-white shadow-xl object-cover" alt="" /> : <div className="w-40 h-40 rounded-[3rem] bg-blue-100 flex items-center justify-center text-blue-600 text-5xl font-black border-8 border-white shadow-xl">{currentUser.name.charAt(0)}</div>}
                <button 
                  onClick={() => document.getElementById('avatar-upload')?.click()}
                  className="absolute inset-0 bg-black/40 rounded-[3rem] opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center text-white font-black uppercase tracking-widest text-[10px]"
                >
                  Modifier Photo
                </button>
                <input 
                  id="avatar-upload" 
                  type="file" 
                  accept="image/*" 
                  className="hidden" 
                  onChange={handleAvatarChange} 
                />
                <div className="absolute -bottom-2 -right-2 bg-emerald-500 w-8 h-8 rounded-full border-4 border-white shadow-lg"></div></div><div className="w-full space-y-12"><div className="text-center"><h3 className="text-3xl font-black text-slate-900 uppercase italic tracking-tighter">Profil Public</h3><p className="text-slate-500 font-bold text-xs uppercase tracking-[0.2em] mt-2">Gérez vos informations académiques</p></div><div className="grid grid-cols-1 md:grid-cols-2 gap-10"><div className="space-y-2"><label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-4">Nom Complet</label><input type="text" value={profileForm.name || ''} onChange={e => setProfileForm({...profileForm, name: e.target.value})} className="w-full px-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 transition-all" /></div><div className="space-y-2"><label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-4">Email Académique</label><input type="email" value={profileForm.email || ''} onChange={e => setProfileForm({...profileForm, email: e.target.value})} className="w-full px-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 transition-all" /></div><div className="space-y-2"><label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-4">Statut Actuel</label><select value={profileForm.status || ''} onChange={e => setProfileForm({...profileForm, status: e.target.value})} className="w-full px-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 transition-all appearance-none"><option value="Undergraduate">Étudiant (Undergraduate)</option><option value="Graduate">Diplômé (Graduate)</option><option value="Alumni">Ancien (Alumni)</option><option value="Staff">Personnel (Staff)</option><option value="Faculty">Enseignant (Faculty)</option></select></div><div className="space-y-2"><label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-4">Cycle Académique</label><select value={profileForm.cycle || ''} onChange={e => setProfileForm({...profileForm, cycle: e.target.value})} className="w-full px-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] font-bold text-slate-900 outline-none focus:border-blue-500 transition-all appearance-none"><option value="Licence">Licence / Bachelor</option><option value="Master">Master</option><option value="Doctorat">Doctorat / PhD</option><option value="Administration">Administration</option><option value="Expertise">Expertise Professionnelle</option></select></div></div><div className="space-y-2"><label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-4">Biographie & Objectifs</label><textarea rows={4} value={profileForm.bio || ''} onChange={e => setProfileForm({...profileForm, bio: e.target.value})} className="w-full px-8 py-6 bg-slate-50 border-2 border-slate-100 rounded-[2.5rem] font-bold text-slate-800 outline-none focus:border-blue-500 transition-all resize-none" placeholder="Parlez-nous de vos passions et de votre parcours..." /></div><div className="pt-6 border-t border-slate-100 flex gap-6"><button onClick={handleSaveProfile} className="flex-1 py-5 bg-blue-600 text-white rounded-[2rem] font-black uppercase tracking-[0.2em] text-[10px] shadow-2xl shadow-blue-200 hover:bg-blue-700 active:scale-95 transition-all">Sauvegarder les modifications</button></div></div></div>
              </div>
            )}
          </div>
        </div>
      </main>
      {isPostModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-6"><div className="absolute inset-0 bg-slate-900/80 backdrop-blur-xl" onClick={() => setIsPostModalOpen(false)}></div><div className="bg-white rounded-[4rem] w-full max-w-2xl z-10 shadow-2xl animate-modalScale flex flex-col overflow-hidden"><div className="p-10 border-b border-slate-100 shrink-0"><h3 className="text-3xl font-black text-gray-900 uppercase italic tracking-tighter">{newPost.id ? 'Modifier la discussion' : 'Ouvrir un débat'}</h3></div><div className="p-10 space-y-8 overflow-y-auto custom-scrollbar flex-1"><input type="text" value={newPost.title} onChange={e => setNewPost({...newPost, title: e.target.value})} className="w-full px-8 py-5 bg-slate-50 border-2 border-slate-100 rounded-[2rem] text-gray-900 font-bold outline-none transition-all" placeholder="Sujet..." /><textarea rows={5} value={newPost.content} onChange={e => setNewPost({...newPost, content: e.target.value})} className="w-full px-8 py-6 bg-slate-50 border-2 border-slate-100 rounded-[2.5rem] text-gray-900 font-medium outline-none transition-all resize-none" placeholder="Détails..." /><div className="flex flex-wrap gap-3">{['Discussion', 'Aide', currentUser.role === UserRole.ADMIN ? 'Annonce' : null, currentUser.role === UserRole.LECTURER ? 'Exercices' : null].filter(Boolean).map(cat => (<button key={cat as string} onClick={() => setNewPost({...newPost, category: cat as any})} className={`px-6 py-3 rounded-xl text-[9px] font-black uppercase tracking-[0.2em] transition-all border-2 ${newPost.category === cat ? 'bg-blue-600 text-white border-blue-600 shadow-xl' : 'bg-white text-slate-400 border-slate-100 hover:border-blue-200'}`}>{cat}</button>))}</div></div><div className="p-10 bg-slate-50 border-t border-slate-100 flex justify-end gap-6 shrink-0"><button onClick={() => setIsPostModalOpen(false)} className="px-8 py-4 font-black text-slate-500 uppercase tracking-widest text-[10px]">Annuler</button><button onClick={handleSavePost} className="px-14 py-5 bg-blue-600 text-white font-black rounded-[1.5rem] shadow-2xl shadow-blue-200 uppercase tracking-widest text-[10px] hover:bg-blue-700 transition-all active:scale-95">{newPost.id ? 'Mettre à jour' : 'Diffuser'}</button></div></div></div>
      )}
      <style>{`@keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } } @keyframes modalScale { from { opacity: 0; transform: scale(0.92) translateY(30px); } to { opacity: 1; transform: scale(1) translateY(0); } } .animate-fadeIn { animation: fadeIn 0.6s cubic-bezier(0.2, 0.8, 0.2, 1) forwards; } .animate-modalScale { animation: modalScale 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) forwards; } .hide-scrollbar::-webkit-scrollbar { display: none; } .hide-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }`}</style>
    </div>
  );
};

export default App;
