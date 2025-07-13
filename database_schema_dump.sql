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

SELECT pg_catalog.setval('public.logs_id_seq', 1, false);


--
-- Name: user_project_associations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_project_associations_id_seq', 1, false);


--
-- Name: user_team_associations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_team_associations_id_seq', 1, false);


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

