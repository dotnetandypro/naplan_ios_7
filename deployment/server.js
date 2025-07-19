const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 8080;

// Basic error handling for server startup
const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

server.on('error', (err) => {
  console.error('Server error:', err);
});

// Simple CORS handling without requiring the cors package
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

// Serve static files from the /public directory
const publicPath = path.join(__dirname, 'public');
app.use(express.static(publicPath));

// Route all other paths to index.html for SPA routing
app.get('*', (req, res) => {
  res.sendFile(path.join(publicPath, 'index.html'));
});
