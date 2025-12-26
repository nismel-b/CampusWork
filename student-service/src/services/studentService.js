const { StudentProfile } = require('../models');
const redisClient = require('../../../shared/utils/redisClient');
const axios = require('axios');
const logger = require('../../../shared/utils/logger');
const {
NotFoundError,
ValidationError,
ConflictError
} = require('../../../shared/utils/errorHandler');
class StudentService {
    async createProfile(userId, profileData = {}) {
try {
// 1. CHECK IF PROFILE ALREADY EXISTS
const existingProfile = await StudentProfile.findOne({
where: { userId }
});
if (existingProfile) {
throw new ConflictError('Student profile already exists for this user');
}
// 2. CHECK IF MATRICULATION NUMBER IS UNIQUE (if provided)
if (profileData.matriculationNumber) {
const duplicateMatric = await StudentProfile.findOne({
where: { matriculationNumber: profileData.matriculationNumber }
});
if (duplicateMatric) {
throw new ConflictError('Matriculation number already in use');
}
}
// 3. CREATE PROFILE
const profile = await StudentProfile.create({
userId,
...profileData,
enrollmentStatus: 'active',
profileVisibility: profileData.profileVisibility || 'public'
});
logger.info('Student profile created', {
userId,
profileId: profile.id
});
// 4. CACHE THE PROFILE (for faster future access)
await redisClient.set( 'student:${userId}',
profile.toJSON(),
3600  // 1 hour cache
);
return profile.toJSON();
} catch (error) {
  logger.error('Failed to create student profile', { 
    userId, 
    error: error.message 
  });
  throw error;
}
}

async getProfileByUserId(userId) {
try {
// 1. TRY CACHE FIRST
const cachedProfile = await redisClient.get('student:${userId}');
if (cachedProfile) {
logger.debug('Cache hit for student profile', { userId });
return cachedProfile;
}
// 2. CACHE MISS - QUERY DATABASE
logger.debug('Cache miss for student profile', { userId });
const profile = await StudentProfile.findOne({
where: { userId }
});
if (!profile) {
throw new NotFoundError('Student profile not found');
}
// 3. CACHE FOR FUTURE REQUESTS
await redisClient.set(
'student:${userId}',
profile.toJSON(),
3600
);
return profile.toJSON();

} catch (error) {
  logger.error('Failed to get student profile', { 
    userId, 
    error: error.message 
  });
  throw error;
}
}
async getProfileByMatriculationNumber(matriculationNumber) {
try {
const profile = await StudentProfile.findOne({
where: { matriculationNumber }
});
if (!profile) {
throw new NotFoundError('Student not found');
}
return profile.toJSON();

} catch (error) {
  logger.error('Failed to get student by matriculation number', { 
    matriculationNumber, 
    error: error.message 
  });
  throw error;
}
}
async updateProfile(userId, updateData) {
try {
// 1. FIND PROFILE
const profile = await StudentProfile.findOne({
where: { userId }
});
if (!profile) {
throw new NotFoundError('Student profile not found');
}
// 2. CHECK FOR DUPLICATE MATRICULATION NUMBER (if updating)
if (updateData.matriculationNumber &&
updateData.matriculationNumber !== profile.matriculationNumber) {
const duplicate = await StudentProfile.findOne({
where: { matriculationNumber: updateData.matriculationNumber }
});
if (duplicate) {
throw new ConflictError('Matriculation number already in use');
}
}
// 3. UPDATE PROFILE
await profile.update(updateData);
logger.info('Student profile updated', {
userId,
updatedFields: Object.keys(updateData)
});
// 4. INVALIDATE CACHE
await redisClient.del('student:${userId}');
// 5. CACHE NEW DATA
await redisClient.set(
'student:${userId}',
profile.toJSON(),
3600
);
return profile.toJSON();
} catch (error) {
  logger.error('Failed to update student profile', { 
    userId, 
    error: error.message 
  });
  throw error;
}
}
async deleteProfile(userId) {
try {
const profile = await StudentProfile.findOne({
where: { userId }
});
if (!profile) {
// Profile doesn't exist, but that's okay (idempotent operation)
logger.warn('Attempted to delete non-existent student profile', { userId });
return true;
}
// DELETE FROM DATABASE
await profile.destroy();
logger.info('Student profile deleted', { userId });
// REMOVE FROM CACHE
await redisClient.del('student:${userId}');
return true;

} catch (error) {
  logger.error('Failed to delete student profile', { 
    userId, 
    error: error.message 
  });
  throw error;
}
}
async addSkill(userId, skill) {
try {
const profile = await StudentProfile.findOne({
where: { userId }
});
if (!profile) {
throw new NotFoundError('Student profile not found');
}
// Use the model method
await profile.addSkill(skill);
logger.info('Skill added to student profile', { userId, skill });
// Invalidate cache
await redisClient.del('student:${userId}');
return profile.toJSON();

} catch (error) {
  logger.error('Failed to add skill', { userId, error: error.message });
  throw error;
}
}
async removeSkill(userId, skill) {
try {
const profile = await StudentProfile.findOne({
where: { userId }
});
  if (!profile) {
    throw new NotFoundError('Student profile not found');
  }  await profile.removeSkill(skill);  logger.info('Skill removed from student profile', { userId, skill });  // Invalidate cache
  await redisClient.del(`student:${userId}`);  return profile.toJSON();
} catch (error) {
    logger.error('Failed to remove skill', { userId, error: error.message });
    throw error;
}
}
async searchStudents(filters = {}, page = 1, limit = 20) {
try {
const where = {};
// Apply filters
if (filters.program) {
where.program = filters.program;
}
if (filters.graduationYear) {
where.graduationYear = filters.graduationYear;
}
if (filters.enrollmentStatus) {
where.enrollmentStatus = filters.enrollmentStatus;
}
// Only show public profiles in search (privacy)
where.profileVisibility = 'public';
// Calculate pagination
const offset = (page - 1) * limit;
// Query database
const { count, rows } = await StudentProfile.findAndCountAll({
where,
limit,
offset,
order: [['created_at', 'DESC']]
});
logger.info('Students searched', {
filters,
resultCount: rows.length
});
return {
students: rows.map(s => s.toJSON()),
totalCount: count,
page,
totalPages: Math.ceil(count / limit),
limit
};
} catch (error) {
  logger.error('Failed to search students', { 
    filters, 
    error: error.message 
  });
  throw error;
}
}
/*async getStudentWithUserInfo(userId) {
try {
// 1. GET STUDENT PROFILE (from our database)
const studentProfile = await this.getProfileByUserId(userId);
// 2. GET USER INFO (from Auth Service via HTTP)
let userInfo = null;
try {
const authServiceUrl = process.env.AUTH_SERVICE_URL || 'http://auth-service:3001';
const response = await axios.get(
${authServiceUrl}/api/auth/users/${userId},
{
timeout: 5000,  // 5 second timeout
headers: {
'X-Service-Token': process.env.SERVICE_AUTH_TOKEN  // Service-to-service auth
}
}
);
userInfo = response.data.data;
} catch (error) {
// If Auth Service is down, log but don't fail the whole request
logger.warn('Failed to fetch user info from Auth Service', {
userId,
error: error.message
});
}
// 3. COMBINE DATA
return {
...studentProfile,
user: userInfo || {
firstName: 'Unknown',
lastName: 'User'
}  // Fallback if Auth Service unavailable
};
} catch (error) {
  logger.error('Failed to get student with user info', { 
    userId, 
    error: error.message 
  });
  throw error;
}
}
}*/
// ...existing code...
async getStudentWithUserInfo(userId) {
  try {
    // 1. FETCH STUDENT PROFILE
    const studentProfile = await this.getStudentProfile(userId);

    // 2. FETCH USER INFO (Auth Service) - don't fail if Auth is down
    let userInfo;
    try {
      const response = await axios.get(`${authUrl}/users/${userId}`);
      userInfo = response.data.data;
    } catch (error) {
      // If Auth Service is down, log but don't fail the whole request
      logger.warn('Failed to fetch user info from Auth Service', {
        userId,
        error: error.message
      });
      userInfo = null;
    }

    // 3. COMBINE DATA
    return {
      ...studentProfile,
      user: userInfo || {
        firstName: 'Unknown',
        lastName: 'User'
      } // Fallback if Auth Service unavailable
    };
  } catch (error) {
    logger.error('Failed to get student with user info', {
      userId,
      error: error.message
    });
    throw error;
  }
}
}

module.exports = new StudentService();

