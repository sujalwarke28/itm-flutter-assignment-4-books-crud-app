const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '.env') });

const bookRoutes = require('./src/routes/bookRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Routes
app.use('/api/books', bookRoutes);

// Root health route
app.get('/', (req, res) => {
  res.json({
    message: 'Books CRUD API is running',
    baseEndpoint: '/api/books',
  });
});

// 404 Route Handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Centralized Error Handling Middleware
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  const statusCode = err.status || 500;
  res.status(statusCode).json({
    error: err.message || 'Internal Server Error',
  });
});

// Start server if run directly
if (require.main === module) {
  const server = app.listen(PORT, () => {
    console.log(`Books CRUD Server running on http://localhost:${PORT}`);
    console.log(`API endpoint available at http://localhost:${PORT}/api/books`);
  });

  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.error(`\n[PORT CONFLICT] Port ${PORT} is already in use.`);
      console.error(`On macOS, this is typically Apple AirPlay Receiver.`);
      console.error(`To free port 5000: Open System Settings -> General -> AirDrop & Handoff -> turn off 'AirPlay Receiver'.`);
    } else {
      console.error('Server error:', err);
    }
  });
}

module.exports = app;

