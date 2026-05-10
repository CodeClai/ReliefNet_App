const bcrypt = require('bcrypt');
const db = require('../config/db');

async function seed() {
  const client = await db.connect();
  try {
    await client.query('BEGIN');
    console.log('Seeding database...');

    // 1. Create Admin User
    const adminHash = await bcrypt.hash('Admin@123', 10);
    const admin = await client.query(`
      INSERT INTO users (email, password, role, name, phone, status)
      VALUES ($1, $2, 'admin', 'System Admin', '+923001234567', 'active')
      ON CONFLICT (email) DO UPDATE SET password = $2
      RETURNING id, email
    `, ['admin@disasteraid.pk', adminHash]);
    console.log(`✓ Admin: ${admin.rows[0].email} / Admin@123`);

    // 2. Create Approved NGO
    const ngoHash = await bcrypt.hash('Ngo@123', 10);
    const ngoUser = await client.query(`
      INSERT INTO users (email, password, role, name, phone, status)
      VALUES ($1, $2, 'ngo', 'Test NGO User', '+923001111111', 'active')
      ON CONFLICT (email) DO UPDATE SET password = $2
      RETURNING id
    `, ['ngo@test.pk', ngoHash]);

    const ngoProfile = await client.query(`
      INSERT INTO ngo_profiles (user_id, org_name, registration_number, contact_person, address, city, province, status)
      VALUES ($1, 'Edhi Foundation Test', 'REG-EDHI-001', 'Abdul Sattar', 'Tower, Karachi', 'Karachi', 'Sindh', 'APPROVED')
      ON CONFLICT (user_id) DO UPDATE SET status = 'APPROVED'
      RETURNING id
    `, [ngoUser.rows[0].id]);
    console.log(`✓ NGO: ngo@test.pk / Ngo@123 - APPROVED`);

    // 3. Create NGO Wallet
    await client.query(`
      INSERT INTO ngo_wallets (ngo_id, balance, total_received, total_withdrawn)
      VALUES ($1, 0, 0, 0)
      ON CONFLICT (ngo_id) DO NOTHING
    `, [ngoProfile.rows[0].id]);

    // 4. Create Volunteer
    const volHash = await bcrypt.hash('Volunteer@123', 10);
    const volUser = await client.query(`
      INSERT INTO users (email, password, role, name, phone, status)
      VALUES ($1, $2, 'volunteer', 'Test Volunteer', '+923002222222', 'active')
      ON CONFLICT (email) DO UPDATE SET password = $2
      RETURNING id
    `, ['volunteer@test.pk', volHash]);

    await client.query(`
      INSERT INTO volunteer_profiles (user_id, ngo_id, status, skills)
      VALUES ($1, $2, 'APPROVED', ARRAY['logistics', 'distribution'])
      ON CONFLICT (user_id) DO UPDATE SET status = 'APPROVED', ngo_id = $2
    `, [volUser.rows[0].id, ngoProfile.rows[0].id]);
    console.log(`✓ Volunteer: volunteer@test.pk / Volunteer@123 - APPROVED`);

    // 5. Create Beneficiary
    const benHash = await bcrypt.hash('Beneficiary@123', 10);
    const benUser = await client.query(`
      INSERT INTO users (email, password, role, name, phone, status)
      VALUES ($1, $2, 'beneficiary', 'Test Beneficiary', '+923003333333', 'active')
      ON CONFLICT (email) DO UPDATE SET password = $2
      RETURNING id
    `, ['beneficiary@test.pk', benHash]);
    console.log(`✓ Beneficiary: beneficiary@test.pk / Beneficiary@123`);

    // 6. Create Test Campaign
    const campaign = await client.query(`
      INSERT INTO campaigns (ngo_id, title, description, category, target_amount, location, status, end_date)
      VALUES ($1, 'Flood Relief Karachi 2026', 'Emergency food and shelter for flood victims', 'emergency', 500000, 'Karachi, Sindh', 'ACTIVE', NOW() + INTERVAL '30 days')
      ON CONFLICT DO NOTHING
      RETURNING id, title
    `, [ngoProfile.rows[0].id]);
    if (campaign.rows[0]) console.log(`✓ Campaign: ${campaign.rows[0].title}`);

    await client.query('COMMIT');
    console.log('\n✅ Seed complete! You can now login with test accounts.');

  } catch (e) {
    await client.query('ROLLBACK');
    console.error('Seed failed:', e);
    process.exit(1);
  } finally {
    client.release();
    process.exit(0);
  }
}

seed();