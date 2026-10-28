require('dotenv').config();
const express = require('express');
const cors = require('cors');

const mealsRoutes = require('./routes/meals.routes');
const recipesRoutes = require('./routes/recipes.routes');
const aiRoutes = require('./routes/ai.routes');
const authRoutes = require('./routes/auth.routes');

const app = express();
const PORT = process.env.PORT || 5000;

// Middlewares
app.use(cors());
app.use(express.json());

// Request logger for development
app.use((req, res, next) => {
  console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    app: 'PROM KIN REST API Server',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Routes
app.use('/api/meals', mealsRoutes);
app.use('/api/recipes', recipesRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/auth', authRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route not found: ${req.originalUrl}` });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Server Error:', err);
  res.status(500).json({ success: false, message: 'Internal Server Error', error: err.message });
});

// Start Server
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`===============================================`);
    console.log(`🌿 PROM KIN REST API Server is running on:`);
    console.log(`   Local:            http://localhost:${PORT}`);
    console.log(`   Android Emulator: http://10.0.2.2:${PORT}`);
    console.log(`===============================================`);
  });
}

module.exports = app;

