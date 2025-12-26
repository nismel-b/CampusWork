/**
 * EVENT HANDLERS - LECTURER SERVICE
 * 
 * Écoute les événements RabbitMQ et réagit en conséquence.
 */

const EventConsumer = require('../../../shared/utils/eventConsumer');
const lecturerService = require('../services/lecturerService');
const redisClient = require('../../../shared/utils/redisClient');
const logger = require('../../../shared/utils/logger');

/**
 * INITIALIZE EVENT CONSUMER
 */
const eventConsumer = new EventConsumer('lecturer-service');

/**
 * START LISTENING TO EVENTS
 */
const startEventConsumer = async () => {
  try {
    await eventConsumer.connect();
    
    await eventConsumer.subscribe(
      [
        'user.created',
        'user.deleted',
        'user.updated'
      ],
      handleEvent
    );
    
    logger.info('✅ Lecturer Service event consumer started');
  } catch (error) {
    logger.error('❌ Failed to start event consumer', {
      error: error.message
    });
  }
};

/**
 * HANDLE EVENT
 * 
 * Point d'entrée pour tous les événements.
 */
const handleEvent = async (event) => {
  const { eventType, data } = event;
  
  logger.info('📨 Event received', { eventType });
  
  try {
    switch (eventType) {
      case 'user.created':
        await handleUserCreated(data);
        break;
      
      case 'user.deleted':
        await handleUserDeleted(data);
        break;
      
      case 'user.updated':
        await handleUserUpdated(data);
        break;
      
      default:
        logger.warn('Unknown event type', { eventType });
    }
  } catch (error) {
    logger.error('Failed to handle event', {
      eventType,
      error: error.message
    });
  }
};

/**
 * HANDLE USER CREATED
 * 
 * Quand un utilisateur est créé avec le rôle 'lecturer',
 * crée automatiquement un profil d'enseignant.
 */
const handleUserCreated = async (data) => {
  const { userId, role } = data;
  
  // Ne créer un profil que pour les enseignants
  if (role !== 'lecturer') {
    return;
  }
  
  try {
    await lecturerService.createProfile(userId, {
      employmentStatus: 'full_time',
      acceptingStudents: true,
      profileVisibility: 'public'
    });
    
    logger.info('✅ Lecturer profile created', { userId });
  } catch (error) {
    if (error.message.includes('already exists')) {
      logger.info('Lecturer profile already exists', { userId });
    } else {
      throw error;
    }
  }
};

/**
 * HANDLE USER DELETED
 * 
 * Quand un utilisateur est supprimé, supprime son profil d'enseignant.
 */
const handleUserDeleted = async (data) => {
  const { userId } = data;
  
  try {
    await lecturerService.deleteProfile(userId);
    logger.info('✅ Lecturer profile deleted', { userId });
  } catch (error) {
    logger.error('Failed to delete lecturer profile', {
      userId,
      error: error.message
    });
  }
};

/**
 * HANDLE USER UPDATED
 * 
 * Quand les informations de base d'un utilisateur sont mises à jour,
 * invalide le cache pour forcer un rafraîchissement.
 */
const handleUserUpdated = async (data) => {
  const { userId } = data;
  
  try {
    // Invalider le cache
    await redisClient.del(`lecturer:${userId}`);
    logger.info('✅ Lecturer cache invalidated', { userId });
  } catch (error) {
    logger.error('Failed to invalidate lecturer cache', {
      userId,
      error: error.message
    });
  }
};

module.exports = {
  startEventConsumer,
  eventConsumer
};
