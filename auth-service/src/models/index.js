const { sequelize } = require('../config/database');
const UserModel = require('./User');

const User = UserModel(sequelize);

const db = {
  sequelize,
  User
};

module.exports = db;
