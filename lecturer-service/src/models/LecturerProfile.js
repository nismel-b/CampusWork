const { DataTypes } = require('sequelize');
const { Hooks } = require('sequelize/lib/hooks');
module.exports = (sequelize) => {
const LecturerProfile = sequelize.define('LecturerProfile', {
    id: {
type: DataTypes.INTEGER,
primaryKey: true,
autoIncrement: true,
field: 'profile_id'
},
userId: {
  type: DataTypes.UUID,
  allowNull: false,
  unique: true,  // Un profil par utilisateur
  field: 'user_id',
  comment: 'References User.id from Auth Service (no FK constraint)'
},
title: {
  type: DataTypes.STRING(20),
  allowNull: true,
  field: 'title',
  validate: {
    isIn: {
      args: [['Dr.', 'Prof.', 'Prof. Dr.', 'Ing.', 'M.', 'Mme.', 'Mr.', 'Mrs.', 'Ms.']],
      msg: 'Invalid title'
    }
  }
},
department: {
  type: DataTypes.STRING(200),
  allowNull: true,
  field: 'department'
},
specialization: {
  type: DataTypes.STRING(200),
  allowNull: true,
  field: 'specialization'
},
academicRank: {
  type: DataTypes.ENUM(
    'assistant_lecturer',
    'lecturer',
    'senior_lecturer',
    'associate_professor',
    'professor',
    'emeritus_professor'
  ),
  allowNull: true,
  field: 'academic_rank'
},
qualifications: {
  type: DataTypes.JSONB,
  defaultValue: [],
  allowNull: true,
  comment: 'Array of degree objects'
},
teachingExperience: {
  type: DataTypes.INTEGER,
  allowNull: true,
  field: 'teaching_experience',
  validate: {
    min: 0,
    max: 60
  },
  comment: 'Years of teaching experience'
},
researchInterests: {
  type: DataTypes.JSONB,
  defaultValue: [],
  allowNull: true,
  field: 'research_interests',
  comment: 'Array of research interest strings'
},
publications: {
  type: DataTypes.JSONB,
  defaultValue: [],
  allowNull: true,
  comment: 'Array of publication objects'
},
researchProjects: {
  type: DataTypes.JSONB,
  defaultValue: [],
  allowNull: true,
  field: 'research_projects'
},
coursesTaught: {
  type: DataTypes.JSONB,
  defaultValue: [],
  allowNull: true,
  field: 'courses_taught'
},
officeLocation: {
  type: DataTypes.STRING(200),
  allowNull: true,
  field: 'office_location'
},
officeHours: {
  type: DataTypes.JSONB,
  defaultValue: {},
  allowNull: true,
  field: 'office_hours'
},
phoneNumber: {
  type: DataTypes.STRING(20),
  allowNull: true,
  field: 'phone_number',
  validate: {
    is: /^[+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,9}$/
  }
},
contactEmail: {
  type: DataTypes.STRING(255),
  allowNull: true,
  field: 'contact_email',
  validate: {
    isEmail: true
  }
},
bio: {
  type: DataTypes.TEXT,
  allowNull: true,
  validate: {
    len: {
      args: [0, 2000],
      msg: 'Bio must not exceed 2000 characters'
    }
  }
},
researchStatement: {
  type: DataTypes.TEXT,
  allowNull: true,
  field: 'research_statement',
  validate: {
    len: {
      args: [0, 3000],
      msg: 'Research statement must not exceed 3000 characters'
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
googleScholarUrl: {
  type: DataTypes.STRING(500),
  allowNull: true,
  field: 'google_scholar_url',
  validate: {
    isUrl: true
  }
},

researchGateUrl: {
  type: DataTypes.STRING(500),
  allowNull: true,
  field: 'researchgate_url',
  validate: {
    isUrl: true
  }
},

orcidUrl: {
  type: DataTypes.STRING(500),
  allowNull: true,
  field: 'orcid_url',
  validate: {
    isUrl: true
  }
},

personalWebsite: {
  type: DataTypes.STRING(500),
  allowNull: true,
  field: 'personal_website',
  validate: {
    isUrl: true
  }
},
acceptingStudents: {
  type: DataTypes.BOOLEAN,
  defaultValue: true,
  allowNull: false,
  field: 'accepting_students'
},
employmentStatus: {
  type: DataTypes.ENUM('full_time', 'part_time', 'visiting', 'emeritus', 'retired'),
  defaultValue: 'full_time',
  allowNull: false,
  field: 'employment_status'
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
tableName: 'lecturer_profiles',
indexes: [
  { fields: ['user_id'] },
  { fields: ['department'] },
  { fields: ['specialization'] },
  { fields: ['academic_rank'] },
  { fields: ['accepting_students'] },
  { fields: ['employment_status'] }
],
hooks: {beforeSave: async (lecturerProfile) => {
    lecturerProfile.profileCompleteness = calculateCompleteness(lecturerProfile);
  }
}
});
LecturerProfile.prototype.toJSON = function() {
const values = { ...this.get() };
return values;
};
LecturerProfile.prototype.addResearchInterest = async function(interest) {
if (!this.researchInterests) this.researchInterests = [];

if (!this.researchInterests.includes(interest)) {
  this.researchInterests.push(interest);
  await this.save();
}
};
LecturerProfile.prototype.removeResearchInterest = async function(interest) {
if (!this.researchInterests) return;

this.researchInterests = this.researchInterests.filter(i => i !== interest);
await this.save();
};
LecturerProfile.prototype.addPublication = async function(publication) {
if (!this.publications) this.publications = [];

this.publications.push(publication);
await this.save();
};
return LecturerProfile;
};
function calculateCompleteness(profile) {
const fields = [
'title',
'department',
'specialization',
'academicRank',
'qualifications',
'bio',
'researchInterests',
'officeLocation',
'officeHours',
'contactEmail'
];

let filledCount = 0;
fields.forEach(field => {
const value = profile[field];
if (value !== null && value !== undefined && value !== '') {
  // Pour les tableaux, vérifier qu'ils ne sont pas vides
  if (Array.isArray(value) && value.length > 0) {
    filledCount++;
  } else if (!Array.isArray(value) && typeof value === 'object') {
    // Pour les objets, vérifier qu'ils ont des clés
    if (Object.keys(value).length > 0) {
      filledCount++;
    }
  } else if (!Array.isArray(value)) {
    filledCount++;
  }
}
});
return Math.round((filledCount / fields.length) * 100);
}