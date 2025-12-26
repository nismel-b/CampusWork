/*const EventConsumer = require('../../../shared/utils/eventConsumer');
const studentService = require('../services/studentService');
const logger = require('../../../shared/utils/logger');
const eventConsumer = new EventConsumer('student-service');
const startEventConsumer = async () => {
try {
// Connect to RabbitMQ
await eventConsumer.connect();
// Subscribe to events using routing keys
await eventConsumer.subscribe(
[
'user.created',   // When new user registers
'user.deleted',   // When user account deleted
'user.updated'    // When user updates basic info
],
handleEvent  // Event handler function
);
logger.info('✅ Student Service event consumer started', {
subscribedEvents: ['user.created', 'user.deleted', 'user.updated']
});

} catch (error) {
logger.error('❌ Failed to start event consumer', {
error: error.message
});
}
};
const handleEvent = async (event) => {
const { eventType, data } = event;

logger.info('📨 Event received', {
eventType,
dataKeys: Object.keys(data)
});
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
// Don't throw - we don't want to nack the message
// Log error and move on
}
};
const handleUserCreated = async (data) => {
const { userId, role } = data;

// Only create profile for students
if (role !== 'student') {
logger.debug('User created but not a student, skipping profile creation', {
userId,
role
});
return;
}
try {
// Create empty profile (student can fill it in later)
await studentService.createProfile(userId, {
enrollmentStatus: 'active',
profileVisibility: 'public'
});
logger.info('✅ Student profile created automatically', { userId });
} catch (error) {
// If profile already exists, that's okay (idempotent)
if (error.message.includes('already exists')) {
logger.info('Student profile already exists', { userId });
} else {
throw error;
}
}
};
const handleUserDeleted = async (data) => {
const { userId } = data;

try {
await studentService.deleteProfile(userId);
logger.info('✅ Student profile deleted', { userId });
} catch (error) {
logger.error('Failed to delete student profile', {
userId,
error: error.message
});
}
};
const handleUserUpdated = async (data) => {
const { userId } = data;

try {
const redisClient = require('../../../shared/utils/redisClient');
// Invalidate cache
await redisClient.del(`student:${userId}`);

logger.info('✅ Student cache invalidated', { userId });
} catch (error) {
logger.error('Failed to invalidate student cache', {
userId,
error*/

const EventConsumer = require('../../../shared/utils/eventConsumer');
const studentService = require('../services/studentService');
const redisClient = require('../../../shared/utils/redisClient');
const logger = require('../../../shared/utils/logger');
const eventConsumer = new EventConsumer('student-service');
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
logger.info('✅ Student Service event consumer started');
} catch (error) {
logger.error('❌ Failed to start event consumer', { error: error.message });
}
};
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
const handleUserCreated = async (data) => {
const { userId, role } = data;

// Only create profile for students
if (role !== 'student') {
return;
}
try {
await studentService.createProfile(userId, {
enrollmentStatus: 'active',
profileVisibility: 'public'
});
logger.info('✅ Student profile created', { userId });
} catch (error) {
if (error.message.includes('already exists')) {
logger.info('Student profile already exists', { userId });
} else {
throw error;
}
}
};
const handleUserDeleted = async (data) => {
const { userId } = data;

try {
await studentService.deleteProfile(userId);
logger.info('✅ Student profile deleted', { userId });
} catch (error) {
logger.error('Failed to delete student profile', {
userId,
error: error.message
});
}
};
const handleUserUpdated = async (data) => {
const { userId } = data;

try {
// Invalidate cache when user updates basic info
await redisClient.del('student:${userId}');
logger.info('✅ Student cache invalidated', { userId });
} catch (error) {
logger.error('Failed to invalidate student cache', {
userId,
error: error.message
});
}
};
module.exports = {
startEventConsumer,
eventConsumer
};


