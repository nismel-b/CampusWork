const router = require('express').Router();
const upload = require('../config/multer');
const controller = require('../controllers/project.controller');
const verifyToken = require('../middlewares/auth.middleware');

// Route publique : voir les projets
router.get('/', controller.getAllProjects);

// Route protégée : créer un projet
// On attend un champ form-data nommé 'projectFiles' (plus clair que 'files')
router.post('/', 
  verifyToken, 
  upload.array('projectFiles', 5), // Max 5 fichiers par projet
  controller.createProject
);

module.exports = router;