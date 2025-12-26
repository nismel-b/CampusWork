const { DataTypes } = require('sequelize');
module.exports = (sequelize) => {
const StudentProfile = sequelize.define('StudentProfile', {
    id: {
type: DataTypes.INTEGER,
primaryKey: true,
autoIncrement: true,
field: 'profile_id'
},
userId: {
  type: DataTypes.UUID,
  allowNull: false,
  unique: true,  // One profile per user
  field: 'user_id',
  comment: 'References User.id from Auth Service (no FK constraint)'
},
matriculationNumber: {
  type: DataTypes.STRING(50),
  allowNull: true,
  unique: true,
  field: 'matriculation_number',
  validate: {
    len: {
      args: [5, 50],
      msg: 'Matriculation number must be 5-50 characters'
    }
  }
},
program: {
  type: DataTypes.STRING(200),
  allowNull: true,
  field: 'program',
  comment: 'Academic program/major'
},
specialization: {
  type: DataTypes.STRING(200),
  allowNull: true,
  field: 'specialization'
},
academicYear: {
  type: DataTypes.STRING(50),
  allowNull: true,
  field: 'academic_year',
  validate: {
    isIn: {
      args: [['1st Year', '2nd Year', '3rd Year', 'Final Year', 'Graduate']],
      msg: 'Invalid academic year'
    }
  }
},
graduationYear: {
  type: DataTypes.INTEGER,
  allowNull: true,
  field: 'graduation_year',
  validate: {
    min: 2020,
    max: 2030
  }
},
enrollmentStatus: {
  type: DataTypes.ENUM('active', 'on_leave', 'graduated', 'withdrawn'),
  defaultValue: 'active',
  allowNull: false,
  field: 'enrollment_status'
},
gpa: {
  type: DataTypes.DECIMAL(3, 2),  // 3 digits total, 2 after decimal
  allowNull: true,
  field: 'gpa',
  validate: {
    min: 0.00,
    max: 4.00
  },
  comment: 'GPA on 4.0 scale'
},
bio: {
  type: DataTypes.TEXT,
  allowNull: true,
  validate: {
    len: {
      args: [0, 1000],
      msg: 'Bio must not exceed 1000 characters'
    }
  }
},
linkedinUrl: {
  type: DataTypes.STRING(500),
  allowNull: true,
  field: 'linkedin_url',
  validate: {
    isUrl: true
  }
},
githubUrl: {
  type: DataTypes.STRING(500),
  allowNull: true,
  field: 'github_url',
  validate: {
    isUrl: true
  }
},
portfolioUrl: {
  type: DataTypes.STRING(500),
  allowNull: true,
  field: 'portfolio_url',
  validate: {
    isUrl: true
  }
},
skills: {
  type: DataTypes.JSONB,
  defaultValue: [],
  allowNull: true,
  comment: 'Array of student skills'
},
interests: {
  type: DataTypes.JSONB,
  defaultValue: [],
  allowNull: true
},
achievements: {
  type: DataTypes.JSONB,
  defaultValue: [],
  allowNull: true
},
profileCompleteness: {
  type: DataTypes.INTEGER,
  defaultValue: 0,
  allowNull: false,
  field: 'profile_completeness',
  validate: {
    min: 0,
    max: 100
  }
},
profileVisibility: {
  type: DataTypes.ENUM('public', 'institution', 'private'),
  defaultValue: 'public',
  allowNull: false,
  field: 'profile_visibility'
}
}, {
tableName: 'student_profiles',
indexes: [
  { fields: ['user_id'] },                    // Find profile by user
  { fields: ['matriculation_number'] },       // Find by student ID
  { fields: ['program'] },                    // Filter by program
  { fields: ['graduation_year'] },            // Filter by graduation year
  { fields: ['enrollment_status'] }           // Filter by status
],
hooks: {
    beforeSave: async (studentProfile) => {
    studentProfile.profileCompleteness = calculateCompleteness(studentProfile);
  }
}
});
StudentProfile.prototype.toJSON = function() {
const values = { ...this.get() };
// Could remove sensitive fields here if needed
return values;
};
StudentProfile.prototype.addSkill = async function(skill) {
if (!this.skills) this.skills = [];

// Avoid duplicates
if (!this.skills.includes(skill)) {
  this.skills.push(skill);
  await this.save();
}
};
StudentProfile.prototype.removeSkill = async function(skill) {
if (!this.skills) return;

this.skills = this.skills.filter(s => s !== skill);
await this.save();
};
return StudentProfile;
};
function calculateCompleteness(profile) {
const fields = [
'matriculationNumber',
'program',
'graduationYear',
'bio',
'linkedinUrl',
'githubUrl',
'skills',
'interests'
];

let filledCount = 0;
fields.forEach(field => {
const value = profile[field];
// Check if field is filled
if (value !== null && value !== undefined && value !== '') {
  // For arrays, check if not empty
  if (Array.isArray(value) && value.length > 0) {
    filledCount++;
  } else if (!Array.isArray(value)) {
    filledCount++;
  }
}
});
// Calculate percentage
return Math.floor((filledCount / fields.length) * 100);
}
