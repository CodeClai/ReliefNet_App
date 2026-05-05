const express = require('express');
const router = express.Router();
const db = require('../../config/db');
const auth = require('../../middleware/auth');

// POST /api/campaigns - NGO creates campaign
router.post('/', auth('ngo'), async (req, res) => {
  const { title, description, category, target_amount, image_url, location, end_date } = req.body;
  try {
    // Get NGO profile id from user id
    const ngo = await db.query('SELECT id, status FROM ngo_profiles WHERE user_id = $1', [req.user.id]);
    if (!ngo.rows[0]) return res.status(400).json({ error: 'Create NGO profile first' });
    if (ngo.rows[0].status!== 'APPROVED') return res.status(403).json({ error: 'NGO not approved yet' });

    const result = await db.query(
      `INSERT INTO campaigns (ngo_id, title, description, category, target_amount, image_url, location, end_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [ngo.rows[0].id, title, description, category, target_amount, image_url, location, end_date]
    );
    res.json({ data: result.rows[0] });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET /api/campaigns - Public list
router.get('/', async (req, res) => {
  const { status = 'ACTIVE', category } = req.query;
  let query = 'SELECT c.*, n.org_name FROM campaigns c JOIN ngo_profiles n ON c.ngo_id = n.id WHERE 1=1';
  const params = [];
  if (status) { params.push(status); query += ` AND c.status = $${params.length}`; }
  if (category) { params.push(category); query += ` AND c.category = $${params.length}`; }
  query += ' ORDER BY c.created_at DESC';
  const result = await db.query(query, params);
  res.json({ data: result.rows });
});

// GET /api/campaigns/my - NGO's own campaigns
router.get('/my', auth('ngo'), async (req, res) => {
  const ngo = await db.query('SELECT id FROM ngo_profiles WHERE user_id = $1', [req.user.id]);
  if (!ngo.rows[0]) return res.json({ data: [] });
  const result = await db.query('SELECT * FROM campaigns WHERE ngo_id = $1 ORDER BY created_at DESC', [ngo.rows[0].id]);
  res.json({ data: result.rows });
});

// GET /api/campaigns/:id - Single campaign
router.get('/:id', async (req, res) => {
  const result = await db.query(
    'SELECT c.*, n.org_name, n.contact_person FROM campaigns c JOIN ngo_profiles n ON c.ngo_id = n.id WHERE c.id = $1',
    [req.params.id]
  );
  if (!result.rows[0]) return res.status(404).json({ error: 'Not found' });
  res.json({ data: result.rows[0] });
});

// PUT /api/campaigns/:id - NGO edits own campaign
router.put('/:id', auth('ngo'), async (req, res) => {
  const { title, description, category, target_amount, image_url, location, end_date } = req.body;
  const ngo = await db.query('SELECT id FROM ngo_profiles WHERE user_id = $1', [req.user.id]);
  const result = await db.query(
    `UPDATE campaigns SET title=$1, description=$2, category=$3, target_amount=$4, image_url=$5, location=$6, end_date=$7
     WHERE id=$8 AND ngo_id=$9 RETURNING *`,
    [title, description, category, target_amount, image_url, location, end_date, req.params.id, ngo.rows[0].id]
  );
  if (!result.rows[0]) return res.status(403).json({ error: 'Not allowed' });
  res.json({ data: result.rows[0] });
});

module.exports = router;
