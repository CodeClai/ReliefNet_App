--
-- PostgreSQL database dump
--

\restrict J1Afg4INy5E2staXAOk7prL38iA8icg5zhNel7IKO4krDll9nRWuEoWMrKSlTIl

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
-- Name: aid_requests; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: aid_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aid_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aid_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.aid_requests_id_seq OWNED BY public.aid_requests.id;


--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.campaigns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.campaigns_id_seq OWNED BY public.campaigns.id;


--
-- Name: donations; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: donations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.donations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: donations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.donations_id_seq OWNED BY public.donations.id;


--
-- Name: ngo_profiles; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: ngo_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ngo_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ngo_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ngo_profiles_id_seq OWNED BY public.ngo_profiles.id;


--
-- Name: ngo_wallets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ngo_wallets (
    id integer NOT NULL,
    ngo_id integer,
    balance numeric(12,2) DEFAULT 0,
    total_received numeric(12,2) DEFAULT 0,
    total_withdrawn numeric(12,2) DEFAULT 0,
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: ngo_wallets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ngo_wallets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ngo_wallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ngo_wallets_id_seq OWNED BY public.ngo_wallets.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(50)
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: volunteer_profiles; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: volunteer_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.volunteer_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: volunteer_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.volunteer_profiles_id_seq OWNED BY public.volunteer_profiles.id;


--
-- Name: wallet_transactions; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: wallet_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wallet_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wallet_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wallet_transactions_id_seq OWNED BY public.wallet_transactions.id;


--
-- Name: withdrawal_requests; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: withdrawal_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.withdrawal_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: withdrawal_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.withdrawal_requests_id_seq OWNED BY public.withdrawal_requests.id;


--
-- Name: aid_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aid_requests ALTER COLUMN id SET DEFAULT nextval('public.aid_requests_id_seq'::regclass);


--
-- Name: campaigns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaigns ALTER COLUMN id SET DEFAULT nextval('public.campaigns_id_seq'::regclass);


--
-- Name: donations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donations ALTER COLUMN id SET DEFAULT nextval('public.donations_id_seq'::regclass);


--
-- Name: ngo_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngo_profiles ALTER COLUMN id SET DEFAULT nextval('public.ngo_profiles_id_seq'::regclass);


--
-- Name: ngo_wallets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngo_wallets ALTER COLUMN id SET DEFAULT nextval('public.ngo_wallets_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: volunteer_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_profiles ALTER COLUMN id SET DEFAULT nextval('public.volunteer_profiles_id_seq'::regclass);


--
-- Name: wallet_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet_transactions ALTER COLUMN id SET DEFAULT nextval('public.wallet_transactions_id_seq'::regclass);


--
-- Name: withdrawal_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal_requests ALTER COLUMN id SET DEFAULT nextval('public.withdrawal_requests_id_seq'::regclass);


--
-- Data for Name: aid_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.aid_requests (id, beneficiary_id, campaign_id, category, description, urgency, family_size, location, lat, lng, status, volunteer_id, ngo_id, proof_url, delivered_at, created_at) FROM stdin;
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.campaigns (id, ngo_id, title, description, category, target_amount, raised_amount, image_url, location, status, created_at, end_date) FROM stdin;
1	1	give me 	this is a chanda system	education	121323.00	6500.00	\N	uoh	ACTIVE	2026-05-06 02:00:22.582857	\N
2	1	MY CAMPAING	THIS IS THE CAMP OF THE LOAKFAJFL KAKLAKLAJJKLFJKLAJFKLWRJKLWQJ	FOOD	147844545.00	0.00	\N	gurjat	ACTIVE	2026-05-07 00:53:34.314565	2026-06-30 00:00:00
\.


--
-- Data for Name: donations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.donations (id, user_id, campaign_id, amount, payment_method, status, transaction_ref, created_at, donor_name, donor_email, is_anonymous) FROM stdin;
1	5	1	5000.00	JAZZCASH	completed	MOCK_1778089623503	2026-05-06 22:47:03.614124	donor	donor@gmail.com	f
2	5	1	1000.00	MOCK	completed	MOCK_1778091301960	2026-05-06 23:15:02.094323	donor	donor@gmail.com	f
3	5	1	500.00	MOCK	completed	MOCK_1778091576095	2026-05-06 23:19:36.197605	donor	donor@gmail.com	f
\.


--
-- Data for Name: ngo_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ngo_profiles (id, user_id, org_name, registration_number, address, contact_person, mission, docs_url, status, rejection_reason, created_at, approved_by, approved_at, updated_at) FROM stdin;
1	2	kjkljkljjhfgcgjuj	hghggcvxvukyjhvfgc	ajfhjkaflakjfkla jl lj  kj j jkaf	03187821704	qqqqqqqqqqqqqqqqqqqqwertyuilkjhgfdfbtdsn v  ngg jk kjuiwajfioxjjkfjksdjjfsdjkahjkhjkhjkh	{https://res.cloudinary.com/dlrw50wd7/image/upload/v1778007232/disasteraid/ngo_docs/lv4rdnlidtnmigq6tqcu.png}	APPROVED	\N	2026-05-05 23:53:53.485268	\N	\N	2026-05-06 00:14:17.825521
2	4	my name is google 	main nahi bataunga ga ky number kiya hy	office jb hy hi nahi tou address kaisiay bataun??	03187821407	waisya yare the mission hota kiya hamara to maqsad ha wo has yoi know 	{https://res.cloudinary.com/dlrw50wd7/image/upload/v1778008219/disasteraid/ngo_docs/mc5ndizsshfckayttl09.png}	PENDING	\N	2026-05-06 00:10:19.763586	\N	\N	2026-05-06 00:14:17.825521
3	16	this is an orga	1123465465465465	bnbvcfdghbhjukjvghvjknj	031878214047	gghfffgdfdssdasaS FFGSFDSDS YTFFGDDRYUYU FYTGYUGY	{https://res.cloudinary.com/dlrw50wd7/image/upload/v1778015579/disasteraid/ngo_docs/a2bdriv1zmxo2wgueugz.png}	REJECTED	yaar waisay mera hi platfrom aur meri marzi nahi	2026-05-06 02:13:00.160089	\N	\N	2026-05-06 02:13:00.160089
\.


--
-- Data for Name: ngo_wallets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ngo_wallets (id, ngo_id, balance, total_received, total_withdrawn, updated_at) FROM stdin;
1	1	5500.00	6500.00	1000.00	2026-05-06 23:19:36.197605
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, name) FROM stdin;
1	donor
2	ngo
3	volunteer
4	beneficiary
5	admin
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, phone, password_hash, role_id, name, locale, fcm_token, created_at) FROM stdin;
1	arshad@gmail.com	\N	$2b$10$4Kz7BuXz7qG7hIuYoF5hieg2swDio6b440DtMBy9qBetJGgjkNtxy	1	arshad	en	\N	2026-05-05 22:24:14.186928
2	ngo@gmail.com	\N	$2b$10$XZJZrJjjRcsFuZnotLIuuuPb4XmqTo4J2NXBxOJQWGdsBk.ZM8W02	2	ngo	en	\N	2026-05-05 23:13:02.512459
3	admin@gmail.com	\N	$2b$10$3s99sIoSQP5xaGhGR0FOn.7J0Pg4RS32FctnlE7eCs.FmKQlU7EDe	5	admin	en	\N	2026-05-06 00:05:22.348171
4	ngo1@gmail.com	\N	$2b$10$M4a9u8SPB8eDKGFJ7CDm5O4RA73MQKkptF8yqMnWGnBvoDWM3bc62	2	ngo1	en	\N	2026-05-06 00:09:00.181657
5	donor@gmail.com	\N	$2b$10$NVg7sT5BS6PiBRg73aW3z.8Q5gYa9FdiSm4PQ4sJELE2yrGFrRhUK	1	donor	en	\N	2026-05-06 02:04:58.428229
7	donors@gmail.com	\N	$2b$10$bcug0xqusSjybGJXFnhfb.9PpyJC2/VewqfRoE/x1ZgAt2/AO4RCK	1	donor	en	\N	2026-05-06 02:05:47.025282
10	dono@gmail.com	\N	$2b$10$aVY6B6jLqr3UQR.xj8sfLO3O2K.js7uoCWAtUHbY4PXWGeaMciYZC	1	donors	en	\N	2026-05-06 02:06:11.005868
11	ngo2@gmail.com	\N	$2b$10$SUY/uSReYQh1d1Om07chgeJaO9TKZ6BYAuE8lsViAYOYTH7E8BC66	2	ngo	en	\N	2026-05-06 02:07:21.761927
15	donr@gmail.com	\N	$2b$10$MwsZrLRc7UkUlznw5ZO8WeIA8iE8urEqHqWyOH4OSYwfU31TcnJ5q	1	donor	en	\N	2026-05-06 02:11:18.971422
16	ngo3@gmail.com	\N	$2b$10$xy.vk1xKgI.tyBLL5rVHzew5y5w0RxC7CooaJplN.6LXkleZjzxAm	2	ngo3	en	\N	2026-05-06 02:12:20.39149
17	test@test.com	\N	$2b$10$Ekey/U65Dipws0jHhQkYDOWyIw9s7YFo8OjV56Yiy4bBw41wUJTGG	1	Test	en	\N	2026-05-06 02:52:53.669523
19	volun@gmail.com	03187821407	$2b$10$XKKrqo0wXH.M2xgssAwnYO9KgjQw3auY5FN7VlcPkmx2.g1/Ntvpu	3	volunteer	en	\N	2026-05-07 00:07:46.241709
22	benf@gmail.com	03124587545	$2b$10$EVj8qzKI9jkNprGSDEHF.uUFBAWILHp.oZGwq4L.p7b6tx9Hg2leG	4	beneficiary	en	\N	2026-05-07 00:08:47.634837
\.


--
-- Data for Name: volunteer_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.volunteer_profiles (id, user_id, ngo_id, location, skills, status, created_at) FROM stdin;
\.


--
-- Data for Name: wallet_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wallet_transactions (id, ngo_id, amount, type, donation_id, description, created_at) FROM stdin;
1	1	5000.00	credit	1	Donation for: give me 	2026-05-06 22:47:03.614124
2	1	1000.00	credit	2	Donation for: give me 	2026-05-06 23:15:02.094323
3	1	500.00	credit	3	Donation for: give me 	2026-05-06 23:19:36.197605
\.


--
-- Data for Name: withdrawal_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.withdrawal_requests (id, ngo_id, amount, bank_name, account_title, account_number, iban, status, rejection_reason, approved_by, transaction_ref, created_at, processed_at) FROM stdin;
1	1	1000.00	alfalah	12wkhfjkahfk	124578987	QWDEFRGTYHJUHGFJF;FJKLJK	APPROVED	\N	3	1223455645	2026-05-07 00:38:18.189704	2026-05-07 01:05:54.263786
\.


--
-- Name: aid_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.aid_requests_id_seq', 1, false);


--
-- Name: campaigns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.campaigns_id_seq', 2, true);


--
-- Name: donations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.donations_id_seq', 3, true);


--
-- Name: ngo_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ngo_profiles_id_seq', 3, true);


--
-- Name: ngo_wallets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ngo_wallets_id_seq', 3, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 85, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 23, true);


--
-- Name: volunteer_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.volunteer_profiles_id_seq', 1, false);


--
-- Name: wallet_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wallet_transactions_id_seq', 3, true);


--
-- Name: withdrawal_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.withdrawal_requests_id_seq', 1, true);


--
-- Name: aid_requests aid_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT aid_requests_pkey PRIMARY KEY (id);


--
-- Name: campaigns campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: donations donations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_pkey PRIMARY KEY (id);


--
-- Name: ngo_profiles ngo_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngo_profiles
    ADD CONSTRAINT ngo_profiles_pkey PRIMARY KEY (id);


--
-- Name: ngo_profiles ngo_profiles_registration_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngo_profiles
    ADD CONSTRAINT ngo_profiles_registration_number_key UNIQUE (registration_number);


--
-- Name: ngo_profiles ngo_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngo_profiles
    ADD CONSTRAINT ngo_profiles_user_id_key UNIQUE (user_id);


--
-- Name: ngo_wallets ngo_wallets_ngo_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngo_wallets
    ADD CONSTRAINT ngo_wallets_ngo_id_key UNIQUE (ngo_id);


--
-- Name: ngo_wallets ngo_wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngo_wallets
    ADD CONSTRAINT ngo_wallets_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: donations unique_transaction_ref; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT unique_transaction_ref UNIQUE (transaction_ref);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: volunteer_profiles volunteer_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_profiles
    ADD CONSTRAINT volunteer_profiles_pkey PRIMARY KEY (id);


--
-- Name: volunteer_profiles volunteer_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_profiles
    ADD CONSTRAINT volunteer_profiles_user_id_key UNIQUE (user_id);


--
-- Name: wallet_transactions wallet_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet_transactions
    ADD CONSTRAINT wallet_transactions_pkey PRIMARY KEY (id);


--
-- Name: withdrawal_requests withdrawal_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal_requests
    ADD CONSTRAINT withdrawal_requests_pkey PRIMARY KEY (id);


--
-- Name: idx_aid_requests_beneficiary; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aid_requests_beneficiary ON public.aid_requests USING btree (beneficiary_id);


--
-- Name: idx_aid_requests_ngo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aid_requests_ngo ON public.aid_requests USING btree (ngo_id);


--
-- Name: idx_aid_requests_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aid_requests_status ON public.aid_requests USING btree (status);


--
-- Name: idx_volunteer_profiles_ngo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_volunteer_profiles_ngo ON public.volunteer_profiles USING btree (ngo_id);


--
-- Name: idx_withdrawal_ngo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_withdrawal_ngo ON public.withdrawal_requests USING btree (ngo_id);


--
-- Name: idx_withdrawal_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_withdrawal_status ON public.withdrawal_requests USING btree (status);


--
-- Name: idx_withdrawals_ngo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_withdrawals_ngo ON public.withdrawal_requests USING btree (ngo_id);


--
-- Name: idx_withdrawals_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_withdrawals_status ON public.withdrawal_requests USING btree (status);


--
-- Name: aid_requests aid_requests_beneficiary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT aid_requests_beneficiary_id_fkey FOREIGN KEY (beneficiary_id) REFERENCES public.users(id);


--
-- Name: aid_requests aid_requests_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT aid_requests_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.campaigns(id);


--
-- Name: aid_requests aid_requests_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT aid_requests_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id);


--
-- Name: aid_requests aid_requests_volunteer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT aid_requests_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.volunteer_profiles(id);


--
-- Name: campaigns campaigns_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id) ON DELETE CASCADE;


--
-- Name: donations donations_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.campaigns(id);


--
-- Name: donations donations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ngo_profiles ngo_profiles_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngo_profiles
    ADD CONSTRAINT ngo_profiles_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: ngo_profiles ngo_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngo_profiles
    ADD CONSTRAINT ngo_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ngo_wallets ngo_wallets_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngo_wallets
    ADD CONSTRAINT ngo_wallets_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id);


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: volunteer_profiles volunteer_profiles_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_profiles
    ADD CONSTRAINT volunteer_profiles_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id);


--
-- Name: volunteer_profiles volunteer_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_profiles
    ADD CONSTRAINT volunteer_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: wallet_transactions wallet_transactions_donation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet_transactions
    ADD CONSTRAINT wallet_transactions_donation_id_fkey FOREIGN KEY (donation_id) REFERENCES public.donations(id);


--
-- Name: wallet_transactions wallet_transactions_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet_transactions
    ADD CONSTRAINT wallet_transactions_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id);


--
-- Name: withdrawal_requests withdrawal_requests_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal_requests
    ADD CONSTRAINT withdrawal_requests_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: withdrawal_requests withdrawal_requests_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal_requests
    ADD CONSTRAINT withdrawal_requests_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.ngo_profiles(id);


--
-- PostgreSQL database dump complete
--

\unrestrict J1Afg4INy5E2staXAOk7prL38iA8icg5zhNel7IKO4krDll9nRWuEoWMrKSlTIl

