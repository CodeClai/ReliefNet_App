const router = require('express').Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const Joi = require('joi');
const db = require('../../config/db');

const registerSchema = Joi.object({
  email: Joi.string().email().allow(null, ''),
  phone: Joi.string().pattern(/^[0-9]{11}$/).allow(null, ''),
  password: Joi.string().min(6).required(),
  role: Joi.string().valid('donor', 'ngo', 'volunteer', 'beneficiary').required(),
  name: Joi.string().min(2).required()
}).or('email', 'phone');

router.post('/register', async (req, res, next) => {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) return res.status(400).json({ error: error.details[0].message });

    const { email, phone, password, role, name } = value;
    const hash = await bcrypt.hash(password, 10);

    await db.query(`CREATE TABLE IF NOT EXISTS roles (id SERIAL PRIMARY KEY, name VARCHAR(50) UNIQUE)`);
    await db.query(`INSERT INTO roles (name) VALUES ('donor'), ('ngo'), ('volunteer'), ('beneficiary'), ('admin') ON CONFLICT DO NOTHING`);

    await db.query(`CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY, email VARCHAR(255) UNIQUE, phone VARCHAR(20) UNIQUE,
      password_hash VARCHAR(255) NOT NULL, role_id INT REFERENCES roles(id),
      name VARCHAR(255) NOT NULL, locale VARCHAR(5) DEFAULT 'en',
      fcm_token TEXT, created_at TIMESTAMP DEFAULT NOW()
    )`);

    const roleRes = await db.query('SELECT id FROM roles WHERE name=$1', [role]);
    const user = await db.query(
      'INSERT INTO users (email, phone, password_hash, role_id, name) VALUES ($1,$2,$3,$4,$5) RETURNING id,name,email,phone,role_id',
      [email || null, phone || null, hash, roleRes.rows[0].id, name]
    );

    const token = jwt.sign({ id: user.rows[0].id, role }, process.env.JWT_SECRET, { expiresIn: '24h' });
    res.status(201).json({ data: { token, user: {...user.rows[0], role } } });
  } catch (e) {
    if (e.code === '23505') return res.status(409).json({ error: 'Email or phone already exists' });
    next(e);
  }
});

router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const user = await db.query(
      'SELECT u.*, r.name as role FROM users u JOIN roles r ON u.role_id=r.id WHERE u.email=$1 OR u.phone=$1',
      [email]
    );

    if (!user.rows[0] ||!await bcrypt.compare(password, user.rows[0].password_hash)) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: user.rows[0].id, role: user.rows[0].role }, process.env.JWT_SECRET, { expiresIn: '24h' });
    const { password_hash,...userData } = user.rows[0];
    res.json({ data: { token, user: userData } });
  } catch (e) { next(e); }
});

module.exports = router;
