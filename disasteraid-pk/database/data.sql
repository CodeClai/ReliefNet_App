--
-- PostgreSQL database dump
--

\restrict sUn56jbgX5HREYGz0JIlL4tPhCrtbyi0vZIfh2pgy7cXtP9AGIqQdraJXLeM30m

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

--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name) FROM stdin;
1	donor
2	ngo
3	volunteer
4	beneficiary
5	admin
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
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
-- Data for Name: ngo_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ngo_profiles (id, user_id, org_name, registration_number, address, contact_person, mission, docs_url, status, rejection_reason, created_at, approved_by, approved_at, updated_at) FROM stdin;
1	2	kjkljkljjhfgcgjuj	hghggcvxvukyjhvfgc	ajfhjkaflakjfkla jl lj  kj j jkaf	03187821704	qqqqqqqqqqqqqqqqqqqqwertyuilkjhgfdfbtdsn v  ngg jk kjuiwajfioxjjkfjksdjjfsdjkahjkhjkhjkh	{https://res.cloudinary.com/dlrw50wd7/image/upload/v1778007232/disasteraid/ngo_docs/lv4rdnlidtnmigq6tqcu.png}	APPROVED	\N	2026-05-05 23:53:53.485268	\N	\N	2026-05-06 00:14:17.825521
2	4	my name is google 	main nahi bataunga ga ky number kiya hy	office jb hy hi nahi tou address kaisiay bataun??	03187821407	waisya yare the mission hota kiya hamara to maqsad ha wo has yoi know 	{https://res.cloudinary.com/dlrw50wd7/image/upload/v1778008219/disasteraid/ngo_docs/mc5ndizsshfckayttl09.png}	PENDING	\N	2026-05-06 00:10:19.763586	\N	\N	2026-05-06 00:14:17.825521
3	16	this is an orga	1123465465465465	bnbvcfdghbhjukjvghvjknj	031878214047	gghfffgdfdssdasaS FFGSFDSDS YTFFGDDRYUYU FYTGYUGY	{https://res.cloudinary.com/dlrw50wd7/image/upload/v1778015579/disasteraid/ngo_docs/a2bdriv1zmxo2wgueugz.png}	REJECTED	yaar waisay mera hi platfrom aur meri marzi nahi	2026-05-06 02:13:00.160089	\N	\N	2026-05-06 02:13:00.160089
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.campaigns (id, ngo_id, title, description, category, target_amount, raised_amount, image_url, location, status, created_at, end_date) FROM stdin;
1	1	give me 	this is a chanda system	education	121323.00	6500.00	\N	uoh	ACTIVE	2026-05-06 02:00:22.582857	\N
2	1	MY CAMPAING	THIS IS THE CAMP OF THE LOAKFAJFL KAKLAKLAJJKLFJKLAJFKLWRJKLWQJ	FOOD	147844545.00	0.00	\N	gurjat	ACTIVE	2026-05-07 00:53:34.314565	2026-06-30 00:00:00
\.


--
-- Data for Name: volunteer_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.volunteer_profiles (id, user_id, ngo_id, location, skills, status, created_at) FROM stdin;
\.


--
-- Data for Name: aid_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.aid_requests (id, beneficiary_id, campaign_id, category, description, urgency, family_size, location, lat, lng, status, volunteer_id, ngo_id, proof_url, delivered_at, created_at) FROM stdin;
\.


--
-- Data for Name: donations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.donations (id, user_id, campaign_id, amount, payment_method, status, transaction_ref, created_at, donor_name, donor_email, is_anonymous) FROM stdin;
1	5	1	5000.00	JAZZCASH	completed	MOCK_1778089623503	2026-05-06 22:47:03.614124	donor	donor@gmail.com	f
2	5	1	1000.00	MOCK	completed	MOCK_1778091301960	2026-05-06 23:15:02.094323	donor	donor@gmail.com	f
3	5	1	500.00	MOCK	completed	MOCK_1778091576095	2026-05-06 23:19:36.197605	donor	donor@gmail.com	f
\.


--
-- Data for Name: ngo_wallets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ngo_wallets (id, ngo_id, balance, total_received, total_withdrawn, updated_at) FROM stdin;
1	1	5500.00	6500.00	1000.00	2026-05-06 23:19:36.197605
\.


--
-- Data for Name: wallet_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wallet_transactions (id, ngo_id, amount, type, donation_id, description, created_at) FROM stdin;
1	1	5000.00	credit	1	Donation for: give me 	2026-05-06 22:47:03.614124
2	1	1000.00	credit	2	Donation for: give me 	2026-05-06 23:15:02.094323
3	1	500.00	credit	3	Donation for: give me 	2026-05-06 23:19:36.197605
\.


--
-- Data for Name: withdrawal_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal_requests (id, ngo_id, amount, bank_name, account_title, account_number, iban, status, rejection_reason, approved_by, transaction_ref, created_at, processed_at) FROM stdin;
1	1	1000.00	alfalah	12wkhfjkahfk	124578987	QWDEFRGTYHJUHGFJF;FJKLJK	APPROVED	\N	3	1223455645	2026-05-07 00:38:18.189704	2026-05-07 01:05:54.263786
\.


--
-- Name: aid_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.aid_requests_id_seq', 1, false);


--
-- Name: campaigns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.campaigns_id_seq', 2, true);


--
-- Name: donations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.donations_id_seq', 3, true);


--
-- Name: ngo_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ngo_profiles_id_seq', 3, true);


--
-- Name: ngo_wallets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ngo_wallets_id_seq', 3, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 85, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 23, true);


--
-- Name: volunteer_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.volunteer_profiles_id_seq', 1, false);


--
-- Name: wallet_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wallet_transactions_id_seq', 3, true);


--
-- Name: withdrawal_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.withdrawal_requests_id_seq', 1, true);


--
-- PostgreSQL database dump complete
--

\unrestrict sUn56jbgX5HREYGz0JIlL4tPhCrtbyi0vZIfh2pgy7cXtP9AGIqQdraJXLeM30m

