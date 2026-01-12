
import React, { useState } from 'react';
import { Post, UserRole, PostCategory } from '../types';
import { ICONS } from '../constants';

interface DiscussionBoardProps {
  posts: Post[];
  onCreatePost?: () => void;
  onEditPost?: (post: Post) => void;
  onDeletePost?: (postId: string) => void;
  onPostClick: (post: Post) => void;
  onLike: (postId: string) => void;
  userRole: UserRole;
  currentUserId?: string;
  t: any;
  searchQuery?: string;
  setSearchQuery?: (query: string) => void;
}

const DiscussionBoard: React.FC<DiscussionBoardProps> = ({ posts, onCreatePost, onEditPost, onDeletePost, onPostClick, onLike, userRole, currentUserId, t, searchQuery, setSearchQuery }) => {
  const [filter, setFilter] = useState<PostCategory | 'All'>('All');

  const filtered = posts.filter(p => {
    const matchesFilter = filter === 'All' || p.category === filter;
    const matchesSearch = !searchQuery || 
      p.title.toLowerCase().includes(searchQuery.toLowerCase()) || 
      p.content.toLowerCase().includes(searchQuery.toLowerCase()) || 
      p.authorName.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesFilter && matchesSearch;
  });

  const getCategoryColor = (cat: PostCategory) => {
    switch(cat) {
      case 'Annonce': return 'bg-red-50 text-red-600 border-red-100';
      case 'Exercices': return 'bg-purple-50 text-purple-600 border-purple-100';
      case 'Aide': return 'bg-blue-50 text-blue-700 border-blue-100';
      default: return 'bg-slate-50 text-slate-700 border-slate-100';
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-6">
        {setSearchQuery && (
          <div className="relative group">
            <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
              <ICONS.Search />
            </div>
            <input
              type="text"
              placeholder="Rechercher une discussion..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-6 py-3.5 bg-white border border-slate-100 rounded-[1.5rem] shadow-sm outline-none focus:ring-4 focus:ring-blue-100 focus:border-blue-300 transition-all font-medium text-sm text-gray-900"
            />
          </div>
        )}
        <div className="flex flex-wrap gap-2">
          {['All', 'Annonce', 'Discussion', 'Aide', 'Exercices'].map(cat => (
            <button
              key={cat}
              onClick={() => setFilter(cat as any)}
              className={`px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all border ${filter === cat ? 'bg-blue-600 text-white border-blue-600 shadow-lg' : 'bg-white text-gray-500 border-gray-100 hover:bg-gray-50'}`}
            >
              {cat === 'All' ? 'Tous' : cat}
            </button>
          ))}
        </div>
        {onCreatePost && (
          <button 
            onClick={onCreatePost}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white py-3.5 rounded-2xl font-black flex items-center justify-center gap-2 shadow-xl shadow-blue-100 transition-all active:scale-95 uppercase tracking-widest text-xs"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" /></svg>
            {t.newPost}
          </button>
        )}
      </div>

      <div className="space-y-4 max-h-[600px] overflow-y-auto pr-2 custom-scrollbar">
        {filtered.length === 0 ? (
          <div className="text-center py-20 bg-white rounded-3xl border border-gray-100 text-gray-400 font-medium text-sm">Aucun message ici.</div>
        ) : filtered.map((post) => (
          <div 
            key={post.id} 
            className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100 hover:border-blue-200 hover:shadow-md transition-all cursor-pointer group animate-fadeIn relative"
            onClick={() => onPostClick(post)}
          >
            {/* Author actions */}
            {post.authorId === currentUserId && (
              <div className="absolute top-5 right-5 flex gap-2" onClick={e => e.stopPropagation()}>
                <button 
                  onClick={() => onEditPost?.(post)}
                  className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-all"
                  title="Modifier"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" /></svg>
                </button>
                <button 
                  onClick={() => onDeletePost?.(post.id)}
                  className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all"
                  title="Supprimer"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                </button>
              </div>
            )}

            <div className="flex justify-between items-start mb-3">
              <div className="space-y-1">
                <div className="flex items-center gap-2 mb-1">
                  <span className={`px-2 py-0.5 rounded-md font-black uppercase tracking-wider text-[8px] border ${getCategoryColor(post.category)}`}>
                    {post.category}
                  </span>
                  {post.deadline && <span className="text-[9px] bg-orange-50 text-orange-600 px-2 py-0.5 rounded-md font-black border border-orange-100">Deadline: {post.deadline}</span>}
                </div>
                <h3 className="font-black text-gray-900 group-hover:text-blue-600 transition-colors text-base line-clamp-1 pr-16">{post.title}</h3>
                <p className="text-[10px] text-gray-400 font-black uppercase tracking-wider">{post.authorName} • {post.createdAt}</p>
              </div>
            </div>
            
            <p className="text-gray-500 text-xs mb-5 leading-relaxed line-clamp-2 font-medium">{post.content}</p>
            
            <div className="pt-4 border-t border-gray-50 flex items-center gap-6" onClick={(e) => e.stopPropagation()}>
              <button 
                onClick={() => onLike(post.id)}
                className={`flex items-center gap-1.5 transition-colors group/btn ${post.likedBy?.includes(currentUserId || '') ? 'text-red-600 font-black' : 'text-gray-400 hover:text-red-500'}`}
              >
                <svg className={`w-4 h-4 transition-all ${post.likedBy?.includes(currentUserId || '') ? 'fill-current' : 'group-hover/btn:fill-red-500'}`} fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>
                <span className="text-[11px] font-black">{post.likes}</span>
              </button>
              {post.category !== 'Annonce' && (
                <div className="flex items-center gap-1.5 text-gray-400">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" /></svg>
                  <span className="text-[11px] font-black">{post.comments}</span>
                </div>
              )}
            </div>
          </div>
        ))}
      </div>

      <style>{`
        .custom-scrollbar::-webkit-scrollbar {
          width: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
          background: transparent;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
          background: #e2e8f0;
          border-radius: 10px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
          background: #cbd5e1;
        }
      `}</style>
    </div>
  );
};

export default DiscussionBoard;
