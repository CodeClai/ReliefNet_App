const db = require('../config/db');
const schema = `
CREATE TABLE IF NOT EXISTS campaigns (
  id SERIAL PRIMARY KEY,
  ngo_id INT REFERENCES ngo_profiles(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(50),
  target_amount NUMERIC(12,2) NOT NULL,
  raised_amount NUMERIC(12,2) DEFAULT 0,
  image_url TEXT,
  location VARCHAR(255),
  status VARCHAR(20) DEFAULT 'ACTIVE',
  created_at TIMESTAMP DEFAULT NOW(),
  end_date TIMESTAMP
);
`;
db.query(schema).then(() => { console.log('Campaign table created'); process.exit(0); }).catch(e => { console.error(e); process.exit(1); });
