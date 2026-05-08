const db = require('../config/db');

async function logAction({ adminId, action, targetType, targetId, oldValue, newValue, reason, req }) {
  try {
    const ip = req?.headers['x-forwarded-for'] || req?.socket?.remoteAddress || null;
    await db.query(
      `INSERT INTO audit_logs (admin_id, action, target_type, target_id, old_value, new_value, reason, ip_address)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [adminId, action, targetType, targetId, oldValue? JSON.stringify(oldValue) : null, newValue? JSON.stringify(newValue) : null, reason, ip]
    );
  } catch (e) {
    console.error('Audit log failed:', e); // Don't crash main request
  }
}

module.exports = { logAction };