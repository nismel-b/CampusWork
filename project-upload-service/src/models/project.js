const mongoose = require('mongoose');

const FileSchema = new mongoose.Schema({
  originalName: String,
  filename: String,
  mimetype: String,
  size: Number,
  path: String,
});

const ProjectSchema = new mongoose.Schema({
  title: { type: String, required: true },
  abstract: { type: String, required: true },
  university: String,
  department: String,
  year: Number,
  
  // Données de l'auteur (venant du token)
  authorId: { type: String, required: true, index: true },
  authorName: String, // Optionnel, pour affichage rapide
  authorBio: String,

  githubUrl: String,
  videoUrl: String,
  keywords: [String],
  
  status: { 
    type: String, 
    enum: ['public', 'private', 'archived'], 
    default: 'public' 
  },

  files: [FileSchema],

  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Project', ProjectSchema);