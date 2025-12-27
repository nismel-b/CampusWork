const Project = require('../models/project');
const fs = require('fs');
const { getLimitByMime } = require('../utils/filevalidation');

exports.createProject = async (req, res) => {
  try {
    // vérification du role de l'utilisateur
    if (req.user.role !== 'student') {
      return res.status(403).json({ message: 'Only students can upload projects' });
    }

    // Validation post-upload des tailles de fichiers
    const processedFiles = [];
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        const limit = getLimitByMime(file.mimetype);
        if (file.size > limit) {
          // Si un fichier est trop gros, on supprime tout ce qui a été uploadé et on erreur
          req.files.forEach(f => fs.unlinkSync(f.path));
          return res.status(400).json({ 
            message: `File ${file.originalname} exceeds limit for type ${file.mimetype}` 
          });
        }
        processedFiles.push({
          originalName: file.originalname,
          filename: file.filename,
          mimetype: file.mimetype,
          size: file.size,
          path: `/uploads/${file.filename}` // Chemin public
        });
      }
    }

    const files = req.files.map(file => ({
      type: file.mimetype,
      url: `/uploads/${file.filename}`,
      size: file.size,
    }));

    // 2. Création du projet
    // req.body contient les champs texte. req.user vient du middleware.
    const newProject = new Project({
      ...req.body,
      authorId: req.user.id, // ID sécurisé venant du token
      authorName: req.user.name || 'Unknown', 
      files: processedFiles,
      keywords: req.body.keywords ? req.body.keywords.split(',').map(k => k.trim()) : []
    });

    await newProject.save();

    res.status(201).json({ message: 'Project created successfully', project: newProject });

  } catch (error) {
    // Nettoyage en cas d'erreur
    if (req.files) req.files.forEach(f => fs.unlinkSync(f.path));
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

exports.getAllProjects = async (req, res) => {
  try {
    const { keyword, department } = req.query;
    let query = { status: 'public' };

    if (keyword) {
      query.$or = [
        { title: { $regex: keyword, $options: 'i' } },
        { keywords: { $in: [new RegExp(keyword, 'i')] } }
      ];
    }
    if (department) query.department = department;

    const projects = await Project.find(query)
      .sort({ createdAt: -1 })
      .select('-__v'); // Exclure version key

    res.json(projects);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
