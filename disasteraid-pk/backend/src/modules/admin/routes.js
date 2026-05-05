const router = require('express').Router();
const auth = require('../../middleware/auth');
const db = require('../../config/db');

const adminOnly = async (req, res, next) => {
  if (req.user.role!== 'admin') return res.status(403).json({ error: 'Admin only' });
  next();
};

router.get('/ngos/pending', auth, adminOnly, async (req, res, next) => {
  try {
    const result = await db.query(
      `SELECT np.*, u.name as user_name, u.email, u.phone
       FROM ngo_profiles np JOIN users u ON np.user_id=u.id
       WHERE np.status='PENDING' ORDER BY np.created_at DESC`
    );
    res.json({ data: result.rows });
  } catch (e) { next(e); }
});

router.post('/ngos/:id/approve', auth('admin'), async (req, res) => {
  const ngo = await db.query('SELECT user_id FROM ngo_profiles WHERE id=$1', [req.params.id]);
  if (ngo.rows[0].user_id === req.user.id) return res.status(403).json({ error: 'Cannot approve yourself' });
  await db.query('UPDATE ngo_profiles SET status=$1, approved_by=$2, approved_at=NOW() WHERE id=$3', ['APPROVED', req.user.id, req.params.id]);
  res.json({ success: true });
});



router.post('/ngos/:id/reject', auth, adminOnly, async (req, res, next) => {
  try {
    const { reason } = req.body;
    await db.query('UPDATE ngo_profiles SET status=$1, rejection_reason=$2 WHERE id=$3', ['REJECTED', reason, req.params.id]);
    res.json({ message: 'NGO rejected' });
  } catch (e) { next(e); }
});

module.exports = router;
