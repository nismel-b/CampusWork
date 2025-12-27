const express = require('express');
const cors = require('cors');
const path = require('path');
const projectRoutes = require('./routes/project.routes');

const app = express();

// Middleware de base
app.use(cors()); // Accepte tout pour le MVP
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir les fichiers statiques (pour que les URLs fonctionnent)
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Routes API
app.use('/api/projects', projectRoutes);

// Route Health Check (pour Docker/Uptime)
app.get('/health', (req, res) => res.status(200).json({ status: 'OK' }));

module.exports = app;