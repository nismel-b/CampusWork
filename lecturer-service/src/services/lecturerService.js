const { LecturerProfile } = require('../models');
const redisClient = require('../../../shared/utils/redisClient');
const axios = require('axios');
const logger = require('../../../shared/utils/logger');
const {
NotFoundError,
ValidationError,
ConflictError
} = require('../../../shared/utils/errorHandler');
const { where } = require('sequelize');
class LecturerService {
    async createProfile(userId, profileData = {}) {
try {
// 1. VÉRIFIER SI LE PROFIL EXISTE DÉJÀ
const existingProfile = await LecturerProfile.findOne({
where: { userId }
});

if (existingProfile) {
throw new ConflictError('Lecturer profile already exists for this user');
}
// 2. CRÉER LE PROFIL
const profile = await LecturerProfile.create({
userId,
...profileData,
employmentStatus: profileData.employmentStatus || 'full_time',
acceptingStudents: profileData.acceptingStudents !== false, // default true
profileVisibility: profileData.profileVisibility || 'public'
});
logger.info('Lecturer profile created', {
userId,
profileId: profile.id
});
// 3. METTRE EN CACHE
await redisClient.set(
`lecturer:${userId}`,
profile.toJSON(),
3600  // 1 heure
);
return profile.toJSON();

} catch (error) {
  logger.error('Failed to create lecturer profile', {
    userId,
    error: error.message
  });
  throw error;
}
}
async getProfileByUserId(userId) {
try {
// 1. ESSAYER LE CACHE D'ABORD
const cachedProfile = await redisClient.get(`lecturer:${userId}`);
if (cachedProfile) {
logger.debug('Cache hit for lecturer profile', { userId });
return cachedProfile;
}
// 2. CACHE MISS - INTERROGER LA BDD
logger.debug('Cache miss for lecturer profile', { userId });
const profile = await LecturerProfile.findOne({
where: { userId }
});
if (!profile) {
throw new NotFoundError('Lecturer profile not found');
}
// 3. METTRE EN CACHE
await redisClient.set(
`lecturer:${userId}`,
profile.toJSON(),
3600
);
return profile.toJSON();

} catch (error) {
  logger.error('Failed to get lecturer profile', {
    userId,
    error: error.message
  });
  throw error;
}
}
async updateProfile(userId, updateData) {
try {
// 1. TROUVER LE PROFIL
const profile = await LecturerProfile.findOne({
where: { userId }
});
if (!profile) {
throw new NotFoundError('Lecturer profile not found');
}
// 2. METTRE À JOUR
await profile.update(updateData);
logger.info('Lecturer profile updated', {
userId,
updatedFields: Object.keys(updateData)
});
// 3. INVALIDER LE CACHE
await redisClient.del(`lecturer:${userId}`);
// 4. METTRE EN CACHE LES NOUVELLES DONNÉES
await redisClient.set(
`lecturer:${userId}`,
profile.toJSON(),
3600
);
return profile.toJSON();

} catch (error) {
  logger.error('Failed to update lecturer profile', {
    userId,
    error: error.message
  });
  throw error;
}
}

async deleteProfile(userId) {
try {
const profile = await LecturerProfile.findOne({
where: { userId }
});
if (!profile) {
logger.warn('Attempted to delete non-existent lecturer profile', {
userId
});
return true;
}
// SUPPRIMER DE LA BDD
await profile.destroy();
logger.info('Lecturer profile deleted', { userId });
// SUPPRIMER DU CACHE
await redisClient.del(`lecturer:${userId}`);
return true;

} catch (error) {
  logger.error('Failed to delete lecturer profile', {
    userId,
    error: error.message
  });
  throw error;
}
}

async addResearchInterest(userId, interest) {
try {
const profile = await LecturerProfile.findOne({
where: { userId }
});
if (!profile) {
throw new NotFoundError('Lecturer profile not found');
}
await profile.addResearchInterest(interest);
logger.info('Research interest added', { userId, interest });
// Invalider le cache
await redisClient.del(`lecturer:${userId}`);
return profile.toJSON();

} catch (error) {
  logger.error('Failed to add research interest', {
    userId,
    error: error.message
  });
  throw error;
}
}
async removeResearchInterest(userId, interest) {
    try {
      const profile = await LecturerProfile.findOne({ where: { userId } });
      
      if (!profile) {
        throw new NotFoundError('Lecturer profile not found');
      }

      await profile.removeResearchInterest(interest);
      
      logger.info('Research interest removed', { userId, interest });
      
      // Invalider le cache
      await redisClient.del(`lecturer:${userId}`);
      
      return profile.toJSON();
    } catch (error) {
      logger.error('Failed to remove research interest', {
        userId,
        error: error.message
      });
      throw error;
    }
  }
  async addPublication(userId, publication) {
    try {
      const profile = await LecturerProfile.findOne({ where: { userId } });
      
      if (!profile) {
        throw new NotFoundError('Lecturer profile not found');
      }

      await profile.addPublication(publication);
      
      logger.info('Publication added', { userId });
      
      // Invalider le cache
      await redisClient.del(`lecturer:${userId}`);
      
      return profile.toJSON();
    } catch (error) {
      logger.error('Failed to add publication', {
        userId,
        error: error.message
      });
      throw error;
    }
  }
  async searchLecturers(filters = {}, pagination = {}) {
    try {
      const {
        department,
        specialization,
        academicRank,
        acceptingStudents,
        employmentStatus,
        researchInterest
      } = filters;

      const {
        page = 1,
        limit = 20
      } = pagination;

      const offset = (page - 1) * limit;

      // Construire les conditions WHERE
      const whereClause = {};

      if (department) {
        whereClause.department = department;
      }

      if (specialization) {
        whereClause.specialization = specialization;
      }

      if (academicRank) {
        whereClause.academicRank = academicRank;
      }

      if (acceptingStudents !== undefined) {
        whereClause.acceptingStudents = acceptingStudents;
      }

      if (employmentStatus) {
        whereClause.employmentStatus = employmentStatus;
      }

      // Profils publics seulement pour la recherche
      whereClause.profileVisibility = 'public';

      // RECHERCHER
      const { rows: profiles, count: total } = await LecturerProfile.findAndCountAll({
        where: whereClause,
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [['created_at', 'DESC']]
      });

      logger.info('Lecturers searched', {
        filters,
        resultCount: profiles.length
      });

      return {
        profiles: profiles.map(p => p.toJSON()),
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          totalPages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      logger.error('Failed to search lecturers', {
        error: error.message
      });
      throw error;
    }
  }
  async getFullProfile(userId) {
    try {
      // 1. RÉCUPÉRER LE PROFIL ENSEIGNANT
      const profile = await this.getProfileByUserId(userId);

      // 2. RÉCUPÉRER LES INFORMATIONS UTILISATEUR DEPUIS AUTH SERVICE
      const userInfo = await this.getUserInfo(userId);

      // 3. COMBINER LES DONNÉES
      return {
        ...profile,
        user: userInfo
      };
    } catch (error) {
      logger.error('Failed to get full lecturer profile', {
        userId,
        error: error.message
      });
      throw error;
    }
  }
  async getUserInfo(userId) {
    try {
      const response = await axios.get(
        `${process.env.AUTH_SERVICE_URL}/api/users/${userId}`,
        {
          headers: {
            'Authorization': `Bearer ${process.env.SERVICE_AUTH_TOKEN}`
          },
          timeout: 5000
        }
      );

      return response.data.data;
    } catch (error) {
      if (error.response?.status === 404) {
        throw new NotFoundError('User not found in Auth Service');
      }

      logger.error('Failed to fetch user info from Auth Service', {
        userId,
        error: error.message
      });

      throw new Error('Failed to fetch user information');
    }
  }
async getStatistics() {
    try {
      const [
        total,
        byDepartment,
        byRank,
        acceptingStudents
      ] = await Promise.all([
        LecturerProfile.count(),
        LecturerProfile.count({
          attributes: ['department'],
          group: ['department']
        }),
        LecturerProfile.count({
          attributes: ['academic_rank'],
          group: ['academic_rank']
        }),
        LecturerProfile.count({
          where: { acceptingStudents: true }
        })
      ]);

      return {
        total,
        byDepartment,
        byRank,
        acceptingStudents
      };
    } catch (error) {
      logger.error('Failed to get lecturer statistics', {
        error: error.message
      });
      throw error;
    }
  }
  async updateAcceptingStudents(userId, accepting) {
    try {
      const profile = await LecturerProfile.findOne({ where: { userId } });
      
      if (!profile) {
        throw new NotFoundError('Lecturer profile not found');
      }

      await profile.update({ acceptingStudents: accepting });
      
      logger.info('Accepting students status updated', { userId, accepting });
      
      // Invalider le cache
      await redisClient.del(`lecturer:${userId}`);
      
      return profile.toJSON();
    } catch (error) {
      logger.error('Failed to update accepting students status', {
        userId,
        error: error.message
      });
      throw error;
    }
  }
}

module.exports = new LecturerService();
