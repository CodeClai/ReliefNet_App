
### **3. Architecture Doc - `docs/ARCHITECTURE.md`**

```markdown
## System Architecture

**Stack:** Flutter + Express.js + PostgreSQL + Supabase

**Flow:**
Flutter App → Express API → Supabase PostgreSQL
         ↓ JWT
    Auth Middleware

**Core Modules:**
1. **Auth**: JWT, bcrypt, roles: donor, ngo, admin
2. **Campaigns**: CRUD, image_url, status: DRAFT/ACTIVE/COMPLETED
3. **Donations**: Atomic transaction: donation → campaign.raised_amount → ngo_wallet.balance → wallet_transactions
4. **Admin**: Stats, NGO approval, withdrawals

**Key DB Relations:**
users 1--1 ngo_profiles
ngo_profiles 1--n campaigns  
campaigns 1--n donations
ngo_profiles 1--1 ngo_wallets
ngo_wallets 1--n wallet_transactions