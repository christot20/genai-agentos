--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg120+1)
-- Dumped by pg_dump version 17.5 (Debian 17.5-1.pgdg120+1)

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
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- Name: navicare; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA navicare;


ALTER SCHEMA navicare OWNER TO postgres;

--
-- Name: sendertype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.sendertype AS ENUM (
    'user',
    'master_agent'
);


ALTER TYPE public.sendertype OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: conversations; Type: TABLE; Schema: navicare; Owner: postgres
--

CREATE TABLE navicare.conversations (
    conversation_id uuid NOT NULL,
    creator_id uuid NOT NULL,
    title character varying,
    creation_date timestamp with time zone DEFAULT now() NOT NULL,
    updated_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE navicare.conversations OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: navicare; Owner: postgres
--

CREATE TABLE navicare.messages (
    message_id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    sender_type character varying NOT NULL,
    creation_date timestamp with time zone DEFAULT now() NOT NULL,
    message character varying NOT NULL
);


ALTER TABLE navicare.messages OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: navicare; Owner: postgres
--

CREATE TABLE navicare.users (
    uuid uuid NOT NULL,
    first_name character varying NOT NULL,
    email character varying NOT NULL,
    salt bytea NOT NULL,
    password character varying NOT NULL,
    creation_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE navicare.users OWNER TO postgres;

--
-- Name: a2acards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.a2acards (
    id uuid NOT NULL,
    name character varying,
    alias character varying,
    description character varying,
    server_url character varying NOT NULL,
    card_content json NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    creator_id uuid
);


ALTER TABLE public.a2acards OWNER TO postgres;

--
-- Name: agent_project_associations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agent_project_associations (
    id integer NOT NULL,
    agent_id uuid NOT NULL,
    project_id uuid NOT NULL
);


ALTER TABLE public.agent_project_associations OWNER TO postgres;

--
-- Name: agent_project_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agent_project_associations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.agent_project_associations_id_seq OWNER TO postgres;

--
-- Name: agent_project_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agent_project_associations_id_seq OWNED BY public.agent_project_associations.id;


--
-- Name: agentflow_project_associations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agentflow_project_associations (
    id integer NOT NULL,
    flow_id uuid NOT NULL,
    project_id uuid NOT NULL
);


ALTER TABLE public.agentflow_project_associations OWNER TO postgres;

--
-- Name: agentflow_project_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agentflow_project_associations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.agentflow_project_associations_id_seq OWNER TO postgres;

--
-- Name: agentflow_project_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agentflow_project_associations_id_seq OWNED BY public.agentflow_project_associations.id;


--
-- Name: agents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agents (
    id uuid NOT NULL,
    alias character varying NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    jwt character varying NOT NULL,
    creator_id uuid,
    input_parameters json NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    last_invoked_at timestamp without time zone DEFAULT now() NOT NULL,
    is_active boolean NOT NULL
);


ALTER TABLE public.agents OWNER TO postgres;

--
-- Name: agentworkflows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agentworkflows (
    id uuid NOT NULL,
    alias character varying NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    flow json NOT NULL,
    creator_id uuid,
    is_active boolean NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.agentworkflows OWNER TO postgres;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: chatconversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chatconversations (
    session_id uuid NOT NULL,
    title character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    creator_id uuid
);


ALTER TABLE public.chatconversations OWNER TO postgres;

--
-- Name: chatmessages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chatmessages (
    id uuid NOT NULL,
    request_id uuid,
    sender_type public.sendertype NOT NULL,
    content character varying NOT NULL,
    extra_metadata json,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    conversation_id uuid
);


ALTER TABLE public.chatmessages OWNER TO postgres;

--
-- Name: files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.files (
    id uuid NOT NULL,
    session_id uuid,
    request_id uuid,
    creator_id uuid,
    mimetype character varying NOT NULL,
    original_name character varying NOT NULL,
    internal_name character varying NOT NULL,
    internal_id uuid NOT NULL,
    from_agent boolean NOT NULL
);


ALTER TABLE public.files OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    id integer NOT NULL,
    session_id uuid NOT NULL,
    request_id uuid NOT NULL,
    agent_id character varying,
    creator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    message character varying NOT NULL,
    log_level character varying NOT NULL
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.logs_id_seq OWNER TO postgres;

--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.logs_id_seq OWNED BY public.logs.id;


--
-- Name: mcpservers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mcpservers (
    id uuid NOT NULL,
    name character varying,
    description character varying,
    server_url character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    creator_id uuid,
    is_active boolean NOT NULL
);


ALTER TABLE public.mcpservers OWNER TO postgres;

--
-- Name: mcptools; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mcptools (
    id uuid NOT NULL,
    name character varying NOT NULL,
    description character varying,
    "inputSchema" json NOT NULL,
    annotations json,
    alias character varying,
    mcp_server_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mcptools OWNER TO postgres;

--
-- Name: modelconfigs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modelconfigs (
    id uuid NOT NULL,
    name character varying NOT NULL,
    model character varying NOT NULL,
    provider_id uuid,
    system_prompt character varying NOT NULL,
    user_prompt character varying,
    max_last_messages integer NOT NULL,
    temperature double precision NOT NULL,
    credentials json NOT NULL,
    creator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.modelconfigs OWNER TO postgres;

--
-- Name: modelproviders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modelproviders (
    id uuid NOT NULL,
    name character varying NOT NULL,
    api_key character varying,
    provider_metadata json NOT NULL,
    creator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.modelproviders OWNER TO postgres;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id uuid NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teams (
    id uuid NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.teams OWNER TO postgres;

--
-- Name: user_project_associations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_project_associations (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    project_id uuid NOT NULL
);


ALTER TABLE public.user_project_associations OWNER TO postgres;

--
-- Name: user_project_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_project_associations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_project_associations_id_seq OWNER TO postgres;

--
-- Name: user_project_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_project_associations_id_seq OWNED BY public.user_project_associations.id;


--
-- Name: user_team_associations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_team_associations (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    team_id uuid NOT NULL
);


ALTER TABLE public.user_team_associations OWNER TO postgres;

--
-- Name: user_team_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_team_associations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_team_associations_id_seq OWNER TO postgres;

--
-- Name: user_team_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_team_associations_id_seq OWNED BY public.user_team_associations.id;


--
-- Name: userprofiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.userprofiles (
    id uuid NOT NULL,
    first_name character varying,
    last_name character varying,
    user_id uuid
);


ALTER TABLE public.userprofiles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    username character varying NOT NULL,
    password character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: agent_project_associations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_project_associations ALTER COLUMN id SET DEFAULT nextval('public.agent_project_associations_id_seq'::regclass);


--
-- Name: agentflow_project_associations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentflow_project_associations ALTER COLUMN id SET DEFAULT nextval('public.agentflow_project_associations_id_seq'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public.logs_id_seq'::regclass);


--
-- Name: user_project_associations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_associations ALTER COLUMN id SET DEFAULT nextval('public.user_project_associations_id_seq'::regclass);


--
-- Name: user_team_associations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_team_associations ALTER COLUMN id SET DEFAULT nextval('public.user_team_associations_id_seq'::regclass);


--
-- Data for Name: job; Type: TABLE DATA; Schema: cron; Owner: postgres
--

COPY cron.job (jobid, schedule, command, nodename, nodeport, database, username, active, jobname) FROM stdin;
\.


--
-- Data for Name: job_run_details; Type: TABLE DATA; Schema: cron; Owner: postgres
--

COPY cron.job_run_details (jobid, runid, job_pid, database, username, command, status, return_message, start_time, end_time) FROM stdin;
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: navicare; Owner: postgres
--

COPY navicare.conversations (conversation_id, creator_id, title, creation_date, updated_date) FROM stdin;
505881f2-ac67-4762-bc0b-ae6537f52883	3adcea23-300e-4610-aac1-4d98cfb36910	\N	2025-07-13 04:36:03.512911+00	2025-07-13 04:36:03.512911+00
7720229b-c122-4dc1-a522-79ea0ebc183a	0509f487-7963-402b-a90d-bfd067826cb1	\N	2025-07-13 06:54:00.873046+00	2025-07-13 06:54:00.873046+00
3f29c8a4-5cb6-4069-903d-7def813591e8	35f4563f-b208-4eb9-980b-9b9dca50085a	\N	2025-07-13 14:15:01.537619+00	2025-07-13 14:15:01.537619+00
2de11394-9963-483b-8b1b-7d7af7e2abeb	5c70ff59-026a-4367-9851-3c56808d6b76	\N	2025-07-13 14:23:12.405114+00	2025-07-13 14:23:12.405114+00
775f44ca-560f-46a2-98e7-65de423e3eb1	a66aa89c-84c1-40d6-a865-6db56f4519e9	\N	2025-07-13 14:58:41.66715+00	2025-07-13 14:58:41.66715+00
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: navicare; Owner: postgres
--

COPY navicare.messages (message_id, conversation_id, sender_type, creation_date, message) FROM stdin;
efa9fd80-f098-4181-8065-8f8b999e7603	505881f2-ac67-4762-bc0b-ae6537f52883	User	2025-07-13 05:42:23.34289+00	test message
8a4e5cef-7dd5-4222-88af-219997f125b6	505881f2-ac67-4762-bc0b-ae6537f52883	User	2025-07-13 05:47:48.803477+00	test message
5e937047-43d4-485a-9c87-f6abf632da0c	505881f2-ac67-4762-bc0b-ae6537f52883	User	2025-07-13 05:47:49.898643+00	test message
9695938f-66f0-43f2-ae24-0b0c87d172e3	505881f2-ac67-4762-bc0b-ae6537f52883	User	2025-07-13 05:48:01.527741+00	test message
e5f568e7-8e94-45a4-8c96-a8e611cb8476	505881f2-ac67-4762-bc0b-ae6537f52883	User	2025-07-13 05:48:02.207355+00	test message
2d087d47-a1bd-4815-aa60-5697bbd44ae5	505881f2-ac67-4762-bc0b-ae6537f52883	User	2025-07-13 05:48:02.828556+00	test message
d214e0e9-c4e7-47dd-b805-e2240679a9cd	7720229b-c122-4dc1-a522-79ea0ebc183a	User	2025-07-13 07:04:20.506125+00	Test message!!!
4d95f0d4-026f-4846-afbd-e72262104413	7720229b-c122-4dc1-a522-79ea0ebc183a	User	2025-07-13 07:04:28.676583+00	Another message
83e926d8-2b7e-4708-826a-f6b374bd3aae	7720229b-c122-4dc1-a522-79ea0ebc183a	User	2025-07-13 07:05:11.242236+00	!!!!!!!!!!!!!!!
1e036143-8a98-4513-8670-d411f1bf0694	3f29c8a4-5cb6-4069-903d-7def813591e8	User	2025-07-13 14:15:20.075359+00	Hello!
9e95ec10-be25-4d80-91da-3fb017495c18	3f29c8a4-5cb6-4069-903d-7def813591e8	User	2025-07-13 14:15:22.818079+00	1
aca239c5-4a8f-40c1-ba55-72f01cd0eb77	3f29c8a4-5cb6-4069-903d-7def813591e8	User	2025-07-13 14:15:23.118214+00	2
1a5467fc-ce17-4e70-8d7d-e32230e0b184	3f29c8a4-5cb6-4069-903d-7def813591e8	User	2025-07-13 14:15:23.313176+00	3
1669ba92-0bb1-4482-9cab-a955e30efcb2	3f29c8a4-5cb6-4069-903d-7def813591e8	User	2025-07-13 14:15:23.658457+00	4
a524f4d5-e194-42e9-aa55-57df1d17e03c	3f29c8a4-5cb6-4069-903d-7def813591e8	User	2025-07-13 14:15:36.222589+00	test message
4c79c262-51e2-42ba-a9f5-3a0d99481400	3f29c8a4-5cb6-4069-903d-7def813591e8	User	2025-07-13 14:22:27.857987+00	a
bd520f98-5cbf-45be-8c09-03e48fc3a0b3	775f44ca-560f-46a2-98e7-65de423e3eb1	User	2025-07-13 14:58:43.393174+00	Hey
e43598ac-5aff-4ce8-81c6-0da35e696151	775f44ca-560f-46a2-98e7-65de423e3eb1	AI	2025-07-13 14:58:44.515528+00	AI Agent Response: I received your message: 'Hey'. This is a simulated response from the master agent. In a real implementation, this would be processed by the actual AI agent.
c8a90274-d86a-4cef-85a5-75501828bd5d	775f44ca-560f-46a2-98e7-65de423e3eb1	User	2025-07-13 14:58:49.071505+00	Hello?
3fc42b2e-3c77-461b-9060-9d046baebf63	775f44ca-560f-46a2-98e7-65de423e3eb1	AI	2025-07-13 14:58:50.144149+00	AI Agent Response: I received your message: 'Hello?'. This is a simulated response from the master agent. In a real implementation, this would be processed by the actual AI agent.
66a86557-554c-475c-b3b8-88da4013b25b	775f44ca-560f-46a2-98e7-65de423e3eb1	User	2025-07-13 15:05:55.671489+00	Hello
75a48e6f-4bdb-4345-b504-40345880eba7	775f44ca-560f-46a2-98e7-65de423e3eb1	AI	2025-07-13 15:05:56.735013+00	AI Agent Response: I received your message: 'Hello'. This is a simulated response from the master agent. In a real implementation, this would be processed by the actual AI agent.
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: navicare; Owner: postgres
--

COPY navicare.users (uuid, first_name, email, salt, password, creation_date) FROM stdin;
7def4f7e-46e2-45b9-8394-69ed8eab4248	Test	test@gmail.com	\\x243262243132245373612f724f77384e565078336e6a676c426637732e	$2b$12$Ssa/rOw8NVPx3njglBf7s.AnkyPW3gPRz8gxq2klDZa/RbBSNB4oG	2025-07-13 02:47:00.221846+00
3adcea23-300e-4610-aac1-4d98cfb36910	test	test@test.com	\\x243262243132246c6a326f3058574b2f63714663526c326268726a464f	$2b$12$lj2o0XWK/cqFcRl2bhrjFO0jP1WkLCHp/ewT6xA.eiyj1bcWYqetG	2025-07-13 04:24:01.659366+00
0509f487-7963-402b-a90d-bfd067826cb1	jake	a@a.com	\\x243262243132244e676c626d7853306d454f4f4b575755564f7350782e	$2b$12$NglbmxS0mEOOKWWUVOsPx.7KAfIlZ2BXH6.Lcccad2NDh.FNJQeoW	2025-07-13 06:42:08.841439+00
35f4563f-b208-4eb9-980b-9b9dca50085a	j	j@j.com	\\x243262243132246255796a4f4c3576372f79615656575547435133584f	$2b$12$bUyjOL5v7/yaVVWUGCQ3XOCC73nfcsgdzspaBJw3bbh/iGyCE9./K	2025-07-13 14:11:55.288661+00
84ff663c-88fa-4ddc-aa3a-96fc86023e8e	new	new	\\x24326224313224514f4163443541557174424d547a4a6c77444d62412e	$2b$12$QOAcD5AUqtBMTzJlwDMbA.zSUPmnhD6n2BqZqAzh.B8P5I6CfIZPi	2025-07-13 14:22:15.448298+00
5c70ff59-026a-4367-9851-3c56808d6b76	new_acc	new_acc	\\x24326224313224765650367667737a662e3947336e727a445a57564f2e	$2b$12$vVP6vgszf.9G3nrzDZWVO.2MivAsRNbJSBMh0Und3UKL13Lvui6Zm	2025-07-13 14:23:00.272111+00
a66aa89c-84c1-40d6-a865-6db56f4519e9	Brilynd	madeyabrilynd@gmail.com	\\x2432622431322463386753516a572f2f335a4c724d622f33347034304f	$2b$12$c8gSQjW//3ZLrMb/34p40Or1/a/1E8oT7/6yE3YaTRMm4cF8W70lS	2025-07-13 14:55:17.34044+00
\.


--
-- Data for Name: a2acards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.a2acards (id, name, alias, description, server_url, card_content, is_active, created_at, updated_at, creator_id) FROM stdin;
\.


--
-- Data for Name: agent_project_associations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.agent_project_associations (id, agent_id, project_id) FROM stdin;
\.


--
-- Data for Name: agentflow_project_associations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.agentflow_project_associations (id, flow_id, project_id) FROM stdin;
\.


--
-- Data for Name: agents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.agents (id, alias, name, description, jwt, creator_id, input_parameters, created_at, updated_at, last_invoked_at, is_active) FROM stdin;
\.


--
-- Data for Name: agentworkflows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.agentworkflows (id, alias, name, description, flow, creator_id, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
bdf04422c056
\.


--
-- Data for Name: chatconversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chatconversations (session_id, title, created_at, updated_at, creator_id) FROM stdin;
\.


--
-- Data for Name: chatmessages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chatmessages (id, request_id, sender_type, content, extra_metadata, created_at, updated_at, conversation_id) FROM stdin;
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.files (id, session_id, request_id, creator_id, mimetype, original_name, internal_name, internal_id, from_agent) FROM stdin;
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (id, session_id, request_id, agent_id, creator_id, created_at, updated_at, message, log_level) FROM stdin;
1	dc6c40d3-fb6c-49b1-8253-e69a4322b65d	39026a84-a810-4376-afcf-49d201d0c785	master_server_ml	\N	2025-07-13 03:18:04.191032	2025-07-13 03:18:04.191032	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "dc6c40d3-fb6c-49b1-8253-e69a4322b65d", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [], "timestamp": 1752376684}}	info
2	dc6c40d3-fb6c-49b1-8253-e69a4322b65d	39026a84-a810-4376-afcf-49d201d0c785	master_server_ml	\N	2025-07-13 03:18:05.732423	2025-07-13 03:18:05.732423	{"execution_time": 1.5793199549998462, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "hello", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "02ca2c8b-1111-4197-8d2b-8a43a2145cce", "example": false}, "execution_time": 1.4223016429996278, "output": {"content": "Hello! How can I assist you today?", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 10, "prompt_tokens": 919, "total_tokens": 929, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-BshW0kidbbMtCKA0pmiAgzztD2GjY", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-eca1f5e4-b039-4574-941f-95fa927d9b6f-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 919, "output_tokens": 10, "total_tokens": 929, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "Hello! How can I assist you today?", "is_success": true}}	info
3	3751285e-11af-470e-8370-62b1861fd8bb	dd001186-bb99-44d7-ac80-6204819eefc2	master_server_ml	\N	2025-07-13 03:18:27.624703	2025-07-13 03:18:27.624703	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [], "timestamp": 1752376707}}	info
4	3751285e-11af-470e-8370-62b1861fd8bb	dd001186-bb99-44d7-ac80-6204819eefc2	master_server_ml	\N	2025-07-13 03:18:28.719603	2025-07-13 03:18:28.719603	{"execution_time": 1.109122355999716, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "What model are you?", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "8502cbe2-dfdb-4164-bdeb-fe362873fd21", "example": false}, "execution_time": 0.9660621900002297, "output": {"content": "I am an AI language model created by OpenAI, based on the GPT-4 architecture. How can I assist you today?", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 27, "prompt_tokens": 923, "total_tokens": 950, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-BshWOpJPXoTbgN7hiSgFKU9wd3jA2", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-a3cb5a17-e42d-4737-968c-76335bf61037-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 923, "output_tokens": 27, "total_tokens": 950, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "I am an AI language model created by OpenAI, based on the GPT-4 architecture. How can I assist you today?", "is_success": true}}	info
5	3751285e-11af-470e-8370-62b1861fd8bb	5201b8f9-a3b7-4fd6-b56f-f733c4cf3e3a	master_server_ml	\N	2025-07-13 03:21:01.350642	2025-07-13 03:21:01.350642	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [], "timestamp": 1752376861}}	info
6	3751285e-11af-470e-8370-62b1861fd8bb	5201b8f9-a3b7-4fd6-b56f-f733c4cf3e3a	master_server_ml	\N	2025-07-13 03:21:02.634303	2025-07-13 03:21:02.634303	{"execution_time": 1.305245603000003, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "What model are you", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "bdbac42d-afc9-4d4d-8886-10a5df5ae6ae", "example": false}, "execution_time": 1.1589345149996007, "output": {"content": "I am an AI language model created by OpenAI, based on the GPT-4 architecture. How can I assist you today?", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 27, "prompt_tokens": 1386, "total_tokens": 1413, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-BshYslRsN9NnmAI9jvJ6lORDPVMgu", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-dfa8db22-f9c6-44ec-a27d-0b415f0d74ac-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 1386, "output_tokens": 27, "total_tokens": 1413, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "I am an AI language model created by OpenAI, based on the GPT-4 architecture. How can I assist you today?", "is_success": true}}	info
7	3751285e-11af-470e-8370-62b1861fd8bb	5070abec-6dce-4731-967c-369cb59722ac	master_server_ml	\N	2025-07-13 03:21:15.626453	2025-07-13 03:21:15.626453	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [], "timestamp": 1752376875}}	info
8	3751285e-11af-470e-8370-62b1861fd8bb	5070abec-6dce-4731-967c-369cb59722ac	master_server_ml	\N	2025-07-13 03:21:17.255891	2025-07-13 03:21:17.255891	{"execution_time": 1.6551141039999493, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "What day is today", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "296af2b0-7a16-4d79-90bf-b974f863e088", "example": false}, "execution_time": 1.5132986389999132, "output": {"content": "I'm unable to determine the current date as I don't have real-time capabilities. You can check the date on your device or calendar. Is there anything else I can assist you with?", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 37, "prompt_tokens": 1861, "total_tokens": 1898, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 1280}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-BshZ61lnpJUtxVhj4tAtIxZYHf5WJ", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-5656bea4-7ba3-4367-8019-40efa2314609-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 1861, "output_tokens": 37, "total_tokens": 1898, "input_token_details": {"audio": 0, "cache_read": 1280}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "I'm unable to determine the current date as I don't have real-time capabilities. You can check the date on your device or calendar. Is there anything else I can assist you with?", "is_success": true}}	info
9	3751285e-11af-470e-8370-62b1861fd8bb	fd8b36fc-4570-4136-9084-1d4b0a24d1ad	master_server_ml	\N	2025-07-13 03:21:31.235843	2025-07-13 03:21:31.235843	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [], "timestamp": 1752376891}}	info
10	3751285e-11af-470e-8370-62b1861fd8bb	fd8b36fc-4570-4136-9084-1d4b0a24d1ad	master_server_ml	\N	2025-07-13 03:21:32.548291	2025-07-13 03:21:32.548291	{"execution_time": 1.3383879479997631, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "What is the weater", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "84e7f33f-e62d-4c81-89b3-1219c3966d75", "example": false}, "execution_time": 1.1912766440000269, "output": {"content": "I'm unable to provide real-time weather information. However, you can check the current weather using a weather app or website like Weather.com or your local news station. Is there anything else I can help you with?", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 43, "prompt_tokens": 1889, "total_tokens": 1932, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-BshZLrNhEsIS0s5UCAiE0n4mMgbkn", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-ccd4bf53-ee5b-490f-b1dc-e104caba1b09-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 1889, "output_tokens": 43, "total_tokens": 1932, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "I'm unable to provide real-time weather information. However, you can check the current weather using a weather app or website like Weather.com or your local news station. Is there anything else I can help you with?", "is_success": true}}	info
11	3751285e-11af-470e-8370-62b1861fd8bb	bc027af6-442c-43ac-924d-f597bb01d4c5	master_server_ml	\N	2025-07-13 03:33:20.728672	2025-07-13 03:33:20.728672	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [{"id": "18247685-f1e3-4d9f-ac6f-2c4e82837047", "session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "request_id": "bc027af6-442c-43ac-924d-f597bb01d4c5", "original_name": "2024 Benefits at a Glance.pdf", "mimetype": "application/pdf", "internal_id": "18247685-f1e3-4d9f-ac6f-2c4e82837047", "internal_name": "18247685-f1e3-4d9f-ac6f-2c4e82837047.pdf", "from_agent": false, "creator_id": "371d2970-a659-4f89-9867-19c8e705cb5f"}], "timestamp": 1752377600}}	info
12	3751285e-11af-470e-8370-62b1861fd8bb	bc027af6-442c-43ac-924d-f597bb01d4c5	master_server_ml	\N	2025-07-13 03:33:22.861795	2025-07-13 03:33:22.861795	{"execution_time": 2.1593225520000487, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "content='Can you create a json response for each unique benefit a end user should be aware of and be sure to give it a title and caption. Ensure the info is extracted from the PDF.' additional_kwargs={} response_metadata={}\\n\\nFILES:\\n[{\\"id\\": \\"18247685-f1e3-4d9f-ac6f-2c4e82837047\\", \\"session_id\\": \\"3751285e-11af-470e-8370-62b1861fd8bb\\", \\"request_id\\": \\"bc027af6-442c-43ac-924d-f597bb01d4c5\\", \\"original_name\\": \\"2024 Benefits at a Glance.pdf\\", \\"mimetype\\": \\"application/pdf\\", \\"internal_id\\": \\"18247685-f1e3-4d9f-ac6f-2c4e82837047\\", \\"internal_name\\": \\"18247685-f1e3-4d9f-ac6f-2c4e82837047.pdf\\", \\"from_agent\\": false, \\"creator_id\\": \\"371d2970-a659-4f89-9867-19c8e705cb5f\\"}]", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "a61b2b1d-aa68-4e76-8098-8e3dbe98a800", "example": false}, "execution_time": 2.013163882000299, "output": {"content": "I'm unable to directly extract content from files or PDFs. However, you can open the PDF titled \\"2024 Benefits at a Glance\\" and identify the unique benefits listed there. Once you have that information, I'd be glad to help you format it into a JSON response with titles and captions.", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 60, "prompt_tokens": 2164, "total_tokens": 2224, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-Bshknu8CnTNhIPljtzZajdaZxJPrG", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-124189a1-dd12-47b5-b861-fadb5c8d413c-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 2164, "output_tokens": 60, "total_tokens": 2224, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "I'm unable to directly extract content from files or PDFs. However, you can open the PDF titled \\"2024 Benefits at a Glance\\" and identify the unique benefits listed there. Once you have that information, I'd be glad to help you format it into a JSON response with titles and captions.", "is_success": true}}	info
13	3751285e-11af-470e-8370-62b1861fd8bb	9d676616-b474-4511-8e45-364662642f4c	master_server_ml	\N	2025-07-13 03:34:09.444151	2025-07-13 03:34:09.444151	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [], "timestamp": 1752377649}}	info
14	3751285e-11af-470e-8370-62b1861fd8bb	9d676616-b474-4511-8e45-364662642f4c	master_server_ml	\N	2025-07-13 03:34:11.769675	2025-07-13 03:34:11.769675	{"execution_time": 2.350452927000333, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "Are you able to extract data from files I provide to you?", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "7ff8e74e-ce56-45d9-98b0-65beffa4e949", "example": false}, "execution_time": 2.2109847949996038, "output": {"content": "No, I'm unable to extract data directly from files you provide. However, I can guide you on how to find specific information within your files or help you format the data once you've extracted it yourself. If you need assistance with a specific file, please let me know how I can help!", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 59, "prompt_tokens": 2255, "total_tokens": 2314, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-BshlZ62KwnXBxJCYpHED8xf7aCCtl", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-42299cbe-0cfe-4f09-88a8-0a7e63f8a23a-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 2255, "output_tokens": 59, "total_tokens": 2314, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "No, I'm unable to extract data directly from files you provide. However, I can guide you on how to find specific information within your files or help you format the data once you've extracted it yourself. If you need assistance with a specific file, please let me know how I can help!", "is_success": true}}	info
15	3751285e-11af-470e-8370-62b1861fd8bb	d6f596ab-2119-4651-971a-9e7f399cfde8	master_server_ml	\N	2025-07-13 03:41:44.943535	2025-07-13 03:41:44.943535	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [{"id": "1c55116b-abf0-42ce-b55e-12788fb2f59b", "session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "request_id": "d6f596ab-2119-4651-971a-9e7f399cfde8", "original_name": "test.txt", "mimetype": "text/plain", "internal_id": "1c55116b-abf0-42ce-b55e-12788fb2f59b", "internal_name": "1c55116b-abf0-42ce-b55e-12788fb2f59b.txt", "from_agent": false, "creator_id": "371d2970-a659-4f89-9867-19c8e705cb5f"}], "timestamp": 1752378104}}	info
16	3751285e-11af-470e-8370-62b1861fd8bb	d6f596ab-2119-4651-971a-9e7f399cfde8	master_server_ml	\N	2025-07-13 03:41:46.804683	2025-07-13 03:41:46.804683	{"execution_time": 1.8744723879999583, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "content='Could you briefly summarize the text document I provided' additional_kwargs={} response_metadata={}\\n\\nFILES:\\n[{\\"id\\": \\"1c55116b-abf0-42ce-b55e-12788fb2f59b\\", \\"session_id\\": \\"3751285e-11af-470e-8370-62b1861fd8bb\\", \\"request_id\\": \\"d6f596ab-2119-4651-971a-9e7f399cfde8\\", \\"original_name\\": \\"test.txt\\", \\"mimetype\\": \\"text/plain\\", \\"internal_id\\": \\"1c55116b-abf0-42ce-b55e-12788fb2f59b\\", \\"internal_name\\": \\"1c55116b-abf0-42ce-b55e-12788fb2f59b.txt\\", \\"from_agent\\": false, \\"creator_id\\": \\"371d2970-a659-4f89-9867-19c8e705cb5f\\"}]", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "4bd9621c-2244-429a-ba1a-6d5725bd624a", "example": false}, "execution_time": 1.7295129629992516, "output": {"content": "I'm unable to directly summarize the content of files you provide. However, if you can share the main points or text from the document, I can help you summarize it or offer insights based on that information. Let me know how you'd like to proceed!", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 51, "prompt_tokens": 2505, "total_tokens": 2556, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-BshsvcZURlGRiRK3IFc2Yz7zr6rIX", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-2d2ed7d3-76f4-425b-9582-7d7b925c8765-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 2505, "output_tokens": 51, "total_tokens": 2556, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "I'm unable to directly summarize the content of files you provide. However, if you can share the main points or text from the document, I can help you summarize it or offer insights based on that information. Let me know how you'd like to proceed!", "is_success": true}}	info
17	3751285e-11af-470e-8370-62b1861fd8bb	15c00743-4137-4130-88d7-9eed7dff8395	master_server_ml	\N	2025-07-13 03:42:00.690584	2025-07-13 03:42:00.690584	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [], "timestamp": 1752378120}}	info
18	3751285e-11af-470e-8370-62b1861fd8bb	15c00743-4137-4130-88d7-9eed7dff8395	master_server_ml	\N	2025-07-13 03:42:06.949648	2025-07-13 03:42:06.949648	{"execution_time": 6.2844396310001684, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "Could you briefly summarize the following:\\n\\nPaid time off and inclusive, \\nflexible holidays \\nWe want and expect you to take time off to relax, recharge, and take care of personal and family matters. Guardian's time off \\nprograms are designed to provide flexibility and inclusivity so colleagues can take the time away from work that they need. \\nAll exempt colleagues (colleagues who are ineligible for overtime) participate in MyTime, which allows you to take time off \\nwithout the restrictions of annual paid time off (PTO) allotments, accruals, or tracking. Non-exempt colleagues are \\nimmediately eligible for PTO upon joining the Company. The amount of PTO you are entitled to is based on your length of \\nservice.  \\nAt Guardian, we celebrate our diverse workforce and want you to be able to recognize the religious, cultural, civic, or \\npersonal days that are most important to you, so you\\u2019ll receive Company holidays off. \\nWe recognize that as it is important that you have the support, flexibility, and resources to focus on what matters most, so \\nyou can do your best. Upon the arrival of your new child (through birth, adoption, or placement for foster care) you are \\neligible for paid parental leave if you are the primary or secondary caregiver, allowing you more time to spend with your \\nfamily. \\nGuardian understands that colleagues who take FMLA leaves are dealing with difficult personal and family situations. To \\nsupport you during this time of need, Guardian provides you with up to 10 business days of paid family and medical leave for \\nFMLA eligible absences. \\nFlexible, hybrid work \\narrangements  \\nGuardian provides flexible contemporary work arrangements that balance purposeful in-office and remote work. \\nBright Horizons child and adult \\nback-up care, pet care, virtual \\ntutoring and test prep, and \\ncollege coaching \\nGuardian focuses on providing benefits that assist you in balancing the competing demands of work and home life. The \\nBright Horizons child and adult back-up care program can help you and your loved ones throughout all stages of life: from \\nday care for an infant to caring for an aging or disabled family member. You will receive access to affordable, high-quality, \\nconvenient care when you have a lapse or breakdown in a normal care arrangement. Through this program, you\\u2019ll also \\nreceive a benefit to help you take care of your furry family members, and will have access to virtual tutoring and test prep. \\nIf you are getting a child ready to go to college, the admissions process can be stressful and time-consuming. With the \\nBright Horizons College Coach program, you\\u2019ll receive personalized assistance from former college admissions and financial \\naid officers, who will help guide you and your student through the college application and admissions process. They provide \\none-on-one support, college essay review and more. \\nVirtual meditation classes \\nGuardian offers virtual guided meditation through the partnership with our onsite fitness center (The CLUB at Bethlehem), \\nso you can clear and refresh your mind.  \\nBody: Benefits for your physical well-being \\nMedical   \\nWe have partnered with both Cigna and Centivo to offer colleagues a choice in their medical plan offerings. All colleagues can \\nchoose from three medical plan options: (1) the Cigna High Deductible Plan (2) the Cigna High Deductible Plus Plan and (3) \\neither the Centivo Copay Plan or Cigna Copay Plan (availability of the Copay Plan is based on your home zip code). All three \\nplans provide comprehensive coverage, covering free in-network preventive care and outpatient behavioral health care \\n(subject to the deductible), and other services like hospital stays, urgent and emergency care. To protect you from \\ncatastrophic expenses, these plans all have an annual out-of-pocket maximum, which is the most you will pay out-of-pocket \\nfor care during the year. \\nThe Cigna high deductible plans provide in- and out-of-network coverage and requires that a deductible be met for all other \\nservices. The Cigna Copay plan offers in-network coverage only (except for emergency care), a small deductible, and \\npredictable costs for office visits. And, under the Cigna High Deductible Plus and Copay Plans, you will receive an enhanced \\nbenefit when you receive care from Tier 1 providers, who meet specific guidelines for quality and cost-effective care.  \\nThe Centivo Copay Plan provides in-network coverage only (except for emergency care), free care from your primary care \\ndoctor for both preventive and sick visits, no deductible, and fixed costs for specialists and other medical care. This is a \\nunique medical plan option that is centered around your relationship with your primary care doctor, who helps you to save \\ntime and money, by guiding your health care journey. \\nThe plans generally cover the same treatments and services; however, the difference between the Cigna high deductible \\nplans, Cigna Copay Plan, and Centivo Copay Plan are the contributions you will pay, and your out-of-pocket expenses.  \\nPrescription Drugs   \\nWhen you enroll in a Guardian medical plan, you will automatically be enrolled in prescription drug coverage through CVS \\nCaremark. CVS Caremark provides coverage for generic and brand name medications filled at an in-network retail pharmacy, \\nand the CVS Caremark specialty and mail order pharmacies.  \\nIf you are enrolling in either of the Cigna high deductible plans, once you meet the combined medical-prescription drug \\ndeductible, you will pay the applicable copayment/coinsurance amount for non-preventive medications. Guardian also \\nprovides enhanced coverage for certain medications used to prevent the onset of a disease or serious medical condition. If \\nyou are taking one of these medications, you will not need to meet the deductible and will only pay the applicable copayment \\nor coinsurance amount. \\nIf you are enrolling in either the Cigna or Centivo Copay Plan, you do not need to meet a deductible. You will immediately \\nbegin paying the copay amount for all medications.  \\n2nd.MD Second Opinion \\nSupport \\nGuardian partners with 2nd.MD to offer medical plan members access to a second opinion service. When you are faced with a \\ncritical health care decision and are unsure what treatment option is best, 2nd.MD connects you with board-certified experts \\nfor a second opinion, via phone or video 24/7, at no cost to you or your family. \\nDental   \\nThe Guardian PPO dental plan provides you and your loved ones with coverage for preventive, basic, major restorative, and \\northodontia services, both in- and out-of-network, up to the annual plan limits. The deductible is waived for all in-network \\npreventive care. Plus, to ensure that we are helping our youngest family members take care of their smiles, the plan offers the \\nEarly Smiles Program, which provides 100% in-network coverage for preventive, basic and major services for children under \\nage 13, with no deductible. In addition to in-person visits, all members also have access to urgent dental care through \\nGuardian\\u2019s partnership with Teledentistry.com.  \\nAs an added feature under the Guardian plan, you and your covered dependents have access to roll over a portion of your \\nunused annual dental maximum into a personal Maximum Rollover Account (MRA), which can be used in future years, should \\nyou reach the annual ", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "10fa0836-4e68-4894-9218-b798c8f79618", "example": false}, "execution_time": 6.140786390999892, "output": {"content": "The provided text outlines Guardian's comprehensive benefits program, which emphasizes flexibility, inclusivity, and support for employees' personal and professional lives. Key points include:\\n\\n1. **Paid Time Off and Holidays**: Guardian offers flexible and inclusive time-off programs, allowing exempt employees to take time off without PTO restrictions, while non-exempt employees are eligible for PTO based on their service length. The company supports recognizing important cultural and personal days and provides paid parental leave and family medical leave.\\n\\n2. **Flexible Work Arrangements**: Employees have access to hybrid work models that balance in-office and remote work.\\n\\n3. **Support Services**: Guardian offers benefits such as backup care for children and adults, pet care, virtual tutoring, and college coaching through Bright Horizons.\\n\\n4. **Meditation and Wellness**: Virtual meditation classes are available to support mental well-being.\\n\\n5. **Medical Benefits**: Employees can choose from several medical plans with comprehensive coverage, including preventive care, and have access to prescription drug coverage through CVS Caremark. The 2nd.MD service offers second medical opinions.\\n\\n6. **Dental Benefits**: The Guardian PPO dental plan provides extensive coverage, including preventive and orthodontic services, with unique features like the Early Smiles Program for children and a Maximum Rollover Account.\\n\\nOverall, the benefits are designed to support employees' health, well-being, and life balance.", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 279, "prompt_tokens": 3726, "total_tokens": 4005, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-BshtBZNmXKVoqydJmki3gZ6H4R5AW", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-acd1ab4e-4236-4323-bf19-548db2187c82-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 3726, "output_tokens": 279, "total_tokens": 4005, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "The provided text outlines Guardian's comprehensive benefits program, which emphasizes flexibility, inclusivity, and support for employees' personal and professional lives. Key points include:\\n\\n1. **Paid Time Off and Holidays**: Guardian offers flexible and inclusive time-off programs, allowing exempt employees to take time off without PTO restrictions, while non-exempt employees are eligible for PTO based on their service length. The company supports recognizing important cultural and personal days and provides paid parental leave and family medical leave.\\n\\n2. **Flexible Work Arrangements**: Employees have access to hybrid work models that balance in-office and remote work.\\n\\n3. **Support Services**: Guardian offers benefits such as backup care for children and adults, pet care, virtual tutoring, and college coaching through Bright Horizons.\\n\\n4. **Meditation and Wellness**: Virtual meditation classes are available to support mental well-being.\\n\\n5. **Medical Benefits**: Employees can choose from several medical plans with comprehensive coverage, including preventive care, and have access to prescription drug coverage through CVS Caremark. The 2nd.MD service offers second medical opinions.\\n\\n6. **Dental Benefits**: The Guardian PPO dental plan provides extensive coverage, including preventive and orthodontic services, with unique features like the Early Smiles Program for children and a Maximum Rollover Account.\\n\\nOverall, the benefits are designed to support employees' health, well-being, and life balance.", "is_success": true}}	info
19	3751285e-11af-470e-8370-62b1861fd8bb	6ac26184-9af5-44bc-a335-fc2b3717b4c5	master_server_ml	\N	2025-07-13 03:47:24.329763	2025-07-13 03:47:24.329763	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [], "timestamp": 1752378444}}	info
20	3751285e-11af-470e-8370-62b1861fd8bb	6ac26184-9af5-44bc-a335-fc2b3717b4c5	master_server_ml	\N	2025-07-13 03:47:25.699208	2025-07-13 03:47:25.699208	{"execution_time": 1.4078259489997436, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "test", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "d73c8be5-ef2e-4982-b493-2fd028c921a8", "example": false}, "execution_time": 1.2477627429998392, "output": {"content": "Hello! How can I assist you today?", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 10, "prompt_tokens": 5769, "total_tokens": 5779, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-BshyPBNDr5tqPCDWn1C6rWP7vT3SO", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-481fa4a5-a3d0-4439-8c2a-4b9f60e69681-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 5769, "output_tokens": 10, "total_tokens": 5779, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "Hello! How can I assist you today?", "is_success": true}}	info
21	3751285e-11af-470e-8370-62b1861fd8bb	ac0c34b1-d916-4bdc-9026-2e3e52c51c98	master_server_ml	\N	2025-07-13 03:48:01.566704	2025-07-13 03:48:01.566704	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [{"id": "5e1c848c-cf64-4ee2-85ce-6b09d889269d", "session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "request_id": "ac0c34b1-d916-4bdc-9026-2e3e52c51c98", "original_name": "test.txt", "mimetype": "text/plain", "internal_id": "5e1c848c-cf64-4ee2-85ce-6b09d889269d", "internal_name": "5e1c848c-cf64-4ee2-85ce-6b09d889269d.txt", "from_agent": false, "creator_id": "371d2970-a659-4f89-9867-19c8e705cb5f"}], "timestamp": 1752378481}}	info
22	3751285e-11af-470e-8370-62b1861fd8bb	ac0c34b1-d916-4bdc-9026-2e3e52c51c98	master_server_ml	\N	2025-07-13 03:48:03.407945	2025-07-13 03:48:03.407945	{"execution_time": 1.8712217749998672, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "content='Read' additional_kwargs={} response_metadata={}\\n\\nFILES:\\n[{\\"id\\": \\"5e1c848c-cf64-4ee2-85ce-6b09d889269d\\", \\"session_id\\": \\"3751285e-11af-470e-8370-62b1861fd8bb\\", \\"request_id\\": \\"ac0c34b1-d916-4bdc-9026-2e3e52c51c98\\", \\"original_name\\": \\"test.txt\\", \\"mimetype\\": \\"text/plain\\", \\"internal_id\\": \\"5e1c848c-cf64-4ee2-85ce-6b09d889269d\\", \\"internal_name\\": \\"5e1c848c-cf64-4ee2-85ce-6b09d889269d.txt\\", \\"from_agent\\": false, \\"creator_id\\": \\"371d2970-a659-4f89-9867-19c8e705cb5f\\"}]", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "e273c4be-d97d-4341-91b5-b46d153daeaa", "example": false}, "execution_time": 1.7214708910005356, "output": {"content": "It seems you have uploaded a file named `test.txt`. How can I assist you with this file? Would you like me to read its contents or perform any specific operation?", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 36, "prompt_tokens": 5679, "total_tokens": 5715, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-Bshz0JImbfkl7y6kKvw8J3ZmHDW54", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-0a3c857a-e5dd-4fcf-bbe0-cb460f91e3ea-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 5679, "output_tokens": 36, "total_tokens": 5715, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "It seems you have uploaded a file named `test.txt`. How can I assist you with this file? Would you like me to read its contents or perform any specific operation?", "is_success": true}}	info
52	3751285e-11af-470e-8370-62b1861fd8bb	cb2876a3-196d-41ed-a8d1-b4992706a324	master_server_ml	\N	2025-07-13 03:48:42.627535	2025-07-13 03:48:42.627535	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [], "timestamp": 1752378522}}	info
53	3751285e-11af-470e-8370-62b1861fd8bb	cb2876a3-196d-41ed-a8d1-b4992706a324	master_server_ml	\N	2025-07-13 03:48:43.871135	2025-07-13 03:48:43.871135	{"execution_time": 1.2996194030001789, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "Read the file", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "02ee9285-88e0-40f4-94bf-df41f4182924", "example": false}, "execution_time": 1.1126827000007324, "output": {"content": "I currently don't have the ability to read files directly. Please let me know if there's anything else I can assist you with!", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 26, "prompt_tokens": 2059, "total_tokens": 2085, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-BshzfhbNFWRmJi7iC2TilMQGe1xT2", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-67bf4c2e-20b5-48c8-b3f3-7e139fd2d8c6-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 2059, "output_tokens": 26, "total_tokens": 2085, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "I currently don't have the ability to read files directly. Please let me know if there's anything else I can assist you with!", "is_success": true}}	info
85	3751285e-11af-470e-8370-62b1861fd8bb	9ed49c29-1fc0-4424-927b-847d8cfaaa80	master_server_ml	\N	2025-07-13 03:49:05.29127	2025-07-13 03:49:05.29127	{"invoked_by": "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be:master_server_ml", "request_payload": {"session_id": "3751285e-11af-470e-8370-62b1861fd8bb", "user_id": "371d2970-a659-4f89-9867-19c8e705cb5f", "configs": {"provider": "genai", "model": "gpt-4o", "temperature": 0.7, "system_prompt": "You are a helpful AI assistant, please respond to the user's query to the best of your ability.\\nYou have access to different tools that can help you to solve the problem and answer the user's query.\\n\\n## Instructions and rules\\n\\n### Receive and Understand the Task\\n- Carefully read and understand the received question or task.\\n- Ensure you comprehend the final goal and the logical steps needed to reach it.\\n- If the task is complex, keep in mind that you may need to break it down into smaller substeps.\\n\\n### Analyze the Available Tools\\n- Carefully review all available tools.\\n- Classify each tool as either:\\n  - Atomic tool: A tool that performs exactly one specific operation.\\n  - Composite tool: A tool that performs multiple operations sequentially.\\n\\n### Break Down the Task into Substeps\\n- Decompose the task into clear, logical substeps.\\n- IMPORTANT: While breaking down, keep in mind the available tools.\\n- Ensure that each substep is atomic and clearly defines a single operation.\\n\\n### Choose Tools Carefully for Each Substep\\n#### Step 1: Always Prefer Composite Tools First\\n- Look for a composite tool that can perform the current first substep (and possibly some next ones).\\n- RULE:\\n  - The composite tool must be able to perform the first substep.\\n  - It is acceptable (and encouraged) if the tool solves the first and additional following substeps.\\n  - It is not acceptable to choose a composite tool that only solves later substeps but not the current one.\\n  - It is not acceptable to introduce unnecessary complexity and choose a composite tool that does more than user asked.\\n\\n#### Step 2: If No Suitable Composite Tool\\nIf no composite tool can solve the current substep:\\n - Look for an atomic tool that can solve it.\\n\\n#### Step 3: If No Tool Matches\\n- If no tool (neither composite nor atomic) can solve the current substep, do nothing.\\n- Do not attempt to \\"force\\" any tool.\\n\\n### Repeat the Process\\n- After completing the current substep:\\n  - Update the remaining task.\\n  - Identify the next immediate substep.\\n  - Go back to Step 4: choose the next tool (composite tools first, atomic tools if necessary).\\n- Continue this loop until:\\n  - The task is fully completed.\\n  - Or no available tool can solve the next substep.\\n\\n### Important Constraints\\n- DO NOT choose a tool that cannot solve the current substep.\\n- DO NOT skip necessary early steps to jump to later steps using a composite tool.\\n- DO NOT use composite tools that do more than asked by user. There is no need to introduce unnecessary complexity.\\n- DO NOT guess, improvise, or attempt a substep manually without a suitable tool.\\n- DO NOT partially use a composite tool \\u2014 you must use it fully if chosen.\\n\\n### Final Response Format\\n- Final response is your response to user when you don't select any tools\\n- Always generate a final response on the same language as initial user query unless the user asks you to respond \\non another language.\\n", "user_prompt": null, "config_name": "default", "max_last_messages": 5, "base_url": "https://proxy-openai.chi-6ec.workers.dev", "api_key": null}, "files": [], "timestamp": 1752378545}}	info
86	3751285e-11af-470e-8370-62b1861fd8bb	9ed49c29-1fc0-4424-927b-847d8cfaaa80	master_server_ml	\N	2025-07-13 03:49:07.418243	2025-07-13 03:49:07.418243	{"execution_time": 2.1770494129996223, "response": {"agents_trace": [{"name": "MasterAgent", "input": {"content": "Try really hard I believe in you", "additional_kwargs": {}, "response_metadata": {}, "type": "human", "name": null, "id": "02a43e4c-7749-43fb-805c-1d309589ed27", "example": false}, "execution_time": 1.9820406930002719, "output": {"content": "I appreciate your confidence! Unfortunately, I still don't have the capability to directly read files. However, if you can provide me with the text or content from the file, I'll be happy to help with any questions or tasks related to it. Let me know how else I can assist you!", "additional_kwargs": {"refusal": null}, "response_metadata": {"token_usage": {"completion_tokens": 59, "prompt_tokens": 2098, "total_tokens": 2157, "completion_tokens_details": {"accepted_prediction_tokens": 0, "audio_tokens": 0, "reasoning_tokens": 0, "rejected_prediction_tokens": 0}, "prompt_tokens_details": {"audio_tokens": 0, "cached_tokens": 0}}, "model_name": "gpt-4o-2024-08-06", "system_fingerprint": "fp_07871e2ad8", "id": "chatcmpl-Bsi010NIcg6AOxqcqfGDICa50zmi9", "finish_reason": "stop", "logprobs": null}, "type": "ai", "name": null, "id": "run-adc55b6d-f1c3-4e1b-be87-215d5a5b460e-0", "example": false, "tool_calls": [], "invalid_tool_calls": [], "usage_metadata": {"input_tokens": 2098, "output_tokens": 59, "total_tokens": 2157, "input_token_details": {"audio": 0, "cache_read": 0}, "output_token_details": {"audio": 0, "reasoning": 0}}}, "is_success": true}], "response": "I appreciate your confidence! Unfortunately, I still don't have the capability to directly read files. However, if you can provide me with the text or content from the file, I'll be happy to help with any questions or tasks related to it. Let me know how else I can assist you!", "is_success": true}}	info
\.


--
-- Data for Name: mcpservers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mcpservers (id, name, description, server_url, created_at, updated_at, creator_id, is_active) FROM stdin;
\.


--
-- Data for Name: mcptools; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mcptools (id, name, description, "inputSchema", annotations, alias, mcp_server_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: modelconfigs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modelconfigs (id, name, model, provider_id, system_prompt, user_prompt, max_last_messages, temperature, credentials, creator_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: modelproviders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modelproviders (id, name, api_key, provider_metadata, creator_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, name) FROM stdin;
3c8092b3-90be-4cd0-a3ca-adc981d3001a	Default
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teams (id, name) FROM stdin;
\.


--
-- Data for Name: user_project_associations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_project_associations (id, user_id, project_id) FROM stdin;
\.


--
-- Data for Name: user_team_associations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_team_associations (id, user_id, team_id) FROM stdin;
\.


--
-- Data for Name: userprofiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.userprofiles (id, first_name, last_name, user_id) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, created_at, updated_at) FROM stdin;
371d2970-a659-4f89-9867-19c8e705cb5f	Jake	$2b$12$vkk5HiQlNzGBewxnUkjZL.fato7lPDNHvF2CdZfn56Hea3xrJzGpu	2025-07-12 16:16:37.039482	2025-07-12 16:16:37.039482
\.


--
-- Name: jobid_seq; Type: SEQUENCE SET; Schema: cron; Owner: postgres
--

SELECT pg_catalog.setval('cron.jobid_seq', 1, false);


--
-- Name: runid_seq; Type: SEQUENCE SET; Schema: cron; Owner: postgres
--

SELECT pg_catalog.setval('cron.runid_seq', 1, false);


--
-- Name: agent_project_associations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agent_project_associations_id_seq', 1, false);


--
-- Name: agentflow_project_associations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agentflow_project_associations_id_seq', 1, false);


--
-- Name: logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.logs_id_seq', 117, true);


--
-- Name: user_project_associations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_project_associations_id_seq', 33, true);


--
-- Name: user_team_associations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_team_associations_id_seq', 1, false);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: navicare; Owner: postgres
--

ALTER TABLE ONLY navicare.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (conversation_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: navicare; Owner: postgres
--

ALTER TABLE ONLY navicare.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (message_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: navicare; Owner: postgres
--

ALTER TABLE ONLY navicare.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (uuid);


--
-- Name: a2acards a2acards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.a2acards
    ADD CONSTRAINT a2acards_pkey PRIMARY KEY (id);


--
-- Name: agent_project_associations agent_project_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_project_associations
    ADD CONSTRAINT agent_project_associations_pkey PRIMARY KEY (id);


--
-- Name: agentflow_project_associations agentflow_project_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentflow_project_associations
    ADD CONSTRAINT agentflow_project_associations_pkey PRIMARY KEY (id);


--
-- Name: agents agents_alias_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_alias_key UNIQUE (alias);


--
-- Name: agents agents_jwt_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_jwt_key UNIQUE (jwt);


--
-- Name: agents agents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (id);


--
-- Name: agentworkflows agentworkflows_alias_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentworkflows
    ADD CONSTRAINT agentworkflows_alias_key UNIQUE (alias);


--
-- Name: agentworkflows agentworkflows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentworkflows
    ADD CONSTRAINT agentworkflows_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: chatconversations chatconversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatconversations
    ADD CONSTRAINT chatconversations_pkey PRIMARY KEY (session_id);


--
-- Name: chatmessages chatmessages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatmessages
    ADD CONSTRAINT chatmessages_pkey PRIMARY KEY (id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: mcpservers mcpservers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mcpservers
    ADD CONSTRAINT mcpservers_pkey PRIMARY KEY (id);


--
-- Name: mcptools mcptools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mcptools
    ADD CONSTRAINT mcptools_pkey PRIMARY KEY (id);


--
-- Name: modelconfigs modelconfigs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelconfigs
    ADD CONSTRAINT modelconfigs_pkey PRIMARY KEY (id);


--
-- Name: modelproviders modelproviders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelproviders
    ADD CONSTRAINT modelproviders_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: teams teams_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_name_key UNIQUE (name);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: a2acards uq_a2a_card_server_url; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.a2acards
    ADD CONSTRAINT uq_a2a_card_server_url UNIQUE (creator_id, server_url);


--
-- Name: mcpservers uq_mcp_server_url; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mcpservers
    ADD CONSTRAINT uq_mcp_server_url UNIQUE (creator_id, server_url);


--
-- Name: modelconfigs uq_user_config_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelconfigs
    ADD CONSTRAINT uq_user_config_name UNIQUE (creator_id, name);


--
-- Name: modelproviders uq_user_provider_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelproviders
    ADD CONSTRAINT uq_user_provider_name UNIQUE (creator_id, name);


--
-- Name: user_project_associations user_project_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_associations
    ADD CONSTRAINT user_project_associations_pkey PRIMARY KEY (id);


--
-- Name: user_team_associations user_team_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_team_associations
    ADD CONSTRAINT user_team_associations_pkey PRIMARY KEY (id);


--
-- Name: userprofiles userprofiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userprofiles
    ADD CONSTRAINT userprofiles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_a2acards_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_a2acards_creator_id ON public.a2acards USING btree (creator_id);


--
-- Name: ix_a2acards_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_a2acards_id ON public.a2acards USING btree (id);


--
-- Name: ix_agent_project_associations_agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agent_project_associations_agent_id ON public.agent_project_associations USING btree (agent_id);


--
-- Name: ix_agent_project_associations_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agent_project_associations_id ON public.agent_project_associations USING btree (id);


--
-- Name: ix_agent_project_associations_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agent_project_associations_project_id ON public.agent_project_associations USING btree (project_id);


--
-- Name: ix_agentflow_project_associations_flow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agentflow_project_associations_flow_id ON public.agentflow_project_associations USING btree (flow_id);


--
-- Name: ix_agentflow_project_associations_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agentflow_project_associations_id ON public.agentflow_project_associations USING btree (id);


--
-- Name: ix_agentflow_project_associations_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agentflow_project_associations_project_id ON public.agentflow_project_associations USING btree (project_id);


--
-- Name: ix_agents_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agents_creator_id ON public.agents USING btree (creator_id);


--
-- Name: ix_agents_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agents_id ON public.agents USING btree (id);


--
-- Name: ix_agentworkflows_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agentworkflows_creator_id ON public.agentworkflows USING btree (creator_id);


--
-- Name: ix_agentworkflows_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agentworkflows_id ON public.agentworkflows USING btree (id);


--
-- Name: ix_chatconversations_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_chatconversations_creator_id ON public.chatconversations USING btree (creator_id);


--
-- Name: ix_chatconversations_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_chatconversations_session_id ON public.chatconversations USING btree (session_id);


--
-- Name: ix_chatmessages_conversation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_chatmessages_conversation_id ON public.chatmessages USING btree (conversation_id);


--
-- Name: ix_chatmessages_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_chatmessages_id ON public.chatmessages USING btree (id);


--
-- Name: ix_files_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_files_creator_id ON public.files USING btree (creator_id);


--
-- Name: ix_files_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_files_id ON public.files USING btree (id);


--
-- Name: ix_files_internal_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_files_internal_id ON public.files USING btree (internal_id);


--
-- Name: ix_files_request_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_files_request_id ON public.files USING btree (request_id);


--
-- Name: ix_files_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_files_session_id ON public.files USING btree (session_id);


--
-- Name: ix_logs_agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_logs_agent_id ON public.logs USING btree (agent_id);


--
-- Name: ix_logs_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_logs_creator_id ON public.logs USING btree (creator_id);


--
-- Name: ix_logs_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_logs_id ON public.logs USING btree (id);


--
-- Name: ix_logs_request_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_logs_request_id ON public.logs USING btree (request_id);


--
-- Name: ix_logs_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_logs_session_id ON public.logs USING btree (session_id);


--
-- Name: ix_mcpservers_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_mcpservers_creator_id ON public.mcpservers USING btree (creator_id);


--
-- Name: ix_mcpservers_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_mcpservers_id ON public.mcpservers USING btree (id);


--
-- Name: ix_mcptools_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_mcptools_id ON public.mcptools USING btree (id);


--
-- Name: ix_mcptools_mcp_server_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_mcptools_mcp_server_id ON public.mcptools USING btree (mcp_server_id);


--
-- Name: ix_modelconfigs_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_modelconfigs_creator_id ON public.modelconfigs USING btree (creator_id);


--
-- Name: ix_modelconfigs_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_modelconfigs_id ON public.modelconfigs USING btree (id);


--
-- Name: ix_modelconfigs_model; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_modelconfigs_model ON public.modelconfigs USING btree (model);


--
-- Name: ix_modelconfigs_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_modelconfigs_provider_id ON public.modelconfigs USING btree (provider_id);


--
-- Name: ix_modelproviders_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_modelproviders_creator_id ON public.modelproviders USING btree (creator_id);


--
-- Name: ix_modelproviders_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_modelproviders_id ON public.modelproviders USING btree (id);


--
-- Name: ix_projects_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_projects_id ON public.projects USING btree (id);


--
-- Name: ix_teams_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_teams_id ON public.teams USING btree (id);


--
-- Name: ix_user_project_associations_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_project_associations_id ON public.user_project_associations USING btree (id);


--
-- Name: ix_user_project_associations_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_project_associations_project_id ON public.user_project_associations USING btree (project_id);


--
-- Name: ix_user_project_associations_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_project_associations_user_id ON public.user_project_associations USING btree (user_id);


--
-- Name: ix_user_team_associations_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_team_associations_id ON public.user_team_associations USING btree (id);


--
-- Name: ix_user_team_associations_team_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_team_associations_team_id ON public.user_team_associations USING btree (team_id);


--
-- Name: ix_user_team_associations_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_team_associations_user_id ON public.user_team_associations USING btree (user_id);


--
-- Name: ix_userprofiles_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_userprofiles_id ON public.userprofiles USING btree (id);


--
-- Name: ix_userprofiles_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_userprofiles_user_id ON public.userprofiles USING btree (user_id);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: conversations conversation.creator_id -> users.uuid; Type: FK CONSTRAINT; Schema: navicare; Owner: postgres
--

ALTER TABLE ONLY navicare.conversations
    ADD CONSTRAINT "conversation.creator_id -> users.uuid" FOREIGN KEY (creator_id) REFERENCES navicare.users(uuid);


--
-- Name: messages messages.conversation_id -> conversations.conversation_id; Type: FK CONSTRAINT; Schema: navicare; Owner: postgres
--

ALTER TABLE ONLY navicare.messages
    ADD CONSTRAINT "messages.conversation_id -> conversations.conversation_id" FOREIGN KEY (conversation_id) REFERENCES navicare.conversations(conversation_id);


--
-- Name: a2acards a2acards_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.a2acards
    ADD CONSTRAINT a2acards_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: agent_project_associations agent_project_associations_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_project_associations
    ADD CONSTRAINT agent_project_associations_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.agents(id) ON DELETE CASCADE;


--
-- Name: agent_project_associations agent_project_associations_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_project_associations
    ADD CONSTRAINT agent_project_associations_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: agentflow_project_associations agentflow_project_associations_flow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentflow_project_associations
    ADD CONSTRAINT agentflow_project_associations_flow_id_fkey FOREIGN KEY (flow_id) REFERENCES public.agentworkflows(id) ON DELETE CASCADE;


--
-- Name: agentflow_project_associations agentflow_project_associations_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentflow_project_associations
    ADD CONSTRAINT agentflow_project_associations_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: agents agents_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: agentworkflows agentworkflows_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentworkflows
    ADD CONSTRAINT agentworkflows_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: chatconversations chatconversations_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatconversations
    ADD CONSTRAINT chatconversations_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: chatmessages chatmessages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatmessages
    ADD CONSTRAINT chatmessages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.chatconversations(session_id) ON DELETE CASCADE;


--
-- Name: files files_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: logs logs_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: mcpservers mcpservers_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mcpservers
    ADD CONSTRAINT mcpservers_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: mcptools mcptools_mcp_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mcptools
    ADD CONSTRAINT mcptools_mcp_server_id_fkey FOREIGN KEY (mcp_server_id) REFERENCES public.mcpservers(id) ON DELETE CASCADE;


--
-- Name: modelconfigs modelconfigs_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelconfigs
    ADD CONSTRAINT modelconfigs_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: modelconfigs modelconfigs_provider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelconfigs
    ADD CONSTRAINT modelconfigs_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES public.modelproviders(id) ON DELETE CASCADE;


--
-- Name: modelproviders modelproviders_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelproviders
    ADD CONSTRAINT modelproviders_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_project_associations user_project_associations_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_associations
    ADD CONSTRAINT user_project_associations_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: user_project_associations user_project_associations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_associations
    ADD CONSTRAINT user_project_associations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_team_associations user_team_associations_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_team_associations
    ADD CONSTRAINT user_team_associations_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: user_team_associations user_team_associations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_team_associations
    ADD CONSTRAINT user_team_associations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: userprofiles userprofiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userprofiles
    ADD CONSTRAINT userprofiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

