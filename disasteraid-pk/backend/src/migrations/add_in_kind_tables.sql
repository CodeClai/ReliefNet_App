-- Migration: Add In-Kind Donation Tables
-- Run this if you already have the base schema and need to add in-kind feature

CREATE TABLE public.in_kind_donations (
  id SERIAL PRIMARY KEY,
  donor_id INTEGER NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  location VARCHAR(255) NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  expires_at TIMESTAMP,
  status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'claimed', 'expired')),
  claimed_by INTEGER REFERENCES public.users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE public.in_kind_donations OWNER TO postgres;

CREATE TABLE public.in_kind_requests (
  id SERIAL PRIMARY KEY,
  donation_id INTEGER NOT NULL REFERENCES public.in_kind_donations(id) ON DELETE CASCADE,
  beneficiary_id INTEGER NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  message TEXT,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(donation_id, beneficiary_id)
);

ALTER TABLE public.in_kind_requests OWNER TO postgres;