const { DataTypes } = require('sequelize');
const bcrypt = require('bcryptjs');

module.exports = (sequelize) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    email: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: {
        name: 'unique_email',
        msg: 'Email address already in use'
      },
      validate: {
        isEmail: {
          msg: 'Please provide a valid email address'
        }
      }
    },
    password: {
      type: DataTypes.STRING(255),
      allowNull: false,
      validate: {
        len: {
          args: [8, 255],
          msg: 'Password must be at least 8 characters long'
        }
      }
    },
    firstName: {
      type: DataTypes.STRING(100),
      allowNull: false,
      field: 'first_name'
    },
    lastName: {
      type: DataTypes.STRING(100),
      allowNull: false,
      field: 'last_name'
    },
    role: {
      type: DataTypes.ENUM('student', 'lecturer', 'admin'),
      allowNull: false,
      defaultValue: 'student'
    },
    emailVerified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      field: 'email_verified'
    },
    emailVerificationToken: {
      type: DataTypes.STRING(255),
      field: 'email_verification_token'
    },
    emailVerificationExpires: {
      type: DataTypes.DATE,
      field: 'email_verification_expires'
    },
    passwordResetToken: {
      type: DataTypes.STRING(255),
      field: 'password_reset_token'
    },
    passwordResetExpires: {
      type: DataTypes.DATE,
      field: 'password_reset_expires'
    },
    accountStatus: {
      type: DataTypes.ENUM('active', 'suspended', 'deleted'),
      defaultValue: 'active',
      field: 'account_status'
    },
    lastLogin: {
      type: DataTypes.DATE,
      field: 'last_login'
    },
    loginAttempts: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      field: 'login_attempts'
    },
    lockUntil: {
      type: DataTypes.DATE,
      field: 'lock_until'
    }
  }, {
    tableName: 'users',
    indexes: [
      { fields: ['email'] },
      { fields: ['role'] },
      { fields: ['account_status'] },
      { fields: ['email_verification_token'] },
      { fields: ['password_reset_token'] }
    ]
  });

  // Hash password before save
  User.beforeSave(async (user) => {
    if (user.changed('password')) {
      const salt = await bcrypt.genSalt(10);
      user.password = await bcrypt.hash(user.password, salt);
    }
  });

  // Instance methods
  User.prototype.comparePassword = async function(candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
  };

  User.prototype.isLocked = function() {
    return !!(this.lockUntil && this.lockUntil > Date.now());
  };

  User.prototype.toJSON = function() {
    const values = { ...this.get() };
    delete values.password;
    delete values.emailVerificationToken;
    delete values.passwordResetToken;
    delete values.loginAttempts;
    delete values.lockUntil;
    return values;
  };

  return User;
};
