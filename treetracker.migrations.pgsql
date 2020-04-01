--
-- PostgreSQL database dump
--

-- Dumped from database version 11.7
-- Dumped by pg_dump version 11.7 (Ubuntu 11.7-2.pgdg18.04+1)

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

SET default_with_oids = false;

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: treetracker
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    run_on timestamp without time zone NOT NULL
);


ALTER TABLE public.migrations OWNER TO treetracker;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: treetracker
--

CREATE SEQUENCE public.migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO treetracker;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: treetracker
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: treetracker
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: treetracker
--

COPY public.migrations (id, name, run_on) FROM stdin;
1	/20180420022615-create-organizations-table	2018-05-03 01:13:23.471
2	/20180420044014-create-donors-table	2018-05-03 01:13:23.481
3	/20180420072310-create-certificates-table	2018-05-03 01:13:23.488
4	/20180420231117-add-certificate-column-to-trees-table	2018-05-03 01:13:23.491
5	/20180427203000-AddEstimatedGeometricLocationToTrees	2018-05-03 01:13:23.516
6	/20180427203000-AddLatLngToTrees	2018-05-03 01:13:23.519
7	/20180427203002-PopulateEstimatedNumericValue	2018-05-03 01:13:23.522
8	/20180427203511-addBtreeIndexToEstimatedGeometricLocation	2018-05-03 01:13:24.821
9	/20180427203512-addGISTIndexToEstimatedGeometricLocation	2018-05-03 01:13:24.9
10	/20180503010729-AddActiveColumnToTrees	2018-05-03 01:13:25.102
11	/20180503090224-AddSaltToUsers	2018-05-03 01:13:25.119
12	/20180509005055-AddUserUrlToUsers	2018-05-09 01:40:06.496
13	/20180907223458-CreateDevicesTable	2018-10-02 00:04:00.998
14	/20180911043107-AddAndroidToDevicesTable	2018-10-02 00:04:01.006
15	/20180911045249-AddAndroidSdkToDevicesTable	2018-10-02 00:04:01.01
16	/20180911191712-AddPlanterPhotoUrlToTrees	2018-10-02 00:04:01.014
17	/20180911191719-AddPlanterIdentifierTrees	2018-10-02 00:04:01.016
18	/20180911200357-DropPasswordColumn	2018-10-02 00:04:01.02
19	/20180911200628-AllowNullEmail	2018-10-02 00:04:01.024
20	/20180911200820-AllowNullOrganization	2018-10-02 00:04:01.028
21	/20180911201842-AddDeviceIdToTrees	2018-10-02 00:04:01.032
22	/20180918023239-CreatePlanterRegistrationsTable	2018-10-02 00:04:01.039
23	/20180918034007-AddSequenceToTrees	2018-10-02 00:04:01.042
24	/20181022232536-CreateClustersTable	2018-10-24 01:26:55.264
25	/20181022232643-AddLocationToClusters	2018-10-24 01:26:55.303
26	/20190326213049-AddNoteToTrees	2019-05-17 23:31:31.848
27	/20190330010447-AddVerfiedToTrees	2019-05-17 23:31:34.079
28	/20190425192804-CreateTreeAttributesTable	2019-05-17 23:31:34.134
29	/20190430172553-AddUUIDToTrees	2019-05-17 23:31:34.139
30	/20190511003640-AddApprovedToTrees	2019-05-17 23:31:36.299
31	/20190516203106-AddLocationStringToPlanterRegistrations	2019-05-17 23:31:36.318
32	/20190615062817-AddSequenceNumberToDevices	2019-07-12 19:44:55.949
33	/20190615063043-AddCreatedAtToDevices	2019-07-12 19:44:55.964
34	/20190615063353-CreateUpdatedAtFunction	2019-07-12 19:44:55.97
35	/20190615063543-AddUpdatedAtToDevices	2019-07-12 19:44:55.98
36	/20190615063706-AddUpdatedAtTriggerToDevices	2019-07-12 19:44:55.984
37	/20190624051633-AddStatusToTrees	2019-07-12 19:44:59.013
38	/20190704175934-CreateTableRegions	2019-07-12 19:44:59.049
39	/20190704180821-AddGeomColumnToRegion	2019-07-12 19:44:59.06
40	/20190704180957-CreateTableRegionZoom	2019-07-12 19:44:59.069
41	/20190704181234-CreateTableRegionTypes	2019-07-12 19:44:59.079
42	/20190704181552-CreateTableTreeRegion	2019-07-12 19:44:59.088
43	/20190704181904-CreateUniqueConstraintOnTreeIdZoomLevel	2019-07-12 19:44:59.095
44	/20190704183509-CreateUniqueConstraintOnRegionType	2019-07-12 19:44:59.101
45	/20190704192114-AddCentroidToRegion	2019-07-12 19:44:59.109
46	/20190704200052-AddGISTIndexToRegion	2019-07-12 19:44:59.115
47	/20190705200936-CreateIndexOnZoomLevel	2019-07-12 19:44:59.121
48	/20190712005859-AddZoomLevelIndexOnTreeRegion	2019-07-12 19:44:59.128
49	/20190712210225-AddClusterRegionsAssignedToTrees	2019-07-12 21:24:28.012
50	/20190712213531-AddIndexOnTreesActive	2019-07-12 21:36:17.973
51	/20191013233512-AddSpeciesIdToTrees	2019-10-13 23:38:18.267
52	/20191013233856-AddValueFactorToTreeSpecies	2019-10-13 23:39:48.091
53	/20191029151319-CreateTablePayment	2019-11-13 20:58:56.956
54	/20191030154610-CreateTokenTable	2019-11-13 20:58:56.969
55	/20191031154014-CreateTransactionTable	2019-11-13 20:58:56.977
56	/20191031154616-CreateEntityTable	2019-11-13 20:58:56.987
57	/20191031163456-AddPersonIdToUsers	2019-11-13 20:58:56.993
58	/20191031164730-AddOrganizationIdToUsers	2019-11-13 20:58:56.998
59	/20191031165334-DropSaltToUsers	2019-11-13 20:58:57.005
60	/20191031170534-RemoveFKConnectedToUserTable	2019-11-13 20:58:57.021
61	/20191031170741-RenameUsersTableToPlanter	2019-11-13 20:58:57.027
62	/20191031171621-AddPlantingOrganizationIdToTrees	2019-11-13 20:58:57.033
63	/20191031175213-AddPaymentIdToTrees	2019-11-13 20:58:57.039
64	/20191031175708-RenameUserIdColumnToPlanterId	2019-11-13 20:58:57.044
65	/20191104143211-AddFkPaymentTable	2019-11-13 20:58:57.053
66	/20191104150856-AddFkTokenTable	2019-11-13 20:58:57.063
67	/20191104153634-AddFkTransactionTable	2019-11-13 20:58:57.073
68	/20191104161746-AddFkPlanterTable	2019-11-13 20:58:57.082
69	/20191104164614-AddFkTreesTable	2019-11-13 20:58:57.296
70	/20191106043018-RenameColumnUserIdToPending_UpdateLcoationNotesTable	2019-11-13 20:58:57.304
71	/20191106162911-AddFkToPlanterTable	2019-11-13 20:58:57.329
72	/20191106170015-AddIndexPaymentTable	2019-11-13 20:58:57.34
73	/20191106203811-AddIndexTokenTable	2019-11-13 20:58:57.349
74	/20191106204739-AddIndexTransactionTable	2019-11-13 20:58:57.357
75	/20191108154713-AddIndexTreesTable	2019-11-13 20:58:57.872
76	/20191109000758-RenameUserIdPlanterIdPlanterRegistrations	2019-11-13 20:58:57.878
77	/20191109030455-CreateRejectReasonEnum	2019-11-13 20:58:57.885
78	/20191109030751-AddRejectReasonColumnToTrees	2019-11-13 20:58:57.89
79	/20191208014540-AddWalletToEntity	2019-12-08 06:10:50.452
80	/20191208043552-AddUUIDToToken	2019-12-08 06:13:55.709
81	/20191208051913-AddIndexToMaterializedView	2019-12-08 06:13:57.359
82	/20191208073023-DropTokensTable	2019-12-08 07:32:28.925
83	/20200116234211-CreateApiKeyTable	2020-03-03 23:13:11.273
84	/20200117001520-AddPasswordToEntity	2020-03-03 23:13:11.288
85	/20200117001645-AddSaltToEntity	2020-03-03 23:13:11.296
86	/20200117201156-CreateEntityRoleTable	2020-03-03 23:13:11.314
87	/20200117201427-AddFkEntityRole	2020-03-03 23:14:09.296
88	/20200117203921-CreateTableEntityManager	2020-03-03 23:14:09.317
89	/20200117204132-AddFkEntityManager	2020-03-03 23:14:09.332
90	/20200117213239-AddUniqueWalletIndexEntityTable	2020-03-03 23:17:05.72
91	/20200117222617-CreateTokenTransactionTrigger	2020-03-03 23:18:04.155
92	/20200117223018-AddTransactionDateToTransaction	2020-03-03 23:18:04.167
93	/20200117223738-CreateTransferTable	2020-03-03 23:18:04.181
94	/20200203012334-CreateContractsTable	2020-03-03 23:18:04.198
95	/20200203014434-AddContractIdToTree	2020-03-03 23:18:04.204
96	/20200203014605-AddActiveContractIdToEntity	2020-03-03 23:18:04.208
97	/20200305223711-AddApiKeyHash	2020-03-05 22:38:50.612
98	/20200305223714-AddApiKeySalt	2020-03-05 22:38:50.623
99	/20200305225054-AddApiKeyName	2020-03-05 22:58:29.404
130	/20200203021656-AddPayToPlantBooleanToEntity	2020-03-21 00:38:05.116
131	/20200203022010-AddTokenIssuedToTrees	2020-03-21 00:38:05.129
132	/20200204175554-AddValidationContractToOrganization	2020-03-21 00:38:05.136
133	/20200320213822-CreateMorphologyTypeEnum	2020-03-21 00:38:05.152
134	/20200320214000-AddMorphologyToTree	2020-03-21 00:38:05.161
135	/20200320214335-CreateAgeTypeEnum	2020-03-21 00:38:05.168
136	/20200320214538-AddAgeToTree	2020-03-21 00:38:05.175
137	/20200320215610-AddSpeciesColumnToTrees	2020-03-21 00:38:05.182
138	/20200320215808-CreateCaptureApprovalType	2020-03-21 00:38:05.195
139	/20200320220026-AddCaptureApprovalToTree	2020-03-21 00:38:05.202
140	/20200320220557-DropRejectReasonFromTrees	2020-03-21 00:38:05.209
141	/20200320220657-DropRejectReasonEnum	2020-03-21 00:38:05.217
142	/20200320220744-CreateRejectionReasonType	2020-03-21 00:38:05.225
143	/20200320221504-AddRejectionReasonToTrees	2020-03-21 00:38:05.233
144	/20200321004009-AddLogoUrlToEntity	2020-03-21 00:40:43.24
145	/20200321005033-DropPasswordRemindersTable	2020-03-21 00:51:18.345
\.


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: treetracker
--

SELECT pg_catalog.setval('public.migrations_id_seq', 145, true);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: treetracker
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: TABLE migrations; Type: ACL; Schema: public; Owner: treetracker
--

REVOKE ALL ON TABLE public.migrations FROM treetracker;
GRANT ALL ON TABLE public.migrations TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.migrations TO treetracker;
GRANT SELECT ON TABLE public.migrations TO treetracker_manager;


--
-- PostgreSQL database dump complete
--

