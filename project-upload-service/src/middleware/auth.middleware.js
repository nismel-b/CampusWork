const axios = require('axios');
const { authServiceUrl } = require('../config/env');

const verifyToken = async (req, res, next) => {
  try {
    // 1. Récupérer le token du header Authorization
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];

    // 2. Appeler le Service d'Authentification
    // On suppose que ton Auth Service a une route GET /auth/verify ou /auth/me
    // Adapte '/auth/verify' selon ta vraie route
    const response = await axios.get(`${authServiceUrl}/auth/verify`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    // 3. Si succès, on attache l'utilisateur à la requête
    req.user = response.data.user; // Assure-toi que ton Auth Service renvoie { user: { id: ... } }
    
    next();
  } catch (error) {
    console.error('Auth verification failed:', error.message);
    // Gestion fine des erreurs
    if (error.response && error.response.status === 401) {
      return res.status(401).json({ message: 'Invalid or expired token' });
    }
    return res.status(503).json({ message: 'Authentication service unavailable' });
  }
};

module.exports = verifyToken;