require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const app = express();

app.use(cors({ origin: process.env.FRONTEND_URL, credentials: true }));
app.use(express.json());
app.use('/api/', rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));

app.use('/api/auth', require('./modules/auth/routes'));
app.use('/api/ngos', require('./modules/ngos/routes'));
app.use('/api/admin', require('./modules/admin/routes'));
app.use('/api/campaigns', require('./modules/campaigns/routes'));

app.get('/api/health', (req, res) => res.json({ status: 'ok' }));
app.use(require('./middleware/error'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => console.log(`API running on http://localhost:${PORT}`));
