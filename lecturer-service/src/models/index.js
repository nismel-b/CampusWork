const { sequelize } = require('../config/database');
const LecturerProfileModel = require('./LecturerProfile');
const LecturerProfile = LecturerProfileModel(sequelize);
// Actuellement un seul modèle, mais prêt pour l'expansion
const db = {
sequelize,
LecturerProfile
};

module.exports = db;
