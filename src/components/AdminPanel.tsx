import React, { useState } from 'react';
import { User, UserRole, Post } from '../../types';
import { ICONS } from '../constants';
import { apiGateway } from '@/api/gateway-supabase';

interface AdminPanelProps {
  users: User[];
  posts: Post[];
  onApprove: (userId: string) => void;
  onReject: (userId: string) => void;
  onDeleteUser: (userId: string) => void;
  onBanUser: (userId: string) => void;
  onPromoteUser: (userId: string) => void;
  onDeletePost: (postId: string) => void;
  onBlockPost: (postId: string) => void;
}

const AdminPanel: React.FC<AdminPanelProps> = ({ 
  users, 
  posts, 
  onApprove, 
  onReject, 
  onDeleteUser, 
  onBanUser, 
  onPromoteUser,
  onDeletePost,
  onBlockPost
}) => {
  const [activeTab, setActiveTab] = React.useState<'pending' | 'users' | 'moderation'>('pending');
  const [userSearch, setUserSearch] = useState('');
  const [modSearch, setModSearch] = useState('');
  const [isProcessing, setIsProcessing] = useState<string | null>(null);
  
  const pendingUsers = users.filter(u => u.pending);
  const activeUsers = users.filter(u => !u.pending && (
    u.name.toLowerCase().includes(userSearch.toLowerCase()) || 
    u.email.toLowerCase().includes(userSearch.toLowerCase())
  ));
  
  const admins = activeUsers.filter(u => u.role === UserRole.ADMIN);
  const students = activeUsers.filter(u => u.role === UserRole.STUDENT);
  const lecturers = activeUsers.filter(u => u.role === UserRole.LECTURER);

  const filteredPosts = posts.filter(p => 
    p.title.toLowerCase().includes(modSearch.toLowerCase()) || 
    p.authorName.toLowerCase().includes(modSearch.toLowerCase())
  );

  // ✅ Approuver un utilisateur
  const handleApprove = async (userId: string) => {
    if (isProcessing) return;
    setIsProcessing(userId);
    
    try {
      const updatedUser = await apiGateway.db.users.update(userId, { pending: false });
      onApprove(userId);
      alert('✅ Utilisateur approuvé avec succès !');
    } catch (error: any) {
      alert('❌ Erreur lors de l\'approbation : ' + error.message);
    } finally {
      setIsProcessing(null);
    }
  };

  // ❌ Rejeter un utilisateur (suppression définitive)
  const handleReject = async (userId: string) => {
    if (isProcessing) return;
    if (!window.confirm('⚠️ Êtes-vous sûr de vouloir rejeter cette demande ? L\'utilisateur sera définitivement supprimé.')) return;
    
    setIsProcessing(userId);
    
    try {
      await apiGateway.db.users.delete(userId);
      onReject(userId);
      alert('✅ Demande rejetée et utilisateur supprimé.');
    } catch (error: any) {
      alert('❌ Erreur lors du rejet : ' + error.message);
    } finally {
      setIsProcessing(null);
    }
  };

  // 🗑️ Supprimer un utilisateur
  const handleDeleteUser = async (userId: string) => {
    if (isProcessing) return;
    if (!window.confirm('⚠️ ATTENTION : Cette action est IRRÉVERSIBLE. Supprimer cet utilisateur ?')) return;
    
    setIsProcessing(userId);
    
    try {
      await apiGateway.db.users.delete(userId);
      onDeleteUser(userId);
      alert('✅ Utilisateur supprimé définitivement.');
    } catch (error: any) {
      alert('❌ Erreur lors de la suppression : ' + error.message);
    } finally {
      setIsProcessing(null);
    }
  };

  // 🚫 Bannir/Débannir un utilisateur
  const handleBanUser = async (userId: string, currentBanStatus: boolean) => {
    if (isProcessing) return;
    
    const action = currentBanStatus ? 'débannir' : 'bannir';
    if (!window.confirm(`Voulez-vous vraiment ${action} cet utilisateur ?`)) return;
    
    setIsProcessing(userId);
    
    try {
      const updatedUser = await apiGateway.db.users.update(userId, { banned: !currentBanStatus });
      onBanUser(userId);
      alert(`✅ Utilisateur ${currentBanStatus ? 'débanni' : 'banni'} avec succès.`);
    } catch (error: any) {
      alert('❌ Erreur : ' + error.message);
    } finally {
      setIsProcessing(null);
    }
  };

  // ⬆️ Promouvoir en Admin
  const handlePromoteUser = async (userId: string) => {
    if (isProcessing) return;
    if (!window.confirm('⚠️ Promouvoir cet utilisateur en ADMINISTRATEUR ? Il aura tous les droits.')) return;
    
    setIsProcessing(userId);
    
    try {
      const updatedUser = await apiGateway.db.users.update(userId, { role: UserRole.ADMIN });
      onPromoteUser(userId);
      alert('✅ Utilisateur promu en Administrateur !');
    } catch (error: any) {
      alert('❌ Erreur lors de la promotion : ' + error.message);
    } finally {
      setIsProcessing(null);
    }
  };

  // 🗑️ Supprimer un post
  const handleDeletePost = async (postId: string) => {
    if (isProcessing) return;
    if (!window.confirm('⚠️ Supprimer définitivement cette discussion ?')) return;
    
    setIsProcessing(postId);
    
    try {
      await apiGateway.db.posts.delete(postId);
      onDeletePost(postId);
      alert('✅ Discussion supprimée.');
    } catch (error: any) {
      alert('❌ Erreur lors de la suppression : ' + error.message);
    } finally {
      setIsProcessing(null);
    }
  };

  // 🚫 Bloquer/Débloquer un post
  const handleBlockPost = async (postId: string, currentBlockStatus: boolean) => {
    if (isProcessing) return;
    
    setIsProcessing(postId);
    
   try {
      // Trouver le post complet
      const post = posts.find(p => p.id === postId);
      if (!post) throw new Error('Post introuvable');
      
      // Trouver l'auteur
      const author = users.find(u => u.id === post.authorId);
      if (!author) throw new Error('Auteur introuvable');
      
      // ⚠️ Nettoyer le post - enlever 'replies' qui n'existe pas dans Supabase
      const { replies, ...cleanPost } = post;
      
      // Sauvegarder avec le champ blocked modifié
      await apiGateway.db.posts.save({ 
        ...cleanPost, 
        blocked: !currentBlockStatus 
      }, author);
      
      onBlockPost(postId);
      alert(`✅ Discussion ${currentBlockStatus ? 'débloquée' : 'bloquée'}.`);
    } catch (error: any) {
      alert('❌ Erreur : ' + error.message);
    } finally {
      setIsProcessing(null);
    }
  };

  return (
    <div className="space-y-6">
      <div className="border-b border-gray-200">
        <nav className="flex gap-8">
          {[
            { id: 'pending', label: 'Inscriptions en attente', count: pendingUsers.length },
            { id: 'users', label: 'Utilisateurs' },
            { id: 'moderation', label: 'Modération' }
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              className={`pb-4 px-2 text-sm font-semibold transition-all relative ${
                activeTab === tab.id ? 'text-blue-600' : 'text-gray-500 hover:text-gray-700'
              }`}
            >
              <div className="flex items-center gap-2">
                {tab.label}
                {tab.count !== undefined && tab.count > 0 && (
                  <span className="w-5 h-5 flex items-center justify-center bg-orange-100 text-orange-600 rounded-full text-[10px] font-bold">
                    {tab.count}
                  </span>
                )}
              </div>
              {activeTab === tab.id && <div className="absolute bottom-0 left-0 right-0 h-1 bg-blue-600 rounded-t-full"></div>}
            </button>
          ))}
        </nav>
      </div>

      {activeTab === 'pending' && (
        <div className="space-y-4 animate-fadeIn">
          <h3 className="text-lg font-bold text-gray-800 mb-4">Demandes d'inscription</h3>
          {pendingUsers.length === 0 ? (
            <p className="text-gray-500 py-12 text-center bg-white rounded-2xl border border-gray-100">Aucune demande en attente.</p>
          ) : (
            pendingUsers.map(user => (
              <div key={user.id} className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center justify-between">
                <div className="flex flex-col gap-1">
                  <h4 className="font-bold text-gray-800 text-lg">{user.name}</h4>
                  <p className="text-gray-500 text-sm">{user.email}</p>
                  <div className="flex items-center gap-3 mt-1">
                    <span className={`px-3 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider ${user.role === UserRole.STUDENT ? 'bg-emerald-50 text-emerald-600' : 'bg-purple-50 text-purple-600'}`}>
                      {user.role === UserRole.STUDENT ? 'Étudiant' : 'Enseignant'}
                    </span>
                  </div>
                </div>
                <div className="flex gap-3">
                  <button 
                    onClick={() => handleApprove(user.id)}
                    disabled={isProcessing === user.id}
                    className="bg-emerald-600 hover:bg-emerald-700 text-white px-6 py-2 rounded-xl text-sm font-bold shadow-sm transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isProcessing === user.id ? '⏳' : 'Approuver'}
                  </button>
                  <button 
                    onClick={() => handleReject(user.id)}
                    disabled={isProcessing === user.id}
                    className="bg-red-600 hover:bg-red-700 text-white px-6 py-2 rounded-xl text-sm font-bold shadow-sm transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isProcessing === user.id ? '⏳' : 'Rejeter'}
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {activeTab === 'users' && (
        <div className="space-y-8 pb-12 animate-fadeIn">
          <div className="max-w-md relative group">
            <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
              <ICONS.Search />
            </div>
            <input
              type="text"
              placeholder="Rechercher un utilisateur (nom, email)..."
              value={userSearch}
              onChange={(e) => setUserSearch(e.target.value)}
              className="w-full pl-12 pr-6 py-3.5 bg-white border border-slate-100 rounded-[1.5rem] shadow-sm outline-none focus:ring-4 focus:ring-blue-100 focus:border-blue-300 transition-all font-medium text-sm text-gray-900"
            />
          </div>

          {admins.length > 0 && (
            <div>
              <h3 className="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
                Administrateurs <span className="text-gray-400 font-normal">({admins.length})</span>
              </h3>
              <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden shadow-sm">
                <table className="w-full text-left">
                  <thead className="bg-gray-50/50 text-gray-500 text-xs font-bold uppercase tracking-wider">
                    <tr>
                      <th className="px-6 py-4">Nom</th>
                      <th className="px-6 py-4">Email</th>
                      <th className="px-6 py-4 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {admins.map(a => (
                      <tr key={a.id} className="hover:bg-gray-50/50 transition-colors">
                        <td className="px-6 py-4 font-bold text-gray-800">{a.name}</td>
                        <td className="px-6 py-4 text-gray-500 text-sm">{a.email}</td>
                        <td className="px-6 py-4 text-right space-x-2">
                          <button 
                            onClick={() => handleDeleteUser(a.id)} 
                            disabled={isProcessing === a.id}
                            className="text-red-500 hover:text-red-700 p-2 disabled:opacity-50"
                          >
                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          <div>
            <h3 className="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
              Étudiants <span className="text-gray-400 font-normal">({students.length})</span>
            </h3>
            <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden shadow-sm">
              <table className="w-full text-left">
                <thead className="bg-gray-50/50 text-gray-500 text-xs font-bold uppercase tracking-wider">
                  <tr>
                    <th className="px-6 py-4">Nom</th>
                    <th className="px-6 py-4">Email</th>
                    <th className="px-6 py-4">Status</th>
                    <th className="px-6 py-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {students.map(s => (
                    <tr key={s.id} className={`hover:bg-gray-50/50 transition-colors ${s.banned ? 'bg-red-50/30' : ''}`}>
                      <td className="px-6 py-4 font-bold text-gray-800">{s.name}</td>
                      <td className="px-6 py-4 text-gray-500 text-sm">{s.email}</td>
                      <td className="px-6 py-4">
                        {s.banned ? <span className="text-red-600 font-bold text-[10px] uppercase">Banni</span> : <span className="text-emerald-600 font-bold text-[10px] uppercase">Actif</span>}
                      </td>
                      <td className="px-6 py-4 text-right space-x-2">
                        <button 
                          onClick={() => handlePromoteUser(s.id)} 
                          disabled={isProcessing === s.id}
                          className="text-blue-500 hover:bg-blue-50 p-2 rounded-lg disabled:opacity-50" 
                          title="Promouvoir Admin"
                        >
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 11l3-3m0 0l3 3m-3-3v8m0-13a9 9 0 110 18 9 9 0 010-18z" /></svg>
                        </button>
                        <button 
                          onClick={() => handleBanUser(s.id, s.banned || false)} 
                          disabled={isProcessing === s.id}
                          className={`${s.banned ? 'text-emerald-500' : 'text-orange-500'} hover:bg-gray-100 p-2 rounded-lg disabled:opacity-50`} 
                          title={s.banned ? 'Débannir' : 'Bannir'}
                        >
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" /></svg>
                        </button>
                        <button 
                          onClick={() => handleDeleteUser(s.id)} 
                          disabled={isProcessing === s.id}
                          className="text-red-500 hover:bg-red-50 p-2 rounded-lg disabled:opacity-50" 
                          title="Supprimer"
                        >
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          <div>
            <h3 className="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
              Enseignants <span className="text-gray-400 font-normal">({lecturers.length})</span>
            </h3>
            <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden shadow-sm">
              <table className="w-full text-left">
                <thead className="bg-gray-50/50 text-gray-500 text-xs font-bold uppercase tracking-wider">
                  <tr>
                    <th className="px-6 py-4">Nom</th>
                    <th className="px-6 py-4">Email</th>
                    <th className="px-6 py-4">Status</th>
                    <th className="px-6 py-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {lecturers.map(l => (
                    <tr key={l.id} className={`hover:bg-gray-50/50 transition-colors ${l.banned ? 'bg-red-50/30' : ''}`}>
                      <td className="px-6 py-4 font-bold text-gray-800">{l.name}</td>
                      <td className="px-6 py-4 text-gray-500 text-sm">{l.email}</td>
                      <td className="px-6 py-4">
                        {l.banned ? <span className="text-red-600 font-bold text-[10px] uppercase">Banni</span> : <span className="text-emerald-600 font-bold text-[10px] uppercase">Actif</span>}
                      </td>
                      <td className="px-6 py-4 text-right space-x-2">
                        <button 
                          onClick={() => handlePromoteUser(l.id)} 
                          disabled={isProcessing === l.id}
                          className="text-blue-500 hover:bg-blue-50 p-2 rounded-lg disabled:opacity-50" 
                          title="Promouvoir Admin"
                        >
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 11l3-3m0 0l3 3m-3-3v8m0-13a9 9 0 110 18 9 9 0 010-18z" /></svg>
                        </button>
                        <button 
                          onClick={() => handleBanUser(l.id, l.banned || false)} 
                          disabled={isProcessing === l.id}
                          className={`${l.banned ? 'text-emerald-500' : 'text-orange-500'} hover:bg-gray-100 p-2 rounded-lg disabled:opacity-50`} 
                          title={l.banned ? 'Débannir' : 'Bannir'}
                        >
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" /></svg>
                        </button>
                        <button 
                          onClick={() => handleDeleteUser(l.id)} 
                          disabled={isProcessing === l.id}
                          className="text-red-500 hover:bg-red-50 p-2 rounded-lg disabled:opacity-50" 
                          title="Supprimer"
                        >
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {activeTab === 'moderation' && (
        <div className="space-y-6 animate-fadeIn pb-12">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
            <h3 className="text-lg font-bold text-gray-800 shrink-0">Modération des Discussions <span className="text-gray-400 font-normal">({posts.length})</span></h3>
            <div className="max-w-md w-full relative group">
              <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <ICONS.Search />
              </div>
              <input
                type="text"
                placeholder="Rechercher par titre ou auteur..."
                value={modSearch}
                onChange={(e) => setModSearch(e.target.value)}
                className="w-full pl-12 pr-6 py-3 bg-white border border-slate-100 rounded-[1.2rem] shadow-sm outline-none focus:ring-4 focus:ring-blue-100 focus:border-blue-300 transition-all font-medium text-sm text-gray-900"
              />
            </div>
          </div>
          <div className="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm">
            <table className="w-full text-left">
              <thead className="bg-gray-50/50 text-gray-500 text-[10px] font-black uppercase tracking-widest">
                <tr>
                  <th className="px-8 py-5">Titre & Catégorie</th>
                  <th className="px-8 py-5">Auteur</th>
                  <th className="px-8 py-5">Replies</th>
                  <th className="px-8 py-5">Status</th>
                  <th className="px-8 py-5 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {filteredPosts.map(post => (
                  <tr key={post.id} className={`hover:bg-slate-50/50 transition-colors ${post.blocked ? 'opacity-50 grayscale bg-gray-50' : ''}`}>
                    <td className="px-8 py-6">
                      <div className="flex flex-col gap-1">
                        <span className="font-bold text-gray-900 line-clamp-1">{post.title}</span>
                        <span className="text-[9px] font-black uppercase tracking-widest text-blue-500">{post.category}</span>
                      </div>
                    </td>
                    <td className="px-8 py-6 text-sm text-gray-500 font-medium">{post.authorName}</td>
                    <td className="px-8 py-6 text-sm text-gray-400 font-black">{post.comments}</td>
                    <td className="px-8 py-6">
                      {post.blocked ? <span className="text-red-500 text-[9px] font-black uppercase">Bloqué</span> : <span className="text-emerald-500 text-[9px] font-black uppercase">Visible</span>}
                    </td>
                    <td className="px-8 py-6 text-right space-x-2">
                      <button 
                        onClick={() => handleBlockPost(post.id, post.blocked || false)} 
                        disabled={isProcessing === post.id}
                        className={`p-2 rounded-xl transition-all disabled:opacity-50 ${post.blocked ? 'bg-emerald-50 text-emerald-600' : 'bg-orange-50 text-orange-600'} hover:scale-110`}
                        title={post.blocked ? "Débloquer" : "Bloquer"}
                      >
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" /></svg>
                      </button>
                      <button 
                        onClick={() => handleDeletePost(post.id)} 
                        disabled={isProcessing === post.id}
                        className="p-2 bg-red-50 text-red-500 rounded-xl hover:bg-red-500 hover:text-white transition-all hover:scale-110 disabled:opacity-50"
                        title="Supprimer définitivement"
                      >
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                      </button>
                    </td>
                  </tr>
                ))}
                {filteredPosts.length === 0 && (
                  <tr>
                    <td colSpan={5} className="px-8 py-12 text-center text-gray-400 font-medium italic">Aucune conversation trouvée.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminPanel;