const multer = require('multer');
const path = require('path');
const { getLimitByMime } = require('../utils/filevalidation');
const fs = require('fs');

// Assurer que le dossier existe
const uploadDir = 'uploads/';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    // Nom unique : Timestamp-NomOriginalNettoyé
    const cleanName = file.originalname.replace(/\s+/g, '-').toLowerCase();
    cb(null, `${Date.now()}-${cleanName}`);
  },
});

const fileFilter = (req, file, cb) => {
  const limit = getLimitByMime(file.mimetype);
  
 
  cb(null, true);
};

const upload = multer({ 
  storage,
  fileFilter,
  limits: { fileSize: 150 * 1024 * 1024 } // Limite globale Max absolue (Code)
});

module.exports = upload;