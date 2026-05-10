--
-- PostgreSQL database dump
--

\restrict IIQLulhkjAjrluW4j2f9X7XzZ4aiTUlKHX5cqW3tT3xlWC566f6eg5yLrbhNIZD

-- Dumped from database version 18.3 (Debian 18.3-1.pgdg13+1)
-- Dumped by pg_dump version 18.3

-- Started on 2026-05-10 21:28:29

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 919 (class 1247 OID 16730)
-- Name: assessment_session_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.assessment_session_status AS ENUM (
    'ACTIVE',
    'COMPLETED',
    'ABANDONED'
);


ALTER TYPE public.assessment_session_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 231 (class 1259 OID 16561)
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 16661)
-- Name: assessment_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assessment_logs (
    log_id integer NOT NULL,
    session_id uuid NOT NULL,
    user_id uuid NOT NULL,
    question_id character varying(10) NOT NULL,
    user_query text NOT NULL,
    is_correct boolean NOT NULL,
    theta_before double precision,
    theta_after double precision,
    execution_time_ms integer,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    attempt_number integer NOT NULL,
    is_final_attempt boolean NOT NULL,
    difficulty_before double precision,
    difficulty_after double precision,
    stagnation_detected boolean NOT NULL
);


ALTER TABLE public.assessment_logs OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16660)
-- Name: assessment_logs_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.assessment_logs_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.assessment_logs_log_id_seq OWNER TO postgres;

--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 237
-- Name: assessment_logs_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.assessment_logs_log_id_seq OWNED BY public.assessment_logs.log_id;


--
-- TOC entry 240 (class 1259 OID 16737)
-- Name: assessment_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assessment_sessions (
    session_id uuid NOT NULL,
    user_id uuid NOT NULL,
    module_id character varying(5) NOT NULL,
    question_ids_served character varying(10)[] DEFAULT '{}'::character varying[] NOT NULL,
    status public.assessment_session_status DEFAULT 'ACTIVE'::public.assessment_session_status NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone,
    current_question_id character varying(10),
    current_question_attempt_count integer NOT NULL,
    total_session_attempts integer NOT NULL,
    current_question_start_time timestamp with time zone
);


ALTER TABLE public.assessment_sessions OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16567)
-- Name: modules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modules (
    module_id character varying(5) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    difficulty_min double precision NOT NULL,
    difficulty_max double precision NOT NULL,
    content_html text,
    unlock_theta_threshold double precision NOT NULL,
    order_index integer NOT NULL
);


ALTER TABLE public.modules OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16694)
-- Name: peer_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.peer_sessions (
    session_id uuid NOT NULL,
    requester_id uuid NOT NULL,
    reviewer_id uuid NOT NULL,
    question_id character varying(10) NOT NULL,
    review_content text NOT NULL,
    system_score double precision NOT NULL,
    is_helpful boolean,
    final_score double precision NOT NULL,
    status character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    requester_query text NOT NULL,
    theta_social_before double precision,
    theta_social_after double precision,
    completed_at timestamp with time zone
);


ALTER TABLE public.peer_sessions OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16598)
-- Name: pretest_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pretest_sessions (
    session_id uuid NOT NULL,
    user_id uuid NOT NULL,
    current_question_index integer NOT NULL,
    answers jsonb NOT NULL,
    total_questions integer NOT NULL,
    current_theta double precision NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone
);


ALTER TABLE public.pretest_sessions OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16619)
-- Name: questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.questions (
    question_id character varying(10) NOT NULL,
    module_id character varying(5) NOT NULL,
    content text NOT NULL,
    target_query text NOT NULL,
    initial_difficulty double precision NOT NULL,
    current_difficulty double precision NOT NULL,
    topic_tags character varying[],
    is_active boolean NOT NULL
);


ALTER TABLE public.questions OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16640)
-- Name: user_module_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_module_progress (
    user_id uuid NOT NULL,
    module_id character varying(5) NOT NULL,
    is_completed boolean NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    is_unlocked boolean NOT NULL
);


ALTER TABLE public.user_module_progress OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16578)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id uuid NOT NULL,
    nim character varying(20) NOT NULL,
    full_name character varying(100) NOT NULL,
    password_hash character varying NOT NULL,
    theta_social double precision NOT NULL,
    k_factor integer NOT NULL,
    has_completed_pretest boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    theta_individu double precision NOT NULL,
    total_attempts integer NOT NULL,
    status character varying(20) NOT NULL,
    group_assignment character varying(1) NOT NULL,
    stagnation_ever_detected boolean NOT NULL,
    is_admin boolean NOT NULL,
    is_deleted boolean NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT check_k_factor_positive CHECK ((k_factor > 0))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 3362 (class 2604 OID 16664)
-- Name: assessment_logs log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_logs ALTER COLUMN log_id SET DEFAULT nextval('public.assessment_logs_log_id_seq'::regclass);


--
-- TOC entry 3559 (class 0 OID 16561)
-- Dependencies: 231
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
494290722d1e
\.


--
-- TOC entry 3566 (class 0 OID 16661)
-- Dependencies: 238
-- Data for Name: assessment_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assessment_logs (log_id, session_id, user_id, question_id, user_query, is_correct, theta_before, theta_after, execution_time_ms, "timestamp", attempt_number, is_final_attempt, difficulty_before, difficulty_after, stagnation_detected) FROM stdin;
1	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q018	select * from student s where s.dept_name = 'Comp.Sci' and s.tot_cred > 80;	f	\N	\N	0	2026-05-07 08:16:57.74548+00	1	f	\N	\N	f
2	99ba6fde-582b-40f8-a287-453c83c9c56d	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH01-Q024	select dept_name from department\nwhere dept_name like '%tech%';	t	1340	1354.7841475487285	0	2026-05-07 08:18:05.018861+00	1	t	1330.2158524512715	1330.2158524512715	f
3	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q018	select * from student s where s.dept_name = 'Comp. Sci' and s.tot_cred > 80;	f	\N	\N	0	2026-05-07 08:18:22.133713+00	2	f	\N	\N	f
4	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q018	select * \n  from student s \n  where (s.dept_name = 'Comp. Sci' and s.tot_cred > 80);	f	1260	1245.2158524512715	0	2026-05-07 08:19:28.470336+00	3	t	1269.7841475487285	1269.7841475487285	f
5	4c6300f2-de1d-490c-b9e4-6d0bc8897b61	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q019	SELECT *\nFROM instructor\nWHERE salary BETWEEN 60000 AND 90000	t	1260	1274.5683844750201	0	2026-05-07 08:20:43.895381+00	1	t	1255.4316155249799	1255.4316155249799	f
6	4c6300f2-de1d-490c-b9e4-6d0bc8897b61	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q018	SELECT *\nFROM STUDENT\nWHERE dept_name='Comp. Sci.' AND tot_cred>80	t	1274.5683844750201	1289.7749235325334	0	2026-05-07 08:22:02.232845+00	1	t	1254.5776084912152	1254.5776084912152	f
7	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q011	select count(ID), dept_name \nfrom instructor, department\ngroup by dept_name \norder by DESC;	f	\N	\N	0	2026-05-07 08:22:16.263089+00	1	f	\N	\N	f
9	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q011	select count(ID), dept_name \nfrom instructor, department\ngroup by dept_name \norder by DESC;	f	\N	\N	0	2026-05-07 08:22:52.006318+00	2	f	\N	\N	f
8	4c6300f2-de1d-490c-b9e4-6d0bc8897b61	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q020	SELECT DISTINCT building, room_no\nFROM classroom	t	1289.7749235325334	1304.9810605746015	0	2026-05-07 08:22:51.65624+00	1	t	1269.7938629579319	1269.7938629579319	f
10	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q016	select course_id, slama.credits, double_credits\nfrom student slama, student sbaru\nwhere sbaru.credits = (sbaru.credits * 2) as double_credits	f	\N	\N	0	2026-05-07 08:23:33.15315+00	1	f	\N	\N	f
12	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q016	select course_id, slama.credits, \n  (select credits\n  from student sbaru\n  where sbaru.credits = (sbaru.credits * 2)) as double_credits\nfrom student slama;	f	\N	\N	0	2026-05-07 08:27:01.228779+00	2	f	\N	\N	f
13	acc607f6-c19c-4c0c-98fa-8e2740677feb	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH01-Q024	select *\nfrom department\nwhere dept_name like '%tech%' and\n      budget > 10000000	t	1340	1355.4223039761632	0	2026-05-07 08:27:08.406263+00	1	t	1314.7935484751083	1314.7935484751083	f
11	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q011	select count(i.id) as jumlah, d.dept_name\nfrom instructor i, department d\ngroup by dept_name\norder by jumlah desc;	f	1354.7841475487285	1339.990682748234	0	2026-05-07 08:26:53.286028+00	3	t	1364.7934648004946	1364.7934648004946	f
14	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q016	select course_id, slama.credits, \n  (select credits\n  from course sbaru\n  where sbaru.credits = (sbaru.credits * 2)) as double_credits\nfrom course slama;	f	1245.2158524512715	1231.0876573219973	0	2026-05-07 08:27:19.529408+00	3	t	1239.1281951292742	1239.1281951292742	f
15	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT COUNT course_id\nFROM course	f	\N	\N	0	2026-05-07 08:28:57.690103+00	1	f	\N	\N	f
16	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q017	select *\nfrom student\nwhere dept_name = 'Comp. Sci' or tot_creds < 50;	f	\N	\N	0	2026-05-07 08:29:09.466553+00	1	f	\N	\N	f
17	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q017	select *\nfrom student\nwhere dept_name = 'Comp. Sci' or tot_cred < 50;	f	\N	\N	0	2026-05-07 08:29:16.006861+00	2	f	\N	\N	f
18	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q010	select building, avg(capacity)\nfrom classroom\ngroup by building\nhaving avg(capacity) > 80;	t	1339.990682748234	1355.2061330245544	0	2026-05-07 08:29:41.969023+00	1	t	1319.7845497236794	1319.7845497236794	f
20	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q017	select name\nfrom student\nwhere dept_name = 'Comp. Sci' or tot_cred < 50;	f	1231.0876573219973	1215.702964932322	0	2026-05-07 08:30:32.967077+00	3	t	1255.3846923896754	1255.3846923896754	f
19	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT COUNT (distinct course_id)\nFROM course	f	1304.9810605746015	1290.6274444057165	0	2026-05-07 08:30:31.786864+00	2	t	1304.353616168885	1304.353616168885	f
21	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q014	select *\nfrom course\nwhere credits > 3\nORDER BY title;	t	1215.702964932322	1231.5957273780043	0	2026-05-07 08:31:51.203327+00	1	t	1179.1072375543176	1179.1072375543176	f
22	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q011	select count(t.ID) as jumlah, d.dept_name\nfrom teachers t, department d\ngroup by d.dept_name\norder by jumlah desc;	f	\N	\N	0	2026-05-07 08:32:13.276784+00	1	f	\N	\N	f
23	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q011	select count(t.ID) as jumlah, d.dept_name\nfrom teaches t, department d\ngroup by d.dept_name\norder by jumlah desc;	f	\N	\N	0	2026-05-07 08:32:47.306115+00	2	f	\N	\N	f
25	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q008	SELECT AVG budget\nFROM department\nWHERE building.department='Taylor'	f	\N	\N	0	2026-05-07 08:34:39.243381+00	1	f	\N	\N	f
26	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q008	SELECT AVG (budget)\nFROM department\nWHERE building.department='Taylor'	f	\N	\N	0	2026-05-07 08:34:45.931974+00	2	f	\N	\N	f
24	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q011	select count(t.ID), d.dept_name\nfrom teaches t, department d\ngroup by d.dept_name\norder by count(t.ID) desc;	f	1355.2061330245544	1339.7923196677448	0	2026-05-07 08:33:59.920381+00	3	t	1380.2072781573042	1380.2072781573042	f
27	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q015	select building\nfrom classroom\nwhere capacity > 150\nORDER BY capacity desc;	f	\N	\N	0	2026-05-07 08:35:20.60331+00	1	f	\N	\N	f
28	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q011	select count(ID)\nfrom instructor\ngroup by dept_name\norder by count(dept_name) desc	f	\N	\N	0	2026-05-07 08:35:22.643345+00	1	f	\N	\N	f
32	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q019	select *\nfrom instructor\nwhere salary >= 60000 and salary <= 90000;	t	1232.5268909849724	1246.5394446411328	0	2026-05-07 08:36:45.36004+00	1	t	1241.4190618688194	1241.4190618688194	f
29	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q015	select *\nfrom classroom\nwhere capacity > 150\nORDER BY capacity desc;	t	1231.5957273780043	1232.5268909849724	0	2026-05-07 08:35:37.577102+00	2	t	1209.068836393032	1209.068836393032	t
30	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q008	SELECT AVG (budget)\nFROM department\nWHERE building.department='Taylor'	f	1290.6274444057165	1275.0072850145855	0	2026-05-07 08:35:59.692474+00	3	t	1320.620159391131	1320.620159391131	f
31	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q011	select count(ID)\nfrom instructor\ngroup by dept_name\norder by count(dept_name) desc	f	\N	\N	0	2026-05-07 08:36:34.156004+00	2	f	\N	\N	f
33	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q006	SELECT COUNT (tot_cred), dept_name\nFROM student	f	\N	\N	0	2026-05-07 08:37:12.691032+00	1	f	\N	\N	f
34	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q006	SELECT COUNT (tot_cred), dept_name\nFROM student\nGROUP BY student.dept_name	f	\N	\N	0	2026-05-07 08:37:26.990479+00	2	f	\N	\N	f
36	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q006	SELECT SUM (tot_cred), dept_name\nFROM student\nGROUP BY student.dept_name	f	1275.0072850145855	1260.0075995339478	0	2026-05-07 08:37:41.651051+00	3	t	1289.9996854806377	1289.9996854806377	f
35	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q020	select distinct room_no, building\nfrom classroom;	t	1246.5394446411328	1260.5369672301854	0	2026-05-07 08:37:28.313093+00	1	t	1255.7963403688793	1255.7963403688793	t
37	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q021	select *\nfrom student\nwhere name like '% %' and name like '%n';	t	1260.5369672301854	1269.4059893469487	0	2026-05-07 08:38:51.700342+00	1	t	1291.1309778832367	1291.1309778832367	t
39	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q022	select title\nfrom course\nwhere title not like '%Intro%' and credits <=3;	f	\N	\N	0	2026-05-07 08:42:04.908642+00	1	f	\N	\N	f
38	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q024	select dept_name\nfrom department\nwhere dept_name like '%tech%' and budget > 10000000;	t	1269.4059893469487	1278.1070113296694	0	2026-05-07 08:39:54.795528+00	1	t	1306.0925264923876	1306.0925264923876	t
615	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q005	SELECT course.title, prereq_course.title\nFROM course natural join course as prereq_course natural join prereq\nWHERE prereq.course_id = course.course_id AND prereq.prereq_id = prereq_course.course_id	f	\N	\N	596696	2026-05-09 07:10:46.612605+00	1	f	\N	\N	f
40	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q022	select *\nfrom course\nwhere title not like '%Intro%' and credits <=3;	t	1278.1070113296694	1277.04911889083	0	2026-05-07 08:42:31.561355+00	2	t	1316.0578924388394	1316.0578924388394	t
622	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q007	select semester, year, count(course_ID) as jumlah_course\nfrom section\ngroup by semester, year	t	1302.0580144466603	1304.0003140000636	187986	2026-05-09 07:12:41.535168+00	2	t	1308.1292481618332	1306.18694860843	t
626	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q004	select dept_name, max(tot_cred) as max_sks\nfrom student\ngroup by dept_name	t	1304.0003140000636	1323.4235091782564	102810	2026-05-09 07:14:26.142896+00	1	t	1269.3155945823028	1249.89239940411	t
632	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q013	select count(distinct ID)\nfrom takes\nwhere year = 2009	t	1323.4235091782564	1345.038703443703	129488	2026-05-09 07:16:38.865239+00	1	t	1358.2797018888912	1336.6645076234445	t
635	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q009	select department.dept_name, student.tot_cred\nfrom department, student\nwhere student.ID = department.dept_name\nwhere student.tot_cred >10	f	\N	\N	108052	2026-05-09 07:18:29.623207+00	2	f	\N	\N	f
638	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q002	SELECT department.dept_name\nFROM department natural left outer join instructor\nHAVING COUNT(instructor.ID) > 0	f	\N	\N	118311	2026-05-09 07:19:27.236514+00	1	f	\N	\N	f
642	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q011	select dept_name, count(name)\nfrom instructor\ngroup by dept_name\norder by count(name) desc	t	1335.2054584739992	1348.930863462319	136252	2026-05-09 07:21:04.392842+00	1	t	1350.8661178991588	1337.140712910839	t
645	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q021	select time_slot_id, count(course_id)\nfrom section\ngroup by time_slot_id\nhaving count(course_id) > 0	t	1403.426636349168	1415.0464087574953	175776	2026-05-09 07:21:33.825196+00	1	t	1511.2912854624951	1499.6715130541677	t
648	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q014	select avg(tot_cred)\nfrom student\nwhere tot_cred > 50	t	1364.6714578289927	1378.4452118744427	54389	2026-05-09 07:22:36.590218+00	1	t	1324.944869274062	1311.171115228612	t
653	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q017	select dept_name\nfrom instructor\nwhere count(ID) > 2	f	\N	\N	74986	2026-05-09 07:23:53.233154+00	1	f	\N	\N	f
654	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q003	SELECT course.title, time_slot.day, time_slot.start_time, time_slot.end_time\nFROM course natural join section natural join time_slot	t	1440.7067040707625	1455.3009635205835	69270	2026-05-09 07:24:27.491935+00	1	t	1440	1425.405740550179	f
657	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q009	select dept_name, sum(credits)\nfrom course\ngroup by dept_name\nhaving sum(credits) > 10	t	1427.5204605815359	1435.685471045497	160625	2026-05-09 07:26:18.54061+00	1	t	1360.666148681275	1352.5011382173138	t
660	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q020	select name, tot_cred, case when tot_cred < 30 then 'Freashman' when tot_cred >=30 and tot_cred < 60 then 'Sophomore' else 'Final Year' end as classification\nfrom student	f	\N	\N	252068	2026-05-09 07:27:23.275887+00	1	f	\N	\N	f
41	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q011	select count(ID)\nfrom instructor\ngroup by dept_name\norder by sum(dept_name) desc	f	1355.4223039761632	1339.354062087387	0	2026-05-07 08:43:09.679729+00	3	t	1396.2755200460804	1396.2755200460804	f
616	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q005	SELECT course.title, prereq_course.title\nFROM course natural join course as prereq_course natural join prereq	f	\N	\N	610998	2026-05-09 07:11:00.918861+00	2	f	\N	\N	f
620	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q019	select dept_name, count(course_id), avg(credits)\nfrom course\ngroup by dept_name\nhaving avg(credits) > 3	f	\N	\N	121636	2026-05-09 07:12:30.009338+00	1	f	\N	\N	f
623	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q013	SELECT COUNT(DISTINCT *) FROM takes\nWHERE year = '2009';	f	\N	\N	67760	2026-05-09 07:13:50.344436+00	1	f	\N	\N	f
627	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q020	select name, tot_cred,\nCASE \nwhen tot_cred < 30 THEN 'Freshmen'\nwhen tot_cred > 29 AND tot_cred <60 THEN 'Sophomore'\nwhen tot_cred > 59 AND tot_cred <90 THEN 'Junior'\nElse 'Final Year'\nEnd as classificaation\nfrom student	f	\N	\N	359583	2026-05-09 07:14:31.314343+00	1	f	\N	\N	f
631	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q004	SELECT name\nFROM student natural join takes natural join course\nWHERE course.title = 'Intro. to Computer Science' AND student.tot_cred < 60	f	1470.8119358868134	1455.345297714133	230515	2026-05-09 07:15:44.886663+00	3	t	1460	1475.4666381726804	f
636	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q020	select name, tot_cred,\nCASE \nwhen tot_cred < 30 THEN 'Freshman'\nwhen tot_cred > 29 AND tot_cred <60 THEN 'Sophomore'\nwhen tot_cred > 59 AND tot_cred <90 THEN 'Junior'\nElse 'Final Year'\nEnd as classification\nfrom student	t	1403.7644269400112	1403.426636349168	604753	2026-05-09 07:18:36.478438+00	3	t	1506.8503925115003	1507.1881831023436	t
639	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q002	SELECT department.dept_name\nFROM department natural left outer join instructor\nGROUP BY department.dept_name\nHAVING COUNT(instructor.ID) > 0	f	\N	\N	133941	2026-05-09 07:19:42.803813+00	2	f	\N	\N	f
651	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q001	SELECT student.name, takes.course_ID\nFROM student inner join takes on student.ID = takes.ID	t	1444.3314733455186	1440.7067040707625	153353	2026-05-09 07:23:12.609143+00	3	t	1400	1403.624769274756	f
655	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q017	select dept_name\nfrom instructor\nhaving count(ID) > 2	f	\N	\N	133405	2026-05-09 07:24:51.673866+00	2	f	\N	\N	f
658	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q020	SELECT name, tot_cred,\n  CASE\n    WHEN tot_cred < 30 THEN 'Freshman'\n    WHEN tot_cred < 59 THEN 'Sophomore'\n    WHEN tot_cred < 89 THEN 'Junior'\n    ELSE 'Final Year'\n  END AS classification\nFROM student;	t	1402.7683839839208	1417.0800707845578	230321	2026-05-09 07:26:37.693235+00	1	t	1507.1881831023436	1492.8764963017065	t
43	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q008	select avg (budget)\nfrom department\nwhere building = 'Taylor'	t	1339.354062087387	1355.1620867451297	0	2026-05-07 08:45:25.46684+00	1	t	1304.8121347333883	1304.8121347333883	f
74	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q009	select dept_name, sum(credits)\nfrom course\ngroup by dept_name\nhaving sum(credits) > 10	t	1339.737463366845	1340.5886826538433	0	2026-05-07 08:55:16.904177+00	2	t	1319.1487807130018	1319.1487807130018	f
42	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q005	SELECT	f	1260.0075995339478	1245.0079276322024	0	2026-05-07 08:44:42.222916+00	1	t	1274.9996719017454	1274.9996719017454	t
44	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q003	SELECT (AVG tot_cred), distinct department\nFROM student\nGROUP BY tot_cred	f	\N	\N	0	2026-05-07 08:46:51.049725+00	1	f	\N	\N	f
45	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q023	select i.name\nfrom instructor i JOIN department d on t.dept_name = d.dept_name JOIN course c on c.dept_name = d.dept_name, \nORDER BY i.name asc, c.course_id asc;	f	\N	\N	0	2026-05-07 08:47:47.383773+00	1	f	\N	\N	f
46	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q012	select dept_name\nfrom department, instructor\nwhere salary > 90000 and salary = max(salary)	f	\N	\N	0	2026-05-07 08:48:11.635705+00	1	f	\N	\N	f
47	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q003	select dept_name, tot_cred\nfrom ( select dept_name, avg (salary)\nfrom student\ngroup by dept_name)	f	\N	\N	0	2026-05-07 08:48:19.284816+00	2	f	\N	\N	f
48	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q012	select department.dept_name\nfrom department, instructor\nwhere salary > 90000 and salary = max(salary)	f	\N	\N	0	2026-05-07 08:48:26.526473+00	2	f	\N	\N	f
50	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q023	select i.name\nfrom instructor i, department d, course c \nWHERE  t.dept_name = d.dept_name and c.dept_name = d.dept_name\nORDER BY i.name asc and c.course_id asc;	f	\N	\N	0	2026-05-07 08:49:15.269704+00	2	f	\N	\N	f
66	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q002	SELECT COUNT (ID) as jumlah_mhs, dept_name\nFROM student	f	1230.6554692496259	1221.105765155689	0	2026-05-07 08:52:54.128041+00	3	t	1224.549704093937	1224.549704093937	t
51	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q023	select i.name\nfrom instructor i, department d, course c \nWHERE  t.dept_name = d.dept_name and c.dept_name = d.dept_name\nORDER BY i.name asc;	f	1277.04911889083	1265.5367612333043	0	2026-05-07 08:49:21.311466+00	3	t	1341.5123576575256	1341.5123576575256	t
52	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q012	select d.dept_name\nfrom department d, instructor i\nwhere i.salary > 90\ngroup by department\nhaving max(i.salary);	f	\N	\N	0	2026-05-07 08:49:46.060601+00	1	f	\N	\N	f
54	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q013	select *\nfrom student\norder by credits desc;	f	\N	\N	0	2026-05-07 08:49:52.053069+00	1	f	\N	\N	f
55	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q013	select *\nfrom student\norder by credit desc;	f	\N	\N	0	2026-05-07 08:49:55.255463+00	2	f	\N	\N	f
56	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q013	select *\nfrom student\norder by tot_credit desc;	f	1265.5367612333043	1257.9501432326217	0	2026-05-07 08:50:02.410102+00	3	t	1187.5866180006826	1187.5866180006826	t
49	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q003	select dept_name, tot_cred\nfrom ( select dept_name, avg (tot_cred)\nfrom student\ngroup by dept_name)	f	1245.0079276322024	1230.6554692496259	0	2026-05-07 08:48:27.823976+00	3	t	1244.3524583825765	1244.3524583825765	t
53	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q012	select department.dept_name\nfrom department, instructor\nwhere salary > 90000\nhaving salary = max(salary)	f	1355.1620867451297	1339.737463366845	0	2026-05-07 08:49:49.05395+00	3	t	1380.4246233782847	1380.4246233782847	f
57	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q018	select *\nfrom student\nwhere dept_name = 'Comp. Sci' and tot_cred > 80;	f	\N	\N	0	2026-05-07 08:50:48.150882+00	1	f	\N	\N	f
58	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q018	select name\nfrom student\nwhere dept_name = 'Comp. Sci' and tot_cred > 80;	f	\N	\N	0	2026-05-07 08:50:59.354275+00	2	f	\N	\N	f
67	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q010	select *\nfrom student \nwhere tot_cred >= 50 and tot_cred <=100;	t	1242.6092772857362	1252.3606749119338	0	2026-05-07 08:53:13.676655+00	1	t	1125.2486023738024	1125.2486023738024	t
59	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q018	select all\nfrom student\nwhere dept_name = 'Comp. Sci' and tot_cred > 80;	f	1257.9501432326217	1248.047209536728	0	2026-05-07 08:51:30.384489+00	3	t	1264.480542187109	1264.480542187109	t
60	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q002	SELECT COUNT ID as jumlah_mhs, distinct department\nFROM student	f	\N	\N	0	2026-05-07 08:51:41.321619+00	1	f	\N	\N	f
61	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q011	select *\nfrom student\nwhere tot_cred >0;	f	\N	\N	0	2026-05-07 08:52:01.112959+00	1	f	\N	\N	f
62	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q011	select name\nfrom student\nwhere tot_cred >0;	f	\N	\N	0	2026-05-07 08:52:09.392541+00	2	f	\N	\N	f
63	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q009	select dept_name \nfrom course\ngroup by dept_name\nhaving sum(credits) > 10	f	\N	\N	0	2026-05-07 08:52:45.110971+00	1	f	\N	\N	f
64	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q002	SELECT COUNT (ID) as jumlah_mhs, distinct dept_name\nFROM student	f	\N	\N	0	2026-05-07 08:52:45.593788+00	2	f	\N	\N	f
68	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q001	SELECT COUNT ID \nFROM student	f	\N	\N	0	2026-05-07 08:53:30.986375+00	1	f	\N	\N	f
65	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q011	select *\nfrom student\nwhere tot_cred is null;	f	1248.047209536728	1242.6092772857362	0	2026-05-07 08:52:45.74334+00	3	t	1155.4379322509917	1155.4379322509917	t
69	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q025	select * from course;	f	\N	\N	0	2026-05-07 08:53:41.392639+00	1	f	\N	\N	f
85	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT COUNT (DISTINCT course.course_id) as jumlah_course, section.semester\nFROM course, section	f	\N	\N	0	2026-05-07 08:57:43.782391+00	2	f	\N	\N	f
70	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q001	SELECT COUNT (distinct ID)\nFROM student	t	1221.105765155689	1221.7124917714802	0	2026-05-07 08:53:55.397632+00	2	t	1199.3932733842087	1199.3932733842087	t
75	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q012	select *\nfrom student\nwhere tot_cred >0;	t	1249.7229701565675	1259.0164534165326	0	2026-05-07 08:55:23.658486+00	1	t	1155.7065167400349	1155.7065167400349	t
71	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q025	select c.course_id, c.title, c.dept_name, c.credits, s.semester, s.year\nfrom course c, section s\nwhere c.course_id = s.course_id;	t	1252.3606749119338	1249.7229701565675	0	2026-05-07 08:55:01.980821+00	2	t	1382.6377047553663	1382.6377047553663	t
72	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q012	select d.dept_name\nfrom department d, instructor i\nwhere i.salary > 90\ngroup by department\nhaving max(salary);	f	\N	\N	0	2026-05-07 08:55:05.355173+00	2	f	\N	\N	f
73	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q004	SELECT MAX (credits), dept_name\nFROM course	f	\N	\N	0	2026-05-07 08:55:09.571556+00	1	f	\N	\N	f
76	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q004	SELECT MAX (credits), course.dept_name\nFROM course	f	\N	\N	0	2026-05-07 08:55:30.097912+00	2	f	\N	\N	f
78	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q008	select name\nfrom student\nwhere name like '%ez';	f	\N	\N	0	2026-05-07 08:55:48.261654+00	1	f	\N	\N	f
79	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q008	select *\nfrom student\nwhere name like '%ez';	t	1259.0164534165326	1262.139242846872	0	2026-05-07 08:55:52.71261+00	2	t	1101.8772105696605	1101.8772105696605	t
77	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q004	SELECT MAX (credits), dept_name\nFROM course\nGROUP BY (dept_name)	f	1221.7124917714802	1211.0432253532417	0	2026-05-07 08:55:45.821187+00	3	t	1255.6692664182385	1255.6692664182385	t
80	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT COUNT (DISTINCT course_id) as jumlah_course\nFROM course	f	\N	\N	0	2026-05-07 08:56:32.506079+00	1	f	\N	\N	f
81	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q009	select *\nfrom student\nwhere dept_name = 'Comp. Sci' or dept_name = 'Physics';	f	\N	\N	0	2026-05-07 08:56:34.173506+00	1	f	\N	\N	f
82	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q009	select name\nfrom student\nwhere dept_name = 'Comp. Sci' or dept_name = 'Physics';	f	\N	\N	0	2026-05-07 08:56:53.970207+00	2	f	\N	\N	f
617	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q007	select semester, year, count(course_ID)\nfrom section\ngroup by semester, year	f	\N	\N	125669	2026-05-09 07:11:39.250785+00	1	f	\N	\N	f
90	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q005	select name, dept_name\nfrom instructor\nwhere dept_name = 'Comp. Sci.';	t	1273.4930893132562	1285.0976499513904	0	2026-05-07 08:59:23.699348+00	1	t	1048.3954393618658	1048.3954393618658	t
91	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q004	select *\nfrom student\nwhere dept_name = 'Comp. Sci.';	t	1285.0976499513904	1297.087602514122	0	2026-05-07 08:59:47.085167+00	1	t	1033.0100474372684	1033.0100474372684	t
92	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q013	select count(distinct ID)\nfrom takes\nwhere year = 2009	t	1341.48579732544	1354.829783203847	0	2026-05-07 08:59:58.945441+00	1	t	1366.656014121593	1366.656014121593	t
93	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q006	select title\nfrom course;	t	1297.087602514122	1308.820361670591	0	2026-05-07 09:00:02.118589+00	1	t	1063.267240843531	1063.267240843531	f
621	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q016	SELECT course.title, count(ID) FROM takes JOIN course\nON course.course_id = takes.course_id\nGROUP BY COURSE.TITLE;	t	1397.2904524825954	1399.2811181964225	777667	2026-05-09 07:12:37.324496+00	2	t	1467.3892025980024	1465.3985368841752	t
624	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q013	SELECT distinct COUNT(*) FROM takes\nWHERE year = '2009';	f	\N	\N	84590	2026-05-09 07:14:07.139+00	2	f	\N	\N	f
628	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q004	SELECT name\nFROM student, takes\nWHERE student.ID = takes.ID\n  AND takes.course_id = 'Intro. to Computer Science' AND student.tot_cred < 60	f	\N	\N	167759	2026-05-09 07:14:42.111169+00	2	f	\N	\N	f
634	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q019	select dept_name, count(course_id), avg(credits)\nfrom (select dept_name, )\ngroup by dept_name\nhaving avg(credits) > 3	f	1365.8570263225113	1360.6916735503564	473887	2026-05-09 07:18:22.281623+00	2	t	1477.7205458682306	1482.8858986403854	t
641	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q019	SELECT dept_name, count(course_id), avg(credits) FROM course\nGROUP BY dept_name\nHAVING avg(credits) > 3;	f	\N	\N	270423	2026-05-09 07:20:33.861203+00	1	f	\N	\N	f
647	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q001	SELECT *\nFROM student inner join takes on student.ID = takes.ID	f	\N	\N	66522	2026-05-09 07:21:45.770707+00	2	f	\N	\N	f
650	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q018	select dept_name, avg_salary\nfrom ( select dept_name, avg (salary) as avg_salary\nfrom instructor\ngroup by dept_name)\nwhere avg_salary > 150000;	t	1360.6916735503564	1370.9213743554994	282890	2026-05-09 07:23:09.294552+00	1	t	1479.7010877178363	1469.4713869126933	t
659	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q008	SELECT title\nFROM course natural join section\nWHERE section.year = 2009 AND course_id NOT IN (SELECT course_id\nFROM takes\nHAVING COUNT(ID) = 0)	f	\N	\N	169496	2026-05-09 07:27:19.677838+00	1	f	\N	\N	f
83	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q010	select bulding, avg(capacity)\nfrom classroom\ngroup by building\nhaving avg(capacity) > 80	f	\N	\N	0	2026-05-07 08:57:27.484506+00	1	f	\N	\N	f
95	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q010	SELECT building, AVG (capacity)\nFROM classroom\nWHERE capacity in (select AVG (capacity) >80 FROM classroom)	f	1198.4202984878054	1185.0855545554982	0	2026-05-07 09:00:41.944261+00	3	t	1332.22217898439	1332.22217898439	t
96	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q009	SELECT dept_name\nFROM course\nWHERE credits > 10	f	\N	\N	0	2026-05-07 09:01:25.037827+00	1	f	\N	\N	f
618	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q005	SELECT course.title, prereq_course.title as prereq_title\nFROM course natural join course as prereq_course natural join prereq\nWHERE prereq.course_id = course.course_id AND prereq.prereq_id = prereq_course.course_id	f	1486.0741513668922	1470.8119358868134	661577	2026-05-09 07:11:51.494184+00	3	t	1480	1495.2622154800788	f
625	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q004	SELECT name\nFROM student, takes\nWHERE student.ID = takes.ID\n  AND takes.course_id = 'Intro. to Computer Science' AND tot_cred < 60	f	\N	\N	143552	2026-05-09 07:14:17.893682+00	1	f	\N	\N	f
629	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q020	select name, tot_cred,\nCASE \nwhen tot_cred < 30 THEN 'Freshmen'\nwhen tot_cred > 29 AND tot_cred <60 THEN 'Sophomore'\nwhen tot_cred > 59 AND tot_cred <90 THEN 'Junior'\nElse 'Final Year'\nEnd as classification\nfrom student	f	\N	\N	383540	2026-05-09 07:14:55.265344+00	2	f	\N	\N	f
640	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q002	SELECT department.dept_name, COUNT(instructor.ID)\nFROM department natural left outer join instructor\nGROUP BY department.dept_name\nHAVING COUNT(instructor.ID) > 0	f	1455.345297714133	1444.3314733455186	176651	2026-05-09 07:20:25.538257+00	3	t	1420	1431.0138243686145	f
643	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q001	SELECT *\nFROM student inner join takes	f	\N	\N	40033	2026-05-09 07:21:19.332111+00	1	f	\N	\N	f
646	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q012	select dept_name\nfrom instructor\nwhere salary > 90000	t	1348.930863462319	1364.6714578289927	33117	2026-05-09 07:21:40.568371+00	1	t	1362.9378208917371	1347.1972265250633	t
649	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q010	SELECT building, avg(capacity) FROM classroom\nGROUP BY building\nHAVING avg(capacity) > 80;	t	1390.4523590670915	1402.7683839839208	72920	2026-05-09 07:22:44.876614+00	1	t	1311.8119496331071	1299.4959247162778	t
619	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q016	SELECT course.title, count(ID) FROM takes JOIN course\n  where course.course_id = takes.course_id\nGROUP BY COURSE.TITLE;	f	\N	\N	755824	2026-05-09 07:12:15.505007+00	1	f	\N	\N	f
84	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q010	select building, avg(capacity)\nfrom classroom\ngroup by building\nhaving avg(capacity) > 80	t	1340.5886826538433	1341.48579732544	0	2026-05-07 08:57:41.351941+00	2	t	1318.8874350520828	1318.8874350520828	t
86	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT COUNT (DISTINCT course.course_id) as jumlah_course, section.semester\nFROM course, section\nGROUP BY (section.semester)	f	1211.0432253532417	1198.4202984878054	0	2026-05-07 08:57:57.396307+00	3	t	1316.9765430343214	1316.9765430343214	t
87	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q009	select *\nfrom student\nwhere dept_name = 'Comp. Sci.' or dept_name = 'Physics';	t	1262.139242846872	1262.5471159447463	0	2026-05-07 08:58:26.793152+00	3	t	1119.5921269021258	1119.5921269021258	t
88	21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01-Q007	select *\nfrom student\nwhere name like 'Z%';	t	1262.5471159447463	1273.4930893132562	0	2026-05-07 08:58:51.561393+00	1	t	1079.0540266314902	1079.0540266314902	t
630	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q013	SELECT distinct COUNT(*) FROM takes\nWHERE year = 2009;	f	1399.2811181964225	1387.7814120189714	178926	2026-05-09 07:15:41.483434+00	3	t	1346.77999571144	1358.2797018888912	t
633	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q009	select department.dept_name, student.tot_cred\nfrom department, student\nwhere student.tot_cred >10	f	\N	\N	71667	2026-05-09 07:17:53.253616+00	1	f	\N	\N	f
637	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q009	select department.dept_name, student.tot_cred\nfrom department, student\nwhere student.dept_name = department.dept_name\nwhere student.tot_cred >10	f	1345.038703443703	1335.2054584739992	123420	2026-05-09 07:18:45.015877+00	3	t	1350.8329037115711	1360.666148681275	t
644	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q019	SELECT dept_name, count(course_id), avg(credits) FROM course\nGROUP BY dept_name\nHAVING avg(credits) >= 3;	t	1387.7814120189714	1390.4523590670915	324763	2026-05-09 07:21:28.193395+00	2	t	1482.8858986403854	1480.2149515922654	t
652	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q023	select building, sum(budget)\nfrom department\ngroup by building\nhaving sum(budget) > 50000	t	1415.0464087574953	1427.5204605815359	120991	2026-05-09 07:23:36.520578+00	1	t	1524.5690620344178	1512.0950102103773	t
656	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q017	select dept_name\nfrom instructor\ngroup by dept_name\nhaving count(ID) > 2	t	1378.4452118744427	1377.0548832299955	149893	2026-05-09 07:25:08.122421+00	3	t	1411.2811828989088	1412.671511543356	t
89	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q010	SELECT building, AVG (capacity)\nFROM classroom\nWHERE AVG(capacity)>80\nGROUP BY capacity	f	\N	\N	0	2026-05-07 08:59:19.441355+00	1	f	\N	\N	f
661	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q016	select course.title, takes.count(ID)\nfrom course, takes\nwhere takes.course_id = section.course_id and section.course_id = course.course_id	f	\N	\N	147506	2026-05-09 07:27:37.415978+00	1	f	\N	\N	f
665	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q008	SELECT title\nFROM course natural join section natural join takes\nWHERE section.year = 2009 AND course_id NOT IN (SELECT course_id\nFROM takes\nGROUP BY course_id\nHAVING COUNT(ID) > 0)	f	1455.3009635205835	1447.6916250484994	259995	2026-05-09 07:28:50.128786+00	3	t	1540	1547.6093384720841	f
668	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q022	select dept_name, avg(credits) as avg_cred \nfrom course\ngroup by dept_name\norder by avg_cred desc\nlimit 3	f	\N	\N	172111	2026-05-09 07:29:12.189393+00	1	f	\N	\N	f
671	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q023	select building, sum(budget)\nfrom department\ngroup by building\nhaving budget > 50000	f	\N	\N	94321	2026-05-09 07:30:31.117284+00	1	f	\N	\N	f
675	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q015	select instructor.ID, count(course.course_ID)\nfrom instructor, course\nwhere instructor.ID = department.dept_name and department.dept_name = course.course_ID	f	\N	\N	103468	2026-05-09 07:31:10.861908+00	1	f	\N	\N	f
678	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q006	SELECT title\nFROM course\nGROUP BY title\nHAVING credits > AVG(credits)	f	1447.6916250484994	1439.1859078301195	173567	2026-05-09 07:31:45.566764+00	3	t	1500	1508.50571721838	f
94	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q010	SELECT building, AVG (capacity)\nFROM classroom\nWHERE capacity in (select AVF (capacity) >80 FROM classroom)	f	\N	\N	0	2026-05-07 09:00:33.77196+00	2	f	\N	\N	f
126	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q005	select s.semester, min(c.credits)\nfrom section s, course c\nwhere s.course_id = c.course_id\ngroup by s.semester;	t	1272.9676904383145	1287.8799637467907	0	2026-05-07 09:11:36.764596+00	1	t	1260.0873985932692	1260.0873985932692	f
97	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q014	select avg(tot_cred)\nfrom student\nwhere tot_cred > 50	t	1354.829783203847	1368.103182301789	0	2026-05-07 09:01:37.911548+00	1	t	1381.726600902058	1381.726600902058	t
98	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q008	select avg(budget)\nfrom section s, course c\nwhere s.course_id = c.course_id and building ='Taylor';	f	\N	\N	0	2026-05-07 09:01:58.872511+00	1	f	\N	\N	f
99	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q008	select avg(budget)\nfrom section s, course c, department d\nwhere s.course_id = c.course_id and d.dept_name = c.dept_name and s.building ='Taylor';	f	\N	\N	0	2026-05-07 09:02:40.834756+00	2	f	\N	\N	f
116	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q011	SELECT COUNT (DISTINCT ID)\nFROM instructor\nGROUP BY instructor\nORDER BY instructor DESC	f	1165.0868725798246	1153.222207072528	0	2026-05-07 09:09:35.02186+00	3	t	1408.140185553377	1408.140185553377	t
102	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q008	select avg(budget), dept_name\nfrom department\nwhere building ='Taylor';	f	1308.820361670591	1293.9934030611842	0	2026-05-07 09:03:25.731318+00	3	t	1319.6390933427951	1319.6390933427951	t
100	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q012	select d.dept_name\nfrom department d, instructor i\ngroup by d.department\nhaving max(i.salary);	f	1339.7923196677448	1323.0460362220638	0	2026-05-07 09:02:53.436522+00	3	t	1397.1709068239657	1397.1709068239657	f
118	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q007	select count(course_id) as jumlah_course, semester\nfrom section\ngroup by year;	f	\N	\N	0	2026-05-07 09:09:45.250653+00	2	f	\N	\N	f
101	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q009	SELECT dept_name\nFROM course\nWHERE (credits > 10) in\n(select COUNT (credits) from course)	f	1185.0855545554982	1171.4076545339617	0	2026-05-07 09:03:08.029314+00	2	t	1332.8266807345383	1332.8266807345383	t
103	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q006	select sum(credits)\nfrom department d, course c\nwhere d.dept_name = c.dept_name and \nGROUP BY c.dept_name;	f	\N	\N	0	2026-05-07 09:04:40.26328+00	1	f	\N	\N	f
104	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q015	select ID, count(course_id)\nfrom teaches\ngroup by course_id	f	\N	\N	0	2026-05-07 09:04:47.469517+00	1	f	\N	\N	f
105	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q006	select sum(credits), dept_name\nfrom department d, course c\nwhere d.dept_name = c.dept_name and \nGROUP BY c.dept_name;	f	\N	\N	0	2026-05-07 09:05:20.419226+00	2	f	\N	\N	f
106	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT (DISTINCT ID)\nFROM takes\nWHERE year='2009'	f	\N	\N	0	2026-05-07 09:06:02.123245+00	1	f	\N	\N	f
107	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT DISTINCT ID\nFROM takes\nWHERE year='2009'	f	\N	\N	0	2026-05-07 09:06:17.463962+00	2	f	\N	\N	f
108	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q006	select dept_name, sum (credits)\nfrom course\ngroup by dept_name;	t	1293.9934030611842	1289.1658181155594	0	2026-05-07 09:06:36.98984+00	3	t	1294.8272704262624	1294.8272704262624	t
120	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q009	select d.dept_name\nfrom d.department, student s\ngroup by d.department\nhaving sum(s.tot_cred)>100;	f	\N	\N	0	2026-05-07 09:10:25.417653+00	1	f	\N	\N	f
109	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT COUNT (DISTINCT ID)\nFROM takes\nWHERE year='2009'	t	1171.4076545339617	1165.0868725798246	0	2026-05-07 09:06:37.449993+00	3	t	1372.9767960757301	1372.9767960757301	t
110	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q015	select instructor.ID, count(course_id)\nfrom instructor join on teaches\ngroup by course_id	f	\N	\N	0	2026-05-07 09:07:16.679216+00	2	f	\N	\N	f
111	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q008	select avg(budget)\nfrom department\nwhere buiding = 'Taylor';	f	\N	\N	0	2026-05-07 09:07:20.488792+00	1	f	\N	\N	f
129	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q011	select count(ID)\nfrom instructor\ngroup by dept_name\norder by count(ID) desc	f	1356.9031063472232	1345.4389832415382	0	2026-05-07 09:14:10.926827+00	3	t	1419.604308659062	1419.604308659062	t
112	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q008	select avg(budget)\nfrom department\nwhere building = 'Taylor';	t	1323.0460362220638	1323.1931210555513	0	2026-05-07 09:07:28.713034+00	2	t	1319.4920085093077	1319.4920085093077	t
119	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q007	select count(s.course_id) as jumlah_course, s.year, s.semester\nfrom section s\ngroup by semester;	f	1289.1658181155594	1272.9676904383145	0	2026-05-07 09:10:21.712812+00	3	t	1333.1746707115663	1333.1746707115663	t
113	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q015	select instructor.ID, count(course_id)\nfrom instructor, teaches\ngroup by course_id	f	1368.103182301789	1356.9031063472232	0	2026-05-07 09:07:47.895876+00	3	t	1421.2000759545658	1421.2000759545658	t
114	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q011	SELECT COUNT (DISTINCT ID.instructor)\nFROM instructor\nGROUP BY instructor DESC	f	\N	\N	0	2026-05-07 09:08:01.232898+00	1	f	\N	\N	f
115	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q011	SELECT COUNT (DISTINCT ID.instructor)\nFROM instructor\nGROUP BY instructor\nORDER BY instructor DESC	f	\N	\N	0	2026-05-07 09:08:36.563048+00	2	f	\N	\N	f
117	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q007	select sum(course_id) as jumlah_course, semester\nfrom section\ngroup by year;	f	\N	\N	0	2026-05-07 09:09:37.156402+00	1	f	\N	\N	f
121	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q011	select count(ID)\nfrom instructor\ngroup by dept_name\norder by count(ID)	f	\N	\N	0	2026-05-07 09:10:30.720908+00	1	f	\N	\N	f
122	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q011	select count(ID)\nfrom instructor\ngroup by dept_name\norder by count(ID) desc	f	\N	\N	0	2026-05-07 09:10:39.970844+00	2	f	\N	\N	f
123	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q009	select d.dept_name\nfrom d.department, student s\ngroup by d.dept_name\nhaving sum(s.tot_cred)>100;	f	\N	\N	0	2026-05-07 09:10:55.12452+00	2	f	\N	\N	f
125	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q009	select d.dept_name\nfrom department d, student s\ngroup by d.dept_name\nhaving sum(s.tot_cred)>100;	f	1323.1931210555513	1312.9159159558706	0	2026-05-07 09:11:23.852201+00	3	t	1343.103885834219	1343.103885834219	t
124	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q014	SELECT AVG (tot_cred)\nFROM student\nWHERE tot_cred>50	t	1153.222207072528	1156.3960340313006	0	2026-05-07 09:11:20.112663+00	1	t	1378.5527739432853	1378.5527739432853	t
127	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q004	select dept_name, max(credits) as max_sks\nfrom course\ngroup by dept_name;	f	\N	\N	0	2026-05-07 09:12:42.77144+00	1	f	\N	\N	f
128	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q012	SELECT dept_name\nFROM instructor\nWHERE salary > 90000	t	1156.3960340313006	1159.396712758403	0	2026-05-07 09:12:43.03445+00	1	t	1394.1702280968632	1394.1702280968632	t
139	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q015	SELECT instructor.ID, COUNT teaches.count_id\nFROM instructor\nWHERE instructor.ID=teaches.id	f	\N	\N	0	2026-05-07 09:18:57.879846+00	1	f	\N	\N	f
130	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q016	SELECT course.title, COUNT(DISTINCT takes.id)\nFROM takes\nJOIN section ON section.course_id = takes.course_id\nJOIN course ON section.course_id = course.course_id	f	\N	\N	0	2026-05-07 09:16:42.782381+00	1	f	\N	\N	f
131	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q004	select name, department, max(credits) as max_sks\nfrom student\ngroup by department	f	\N	\N	0	2026-05-07 09:16:47.432404+00	2	f	\N	\N	f
133	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q007	select count(s.course_id) as jumlah_course\nfrom course c, section s\ngroup by s.semester;	f	\N	\N	0	2026-05-07 09:17:02.341882+00	1	f	\N	\N	f
132	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q004	select name, dept_name, max(credits) as max_sks\nfrom student\ngroup by dept_name	f	1287.8799637467907	1274.266640729718	0	2026-05-07 09:17:00.602838+00	3	t	1269.2825894353114	1269.2825894353114	t
134	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q016	SELECT course.title, COUNT(DISTINCT takes.id)\nFROM takes\nJOIN section ON section.course_id = takes.course_id\nJOIN course ON section.course_id = course.course_id\nGROUP BY (course.title)	f	\N	\N	0	2026-05-07 09:17:07.774904+00	2	f	\N	\N	f
142	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q015	SELECT instructor.ID, COUNT teaches.count_id\nFROM instructor\nWHERE instructor.ID=teaches.ID	f	\N	\N	0	2026-05-07 09:19:12.061615+00	2	f	\N	\N	f
146	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q003	select dept_name, avg(tot_cred)\nfrom student\ngroup by dept_name;	t	1262.9722524633924	1273.507660731166	0	2026-05-07 09:20:02.977057+00	1	t	1233.817050114803	1233.817050114803	f
662	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q020	select name, tot_cred, case when \ntot_cred < 30 then 'Freshman' when tot_cred >=30 and tot_cred < 60 then 'Sophomore' else 'Final Year' end as classification\nfrom student	f	\N	\N	269706	2026-05-09 07:27:40.924638+00	2	f	\N	\N	f
147	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q007	select semester, year, count(course_id) as jumlah_course\nfrom section\ngroup by semester, year	t	1345.4389832415382	1342.4584986539494	0	2026-05-07 09:20:16.266183+00	3	t	1336.155155299155	1336.155155299155	t
148	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q010	select building, avg(capacity)\nfrom classroom\nwhere avg(capacity) > 80	f	\N	\N	0	2026-05-07 09:21:18.677569+00	1	f	\N	\N	f
669	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q016	select course.title, count(takes.ID)\nfrom course, takes\ngroup by tittle\nwhere takes.course_id = course.course_id	f	1377.0548832299955	1369.5441989076667	255595	2026-05-09 07:29:25.521743+00	3	t	1465.3985368841752	1472.909221206504	t
672	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q022	select dept_name, avg(tot_cred) as avg_cred \nfrom mahasiswa\ngroup by dept_name\norder by avg_cred desc\nlimit 3	f	\N	\N	253423	2026-05-09 07:30:33.527105+00	2	f	\N	\N	f
677	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q006	SELECT title\nFROM course\nHAVING credits > AVG(credits)	f	\N	\N	160339	2026-05-09 07:31:32.315679+00	2	f	\N	\N	f
135	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q016	SELECT course.title, COUNT(takes.id)\nFROM takes\nJOIN section ON section.course_id = takes.course_id\nJOIN course ON section.course_id = course.course_id\nGROUP BY (course.title)	f	1159.396712758403	1147.0689552473777	0	2026-05-07 09:17:26.679226+00	3	t	1437.3277575110253	1437.3277575110253	t
136	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q008	select c.dept_name, avg (budget)\nfrom section s, course c\nwhere s.course_id = c.course_id and building = 'Taylor'\ngroup by c.dept_name;	f	\N	\N	0	2026-05-07 09:18:39.920225+00	1	f	\N	\N	f
137	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q007	select count(course_id) as jumlah_course\nfrom section\ngroup by semester, year	f	\N	\N	0	2026-05-07 09:18:43.286813+00	1	f	\N	\N	f
138	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q008	select c.dept_name, avg (s.budget)\nfrom section s, course c\nwhere s.course_id = c.course_id and building = 'Taylor'\ngroup by c.dept_name;	f	\N	\N	0	2026-05-07 09:18:47.312327+00	2	f	\N	\N	f
144	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q015	SELECT instructor.ID, COUNT teaches.count_ID\nFROM instructor\nWHERE instructor.ID=teaches.ID	f	1147.0689552473777	1134.6350845943575	0	2026-05-07 09:19:23.841016+00	3	t	1433.633946607586	1433.633946607586	t
663	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q023	SELECT building, sum(budget) FROM department\nGROUP BY building\nHAVING sum(budget) > 50000;	t	1417.0800707845578	1434.3912841613655	67867	2026-05-09 07:27:49.23396+00	1	t	1512.0950102103773	1494.7837968335693	t
143	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q008	select dept_name, avg (budget)\nfrom department \nwhere building = 'Taylor'\ngroup by dept_name;	f	1274.266640729718	1262.9722524633924	0	2026-05-07 09:19:22.608509+00	3	t	1330.7863967756332	1330.7863967756332	t
145	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q017	SELECT dept_name\nFROM instructor\nWHERE	f	1134.6350845943575	1121.8410349869298	0	2026-05-07 09:19:58.87298+00	1	t	1452.7940496074277	1452.7940496074277	t
149	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q004	select dept_name, max(tot_cred) as max_sks\nfrom student\ngroup by dept_name	t	1342.4584986539494	1354.5340704904024	0	2026-05-07 09:21:51.690665+00	1	t	1257.2070175988583	1257.2070175988583	t
150	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q018	SELECT AVG (instructor.salary)\nFROM instructor\nJOIN department on department.dept_name = instructor.dept_name\nWHERE department.budget>150000	f	\N	\N	0	2026-05-07 09:21:57.541169+00	1	f	\N	\N	f
151	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q010	select building, avg(capacity)\nfrom classroom\nhaving avg(capacity) > 80;	f	\N	\N	0	2026-05-07 09:22:18.255787+00	2	f	\N	\N	f
152	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q018	SELECT AVG (instructor.salary)\nFROM instructor\nWHERE department.budget>150000	f	\N	\N	0	2026-05-07 09:22:19.153606+00	2	f	\N	\N	f
161	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q002	SELECT COUNT (DISTINCT ID) as jumlah_mhs, dept_name\nfrom student	f	\N	\N	0	2026-05-07 09:25:11.463542+00	1	f	\N	\N	f
666	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q020	select name, tot_cred, case \nwhen tot_cred < 30 then 'Freshman'\nwhen tot_cred >=30 and tot_cred < 60 then 'Sophomore'\nwhen tot_cred >=60 and tot_cred <90 then 'Junior'\nelse 'Final Year' end as classification\nfrom student	t	1370.9213743554994	1370.9509401690905	344133	2026-05-09 07:28:55.364677+00	3	t	1492.8764963017065	1492.8469304881155	t
162	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q002	SELECT COUNT (DISTINCT ID) as jumlah_mhs, dept_name\nfrom student\nGROUP BY dept_name	t	1095.4292674545254	1090.520062245582	0	2026-05-07 09:25:22.491428+00	2	t	1218.389892125946	1218.389892125946	t
674	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q023	select building, sum(budget)\nfrom department\ngroup by building\nhaving sum(budget) > 50000	t	1370.9509401690905	1374.8622834814662	120544	2026-05-09 07:30:57.316881+00	2	t	1494.7837968335693	1490.8724535211936	t
676	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q006	SELECT title\nFROM course\nWHERE course > AVG(credits)	f	\N	\N	143042	2026-05-09 07:31:15.034372+00	1	f	\N	\N	f
140	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q007	select count(s.course_id) as jumlah_course, s.semester, s.year\nfrom course c, section s\ngroup by s.semester, s.year;	f	\N	\N	0	2026-05-07 09:19:07.637408+00	2	f	\N	\N	f
664	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q008	SELECT title\nFROM course natural join section natural join takes\nWHERE section.year = 2009 AND course_id NOT IN (SELECT course_id\nFROM takes\nGROUP BY course_id\nHAVING COUNT(ID) = 0)	f	\N	\N	224068	2026-05-09 07:28:14.18592+00	2	f	\N	\N	f
156	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q019	SELECT	f	1108.7626126635296	1095.4292674545254	0	2026-05-07 09:23:27.35451+00	1	t	1483.3333452090042	1483.3333452090042	t
667	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q016	select course.title, count(takes.ID)\nfrom course, takes\nwhere takes.course_id = course.course_id	f	\N	\N	238092	2026-05-09 07:29:08.018091+00	2	f	\N	\N	f
141	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q007	select count(course_id) as jumlah_course\nfrom section\ngroup by year, semester	f	\N	\N	0	2026-05-07 09:19:09.832167+00	2	f	\N	\N	f
670	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q022	SELECT dept_name, avg(tot_cred) AS avg_cred FROM student\nGROUP BY dept_name\nORDER BY avg_cred desc\nLIMIT 3;	t	1434.3912841613655	1451.1667603699636	95848	2026-05-09 07:29:27.103528+00	1	t	1530.3002338108504	1513.5247576022523	t
673	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q022	select dept_name, avg(tot_cred) as avg_cred \nfrom student\ngroup by dept_name\norder by avg_cred desc\nlimit 3	t	\N	\N	261505	2026-05-09 07:30:41.575268+00	3	t	\N	\N	f
170	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q016	select title, count(student.id)\nfrom course, takes, student\ngroup by title	f	1356.2358506672908	1343.9433170324423	0	2026-05-07 09:27:17.615664+00	3	t	1449.6202911458738	1449.6202911458738	t
153	28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q018	SELECT AVG (instructor.salary)\nFROM instructor\nWHERE department.budget>150000\nJOIN department on department.dept_name = instructor.dept_name	f	1121.8410349869298	1108.7626126635296	0	2026-05-07 09:22:31.706261+00	3	t	1468.0784223234002	1468.0784223234002	t
183	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q004	select dept_name, max(tot_cred) as max_sks \nfrom student\ngroup by dept_name	t	1327.8841123787895	1339.2901186040522	0	2026-05-07 09:31:58.811829+00	1	t	1267.302678343362	1267.302678343362	t
154	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q010	select building, avg(capacity)\nfrom classroom\nhaving avg(capacity) > 80\ngroup by building;	f	1273.507660731166	1261.8336270124607	0	2026-05-07 09:22:35.453717+00	3	t	1343.8962127030952	1343.8962127030952	t
155	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q006	select sum(credits)\nfrom course\ngroup by dept_name	f	\N	\N	0	2026-05-07 09:23:21.336393+00	1	f	\N	\N	f
172	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q013	select count(distinct id)\nfrom takes\nwhere year = 2009;	t	1284.9873985168688	1279.1743164068716	0	2026-05-07 09:27:22.648252+00	3	t	1378.7898781857273	1378.7898781857273	t
157	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q002	select dept_name, count(ID) as jumlah_mhs\nfrom student\ngroup by dept_name;	t	1261.8336270124607	1272.902644189395	0	2026-05-07 09:23:40.347423+00	1	t	1213.4806869170027	1213.4806869170027	t
174	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q004	SELECT MAX (credits) as max_sks, dept_name\nFROM course\nGROUP BY dept_name	f	\N	\N	0	2026-05-07 09:27:34.144791+00	2	f	\N	\N	f
158	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q007	select s.semester, s.year, count(s.course_id) as jumlah_course\nfrom section s\ngroup by s.semester, s.year;	t	1312.9159159558706	1308.9146992844703	0	2026-05-07 09:23:43.271347+00	3	t	1340.1563719705553	1340.1563719705553	t
159	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q006	select dept_name, sum(credits)\nfrom course\ngroup by dept_name	t	1354.5340704904024	1356.2358506672908	0	2026-05-07 09:23:54.417635+00	2	t	1293.125490249374	1293.125490249374	t
181	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q003	SELECT AVG (tot_cred), dept_name\nFROM student\nGROUP BY dept_name	t	1074.4499966781448	1068.0146935386022	0	2026-05-07 09:29:43.165662+00	2	t	1240.2523532543455	1240.2523532543455	t
160	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q001	select count(ID)\nfrom student;	t	1272.902644189395	1284.9873985168688	0	2026-05-07 09:24:03.269641+00	1	t	1187.308519056735	1187.308519056735	t
163	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q002	SELECT COUNT (DISTINCT ID), dept_name\nFROM student\nGROUP BY dept_name	f	\N	\N	0	2026-05-07 09:26:10.845749+00	1	f	\N	\N	f
164	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q013	select distinct id\nfrom takes\nwhere year = '2009';	f	\N	\N	0	2026-05-07 09:26:13.450621+00	1	f	\N	\N	f
165	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q013	select distinct count(id)\nfrom takes\nwhere year = 2009;	f	\N	\N	0	2026-05-07 09:26:34.789772+00	2	f	\N	\N	f
167	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q016	select title, count(student.id)\nfrom course, takes, student\ngroup by course_id	f	\N	\N	0	2026-05-07 09:26:45.170739+00	1	f	\N	\N	f
175	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q014	select avg(tot_cred)\nfrom student\nwhere tot_cred > 50;	t	1279.1743164068716	1286.3895102550573	0	2026-05-07 09:27:51.535121+00	1	t	1371.3375800950996	1371.3375800950996	t
166	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q002	SELECT COUNT (DISTINCT ID) as jumlah_mhs, dept_name\nFROM student\nGROUP BY dept_name	t	1090.520062245582	1085.2359339899217	0	2026-05-07 09:26:44.852738+00	2	t	1223.6740203816064	1223.6740203816064	t
168	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q016	select title, count(student.id)\nfrom course, takes, student\ngroup by takes.course_id	f	\N	\N	0	2026-05-07 09:26:56.883337+00	2	f	\N	\N	f
169	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q001	SELECT COUNT(DISTINCT ID)\nfrom student	t	1085.2359339899217	1095.9516636479111	0	2026-05-07 09:27:03.159084+00	1	t	1176.5927893987455	1176.5927893987455	t
173	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q004	SELECT MAX (credits) as max_sks, dept_name\nFROM course	f	\N	\N	0	2026-05-07 09:27:24.248076+00	1	f	\N	\N	f
171	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q006	select sum(credits), dept_name\nfrom course\ngroup by dept_name;	t	1308.9146992844703	1319.3688366590432	0	2026-05-07 09:27:22.328936+00	1	t	1282.6713528748012	1282.6713528748012	t
176	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q012	select dept_name\nfrom instructor\nwhere salary > 90000;	t	1286.3895102550573	1293.3831576158427	0	2026-05-07 09:28:21.168287+00	1	t	1387.1765807360778	1387.1765807360778	t
182	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q005	SELECT MIN (course.credits), section.semester\nFROM course\nJOIN section ON section.course_id = course.course_id\nGROUP BY section.semester	t	1068.0146935386022	1075.4751235910305	0	2026-05-07 09:31:41.948826+00	1	t	1252.6269685408408	1252.6269685408408	t
177	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q004	SELECT dept_name, MAX (credits) as max_sks\nFROM course\nGROUP BY dept_name	f	1095.9516636479111	1074.4499966781448	0	2026-05-07 09:28:24.847345+00	3	t	1278.7086845686247	1278.7086845686247	t
178	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q017	select dept_name\nfrom instructor\ngroup by dept_name\nhaving count(id) > 2	t	1343.9433170324423	1350.9089764217083	0	2026-05-07 09:29:09.739597+00	1	t	1445.8283902181618	1445.8283902181618	t
179	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q014	select avg(tot_cred)\nfrom student\nwhere tot_cred > 50;	t	1319.3688366590432	1327.8841123787895	0	2026-05-07 09:29:13.84478+00	1	t	1362.8223043753533	1362.8223043753533	t
180	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q003	SELECT AVG (tot_cred), dept_name\nFROM student	f	\N	\N	0	2026-05-07 09:29:29.336547+00	1	f	\N	\N	f
189	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q015	select id, count(course_id)\nfrom teaches\ngroup by id;	t	1299.9020387319977	1306.2323877636002	0	2026-05-07 09:33:52.528808+00	1	t	1427.3035975759835	1427.3035975759835	t
184	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q005	select semester, min(credits)\nfrom section, course\ngroup by semester	t	1350.9089764217083	1360.4757286823685	0	2026-05-07 09:31:59.067605+00	1	t	1243.0602162801806	1243.0602162801806	t
187	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q006	SELECT SUM (credits), dept_name\nFROM course\nGROUP BY dept_name	t	1081.084816480088	1088.2425164571937	0	2026-05-07 09:33:31.417609+00	1	t	1275.5136528976955	1275.5136528976955	t
185	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q008	SELECT AVG (budget)\nFROM department\nWHERE building='Taylor'	t	1075.4751235910305	1081.084816480088	0	2026-05-07 09:32:42.15955+00	1	t	1325.1767038865758	1325.1767038865758	t
188	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q018	select avg(salary)\nfrom instructor, department\nwhere budget > 150000\ngroup by dept_name	f	\N	\N	0	2026-05-07 09:33:50.99121+00	1	f	\N	\N	f
186	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q011	select dept_name, count(id)\nfrom instructor\ngroup by dept_name\norder by count(id) desc;	t	1293.3831576158427	1299.9020387319977	0	2026-05-07 09:33:11.860122+00	1	t	1413.0854275429072	1413.0854275429072	t
190	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q018	select avg(salary)\nfrom instructor, department\nwhere budget > 150000\ngroup by instructor.dept_name	t	1360.4757286823685	1358.2244603696608	0	2026-05-07 09:34:11.238455+00	2	t	1470.329690636108	1470.329690636108	t
191	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q015	select t.id, count(t.course_id)\nfrom teaches t join section s\nwhere t.course_id=s.course_id;	f	\N	\N	0	2026-05-07 09:35:16.723577+00	1	f	\N	\N	f
192	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q003	select dept_name, avg(tot_cred)\nfrom student\ngroup by dept_name	t	1358.2244603696608	1368.1775341519087	0	2026-05-07 09:35:23.10833+00	1	t	1230.2992794720976	1230.2992794720976	t
193	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q015	select t.id, count(t.course_id)\nfrom teaches t join section s\non t.course_id=s.course_id;	f	\N	\N	0	2026-05-07 09:35:33.247742+00	2	f	\N	\N	f
202	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT COUNT (DISTINCT course.ID) as jumlah_course, section.semester\nFROM course \nJOIN section ON section.course_id = course.course_id\nGROUP BY semester	f	\N	\N	0	2026-05-07 09:41:44.17779+00	1	f	\N	\N	f
195	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q009	select dept_name\nfrom course\nhaving sum(credits) > 10\ngroup by dept_name;	f	\N	\N	0	2026-05-07 09:36:36.246947+00	1	f	\N	\N	f
196	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q009	select dept_name\nfrom course\nhaving sum(credits) > 10;	f	\N	\N	0	2026-05-07 09:36:51.937072+00	2	f	\N	\N	f
197	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q009	select dept_name, sum(credits)\nfrom course\nhaving sum(credits) > 10\ngroup by dept_name;	f	1306.2323877636002	1297.939427157551	0	2026-05-07 09:37:27.666354+00	3	t	1351.396846440268	1351.396846440268	t
194	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q015	select t.id, count(t.course_id)\nfrom teaches t join section s\non t.course_id=s.course_id\ngroup by t.id;	f	1339.2901186040522	1326.8097193407266	0	2026-05-07 09:36:16.077741+00	3	t	1439.783996839309	1439.783996839309	t
198	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q009	SELECT dept_name, SUM (credits)\nFROM course\nHAVING SUM (credits) > 10\nGROUP BY dept_name	f	\N	\N	0	2026-05-07 09:39:00.620032+00	1	f	\N	\N	f
679	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q010	SELECT dept_name\nFROM course\nWHERE EXISTS (SELECT course_id FROM course WHERE credits > 4)	t	1439.1859078301195	1453.0306167148826	22601341	2026-05-09 13:48:29.795731+00	1	t	1580	1566.1552911152369	f
199	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q009	SELECT dept_name, SUM (credits)\nFROM course\nGROUP BY dept_name\nHAVING SUM (credits) > 10	t	1088.2425164571937	1081.8469743463183	0	2026-05-07 09:39:13.204979+00	2	t	1357.7923885511434	1357.7923885511434	t
682	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q009	SELECT name\nFROM instructor as i\nWHERE salary > (SELECT AVG(salary) FROM instructor WHERE instructor.dept_name = i.dept_name)	f	\N	\N	273340	2026-05-09 13:55:16.780874+00	2	f	\N	\N	f
200	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q010	SELECT building, AVG (capacity)\nfrom classroom\nGROUP BY building\nHAVING AVG (capacity) > 80	t	1081.8469743463183	1085.4702675386845	0	2026-05-07 09:40:14.698059+00	1	t	1340.272919510729	1340.272919510729	t
201	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q016	select c.title, count(t.id)\nfrom takes t, section s, course c\nwhere t.course_id = s.course_id and c.course_id = s.course_id\ngroup by c.title;	f	\N	\N	0	2026-05-07 09:41:18.901455+00	1	f	\N	\N	f
208	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q017	select dept_name, count(id)\nfrom instructor\ngroup by dept_name\nhaving count(id) > 2;	f	1294.8584311256798	1284.2902021709533	0	2026-05-07 09:44:07.011834+00	3	t	1456.3966191728882	1456.3966191728882	t
686	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q012	SELECT room_no, capacity\nFROM classroom\nWHERE capacity > 100\nEXCEPT\nSELECT room_no, capacity\nFROM classroom\nWHERE building = 'Watson'	f	1464.918682516911	1460.5604494644335	167739	2026-05-09 13:58:49.128061+00	3	t	1620	1624.3582330524775	f
209	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q018	select dept_name, avg(salary)\nfrom instructor\ngroup by dept_name\nhaving avg(salary) > 150000;	t	1284.2902021709533	1288.1185978945523	0	2026-05-07 09:45:22.702685+00	1	t	1466.501294912509	1466.501294912509	t
693	e8d258a4-1fb5-45c2-899e-0e2f54c512b5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q006	SELECT title, credits\nFROM course\nWHERE credits > (SELECT AVG(credits) FROM course)	f	\N	\N	98304	2026-05-09 14:08:04.695933+00	2	f	\N	\N	f
210	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q020	SELECT name, tot_cred,\nCASE\n  WHEN tot_cred < 30 then 'Freshman'\n  when tot_cred between 30 and 59 then 'Sophomore'\n  when tot_cred between 60 and 89 then 'Junior'\n  else 'Final Year'\nEND AS classification\nFROM student	t	1368.1775341519087	1365.746646402724	0	2026-05-07 09:45:56.744549+00	2	t	1487.4308877491846	1487.4308877491846	t
697	e8d258a4-1fb5-45c2-899e-0e2f54c512b5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q005	SELECT a.title AS course_title, b.title AS prereq_course\nFROM course a, course b, prereq\nWHERE a.course_id = prereq.course_id\n  AND b.course_id = prereq.prereq_id	f	1485.8866468379301	1471.291324450998	208087	2026-05-09 14:12:14.65409+00	3	t	1495.2622154800788	1509.857537867011	f
701	45255620-ee2d-4366-9928-6d61c7357bd5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q018	SELECT dept_name, AVG(salary)\nFROM instructor\nWHERE dept_name IN (SELECT dept_name FROM department WHERE budget>150000)\nGROUP BY dept_name	t	1454.5601532889318	1476.5519552301737	57819	2026-05-09 14:16:05.251889+00	1	t	1448.2215751517658	1426.229773210524	f
704	b27a3d1f-a57f-4d8c-80f9-1dadb582f928	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q020	SELECT name, tot_cred,\nCASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore'\n  WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior'\n  ELSE 'Final Year'\nEND AS classification\nFROM student	t	1499.8006409546701	1502.2306902209866	117985	2026-05-09 14:19:08.864584+00	2	t	1492.8469304881155	1490.416881221799	f
707	c93d1c20-c6af-4341-9947-119e01a1fd76	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q022	SELECT dept_name, AVG(tot_cred) AS avg_cred\nFROM student\nGROUP BY dept_name\nORDER BY avg_cred DESC\nLIMIT 3	t	1506.3211076278014	1529.342543084973	37099	2026-05-09 14:21:04.089456+00	1	t	1509.4343401954375	1486.412904738266	f
203	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT COUNT (DISTINCT course.course_id) as jumlah_course, section.semester\nFROM course \nJOIN section ON section.course_id = course.course_id\nGROUP BY semester	f	\N	\N	0	2026-05-07 09:42:05.143551+00	2	f	\N	\N	f
204	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q020	SELECT name, tot_cred, classification\nCASE\n  WHEN tot_cred < 30 then 'Freshman'\n  when tot_cred between 30 and 59 then 'Sophomore'\n  when tot_cred between 60 and 89 then 'Junior'\n  else 'Final Year'\nEND AS classification\nFROM student;	f	\N	\N	0	2026-05-07 09:42:35.219314+00	1	f	\N	\N	f
205	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q016	select c.title, count(t.id)\nfrom takes t, course c\nwhere t.course_id = c.course_id\ngroup by c.title;	t	1297.939427157551	1294.8584311256798	0	2026-05-07 09:42:55.363599+00	2	t	1452.7012871777451	1452.7012871777451	t
206	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q017	select dept_name\nfrom instructor\nhaving count(id) > 2;	f	\N	\N	0	2026-05-07 09:43:34.577332+00	1	f	\N	\N	f
207	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q017	select dept_name, count(id)\nfrom instructor\nhaving count(id) > 2\ngroup by dept_name;	f	\N	\N	0	2026-05-07 09:43:53.184697+00	2	f	\N	\N	f
211	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q019	select dept_name, avg(credits)\nfrom course\ngroup by dept_name\nhaving avg(credits) > 3;	f	\N	\N	0	2026-05-07 09:47:08.203316+00	1	f	\N	\N	f
680	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q011	SELECT name\nFROM student\nWHERE dept_name = 'Physics'\nUNION\nSELECT name\nFROM student\nWHERE dept_name = 'Elec. Eng.'	t	1453.0306167148826	1470.5288842044001	124819	2026-05-09 13:50:39.918805+00	1	t	1600	1582.5017325104825	f
214	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q019	select dept_name, count(course_id)\nfrom course\ngroup by dept_name\nhaving avg(credits) > 3;	f	1288.1185978945523	1276.7983532389776	0	2026-05-07 09:47:44.988643+00	3	t	1494.6535898645789	1494.6535898645789	t
216	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q014	SELECT AVG (tot_cred)\nFROM student\nGROUP BY tot_cred\nHAVING tot_cred > 50	f	\N	\N	0	2026-05-07 09:48:03.472257+00	2	f	\N	\N	f
219	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q014	SELECT AVG (tot_cred)\nFROM student\nWHERE tot_cred > 50	t	1069.2210171280112	1059.002924783212	0	2026-05-07 09:51:21.643337+00	3	t	1373.0403967201526	1373.0403967201526	t
220	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q021	select time_slot_id, count(course_id)\nfrom time_slot left join section on section.time_slot_id = time_slot.time_slot_id\ngroup by time_slot_id\nhaving count(course_id) <> 0	f	\N	\N	0	2026-05-07 09:51:35.618937+00	1	f	\N	\N	f
230	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q005	select s.semester, count(c.course_id)\nfrom section s, course c\nwhere c.credits = 2\ngroup by s.semester;	f	\N	\N	0	2026-05-07 09:54:35.505499+00	2	f	\N	\N	f
690	9f090bc2-52c7-4dbf-af83-414d3ecc3bb3	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q016	SELECT course.title, COUNT(takes.ID)\nFROM course, takes\nWHERE course.course_id = takes.course_id\nGROUP BY course.title	t	1481.810261225361	1477.53103649016	189502	2026-05-09 14:05:12.431677+00	3	t	1472.909221206504	1477.1884459417051	f
694	e8d258a4-1fb5-45c2-899e-0e2f54c512b5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q006	SELECT title\nFROM course\nWHERE credits > AVG(credits)	f	1500.5429256720186	1485.8866468379301	134797	2026-05-09 14:08:41.208559+00	3	t	1508.50571721838	1523.1619960524683	f
705	f23eeb8d-9d08-4535-b6ee-d317d0c2c443	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q022	SELECT dept_name, AVG(tot_cred)\nFROM student\nGROUP BY dept_name\nORDER BY AVG(tot_cred) desc\nLIMIT 3	f	\N	\N	45942	2026-05-09 14:20:03.518839+00	1	f	\N	\N	f
244	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q020	SELECT name, tot_cred\nCASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred >= 30 and tot_cred <= 59 THEN 'Sophomore'\n  WHEN tot_cred >= 60 and tot_cred <= 89 THEN 'Junior'\nELSE\n  'Final Year'\nEND AS 'Classification'\nFROM student;	f	1265.526823390691	1253.79676509106	0	2026-05-07 09:59:57.479265+00	3	t	1499.1609460488157	1499.1609460488157	t
212	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT section.semester, section.year, COUNT (DISTINCT course.course_id) as jumlah_course\nFROM course \nJOIN section ON section.course_id = course.course_id\nGROUP BY semester	f	1085.4702675386845	1069.2210171280112	0	2026-05-07 09:47:09.475675+00	3	t	1356.4056223812286	1356.4056223812286	t
213	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q019	select dept_name, avg(credits)\nfrom course\ngroup by dept_name\nhaving avg(credits) >= 3;	f	\N	\N	0	2026-05-07 09:47:21.899668+00	2	f	\N	\N	f
215	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q014	SELECT AVG (tot_cred)\nFROM student\nHAVING tot_cred > 50	f	\N	\N	0	2026-05-07 09:47:45.846625+00	1	f	\N	\N	f
217	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q021	select ts.time_slot_id, count(s.sec_id)\nfrom time_slot ts, section s\nwhere ts.time_slot_id = s.time_slot_id and ts.time_slot_id is not null;	f	\N	\N	0	2026-05-07 09:50:06.268564+00	1	f	\N	\N	f
233	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q015	SELECT instructor.ID, COUNT (teaches.course_id)\nFROM instructor\nJOIN teaches ON teaches.id = instructor.id\nGROUP BY instructor.id	t	1063.965714603898	1056.0274576358777	0	2026-05-07 09:56:05.509904+00	2	t	1447.7222538073295	1447.7222538073295	t
218	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q021	select ts.time_slot_id, count(s.sec_id)\nfrom time_slot ts, section s\nwhere ts.time_slot_id = s.time_slot_id and ts.time_slot_id is not null\n  group by ts.time_slot_id;	t	1276.7983532389776	1272.5492349038673	0	2026-05-07 09:50:29.632485+00	2	t	1504.2491183351103	1504.2491183351103	t
234	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT COUNT (DISTINCT ID)\nFROM student\nJOIN takes ON takes.id = student.identity\nWHERE year='2009'	f	\N	\N	0	2026-05-07 09:57:06.855154+00	1	f	\N	\N	f
221	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q021	select section.time_slot_id, count(course_id)\nfrom time_slot left join section on section.time_slot_id = time_slot.time_slot_id\ngroup by section.time_slot_id\nhaving count(course_id) <> 0	t	1365.746646402724	1362.9057473388086	0	2026-05-07 09:51:51.68732+00	2	t	1507.0900173990258	1507.0900173990258	t
235	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT COUNT (DISTINCT ID)\nFROM student\nJOIN takes ON takes.id = student.id\nWHERE year='2009'	f	\N	\N	0	2026-05-07 09:57:12.522457+00	2	f	\N	\N	f
222	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q012	SELECT dept_name\nFROM instructor\nWHERE salary > 90000	t	1059.002924783212	1061.6298228868275	0	2026-05-07 09:51:59.624503+00	1	t	1384.5496826324622	1384.5496826324622	t
223	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q022	select dept_name, avg(credits) as avg_creds\nfrom course\ngroup by dept_name\norder by avg(credits) desc\nlimit 3;	f	\N	\N	0	2026-05-07 09:52:06.966662+00	1	f	\N	\N	f
224	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q022	select dept_name, avg(tot_cred) as avg_creds\nfrom student\ngroup by dept_name\norder by avg(tot_cred) desc\nlimit 3;	f	\N	\N	0	2026-05-07 09:52:48.643109+00	2	f	\N	\N	f
225	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q019	select dept_name, avg(credits), count(course_id)\nfrom course\ngroup by dept_name\nhaving avg(credits) > 3	f	\N	\N	0	2026-05-07 09:53:53.190276+00	1	f	\N	\N	f
226	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q011	SELECT COUNT (DISTINCT ID), dept_name\nfrom instructor\nGROUP BY dept_name\nORDER BY COUNT(DISTINCT ID) DESC	t	1061.6298228868275	1063.965714603898	0	2026-05-07 09:53:55.679261+00	1	t	1410.7495358258366	1410.7495358258366	t
228	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q005	select s.semester, count(c.course_id)\nfrom section s, course c\nwhere c.credits = 1\ngroup by s.semester;	f	\N	\N	0	2026-05-07 09:54:21.542653+00	1	f	\N	\N	f
229	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q019	select dept_name, count(course_id), avg(credits)\nfrom course\ngroup by dept_name\nhaving avg(credits) > 3	f	\N	\N	0	2026-05-07 09:54:24.935391+00	2	f	\N	\N	f
241	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q017	SELECT dept_name\nFROM instructor\nGROUP BY dept_name\nHAVING COUNT (DISTINCT ID) > 2	t	1045.3929214733246	1039.18004253713	0	2026-05-07 09:58:52.494854+00	2	t	1462.6094981090828	1462.6094981090828	t
227	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q022	select dept_name, avg(tot_cred) as avg_cred\nfrom student\ngroup by dept_name\norder by avg(tot_cred) desc\nlimit 3;	t	1272.5492349038673	1265.526823390691	0	2026-05-07 09:53:59.177444+00	3	t	1522.0224115131762	1522.0224115131762	t
236	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT COUNT (DISTINCT student.ID)\nFROM student\nJOIN takes ON takes.id = student.id\nWHERE year='2009'	t	1056.0274576358777	1045.3929214733246	0	2026-05-07 09:57:25.040663+00	3	t	1389.4244143482804	1389.4244143482804	t
231	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q019	select dept_name, count(course_id), avg(credits)\nfrom course\ngroup by dept_name\nhaving avg(credits) > 2	t	1362.9057473388086	1357.6906484666479	0	2026-05-07 09:55:07.914737+00	3	t	1499.8686887367396	1499.8686887367396	t
232	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q015	SELECT instructor.ID, COUNT (teaches.course_id)\nFROM instructor\nJOIN teaches ON teaches.id = instructor.id\nGROUP BY course_id	f	\N	\N	0	2026-05-07 09:55:54.593311+00	1	f	\N	\N	f
242	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q020	SELECT name, tot_cred\nCASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred >= 30 and tot_cred <= 59 THEN 'Sophomore'\n  WHEN tot_cred >= 60 and tot_cred <= 89 THEN 'Junior'\nELSE\n  'Final Year'\nEND\nFROM student;	f	\N	\N	0	2026-05-07 09:58:56.934047+00	2	f	\N	\N	f
237	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q022	select dept_name, avg(tot_cred) as avg_cred\nfrom student\ngroup by dept_name\norder by avg_cred desc\nlimit 3	t	1357.6906484666479	1361.8860896038595	0	2026-05-07 09:57:41.623379+00	1	t	1517.8269703759645	1517.8269703759645	t
243	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q023	select building, sum(budget)\nfrom department\ngroup by dept_name\nhaving sum(budget) > 50000	f	\N	\N	0	2026-05-07 09:59:29.405282+00	1	f	\N	\N	f
238	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q005	select s.semester, min(c.credits)\nfrom section s, course c\nwhere s.course_id = c.course_id\ngroup by s.semester;	t	1326.8097193407266	1325.8412629521697	0	2026-05-07 09:58:04.298596+00	3	t	1244.0286726687375	1244.0286726687375	t
239	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q020	SELECT name,\nCASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred >= 30 and tot_cred <= 59 THEN 'Sophomore'\n  WHEN tot_cred >= 60 and tot_cred <= 89 THEN 'Junior'\nELSE\n  'Final Year'\nEND\nFROM student;	f	\N	\N	0	2026-05-07 09:58:39.664715+00	1	f	\N	\N	f
240	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q017	SELECT dept_name\nFROM instructor\nHAVING COUNT (DISTINCT ID) > 2\nGROUP BY dept_name	f	\N	\N	0	2026-05-07 09:58:42.373884+00	1	f	\N	\N	f
245	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q023	select building, sum(budget)\nfrom department\ngroup by building\nhaving sum(budget) > 50000	t	1361.8860896038595	1358.5160531931183	0	2026-05-07 10:00:02.303139+00	2	t	1533.3700364107412	1533.3700364107412	t
246	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q016	SELECT course.title, COUNT (DISTINCT takes.id)\nFROM takes\nJOIN section ON section.course_id = takes.course_id\nJOIN course ON section.course_id = course.course_id\nGROUP BY course.title	f	\N	\N	0	2026-05-07 10:00:14.230453+00	1	f	\N	\N	f
247	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q013	select count(distinct t.id)\nfrom takes t, section s\nwhere s.year = 2009;	f	\N	\N	0	2026-05-07 10:00:40.390242+00	1	f	\N	\N	f
248	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q001	select count(id)\nfrom student	t	1358.5160531931183	1369.619705565653	0	2026-05-07 10:00:51.902194+00	1	t	1165.4891370262108	1165.4891370262108	t
256	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q025	SELECT product_name,\nCASE\n  WHEN price < 10 THEN 'Low price product'\n  WHEN price > 50 THEN 'High price product'\nELSE\n  'Normal product'\nEND AS "price category"\nFROM products;	f	\N	\N	0	2026-05-07 10:03:24.18442+00	1	f	\N	\N	f
249	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q016	SELECT course.title, COUNT (DISTINCT takes.id)\nFROM takes\nJOIN course ON section.course_id = course.course_id\nGROUP BY course.title	f	\N	\N	0	2026-05-07 10:01:34.967268+00	2	f	\N	\N	f
254	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q024	select count(distinct t.id), c.title, s.semester, s.year\nfrom course c, section s, takes t\nwhere c.course_id = s.course_id and t.course_id = s.course_id\ngroup by c.course_id;	f	1253.79676509106	1241.1605544330223	0	2026-05-07 10:02:39.94479+00	3	t	1557.6362106580377	1557.6362106580377	t
255	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q003	select avg(tot_cred), dept_name\nfrom student\ngroup by dept_name;	t	1324.0313533452497	1333.507022306348	0	2026-05-07 10:03:19.044552+00	1	t	1220.8236105109993	1220.8236105109993	t
261	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q023	select building, budget\nfrom department\ngroup by building\nhaving sum(budget) > 50000;	f	\N	\N	0	2026-05-07 10:05:05.284248+00	2	f	\N	\N	f
681	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q009	SELECT name\nFROM instructor\nWHERE salary > (SELECT AVG(salary) FROM instructor GROUP BY dept_name)	f	\N	\N	106565	2026-05-09 13:52:30.049101+00	1	f	\N	\N	f
685	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q012	SELECT room_no, building\nFROM classroom\nWHERE capacity > 100\nEXCEPT\nSELECT room_no\nFROM classroom\nWHERE building = 'Watson'	f	\N	\N	126099	2026-05-09 13:58:07.493197+00	2	f	\N	\N	f
687	3f7a08ee-e7d6-4a11-8609-42a274c7f385	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q018	SELECT dept_name, AVG(salary)\nFROM instructor\nWHERE dept_name IN (SELECT dept_name FROM department WHERE budget > 150000)\nGROUP BY dept_name	t	1460.5604494644335	1481.810261225361	104494	2026-05-09 14:01:42.485454+00	1	t	1469.4713869126933	1448.2215751517658	f
695	e8d258a4-1fb5-45c2-899e-0e2f54c512b5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q005	SELECT a.title AS course_title, b.title AS prereq_title\nFROM course a, course b, prereq\nWHERE a.course_id = prereq.course_id\n  AND b.course_id = prereq.prereq_id	f	\N	\N	150735	2026-05-09 14:11:17.382168+00	1	f	\N	\N	f
699	e8d258a4-1fb5-45c2-899e-0e2f54c512b5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q002	SELECT department.dept_name\nFROM department natural left outer join instructor\nHAVING COUNT(instructor.ID) = 0\nGROUP BY dept_name	f	\N	\N	121851	2026-05-09 14:14:19.403356+00	2	f	\N	\N	f
250	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q024	select count(distinct t.id), c.title, s.semester, s.year\nfrom course c, section s, takes t\nwhere c.course_id = s.course_id and t.course_id = s.course_id;	f	\N	\N	0	2026-05-07 10:01:53.040789+00	1	f	\N	\N	f
262	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q024	select course_id, sec_id, semester, year, count(distinct id)\nfrom takes\ngroup by course_id, sec_id, semester, year	t	1369.619705565653	1365.9157423460292	0	2026-05-07 10:05:05.612821+00	2	t	1561.3401738776615	1561.3401738776615	t
683	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q009	SELECT name, salary\nFROM instructor as i\nWHERE salary > (SELECT AVG(salary) FROM instructor WHERE instructor.dept_name = i.dept_name)	f	1470.5288842044001	1464.918682516911	314823	2026-05-09 13:55:58.225445+00	3	t	1560	1565.610201687489	f
263	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q023	select building, sum(budget)\nfrom department\ngroup by building\nhaving sum(budget) > 50000;	t	1228.028009953598	1220.234208267703	0	2026-05-07 10:05:18.254225+00	3	t	1541.1638380966363	1541.1638380966363	t
266	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q020	CASE\n    WHEN tot_cred < 30 THEN 'Freshman'\n    WHEN tot_cred between 30 and 59 THEN 'Sophomore'\n    WHEN tot_cred between 60 and 89 THEN 'Junior'\n    ELSE 'Final Year'\nEND	f	\N	\N	0	2026-05-07 10:08:46.983429+00	1	f	\N	\N	f
688	9f090bc2-52c7-4dbf-af83-414d3ecc3bb3	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q016	SELECT title, COUNT(ID)\nFROM course natural join student\nGROUP BY title	f	\N	\N	56373	2026-05-09 14:02:59.33867+00	1	f	\N	\N	f
691	621e5377-507a-48df-b4a7-464acf97df96	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q016	SELECT course.title, COUNT(takes.ID)\nFROM course natural join takes\nGROUP BY course.title	t	1477.53103649016	1500.5429256720186	32444	2026-05-09 14:05:57.516172+00	1	t	1477.1884459417051	1454.1765567598466	f
698	e8d258a4-1fb5-45c2-899e-0e2f54c512b5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q002	SELECT department.dept_name\nFROM department natural left outer join instructor\nHAVING COUNT(instructor.ID) = 0	f	\N	\N	113183	2026-05-09 14:14:10.770611+00	1	f	\N	\N	f
702	891a6c2d-74e7-4945-a823-512d7be899e2	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q023	SELECT building, SUM(budget)\nFROM department\nGROUP BY building\nHAVING SUM(budget) > 50000	t	1476.5519552301737	1499.8006409546701	45641	2026-05-09 14:16:59.46686+00	1	t	1490.8724535211936	1467.6237677966972	f
703	b27a3d1f-a57f-4d8c-80f9-1dadb582f928	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q020	SELECT name, tot_cred,\nCASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore'\n  WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior'\n  ELSE THEN 'Final Year'\nEND AS classification\nFROM student	f	\N	\N	103733	2026-05-09 14:18:54.633932+00	1	f	\N	\N	f
706	f23eeb8d-9d08-4535-b6ee-d317d0c2c443	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q022	SELECT dept_name, AVG(tot_cred) AS avg_cred\nFROM student\nGROUP BY dept_name\nORDER BY AVG(tot_cred) desc\nLIMIT 3	t	1502.2306902209866	1506.3211076278014	59801	2026-05-09 14:20:17.369118+00	2	t	1513.5247576022523	1509.4343401954375	f
684	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q012	SELECT room_no\nFROM classroom\nWHERE capacity > 100\nEXCEPT\nSELECT room_no\nFROM classroom\nWHERE building = 'Watson'	f	\N	\N	108594	2026-05-09 13:57:49.956311+00	1	f	\N	\N	f
251	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q016	SELECT course.title, COUNT (DISTINCT takes.id)\nFROM takes\nJOIN course ON course.course_id = takes.course_id\nGROUP BY course.title	f	1039.18004253713	1025.4502130654369	0	2026-05-07 10:02:10.707021+00	3	t	1466.4311166494383	1466.4311166494383	t
689	9f090bc2-52c7-4dbf-af83-414d3ecc3bb3	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q016	SELECT course.title, COUNT(student.ID)\nFROM course natural join takes natural join student\nGROUP BY course.title	f	\N	\N	147126	2026-05-09 14:04:30.12062+00	2	f	\N	\N	f
692	e8d258a4-1fb5-45c2-899e-0e2f54c512b5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q006	SELECT title\nFROM course\nWHERE credits > (SELECT AVG(credits) FROM course)	f	\N	\N	43496	2026-05-09 14:07:09.873839+00	1	f	\N	\N	f
696	e8d258a4-1fb5-45c2-899e-0e2f54c512b5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q005	SELECT a.title, b.title\nFROM course a, course b, prereq\nWHERE a.course_id = prereq.course_id\n  AND b.course_id = prereq.prereq_id	f	\N	\N	172503	2026-05-09 14:11:39.124248+00	2	f	\N	\N	f
700	e8d258a4-1fb5-45c2-899e-0e2f54c512b5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q002	SELECT department.dept_name\nFROM department natural left outer join instructor\nGROUP BY dept_name\nHAVING COUNT(instructor.ID) = 0	f	1471.291324450998	1454.5601532889318	132531	2026-05-09 14:14:30.043663+00	3	t	1431.0138243686145	1447.7449955306806	f
252	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q013	select count(distinct t.id)\nfrom takes t\nwhere t.year = 2009;	t	1325.8412629521697	1324.0313533452497	0	2026-05-07 10:02:13.375293+00	2	t	1391.2343239552004	1391.2343239552004	t
253	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q024	select count(distinct t.id), c.title, s.semester, s.year\nfrom course c, section s, takes t\nwhere c.course_id = s.course_id and t.course_id = s.course_id\ngroup by course_id;	f	\N	\N	0	2026-05-07 10:02:33.055643+00	2	f	\N	\N	f
267	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q020	CASE\n    WHEN tot_cred < 30 THEN 'Freshman'\n    WHEN tot_cred between 30 and 59 THEN 'Sophomore'\n    WHEN tot_cred between 60 and 89 THEN 'Junior'\n    ELSE 'Final Year'\nEND AS classification\nFROM student	f	\N	\N	0	2026-05-07 10:09:57.294935+00	2	f	\N	\N	f
257	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q025	SELECT product_name,\nCASE\n  WHEN price < 10 THEN 'Low price product'\n  WHEN price > 50 THEN 'High price product'\nELSE\n  'Normal product'\nEND AS "price category"\nFROM products;	f	1241.1605544330223	1228.028009953598	0	2026-05-07 10:03:25.66289+00	2	t	1593.1325444794243	1593.1325444794243	t
260	bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02-Q023	select building, budget\ngroup by building\nhaving sum(budget) > 50000;	f	\N	\N	0	2026-05-07 10:04:54.950866+00	1	f	\N	\N	f
264	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q002	select dept_name, count(id) as jumlah_mhs\nfrom student\ngroup by dept_name	t	1365.9157423460292	1376.5031209799433	0	2026-05-07 10:06:04.421428+00	1	t	1203.2916511521953	1203.2916511521953	t
265	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q017	select distinct dept_name\nfrom instructor\ngroup by dept_name\nhaving count(id) > 2;	t	1343.302012901845	1348.3232289401403	0	2026-05-07 10:07:18.854632+00	1	t	1457.5882820707875	1457.5882820707875	t
289	e9a90178-0cb7-4b07-ba57-18a5220126c4	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q008	select d.dept_name, avg(d.budget)\nfrom department d\nwhere d.building = 'Taylor'\ngroup by dept_name;	f	1339.9968630182395	1325.6363129373476	0	2026-05-07 10:18:37.664993+00	3	t	1339.5372539674677	1339.5372539674677	t
258	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q002	select count(distinct id) as jumlah_mhs, dept_name\nfrom student\ngroup by dept_name;	t	1333.507022306348	1343.302012901845	0	2026-05-07 10:04:32.697318+00	1	t	1213.8790297861094	1213.8790297861094	t
259	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q024	select course_id, sec_id, semester, year, count(distinct id)\nfrom takes\ngroup by course_id	f	\N	\N	0	2026-05-07 10:04:50.997085+00	1	f	\N	\N	f
282	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q021	SELECT	f	1000	1000	0	2026-05-07 10:14:57.600765+00	1	t	1521.321715882216	1521.321715882216	t
268	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q020	SELECT *\nCASE\n    WHEN tot_cred < 30 THEN 'Freshman'\n    WHEN tot_cred between 30 and 59 THEN 'Sophomore'\n    WHEN tot_cred between 60 and 89 THEN 'Junior'\n    ELSE 'Final Year'\nEND AS classification\nFROM student	f	1025.4502130654369	1011.3712834236898	0	2026-05-07 10:10:23.49038+00	3	t	1513.239875690563	1513.239875690563	t
269	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q025	select\ncase\n  when tot_cred < 30 then 'Freshman'\n  when tot_cred between 30 and 59 then 'Sophomore'\n  when tot_cred between 60 and 89 then 'Junior'\n  else 'Final Year'\nend as classification, count(id)\nfrom student\ngroup by classification	f	\N	\N	0	2026-05-07 10:10:45.578722+00	1	f	\N	\N	f
270	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q016	select c.title, count(t.id)\nfrom takes t, course c\nwhere c.course_id = t.course_id;	f	\N	\N	0	2026-05-07 10:10:47.79416+00	1	f	\N	\N	f
271	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q016	select c.title, count(t.id)\nfrom takes t, course c\nwhere c.course_id = t.course_id\ngroup by c.title;	t	1348.3232289401403	1345.8675379947838	0	2026-05-07 10:11:15.096663+00	2	t	1468.8868075947948	1468.8868075947948	t
272	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q025	select\ncase\n  when tot_cred < 30 then 'Freshman'\n  when tot_cred between 30 and 59 then 'Sophomore'\n  when tot_cred between 60 and 89 then 'Junior'\n  else 'Final Year'\nend as classification, count(*)\nfrom student\ngroup by classification	f	\N	\N	0	2026-05-07 10:11:19.437179+00	2	f	\N	\N	f
273	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q019	SELECT COUNT (course_id), dept_name\nFROM course\nGROUP BY dept_name\nHAVING AVG (credits) > 3	f	\N	\N	0	2026-05-07 10:11:38.40454+00	1	f	\N	\N	f
274	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q019	SELECT dept_name, COUNT (course_id)\nFROM course\nGROUP BY dept_name\nHAVING AVG (credits) > 3	f	\N	\N	0	2026-05-07 10:12:27.404014+00	2	f	\N	\N	f
275	81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02-Q025	select\ncase\n  when tot_cred < 30 then 'Freshman'\n  when tot_cred between 30 and 59 then 'Sophomore'\n  when tot_cred between 60 and 89 then 'Junior'\n  else 'Final Year'\nend as classification, count(*) as jumlah\nfrom student\ngroup by classification	t	1376.5031209799433	1369.8513693125378	0	2026-05-07 10:12:27.655284+00	3	t	1599.7842961468298	1599.7842961468298	t
283	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q019	select dept_name, count(course_id), avg(credits)\nfrom course\ngroup by dept_name\nhaving avg(credits) >= 3;	t	1345.8675379947838	1339.9968630182395	0	2026-05-07 10:15:32.108513+00	3	t	1519.889190143824	1519.889190143824	t
276	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q019	SELECT dept_name, COUNT (course_id)\nFROM course\nGROUP BY dept_name\nHAVING AVG (credits) >= 3	f	1011.3712834236898	1000	0	2026-05-07 10:12:48.345632+00	3	t	1514.0185151672797	1514.0185151672797	t
277	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q019	select dept_name, count(course_id)\nfrom course\ngroup by dept_name\nhaving avg(credits) > 3;	f	\N	\N	0	2026-05-07 10:13:21.447897+00	1	f	\N	\N	f
278	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q018	SELECT AVG (salary)\nFROM instructor\nWHERE budget > 150000	f	\N	\N	0	2026-05-07 10:13:54.702393+00	1	f	\N	\N	f
279	dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q019	select dept_name, avg(credits), count(course_id)\nfrom course\ngroup by dept_name\nhaving avg(credits) > 3;	f	\N	\N	0	2026-05-07 10:14:27.70975+00	2	f	\N	\N	f
280	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q018	SELECT AVG (instructor.salary)\nFROM instructor\nJOIN department ON department.dept+name = instructor.dept_name\nWHERE department.budget > 150000	f	\N	\N	0	2026-05-07 10:14:34.078112+00	2	f	\N	\N	f
281	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q018	SELECT AVG (instructor.salary)\nFROM instructor\nJOIN department ON department.dept_name = instructor.dept_name\nWHERE department.budget > 150000	f	1000	1000	0	2026-05-07 10:14:40.160901+00	3	t	1480.543686727664	1480.543686727664	t
293	c8cabe3c-4a7a-4d28-ae51-76a5d8424666	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q001	SELECT * from student	t	1015	1030.6471999915343	0	2026-05-07 12:29:35.644466+00	1	t	1000	1000	f
284	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q022	SELECT dept_name\nFROM department\nHAVING AVG(tot_cred)	f	1000	1000	0	2026-05-07 10:16:00.387092+00	1	t	1532.1024933764738	1532.1024933764738	t
290	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q025	SELECT count(distinct id),\nCASE\n  WHEN  THEN 'Low Cost'\n  WHEN Price BETWEEN 20 AND 50 THEN 'Medium Cost'\n  ELSE 'Final Year'\nEND AS classifier\nFROM student;	f	1000	1000	0	2026-05-07 10:19:20.52699+00	1	t	1614.323940943302	1614.323940943302	t
285	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q023	SELECT dept_name\nFROM department\nHAVING	f	1000	1000	0	2026-05-07 10:17:37.280719+00	1	t	1555.5265625791244	1555.5265625791244	t
286	e9a90178-0cb7-4b07-ba57-18a5220126c4	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q008	select avg(d.budget), d.dept_name\nfrom department d\nwhere d.building = 'Taylor';	f	\N	\N	0	2026-05-07 10:17:54.249973+00	1	f	\N	\N	f
291	e9a90178-0cb7-4b07-ba57-18a5220126c4	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q010	select building, avg(capacity)\nfrom classroom\ngroup by building\nhaving avg(capacity) > 80;	t	\N	\N	0	2026-05-07 10:20:33.508382+00	1	t	\N	\N	f
287	1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q024	SELECT (DISTINCT )	f	1000	1000	0	2026-05-07 10:18:08.155158+00	1	t	1575.7701220573977	1575.7701220573977	t
288	e9a90178-0cb7-4b07-ba57-18a5220126c4	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02-Q008	select avg(d.budget), d.dept_name\nfrom department d\nwhere d.building = 'Taylor'\ngroup by dept_name;	f	\N	\N	0	2026-05-07 10:18:15.3145+00	2	f	\N	\N	f
292	e649a50c-d688-44a3-b93f-bd2aa52508a7	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q001	SELECT * FROM student	t	1000	1015	0	2026-05-07 12:29:22.6716+00	1	t	1000	1000	f
294	1927c22f-0581-4027-87b4-55affcb79e40	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q004	SELECT *\nFROM student\nWHERE dept_name='Comp. Sci.'	t	1030.6471999915343	1045.5451892397557	0	2026-05-07 12:30:24.973558+00	1	t	1018.1120581890469	1018.1120581890469	f
295	26525756-5f18-4a7f-9032-69d043a876f6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q005	SELECT *\nFROM instructor\nWHERE dept_name='Comp. Sci.'	f	\N	\N	0	2026-05-07 12:30:58.343413+00	1	f	\N	\N	f
296	26525756-5f18-4a7f-9032-69d043a876f6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q005	SELECT name, dept_name\nFROM instructor\nWHERE dept_name='Comp. Sci.'	t	1045.5451892397557	1045.4221368106876	0	2026-05-07 12:31:10.023384+00	2	t	1048.518491790934	1048.518491790934	f
297	3f67c12e-5c27-4d45-bc95-d8987627e09a	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q003	SELECT name FROM student where tot_cred > 0	f	\N	\N	0	2026-05-07 12:31:41.488757+00	1	f	\N	\N	f
298	3f67c12e-5c27-4d45-bc95-d8987627e09a	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q003	SELECT * FROM student where tot_cred > 0	t	1045.4221368106876	1046.087527022315	0	2026-05-07 12:31:47.709163+00	2	t	1029.3346097883725	1029.3346097883725	f
299	f7e51e73-a281-4ca0-93be-533f63350285	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q005	SELECT name, dept_name\nFROM instructor\nWHERE dept_name='Comp. Sci.'	t	1046.087527022315	1060.9825755492795	0	2026-05-07 12:32:27.502649+00	1	t	1033.6234432639694	1033.6234432639694	f
300	873a951b-f37c-4daf-b382-32fcab5af1f9	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q007	SELECT name\nFROM student\nWHERE name LIKE 'Z%'	f	\N	\N	0	2026-05-07 12:34:00.14666+00	1	f	\N	\N	f
301	873a951b-f37c-4daf-b382-32fcab5af1f9	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q007	SELECT *\nFROM student\nWHERE name LIKE 'Z%'	t	1060.9825755492795	1060.2030711291986	0	2026-05-07 12:34:44.094506+00	2	t	1079.833531051571	1079.833531051571	f
302	410a9331-316c-431d-b68f-219a2670fbc2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q006	SELECT title\nFROM course	t	1060.2030711291986	1075.0707837182752	0	2026-05-07 12:35:06.805636+00	1	t	1048.3995282544545	1048.3995282544545	f
303	9933ff5d-204a-4313-afff-609cbd0e1b3f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q006	SELECT title\nFROM course	t	1075.0707837182752	1091.220017776924	0	2026-05-07 12:35:21.678744+00	1	t	1032.2502941958057	1032.2502941958057	f
304	80715770-163f-40bb-99cd-9eaf5a7fef0d	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q007	SELECT *\nFROM student\nWHERE name LIKE 'Z%'	t	1091.220017776924	1106.7114359996801	0	2026-05-07 12:35:41.492651+00	1	t	1064.3421128288148	1064.3421128288148	f
305	a4c24ab5-e69c-4ac6-9b96-cb9830382929	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q008	SELECT name\nFROM student\nWHERE name LIKE '%ez'	f	\N	\N	0	2026-05-07 15:03:49.448412+00	1	f	\N	\N	f
306	a4c24ab5-e69c-4ac6-9b96-cb9830382929	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q008	SELECT *\nFROM student\nWHERE name LIKE '%ez'	t	1106.7114359996801	1106.9201328209197	0	2026-05-07 15:03:54.67025+00	2	t	1101.668513748421	1101.668513748421	f
307	ab6fc46b-0de9-4819-aaac-51a1a318323d	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q008	SELECT *\nFROM student\nWHERE name LIKE '%ez'	t	1106.9201328209197	1122.1468461761754	0	2026-05-07 15:04:13.574192+00	1	t	1086.4418003931653	1086.4418003931653	f
308	83ef5f2a-02d4-4c31-a305-97c6749806a4	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q009	SELECT *\nFROM student\nWHERE dept_name IN ('Comp. Sci.', 'Physics');	t	1122.1468461761754	1137.2571402855979	0	2026-05-07 16:24:17.898887+00	1	t	1104.4818327927032	1104.4818327927032	f
309	a2254da8-7e9d-4b15-ae31-1471bcfc4e47	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q010	SELECT *\nfrom student\nwhere tot_cred BETWEEN 50 AND 100	t	1137.2571402855979	1152.7753841901629	0	2026-05-07 16:26:41.669475+00	1	t	1109.7303584692374	1109.7303584692374	f
310	b6bca809-5d4d-4db4-97da-762cf5eabbf6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q011	SELECT *\nFROM student\nWHERE tot_cred IS NULL	f	\N	\N	0	2026-05-07 16:27:02.972008+00	1	f	\N	\N	f
311	b6bca809-5d4d-4db4-97da-762cf5eabbf6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q011	SELECT *\nFROM student\nWHERE tot_cred=0	t	1152.7753841901629	1152.660435000263	0	2026-05-07 16:27:23.672764+00	2	t	1155.5528814408915	1155.5528814408915	f
312	56d84687-596b-4ea5-ab0a-7aec59c4c187	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q011	SELECT *\nFROM student\nWHERE tot_cred = 0	t	1152.660435000263	1167.5355609341061	0	2026-05-07 16:27:39.81925+00	1	t	1140.6777555070485	1140.6777555070485	f
313	7797a258-dd22-435d-b5cd-57551d13d25b	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q012	SELECT *\nFROM student\nWHERE tot_cred > 0	t	1167.5355609341061	1183.0460645846974	0	2026-05-07 16:28:01.796561+00	1	t	1140.1960130894436	1140.1960130894436	f
314	20ebfabf-28e9-4e16-9a41-1121ea190753	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q013	SELECT *\nFROM student\nORDER BY tot_cred DESC	t	1183.0460645846974	1197.8500442952438	0	2026-05-07 16:28:25.337473+00	1	t	1172.7826382901362	1172.7826382901362	f
315	4e2ceaff-3fa3-4d26-a5ea-217c1190f0e2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q015	select building\nFROM classroom\nWHERE capacity > 150\nORDER BY capacity DESC	f	\N	\N	0	2026-05-07 16:28:53.166007+00	1	f	\N	\N	f
316	4e2ceaff-3fa3-4d26-a5ea-217c1190f0e2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q015	SELECT building, capacity\nFROM classroom\nWHERE capacity > 150\nORDER BY capacity DESC	f	\N	\N	0	2026-05-07 16:30:11.198839+00	2	f	\N	\N	f
317	4e2ceaff-3fa3-4d26-a5ea-217c1190f0e2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q015	SELECT building\nFROM classroom\nwhere capacity > 150\norder by capacity desc	f	1197.8500442952438	1182.3658583747151	0	2026-05-07 16:31:29.020052+00	3	t	1224.5530223135606	1224.5530223135606	f
318	e61243b5-f448-47ec-ae62-66702ece4395	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q013	SELECT *\nFROM student\nORDER BY tot_cred desc;	t	1182.3658583747151	1197.7794943505837	0	2026-05-07 16:31:49.881699+00	1	t	1157.3690023142676	1157.3690023142676	f
319	308ce14f-52bb-45ed-be2a-8553eebb06e2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q015	SELECT *\nFROM classroom\nwhere capacity > 150\norder by capacity desc	t	1197.7794943505837	1211.625870850857	0	2026-05-07 16:32:18.79679+00	1	t	1210.7066458132874	1210.7066458132874	f
320	9559ebae-d44f-4620-97c4-c44809c5521f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q015	SELECT *\nFROM building\nWHERE capacity > 150\nORDER BY capacity desc	f	\N	\N	0	2026-05-07 16:32:37.745847+00	1	f	\N	\N	f
321	9559ebae-d44f-4620-97c4-c44809c5521f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q015	SELECT *\nFROM classroom\nWHERE capacity > 150\nORDER BY capacity desc	t	1211.625870850857	1211.6655568932933	0	2026-05-07 16:32:45.34607+00	2	t	1210.666959770851	1210.666959770851	f
322	b8f4276a-1149-443b-baa1-7edb37c12591	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q015	SELECT *\nFROM classroom\nWHERE capacity > 150\norder by capacity desc	t	1211.6655568932933	1226.708669677976	0	2026-05-07 16:33:03.542568+00	1	t	1195.6238469861682	1195.6238469861682	f
323	2de60028-a726-41b8-8891-10df0b6a31e6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q019	SELECT *\nfrom instructor\nWHERE salary between 60000 and 90000	t	1226.708669677976	1241.073950229904	0	2026-05-07 16:33:23.788362+00	1	t	1227.0537813168914	1227.0537813168914	f
324	18e28242-d5b4-423b-8913-b9e773eeb65a	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q019	SELECT *\nfrom instructor\nwhere salary between 60000 and 90000	t	1241.073950229904	1256.6789212385834	0	2026-05-07 16:33:44.617897+00	1	t	1211.4488103082122	1211.4488103082122	f
325	87adf447-3897-476d-9ce8-00dfae272342	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q020	SELECT distinct building, distinct room_no\nfrom classroom	f	\N	\N	0	2026-05-07 16:34:59.940042+00	1	f	\N	\N	f
326	87adf447-3897-476d-9ce8-00dfae272342	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q020	SELECT (distinct building), (distinct room_no)\nfrom classroom	f	\N	\N	0	2026-05-07 16:35:14.452879+00	2	f	\N	\N	f
327	87adf447-3897-476d-9ce8-00dfae272342	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q020	SELECT DISTINCT building, room_no\nFROM classroom;	t	1256.6789212385834	1251.7170252357585	0	2026-05-07 16:35:35.754875+00	3	t	1260.7582363717042	1260.7582363717042	f
328	78d837df-fc9d-4bc0-af2c-903111d484f0	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q020	SELECT building, room_no\nFROM classroom	t	1251.7170252357585	1266.3267728600472	0	2026-05-07 16:35:53.980149+00	1	t	1246.1484887474155	1246.1484887474155	f
329	898acc64-1d09-438e-8be8-2117aa9ec140	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q018	SELECT *\nFROM student\nWHERE dept_name='Comp. Sci.' AND tot_cred>80	t	1266.3267728600472	1281.4064802952898	0	2026-05-07 16:36:27.068463+00	1	t	1249.4008347518663	1249.4008347518663	f
330	e6723a72-cd4a-4817-91e2-a6eed9e91dfb	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q021	SELECT *\nfrom student\nWHERE name LIKE '% %n'	t	1281.4064802952898	1295.9867495861172	0	2026-05-07 16:37:39.411114+00	1	t	1276.5507085924094	1276.5507085924094	f
331	34a5d6af-c8d0-4171-8a6d-a24012ea8972	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q021	SELECT *\nFROM student\nWHERE name LIKE '% %n'	t	1295.9867495861172	1311.82499669539	0	2026-05-07 16:38:06.567513+00	1	t	1260.7124614831366	1260.7124614831366	f
332	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q010	SELECT building, AVG (capacity)\nFROM classroom\nHAVING AVG (capacity) > 80\nGROUP BY building	f	\N	\N	0	2026-05-07 16:39:55.280733+00	1	f	\N	\N	f
333	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q010	SELECT building, AVG (capacity)\nFROM classroom\nGROUP BY building\nHAVING AVG (capacity) > 80	t	1310.59953852318	1314.2690343211389	0	2026-05-07 16:40:02.53571+00	2	t	1337.82888188498	1337.82888188498	t
340	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT semester, year, count(course_id) as jumlah_course\nfrom section\ngroup by year, semester	t	1329.9179209834401	1323.7765653916083	0	2026-05-07 16:44:14.498827+00	3	t	1362.5469779730604	1362.5469779730604	f
334	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q010	SELECT building, AVG (capacity)\nFROM classroom\nGROUP BY building\nHAVING AVG (capacity) > 80	t	\N	\N	0	2026-05-07 16:40:44.846111+00	1	t	\N	\N	f
335	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q006	SELECT credits, dept_name\nFROM course	f	\N	\N	0	2026-05-07 16:41:10.697178+00	1	f	\N	\N	f
336	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q006	SELECT SUM (credits), dept_name\nFROM course\nGROUP BY dept_name	t	1314.2690343211389	1315.9353332648143	0	2026-05-07 16:41:59.835378+00	2	t	1273.84735395402	1273.84735395402	f
337	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q008	SELECT AVG (budget)\nFROM department\nWHERE building='Taylor'	t	1315.9353332648143	1329.9179209834401	0	2026-05-07 16:42:29.664285+00	1	t	1325.5546662488418	1325.5546662488418	f
338	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT semester, year, count(course_id) as jumlah_course\nfrom section\ngroup by semester	f	\N	\N	0	2026-05-07 16:43:58.250255+00	1	f	\N	\N	f
339	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT semester, year, count(course_id) as jumlah_course\nfrom section\ngroup by year	f	\N	\N	0	2026-05-07 16:44:08.282307+00	2	f	\N	\N	f
341	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q014	SELECT AVG(tot_cred)\nFROM student\nwhere tot_cred > 50	t	1323.7765653916083	1336.663814951246	0	2026-05-07 16:44:41.079459+00	1	t	1360.153147160515	1360.153147160515	f
342	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q009	SELECT dept_name\nFROM course\ngroup by dept_name\nhaving sum(credits) > 10	f	\N	\N	0	2026-05-07 16:45:30.049556+00	1	f	\N	\N	f
345	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT (distinct id)\nFROM takes\nWHERE year='2009'	f	\N	\N	0	2026-05-07 16:46:48.955335+00	2	f	\N	\N	f
348	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q011	SELECT COUNT(ID), dept_name\nFROM instructor\nORDER BY count(id) desc\ngroup by dept_name	f	\N	\N	0	2026-05-07 16:48:06.221924+00	1	f	\N	\N	f
343	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q009	SELECT dept_name, SUM(CREDITS)\nFROM course\ngroup by dept_name\nhaving sum(credits) > 10	t	1336.663814951246	1335.7527439366977	0	2026-05-07 16:46:06.662351+00	2	t	1358.7034595656917	1358.7034595656917	t
344	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT (id)\nFROM takes\nWHERE year='2009'	f	\N	\N	0	2026-05-07 16:46:44.015072+00	1	f	\N	\N	f
354	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q003	SELECT AVG (tot_cred), dept_name\nFROM student\nGROUP BY dept_name	t	1334.7995416355839	1347.9672088218072	0	2026-05-07 16:53:45.311564+00	1	t	1207.655943324776	1207.655943324776	t
346	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT DISTINCT (ID)\nFROM takes\nWHERE year='2009'	f	1335.7527439366977	1324.1692924838005	0	2026-05-07 16:46:58.624499+00	3	t	1402.8177754080975	1402.8177754080975	t
347	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q012	SELECT dept_name\nFROM instructor\nwhere salary > 90000	t	1324.1692924838005	1332.448692530916	0	2026-05-07 16:47:22.99906+00	1	t	1376.2702825853466	1376.2702825853466	t
350	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q005	SELECT section.semester, MIN (course.credits)\nFROM section, course\nGROUP BY semester	t	1330.232408865509	1342.6638614358428	0	2026-05-07 16:50:19.374005+00	1	t	1231.5972200984036	1231.5972200984036	t
349	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q011	SELECT COUNT(ID), dept_name\nFROM instructor\ngroup by dept_name\nORDER BY count(id) desc	t	1332.448692530916	1330.232408865509	0	2026-05-07 16:48:20.276044+00	2	t	1412.9658194912438	1412.9658194912438	t
352	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q004	SELECT name, MAX(tot_cred) as max_sks, dept_name\nFROM student\nGROUP BY dept_name, name	f	\N	\N	0	2026-05-07 16:51:16.428887+00	2	f	\N	\N	f
355	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q017	SELECT dept_name\nFROM instructor\nGROUP BY dept_name\nHAVING COUNT (ID) > 2	t	1347.9672088218072	1354.91275103424	0	2026-05-07 16:54:31.076828+00	1	t	1450.6427398583546	1450.6427398583546	t
351	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q004	SELECT name, MAX(tot_cred) as max_sks, dept_name\nFROM student\nGROUP BY dept_name	f	\N	\N	0	2026-05-07 16:51:08.370233+00	1	f	\N	\N	f
378	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q024	SELECT COUNT(DISTINCT id), sec_id, semester, year\nFROM takes\nGROUP BY id, sec_id, semester, year	f	1355.7013892942366	1343.9984273553755	0	2026-05-07 17:13:59.774181+00	3	t	1587.4730839962588	1587.4730839962588	t
353	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q004	SELECT student.name, MAX(course.credits) as max_sks, course.dept_name\nFROM course\n  JOIN student ON student.dept_name = course.dept_name\nGROUP BY course.dept_name, student.name	f	1342.6638614358428	1334.7995416355839	0	2026-05-07 16:53:08.537321+00	3	t	1275.1669981436207	1275.1669981436207	t
356	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q016	SELECT course.title, COUNT (student.ID)\nFROM course\nJOIN student ON course.dept_name = student.dept_name\nGROUP BY title	f	\N	\N	0	2026-05-07 16:55:39.927308+00	1	f	\N	\N	f
357	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q016	SELECT course.title, COUNT (takes.ID)\nFROM course\nJOIN stakes ON course.course_id = takes.course_id\nGROUP BY course.title	f	\N	\N	0	2026-05-07 16:56:26.669433+00	2	f	\N	\N	f
369	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q021	SELECT time_slot.time_slot_id, COUNT(section.course_id)\nFROM time_slot\nLEFT JOIN section ON time_slot.time_slot_id = section.time_slot_id\nGROUP BY time_slot.time_slot_id\nHAVING COUNT(section.course_id) > 0;	t	1352.240101014197	1348.8534136121932	0	2026-05-07 17:06:27.637921+00	2	t	1524.70840328422	1524.70840328422	t
358	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q016	SELECT course.title, COUNT (takes.ID)\nFROM course\nJOIN takes ON course.course_id = takes.course_id\nGROUP BY course.title	t	1354.91275103424	1348.4117990552206	0	2026-05-07 16:56:32.874306+00	3	t	1475.3877595738143	1475.3877595738143	t
359	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q015	SELECT ID, COUNT (course_id)\nFROM teaches\ngroup by course_id	f	\N	\N	0	2026-05-07 16:57:16.457167+00	1	f	\N	\N	f
360	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q015	SELECT ID, COUNT (course_id)\nFROM teaches\ngroup by course_id, id	f	\N	\N	0	2026-05-07 16:57:22.963001+00	2	f	\N	\N	f
361	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q015	SELECT ID, COUNT (course_id)\n  FROM teaches\n  group by ID	t	1348.4117990552206	1343.8245486309718	0	2026-05-07 16:58:03.060697+00	3	t	1452.3095042315783	1452.3095042315783	t
375	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q025	SELECT COUNT (id)\nCASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore'\n  WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior'\n  ELSE 'Final Year'\nEND AS clasification\nFROM student	f	1367.779638184045	1355.7013892942366	0	2026-05-07 17:11:05.838493+00	3	t	1626.4021898331105	1626.4021898331105	t
362	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q002	SELECT count(id) as jumlah_mhs, dept_name\nFROM student\nGROUP BY dept_name	t	1343.8245486309718	1354.2029058757787	0	2026-05-07 16:58:31.171333+00	1	t	1192.9132939073884	1192.9132939073884	t
363	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q020	SELECT *\ncase\nwhen tot_cred < 30 then 'Freshman'\nwhen tot_cred BETWEEN 30 AND 59 then 'Sophomore'\nWHEN tot_cred BETWEEN 60 AND 89 then 'Junior'\nELSE 'Final Year'\nEND AS classification\nFROM student	f	\N	\N	0	2026-05-07 17:00:05.614628+00	1	f	\N	\N	f
364	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q020	SELECT *\n  case\n    when tot_cred < 30 then 'Freshman'\n    when tot_cred BETWEEN 30 AND 59 then 'Sophomore'\n    WHEN tot_cred BETWEEN 60 AND 89 then 'Junior'\n    ELSE 'Final Year'\n  END AS classification\nFROM student	f	\N	\N	0	2026-05-07 17:00:27.689394+00	2	f	\N	\N	f
370	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q001	SELECT COUNT(ID)\nFROM student	t	1348.8534136121932	1359.98094347733	0	2026-05-07 17:06:47.7132+00	1	t	1154.361607161074	1154.361607161074	t
365	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q020	SELECT *\n  CASE\n    when tot_cred < 30 then 'Freshman'\n    when tot_cred BETWEEN 30 AND 59 then 'Sophomore'\n    WHEN tot_cred BETWEEN 60 AND 89 then 'Junior'\n    ELSE 'Final Year'\n  END AS classification\nFROM student	f	1354.2029058757787	1343.491070608296	0	2026-05-07 17:00:49.285585+00	3	t	1523.9517109580456	1523.9517109580456	t
366	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q019	SELECT dept_name, COUNT(course_id), AVG(credits)\nFROM course\nGROUP BY dept_name\nHAVING AVG(credits) >= 3;	t	1343.491070608296	1347.4798509948912	0	2026-05-07 17:02:21.82735+00	1	t	1515.9004097572288	1515.9004097572288	t
376	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q024	SELECT COUNT(takes.id), section.sec_id, section.semester, section.year\nFROM takes\nJOIN section ON takes.course_id=section.course_id\nGROUP BY section.sec_id, section.semester, section.year	f	\N	\N	0	2026-05-07 17:12:30.569817+00	1	f	\N	\N	f
367	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q018	SELECT AVG (salary)\nFROM instructor\nJOIN department ON department.dept_name = instructor.dept_name\nWHERE department.budget > 150000\ngroup by department.dept_name	t	1347.4798509948912	1352.240101014197	0	2026-05-07 17:04:12.125086+00	1	t	1475.783436708358	1475.783436708358	t
368	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q021	SELECT time_slot.time_slot_id\nFROM time_slot\nLEFT JOIN section ON time_slot.time_slot_id = section.time_slot_id\nGROUP BY time_slot.time_slot_id\nHAVING COUNT(section.course_id) > 0;	f	\N	\N	0	2026-05-07 17:06:12.477021+00	1	f	\N	\N	f
371	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q023	SELECT SUM (budget), building\nFROM department\nGROUP BY building\nHAVING SUM (budget) > 50000	t	1359.98094347733	1363.6554120789262	0	2026-05-07 17:07:45.949116+00	1	t	1551.852093977528	1551.852093977528	t
377	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q024	SELECT COUNT(DISTINCT takes.id), section.sec_id, section.semester, section.year\nFROM takes\nJOIN section ON takes.course_id=section.course_id\nGROUP BY section.sec_id, section.semester, section.year	f	\N	\N	0	2026-05-07 17:12:38.855805+00	2	f	\N	\N	f
372	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q022	SELECT dept_name, AVG(tot_cred) as avg_cred\nFROM student\nGROUP by dept_name\nORDER BY AVG(tot_cred) desc\nLIMIT 3	t	1363.6554120789262	1367.779638184045	0	2026-05-07 17:09:01.276181+00	1	t	1527.978267271355	1527.978267271355	t
373	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q025	SELECT COUNT (id)\n  CASE\n        WHEN tot_cred < 30 THEN 'Freshman'\n        WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore'\n        WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior'\n        ELSE 'Final Year'\n  END AS clasification\nFROM student;	f	\N	\N	0	2026-05-07 17:10:09.916523+00	1	f	\N	\N	f
374	f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q025	SELECT COUNT (id)\n  CASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore'\n  WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior'\n  ELSE 'Final Year'\n  END AS clasification\nFROM student;	f	\N	\N	0	2026-05-07 17:10:29.378399+00	2	f	\N	\N	f
380	82a1a35a-bc3d-4cf4-a380-f09d949bd653	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q025	SELECT course.*, section.semester, section.year\nFROM course\nJOIN section ON section.course_id = course.course_id	t	1360.202123458302	1374.2348456627371	0	2026-05-07 17:16:39.382082+00	1	t	1368.604982550931	1368.604982550931	f
379	3104259e-7ea7-44c4-a5b2-3c7247d5382f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q022	SELECT *\nFROM course\nWHERE title NOT LIKE '%Intro%' AND credits <= 3	t	1343.9984273553755	1360.202123458302	0	2026-05-07 17:15:10.29532+00	1	t	1299.854196335913	1299.854196335913	f
381	1fe6eca1-c969-406c-81f7-e0eeb2d0ea49	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q025	SELECT course.*, section.semester, section.year\nFROM course\nJOIN section ON course.course_id = section.course_id	t	1374.2348456627371	1389.4778851203303	0	2026-05-07 17:17:27.599828+00	1	t	1353.361943093338	1353.361943093338	f
384	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT COUNT (ID)\nfrom takes\nwhere year = '2009'	f	\N	\N	0	2026-05-08 00:26:03.296541+00	1	f	\N	\N	f
382	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT COUNT(distinct ID)\nFROM takes\nwhere year = '2009'	t	1389.4778851203303	1403.902238605186	0	2026-05-07 17:18:19.769735+00	1	t	1388.3934219232417	1388.3934219232417	t
383	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q011	SELECT COUNT(id), dept_name\nFROM instructor\nGROUP BY dept_name\nORDER BY COUNT(id) DESC	t	1403.902238605186	1418.511021105059	0	2026-05-07 17:19:02.575608+00	1	t	1398.357036991371	1398.357036991371	t
435	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q008	select avg(budget)\nfrom departmen\nwhere building = 'Taylor'	f	\N	\N	54978	2026-05-09 04:07:13.961636+00	1	f	\N	\N	f
385	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013	SELECT COUNT (distinct ID)\nfrom takes\nwhere year = '2009'	t	1418.511021105059	1424.8080552164895	0	2026-05-08 00:26:15.337945+00	2	t	1382.0963878118112	1382.0963878118112	t
386	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q017	SELECT dept_name\nFROM instructor\n  GROUP BY dept_name\nHAVING COUNT(id) > 2	t	1424.8080552164895	1438.6947333702453	0	2026-05-08 00:26:55.348184+00	1	t	1436.7560617045988	1436.7560617045988	t
388	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q015	SELECT ID, COUNT(course_id)\nFROM teaches\nGROUP BY ID	t	1438.6947333702453	1438.1072371469659	0	2026-05-08 00:28:59.689265+00	2	t	1452.8970004548578	1452.8970004548578	t
389	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q018	SELECT AVG(instructor.salary), instructor.dept_name\nFROM instructor\nJOIN department ON department.dept_name = instructor.dept_name\nWHERE budget>150000\nGROUP BY department.dept_name	f	\N	\N	0	2026-05-08 00:30:58.472459+00	1	f	\N	\N	f
391	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q012	SELECT dept_name\nFROM instructor\nWHERE salary > 90000	t	1436.4869710087373	1454.061012043844	0	2026-05-08 00:31:38.790999+00	1	t	1358.69624155024	1358.69624155024	t
392	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q019	SELECT dept_name, COUNT (course_id)\nFROM course\n  GROUP BY dept_name, course_id\nHAVING AVG(credits) > 3	f	\N	\N	0	2026-05-08 00:32:34.69374+00	1	f	\N	\N	f
396	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q016	SELECT course.title, COUNT(takes.ID)\nfrom takes\nJOIN course ON course.course_id=takes.course_id\nGROUP BY title	t	1446.4190309960318	1445.5871707705596	0	2026-05-08 00:34:35.085852+00	2	t	1476.2196197992864	1476.2196197992864	t
387	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q015	SELECT instructor.ID, COUNT(teaches.course_id)\nFROM instructor\nJOIN teaches ON instructor.id=teaches.id\nGROUP BY instructor.id, teaches.course_id	f	\N	\N	0	2026-05-08 00:28:16.545221+00	1	f	\N	\N	f
413	a76a7bcc-9522-42bb-b424-0f799b309a2b	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q025	SELECT course.*, section.semester, section.year\nFROM course\nJOIN section ON section.course_id=course.course_id	t	1503.108430318182	1524.238807639378	0	2026-05-08 00:48:02.360488+00	1	t	1331.1772100913404	1331.1772100913404	f
390	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q018	SELECT AVG(instructor.salary), instructor.dept_name\nFROM instructor\nJOIN department ON department.dept_name = instructor.dept_name\nWHERE budget>150000\nGROUP BY instructor.dept_name	t	1438.1072371469659	1436.4869710087373	0	2026-05-08 00:31:10.374956+00	2	t	1477.4037028465866	1477.4037028465866	t
393	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q019	SELECT dept_name, COUNT (course_id), AVG(credits)\nFROM course\n  GROUP BY dept_name\nHAVING AVG(credits) > 3	f	\N	\N	0	2026-05-08 00:33:26.68543+00	2	f	\N	\N	f
406	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q023	SELECT SUM(budget), building\nFROM department\n  GROUP BY building\nHAVING SUM(budget) > 50000	t	1460.6104089622759	1468.0430139589691	0	2026-05-08 00:42:36.063125+00	1	t	1544.4194889808348	1544.4194889808348	t
394	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q019	SELECT dept_name, COUNT (course_id), AVG(credits)\nFROM course\n  GROUP BY dept_name\nHAVING AVG(credits) >= 3	t	1454.061012043844	1446.4190309960318	0	2026-05-08 00:33:44.729587+00	3	t	1523.542390805041	1523.542390805041	t
395	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q016	SELECT title, COUNT(ID)\nfrom takes	f	\N	\N	0	2026-05-08 00:34:04.568819+00	1	f	\N	\N	f
397	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q021	SELECT time_slot.time_slot_id, COUNT(section.course_id)\nFROM time_slot\nLEFT JOIN section\nON time_slot.time_slot_id = section.time_slot_id\nGROUP BY time_slot.time_slot_id\nHAVING COUNT(section.course_id) > 0;	t	1445.5871707705596	1453.3484460263446	0	2026-05-08 00:36:15.5649+00	1	t	1516.947128028435	1516.947128028435	t
398	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q020	SELECT *\nCASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore'\n  WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior'\n  ELSE 'Final Year'\nEND AS Classification\nFROM student;	f	\N	\N	0	2026-05-08 00:37:35.076825+00	1	f	\N	\N	f
399	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q020	SELECT id, name, dept_name, tot_cred\nCASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore'\n  WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior'\n  ELSE 'Final Year'\nEND AS Classification\nFROM student;	f	\N	\N	0	2026-05-08 00:37:53.608879+00	2	f	\N	\N	f
414	86f6c99b-d9dc-4dfa-a135-af605ca0a2e5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH03-Q007	SELECT student.name\nFROM student\nJOIN advisor ON advisor.s_id=student.id\nJOIN instructor on advisor.i_id=instructor.id\nWHERE instructor.dept_name='Comp. Sci.'	f	\N	\N	0	2026-05-08 00:50:00.775763+00	1	f	\N	\N	f
400	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q020	SELECT id, name, dept_name, tot_cred, classification\nCASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore'\n  WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior'\n  ELSE 'Final Year'\nEND AS Classification\nFROM student;	f	1453.3484460263446	1441.3438386837206	0	2026-05-08 00:38:00.799921+00	3	t	1535.9563183006696	1535.9563183006696	t
407	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q024	SELECT course_id,sec_id,semester, year, COUNT(DISTINCT ID)\nFROM takes\nGROUP BY course_id, sec_id, semester, year;	t	1468.0430139589691	1474.7348261731727	0	2026-05-08 00:43:44.920272+00	1	t	1580.7812717820552	1580.7812717820552	t
401	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q007	SELECT COUNT(course_id) as jumlah_course, semester, year\nFROM section\nGROUP BY semester,year	t	1441.3438386837206	1453.5736933240626	0	2026-05-08 00:39:29.155558+00	1	t	1350.3171233327184	1350.3171233327184	t
402	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q022	SELECT dept_name, AVG(credits) as avg_cred\nFROM course\nORDER BY avg_cred desc\nGROUP BY dept_name\nLIMIT 3	f	\N	\N	0	2026-05-08 00:40:30.875018+00	1	f	\N	\N	f
403	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q022	SELECT dept_name, AVG(credits) as avg_cred\nFROM course\nGROUP BY dept_name\n  ORDER BY avg_cred desc\nLIMIT 3	f	\N	\N	0	2026-05-08 00:40:39.704388+00	2	f	\N	\N	f
404	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q022	SELECT dept_name, AVG(tot_cred) as avg_cred\nFROM student\nGROUP BY dept_name\n  ORDER BY avg_cred desc\nLIMIT 3	t	1453.5736933240626	1448.130972774711	0	2026-05-08 00:41:20.533714+00	3	t	1533.4209878207066	1533.4209878207066	t
405	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q014	SELECT AVG(tot_cred)\nFROM student\nWHERE tot_cred>50	t	1448.130972774711	1460.6104089622759	0	2026-05-08 00:41:46.813411+00	1	t	1347.67371097295	1347.67371097295	t
408	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q010	SELECT building, AVG(capacity)\nFROM classroom\nGROUP BY building\nHAVING AVG(capacity) > 80	t	1474.7348261731727	1488.4832646072787	0	2026-05-08 00:45:00.568956+00	1	t	1324.080443450874	1324.080443450874	t
409	a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q009	SELECT dept_name, SUM(credits)\nFROM course\nGROUP BY dept_name\nHAVING SUM(credits)>10	t	1488.4832646072787	1502.0540746373804	0	2026-05-08 00:45:53.880233+00	1	t	1345.13264953559	1345.13264953559	f
410	40877d9d-ac31-4e1b-b212-5905f285fce2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q025	SELECT course.*, section.semester, semester.year\nFROM course\nJOIN section ON course.course_id, section.course_id	f	\N	\N	0	2026-05-08 00:47:00.549732+00	1	f	\N	\N	f
411	40877d9d-ac31-4e1b-b212-5905f285fce2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q025	SELECT course.*, section.semester, semester.year\nFROM course\nJOIN section ON course.course_id=section.course_id	f	\N	\N	0	2026-05-08 00:47:06.162078+00	2	f	\N	\N	f
412	40877d9d-ac31-4e1b-b212-5905f285fce2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01-Q025	SELECT course.*, section.semester, section.year\nFROM course\nJOIN section ON course.course_id=section.course_id	t	1502.0540746373804	1503.108430318182	0	2026-05-08 00:47:26.311378+00	3	t	1352.3075874125363	1352.3075874125363	f
415	86f6c99b-d9dc-4dfa-a135-af605ca0a2e5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH03-Q007	SELECT student.name, student.id\nFROM student\nJOIN advisor ON advisor.s_id=student.id\nJOIN instructor on advisor.i_id=instructor.id\nWHERE instructor.dept_name='Comp. Sci.'	t	1524.238807639378	1524.4218025966245	0	2026-05-08 00:50:29.317201+00	2	t	1519.8170050427534	1519.8170050427534	f
416	86f6c99b-d9dc-4dfa-a135-af605ca0a2e5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH03-Q007	SELECT student.name, student.id\nFROM student\nJOIN advisor ON student.id=advisor.s_id\nJOIN instructor ON advisor.i_id=instructor.id	f	\N	\N	0	2026-05-08 00:51:26.283817+00	1	f	\N	\N	f
417	86f6c99b-d9dc-4dfa-a135-af605ca0a2e5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH03-Q007	SELECT student.name, student.id\nFROM student\nJOIN advisor ON student.id=advisor.s_id\nJOIN instructor ON advisor.i_id=instructor.id\nWHERE instructor.dept_name='Comp. Sci.'	t	1524.4218025966245	1524.6205960480734	0	2026-05-08 00:51:45.207904+00	2	t	1519.6182115913045	1519.6182115913045	f
418	9769d349-d8f5-4e61-928e-e442c436b4b5	53750c4a-a048-4037-b563-272d5c8b2567	CH01-Q023	select from where	f	\N	\N	8757	2026-05-08 14:05:06.956199+00	1	f	\N	\N	f
419	9769d349-d8f5-4e61-928e-e442c436b4b5	53750c4a-a048-4037-b563-272d5c8b2567	CH01-Q023	select from where	f	\N	\N	10451	2026-05-08 14:05:08.79078+00	2	f	\N	\N	f
420	9769d349-d8f5-4e61-928e-e442c436b4b5	53750c4a-a048-4037-b563-272d5c8b2567	CH01-Q023	select from where	f	1420	1401.6679067873085	324230	2026-05-08 14:10:22.478338+00	3	t	1341.5123576575256	1359.844450870217	f
421	ec27073f-9615-46f4-a6dd-f2a4b98b20b3	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q011	select dept_name, count(*)\nfrom instructor\norder by count(*)	f	\N	\N	44410	2026-05-08 14:11:12.45735+00	1	f	\N	\N	f
422	ec27073f-9615-46f4-a6dd-f2a4b98b20b3	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q011	select dept_name, count(*)\nfrom instructor\ngroup by dept_name\norder by count(*)	t	1401.6679067873085	1405.0756343745738	63289	2026-05-08 14:11:31.264889+00	2	t	1398.357036991371	1394.9493094041056	f
423	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q011	select from where	f	\N	\N	8012	2026-05-09 04:03:33.440414+00	1	f	\N	\N	f
424	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q011	select from where	f	1405.0756343745738	1389.6385695350843	10887	2026-05-09 04:03:36.497727+00	2	t	1394.9493094041056	1410.3863742435951	f
425	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q012	select from where	f	\N	\N	8324	2026-05-09 04:03:48.666328+00	1	f	\N	\N	f
426	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q012	select from where	f	1389.6385695350843	1373.3062025624092	10271	2026-05-09 04:03:50.614013+00	2	t	1358.69624155024	1375.0286085229152	f
427	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q013	select from where	f	\N	\N	2929	2026-05-09 04:03:56.81812+00	1	f	\N	\N	f
432	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q009	select dept_name, sum(credits)\nfrom course\nhaving SUM(credits) > 10	f	\N	\N	31354	2026-05-09 04:06:00.199579+00	1	f	\N	\N	f
436	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q008	select avg(budget)\nfrom department\nwhere building = 'Taylor'	t	1363.4293671131768	1364.7655633721397	57798	2026-05-09 04:07:16.766606+00	2	t	1325.5546662488418	1324.218469989879	f
439	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q017	select dept_name\nfrom instructor\nhaving COUNT(ID) > 2	f	\N	\N	29593	2026-05-09 04:09:43.376953+00	1	f	\N	\N	f
442	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q015	select ID, count(course_id)\nfrom teaches\ngroup by ID	t	1382.9707346295465	1400.0710121061993	44281	2026-05-09 04:11:05.713644+00	1	t	1452.8970004548578	1435.7967229782048	t
428	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q013	select from where	f	1373.3062025624092	1358.6856244134553	4412	2026-05-09 04:03:58.300249+00	2	t	1382.0963878118112	1396.716965960765	t
429	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q014	select from where	f	\N	\N	18036	2026-05-09 04:04:19.442322+00	1	f	\N	\N	f
433	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q009	select dept_name, sum(credits)\nfrom course\nhaving SUM(credits) > 10\ngroup by dept_name	f	\N	\N	39214	2026-05-09 04:06:08.042733+00	2	f	\N	\N	f
440	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q017	select dept_name\nfrom instructor\ngroup by dept_name\nhaving COUNT(ID) > 2	t	1365.4793048656063	1370.1150806503633	38743	2026-05-09 04:09:52.520087+00	2	t	1436.7560617045988	1432.1202859198418	t
430	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q014	select from where	f	1358.6856244134553	1343.2103610267286	19327	2026-05-09 04:04:20.710181+00	2	t	1347.67371097295	1363.1489743596767	t
434	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q009	select dept_name, sum(credits)\nfrom course\ngroup by dept_name\nhaving SUM(credits) > 10	t	1365.6666218346224	1363.4293671131768	47039	2026-05-09 04:06:15.772546+00	3	t	1345.13264953559	1347.3699042570356	f
437	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q010	select building, AVG(capacity)\nfrom classroom\nhaving AVG(capacity) > 80	f	\N	\N	100310	2026-05-09 04:09:00.157459+00	1	f	\N	\N	f
431	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q007	select semester, year, count(course_id) as jumlah_course\nfrom section\ngroup by semester, year	t	1343.2103610267286	1365.6666218346224	61684	2026-05-09 04:05:24.682087+00	1	t	1350.3171233327184	1327.8608625248246	f
461	633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01-Q021	Select * \nFROM student\nWhere name like '%n'\nAND name like '% %'	t	1258.7603948927276	1279.6485113323681	107692	2026-05-09 06:11:19.407188+00	1	t	1261.5139129013196	1240.625796461679	f
438	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q010	select building, AVG(capacity)\nfrom classroom\ngroup by building\nhaving AVG(capacity) > 80	t	1364.7655633721397	1365.4793048656063	112057	2026-05-09 04:09:11.918402+00	2	t	1324.080443450874	1323.3667019574075	t
462	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q021	select name\nfrom student\nwhere name like '% %' and '%n'	f	\N	\N	784378	2026-05-09 06:11:35.282217+00	2	f	\N	\N	f
441	0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02-Q004	select dept_name, max(tot_cred) as max_sks\nfrom student\ngroup by dept_name	t	1370.1150806503633	1382.9707346295465	23879	2026-05-09 04:10:19.20934+00	1	t	1275.1669981436207	1262.3113441644375	t
443	e0282baf-b400-4d1e-9ee3-9e536a65a413	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH01-Q023	SELECT i.name, t.course_id\nFROM instructor i\nJOIN teaches t ON i.ID = t.ID \nORDER BY i.name ASC, t.course_id ASC;	t	1340	1360.4809533534433	145829	2026-05-09 05:53:27.998028+00	1	t	1359.844450870217	1339.3634975167738	f
444	f045cc2f-ef0f-4229-8af9-f7fd2e0c5e71	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH01-Q017	select * from student where dept_name = 'Comp. Sci.' or tot_cred <50;	t	1260	1279.2936728728184	150236	2026-05-09 05:58:44.812482+00	1	t	1255.3846923896754	1236.091019516857	f
445	00283fab-9b77-4ebd-ac4b-0666a1eec277	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH01-Q025	SELECT c.title, s.semester, s.year\nFROM course c, section s \nWHERE c.course_id = s.course_id;	f	\N	\N	294924	2026-05-09 05:59:46.672926+00	1	f	\N	\N	f
446	633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01-Q017	Select name \nFROM student\nWHERE dept_name = 'Comp.Sci' OR tot_cred < 50	f	\N	\N	115059	2026-05-09 06:00:03.730954+00	1	f	\N	\N	f
447	00283fab-9b77-4ebd-ac4b-0666a1eec277	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH01-Q025	SELECT c.*, s.semester, s.year\nFROM course c, section s \nWHERE c.course_id = s.course_id;	t	1360.4809533534433	1359.2188005130322	336580	2026-05-09 06:00:28.299009+00	2	t	1331.1772100913404	1332.4393629317515	f
448	633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01-Q017	Select * \nFROM student\nWHERE dept_name = 'Comp.Sci' OR tot_cred < 50	f	\N	\N	155647	2026-05-09 06:00:44.434702+00	2	f	\N	\N	f
449	633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01-Q017	Select name\nFROM student\nWHERE dept_name = 'Comp.Sci.' OR tot_cred < 50	f	1260	1243.9693926656428	325190	2026-05-09 06:03:33.963203+00	3	t	1236.091019516857	1252.1216268512142	f
450	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q021	select name\nfrom student\nwhere name like '%n'	f	\N	\N	416521	2026-05-09 06:05:27.391485+00	1	f	\N	\N	f
451	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q009	SELECT dept_name, SUM(credits) AS total_sks\nFROM course\nGROUP BY dept_name\nHAVING SUM(credits) > 10;	f	\N	\N	284068	2026-05-09 06:05:34.815661+00	1	f	\N	\N	f
452	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q009	SELECT dept_name, SUM(credits) AS total_sks\nFROM course\nGROUP BY dept_name\nHAVING total_sks > 10;	f	\N	\N	310271	2026-05-09 06:06:01.042786+00	2	f	\N	\N	f
453	ca75e361-a3f6-4fc3-9afd-7b96a7a040e8	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH01-Q023	SELECT name, course_id\nFROM instructor, course\nWHERE instructor.ID = teaches.ID\nORDER BY name ASC	f	\N	\N	447975	2026-05-09 06:06:12.353494+00	1	f	\N	\N	f
454	ca75e361-a3f6-4fc3-9afd-7b96a7a040e8	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH01-Q023	SELECT name, course_id\nFROM instructor, teaches\nWHERE instructor.ID = teaches.ID\nORDER BY name ASC	t	1420	1416.579833177547	459741	2026-05-09 06:06:24.105629+00	2	t	1339.3634975167738	1342.7836643392268	f
455	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q009	SELECT d.dept_name, SUM(c.credits) AS total_sks\nFROM department d\nJOIN course c ON d.dept_name = c.dept_name\nGROUP BY d.dept_name\nHAVING SUM(c.credits) > 10;	f	1359.2188005130322	1343.707440774442	418120	2026-05-09 06:07:48.874551+00	3	t	1347.3699042570356	1362.8812639956259	f
456	9d2e155f-2de5-4799-943d-07a362851a09	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH01-Q023	SELECT name, course_id FROM instructor, teaches\nWHERE instructor.ID = teaches.ID;	t	1340	1355.1201778787135	598898	2026-05-09 06:08:51.821657+00	1	t	1342.7836643392268	1327.6634864605132	f
457	633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01-Q016	Select course_id, credits, (credits*2) as double_credits\nFrom course	t	1243.9693926656428	1258.7603948927276	346546	2026-05-09 06:09:23.637722+00	1	t	1239.1281951292742	1224.3371929021894	f
458	f045cc2f-ef0f-4229-8af9-f7fd2e0c5e71	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH01-Q021	select * from student where nameselect * from student where name like '%n' and name like '% %'	f	\N	\N	676322	2026-05-09 06:10:03.570326+00	1	f	\N	\N	f
460	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q014	SELECT AVG(tot_cred) AS rata_rata_tot_sks\nFROM student\nWHERE tot_cred > 50;	f	\N	\N	157093	2026-05-09 06:10:45.81778+00	1	f	\N	\N	f
459	f045cc2f-ef0f-4229-8af9-f7fd2e0c5e71	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH01-Q021	select * from student where name like '%n' and name like '% %'	t	1279.2936728728184	1278.4922214546355	692905	2026-05-09 06:10:20.084057+00	2	t	1260.7124614831366	1261.5139129013196	f
463	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q014	SELECT AVG(tot_cred) \nFROM student\nWHERE tot_cred > 50;	t	1343.707440774442	1345.8439492771915	213465	2026-05-09 06:11:42.184554+00	2	t	1363.1489743596767	1361.012465856927	f
464	f045cc2f-ef0f-4229-8af9-f7fd2e0c5e71	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH01-Q022	select * from course where title not like '%intro%' and credits <= 3	f	\N	\N	103945	2026-05-09 06:13:07.125131+00	1	f	\N	\N	f
465	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q021	select name\nfrom student\nwhere name like '% %' and name ='%n'	t	1260	1254.1644143173346	894085	2026-05-09 06:13:24.966718+00	3	t	1240.625796461679	1246.4613821443445	f
466	f045cc2f-ef0f-4229-8af9-f7fd2e0c5e71	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH01-Q022	select * from course where title not like '%Intro%' and credits <= 3	t	1278.4922214546355	1281.9849766271393	128557	2026-05-09 06:13:31.888833+00	2	t	1299.854196335913	1296.3614411634092	f
467	633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01-Q022	Select * \nFROM course\nWHERE title not like %Intro%\nAND credits <= 3	f	\N	\N	131865	2026-05-09 06:13:42.175908+00	1	f	\N	\N	f
468	633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01-Q022	Select * \nFROM course\nWHERE title not like '%Intro%'\nAND credits <= 3	t	1279.6485113323681	1282.7609904790577	140568	2026-05-09 06:13:50.859685+00	2	t	1296.3614411634092	1293.2489620167196	f
469	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q007	SELECT semester, year, COUNT(course_id) AS jumlah_course\nFROM section\nGROUP BY semester;	f	\N	\N	142731	2026-05-09 06:14:10.147015+00	1	f	\N	\N	f
470	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q017	SELECT dept_name, COUNT(DISTINCT ID)\nFROM instructor\nGROUP BY dept_name\nHAVING COUNT(DISTINCT ID) > 2	f	\N	\N	205433	2026-05-09 06:14:33.95418+00	1	f	\N	\N	f
472	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q017	SELECT dept_name\nFROM instructor\nGROUP BY dept_name\nHAVING COUNT(DISTINCT ID) > 2	t	1416.579833177547	1418.2747613698577	231704	2026-05-09 06:15:00.110191+00	2	t	1432.1202859198418	1430.425357727531	f
471	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q007	SELECT semester, year, COUNT(course_id) AS jumlah_course\nFROM section\nGROUP BY semester, year;	t	1345.8439492771915	1346.988774599461	171965	2026-05-09 06:14:39.378271+00	2	t	1327.8608625248246	1326.716037202555	t
473	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q018	select name\nfrom student\nwhere student = 'Comp. Sci.' and tot.cred > 80	f	\N	\N	93244	2026-05-09 06:15:01.060526+00	1	f	\N	\N	f
474	633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01-Q018	SELECT * \nfrom student\nwhere dept_name = 'Comp. Sci.' AND credits > 80	f	\N	\N	70818	2026-05-09 06:15:05.903025+00	1	f	\N	\N	f
475	f045cc2f-ef0f-4229-8af9-f7fd2e0c5e71	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH01-Q024	select * from department where budget > 10000000 and dept_name like '%tech%'	t	1281.9849766271393	1304.2596460848883	92149	2026-05-09 06:15:06.190472+00	1	t	1306.0925264923876	1283.8178570346386	f
479	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q015	SELECT ID, COUNT(course_id)\nFROM instructor, teaches\nWHERE instructor.ID = teaches.ID\nGROUP BY ID	f	\N	\N	104290	2026-05-09 06:16:46.368938+00	1	f	\N	\N	f
476	633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01-Q018	SELECT * \nfrom student\nwhere dept_name = 'Comp. Sci.' AND tot_cred > 80	t	1282.7609904790577	1284.6227417207238	80159	2026-05-09 06:15:15.177978+00	2	t	1249.4008347518663	1247.5390835102003	t
477	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q018	select name\nfrom student\nwhere student = 'Comp. Sci.' and tot_cred > 80	f	\N	\N	111518	2026-05-09 06:15:19.375484+00	2	f	\N	\N	f
478	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q018	select name\nfrom student\nwhere dept_name = 'Comp. Sci.' and tot_cred > 80	f	1254.1644143173346	1238.878410459455	143455	2026-05-09 06:15:51.28423+00	3	t	1247.5390835102003	1262.82508736808	f
489	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q012	SELECT dept_name\nFROM instructor\nGROUP BY dept_name\nHAVING MAX(salary) > 90000;	t	1366.4932562949618	1368.165884069948	157299	2026-05-09 06:19:37.762793+00	2	t	1375.0286085229152	1373.355980747929	t
496	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q009	SELECT dept_name, credits\nFROM (SELECT dept_name, sum (credits) AS credits\n  FROM course\n  GROUP BY dept_name)\nWHERE credits > 10;	f	\N	\N	660363	2026-05-09 06:21:55.664026+00	2	f	\N	\N	f
500	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q011	SELECT dept_name, COUNT(*) \nFROM instructor\nGROUP BY dept_name\nORDER BY COUNT(*) DESC;	t	1368.165884069948	1369.6403906013015	217906	2026-05-09 06:23:21.959346+00	2	t	1390.9055254821358	1389.4310189507823	t
503	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q010	Select building, avg(capacity)\nfrom classroom\nwhere avg(capacity) > 80\ngroup by building	f	\N	\N	294165	2026-05-09 06:24:21.219468+00	2	f	\N	\N	f
481	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q015	SELECT ID, COUNT(course_id)\nFROM instructor, teaches\nWHERE instructor.ID = teaches.ID\nGROUP BY instructor.ID	f	\N	\N	114061	2026-05-09 06:16:56.158242+00	2	f	\N	\N	f
480	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q010	SELECT building, AVG(capacity)\nFROM classroom\nGROUP BY building\nHAVING AVG(capacity) > 80;	t	1346.988774599461	1366.4932562949618	115908	2026-05-09 06:16:50.481943+00	1	t	1323.3667019574075	1303.8622202619067	t
483	633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01-Q020	SELECT DISTINCT building, room_no\nFROM section	t	1284.6227417207238	1296.9477681508426	128605	2026-05-09 06:17:25.018493+00	1	t	1246.1484887474155	1233.8234623172966	t
490	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q008	select avg (budget) from department where building = 'Taylor'	t	1304.2596460848883	1305.7425311524676	258524	2026-05-09 06:19:42.379313+00	2	t	1324.218469989879	1322.7355849222997	t
495	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q007	select semester, year, count (course_id) from section group by semester, year	f	\N	\N	115388	2026-05-09 06:21:39.35024+00	1	f	\N	\N	f
499	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q011	SELECT dept_name, COUNT(*) AS jumlah_dosen\nFROM instructor\nGROUP BY dept_name\nORDER BY COUNT(*) DESC;	f	\N	\N	205421	2026-05-09 06:23:09.471144+00	1	f	\N	\N	f
482	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q015	SELECT instructor.ID, COUNT(teaches.course_id)\nFROM instructor, teaches\nWHERE instructor.ID = teaches.ID\nGROUP BY instructor.ID	t	1418.2747613698577	1415.6048145638915	142579	2026-05-09 06:17:24.650475+00	3	t	1435.7967229782048	1438.466669784171	f
485	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q008	select avg (budget) from department where dept_name = 'Taylor'	f	\N	\N	184724	2026-05-09 06:18:28.584781+00	1	f	\N	\N	f
487	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q020	select distinct building, distinct room_no\nfrom classroom	f	\N	\N	182411	2026-05-09 06:19:13.207664+00	1	f	\N	\N	f
491	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q020	select distinct building, room_no\nfrom classroom	t	1238.878410459455	1239.8981212028557	217471	2026-05-09 06:19:48.228507+00	2	t	1233.8234623172966	1232.8037515738959	f
498	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q016	SELECT title, COUNT (student.ID)\nFROM course, takes, student\nWHERE course.course_id = takes.course_id AND takes.ID = student.ID\nGROUP BY course.title	t	1455.3029748925744	1458.9519996275878	116862	2026-05-09 06:23:04.06061+00	2	t	1476.2196197992864	1472.570595064273	t
501	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q010	Select building, avg(capacity)\nfrom classroom\ngroup by building	f	\N	\N	251446	2026-05-09 06:23:38.487567+00	1	f	\N	\N	f
484	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q009	SELECT dept_name, tot_cred\nFROM (SELECT dept_name, sum (credits) AS tot_cred\n  FROM course\n  GROUP BY dept_name)\nWHERE tot_cred > 10;	f	\N	\N	398496	2026-05-09 06:17:33.802566+00	1	f	\N	\N	f
492	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q011	SELECT dept_name, COUNT(ID)\nFROM instructor\nGROUP BY dept_name\nORDER BY COUNT(ID) ASC	t	1415.6048145638915	1435.0856633253509	143129	2026-05-09 06:19:50.6561+00	1	t	1410.3863742435951	1390.9055254821358	f
494	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q017	select name\nfrom student\nwhere dept_name = 'Comp. Sci.' or tot_cred < 50	f	\N	\N	94611	2026-05-09 06:21:25.664623+00	1	f	\N	\N	f
502	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q017	select *\nfrom student\nwhere dept_name = 'Comp. Sci.' or tot_cred < 50	t	1239.8981212028557	1240.9411868895772	230861	2026-05-09 06:23:41.923434+00	2	t	1252.1216268512142	1251.0785611644926	f
486	633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01-Q024	SELECT dept_name from department\nwhere dept_name like '%tech%' AND budget > 10000000	t	1296.9477681508426	1310.5561587321845	100694	2026-05-09 06:19:07.428432+00	1	t	1283.8178570346386	1270.2094664532967	f
488	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q012	SELECT dept_name\nFROM instructor\nGROUP BY dept_name\nHAVING salary > 90000;	f	\N	\N	137926	2026-05-09 06:19:18.415486+00	1	f	\N	\N	f
493	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q013	SELECT COUNT(DISTINCT student.ID)\nFROM student, takes\nWHERE student.ID = takes.ID AND takes.year = '2009'	t	1435.0856633253509	1455.3029748925744	71096	2026-05-09 06:21:04.4814+00	1	t	1396.716965960765	1376.4996543935415	t
497	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q016	SELECT title, COUNT (student.ID)\nFROM course, takes, student\nWHERE course.course_id = takes.course_id AND takes.ID = student.ID	f	\N	\N	104109	2026-05-09 06:22:51.367184+00	1	f	\N	\N	f
516	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q010	select building, avg(capacity) from classroom group by building having avg(capacity) > 80	t	1306.6469318802388	1309.013807308831	149416	2026-05-09 06:28:30.94564+00	2	t	1309.1511850626807	1306.7843096340885	t
504	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q008	SELECT AVG(budget)\nFROM department\nWHERE building = 'Taylor';	t	1369.6403906013015	1382.9688041917714	66485	2026-05-09 06:24:33.5043+00	1	t	1322.7355849222997	1309.4071713318299	t
505	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q009	SELECT dept_name, sum (credits) AS credits\nFROM course\nGROUP BY dept_name)\nWHERE credits > 10;	f	1355.1201778787135	1340.4551951790208	833332	2026-05-09 06:24:48.679199+00	3	t	1362.8812639956259	1377.5462466953186	f
506	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q010	Select building, avg(capacity)\nfrom classroom\ngroup by building\nhaving avg (capacity) > 80	t	1310.5561587321845	1305.2671939314105	328749	2026-05-09 06:24:55.771175+00	3	t	1303.8622202619067	1309.1511850626807	t
507	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q024	select dept_name\nfrom department\nwhere dept_name like '%tech%' and budget > 10000000	t	1240.9411868895772	1255.5910886074107	109526	2026-05-09 06:25:34.37494+00	1	t	1270.2094664532967	1255.5595647354633	t
524	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q016	SELECT c.title, COUNT(t.ID)\nFROM course c\nJOIN takes t ON c.course_id = t.course_id\nGROUP BY c.title;	t	1410.6769009002294	1424.7172558532777	186124	2026-05-09 06:32:04.656935+00	1	t	1472.570595064273	1458.5302401112247	t
508	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q007	select semester, year, count (course_id) as jumlah_course  from section group by semester, year	t	1305.7425311524676	1306.6469318802388	376075	2026-05-09 06:26:00.066395+00	2	t	1326.716037202555	1325.8116364747839	t
509	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q007	select semester, year, count(course_id) as jumlah_course\nfrom section\ngroup by semester	f	\N	\N	115315	2026-05-09 06:26:56.236381+00	1	f	\N	\N	f
517	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q016	select course_id, credits, credits * 2 as double_credits\nfrom course	t	1255.5910886074107	1266.8819277828668	190601	2026-05-09 06:28:50.299698+00	1	t	1224.3371929021894	1213.0463537267333	t
510	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q007	select semester, year, count(course_id) as jumlah_course\nfrom section\ngroup by semester, year	t	1305.2671939314105	1308.730616474272	128168	2026-05-09 06:27:09.058379+00	2	t	1325.8116364747839	1322.3482139319224	t
511	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q021	SELECT time_slot_id, COUNT (sec_id)\nFROM section\nWHERE sec_id > 0	f	\N	\N	248047	2026-05-09 06:27:14.222682+00	1	f	\N	\N	f
512	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q013	SELECT COUNT(DISTINCT ID)\nFROM takes\nWHERE year = 2009;	t	1382.9688041917714	1395.5030886079464	163977	2026-05-09 06:27:19.832225+00	1	t	1376.4996543935415	1363.9653699773664	t
513	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q021	SELECT time_slot_id, COUNT(sec_id)\nFROM section\nWHERE COUNT(sec_id) > 0\nGROUP BY time_slot_id	f	\N	\N	272197	2026-05-09 06:27:38.388626+00	2	f	\N	\N	f
514	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q010	select building, avg(capacity) group by building having avg(capacity) > 80	f	\N	\N	129471	2026-05-09 06:28:11.036314+00	1	f	\N	\N	f
518	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q017	SELECT dept_name\nFROM instructor\nGROUP BY dept_name\nHAVING COUNT(ID) > 2;	t	1395.5030886079464	1410.6769009002294	91398	2026-05-09 06:28:53.248289+00	1	t	1430.425357727531	1415.251545435248	t
515	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q008	select avg(budget)\nfrom department\ngroup by building\nhaving building = 'Taylor'	t	1308.730616474272	1330.5689556585326	73029	2026-05-09 06:28:27.250104+00	1	t	1309.4071713318299	1287.5688321475693	t
519	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q004	select dept_name, max(credits) as max_sks from course group by dept_name	f	\N	\N	108245	2026-05-09 06:30:20.720248+00	1	f	\N	\N	f
521	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q022	select title\nfrom course\nwhere title not like '%Intro%' and credits <= 3	f	\N	\N	129984	2026-05-09 06:31:03.900952+00	1	f	\N	\N	f
520	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q007	SELECT semester, year, count(course_id) AS jumlah_course\nFROM section\nGROUP BY semester, year;	t	1340.4551951790208	1354.67416094911	345591	2026-05-09 06:30:41.012309+00	1	t	1322.3482139319224	1308.1292481618332	f
522	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q021	SELECT time_slot_id, COUNT(sec_id)\nFROM section\nGROUP BY time_slot_id\nHAVING COUNT(sec_id) > 2	f	1458.9519996275878	1450.605900946745	499630	2026-05-09 06:31:25.785797+00	3	t	1516.947128028435	1525.2932267092779	t
526	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q019	SELECT dept_name, COUNT(course_id), AVG(credits)\nFROM course\nGROUP BY dept_name\nHAVING AVG(credits) > 2	t	1450.605900946745	1466.4690176638562	110293	2026-05-09 06:33:19.55433+00	1	t	1523.542390805041	1507.6792740879296	t
523	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q022	select *\nfrom course\nwhere title not like '%Intro%' and credits <= 3	t	1266.8819277828668	1269.0486084477268	159077	2026-05-09 06:31:33.003498+00	2	t	1293.2489620167196	1291.0822813518596	t
525	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q019	select name\nfrom instructor\nwhere salary between 60000 and 90000 \nwhere salary > 0	f	\N	\N	62364	2026-05-09 06:32:40.33358+00	1	f	\N	\N	f
527	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q019	select *\nfrom instructor\nwhere salary between 60000 and 90000 \nwhere salary > 0	f	\N	\N	104817	2026-05-09 06:33:22.792693+00	2	f	\N	\N	f
528	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q014	SELECT avg(tot_cred)\nFROM student\nWHERE tot_cred > 50;	t	1354.67416094911	1375.000647215534	131571	2026-05-09 06:33:33.396334+00	1	t	1361.012465856927	1340.6859795905032	f
529	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q013	Select count(distinct name) \nfrom student, takes\nwhere student.ID = takes.ID\nAND year = 2009	t	1330.5689556585326	1347.0063704665508	338793	2026-05-09 06:34:08.224933+00	1	t	1363.9653699773664	1347.5279551693482	t
532	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q012	select dept_name\nfrom instructor\nwhere salary > 90000	t	1347.0063704665508	1369.954768524412	72901	2026-05-09 06:35:23.760222+00	1	t	1373.355980747929	1350.4075826900678	t
530	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q019	select *\nfrom instructor\nwhere salary between 60000 and 90000	t	1269.0486084477268	1265.0363698130052	155411	2026-05-09 06:34:13.303245+00	3	t	1211.4488103082122	1215.4610489429338	t
531	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q004	select dept_name, max(tot_cred) from student group by dept_name	f	\N	\N	373842	2026-05-09 06:34:46.287138+00	2	f	\N	\N	f
533	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q015	SELECT i.ID, COUNT(t.course_id)\nFROM instructor i\nJOIN teaches t ON i.ID = t.ID \nGROUP BY i.ID;	t	1424.7172558532777	1437.6147493374663	174902	2026-05-09 06:35:58.085668+00	1	t	1438.466669784171	1425.5691762999825	t
534	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q004	select dept_name, max(tot_cred) as max_sks from student group by dept_name	t	1309.013807308831	1302.0095568909658	453935	2026-05-09 06:36:06.38536+00	3	t	1262.3113441644375	1269.3155945823028	t
535	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q012	SELECT DISTINCT dept_name\nFROM instructor\nGROUP BY dept_name\nHAVING salary > 90000;	f	\N	\N	175157	2026-05-09 06:36:31.798197+00	1	f	\N	\N	f
536	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q014	select avg(tot_cred) from student where tot_cred > 50	t	1302.0095568909658	1317.9627982266227	57769	2026-05-09 06:37:06.946456+00	1	t	1340.6859795905032	1324.7327382548463	t
544	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q017	select dept_name from instructor\nwhere count(id) > 2\ngroup by dept_name	f	\N	\N	110231	2026-05-09 06:39:02.376766+00	1	f	\N	\N	f
537	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q011	select dept_name, count(ID) \nFROM instructor\ngroup by dept_name\norder by count(ID) desc	t	1369.954768524412	1392.105996181901	89625	2026-05-09 06:37:09.918932+00	1	t	1389.4310189507823	1367.2797912932933	t
540	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q012	select dept_name from department where budget > 90000	f	\N	\N	49623	2026-05-09 06:37:58.339916+00	1	f	\N	\N	f
538	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q018	SELECT dept_name, AVG(salary)\nFROM instructor\nWHERE dept_name in (SELECT dept_name FROM department WHERE budget > 150000)	f	\N	\N	245375	2026-05-09 06:37:27.48749+00	1	f	\N	\N	f
541	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q012	SELECT dept_name\nFROM instructor\nGROUP BY instructor.salary\nHAVING max (salary) > 90000;	f	1375.000647215534	1358.9406490346626	276686	2026-05-09 06:38:13.29621+00	2	t	1350.4075826900678	1366.4675808709392	f
542	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q012	select dept_name from instructor where salary > 90000	t	1317.9627982266227	1321.4925582058247	85732	2026-05-09 06:38:34.459553+00	2	t	1366.4675808709392	1362.9378208917371	t
545	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q017	select dept_name from instructor\nhaving count(id) > 2\ngroup by dept_name	f	\N	\N	120048	2026-05-09 06:39:12.172085+00	2	f	\N	\N	f
547	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q023	select name, title\nfrom instructor, course\nwhere instructor.dept_name = department.dept_name = course.dept_name\norder by instructor.name asc\norder by course.course_id asc	f	\N	\N	329078	2026-05-09 06:39:45.860955+00	1	f	\N	\N	f
549	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q020	SELECT name, tot_cred,\nCASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore'\n  WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior'\n  ELSE 'Final Year'\nEND AS classification\nFROM student;	t	1467.1930493295877	1481.8176719313985	166455	2026-05-09 06:40:30.339923+00	1	t	1535.9563183006696	1521.3316956988588	t
539	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q018	SELECT dept_name, AVG(salary)\nFROM instructor\nWHERE dept_name in (SELECT dept_name FROM department WHERE budget > 150000)\nGROUP BY instructor.dept_name	t	1466.4690176638562	1467.1930493295877	259059	2026-05-09 06:37:41.157016+00	2	t	1477.4037028465866	1476.6796711808552	t
546	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q017	select dept_name from instructor\ngroup by dept_name\nhaving count(id) > 2	t	1392.105996181901	1390.563581549545	131142	2026-05-09 06:39:23.236016+00	3	t	1415.251545435248	1416.793960067604	t
548	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q023	select name, title\nfrom instructor, course\nwhere instructor.dept_name = department.dept_name \nwhere departement.dept_name = course.dept_name\norder by instructor.name asc\norder by course.course_id asc	f	\N	\N	359976	2026-05-09 06:40:16.749617+00	2	f	\N	\N	f
550	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q015	select ID, count(course_id)\nfrom teaches\ngroup by ID	t	1390.563581549545	1405.134608021055	121656	2026-05-09 06:41:26.011668+00	1	t	1425.5691762999825	1410.9981498284724	t
564	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q009	SELECT dept_name, SUM(credits)\nFROM course\nGROUP BY dept_name\nHAVING SUM(credits) > 10	t	1488.931691819019	1500.2383209127925	79647	2026-05-09 06:45:19.591653+00	1	t	1377.5462466953186	1366.2396176015452	f
543	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q019	SELECT dept_name, COUNT(course_Id), AVG(credits)\nFROM course\nGROUP BY dept_name\nHAVING AVG(credits) >= 3;	t	1437.6147493374663	1452.3928689840186	160580	2026-05-09 06:38:42.580547+00	1	t	1507.6792740879296	1492.9011544413772	t
551	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q023	SELECT building, SUM(budget)\nFROM department\nGROUP BY dept_name\nHAVING SUM(budget) > 50000	f	\N	\N	56764	2026-05-09 06:41:29.32162+00	1	f	\N	\N	f
565	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q016	select course.title, count(ID)\nfrom takes, course\ngroup by takes.course_id\nhaving takes.course_id = course.course_id	f	\N	\N	286727	2026-05-09 06:46:15.165835+00	2	f	\N	\N	f
552	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q023	SELECT building, SUM(budget)\nFROM department\nGROUP BY building\nHAVING SUM(budget) > 50000	t	1481.8176719313985	1485.8109378091629	78931	2026-05-09 06:41:51.506071+00	2	t	1544.4194889808348	1540.4262231030705	t
553	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q021	SELECT t.time_slot_id, COUNT(s.course_id)\nFROM time_slot t\nLEFT JOIN section s ON t.time_slot_id = s.time_slot_id\nGROUP BY t.time_slot_id\nHAVING COUNT(s.course_id) >=1;	t	1452.3928689840186	1466.3948102308013	203302	2026-05-09 06:42:14.309218+00	1	t	1525.2932267092779	1511.2912854624951	t
554	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q013	select distinct count(ID) from takes where year = 2009	f	\N	\N	280401	2026-05-09 06:43:16.367861+00	1	f	\N	\N	f
573	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q023	SELECT building, SUM(budget)\nFROM department\nGROUP BY building\nHAVING SUM(budget) >50000;	t	1494.0684759746123	1509.925637043265	73463	2026-05-09 06:48:39.626335+00	1	t	1540.4262231030705	1524.5690620344178	f
555	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q023	select name, course_ID\nfrom instructor, teaches\nwhere instructor.ID = teaches.ID\norder by instructor.name asc, teaches.course_id asc	t	1265.0363698130052	1263.4863173907413	541911	2026-05-09 06:43:18.65431+00	3	t	1327.6634864605132	1329.2135388827771	t
556	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q011	SELECT dept_name, count(*) FROM instructor\nGROUP BY dept_name\nORDER BY COUNT(*) DESC;	t	1358.9406490346626	1374.4383096257202	295410	2026-05-09 06:43:25.080824+00	1	t	1367.2797912932933	1351.7821307022357	f
557	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q022	SELECT dept_name, AVG(tot_cred) as avg_cred\nFROM student\nGROUP BY dept_name\nORDER BY avg_cred asc\nLIMIT 3	f	\N	\N	102241	2026-05-09 06:43:36.189382+00	1	f	\N	\N	f
566	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q016	select course.title, count(ID)\nfrom takes, course\ngroup by course.title\nhaving takes.course_id = course.course_id	f	1405.134608021055	1396.6594714260236	305530	2026-05-09 06:46:34.002369+00	3	t	1458.5302401112247	1467.0053767062561	t
558	3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02-Q022	SELECT dept_name, AVG(tot_cred) as avg_cred\nFROM student\nGROUP BY dept_name\nORDER BY avg_cred desc\nLIMIT 3	t	1485.8109378091629	1488.931691819019	124106	2026-05-09 06:43:57.976602+00	2	t	1533.4209878207066	1530.3002338108504	t
559	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q013	select count(distinct ID) from takes where year = 2009	t	1321.4925582058247	1322.2405176637328	339740	2026-05-09 06:44:15.5209+00	2	t	1347.5279551693482	1346.77999571144	t
560	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q015	select *\nfrom classroom\nwhere capacity > 150\norder by desc	f	\N	\N	81112	2026-05-09 06:44:43.258861+00	1	f	\N	\N	f
561	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q020	SELECT name, tot_cred,\nCASE\n  WHEN tot_cred < 30 THEN 'Freshman'\n  WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore'\n  WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior'\n  ELSE 'Final Year'\nEND AS classification\nFROM student;	t	1466.3948102308013	1480.8761134181598	154343	2026-05-09 06:44:57.865796+00	1	t	1521.3316956988588	1506.8503925115003	t
562	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q016	select course.title, count(ID)\nfrom takes, course\ngroup by course_id\nhaving takes.course_id = course.course_id	f	\N	\N	218088	2026-05-09 06:45:06.551254+00	1	f	\N	\N	f
567	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q014	select *\nfrom course\nwhere credits > 3\norder by title asc	t	1263.471464793721	1275.413331185105	83828	2026-05-09 06:46:37.621604+00	1	t	1179.1072375543176	1167.1653711629335	t
563	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q015	select *\nfrom classroom\nwhere capacity > 150\norder by capacity desc	t	1263.4863173907413	1263.471464793721	108608	2026-05-09 06:45:10.704944+00	2	t	1195.6238469861682	1195.6386995831886	t
568	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q011	select dept_name, count(ID) from instructor group by dept_name order by asc	f	\N	\N	145988	2026-05-09 06:46:45.098438+00	1	f	\N	\N	f
577	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q017	SELECT dept_name FROM instructor\nGROUP BY dept_name\nHAVING COUNT(*) > 2;	t	1391.5370346373256	1405.6407095360858	131100	2026-05-09 06:50:32.45414+00	1	t	1416.793960067604	1402.690285168844	f
569	e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q018	SELECT dept_name, AVG(salary)\nFROM instructor\nWHERE dept_name IN (\n  SELECT dept_name\n  FROM department\n  WHERE budget > 150000\n)\nGROUP BY dept_name;	t	1480.8761134181598	1494.0684759746123	134343	2026-05-09 06:47:19.542718+00	1	t	1476.6796711808552	1463.4873086244027	t
570	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q015	SELECT ID, count (course_id)\nFROM teaches\nGROUP BY ID;	t	1374.4383096257202	1391.5370346373256	282463	2026-05-09 06:48:17.213364+00	1	t	1410.9981498284724	1393.899424816867	f
571	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q014	select avg(tot_cred)\nfrom student\nwhere tot)cred > 50	f	\N	\N	109867	2026-05-09 06:48:26.720975+00	1	f	\N	\N	f
574	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q011	select dept_name, count(ID) from instructor group by dept_name order by dept_name desc	t	1322.2405176637328	1323.1565304668097	293222	2026-05-09 06:49:12.289078+00	2	t	1351.7821307022357	1350.8661178991588	t
572	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q014	select avg(tot_cred)\nfrom student\nwhere tot_cred > 50	t	1396.6594714260236	1396.4473404068078	117099	2026-05-09 06:48:33.896469+00	2	t	1324.7327382548463	1324.944869274062	t
575	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q025	select course.title, section.semester, section.year\nfrom course, section\nwhere course.course_ID = section.course_ID	f	\N	\N	163213	2026-05-09 06:49:26.745365+00	1	f	\N	\N	f
576	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q025	select course.*, section.semester, section.year\nfrom course, section\nwhere course.course_ID = section.course_ID	t	1275.413331185105	1277.3252379368473	207755	2026-05-09 06:50:11.27934+00	2	t	1332.4393629317515	1330.5274561800093	t
578	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q009	select dept_name, sum(credits) from course group by dept_name having sum(credits) > 10	t	1323.1565304668097	1338.5632443567838	91350	2026-05-09 06:50:46.428244+00	1	t	1366.2396176015452	1350.8329037115711	t
579	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q011	select *\nfrom student\nwhere tot_cred is null	f	\N	\N	84441	2026-05-09 06:51:38.631031+00	1	f	\N	\N	f
580	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q011	select name\nfrom student\nwhere tot_cred is null	f	\N	\N	108558	2026-05-09 06:52:02.73779+00	2	f	\N	\N	f
581	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q015	select ID, count(course_id) from teaches group by ID	t	1338.5632443567838	1353.4051155335042	136875	2026-05-09 06:53:07.634762+00	1	t	1393.899424816867	1379.0575536401466	t
582	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q018	select t.dept_name, avg(t.salary)\nfrom instructor t, department d\ngroup by t.dept_name\nhaving d.budget > 150000	f	\N	\N	276679	2026-05-09 06:53:13.322428+00	1	f	\N	\N	f
583	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q018	SELECT dept_name, avg(salary)\nFROM (SELECT dept_name, avg(salary)\n  FROM instructor\n  GROUP BY dept_name)\nHAVING avg(salary) > 150000;	f	\N	\N	181117	2026-05-09 06:53:36.525679+00	1	f	\N	\N	f
584	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q011	select *\nfrom student\nwhere tot_cred = 0	t	1277.3252379368473	1272.4573908532002	212263	2026-05-09 06:53:46.458507+00	3	t	1140.6777555070485	1145.5456025906956	t
590	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q009	select *\nfrom student\nwhere dept_name = 'Comp. Sci.' or 'Physics'	f	\N	\N	49179	2026-05-09 06:55:54.449385+00	1	f	\N	\N	f
585	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q018	SELECT dept_name, avg (salary)\nFROM (SELECT dept_name, avg (salary)\n  FROM instructor\n  GROUP BY dept_name)\nHAVING avg (salary) > 150000;	f	\N	\N	208745	2026-05-09 06:54:04.152441+00	2	f	\N	\N	f
596	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q008	select *\nfrom student\nwhere name like '%ez'	t	1278.1701223245113	1285.9122010359608	32913	2026-05-09 06:57:02.904821+00	1	t	1086.4418003931653	1078.6997216817158	t
599	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q007	SELECT *\nFROM student\nWHERE name IN (SELECT student.name\nFROM student, advisor, instructor\nWHERE student.ID = advisor.s_id\n  AND advisor.i_id = instructor.ID\n  AND instructor.dept_name = 'Comp. Sci.')	f	1500.2383209127925	1486.0741513668922	540766	2026-05-09 06:58:41.123441+00	3	t	1519.6182115913045	1533.7823811372048	f
586	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q013	select *\nfrom student\norder by tot_cred desc	t	1272.4573908532002	1281.471697729035	39224	2026-05-09 06:54:27.266015+00	1	t	1157.3690023142676	1148.3546954384328	t
587	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q010	select *\nfrom student\nwhere tot_cred between 500 and 100	f	\N	\N	27838	2026-05-09 06:54:57.033074+00	1	f	\N	\N	f
591	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q007	SELECT student.name\nFROM student, advisor, instructor\nWHERE student.ID = advisor.s_id\n  AND advisor.i_id = instructor.ID\n  AND instructor.dept_name = 'Comp. Sci.'	f	\N	\N	377367	2026-05-09 06:55:57.719707+00	2	f	\N	\N	f
595	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q017	select d.dept_name, count(i.ID)\nfrom department d, instructor i\nwhere d.dept_name = i.dept_name\ngroup by d.dept_name\nhaving count(i.ID) > 2	f	1353.4051155335042	1344.8142178034393	218914	2026-05-09 06:56:48.915296+00	3	t	1402.690285168844	1411.2811828989088	t
598	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q007	select *\nfrom student\nwhere name like 'Z%'	t	1285.9122010359608	1293.2834864943836	26905	2026-05-09 06:57:32.375436+00	1	t	1064.3421128288148	1056.970827370392	t
603	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q005	select section.semester, min(course.credits)\nfrom section, course\nwhere section.course_id = course.course_id\ngroup by section.semester	t	1344.8142178034393	1353.5071562150033	207953	2026-05-09 07:00:21.661125+00	1	t	1231.5972200984036	1222.9042816868396	t
588	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q010	select *\nfrom student\nwhere tot_cred between 50 and 100	t	1281.471697729035	1280.0354360590766	33870	2026-05-09 06:55:03.070624+00	2	t	1109.7303584692374	1111.1666201391959	t
589	97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03-Q007	SELECT student.name\nFROM student, advisor, instructor\nWHERE student.ID = advisor.s_id\n  AND advisor.i_id = instructor.identity\n  AND instructor.dept_name = 'Comp. Sci.'	f	\N	\N	370192	2026-05-09 06:55:50.591707+00	1	f	\N	\N	f
593	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q017	select d.dept_name, count(i.ID)\nfrom department d, instructor i\nwhere d.dept_name = i.dept_name\ngroup by d.dept_name\nhaving count(i.id) > 2	f	\N	\N	199659	2026-05-09 06:56:29.660726+00	1	f	\N	\N	f
602	f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q018	SELECT instructor.dept_name, avg (instructor.salary)\nFROM instructor, department\nGROUP BY instructor.dept_name\nWHERE department.budget > 150000 AND instructor.dept_name = department.dept_name;	f	1405.6407095360858	1397.2904524825954	538777	2026-05-09 06:59:34.183924+00	3	t	1463.4873086244027	1471.837565677893	f
592	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q009	select *\nfrom student\nwhere dept_name = 'Comp. Sci.' or dept_name = 'Physics'	t	1280.0354360590766	1278.1701223245113	82446	2026-05-09 06:56:27.687642+00	2	t	1104.4818327927032	1106.3471465272685	t
601	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q012	select *\nfrom student\nwhere tot_cred > 0	t	1299.367679016549	1307.7311897380716	28152	2026-05-09 06:59:21.848564+00	1	t	1140.1960130894436	1131.8325023679208	f
594	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q017	select d.dept_name, count(i.ID)\nfrom department d, instructor i\nwhere d.dept_name = i.dept_name\ngroup by d.dept_name\nhaving count(i.ID) > 2	f	\N	\N	211607	2026-05-09 06:56:41.600155+00	2	f	\N	\N	f
597	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q018	select i.dept_name, avg(select i.salary from instructor i, department d where d.dept_name = i.dept_name AND d.budget>150000)\nfrom instructor i\ngroup by i.dept_name	f	\N	\N	531959	2026-05-09 06:57:28.623526+00	2	f	\N	\N	f
600	86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01-Q005	select name, dept_name\nfrom instructor\nwhere dept_name = 'Comp. Sci.'	t	1293.2834864943836	1299.367679016549	77601	2026-05-09 06:58:51.825006+00	1	t	1033.6234432639694	1027.5392507418042	t
604	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q010	select building, avg(capacity)\nfrom classroom\nwhere capacity > 80	f	\N	\N	67875	2026-05-09 07:00:39.174885+00	1	f	\N	\N	f
605	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q006	select dept_name, sum(credits) \nfrom course\ngroup by dept_name	t	1353.5071562150033	1366.2408522142575	50643	2026-05-09 07:01:14.879496+00	1	t	1273.84735395402	1261.1136579547658	t
606	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q010	select building, avg(capacity)\nfrom classroom\nwhere capacity > 80\ngroup by building	f	\N	\N	127829	2026-05-09 07:01:39.071559+00	2	f	\N	\N	f
607	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q010	select building, avg(capacity)\nfrom classroom\ngroup by building\nhaving avg(capacity) > 80	t	1307.7311897380716	1302.703549739053	298676	2026-05-09 07:04:29.924159+00	3	t	1306.7843096340885	1311.8119496331071	t
608	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q018	select i.dept_name, i.avg(salary)\nfrom instructor i, department d\ngroup by i.dept_name\nhaving i.dept_name = d.dept_name\nAND d.budget > 150000	f	1396.4473404068078	1388.5838183668645	993920	2026-05-09 07:05:10.580993+00	3	t	1471.837565677893	1479.7010877178363	t
609	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q016	select c.title, count(distinct (s.name))\nfrom course c, department d, student s\nwhere c.dept_name = d.dept_name and d.dept_name = s.dept_name\ngroup by c.title	f	\N	\N	286407	2026-05-09 07:06:03.799878+00	1	f	\N	\N	f
610	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q008	select avg(budget)\nfrom department\nwhere dept_name = 'Taylor'	f	\N	\N	129092	2026-05-09 07:06:41.396905+00	1	f	\N	\N	f
611	84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02-Q019	select dept_name, count(course_id), avg(credits)\nfrom course\ngroup by dept_name\nhaving avg(credits) > 2	t	1388.5838183668645	1403.7644269400112	186740	2026-05-09 07:08:28.64792+00	1	t	1492.9011544413772	1477.7205458682306	t
612	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q016	select c.title, count(distinct (s.name))\nfrom course c, takes t, student s\nwhere c.course_id = t.course_id and t.ID = s.ID\ngroup by c.title	f	\N	\N	490070	2026-05-09 07:09:27.47911+00	2	f	\N	\N	f
613	8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q008	select avg(budget)\nfrom department\nwhere building = 'Taylor'	t	1302.703549739053	1302.0580144466603	299502	2026-05-09 07:09:31.650117+00	2	t	1287.5688321475693	1288.214367439962	t
614	a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q016	select c.title, count(s.name)\nfrom course c, takes t, student s\nwhere c.course_id = t.course_id and t.ID = s.ID\ngroup by c.title	t	1366.2408522142575	1365.8570263225113	548194	2026-05-09 07:10:25.599403+00	3	t	1467.0053767062561	1467.3892025980024	t
\.


--
-- TOC entry 3568 (class 0 OID 16737)
-- Dependencies: 240
-- Data for Name: assessment_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assessment_sessions (session_id, user_id, module_id, question_ids_served, status, started_at, ended_at, current_question_id, current_question_attempt_count, total_session_attempts, current_question_start_time) FROM stdin;
81ca8159-1ffb-465a-b49e-0c1b19630481	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02	{CH02-Q008,CH02-Q012,CH02-Q009,CH02-Q010,CH02-Q013,CH02-Q014,CH02-Q015,CH02-Q011,CH02-Q007,CH02-Q004,CH02-Q006,CH02-Q016,CH02-Q017,CH02-Q005,CH02-Q018,CH02-Q003,CH02-Q020,CH02-Q021,CH02-Q019,CH02-Q022,CH02-Q023,CH02-Q001,CH02-Q024,CH02-Q002,CH02-Q025}	COMPLETED	2026-05-07 08:29:01.189051+00	2026-05-07 10:12:29.768895+00	\N	0	50	\N
bf691a19-e777-4e38-8b31-78610c6bb3ec	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02	{CH02-Q006,CH02-Q007,CH02-Q005,CH02-Q004,CH02-Q008,CH02-Q003,CH02-Q010,CH02-Q002,CH02-Q001,CH02-Q013,CH02-Q014,CH02-Q012,CH02-Q011,CH02-Q015,CH02-Q009,CH02-Q016,CH02-Q017,CH02-Q018,CH02-Q019,CH02-Q021,CH02-Q022,CH02-Q020,CH02-Q024,CH02-Q025,CH02-Q023}	COMPLETED	2026-05-07 09:00:41.305557+00	2026-05-07 10:05:21.507556+00	\N	0	57	\N
40877d9d-ac31-4e1b-b212-5905f285fce2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-08 00:46:05.342563+00	2026-05-08 00:47:30.313989+00	\N	0	3	\N
99ba6fde-582b-40f8-a287-453c83c9c56d	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH01	{}	COMPLETED	2026-05-07 08:16:24.906204+00	2026-05-07 08:18:08.190643+00	\N	0	1	\N
21886a26-9326-453e-a000-fc796ec48802	d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01	{CH01-Q016,CH01-Q017,CH01-Q014,CH01-Q015,CH01-Q019,CH01-Q020,CH01-Q021,CH01-Q024,CH01-Q022,CH01-Q023,CH01-Q013,CH01-Q018,CH01-Q011,CH01-Q010,CH01-Q025,CH01-Q012,CH01-Q008,CH01-Q009,CH01-Q007,CH01-Q005,CH01-Q004,CH01-Q006}	COMPLETED	2026-05-07 08:15:55.3062+00	2026-05-07 09:00:03.840021+00	\N	0	43	\N
a76a7bcc-9522-42bb-b424-0f799b309a2b	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-08 00:47:33.468692+00	2026-05-08 00:48:03.993271+00	\N	0	1	\N
f2485a88-d21d-40e3-b0bc-6177b4cc30cb	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02	{}	ACTIVE	2026-05-07 10:12:54.026986+00	\N	CH02-Q014	0	0	\N
e61243b5-f448-47ec-ae62-66702ece4395	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:31:34.362296+00	2026-05-07 16:31:51.455012+00	\N	0	1	\N
4c6300f2-de1d-490c-b9e4-6d0bc8897b61	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{CH01-Q018,CH01-Q020}	COMPLETED	2026-05-07 08:15:57.308359+00	2026-05-07 08:22:53.472659+00	\N	0	3	\N
e649a50c-d688-44a3-b93f-bd2aa52508a7	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 12:29:13.661159+00	2026-05-07 12:29:25.145498+00	\N	0	1	\N
dbf42c3f-7cd4-4e6f-870f-6ca6811f330e	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02	{CH02-Q010,CH02-Q011,CH02-Q012,CH02-Q008,CH02-Q009,CH02-Q007,CH02-Q006,CH02-Q014,CH02-Q004,CH02-Q015,CH02-Q005,CH02-Q013,CH02-Q003,CH02-Q002,CH02-Q017,CH02-Q016,CH02-Q019,CH02-Q020}	COMPLETED	2026-05-07 08:18:21.868573+00	2026-05-07 10:15:56.423841+00	CH02-Q020	0	37	\N
a4c24ab5-e69c-4ac6-9b96-cb9830382929	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 15:03:27.811548+00	2026-05-07 15:03:55.948752+00	\N	0	2	\N
acc607f6-c19c-4c0c-98fa-8e2740677feb	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH01	{}	COMPLETED	2026-05-07 08:23:46.97804+00	2026-05-07 08:27:11.165539+00	\N	0	1	\N
20ebfabf-28e9-4e16-9a41-1121ea190753	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:28:06.046948+00	2026-05-07 16:28:26.865246+00	\N	0	1	\N
c8cabe3c-4a7a-4d28-ae51-76a5d8424666	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 12:29:29.997216+00	2026-05-07 12:29:37.456554+00	\N	0	1	\N
1c587135-03e2-4139-a678-9cd6137f28b5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02	{CH02-Q002,CH02-Q001,CH02-Q004,CH02-Q003,CH02-Q005,CH02-Q008,CH02-Q006,CH02-Q009,CH02-Q010,CH02-Q007,CH02-Q014,CH02-Q012,CH02-Q011,CH02-Q015,CH02-Q013,CH02-Q017,CH02-Q016,CH02-Q020,CH02-Q019,CH02-Q018,CH02-Q021,CH02-Q022,CH02-Q023,CH02-Q024,CH02-Q025}	COMPLETED	2026-05-07 09:24:33.411431+00	2026-05-07 10:19:23.281061+00	\N	0	48	\N
e9a90178-0cb7-4b07-ba57-18a5220126c4	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02	{CH02-Q010}	COMPLETED	2026-05-07 10:16:04.143492+00	2026-05-07 10:20:46.611232+00	CH02-Q010	1	4	\N
873a951b-f37c-4daf-b382-32fcab5af1f9	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 12:32:54.409346+00	2026-05-07 12:34:45.619751+00	\N	0	2	\N
b6bca809-5d4d-4db4-97da-762cf5eabbf6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:26:46.617107+00	2026-05-07 16:27:25.643019+00	\N	0	2	\N
1927c22f-0581-4027-87b4-55affcb79e40	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 12:30:07.067981+00	2026-05-07 12:30:26.757262+00	\N	0	1	\N
ab6fc46b-0de9-4819-aaac-51a1a318323d	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 15:04:01.229429+00	2026-05-07 15:04:16.139529+00	\N	0	1	\N
410a9331-316c-431d-b68f-219a2670fbc2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 12:34:50.368719+00	2026-05-07 12:35:08.638588+00	\N	0	1	\N
26525756-5f18-4a7f-9032-69d043a876f6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 12:30:42.695422+00	2026-05-07 12:31:11.988648+00	\N	0	2	\N
28500c85-672b-4373-9855-b0b662e2298f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02	{CH02-Q008,CH02-Q006,CH02-Q005,CH02-Q003,CH02-Q002,CH02-Q001,CH02-Q004,CH02-Q007,CH02-Q010,CH02-Q009,CH02-Q013,CH02-Q011,CH02-Q014,CH02-Q012,CH02-Q016,CH02-Q015,CH02-Q017,CH02-Q018,CH02-Q019,CH02-Q021}	COMPLETED	2026-05-07 08:25:32.044956+00	2026-05-07 09:24:29.788189+00	CH02-Q021	0	47	\N
9933ff5d-204a-4313-afff-609cbd0e1b3f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 12:35:11.820321+00	2026-05-07 12:35:23.123638+00	\N	0	1	\N
3f67c12e-5c27-4d45-bc95-d8987627e09a	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 12:31:15.17627+00	2026-05-07 12:31:48.865736+00	\N	0	2	\N
9559ebae-d44f-4620-97c4-c44809c5521f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:32:23.66412+00	2026-05-07 16:32:46.96141+00	\N	0	2	\N
83ef5f2a-02d4-4c31-a305-97c6749806a4	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 15:29:02.201116+00	2026-05-07 16:24:20.275379+00	\N	0	1	\N
f7e51e73-a281-4ca0-93be-533f63350285	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 12:32:01.902247+00	2026-05-07 12:32:29.592793+00	\N	0	1	\N
80715770-163f-40bb-99cd-9eaf5a7fef0d	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 12:35:25.853654+00	2026-05-07 12:35:43.1682+00	\N	0	1	\N
56d84687-596b-4ea5-ab0a-7aec59c4c187	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:27:28.615158+00	2026-05-07 16:27:41.601035+00	\N	0	1	\N
a2254da8-7e9d-4b15-ae31-1471bcfc4e47	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:26:21.708902+00	2026-05-07 16:26:43.507661+00	\N	0	1	\N
308ce14f-52bb-45ed-be2a-8553eebb06e2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:31:54.51253+00	2026-05-07 16:32:20.747086+00	\N	0	1	\N
4e2ceaff-3fa3-4d26-a5ea-217c1190f0e2	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:28:29.466064+00	2026-05-07 16:31:31.346823+00	\N	0	3	\N
7797a258-dd22-435d-b5cd-57551d13d25b	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:27:47.634044+00	2026-05-07 16:28:03.524819+00	\N	0	1	\N
2de60028-a726-41b8-8891-10df0b6a31e6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:33:08.154778+00	2026-05-07 16:33:25.502001+00	\N	0	1	\N
b8f4276a-1149-443b-baa1-7edb37c12591	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:32:49.810602+00	2026-05-07 16:33:05.15382+00	\N	0	1	\N
87adf447-3897-476d-9ce8-00dfae272342	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:34:44.360173+00	2026-05-07 16:35:38.550828+00	\N	0	3	\N
78d837df-fc9d-4bc0-af2c-903111d484f0	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:35:40.965741+00	2026-05-07 16:35:56.380265+00	\N	0	1	\N
18e28242-d5b4-423b-8913-b9e773eeb65a	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:33:29.837416+00	2026-05-07 16:33:46.420959+00	\N	0	1	\N
898acc64-1d09-438e-8be8-2117aa9ec140	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:35:58.904209+00	2026-05-07 16:36:29.584115+00	\N	0	1	\N
e6723a72-cd4a-4817-91e2-a6eed9e91dfb	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:36:32.658528+00	2026-05-07 16:37:42.296211+00	\N	0	1	\N
34a5d6af-c8d0-4171-8a6d-a24012ea8972	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 16:37:47.265964+00	2026-05-07 16:38:09.725621+00	\N	0	1	\N
3104259e-7ea7-44c4-a5b2-3c7247d5382f	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 17:14:11.652604+00	2026-05-07 17:15:12.078257+00	\N	0	1	\N
82a1a35a-bc3d-4cf4-a380-f09d949bd653	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 17:15:18.132373+00	2026-05-07 17:16:41.505662+00	\N	0	1	\N
1fe6eca1-c969-406c-81f7-e0eeb2d0ea49	c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	{}	COMPLETED	2026-05-07 17:16:49.802405+00	2026-05-07 17:17:30.009645+00	\N	0	1	\N
00283fab-9b77-4ebd-ac4b-0666a1eec277	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH01	{CH01-Q025}	COMPLETED	2026-05-09 05:54:51.049279+00	2026-05-09 06:00:39.121768+00	\N	0	2	2026-05-09 05:54:51.832745+00
a6d571fe-46fd-4b9e-b648-9c5ef70dda16	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02	{CH02-Q008,CH02-Q007,CH02-Q010,CH02-Q004,CH02-Q014,CH02-Q012,CH02-Q013,CH02-Q011,CH02-Q009,CH02-Q015,CH02-Q017,CH02-Q005,CH02-Q006,CH02-Q016,CH02-Q019,CH02-Q018,CH02-Q020,CH02-Q023,CH02-Q022}	COMPLETED	2026-05-09 06:15:23.721341+00	2026-05-09 07:31:53.729592+00	CH02-Q022	0	34	2026-05-09 07:30:59.588916+00
f26e866c-49ea-4ec7-a3be-a50a7a6d55a6	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02	{CH02-Q010,CH02-Q006,CH02-Q008,CH02-Q007,CH02-Q014,CH02-Q009,CH02-Q013,CH02-Q012,CH02-Q011,CH02-Q005,CH02-Q004,CH02-Q003,CH02-Q017,CH02-Q016,CH02-Q015,CH02-Q002,CH02-Q020,CH02-Q019,CH02-Q018,CH02-Q021,CH02-Q001,CH02-Q023,CH02-Q022,CH02-Q025,CH02-Q024}	COMPLETED	2026-05-07 16:39:18.569377+00	2026-05-07 17:14:02.824462+00	\N	0	47	\N
86f6c99b-d9dc-4dfa-a135-af605ca0a2e5	c1b54361-4d33-4c69-936d-ee088bedfd00	CH03	{CH03-Q007,CH03-Q006}	ACTIVE	2026-05-08 00:48:11.032464+00	\N	CH03-Q006	0	4	\N
ca75e361-a3f6-4fc3-9afd-7b96a7a040e8	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH01	{CH01-Q023}	COMPLETED	2026-05-09 05:58:43.916884+00	2026-05-09 06:06:28.862845+00	\N	0	2	2026-05-09 05:58:44.452638+00
ec27073f-9615-46f4-a6dd-f2a4b98b20b3	53750c4a-a048-4037-b563-272d5c8b2567	CH02	{CH02-Q011,CH02-Q013}	COMPLETED	2026-05-08 14:10:27.910788+00	2026-05-08 14:12:09.082749+00	CH02-Q013	0	2	2026-05-08 14:11:38.318047+00
f045cc2f-ef0f-4229-8af9-f7fd2e0c5e71	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH01	{CH01-Q017,CH01-Q021,CH01-Q022,CH01-Q024}	COMPLETED	2026-05-09 05:56:14.423991+00	2026-05-09 06:15:08.648741+00	\N	0	6	2026-05-09 06:13:34.141873+00
e0282baf-b400-4d1e-9ee3-9e536a65a413	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH01	{CH01-Q023}	COMPLETED	2026-05-09 05:51:01.478699+00	2026-05-09 05:54:18.88975+00	\N	0	1	2026-05-09 05:51:02.288853+00
9d2e155f-2de5-4799-943d-07a362851a09	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH01	{CH01-Q023}	COMPLETED	2026-05-09 05:58:52.834556+00	2026-05-09 06:08:56.866443+00	\N	0	1	2026-05-09 05:58:53.085328+00
e5f56886-7a49-423e-9733-2f8e51e4eb8f	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02	{CH02-Q009,CH02-Q014,CH02-Q007,CH02-Q010,CH02-Q012,CH02-Q011,CH02-Q008,CH02-Q013,CH02-Q017,CH02-Q016,CH02-Q015,CH02-Q019,CH02-Q021,CH02-Q020,CH02-Q018,CH02-Q023}	COMPLETED	2026-05-09 06:00:50.074527+00	2026-05-09 06:48:42.46818+00	\N	0	22	2026-05-09 06:47:26.252011+00
3f1e101a-5093-4e68-abf2-0bd9dc1c90b0	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02	{CH02-Q017,CH02-Q015,CH02-Q011,CH02-Q013,CH02-Q016,CH02-Q021,CH02-Q019,CH02-Q018,CH02-Q020,CH02-Q023,CH02-Q022,CH02-Q009}	COMPLETED	2026-05-09 06:11:08.193143+00	2026-05-09 06:45:21.848754+00	\N	0	21	2026-05-09 06:44:00.123402+00
8f7c949b-c4bb-42d0-8df1-39ec866d0dbb	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02	{CH02-Q010,CH02-Q008,CH02-Q007,CH02-Q004,CH02-Q013,CH02-Q009,CH02-Q011,CH02-Q012,CH02-Q014,CH02-Q017,CH02-Q016,CH02-Q015}	COMPLETED	2026-05-09 06:59:30.948749+00	2026-05-09 07:31:26.821971+00	CH02-Q015	1	22	2026-05-09 07:29:27.479221+00
bbe1fed6-1ba2-4e52-8d55-67b4dd19073e	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02	{CH02-Q018}	COMPLETED	2026-05-09 14:14:50.116905+00	2026-05-09 14:15:00.434477+00	CH02-Q018	0	0	2026-05-09 14:14:51.066638+00
86029f58-dc07-424a-b9f3-42ee0b1dd64b	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01	{CH01-Q021,CH01-Q018,CH01-Q020,CH01-Q017,CH01-Q024,CH01-Q016,CH01-Q022,CH01-Q019,CH01-Q023,CH01-Q015,CH01-Q014,CH01-Q025,CH01-Q011,CH01-Q013,CH01-Q010,CH01-Q009,CH01-Q008,CH01-Q007,CH01-Q005,CH01-Q012}	COMPLETED	2026-05-09 05:58:30.322578+00	2026-05-09 06:59:25.385866+00	\N	0	37	2026-05-09 06:58:53.7967+00
97b3e90d-6706-4e1a-9c0e-058a426a079f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03	{CH03-Q007,CH03-Q005,CH03-Q004,CH03-Q002,CH03-Q001,CH03-Q003,CH03-Q008,CH03-Q006,CH03-Q010,CH03-Q011,CH03-Q009,CH03-Q012,CH03-Q014}	COMPLETED	2026-05-09 06:49:40.244752+00	2026-05-09 13:59:28.819986+00	CH03-Q014	0	30	2026-05-09 13:58:52.648417+00
45255620-ee2d-4366-9928-6d61c7357bd5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02	{CH02-Q018}	COMPLETED	2026-05-09 14:15:06.527161+00	2026-05-09 14:16:07.86305+00	\N	0	1	2026-05-09 14:15:07.522723+00
3f7a08ee-e7d6-4a11-8609-42a274c7f385	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02	{CH02-Q018}	COMPLETED	2026-05-09 13:59:57.13707+00	2026-05-09 14:01:45.31362+00	\N	0	1	2026-05-09 13:59:58.10726+00
b27a3d1f-a57f-4d8c-80f9-1dadb582f928	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02	{CH02-Q020}	COMPLETED	2026-05-09 14:17:09.923378+00	2026-05-09 14:19:11.589188+00	\N	0	2	2026-05-09 14:17:10.965998+00
e8d258a4-1fb5-45c2-899e-0e2f54c512b5	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03	{CH03-Q006,CH03-Q005,CH03-Q002,CH03-Q003}	COMPLETED	2026-05-09 14:06:25.501459+00	2026-05-09 14:14:43.781396+00	CH03-Q003	0	9	2026-05-09 14:14:34.286263+00
f23eeb8d-9d08-4535-b6ee-d317d0c2c443	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02	{CH02-Q022}	COMPLETED	2026-05-09 14:19:16.844842+00	2026-05-09 14:20:19.9139+00	\N	0	2	2026-05-09 14:19:17.684025+00
621e5377-507a-48df-b4a7-464acf97df96	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02	{CH02-Q016}	COMPLETED	2026-05-09 14:05:24.083039+00	2026-05-09 14:05:59.911679+00	\N	0	1	2026-05-09 14:05:25.19004+00
f1e4f3c8-9db3-4ede-9ee6-874f6b010f6c	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02	{CH02-Q009,CH02-Q007,CH02-Q014,CH02-Q012,CH02-Q011,CH02-Q015,CH02-Q017,CH02-Q018,CH02-Q016,CH02-Q013,CH02-Q019,CH02-Q010,CH02-Q020,CH02-Q023,CH02-Q022,CH02-Q021}	COMPLETED	2026-05-09 06:10:54.896626+00	2026-05-09 07:30:37.994687+00	CH02-Q021	0	24	2026-05-09 07:29:29.959067+00
82ed1822-dd0a-4847-a0fd-c0e76acd2535	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH03	{CH03-Q006}	COMPLETED	2026-05-09 06:50:21.703194+00	2026-05-09 06:50:33.858417+00	CH03-Q006	0	0	2026-05-09 06:50:23.61723+00
84401ebe-962e-484b-bdee-21e65d3ca511	1907a5eb-a5a4-4782-b2af-b5779b706982	CH02	{CH02-Q010,CH02-Q007,CH02-Q008,CH02-Q013,CH02-Q012,CH02-Q011,CH02-Q017,CH02-Q015,CH02-Q016,CH02-Q014,CH02-Q018,CH02-Q019,CH02-Q020,CH02-Q021,CH02-Q023,CH02-Q009,CH02-Q022}	COMPLETED	2026-05-09 06:19:26.911515+00	2026-05-09 07:30:45.63138+00	CH02-Q022	3	31	2026-05-09 07:26:20.161552+00
a80c80c2-166f-4bd8-9940-26fd1c563408	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02	{CH02-Q011,CH02-Q013,CH02-Q017,CH02-Q015,CH02-Q018,CH02-Q012,CH02-Q019,CH02-Q016,CH02-Q021,CH02-Q020,CH02-Q007,CH02-Q022,CH02-Q014,CH02-Q023,CH02-Q024,CH02-Q010,CH02-Q009}	COMPLETED	2026-05-07 17:17:52.102976+00	2026-05-08 00:45:55.719846+00	\N	0	28	\N
891a6c2d-74e7-4945-a823-512d7be899e2	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02	{CH02-Q023}	COMPLETED	2026-05-09 14:16:12.89756+00	2026-05-09 14:17:02.484768+00	\N	0	1	2026-05-09 14:16:13.94005+00
633c7915-87e0-4df4-a503-9737f3f677e5	1907a5eb-a5a4-4782-b2af-b5779b706982	CH01	{CH01-Q017,CH01-Q016,CH01-Q021,CH01-Q022,CH01-Q018,CH01-Q020,CH01-Q024}	COMPLETED	2026-05-09 05:58:08.695494+00	2026-05-09 06:19:10.393965+00	\N	0	11	2026-05-09 06:17:26.882249+00
9769d349-d8f5-4e61-928e-e442c436b4b5	53750c4a-a048-4037-b563-272d5c8b2567	CH01	{CH01-Q023}	COMPLETED	2026-05-08 14:04:58.155633+00	2026-05-08 14:10:24.129403+00	\N	0	3	2026-05-08 14:04:58.488686+00
0f2f9141-165b-44b0-9053-f93abd84e53a	53750c4a-a048-4037-b563-272d5c8b2567	CH02	{CH02-Q011,CH02-Q012,CH02-Q013,CH02-Q014,CH02-Q007,CH02-Q009,CH02-Q008,CH02-Q010,CH02-Q017,CH02-Q004,CH02-Q015,CH02-Q018}	COMPLETED	2026-05-09 04:03:25.313473+00	2026-05-09 04:12:02.852566+00	CH02-Q018	0	20	2026-05-09 04:11:08.461012+00
9f090bc2-52c7-4dbf-af83-414d3ecc3bb3	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02	{CH02-Q016}	COMPLETED	2026-05-09 14:02:02.228755+00	2026-05-09 14:05:19.270668+00	\N	0	3	2026-05-09 14:02:03.095055+00
c93d1c20-c6af-4341-9947-119e01a1fd76	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02	{CH02-Q022}	COMPLETED	2026-05-09 14:20:26.238451+00	2026-05-09 14:21:07.219825+00	\N	0	1	2026-05-09 14:20:27.096177+00
\.


--
-- TOC entry 3560 (class 0 OID 16567)
-- Dependencies: 232
-- Data for Name: modules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modules (module_id, title, description, difficulty_min, difficulty_max, content_html, unlock_theta_threshold, order_index) FROM stdin;
CH01	Basic Selection	SELECT, WHERE, and basic filtering operations	1000	1400	<h1>Basic Selection</h1><p>Learn SELECT and WHERE clauses...</p>	0	1
CH02	Aggregation	GROUP BY, HAVING, and aggregate functions	1200	1600	<h1>Aggregation</h1><p>Learn GROUP BY and aggregate functions...</p>	1300	2
CH03	Advanced Querying	JOINs, Subqueries, and CTEs	1400	1800	<h1>Advanced Querying</h1><p>Learn JOINs and subqueries...</p>	1500	3
\.


--
-- TOC entry 3567 (class 0 OID 16694)
-- Dependencies: 239
-- Data for Name: peer_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.peer_sessions (session_id, requester_id, reviewer_id, question_id, review_content, system_score, is_helpful, final_score, status, created_at, requester_query, theta_social_before, theta_social_after, completed_at) FROM stdin;
9f3f965c-8725-4377-8367-b15497ef5943	53750c4a-a048-4037-b563-272d5c8b2567	c1b54361-4d33-4c69-936d-ee088bedfd00	CH02-Q013		0	\N	0	PENDING_REVIEW	2026-05-09 04:04:01.329102+00	select from where	\N	\N	\N
2b3cb31a-c2ac-4858-8965-603ac5f3317d	53750c4a-a048-4037-b563-272d5c8b2567	b28ca094-8a90-4d30-930c-ea7fc554e7c3	CH02-Q014		0	\N	0	PENDING_REVIEW	2026-05-09 04:04:23.008664+00	select from where	\N	\N	\N
884d2a9b-c9b9-4f2d-929b-1aaa49afe6ac	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q021	sectionnya di left join ke time slot, nah nanti keliatan yg mana yang null, lalu baru disorting,,,,, anjay	0.1	t	0.55	COMPLETED	2026-05-09 06:31:29.250453+00	SELECT time_slot_id, COUNT(sec_id)\nFROM section\nGROUP BY time_slot_id\nHAVING COUNT(sec_id) > 2	1300	1301.5	2026-05-09 07:43:36.81061+00
b8bd0bc8-f512-4219-b4fe-5bab9743c507	1907a5eb-a5a4-4782-b2af-b5779b706982	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q018	i.dept_name = d.dept_name nya pake where aja gasih???	0.9044304341077805	t	0.9522152170538902	COMPLETED	2026-05-09 07:05:21.909209+00	select i.dept_name, i.avg(salary)\nfrom instructor i, department d\ngroup by i.dept_name\nhaving i.dept_name = d.dept_name\nAND d.budget > 150000	1300	1313.5664565116167	2026-05-09 07:34:45.559499+00
4675cb15-f9df-4225-8fee-b6d3d2227104	1907a5eb-a5a4-4782-b2af-b5779b706982	e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02-Q016	gatau lah jo, jawab sendiri lah, dah gede kan\n1. belum di join jo\n2. pake where dh jo	0.9094509482383728	t	0.9547254741191864	COMPLETED	2026-05-09 06:46:36.804503+00	select course.title, count(ID)\nfrom takes, course\ngroup by course.title\nhaving takes.course_id = course.course_id	1301.5	1315.1417642235756	2026-05-09 07:43:39.4889+00
4e3a5e06-f0c8-4f43-9c50-9a80e5d5d0f9	71ff93d9-bdd1-441d-8984-d4094ae239d0	32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02-Q013	count(*) nya ganti jadi count(distinct ID) ato semacamnya	0.1	t	0.55	COMPLETED	2026-05-09 07:16:03.443629+00	SELECT distinct COUNT(*) FROM takes\nWHERE year = 2009;	1313.5664565116167	1315.0664565116167	2026-05-09 07:37:52.36725+00
83b15616-d241-4237-8895-69ca8b9a7abf	e0e04c7e-8e71-49d6-8a65-a76b82826016	6d23e37a-d746-4a4a-b9be-29507cc9a88c	CH02-Q019	Kesalahannya terletak di avg(credits) seharusnya include 3 jadi pakai >=	0.1	t	0.55	COMPLETED	2026-05-09 07:18:26.394632+00	select dept_name, count(course_id), avg(credits)\nfrom (select dept_name, )\ngroup by dept_name\nhaving avg(credits) > 3	1300	1301.5	2026-05-09 07:44:00.385048+00
3d4eca5e-678f-47f3-b6a4-dc1636eb7fb0	32c7420c-0bf8-4aa7-8174-45e980dee27c	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q009	seharusnya query ini cukup memakai kolom course. total sks seharusnya dicari dengan memakai SUM(credits), lalu dikelompokkan berdasarkan nama departemen, dan dipakaikan syarat SUM(credits) >10\n\nQUERY LENGKAP:\nSELECT dept_name, SUM(credits) \nFROM course\nGROUP BY dept_name\nHAVING SUM(credits) > 10;	0.9145185947418213	t	0.9572592973709106	COMPLETED	2026-05-09 07:18:48.126541+00	select department.dept_name, student.tot_cred\nfrom department, student\nwhere student.dept_name = department.dept_name\nwhere student.tot_cred >10	1300	1313.7177789211273	2026-05-09 07:42:52.814552+00
16db96c2-5345-4f7c-b944-eeb70b04b958	e0e04c7e-8e71-49d6-8a65-a76b82826016	71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02-Q017	sepertinya cukup satu tabel instructor saja yang dipakai	0.9121715724468231	t	0.9560857862234116	COMPLETED	2026-05-09 06:56:53.720519+00	select d.dept_name, count(i.ID)\nfrom department d, instructor i\nwhere d.dept_name = i.dept_name\ngroup by d.dept_name\nhaving count(i.ID) > 2	1300	1313.6825735867023	2026-05-09 07:44:10.538069+00
05868f67-4fc6-43ed-8749-e37679917bf2	32c7420c-0bf8-4aa7-8174-45e980dee27c	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02-Q016	seharusnya query memakai JOIN untuk menggabungkan course dengan takes, lalu dikelompokkan berdasarkan judul mata kuliah.\n\nQUERY:\nSELECT c.title, COUNT(t.ID)\nFROM course c\nJOIN takes t ON c.course_id = t.course_id\nGROUP BY c.title;	0.1	\N	0	WAITING_CONFIRMATION	2026-05-09 07:29:27.402256+00	select course.title, count(takes.ID)\nfrom course, takes\ngroup by tittle\nwhere takes.course_id = course.course_id	\N	\N	\N
\.


--
-- TOC entry 3562 (class 0 OID 16598)
-- Dependencies: 234
-- Data for Name: pretest_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pretest_sessions (session_id, user_id, current_question_index, answers, total_questions, current_theta, started_at, completed_at) FROM stdin;
91d3c919-3a16-4cb4-a214-ba5c7c7ea76e	417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	4	{"CH01-Q001": true, "CH01-Q002": false, "CH01-Q003": false, "CH01-Q004": true, "CH01-Q005": true}	5	1340	2026-05-09 05:40:24.22788+00	2026-05-09 05:50:02.602965+00
07fcbf31-0654-4e7b-b333-879e37013687	32c7420c-0bf8-4aa7-8174-45e980dee27c	4	{"CH01-Q001": true, "CH01-Q002": false, "CH01-Q003": false, "CH01-Q004": false, "CH01-Q006": true}	5	1260	2026-05-09 05:36:21.848819+00	2026-05-09 05:50:28.903707+00
8cded907-8889-4135-bdcd-4076ebde7044	53750c4a-a048-4037-b563-272d5c8b2567	4	{"CH01-Q001": true, "CH01-Q002": true, "CH01-Q004": true, "CH01-Q005": false, "CH01-Q006": true}	5	1420	2026-05-03 13:50:18.221762+00	2026-05-03 13:54:48.475676+00
700b6bec-8dd3-42a8-913c-057c2844bd9c	71ff93d9-bdd1-441d-8984-d4094ae239d0	4	{"CH01-Q001": true, "CH01-Q002": true, "CH01-Q003": false, "CH01-Q004": false, "CH01-Q006": true}	5	1340	2026-05-09 05:48:45.053458+00	2026-05-09 05:53:13.809059+00
dd66794d-0c05-4610-8938-57f92d78c937	e0e04c7e-8e71-49d6-8a65-a76b82826016	4	{"CH01-Q001": false, "CH01-Q002": false, "CH01-Q004": true, "CH01-Q005": false, "CH01-Q006": true}	5	1260	2026-05-09 05:47:30.527981+00	2026-05-09 05:54:40.304524+00
f4685620-e587-4640-89aa-28309cf66e1d	6d23e37a-d746-4a4a-b9be-29507cc9a88c	0	{}	5	0	2026-05-09 07:37:10.618941+00	\N
009f6056-ad6c-45e9-83c9-edcd91ab953e	d897aef3-80ea-473d-be4c-f4367cbc4d93	4	{"CH01-Q001": true, "CH01-Q002": false, "CH01-Q003": true, "CH01-Q004": false, "CH01-Q005": false}	5	1260	2026-05-07 07:58:49.316043+00	2026-05-07 08:07:07.404075+00
ff1198bd-556d-415d-b76a-e1d4f38e55e4	c1b54361-4d33-4c69-936d-ee088bedfd00	4	{"CH01-Q001": true, "CH01-Q002": false, "CH01-Q003": false, "CH01-Q004": false, "CH01-Q006": true}	5	1260	2026-05-07 07:57:50.088141+00	2026-05-07 08:07:43.284365+00
4ce925cf-a677-4531-a6f6-76213ee42ce9	e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	4	{"CH01-Q001": true, "CH01-Q002": true, "CH01-Q003": false, "CH01-Q004": false, "CH01-Q006": true}	5	1340	2026-05-07 08:00:15.888578+00	2026-05-07 08:07:47.805283+00
17e50a90-7a22-4235-8813-e4a2a855b935	7e2e07f2-813f-4c75-abfc-dc1d009b35a1	4	{"CH01-Q001": true, "CH01-Q002": true, "CH01-Q003": true, "CH01-Q004": false, "CH01-Q006": false}	5	1340	2026-05-07 07:58:19.128267+00	2026-05-07 08:08:38.810614+00
71905cda-91ae-4f17-91fa-9963f2319a21	1907a5eb-a5a4-4782-b2af-b5779b706982	4	{"CH01-Q001": true, "CH01-Q002": true, "CH01-Q003": false, "CH01-Q004": false, "CH01-Q005": false}	5	1260	2026-05-09 05:37:25.6276+00	2026-05-09 05:45:05.725883+00
6f4e60b4-bcd0-4994-bcfe-bb097287641f	dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	4	{"CH01-Q001": true, "CH01-Q002": true, "CH01-Q004": true, "CH01-Q005": true, "CH01-Q006": false}	5	1420	2026-05-09 05:37:19.672832+00	2026-05-09 05:45:12.37473+00
\.


--
-- TOC entry 3563 (class 0 OID 16619)
-- Dependencies: 235
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.questions (question_id, module_id, content, target_query, initial_difficulty, current_difficulty, topic_tags, is_active) FROM stdin;
CH01-Q001	CH01	Tampilkan seluruh data yang ada pada tabel `student`. Gampang sih, tinggal SELECT aja!	SELECT * FROM student;	1000	1000	{SELECT,ALL}	t
CH01-Q002	CH01	Kita butuh daftar nama semua mahasiswa dan total SKS (SKS) mereka buat laporan akademik.	SELECT name, tot_cred FROM student;	1015	1015	{SELECT,COLUMN}	t
CH01-Q017	CH01	Mahasiswa departemen 'Comp. Sci.' ATAU yang total SKSnya < 50 bisa ikut program beasiswa ini. Tolong cariin dong siapa aja itu	SELECT * FROM student WHERE dept_name = 'Comp. Sci.' OR tot_cred < 50;	1240	1251.0785611644926	{SELECT,WHERE,OR}	t
CH01-Q020	CH01	Kombinasi building dan room_no yang unik aja dong.	SELECT DISTINCT building, room_no FROM classroom;	1285	1232.8037515738959	{SELECT,DISTINCT,MULTI-COLUMN}	t
CH01-Q013	CH01	Urutkan mahasiswa berdasarkan total SKS tertinggi. Kita mau buat dean's list!	SELECT * FROM student ORDER BY tot_cred DESC;	1180	1148.3546954384328	{SELECT,"ORDER BY",DESC}	t
CH01-Q021	CH01	Rudi penasaran siapa saja mahasiswa yang namanya setidaknya mengandung 2 kata (berarti ada spasi) dan berakhiran huruf 'n'	SELECT * FROM student WHERE name LIKE '% %' AND name LIKE '%n';	1300	1246.4613821443445	{SELECT,WHERE,LIKE,AND}	t
CH01-Q011	CH01	Kita perlu tahu siapa saja mahasiswa yang belum punya total SKS alias 0 (treat as NULL concept) nih. Bantuin filter dong.	SELECT * FROM student WHERE tot_cred = 0;	1150	1145.5456025906956	{SELECT,WHERE,"NULL"}	t
CH01-Q025	CH01	Coba tampilkan semua mata kuliah (course), semester, serta tahun kelasnya (section). Semua atribut dari course harus ditampilkan	SELECT c.*, s.semester, s.year FROM course c, section s WHERE c.course_id = s.course_id;	1380	1330.5274561800093	{SELECT,"IMPLICIT JOIN",MULTI-TABLE}	t
CH01-Q010	CH01	Total SKS antara 50 sampai 100 itu range yang cukup bagus. Tunjukkan mahasiswa di range itu aja.	SELECT * FROM student WHERE tot_cred BETWEEN 50 AND 100;	1135	1111.1666201391959	{SELECT,WHERE,BETWEEN}	t
CH01-Q023	CH01	Kampus sedang mau liat daftar dosen dan mata kuliah yang mereka ajar. Bisa bantu cariin? Tolong diurutkan berdasarkan nama dosen ASC dan course_id ASC	SELECT i.name, t.course_id FROM instructor i, teaches t WHERE i.ID = t.ID ORDER BY i.name ASC, t.course_id ASC;	1330	1329.2135388827771	{SELECT,"IMPLICIT JOIN","ORDER BY"}	t
CH02-Q001	CH02	Tolong hitung dong total semua mahasiswa yang terdaftar di sistem kita. Cukup tampilkan kolom count-nya saja ya!	SELECT COUNT(*) FROM student;	1200	1154.361607161074	{COUNT,AGGREGATE}	t
CH01-Q015	CH01	Kapasitas ruangan kampus lagi disurvei nih. Cari bangunan dengan kapasitas > 150, urutin dari yang paling gede.	SELECT building, room_no, capacity FROM classroom WHERE capacity > 150 ORDER BY capacity DESC;	1210	1195.6386995831886	{SELECT,WHERE,"ORDER BY",COMPARISON}	t
CH01-Q018	CH01	Panitia hackathon mau melakukan pre-filter calon perwakilan. Syaratnya mahasiswa 'Comp. Sci.' dengan total SKS > 80, dua-duanya harus terpenuhi buat masuk tim utama.	SELECT * FROM student WHERE dept_name = 'Comp. Sci.' AND tot_cred > 80;	1255	1262.82508736808	{SELECT,WHERE,AND}	t
CH01-Q022	CH01	Coba cari mata kuliah yang TIDAK mengandung kata 'Intro' di judulnya dan SKS-nya <= 3.	SELECT * FROM course WHERE title NOT LIKE '%Intro%' AND credits <= 3;	1315	1291.0822813518596	{SELECT,WHERE,"NOT LIKE",COMPARISON}	t
CH01-Q004	CH01	TU katanya mau liat data mahasiswa dari departemen 'Comp. Sci.'. Bantu filter dong biar lebih rapih.	SELECT * FROM student WHERE dept_name = 'Comp. Sci.';	1045	1018.1120581890469	{SELECT,WHERE,EQUALITY}	t
CH01-Q016	CH01	Fakultas sedang mempertimbangkan untuk menggandakan SKS mata kuliah tertentu. Coba tampilin kode matkul, SKS lama, dan SKS baru kalau SKS mata kuliah yang ada dikali 2. Kasih alias `double_credits` biar jelas!	SELECT course_id, credits, (credits * 2) AS double_credits FROM course;	1225	1213.0463537267333	{SELECT,ARITHMETIC,ALIAS}	t
CH01-Q014	CH01	Bisa tolong tunjukin mata kuliah yang punya SKS lebih dari 3? Terus dibuat terurut berdasarkan JUDUL secara ascending... A-Z gitu lohh.	SELECT * FROM course WHERE credits > 3 ORDER BY title ASC;	1195	1167.1653711629335	{SELECT,WHERE,"ORDER BY",ASC}	t
CH01-Q007	CH01	Mahasiswa yang namanya mulai dari huruf 'Z' doang yang ikut acara hari ini. Cari yang namanya AWAL dengan 'Z' ya!	SELECT * FROM student WHERE name LIKE 'Z%';	1090	1056.970827370392	{SELECT,WHERE,LIKE}	t
CH01-Q009	CH01	Mahasiswa dari departemen 'Comp. Sci.' atau 'Physics' aja yang mau kita ajak survei. Kedua departemen itu penting banget buat proyek ini. Coba bantu buatin querynya.	SELECT * FROM student WHERE dept_name IN ('Comp. Sci.', 'Physics');	1120	1106.3471465272685	{SELECT,WHERE,IN}	t
CH01-Q005	CH01	Dosen-dosen yang departemennya 'Comp. Sci.' lagi dikumpulin buat rapat. Tampilkan siapa saja nama mereka dan departemennya.	SELECT name, dept_name FROM instructor WHERE dept_name = 'Comp. Sci.';	1060	1027.5392507418042	{SELECT,WHERE,COLUMN}	t
CH01-Q003	CH01	Nona Angelin pengen liat siapa saja mahasiswa yang total SKSnya nggak nol alias udah punya SKS terakumulasi. Bantuin dong!	SELECT * FROM student WHERE tot_cred <> 0;	1030	1029.3346097883725	{SELECT,WHERE,COMPARISON}	t
CH01-Q008	CH01	Kita mau ngasih kado ke mahasiswa yang nama belakangnya 'ez'. Bantuin cari yang namanya BERAKHIRAN 'ez' dong.	SELECT * FROM student WHERE name LIKE '%ez';	1105	1078.6997216817158	{SELECT,WHERE,LIKE}	t
CH01-Q006	CH01	Kampus kita lagi ngadain survei nih. Kita mau tau judul mata kuliah apa aja yang ditawarkan. Bantuin buat daftarnya dong!	SELECT DISTINCT title FROM course;	1075	1032.2502941958057	{SELECT,DISTINCT}	t
CH01-Q019	CH01	Coba tunjukin ada gak sih dosen dengan gaji antara 60rb dan 90rb? jangan lupa cek yang salary-nya nggak NULL ya!	SELECT * FROM instructor WHERE salary BETWEEN 60000 AND 90000 AND salary IS NOT NULL;	1270	1215.4610489429338	{SELECT,WHERE,BETWEEN,"IS NOT NULL"}	t
CH01-Q012	CH01	Kita juga perlu tahu siapa saja mahasiswa yang total SKSnya SUDAH ADA dan nggak 0.	SELECT * FROM student WHERE tot_cred > 0;	1165	1131.8325023679208	{SELECT,WHERE,"NOT NULL"}	t
CH03-Q001	CH03	Tolong gabungin tabel student sama takes-nya, kita mau liat nama mahasiswa barengan sama kode mata kuliah yang dia ambil.	SELECT s.name, t.course_id FROM student s INNER JOIN takes t ON s.ID = t.ID;	1400	1403.624769274756	{"INNER JOIN",SELECT}	t
CH02-Q002	CH02	Tolong tampilin nama departemen dan jumlah mahasiswa (alias jumlah_mhs) di setiap departemen tersebut. Kita pengen tau departemen mana yang favorit.	SELECT dept_name, COUNT(*) AS jumlah_mhs FROM student GROUP BY dept_name;	1215	1192.9132939073884	{COUNT,"GROUP BY"}	t
CH03-Q013	CH03	Siapa sih mahasiswa rajin yang ngambil mata kuliah 'CS-101' sekaligus 'CS-201'? Ga perlu pake alias ya! :D	(SELECT ID FROM takes WHERE course_id = 'CS-101') INTERSECT (SELECT ID FROM takes WHERE course_id = 'CS-201');	1640	1640	{INTERSECT,SET-OP}	t
CH03-Q014	CH03	Coba hitung dulu rata-rata budget (alias avg_budget) per gedung, terus tampilin gedung mana yang rata-ratanya di atas rata-rata budget kampus secara keseluruhan.	WITH building_avg AS (SELECT building, AVG(budget) AS avg_budget FROM department GROUP BY building) SELECT * FROM building_avg WHERE avg_budget > (SELECT AVG(budget) FROM department);	1660	1660	{CTE,WITH,SUBQUERY}	t
CH03-Q015	CH03	Tolong buatin ranking mahasiswa berdasarkan total SKS di masing-masing departemennya, dan kolom rankingnya alias 'rank' ya!	SELECT name, dept_name, tot_cred, RANK() OVER(PARTITION BY dept_name ORDER BY tot_cred DESC) AS rank FROM student;	1680	1680	{RANK,WINDOW,PARTITION}	t
CH03-Q016	CH03	Ada kabar gembira! Fakultas (departemen) yang rata-rata SKS (tot_cred) mahasiswanya lebih dari 50 akan mendapatkan peningkatkan APB dari pusat DITKEU. Coba tampilkan nama fakultas, budget saat ini, dan kolom 'proyeksi_budget' (budget + 10%) untuk departemen-departemen tersebut	SELECT dept_name, budget, (budget * 1.1) AS proyeksi_budget FROM department WHERE dept_name IN (SELECT dept_name FROM student GROUP BY dept_name HAVING AVG(tot_cred) > 50);	1700	1700	{SUBQUERY,ARITHMETIC}	t
CH03-Q017	CH03	TU Akademik sedang mensurvei kelas apa saja yang perlu ditutup pada masa PRS. Coba cari data kelas di tahun 2008 yang memiliki kurang dari 5 mahasiswa. Tampilkan course_id, sec_id, dan kolom jumlah mahasiswanya alias 'jumlah_mhs' ya!	SELECT course_id, sec_id, COUNT(ID) AS jumlah_mhs FROM takes WHERE year = 2008 GROUP BY course_id, sec_id HAVING COUNT(ID) < 5;	1715	1715	{COUNT,"GROUP BY",HAVING}	t
CH03-Q018	CH03	Kita ingin merancang mata kuliah baru. Tampilkan sebuah baris tunggal dengan ID 'NEW-001', judulnya 'NEW COURSE', departemennya sama dengan 'CS-101', dan SKS-nya juga sama	SELECT 'NEW-001' AS course_id, 'New Course' AS title, dept_name, credits FROM course WHERE course_id = 'CS-101';	1730	1730	{LITERAL,SELECT}	t
CH03-Q019	CH03	Gunakan CTE (Common Table Expression) dengan alias 'jml' untuk menghitung jumlah mahasiswa per departemen, lalu tampilkan departemen yang populasinya di atas rata-rata populasi departemen lain	WITH dept_counts AS (SELECT dept_name, COUNT(*) AS jml FROM student GROUP BY dept_name) SELECT * FROM dept_counts WHERE jml > (SELECT AVG(jml) FROM dept_counts);	1745	1745	{CTE,WITH,SUBQUERY}	t
CH03-Q020	CH03	Gunakan CTE dengan alias 'jml' untuk menghitung jumlah mahasiswa per departemen, lalu tampilkan departemen yang mahasiswanya lebih dari 20 orang.	WITH dept_counts AS (SELECT dept_name, COUNT(*) AS jml FROM student GROUP BY dept_name) SELECT * FROM dept_counts WHERE jml > 20;	1760	1760	{CTE,WITH}	t
CH03-Q021	CH03	Coba klasifikasi mata kuliah berdasarkan nilai rata-rata mahasiswanya dengan alias kolom: avg_grade (rata-rata nilai) dan difficulty ('Easy' kalau >= 'B', 'Medium' antara 'C' dan 'B', 'Hard' sisanya).	SELECT c.title, AVG(t.grade) AS avg_grade, CASE WHEN AVG(t.grade) >= 'B' THEN 'Easy' WHEN AVG(t.grade) BETWEEN 'C' AND 'B' THEN 'Medium' ELSE 'Hard' END AS difficulty FROM course c JOIN takes t ON c.course_id = t.course_id GROUP BY c.title;	1770	1770	{CASE,JOIN,"GROUP BY"}	t
CH03-Q004	CH03	Cari mahasiswa yang ngambil 'Intro. to Computer Science' tapi total SKSnya masih di bawah 60. Mau kita kasih bimbingan tambahan. Ga perlu pake alias ya! :D	SELECT s.ID, s.name, s.tot_cred, s.dept_name FROM student s JOIN takes t ON s.ID = t.ID JOIN course c ON t.course_id = c.course_id WHERE c.title = 'Intro. to Computer Science' AND s.tot_cred < 60;	1460	1475.4666381726804	{JOIN,WHERE,MULTI-TABLE}	t
CH03-Q003	CH03	Bisa tunjukin judul mata kuliah, hari, sama jam mulai dan berakhirnya nggak? Gabungin tiga tabel sekalian ya.	SELECT c.title, t.day, t.start_time, t.end_time FROM course c JOIN section s ON c.course_id = s.course_id JOIN time_slot t ON s.time_slot_id = t.time_slot_id;	1440	1425.405740550179	{JOIN,MULTI-TABLE}	t
CH03-Q008	CH03	Mata kuliah apa aja sih yang sama sekali nggak ada peminatnya (nggak diambil siapapun) di tahun 2009?	SELECT * FROM course WHERE course_id NOT IN (SELECT DISTINCT course_id FROM takes WHERE year = 2009);	1540	1547.6093384720841	{"NOT IN",SUBQUERY}	t
CH03-Q002	CH03	Coba cari tahu departemen mana aja yang ternyata belum punya dosen sama sekali. Pakai filter NULL ya! Ga perlu pake alias ya! :D	SELECT d.dept_name, COUNT(i.ID) FROM department d LEFT JOIN instructor i ON d.dept_name = i.dept_name GROUP BY d.dept_name HAVING COUNT(i.ID) = 0;	1420	1447.7449955306806	{"LEFT JOIN",HAVING,COUNT}	t
CH03-Q010	CH03	Tampilkan departemen yang nawarin setidaknya satu mata kuliah dengan SKS lebih dari 4.	SELECT * FROM department d WHERE EXISTS (SELECT * FROM course c WHERE c.dept_name = d.dept_name AND c.credits > 4);	1580	1566.1552911152369	{EXISTS,SUBQUERY}	t
CH03-Q011	CH03	Tolong gabungin daftar nama mahasiswa dari jurusan 'Physics' sama jurusan 'Elec. Eng.' jadi satu list. Ga perlu pake alias ya! :D	(SELECT name FROM student WHERE dept_name = 'Physics') UNION (SELECT name FROM student WHERE dept_name = 'Elec. Eng.');	1600	1582.5017325104825	{UNION,SET-OP}	t
CH03-Q009	CH03	Cari dosen yang gajinya lebih tinggi dibandingkan rata-rata gaji di departemennya sendiri. Sultan nih! Ga perlu pake alias ya! :D	SELECT * FROM instructor i WHERE salary > (SELECT AVG(salary) FROM instructor WHERE dept_name = i.dept_name);	1560	1565.610201687489	{"CORRELATED SUBQUERY"}	t
CH03-Q012	CH03	Tampilkan ruangan yang kapasitasnya di atas 100, tapi jangan masukin ruangan yang ada di gedung Watson.	(SELECT building, room_no, capacity FROM classroom WHERE capacity > 100) EXCEPT (SELECT building, room_no, capacity FROM classroom WHERE building = 'Watson');	1620	1624.3582330524775	{EXCEPT,SET-OP}	t
CH03-Q006	CH03	Tolong cari mata kuliah yang SKS-nya di atas rata-rata SKS semua mata kuliah yang ada.	SELECT * FROM course WHERE credits > (SELECT AVG(credits) FROM course);	1500	1523.1619960524683	{SUBQUERY,SCALAR}	t
CH03-Q022	CH03	Tampilkan judul mata kuliah, terus di kolom sebelahnya alias 'enrolled' hitung berapa banyak mahasiswa yang daftar di tiap mata kuliah itu.	SELECT c.title, (SELECT COUNT(*) FROM takes t WHERE t.course_id = c.course_id) AS enrolled FROM course c;	1775	1775	{"CORRELATED SUBQUERY",SELECT}	t
CH03-Q023	CH03	Amad ingin melihat mata kuliah-mata kuliah yang 'berat' dan 'ringan' yang ada di kampusnya. Bantu Amad untuk menampilkan judul mata kuliah dan kolom 'level' berisi 'berat' jka SKS >=4 dan 'ringan' jika SKS < 4. Urutkan berdasarkan 'level' tersebut.	SELECT title, credits, CASE WHEN credits >= 4 THEN 'berat' ELSE 'ringan' END AS level FROM course ORDER BY level;	1780	1780	{CASE,"ORDER BY"}	t
CH03-Q024	CH03	Tampilkan nama gedung, total budget fakultas (alias total_bud), dan banyaknya dosen unik (alias jml_dosen) yang berkantor di gedung tersebut. Tapi hanya untuk fakultas dengan total budget > 50 ribu	SELECT d.building, SUM(d.budget) AS total_bud, COUNT(DISTINCT i.ID) AS jml_dosen FROM department d LEFT JOIN instructor i ON d.dept_name = i.dept_name GROUP BY d.building HAVING SUM(d.budget) > 50000;	1785	1785	{"LEFT JOIN",SUM,COUNT,HAVING}	t
CH03-Q025	CH03	Tolong list 10 mahasiswa 'Senior' (SKS >= 90) dengan SKS tertinggi, dan kasih kolom status 'Excellent' kalau SKSnya sudah 120 ke atas, atau 'Good' kalau belum.	WITH high_cred_students AS (SELECT * FROM student WHERE tot_cred >= 90) SELECT h.name, h.dept_name, h.tot_cred, CASE WHEN h.tot_cred >= 120 THEN 'Excellent' ELSE 'Good' END AS status FROM high_cred_students h ORDER BY h.tot_cred DESC LIMIT 10;	1780	1780	{CTE,WITH,CASE,LIMIT}	t
CH02-Q008	CH02	Coba hitung rata-rata budget untuk departemen-departemen yang ada di gedung 'Taylor'. Tampilkan kolom rata-ratanya saja.	SELECT AVG(budget) FROM department WHERE building = 'Taylor';	1305	1288.214367439962	{AVG,WHERE}	t
CH01-Q024	CH01	Coba ada fakultas apa aja sih yang name nya mengandung kata subkata 'tech' dan budgetnya > 10jt!	SELECT * FROM department WHERE dept_name LIKE '%tech%' AND budget > 10000000;	1345	1255.5595647354633	{SELECT,WHERE,LIKE,COMPARISON}	t
CH02-Q007	CH02	Tampilkan nama semester, tahun, dan jumlah mata kuliah (alias jumlah_course) yang dibuka pada periode tersebut.	SELECT semester, year, COUNT(*) AS jumlah_course FROM section GROUP BY semester, year;	1290	1306.18694860843	{COUNT,"GROUP BY",MULTI-COLUMN}	t
CH02-Q006	CH02	Tolong rekap nama departemen dan total SKS yang ditawarkan di masing-masing departemen tersebut.	SELECT dept_name, SUM(credits) FROM course GROUP BY dept_name;	1275	1261.1136579547658	{SUM,"GROUP BY"}	t
CH02-Q003	CH02	Dosen-dosen penasaran nih, tolong tampilkan nama departemen dan berapa rata-rata total SKS mahasiswa di tiap departemen tersebut.	SELECT dept_name, AVG(tot_cred) FROM student GROUP BY dept_name;	1230	1207.655943324776	{AVG,"GROUP BY"}	t
CH02-Q015	CH02	Tolong tampilkan ID dosen dan berapa banyak mata kuliah yang mereka ajar masing-masing.	SELECT t.ID, COUNT(c.course_id) FROM teaches t JOIN course c ON t.course_id = c.course_id GROUP BY t.ID;	1410	1379.0575536401466	{COUNT,JOIN,"GROUP BY"}	t
CH02-Q013	CH02	Ada berapa banyak sih mahasiswa unik yang ngambil mata kuliah di tahun 2009? Tampilkan kolom count-nya saja.	SELECT COUNT(DISTINCT ID) FROM takes WHERE year = 2009;	1380	1336.6645076234445	{COUNT,DISTINCT,WHERE}	t
CH02-Q009	CH02	Tampilkan nama departemen dan total SKS mata kuliahnya untuk departemen yang total SKS-nya sudah lebih dari 10.	SELECT dept_name, SUM(credits) FROM course GROUP BY dept_name HAVING SUM(credits) > 10;	1320	1352.5011382173138	{SUM,"GROUP BY",HAVING}	t
CH02-Q004	CH02	Kita mau cari bintang kampus! Coba tampilkan nama departemen dan total SKS tertinggi (alias max_sks) di masing-masing departemen.	SELECT dept_name, MAX(tot_cred) AS max_sks FROM student GROUP BY dept_name;	1245	1249.89239940411	{MAX,"GROUP BY"}	t
CH02-Q005	CH02	Biasanya semester berapa sih yang beban matakuliahnya paling enteng? Coba tampilkan nama semester dan SKS paling kecil di tiap semester tersebut.	SELECT semester, MIN(credits) FROM course JOIN section ON course.course_id = section.course_id GROUP BY semester;	1260	1222.9042816868396	{MIN,"GROUP BY"}	t
CH02-Q016	CH02	Tampilkan judul mata kuliah beserta total mahasiswa yang terdaftar di setiap mata kuliah tersebut.	SELECT c.title, COUNT(t.ID) FROM takes t JOIN course c ON t.course_id = c.course_id GROUP BY c.title;	1425	1454.1765567598466	{COUNT,JOIN,"GROUP BY"}	t
CH02-Q012	CH02	Tampilkan nama departemen yang berani ngasih gaji dosen paling tinggi (di atas 90 ribu).	SELECT dept_name FROM instructor GROUP BY dept_name HAVING MAX(salary) > 90000;	1365	1347.1972265250633	{MAX,"GROUP BY",HAVING}	t
CH02-Q014	CH02	Coba hitung rata-rata total SKS untuk mahasiswa yang sudah punya lebih dari 50 SKS. Tampilkan kolom rata-ratanya saja.	SELECT AVG(tot_cred) FROM student WHERE tot_cred > 50;	1395	1311.171115228612	{AVG,WHERE}	t
CH02-Q010	CH02	Tunjukkan nama gedung dan rata-rata kapasitasnya, khusus untuk gedung yang punya rata-rata kapasitas di atas 80 orang.	SELECT building, AVG(capacity) FROM classroom GROUP BY building HAVING AVG(capacity) > 80;	1335	1299.4959247162778	{AVG,"GROUP BY",HAVING}	t
CH02-Q011	CH02	Tampilkan nama departemen dan jumlah dosen di tiap departemen tersebut, lalu urutkan dari yang paling banyak personilnya.	SELECT dept_name, COUNT(ID) FROM instructor GROUP BY dept_name ORDER BY COUNT(ID) DESC;	1350	1337.140712910839	{COUNT,"GROUP BY","ORDER BY"}	t
CH03-Q007	CH03	Siapa aja mahasiswa yang dosen pembimbingnya berasal dari departemen 'Comp. Sci.'? Ga perlu pake alias ya! :D	SELECT DISTINCT s.ID, s.name FROM student s JOIN advisor a ON s.ID = a.s_ID WHERE a.i_ID IN (SELECT ID FROM instructor WHERE dept_name = 'Comp. Sci.');	1520	1533.7823811372048	{IN,SUBQUERY,JOIN}	t
CH02-Q017	CH02	Tampilkan nama departemen yang punya dosen lebih dari 2 orang.	SELECT dept_name FROM instructor GROUP BY dept_name HAVING COUNT(ID) > 2;	1440	1412.671511543356	{COUNT,"GROUP BY",HAVING}	t
CH02-Q024	CH02	Tampilkan kode mata kuliah, ID kelas, semester, tahun, and jumlah mahasiswa unik di setiap kelas tersebut.	SELECT course_id, sec_id, semester, year, COUNT(DISTINCT ID) FROM takes GROUP BY course_id, sec_id, semester, year;	1545	1580.7812717820552	{COUNT,DISTINCT,"GROUP BY"}	t
CH02-Q025	CH02	Tolong tampilkan klasifikasi angkatan (alias classification) and jumlah mahasiswa di setiap kategori tersebut.	SELECT CASE WHEN tot_cred < 30 THEN 'Freshman' WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore' WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior' ELSE 'Final Year' END AS classification, COUNT(*) AS jumlah FROM student GROUP BY classification;	1580	1626.4021898331105	{CASE,COUNT,"GROUP BY"}	t
CH02-Q023	CH02	Tolong tampilkan nama gedung and total budget departemen di gedung tersebut, khusus untuk gedung yang total budget-nya di atas 50 ribu.	SELECT building, SUM(budget) FROM department GROUP BY building HAVING SUM(budget) > 50000;	1530	1467.6237677966972	{SUM,"GROUP BY",HAVING}	t
CH02-Q020	CH02	Tampilkan nama mahasiswa, total SKS, and klasifikasinya (alias classification) berdasarkan aturan: <30 'Freshman', 30-59 'Sophomore', 60-89 'Junior', sisanya 'Final Year'.	SELECT name, tot_cred, CASE WHEN tot_cred < 30 THEN 'Freshman' WHEN tot_cred BETWEEN 30 AND 59 THEN 'Sophomore' WHEN tot_cred BETWEEN 60 AND 89 THEN 'Junior' ELSE 'Final Year' END AS classification FROM student;	1485	1490.416881221799	{CASE,SELECT}	t
CH02-Q022	CH02	Tampilkan nama departemen and rata-rata total SKS (alias avg_cred) mahasiswa untuk 3 departemen dengan rata-rata tertinggi.	SELECT dept_name, AVG(tot_cred) AS avg_cred FROM student GROUP BY dept_name ORDER BY avg_cred DESC LIMIT 3;	1515	1486.412904738266	{AVG,"GROUP BY","ORDER BY",LIMIT}	t
CH03-Q005	CH03	Tampilkan daftar mata kuliah beserta nama mata kuliah prasyaratnya. Biar mahasiswa nggak bingung pas mau ngambil.	SELECT c.course_id, c.title, p.prereq_id, pr.title AS prereq_title FROM course c JOIN prereq p ON c.course_id = p.course_id JOIN course pr ON p.prereq_id = pr.course_id;	1480	1509.857537867011	{JOIN,SELF-JOIN}	t
CH02-Q018	CH02	Tampilkan nama departemen dan rata-rata gaji dosennya, khusus untuk departemen yang berada di bawah naungan fakultas dengan budget di atas 150 ribu.	SELECT dept_name, AVG(salary) FROM instructor WHERE dept_name IN (SELECT dept_name FROM department WHERE budget > 150000) GROUP BY dept_name;	1455	1426.229773210524	{AVG,WHERE,SUBQUERY,"GROUP BY"}	t
CH02-Q019	CH02	Daftarkan nama departemen, jumlah mata kuliah, dan rata-rata SKS-nya untuk departemen yang rata-rata SKS mata kuliahnya 3 ke atas.	SELECT dept_name, COUNT(*), AVG(credits) FROM course GROUP BY dept_name HAVING AVG(credits) >= 3;	1470	1480.2149515922654	{AVG,COUNT,"GROUP BY",HAVING}	t
CH02-Q021	CH02	Tampilkan ID jadwal (time slot) and berapa banyak kelas yang menggunakan jadwal tersebut, untuk jadwal yang setidaknya digunakan oleh satu kelas.	SELECT ts.time_slot_id, COUNT(*) FROM time_slot ts LEFT JOIN section s ON ts.time_slot_id = s.time_slot_id GROUP BY ts.time_slot_id HAVING COUNT(*) > 0;	1500	1499.6715130541677	{COUNT,"LEFT JOIN","GROUP BY",HAVING}	t
\.


--
-- TOC entry 3564 (class 0 OID 16640)
-- Dependencies: 236
-- Data for Name: user_module_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_module_progress (user_id, module_id, is_completed, started_at, completed_at, is_unlocked) FROM stdin;
53750c4a-a048-4037-b563-272d5c8b2567	CH03	f	2026-05-03 13:54:48.462741+00	\N	f
d897aef3-80ea-473d-be4c-f4367cbc4d93	CH03	f	2026-05-07 08:07:07.303731+00	\N	f
e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH03	f	2026-05-07 08:07:47.711799+00	\N	f
7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH03	f	2026-05-07 08:08:38.766837+00	\N	f
e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH02	f	2026-05-07 08:07:47.711799+00	\N	t
e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	CH01	t	2026-05-07 08:07:47.711799+00	2026-05-07 08:18:08.100654+00	f
c1b54361-4d33-4c69-936d-ee088bedfd00	CH01	t	2026-05-07 08:07:43.16138+00	2026-05-07 08:22:53.419526+00	f
7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH02	f	2026-05-07 08:08:38.766837+00	\N	t
7e2e07f2-813f-4c75-abfc-dc1d009b35a1	CH01	t	2026-05-07 08:08:38.766837+00	2026-05-07 08:27:11.127027+00	f
d897aef3-80ea-473d-be4c-f4367cbc4d93	CH02	f	2026-05-07 08:07:07.303731+00	\N	t
d897aef3-80ea-473d-be4c-f4367cbc4d93	CH01	t	2026-05-07 08:07:07.303731+00	2026-05-07 09:00:03.792429+00	f
c1b54361-4d33-4c69-936d-ee088bedfd00	CH03	f	2026-05-07 08:07:43.16138+00	\N	t
c1b54361-4d33-4c69-936d-ee088bedfd00	CH02	t	2026-05-07 08:07:43.16138+00	2026-05-08 00:45:55.675204+00	t
53750c4a-a048-4037-b563-272d5c8b2567	CH02	f	2026-05-03 13:54:48.462741+00	\N	t
53750c4a-a048-4037-b563-272d5c8b2567	CH01	t	2026-05-03 13:54:48.462741+00	2026-05-08 14:10:24.065032+00	f
1907a5eb-a5a4-4782-b2af-b5779b706982	CH03	f	2026-05-09 05:45:05.647939+00	\N	f
32c7420c-0bf8-4aa7-8174-45e980dee27c	CH03	f	2026-05-09 05:50:28.777058+00	\N	f
71ff93d9-bdd1-441d-8984-d4094ae239d0	CH03	f	2026-05-09 05:53:13.701214+00	\N	f
417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH01	t	2026-05-09 05:50:02.528833+00	2026-05-09 05:54:18.829069+00	f
e0e04c7e-8e71-49d6-8a65-a76b82826016	CH03	f	2026-05-09 05:54:40.219272+00	\N	f
dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH01	t	2026-05-09 05:45:12.296382+00	2026-05-09 06:06:28.815237+00	f
71ff93d9-bdd1-441d-8984-d4094ae239d0	CH02	f	2026-05-09 05:53:13.701214+00	\N	t
71ff93d9-bdd1-441d-8984-d4094ae239d0	CH01	t	2026-05-09 05:53:13.701214+00	2026-05-09 06:08:56.792088+00	f
e0e04c7e-8e71-49d6-8a65-a76b82826016	CH02	f	2026-05-09 05:54:40.219272+00	\N	t
e0e04c7e-8e71-49d6-8a65-a76b82826016	CH01	t	2026-05-09 05:54:40.219272+00	2026-05-09 06:15:08.598194+00	f
1907a5eb-a5a4-4782-b2af-b5779b706982	CH02	f	2026-05-09 05:45:05.647939+00	\N	t
1907a5eb-a5a4-4782-b2af-b5779b706982	CH01	t	2026-05-09 05:45:05.647939+00	2026-05-09 06:19:10.32374+00	f
dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH03	f	2026-05-09 05:45:12.296382+00	\N	t
dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	CH02	t	2026-05-09 05:45:12.296382+00	2026-05-09 06:45:21.705375+00	t
417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH03	f	2026-05-09 05:50:02.528833+00	\N	t
417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	CH02	t	2026-05-09 05:50:02.528833+00	2026-05-09 06:48:42.431619+00	t
32c7420c-0bf8-4aa7-8174-45e980dee27c	CH02	f	2026-05-09 05:50:28.777058+00	\N	t
32c7420c-0bf8-4aa7-8174-45e980dee27c	CH01	t	2026-05-09 05:50:28.777058+00	2026-05-09 06:59:25.340573+00	f
\.


--
-- TOC entry 3561 (class 0 OID 16578)
-- Dependencies: 233
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, nim, full_name, password_hash, theta_social, k_factor, has_completed_pretest, created_at, theta_individu, total_attempts, status, group_assignment, stagnation_ever_detected, is_admin, is_deleted, deleted_at) FROM stdin;
7e2e07f2-813f-4c75-abfc-dc1d009b35a1	18223001	Darren Mansyl	$argon2id$v=19$m=65536,t=3,p=4$vZeylrJ27p0zxnjv/T+nNA$T72x2bklrwzkZkClbwlJ6A5IYXHp0cLcofOD0DokroY	1300	15	t	2026-05-03 14:10:12.22317+00	1369.8513693125378	27	ACTIVE	B	t	f	f	\N
32c7420c-0bf8-4aa7-8174-45e980dee27c	18223078	Vincentia Belinda Sumartoyo	$argon2id$v=19$m=65536,t=3,p=4$+j/H2DsnZAxhzHnvHaMUYg$Na/QIsin5sgDvCh3VlRskA0zjR4Ll2rWl85EXGQlx1s	1315.0664565116167	20	t	2026-05-03 14:04:46.282657+00	1369.5441989076667	31	ACTIVE	A	t	f	f	\N
417880d7-6da0-4fd6-9f4e-f61b2e70d5ab	18223023	Sarah Alwa Neguita Surbakti 	$argon2id$v=19$m=65536,t=3,p=4$fU+JEQIAQMjZe89Zay3FGA$/YyqhnyqTjXvUAV4aYUyq5A9AGsU9bTcQyrZXIF2V/Q	1313.7177789211273	20	t	2026-05-03 14:11:07.351494+00	1509.925637043265	18	ACTIVE	A	t	f	f	\N
53750c4a-a048-4037-b563-272d5c8b2567	111222333	admin123	$argon2id$v=19$m=65536,t=3,p=4$spbS2hsjhDCmtBbCOAdAqA$VfQ6O4f1oQbKmOZGnm4IjcnJEto8ujCP/8h/eBtYVjo	1300	20	t	2026-05-03 13:49:23.533431+00	1400.0710121061993	13	NEEDS_PEER_REVIEW	A	t	t	f	\N
c1b54361-4d33-4c69-936d-ee088bedfd00	18223046	Farella Kamala Budianto	$argon2id$v=19$m=65536,t=3,p=4$7v0/BwCgFIJw7t0bo3SulQ$FTBLfjWuPVR0+e/a60bO9jIT/ISh2r5EQ1ez1Egefgk	1300	30	t	2026-05-03 13:55:58.107896+00	1524.6205960480734	130	ACTIVE	B	t	f	f	\N
e1963a44-bf91-4a7e-80eb-6c6cc0a43acb	18223098	Kenlyn Tesalonika Winata	$argon2id$v=19$m=65536,t=3,p=4$CSEEAGDM2fs/5/w/h/DeWw$fQT/yewFUbPKSmKgFDmRgq4h5P1vjFYjZ5RF/dQxs6c	1300	30	t	2026-05-03 14:06:53.976526+00	1325.6363129373476	20	ACTIVE	B	t	f	f	\N
7051569a-fc90-48d4-a186-639c1dc2ca7e	1822200Y	1822200Y	$argon2id$v=19$m=65536,t=3,p=4$ec+Zs/a+956zdm6NsTZGqA$9twkEi+p+5nBjI2ONjk9+6O7dKkMoPobodlpudZpa5E	1300	30	f	2026-05-09 04:01:05.79243+00	1300	0	ACTIVE	A	f	f	f	\N
b28ca094-8a90-4d30-930c-ea7fc554e7c3	1822200Z	1822200Z	$argon2id$v=19$m=65536,t=3,p=4$iPH+/38PIaQUAiAkxJjTWg$agq4XdQXU3D6BEIbqfd1RBaUyLFFqKhuq2VazL6hH6E	1300	30	f	2026-05-09 04:01:15.54579+00	1400	0	ACTIVE	A	f	f	f	\N
d897aef3-80ea-473d-be4c-f4367cbc4d93	18223101	Ni Made Sekar Jelita Parameswari 	$argon2id$v=19$m=65536,t=3,p=4$HyNE6L3XGgNAaK0VgvA+Zw$KXhdnTPUZigJ1opTVUNnE8F80YZS/Opi/CdR9fkdjoo	1300	15	t	2026-05-03 14:09:39.980305+00	1220.234208267703	49	ACTIVE	B	t	f	f	\N
6d23e37a-d746-4a4a-b9be-29507cc9a88c	18222001	18222001	$argon2id$v=19$m=65536,t=3,p=4$U2qNsRailJKSEmIsRag1hg$j598y0CZkgTcgPceS66n+8BocRLLX/1EKp6S1y6nW7g	1301.5	30	f	2026-05-09 04:00:53.901278+00	1200	0	ACTIVE	A	f	f	f	\N
e0e04c7e-8e71-49d6-8a65-a76b82826016	18223004	Muhammad Farhan	$argon2id$v=19$m=65536,t=3,p=4$K6UU4tw7R0iptZYyxvjfOw$71S2KjFNp3cL86X2w2npJuv3irLtOxMPFNOkaZg6cCA	1315.1417642235756	15	t	2026-05-03 14:08:53.194339+00	1374.8622834814662	22	ACTIVE	A	t	f	f	\N
71ff93d9-bdd1-441d-8984-d4094ae239d0	18223106	Nurul Na'im Natifah	$argon2id$v=19$m=65536,t=3,p=4$QwiB8H5PaY3RutfauzdGaA$3DOgW1RiiydzBsDhKp9MQEgwuPiSkw1OIQB09Trb4rY	1313.6825735867023	20	t	2026-05-03 13:57:14.092613+00	1451.1667603699636	16	ACTIVE	A	t	f	f	\N
dc1b1d60-9a59-45c1-bb0c-1320aad3f9c2	18223100	Indana Aulia Ayundazulfa	$argon2id$v=19$m=65536,t=3,p=4$nDNGaC2F8B4DwNg7h5Dyng$kUVHIxtHBPaswrg5s/PhcBEuDOLPn0ZZO+Q7BMVgCi0	1300	30	t	2026-05-03 14:06:05.770077+00	1529.342543084973	36	ACTIVE	A	t	f	f	\N
1907a5eb-a5a4-4782-b2af-b5779b706982	18223102	Joan Melkior Silaen	$argon2id$v=19$m=65536,t=3,p=4$nRPiHEPIGUOIUQqhFCJEqA$H5ctP4IwK2jS6Cg3PEM3bGTkDW66QTQV+Jo1Jn5Zkvo	1300	15	t	2026-05-03 14:08:13.586553+00	1435.685471045497	23	ACTIVE	A	t	f	f	\N
\.


--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 237
-- Name: assessment_logs_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.assessment_logs_log_id_seq', 707, true);


--
-- TOC entry 3370 (class 2606 OID 16566)
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- TOC entry 3386 (class 2606 OID 16679)
-- Name: assessment_logs assessment_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_logs
    ADD CONSTRAINT assessment_logs_pkey PRIMARY KEY (log_id);


--
-- TOC entry 3397 (class 2606 OID 16752)
-- Name: assessment_sessions assessment_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_sessions
    ADD CONSTRAINT assessment_sessions_pkey PRIMARY KEY (session_id);


--
-- TOC entry 3372 (class 2606 OID 16577)
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules
    ADD CONSTRAINT modules_pkey PRIMARY KEY (module_id);


--
-- TOC entry 3395 (class 2606 OID 16710)
-- Name: peer_sessions peer_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.peer_sessions
    ADD CONSTRAINT peer_sessions_pkey PRIMARY KEY (session_id);


--
-- TOC entry 3378 (class 2606 OID 16612)
-- Name: pretest_sessions pretest_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pretest_sessions
    ADD CONSTRAINT pretest_sessions_pkey PRIMARY KEY (session_id);


--
-- TOC entry 3382 (class 2606 OID 16632)
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (question_id);


--
-- TOC entry 3384 (class 2606 OID 16649)
-- Name: user_module_progress user_module_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_module_progress
    ADD CONSTRAINT user_module_progress_pkey PRIMARY KEY (user_id, module_id);


--
-- TOC entry 3375 (class 2606 OID 16596)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3387 (class 1259 OID 16690)
-- Name: ix_assessment_logs_question_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_assessment_logs_question_id ON public.assessment_logs USING btree (question_id);


--
-- TOC entry 3388 (class 1259 OID 16691)
-- Name: ix_assessment_logs_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_assessment_logs_session_id ON public.assessment_logs USING btree (session_id);


--
-- TOC entry 3389 (class 1259 OID 16692)
-- Name: ix_assessment_logs_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_assessment_logs_timestamp ON public.assessment_logs USING btree ("timestamp");


--
-- TOC entry 3390 (class 1259 OID 16693)
-- Name: ix_assessment_logs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_assessment_logs_user_id ON public.assessment_logs USING btree (user_id);


--
-- TOC entry 3398 (class 1259 OID 16763)
-- Name: ix_assessment_sessions_module_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_assessment_sessions_module_id ON public.assessment_sessions USING btree (module_id);


--
-- TOC entry 3399 (class 1259 OID 16764)
-- Name: ix_assessment_sessions_question_ids_served; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_assessment_sessions_question_ids_served ON public.assessment_sessions USING btree (question_ids_served);


--
-- TOC entry 3400 (class 1259 OID 16765)
-- Name: ix_assessment_sessions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_assessment_sessions_user_id ON public.assessment_sessions USING btree (user_id);


--
-- TOC entry 3391 (class 1259 OID 16726)
-- Name: ix_peer_sessions_question_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_peer_sessions_question_id ON public.peer_sessions USING btree (question_id);


--
-- TOC entry 3392 (class 1259 OID 16727)
-- Name: ix_peer_sessions_requester_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_peer_sessions_requester_id ON public.peer_sessions USING btree (requester_id);


--
-- TOC entry 3393 (class 1259 OID 16728)
-- Name: ix_peer_sessions_reviewer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_peer_sessions_reviewer_id ON public.peer_sessions USING btree (reviewer_id);


--
-- TOC entry 3376 (class 1259 OID 16618)
-- Name: ix_pretest_sessions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pretest_sessions_user_id ON public.pretest_sessions USING btree (user_id);


--
-- TOC entry 3379 (class 1259 OID 16638)
-- Name: ix_questions_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_questions_is_active ON public.questions USING btree (is_active);


--
-- TOC entry 3380 (class 1259 OID 16639)
-- Name: ix_questions_module_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_questions_module_id ON public.questions USING btree (module_id);


--
-- TOC entry 3373 (class 1259 OID 16597)
-- Name: ix_users_nim; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_nim ON public.users USING btree (nim);


--
-- TOC entry 3405 (class 2606 OID 16680)
-- Name: assessment_logs assessment_logs_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_logs
    ADD CONSTRAINT assessment_logs_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(question_id) ON DELETE RESTRICT;


--
-- TOC entry 3406 (class 2606 OID 16685)
-- Name: assessment_logs assessment_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_logs
    ADD CONSTRAINT assessment_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3410 (class 2606 OID 16753)
-- Name: assessment_sessions assessment_sessions_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_sessions
    ADD CONSTRAINT assessment_sessions_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(module_id) ON DELETE CASCADE;


--
-- TOC entry 3411 (class 2606 OID 16758)
-- Name: assessment_sessions assessment_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_sessions
    ADD CONSTRAINT assessment_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3407 (class 2606 OID 16711)
-- Name: peer_sessions peer_sessions_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.peer_sessions
    ADD CONSTRAINT peer_sessions_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(question_id) ON DELETE RESTRICT;


--
-- TOC entry 3408 (class 2606 OID 16716)
-- Name: peer_sessions peer_sessions_requester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.peer_sessions
    ADD CONSTRAINT peer_sessions_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3409 (class 2606 OID 16721)
-- Name: peer_sessions peer_sessions_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.peer_sessions
    ADD CONSTRAINT peer_sessions_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3401 (class 2606 OID 16613)
-- Name: pretest_sessions pretest_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pretest_sessions
    ADD CONSTRAINT pretest_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3402 (class 2606 OID 16633)
-- Name: questions questions_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(module_id) ON DELETE CASCADE;


--
-- TOC entry 3403 (class 2606 OID 16650)
-- Name: user_module_progress user_module_progress_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_module_progress
    ADD CONSTRAINT user_module_progress_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(module_id) ON DELETE CASCADE;


--
-- TOC entry 3404 (class 2606 OID 16655)
-- Name: user_module_progress user_module_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_module_progress
    ADD CONSTRAINT user_module_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


-- Completed on 2026-05-10 21:29:10

--
-- PostgreSQL database dump complete
--

\unrestrict IIQLulhkjAjrluW4j2f9X7XzZ4aiTUlKHX5cqW3tT3xlWC566f6eg5yLrbhNIZD

