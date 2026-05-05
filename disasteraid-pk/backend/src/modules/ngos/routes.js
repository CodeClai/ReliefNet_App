const router = require('express').Router();
const auth = require('../../middleware/auth');
const db = require('../../config/db');
const upload = require('../../utils/upload');
const Joi = require('joi');

const onboardSchema = Joi.object({
  org_name: Joi.string().min(3).required(),
  registration_number: Joi.string().min(5).required(),
  address: Joi.string().min(10).required(),
  contact_person: Joi.string().min(2).required(),
  mission: Joi.string().min(20).required(),
});

router.post('/onboard', auth('ngo'), upload.array('docs'), async (req, res) => {
  const existing = await db.query('SELECT status FROM ngo_profiles WHERE user_id=$1', [req.user.id]);
  if (existing.rows[0]?.status === 'PENDING') return res.status(400).json({ error: 'Already submitted' });
  if (existing.rows[0]?.status === 'APPROVED') return res.status(400).json({ error: 'Already verified' });

  const urls = req.files.map(f => f.path);
  const { org_name, registration_number, address, contact_person, mission } = req.body;
  await db.query(
    `INSERT INTO ngo_profiles(user_id, org_name, registration_number, address, contact_person, mission, docs_url)
     VALUES($1,$2,$3,$4,$5,$6,$7)
     ON CONFLICT (user_id) DO UPDATE SET
     org_name=$2, registration_number=$3, address=$4, contact_person=$5, mission=$6, docs_url=$7, status='PENDING', updated_at=NOW()`,
    [req.user.id, org_name, registration_number, address, contact_person, mission, urls]
  );
  res.json({ success: true });
});

router.get('/profile', auth, async (req, res, next) => {
  try {
    const result = await db.query('SELECT * FROM ngo_profiles WHERE user_id=$1', [req.user.id]);
    res.json({ data: result.rows[0] || null });
  } catch (e) { next(e); }
});


router.get('/me', auth('ngo'), async (req, res) => {
  const result = await db.query('SELECT * FROM ngo_profiles WHERE user_id=$1', [req.user.id]);
  res.json({ data: result.rows[0] || null });
});
module.exports = router;
