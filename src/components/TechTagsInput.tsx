import React, { useState } from 'react';

interface TechTagsInputProps {
  label: string;
  placeholder: string;
  items: string[];
  onChange: (items: string[]) => void;
  suggestions?: string[];
  maxItems?: number;
  icon?: 'tech' | 'tag';
}

const TechTagsInput: React.FC<TechTagsInputProps> = ({ 
  label, 
  placeholder, 
  items, 
  onChange, 
  suggestions = [],
  maxItems = 20,
  icon = 'tech'
}) => {
  const [inputValue, setInputValue] = useState('');
  const [showSuggestions, setShowSuggestions] = useState(false);

  // Suggestions prédéfinies pour technologies
  const techSuggestions = [
    'React', 'Angular', 'Vue.js', 'Node.js', 'Express', 'Django', 'Flask',
    'Spring Boot', 'Laravel', 'MongoDB', 'PostgreSQL', 'MySQL', 'Firebase',
    'AWS', 'Azure', 'Docker', 'Kubernetes', 'Python', 'JavaScript', 'TypeScript',
    'Java', 'C++', 'C#', 'PHP', 'Ruby', 'Go', 'Rust', 'Swift', 'Kotlin',
    'TailwindCSS', 'Bootstrap', 'Material-UI', 'Redux', 'GraphQL', 'REST API',
    'Git', 'GitHub', 'GitLab', 'Jira', 'Figma', 'Adobe XD', 'TensorFlow',
    'PyTorch', 'Scikit-learn', 'Pandas', 'NumPy', 'Jupyter', 'Unity', 'Unreal Engine'
  ];

  const activeSuggestions = suggestions.length > 0 ? suggestions : (icon === 'tech' ? techSuggestions : []);

  const filteredSuggestions = activeSuggestions.filter(
    s => s.toLowerCase().includes(inputValue.toLowerCase()) && !items.includes(s)
  );

  const handleAdd = (value: string) => {
    const trimmed = value.trim();
    if (trimmed && !items.includes(trimmed) && items.length < maxItems) {
      onChange([...items, trimmed]);
      setInputValue('');
      setShowSuggestions(false);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      handleAdd(inputValue);
    } else if (e.key === 'Backspace' && !inputValue && items.length > 0) {
      onChange(items.slice(0, -1));
    }
  };

  const handleRemove = (index: number) => {
    onChange(items.filter((_, i) => i !== index));
  };

  const getIcon = () => {
    if (icon === 'tech') {
      return (
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
        </svg>
      );
    }
    return (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
      </svg>
    );
  };

  const getColorClass = () => {
    return icon === 'tech' 
      ? 'bg-purple-100 text-purple-700 border-purple-200 hover:bg-purple-600 hover:text-white'
      : 'bg-blue-100 text-blue-700 border-blue-200 hover:bg-blue-600 hover:text-white';
  };

  return (
    <div className="space-y-3">
      <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 flex items-center gap-2">
        {getIcon()}
        {label}
      </label>

      {/* Zone de tags */}
      <div className="bg-white border-2 border-slate-200 rounded-[2rem] p-4 min-h-[120px] focus-within:border-blue-500 transition-all">
        <div className="flex flex-wrap gap-2 mb-3">
          {items.map((item, index) => (
            <span
              key={index}
              className={`inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-black border-2 transition-all group ${getColorClass()}`}
            >
              {item}
              <button
                onClick={() => handleRemove(index)}
                className="flex-shrink-0 hover:scale-125 transition-transform"
                type="button"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </span>
          ))}
        </div>

        <div className="relative">
          <input
            type="text"
            value={inputValue}
            onChange={(e) => {
              setInputValue(e.target.value);
              setShowSuggestions(true);
            }}
            onKeyDown={handleKeyDown}
            onFocus={() => setShowSuggestions(true)}
            placeholder={items.length >= maxItems ? `Maximum ${maxItems} éléments atteints` : placeholder}
            disabled={items.length >= maxItems}
            className="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl font-medium text-sm text-slate-800 outline-none focus:bg-white focus:border-blue-400 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          />

          {/* Suggestions dropdown */}
          {showSuggestions && inputValue && filteredSuggestions.length > 0 && (
            <div className="absolute top-full left-0 right-0 mt-2 bg-white border-2 border-slate-200 rounded-2xl shadow-2xl max-h-60 overflow-y-auto z-20 animate-fadeIn">
              {filteredSuggestions.slice(0, 10).map((suggestion, index) => (
                <button
                  key={index}
                  type="button"
                  onClick={() => handleAdd(suggestion)}
                  className="w-full px-6 py-3 text-left text-sm font-bold text-slate-700 hover:bg-blue-50 hover:text-blue-600 transition-colors first:rounded-t-2xl last:rounded-b-2xl flex items-center gap-3"
                >
                  {getIcon()}
                  {suggestion}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Compteur */}
      <div className="flex items-center justify-between px-4">
        <p className="text-xs text-slate-500 font-medium">
          Appuyez sur <kbd className="px-2 py-1 bg-slate-100 rounded text-[10px] font-black">Entrée</kbd> pour ajouter
        </p>
        <p className="text-xs text-slate-400 font-bold">
          {items.length}/{maxItems}
        </p>
      </div>

      {/* Suggestions populaires (si vide) */}
      {items.length === 0 && icon === 'tech' && (
        <div className="bg-purple-50 border-2 border-purple-100 rounded-2xl p-4">
          <p className="text-xs font-black text-purple-800 mb-3 uppercase tracking-widest">Suggestions Populaires :</p>
          <div className="flex flex-wrap gap-2">
            {['React', 'Node.js', 'Python', 'MongoDB', 'TailwindCSS', 'Docker'].map(tech => (
              <button
                key={tech}
                type="button"
                onClick={() => handleAdd(tech)}
                className="px-3 py-1.5 bg-white text-purple-600 rounded-lg text-xs font-bold hover:bg-purple-600 hover:text-white transition-all border border-purple-200"
              >
                + {tech}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default TechTagsInput;