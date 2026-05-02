#!/usr/bin/env node
const express = require('express');
const path = require('path');
const app = express();
const PORT = 3000;

// Serve static files from the dashboard directory
app.use(express.static(path.join(__dirname)));

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'openclaw-dashboard', port: PORT });
});

app.listen(PORT, '127.0.0.1', () => {
    console.log(`📊 OpenClaw Dashboard running at http://127.0.0.1:${PORT}`);
    console.log(`📁 Serving files from: ${__dirname}`);
});
