const express = require('express');
const router = express.Router();
const studentController = require('../controllers/studentController');
const { authenticate, authorize } = require('../middleware/authMiddleware');
const { validationRules, handleValidationErrors } = require('../middleware/validationMiddleware');
router.get(
'/search',
studentController.searchStudents
);
router.post(
'/profile',
authenticate,                              // Verify JWT token
authorize('student'),                      // Only students can create student profiles
validationRules.createProfile,             // Validate input
handleValidationErrors,                    // Check for validation errors
studentController.createProfile
);
router.get(
'/profile/me',
authenticate,
authorize('student'),
studentController.getOwnProfile
);
router.put(
'/profile/me',
authenticate,
authorize('student'),
validationRules.updateProfile,
handleValidationErrors,
studentController.updateOwnProfile
);
router.post(
'/profile/me/skills',
authenticate,
authorize('student'),
validationRules.addSkill,
handleValidationErrors,
studentController.addSkill
);
router.delete(
'/profile/me/skills/:skill',
authenticate,
authorize('student'),
studentController.removeSkill
);
router.get(
'/profile/:userId',
authenticate,  // Optional: Will set req.user if token present
studentController.getProfileByUserId
);
router.get(
'/profile/:userId/full',
authenticate,
studentController.getStudentWithUserInfo
);
router.get(
'/profile/matriculation/:number',
authenticate,
authorize('admin', 'lecturer'),  // Admins and lecturers can search by matric number
studentController.getProfileByMatriculationNumber
);
router.put(
'/profile/:userId',
authenticate,
authorize('admin'),
validationRules.updateProfile,
handleValidationErrors,
studentController.updateProfile
);
router.delete(
'/profile/:userId',
authenticate,
authorize('admin', 'student'),  // Admin or student (controller checks if owner)
studentController.deleteProfile
);
router.get(
'/statistics',
authenticate,
authorize('admin'),
studentController.getStatistics
);
router.get('/health', (req, res) => {
res.status(200).json({
status: 'healthy',
service: 'student-service',
timestamp: new Date().toISOString()
});
});
module.exports = router;

