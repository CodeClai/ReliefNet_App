--
-- PostgreSQL database dump
--

\restrict DqUC0qEPTLLV1ev6SiWJxpVdNkpkfbzK3abwZIBJGgvQCEJsEcv7QUA5usdDn5E

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aid_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aid_requests (
    id integer NOT NULL,
    beneficiary_id integer,
    campaign_id integer,
    category character varying(50) NOT NULL,
    description text NOT NULL,
    urgency character varying(20) DEFAULT 'MEDIUM'::character varying,
    family_size integer DEFAULT 1,
    location text NOT NULL,
    lat numeric(10,8),
    lng numeric(11,8),
    status character varying(20) DEFAULT 'PENDING'::character varying,
    volunteer_id integer,
    ngo_id integer,
    proof_url text,
    delivered_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.aid_requests OWNER TO postgres;

--
-- Name: aid_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aid_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.aid_requests_id_seq OWNER TO postgres;

--
-- Name: aid_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aid_requests_id_seq OWNED BY public.aid_requests.id;


--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.campaigns (
    id integer NOT NULL,
    ngo_id integer,
    title character varying(255) NOT NULL,
    description text,
    category character varying(50),
    target_amount numeric(12,2) NOT NULL,
    raised_amount numeric(12,2) DEFAULT 0,
    image_url text,
    location character varying(255),
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    end_date timestamp without time zone
);


ALTER TABLE public.campaigns OWNER TO postgres;

--
-- Name: campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.campaigns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.campaigns_id_seq OWNER TO postgres;

--
-- Name: campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.campaigns_id_seq OWNED BY public.campaigns.id;


--
-- Name: donations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.donations (
    id integer NOT NULL,
    user_id integer,
    campaign_id integer,
    amount numeric(10,2) NOT NULL,
    payment_method character varying(50) DEFAULT 'MOCK'::character varying,
    status character varying(20) DEFAULT 'completed'::character varying,
    transaction_ref character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    donor_name character varying(255),
    donor_email character varying(255),
    is_anonymous boolean DEFAULT false
);


ALTER TABLE public.donations OWNER TO postgres;

--
-- Name: donations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.donations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.donations_id_seq OWNER TO postgres;

--
-- Name: donations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.donations_id_seq OWNED BY public.donations.id;


--
-- Name: ngo_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ngo_profiles (
    id integer NOT NULL,
    user_id integer,
    org_name character varying(255),
    registration_number character varying(100),
    address text,
    contact_person character varying(255),
    mission text,
    docs_url text[],
    status character varying(20) DEFAULT 'PENDING'::character varying,
    rejection_reason text,
    created_at timestamp without time zone DEFAULT now(),
    approved_by integer,
    approved_at timestamp without time zone,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.ngo_profiles OWNER TO postgres;

--
-- Name: ngo_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ngo_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ngo_profiles_id_seq OWNER TO postgres;

--
-- Name: ngo_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ngo_profiles_id_seq OWNED BY public.ngo_profiles.id;


--
-- Name: ngo_wallets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ngo_wallets (
    id integer NOT NULL,
    ngo_id integer,
    balance numeric(12,2) DEFAULT 0,
    total_received numeric(12,2) DEFAULT 0,
    total_withdrawn numeric(12,2) DEFAULT 0,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.ngo_wallets OWNER TO postgres;

--
-- Name: ngo_wallets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ngo_wallets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ngo_wallets_id_seq OWNER TO postgres;

--
-- Name: ngo_wallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ngo_wallets_id_seq OWNED BY public.ngo_wallets.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(50)
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255),
    phone character varying(20),
    password_hash character varying(255) NOT NULL,
    role_id integer,
    name character varying(255) NOT NULL,
    locale character varying(5) DEFAULT 'en'::character varying,
    fcm_token text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: volunteer_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.volunteer_profiles (
    id integer NOT NULL,
    user_id integer,
    ngo_id integer,
    location text,
    skills text[],
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.volunteer_profiles OWNER TO postgres;

--
-- Name: volunteer_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.volunteer_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.volunteer_profiles_id_seq OWNER TO postgres;

--
-- Name: volunteer_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.volunteer_profiles_id_seq OWNED BY public.volunteer_profiles.id;


--
-- Name: wallet_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wallet_transactions (
    id integer NOT NULL,
    ngo_id integer,
    amount numeric(10,2) NOT NULL,
    type character varying(20) NOT NULL,
    donation_id integer,
    description text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.wallet_transactions OWNER TO postgres;

--
-- Name: wallet_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wallet_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wallet_transactions_id_seq OWNER TO postgres;

--
-- Name: wallet_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wallet_transactions_id_seq OWNED BY public.wallet_transactions.id;


--
-- Name: withdrawal_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.withdrawal_requests (
    id integer NOT NULL,
    ngo_id integer,
    amount numeric(12,2) NOT NULL,
    bank_name character varying(100) NOT NULL,
    account_title character varying(255) NOT NULL,
    account_number character varying(50) NOT NULL,
    iban character varying(50),
    status character varying(20) DEFAULT 'PENDING'::character varying,
    rejection_reason text,
    approved_by integer,
    transaction_ref character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    processed_at timestamp without time zone
);


ALTER TABLE public.withdrawal_requests OWNER TO postgres;

--
-- Name: withdrawal_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.withdrawal_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.withdrawal_requests_id_seq OWNER TO postgres;

--
-- Name: withdrawal_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.withdrawal_requests_id_seq OWNED BY public.withdrawal_requests.id;


--
-- Name: aid_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aid_requests ALTER COLUMN id SET DEFAULT nextval('public.aid_requests_id_seq'::regclass);


--
-- Name: campaigns id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campaigns ALTER COLUMN id SET DEFAULT nextval('public.campaigns_id_seq'::regclass);


--
-- Name: donations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donations ALTER COLUMN id SET DEFAULT nextval('public.donations_id_seq'::regclass);


--
-- Name: ngo_profiles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ngo_profiles ALTER COLUMN id SET DEFAULT nextval('public.ngo_profiles_id_seq'::regclass);


--
-- Name: ngo_wallets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ngo_wallets ALTER COLUMN id SET DEFAULT nextval('public.ngo_wallets_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: volunteer_profiles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.volunteer_profiles ALTER COLUMN id SET DEFAULT nextval('public.volunteer_profiles_id_seq'::regclass);


--
-- Name: wallet_transactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_transactions ALTER COLUMN id SET DEFAULT nextval('public.wallet_transactions_id_seq'::regclass);


--
-- Name: withdrawal_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.withdrawal_requests ALTER COLUMN id SET DEFAULT nextval('public.withdrawal_requests_id_seq'::regclass);


--
-- Name: aid_requests aid_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT aid_requests_pkey PRIMARY KEY (id);


--
-- Name: campaigns campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: donations donations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_pkey PRIMARY KEY (id);


--
-- Name: ngo_profiles ngo_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ngo_profiles
    ADD CONSTRAINT ngo_profiles_pkey PRIMARY KEY (id);


--
-- Name: ngo_profiles ngo_profiles_registration_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ngo_profiles
    ADD CONSTRAINT ngo_profiles_registration_number_key UNIQUE (registration_number);


--
-- Name: ngo_profiles ngo_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ngo_profiles
    ADD CONSTRAINT ngo_profiles_user_id_key UNIQUE (user_id);


--
-- Name: ngo_wallets ngo_wallets_ngo_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ngo_wallets
    ADD CONSTRAINT ngo_wallets_ngo_id_key UNIQUE (ngo_id);


--
-- Name: ngo_wallets ngo_wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ngo_wallets
    ADD CONSTRAINT ngo_wallets_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: donations unique_transaction_ref; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT unique_transaction_ref UNIQUE (transaction_ref);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: volunteer_profiles volunteer_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.volunteer_profiles
    ADD CONSTRAINT volunteer_profiles_pkey PRIMARY KEY (id);


--
-- Name: volunteer_profiles volunteer_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.volunteer_profiles
    ADD CONSTRAINT volunteer_profiles_user_id_key UNIQUE (user_id);


--
-- Name: wallet_transactions wallet_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_transactions
    ADD CONSTRAINT wallet_transactions_pkey PRIMARY KEY (id);


--
-- Name: withdrawal_requests withdrawal_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.withdrawal_requests
    ADD CONSTRAINT withdrawal_requests_pkey PRIMARY KEY (id);


--
-- Name: idx_aid_requests_beneficiary; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_aid_requests_beneficiary ON public.aid_requests USING btree (beneficiary_id);


--
-- Name: idx_aid_requests_ngo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_aid_requests_ngo ON public.aid_requests USING btree (ngo_id);


--
-- Name: idx_aid_requests_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_aid_requests_status ON public.aid_requests USING btree (status);


--
-- Name: idx_volunteer_profiles_ngo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_volunteer_profiles_ngo ON public.volunteer_profiles USING btree (ngo_id);


--
-- Name: idx_withdrawal_ngo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_withdrawal_ngo ON public.withdrawal_requests USING btree (ngo_id);


--
-- Name: idx_withdrawal_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_withdrawal_status ON public.withdrawal_requests USING btree (status);


--
-- Name: idx_withdrawals_ngo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_withdrawals_ngo ON public.withdrawal_requests USING btree (ngo_id);


--
-- Name: idx_withdrawals_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_withdrawals_status ON public.withdrawal_requests USING btree (status);


--
-- Name: aid_requests aid_requests_beneficiary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT aid_requests_beneficiary_id_fkey FOREIGN KEY (beneficiary_id) REFERENCES public.users(id);


--
-- Name: aid_requests aid_requests_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT aid_requests_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.campaigns(id);


--
-- Name: aid_requests aid_requests_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT aid_requests_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id);


--
-- Name: aid_requests aid_requests_volunteer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT aid_requests_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.volunteer_profiles(id);


--
-- Name: campaigns campaigns_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id) ON DELETE CASCADE;


--
-- Name: donations donations_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.campaigns(id);


--
-- Name: donations donations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ngo_profiles ngo_profiles_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ngo_profiles
    ADD CONSTRAINT ngo_profiles_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: ngo_profiles ngo_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ngo_profiles
    ADD CONSTRAINT ngo_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ngo_wallets ngo_wallets_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ngo_wallets
    ADD CONSTRAINT ngo_wallets_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id);


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: volunteer_profiles volunteer_profiles_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.volunteer_profiles
    ADD CONSTRAINT volunteer_profiles_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id);


--
-- Name: volunteer_profiles volunteer_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.volunteer_profiles
    ADD CONSTRAINT volunteer_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: wallet_transactions wallet_transactions_donation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_transactions
    ADD CONSTRAINT wallet_transactions_donation_id_fkey FOREIGN KEY (donation_id) REFERENCES public.donations(id);


--
-- Name: wallet_transactions wallet_transactions_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_transactions
    ADD CONSTRAINT wallet_transactions_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id);


--
-- Name: withdrawal_requests withdrawal_requests_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.withdrawal_requests
    ADD CONSTRAINT withdrawal_requests_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: withdrawal_requests withdrawal_requests_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.withdrawal_requests
    ADD CONSTRAINT withdrawal_requests_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id);


--
-- PostgreSQL database dump complete
--

\unrestrict DqUC0qEPTLLV1ev6SiWJxpVdNkpkfbzK3abwZIBJGgvQCEJsEcv7QUA5usdDn5E

