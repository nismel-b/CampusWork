const app = require('./app');
const connectDB = require('./config/db');
const { port } = require('./config/env');

// Démarrage
const startServer = async () => {
  await connectDB();
  
  app.listen(port, () => {
    console.log(`🚀 Upload Service running on port ${port}`);
  });
};

startServer();