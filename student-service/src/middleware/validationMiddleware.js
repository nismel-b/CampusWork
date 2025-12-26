const { body, param, validationResult } = require('express-validator');
const { ValidationError } = require('../../../shared/utils/errorHandler');
createProfile: [
body('matriculationNumber')
.optional()
.trim()
.isLength({ min: 5, max: 50 })
.withMessage('Matriculation number must be 5-50 characters')
.matches(/^[A-Z0-9]+$/)
.withMessage('Matriculation number must contain only uppercase letters and numbers'),

body('program')
.optional()
.trim()
.isLength({ min: 2, max: 200 })
.withMessage('Program must be 2-200 characters'),
body('specialization')
.optional()
.trim()
.isLength({ max: 200 })
.withMessage('Specialization must not exceed 200 characters'),
body('academicYear')
.optional()
.isIn(['1st Year', '2nd Year', '3rd Year', 'Final Year', 'Graduate'])
.withMessage('Invalid academic year'),
body('graduationYear')
.optional()
.isInt({ min: 2020, max: 2035 })
.withMessage('Graduation year must be between 2020 and 2035'),
body('gpa')
.optional()
.isFloat({ min: 0.00, max: 4.00 })
.withMessage('GPA must be between 0.00 and 4.00'),
body('bio')
.optional()
.trim()
.isLength({ max: 1000 })
.withMessage('Bio must not exceed 1000 characters'),
body('linkedinUrl')
.optional()
.isURL()
.withMessage('Invalid LinkedIn URL'),
body('githubUrl')
.optional()
.isURL()
.withMessage('Invalid GitHub URL'),
body('portfolioUrl')
.optional()
.isURL()
.withMessage('Invalid portfolio URL'),
body('skills')
.optional()
.isArray()
.withMessage('Skills must be an array'),
body('skills.*')
.optional()
.trim()
.isLength({ min: 1, max: 50 })
.withMessage('Each skill must be 1-50 characters'),
body('profileVisibility')
.optional()
.isIn(['public', 'institution', 'private'])
.withMessage('Invalid profile visibility option')
];
/*updateProfile: [
// Reuse create validation rules (all are optional)
...validationRules.createProfile
];
addSkill: [
body('skill')
.trim()
.notEmpty()
.withMessage('Skill is required')
.isLength({ min: 1, max: 50 })
.withMessage('Skill must be 1-50 characters')
],
};
const handleValidationErrors = (req, res, next) => {
const errors = validationResult(req);

if (!errors.isEmpty()) {
// Format errors for better readability
const errorMessages = errors.array().map(err => ({
field: err.path || err.param,
message: err.msg,
value: err.value
}));
logger.warn('Validation failed', { 
  errors: errorMessages,
  path: req.path 
});

throw new ValidationError('Validation failed', errorMessages);
}
next();
};*/
// ...existing code...

const validationRules = {
  createProfile,
  updateProfile: [
    // Reuse create validation rules (all are optional in your route handler if desired)
    ...createProfile
  ],
  addSkill: [
    body('skill')
      .trim()
      .notEmpty()
      .withMessage('Skill is required')
      .isLength({ min: 1, max: 50 })
      .withMessage('Skill must be 1-50 characters')
  ],
};

const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(err => ({
      field: err.path || err.param,
      message: err.msg,
      value: err.value
    }));
    logger.warn('Validation failed', { 
      errors: errorMessages,
      path: req.path 
    });

    throw new ValidationError('Validation failed', errorMessages);
  }
  next();
};

module.exports = {
validationRules,
handleValidationErrors
};

