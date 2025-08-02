const express = require('express');
const app = express();
const port = 3000;

// Simple API endpoint
app.get('/api/status', (req, res) => {
    res.json({ message: 'Backend is up and running!' });
});

app.listen(port, () => {
    console.log(`Backend listening at http://localhost:${port}`);
});