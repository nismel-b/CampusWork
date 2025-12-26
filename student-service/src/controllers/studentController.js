const studentService = require('../services/studentService');
const ResponseHandler = require('../../../shared/utils/responseHandler');
const { asyncHandler } = require('../../../shared/utils/errorHandler');
class StudentController {
    createProfile = asyncHandler(async (req, res) => {
// Extract user ID from JWT token (added by auth middleware)
const userId = req.user.userId;

// Get profile data from request body
const profileData = req.body;

// Call service to create profile
const profile = await studentService.createProfile(userId, profileData);

// Send success response
ResponseHandler.created(
  res, 
  { profile }, 
  'Student profile created successfully'
);
});
getOwnProfile = asyncHandler(async (req, res) => {
const userId = req.user.userId;

const profile = await studentService.getProfileByUserId(userId);
ResponseHandler.success(
  res, 
  { profile }, 
  'Profile retrieved successfully'
);
});
getProfileByUserId = asyncHandler(async (req, res) => {
const { userId } = req.params;
const requestingUserId = req.user?.userId;  // May be undefined if not authenticated

// Get profile
const profile = await studentService.getProfileByUserId(userId);

// PRIVACY CHECK
// If profile is private and requester is not the owner or admin
if (profile.profileVisibility === 'private' && 
    requestingUserId !== userId && 
    req.user?.role !== 'admin') {
  return ResponseHandler.error(
    res, 
    'This profile is private', 
    403
  );
}

ResponseHandler.success(
  res, 
  { profile }, 
  'Profile retrieved successfully'
);
});
getProfileByMatriculationNumber = asyncHandler(async (req, res) => {
const { number } = req.params;

const profile = await studentService.getProfileByMatriculationNumber(number);
// Privacy check (same as above)
if (profile.profileVisibility === 'private' && 
    req.user.userId !== profile.userId && 
    req.user.role !== 'admin') {
  return ResponseHandler.error(
    res, 
    'This profile is private', 
    403
  );
}

ResponseHandler.success(
  res, 
  { profile }, 
  'Profile retrieved successfully'
);
});
updateOwnProfile = asyncHandler(async (req, res) => {
const userId = req.user.userId;
const updateData = req.body;

const profile = await studentService.updateProfile(userId, updateData);
ResponseHandler.success(
  res, 
  { profile }, 
  'Profile updated successfully'
);
});
updateProfile = asyncHandler(async (req, res) => {
const { userId } = req.params;
const updateData = req.body;

const profile = await studentService.updateProfile(userId, updateData);
ResponseHandler.success(
  res, 
  { profile }, 
  'Profile updated successfully'
);
});
deleteProfile = asyncHandler(async (req, res) => {
const { userId } = req.params;
const requestingUserId = req.user.userId;

// Check permission: user can delete own profile, or admin can delete any
if (userId !== requestingUserId && req.user.role !== 'admin') {
  return ResponseHandler.error(
    res, 
    'You do not have permission to delete this profile', 
    403
  );
}

await studentService.deleteProfile(userId);

ResponseHandler.success(
  res, 
  null, 
  'Profile deleted successfully'
);
});
addSkill = asyncHandler(async (req, res) => {
const userId = req.user.userId;
const { skill } = req.body;

if (!skill) {
  return ResponseHandler.error(res, 'Skill is required', 400);
}

const profile = await studentService.addSkill(userId, skill);

ResponseHandler.success(
  res, 
  { profile }, 
  'Skill added successfully'
);
});
removeSkill = asyncHandler(async (req, res) => {
const userId = req.user.userId;
const { skill } = req.params;

const profile = await studentService.removeSkill(userId, skill);
ResponseHandler.success(
  res, 
  { profile }, 
  'Skill removed successfully'
);
});
searchStudents = asyncHandler(async (req, res) => {
// Extract query parameters
const { program, graduationYear, page = 1, limit = 20 } = req.query;

// Build filters object
const filters = {};
if (program) filters.program = program;
if (graduationYear) filters.graduationYear = parseInt(graduationYear);

// Call service
const result = await studentService.searchStudents(
  filters, 
  parseInt(page), 
  parseInt(limit)
);

// Send paginated response
ResponseHandler.paginated(
  res, 
  result.students, 
  {
    page: result.page,
    limit: result.limit,
    totalCount: result.totalCount
  },
  'Students retrieved successfully'
);
});
getStudentWithUserInfo = asyncHandler(async (req, res) => {
const { userId } = req.params;

const data = await studentService.getStudentWithUserInfo(userId);
ResponseHandler.success(
  res, 
  data, 
  'Student data retrieved successfully'
);
});
getStatistics = asyncHandler(async (req, res) => {
// This would be implemented in the service layer
// For now, return placeholder
ResponseHandler.success(
res,
{
totalStudents: 0,
byProgram: {},
byYear: {}
},
'Statistics retrieved successfully'
);
});
}

// Export singleton instance
module.exports = new StudentController();
