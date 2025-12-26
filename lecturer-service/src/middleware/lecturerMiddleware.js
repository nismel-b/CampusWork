const jwt = require('jsonwebtoken');
const { body, param, query, validationResult } = require('express-validator');
const { UnauthorizedError, ForbiddenError } = require('../../../shared/utils/errorHandler');
exports.verifyToken = (req, res, next) => {
  try {
    // Récupérer le token depuis le header Authorization
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedError('No token provided');
    }

    const token = authHeader.substring(7); // Enlever "Bearer "

    // Vérifier et décoder le token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Ajouter les infos utilisateur à la requête
    req.user = {
      userId: decoded.userId,
      email: decoded.email,
      role: decoded.role
    };

    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      next(new UnauthorizedError('Invalid token'));
    } else if (error.name === 'TokenExpiredError') {
      next(new UnauthorizedError('Token expired'));
    } else {
      next(error);
    }
  }
};
exports.requireLecturer = (req, res, next) => {
  if (req.user.role !== 'lecturer' && req.user.role !== 'admin') {
    return next(new ForbiddenError('Lecturer access required'));
  }
  next();
};

/**
 * REQUIRE ADMIN ROLE
 * 
 * Vérifie que l'utilisateur a le rôle 'admin'.
 */
exports.requireAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return next(new ForbiddenError('Admin access required'));
  }
  next();
};
/**
 * ======================
 * VALIDATION MIDDLEWARE
 * ======================
 */

/**
 * VALIDATE RESULTS
 * 
 * Vérifie les résultats de validation express-validator.
 */
const validateResults = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array()
    });
  }
  
  next();
};

/**
 * CREATE PROFILE VALIDATION
 */
exports.validateCreateProfile = [
  body('title')
    .optional()
    .isIn(['Dr.', 'Prof.', 'Prof. Dr.', 'Ing.', 'M.', 'Mme.', 'Mr.', 'Mrs.', 'Ms.'])
    .withMessage('Invalid title'),
  
  body('department')
    .optional()
    .isLength({ min: 2, max: 200 })
    .withMessage('Department must be between 2 and 200 characters'),
  
  body('specialization')
    .optional()
    .isLength({ min: 2, max: 200 })
    .withMessage('Specialization must be between 2 and 200 characters'),
  
  body('academicRank')
    .optional()
    .isIn([
      'assistant_lecturer',
      'lecturer',
      'senior_lecturer',
      'associate_professor',
      'professor',
      'emeritus_professor'
    ])
    .withMessage('Invalid academic rank'),
  
  body('teachingExperience')
    .optional()
    .isInt({ min: 0, max: 60 })
    .withMessage('Teaching experience must be between 0 and 60 years'),
  
  body('qualifications')
    .optional()
    .isArray()
    .withMessage('Qualifications must be an array'),
  
  body('researchInterests')
    .optional()
    .isArray()
    .withMessage('Research interests must be an array'),
  
  body('phoneNumber')
    .optional()
    .matches(/^[+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,9}$/)
    .withMessage('Invalid phone number format'),
  
  body('contactEmail')
    .optional()
    .isEmail()
    .normalizeEmail()
    .withMessage('Invalid email format'),
  
  body('bio')
    .optional()
    .isLength({ max: 2000 })
    .withMessage('Bio must not exceed 2000 characters'),
  
  body('researchStatement')
    .optional()
    .isLength({ max: 3000 })
    .withMessage('Research statement must not exceed 3000 characters'),
  
  body('linkedinUrl')
    .optional()
    .isURL()
    .withMessage('Invalid LinkedIn URL'),
  
  body('googleScholarUrl')
    .optional()
    .isURL()
    .withMessage('Invalid Google Scholar URL'),
  
  body('researchGateUrl')
    .optional()
    .isURL()
    .withMessage('Invalid ResearchGate URL'),
  
  body('orcidUrl')
    .optional()
    .isURL()
    .withMessage('Invalid ORCID URL'),
  
  body('personalWebsite')
    .optional()
    .isURL()
    .withMessage('Invalid website URL'),
  
  body('acceptingStudents')
    .optional()
    .isBoolean()
    .withMessage('Accepting students must be a boolean'),
  
  body('employmentStatus')
    .optional()
    .isIn(['full_time', 'part_time', 'visiting', 'emeritus', 'retired'])
    .withMessage('Invalid employment status'),
  
  body('profileVisibility')
    .optional()
    .isIn(['public', 'institution', 'private'])
    .withMessage('Invalid profile visibility'),
  
  validateResults
];

/**
 * UPDATE PROFILE VALIDATION
 */
exports.validateUpdateProfile = [
  // Mêmes validations que create, mais tout est optionnel
  ...exports.validateCreateProfile
];

/**
 * ADD RESEARCH INTEREST VALIDATION
 */
exports.validateAddResearchInterest = [
  body('interest')
    .notEmpty()
    .withMessage('Interest is required')
    .isLength({ min: 2, max: 100 })
    .withMessage('Interest must be between 2 and 100 characters'),
  
  validateResults
];

/**
 * ADD PUBLICATION VALIDATION
 */
exports.validateAddPublication = [
  body('title')
    .notEmpty()
    .withMessage('Publication title is required')
    .isLength({ min: 5, max: 500 })
    .withMessage('Title must be between 5 and 500 characters'),
  
  body('authors')
    .optional()
    .isArray()
    .withMessage('Authors must be an array'),
  
  body('journal')
    .optional()
    .isString()
    .withMessage('Journal must be a string'),
  
  body('year')
    .optional()
    .isInt({ min: 1900, max: 2100 })
    .withMessage('Invalid publication year'),
  
  body('doi')
    .optional()
    .isString()
    .withMessage('DOI must be a string'),
  
  validateResults
];

/**
 * UPDATE ACCEPTING STUDENTS VALIDATION
 */
exports.validateUpdateAcceptingStudents = [
  body('accepting')
    .notEmpty()
    .withMessage('Accepting status is required')
    .isBoolean()
    .withMessage('Accepting must be a boolean'),
  
  validateResults
];

/**
 * SEARCH VALIDATION
 */
exports.validateSearch = [
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  
  query('department')
    .optional()
    .isString()
    .withMessage('Department must be a string'),
  
  query('specialization')
    .optional()
    .isString()
    .withMessage('Specialization must be a string'),
  
  query('academicRank')
    .optional()
    .isIn([
      'assistant_lecturer',
      'lecturer',
      'senior_lecturer',
      'associate_professor',
      'professor',
      'emeritus_professor'
    ])
    .withMessage('Invalid academic rank'),
  
  query('acceptingStudents')
    .optional()
    .isBoolean()
    .withMessage('Accepting students must be a boolean'),
  
  query('employmentStatus')
    .optional()
    .isIn(['full_time', 'part_time', 'visiting', 'emeritus', 'retired'])
    .withMessage('Invalid employment status'),
  
  validateResults
];

/**
 * USER ID PARAM VALIDATION
 */
exports.validateUserId = [
  param('userId')
    .isUUID()
    .withMessage('Invalid user ID format'),
  
  validateResults
];
