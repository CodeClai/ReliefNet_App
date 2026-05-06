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