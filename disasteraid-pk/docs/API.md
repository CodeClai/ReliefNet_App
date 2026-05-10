# ReliefNet API v1

Base URL: `http://localhost:3000/api`

## Authentication
All endpoints except `/auth/*` and `GET /campaigns` require JWT:
`Authorization: Bearer <token>`

## Endpoints

### Auth
#### POST /auth/register
#### POST /auth/login

### Campaigns
#### GET /campaigns
List campaigns with filters: ?status=ACTIVE&category=emergency

#### GET /campaigns/:id
Get single campaign with NGO details + donor_count

### Donations
#### POST /donations
Create donation + update NGO wallet

**Auth:** Required - any logged user

**Body:**
```json
{
  "campaign_id": 1,
  "amount": 500,
  "donor_name": "Arshad",
  "donor_email": "test@test.com",
  "payment_method": "MOCK",
  "transaction_id": "MOCK_1715012345678",
  "is_anonymous": false
}

# API Documentation - Phase 3 Complete

## Base URL
`http://localhost:3000/api`

## Authentication
All protected routes require `Authorization: Bearer <JWT>` header.

## Admin Routes

### GET /admin/stats
Returns platform overview for dashboard.
**Auth:** admin
**Response:** `{data: {users, ngos, campaigns, donations}}`

### GET /admin/ngos
List NGOs with optional status filter.
**Auth:** admin
**Query:** `?status=PENDING|APPROVED|REJECTED`
**Response:** `{data: [ngo_objects]}`

### PATCH /admin/ngos/:id/approve
Approve pending NGO.
**Auth:** admin
**Response:** `{success: true, data: ngo_object}`

### PATCH /admin/ngos/:id/reject
Reject pending NGO with reason.
**Auth:** admin
**Body:** `{reason: string}`
**Response:** `{success: true, data: ngo_object}`

## Donation Routes

### POST /donations
Create donation to campaign.
**Auth:** donor
**Body:** `{campaign_id, amount, payment_method}`
**Validation:** amount >= 100, campaign.status = ACTIVE
**Side Effect:** Credits ngo_wallets.balance

## Business Rules Tested
1. Minimum donation: 100 PKR
2. Campaign must be ACTIVE to receive donations
3. Donations atomically update campaign.raised_amount + ngo_wallets.balance