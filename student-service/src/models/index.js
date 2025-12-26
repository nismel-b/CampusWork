const { sequelize } = require('../config/database');
const StudentProfileModel = require('./studentProfile');
const StudentProfile = StudentProfileModel(sequelize);
// Currently only one model, but ready for expansion
const db = {
sequelize,           // Sequelize instance (for transactions, queries)
StudentProfile       // StudentProfile model
};

module.exports = db;
