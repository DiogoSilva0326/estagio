--
-- PostgreSQL database dump
--

\restrict NDkWz33r0Vu7PRvdWlHICfjlByrxWtu6QuL9IyaIDm2D5JDHkZ9U7qpw1sSjoE4

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

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
-- Name: cleanup_expired_sessions(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cleanup_expired_sessions() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.sessions WHERE expires_at < CURRENT_TIMESTAMP;
END;
$$;


ALTER FUNCTION public.cleanup_expired_sessions() OWNER TO postgres;

--
-- Name: update_professor_rooms_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_professor_rooms_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_professor_rooms_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: chat_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_files (
    id bigint NOT NULL,
    file_id character varying(255) NOT NULL,
    file_name character varying(500) NOT NULL,
    storage_path character varying(1000) NOT NULL,
    content_type character varying(255) NOT NULL,
    file_size bigint DEFAULT 0 NOT NULL,
    uploaded_by_user_id bigint,
    room_id character varying(255),
    message_id bigint,
    thumbnail_url character varying(500),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.chat_files OWNER TO postgres;

--
-- Name: chat_files_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_files_id_seq OWNER TO postgres;

--
-- Name: chat_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_files_id_seq OWNED BY public.chat_files.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    owner_user_id bigint NOT NULL,
    contact_user_id bigint NOT NULL,
    display_name_override text,
    status text DEFAULT 'pending'::text NOT NULL,
    notes text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_contacts_no_self CHECK ((owner_user_id <> contact_user_id))
);


ALTER TABLE public.contacts OWNER TO postgres;

--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO postgres;

--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: group_room_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_room_members (
    id bigint NOT NULL,
    room_id bigint NOT NULL,
    user_id bigint NOT NULL,
    role text DEFAULT 'member'::text NOT NULL,
    nickname text,
    status text DEFAULT 'active'::text NOT NULL,
    notifications_enabled boolean DEFAULT true NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL,
    left_at timestamp with time zone,
    last_read_at timestamp with time zone
);


ALTER TABLE public.group_room_members OWNER TO postgres;

--
-- Name: group_room_members_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.group_room_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.group_room_members_id_seq OWNER TO postgres;

--
-- Name: group_room_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.group_room_members_id_seq OWNED BY public.group_room_members.id;


--
-- Name: group_rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_rooms (
    id bigint NOT NULL,
    room_code text NOT NULL,
    name text NOT NULL,
    description text,
    room_type text DEFAULT 'group'::text NOT NULL,
    created_by_user_id bigint,
    is_active boolean DEFAULT true NOT NULL,
    avatar_url text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.group_rooms OWNER TO postgres;

--
-- Name: group_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.group_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.group_rooms_id_seq OWNER TO postgres;

--
-- Name: group_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.group_rooms_id_seq OWNED BY public.group_rooms.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id bigint NOT NULL,
    room_id text,
    sender_id text,
    receiver_id text,
    sender_user_id bigint,
    receiver_user_id bigint,
    group_room_id bigint,
    content text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messages_id_seq OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: professor_rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.professor_rooms (
    id bigint NOT NULL,
    professor_id bigint NOT NULL,
    professor_name character varying(255) NOT NULL,
    room_name character varying(255) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.professor_rooms OWNER TO postgres;

--
-- Name: TABLE professor_rooms; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.professor_rooms IS 'Video call rooms owned by professors - each professor has a unique room';


--
-- Name: COLUMN professor_rooms.room_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.professor_rooms.room_name IS 'Unique room name for video calls. Default format: Professor_Username. Can be customized by the professor.';


--
-- Name: professor_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.professor_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.professor_rooms_id_seq OWNER TO postgres;

--
-- Name: professor_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.professor_rooms_id_seq OWNED BY public.professor_rooms.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token character varying(255) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ip_address character varying(50),
    user_agent text
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.sessions IS 'User authentication sessions for token-based auth';


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sessions_id_seq OWNER TO postgres;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    username text NOT NULL,
    display_name text,
    email text,
    external_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    password_hash character varying(255),
    role character varying(50) DEFAULT 'aluno'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    last_login_at timestamp with time zone,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'professor'::character varying, 'aluno'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: COLUMN users.role; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.role IS 'User role: admin (full access), professor (can start video calls), aluno (can only join existing calls)';


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
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
-- Name: video_call_participants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.video_call_participants (
    id bigint NOT NULL,
    call_id bigint NOT NULL,
    user_id bigint NOT NULL,
    role text DEFAULT 'participant'::text NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL,
    left_at timestamp with time zone,
    duration_seconds integer,
    avg_video_quality text,
    avg_audio_quality text,
    had_video boolean DEFAULT true NOT NULL,
    had_audio boolean DEFAULT true NOT NULL,
    had_screen_share boolean DEFAULT false NOT NULL,
    device_type text,
    metadata jsonb
);


ALTER TABLE public.video_call_participants OWNER TO postgres;

--
-- Name: video_call_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.video_call_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.video_call_participants_id_seq OWNER TO postgres;

--
-- Name: video_call_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.video_call_participants_id_seq OWNED BY public.video_call_participants.id;


--
-- Name: video_calls; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.video_calls (
    id bigint NOT NULL,
    channel_name text NOT NULL,
    call_name text,
    call_type text DEFAULT 'video'::text NOT NULL,
    initiated_by_user_id bigint,
    status text DEFAULT 'active'::text NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone,
    duration_seconds integer,
    max_participants integer DEFAULT 0 NOT NULL,
    recording_url text,
    is_recorded boolean DEFAULT false NOT NULL,
    metadata jsonb,
    group_room_id bigint
);


ALTER TABLE public.video_calls OWNER TO postgres;

--
-- Name: video_calls_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.video_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.video_calls_id_seq OWNER TO postgres;

--
-- Name: video_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.video_calls_id_seq OWNED BY public.video_calls.id;


--
-- Name: video_room_participants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.video_room_participants (
    id bigint NOT NULL,
    video_room_id bigint NOT NULL,
    user_id bigint NOT NULL,
    joined_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    left_at timestamp with time zone,
    role character varying(50) DEFAULT 'participant'::character varying
);


ALTER TABLE public.video_room_participants OWNER TO postgres;

--
-- Name: video_room_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.video_room_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.video_room_participants_id_seq OWNER TO postgres;

--
-- Name: video_room_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.video_room_participants_id_seq OWNED BY public.video_room_participants.id;


--
-- Name: video_rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.video_rooms (
    id bigint NOT NULL,
    channel_name character varying(255) NOT NULL,
    host_user_id bigint NOT NULL,
    host_username character varying(100),
    title character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    host_joined boolean DEFAULT false NOT NULL,
    started_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ended_at timestamp with time zone,
    total_duration_seconds integer DEFAULT 0,
    max_participants integer DEFAULT 50,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.video_rooms OWNER TO postgres;

--
-- Name: TABLE video_rooms; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.video_rooms IS 'Active video call rooms - only professors/admins can create';


--
-- Name: video_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.video_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.video_rooms_id_seq OWNER TO postgres;

--
-- Name: video_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.video_rooms_id_seq OWNED BY public.video_rooms.id;


--
-- Name: chat_files id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_files ALTER COLUMN id SET DEFAULT nextval('public.chat_files_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: group_room_members id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_room_members ALTER COLUMN id SET DEFAULT nextval('public.group_room_members_id_seq'::regclass);


--
-- Name: group_rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_rooms ALTER COLUMN id SET DEFAULT nextval('public.group_rooms_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: professor_rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professor_rooms ALTER COLUMN id SET DEFAULT nextval('public.professor_rooms_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: video_call_participants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_call_participants ALTER COLUMN id SET DEFAULT nextval('public.video_call_participants_id_seq'::regclass);


--
-- Name: video_calls id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_calls ALTER COLUMN id SET DEFAULT nextval('public.video_calls_id_seq'::regclass);


--
-- Name: video_room_participants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_room_participants ALTER COLUMN id SET DEFAULT nextval('public.video_room_participants_id_seq'::regclass);


--
-- Name: video_rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_rooms ALTER COLUMN id SET DEFAULT nextval('public.video_rooms_id_seq'::regclass);


--
-- Data for Name: chat_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_files (id, file_id, file_name, storage_path, content_type, file_size, uploaded_by_user_id, room_id, message_id, thumbnail_url, is_active, created_at) FROM stdin;
12	f24e3ede-aeb3-424d-a960-6fcc8754066e	AppFinanceira_ER_Diagram.drawio(2).png	/app/uploads/f24e3ede-aeb3-424d-a960-6fcc8754066e.png	image/png	846694	5	Professor_user1_teste	\N	/api/files/f24e3ede-aeb3-424d-a960-6fcc8754066e	t	2026-02-05 11:45:09.155219
13	4f1af889-b630-45fe-99f3-5ceb79699876	AppFinanceira_ER_Diagram.drawio.png	/app/uploads/4f1af889-b630-45fe-99f3-5ceb79699876.png	image/png	288313	3	dm_2_3_7f793310	\N	/api/files/4f1af889-b630-45fe-99f3-5ceb79699876	t	2026-02-05 11:49:27.295486
14	fe9fee34-5b9c-47d6-8b60-e45104580bca	AppFinanceira_ER_Diagram.drawio(1) (1).png	/app/uploads/fe9fee34-5b9c-47d6-8b60-e45104580bca.png	image/png	567545	2	dm_2_3_7f793310	\N	/api/files/fe9fee34-5b9c-47d6-8b60-e45104580bca	t	2026-02-05 12:04:22.525264
15	54174784-dc28-430f-8bcc-8569db10b34b	AppFinanceira_ER_Diagram.drawio(1) (1).png	/app/uploads/54174784-dc28-430f-8bcc-8569db10b34b.png	image/png	567545	2	dm_2_3_7f793310	\N	/api/files/54174784-dc28-430f-8bcc-8569db10b34b	t	2026-02-05 12:12:47.369213
16	a4bf4226-e382-4f0d-8b2b-1be41316ef11	AppFinanceira_ER_Diagram.drawio.png	/app/uploads/a4bf4226-e382-4f0d-8b2b-1be41316ef11.png	image/png	288313	3	dm_2_3_7f793310	\N	/api/files/a4bf4226-e382-4f0d-8b2b-1be41316ef11	t	2026-02-05 12:27:44.258903
17	7fe0a80e-6286-46ff-9aaa-346634522340	AppFinanceira_ER_Diagram.drawio(1) (1).png	/app/uploads/7fe0a80e-6286-46ff-9aaa-346634522340.png	image/png	567545	3	dm_2_3_7f793310	\N	/api/files/7fe0a80e-6286-46ff-9aaa-346634522340	t	2026-02-05 12:49:32.065357
18	6573ac26-9e4f-4982-8957-437f979a2b53	AppFinanceira_ER_Diagram.drawio(1) (1).png	/app/uploads/6573ac26-9e4f-4982-8957-437f979a2b53.png	image/png	567545	3	dm_2_3_7f793310	\N	/api/files/6573ac26-9e4f-4982-8957-437f979a2b53	t	2026-02-05 12:58:42.722314
19	b922b651-40dd-4dec-9e44-ec270e713cde	AppFinanceira_ER_Diagram.drawio(1) (1).png	/app/uploads/b922b651-40dd-4dec-9e44-ec270e713cde.png	image/png	567545	3	dm_2_3_7f793310	\N	/api/files/b922b651-40dd-4dec-9e44-ec270e713cde	t	2026-02-05 12:58:56.78073
20	74aad389-681c-4239-8ba2-39a6e47935ea	AppFinanceira_ER_Diagram.drawio.png	/app/uploads/74aad389-681c-4239-8ba2-39a6e47935ea.png	image/png	288313	3	dm_2_3_7f793310	\N	/api/files/74aad389-681c-4239-8ba2-39a6e47935ea	t	2026-02-05 12:59:14.937234
21	bc8d0764-4296-4743-9595-69058853b030	AppFinanceira_ER_Diagram.drawio.png	/app/uploads/bc8d0764-4296-4743-9595-69058853b030.png	image/png	288313	3	dm_2_3_7f793310	\N	/api/files/bc8d0764-4296-4743-9595-69058853b030	t	2026-02-05 13:02:22.527581
22	d322357c-50e1-443e-94bc-0b0ea7cd5a56	AppFinanceira_ER_Diagram.drawio(1) (1).png	/app/uploads/d322357c-50e1-443e-94bc-0b0ea7cd5a56.png	image/png	567545	2	dm_2_3_7f793310	\N	/api/files/d322357c-50e1-443e-94bc-0b0ea7cd5a56	t	2026-02-05 13:02:29.097138
23	a516dd1b-3f7b-44c8-bdd3-7c4edf030cec	AppFinanceira_ER_Diagram.drawio.png	/app/uploads/a516dd1b-3f7b-44c8-bdd3-7c4edf030cec.png	image/png	288313	9	Professor_user1_teste	\N	/api/files/a516dd1b-3f7b-44c8-bdd3-7c4edf030cec	t	2026-02-05 13:42:53.241526
24	1ccef032-d326-4bb0-a757-f7c1fae63c8c	AppFinanceira_ER_Diagram.drawio.png	/app/uploads/1ccef032-d326-4bb0-a757-f7c1fae63c8c.png	image/png	288313	2	dm_2_3_7f793310	\N	/api/files/1ccef032-d326-4bb0-a757-f7c1fae63c8c	t	2026-02-05 14:12:01.221657
25	176d636b-e4cc-4523-ba33-68cf044af9f2	AppFinanceira_ER_Diagram.drawio(1).png	/app/uploads/176d636b-e4cc-4523-ba33-68cf044af9f2.png	image/png	567545	3	dm_2_3_7f793310	\N	/api/files/176d636b-e4cc-4523-ba33-68cf044af9f2	t	2026-02-05 14:12:16.980674
26	04241690-5c5f-4da3-bcbe-e3385683f1e5	AppFinanceira_ER_Diagram.drawio(2).png	/app/uploads/04241690-5c5f-4da3-bcbe-e3385683f1e5.png	image/png	846694	3	dm_2_3_7f793310	20	/api/files/04241690-5c5f-4da3-bcbe-e3385683f1e5	t	2026-02-05 14:16:44.958633
27	680b7e0d-7330-4549-b90d-fc679d0e7aa8	AppFinanceira_ER_Diagram.drawio(1).png	/app/uploads/680b7e0d-7330-4549-b90d-fc679d0e7aa8.png	image/png	567545	3	dm_2_3_7f793310	21	/api/files/680b7e0d-7330-4549-b90d-fc679d0e7aa8	t	2026-02-05 14:17:01.967284
28	4f1b536d-c560-43e4-a00a-42e5933a5b1f	AppFinanceira_ER_Diagram.drawio(1) (1).png	/app/uploads/4f1b536d-c560-43e4-a00a-42e5933a5b1f.png	image/png	567545	3	dm_2_3_7f793310	22	/api/files/4f1b536d-c560-43e4-a00a-42e5933a5b1f	t	2026-02-05 14:17:58.906905
29	5b160ca9-9f1b-4981-88d9-1e46d78fc9c8	AppFinanceira_ER_Diagram.drawio(2).png	/app/uploads/5b160ca9-9f1b-4981-88d9-1e46d78fc9c8.png	image/png	846694	3	dm_2_3_7f793310	23	/api/files/5b160ca9-9f1b-4981-88d9-1e46d78fc9c8	t	2026-02-05 14:21:24.514031
30	2fd6b553-af5a-401e-8e5d-d12e73f4b2c3	AppFinanceira_ER_Diagram.drawio(1) (1).png	/app/uploads/2fd6b553-af5a-401e-8e5d-d12e73f4b2c3.png	image/png	567545	5	Professor_user1_teste	\N	/api/files/2fd6b553-af5a-401e-8e5d-d12e73f4b2c3	t	2026-02-05 14:21:50.356801
31	793628b2-10ea-4b03-a432-cc7e6556b8a7	AppFinanceira_ER_Diagram.drawio(1) (1) (1).png	/app/uploads/793628b2-10ea-4b03-a432-cc7e6556b8a7.png	image/png	567545	3	dm_2_3_7f793310	25	/api/files/793628b2-10ea-4b03-a432-cc7e6556b8a7	t	2026-02-05 14:23:49.548085
32	60d04093-0152-4a5c-8c39-fb98d975c131	AppFinanceira_ER_Diagram.drawio(1) (1) (1) (1).png	/app/uploads/60d04093-0152-4a5c-8c39-fb98d975c131.png	image/png	567545	2	dm_2_3_7f793310	27	/api/files/60d04093-0152-4a5c-8c39-fb98d975c131	t	2026-02-05 14:24:13.201255
\.


--
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contacts (id, owner_user_id, contact_user_id, display_name_override, status, notes, metadata, created_at, updated_at) FROM stdin;
1	2	3	User Two	accepted	\N	\N	2026-02-05 09:31:26.352715+00	2026-02-05 09:32:02.003914+00
2	3	2	user	accepted	\N	\N	2026-02-05 09:32:02.009261+00	2026-02-05 09:32:02.009266+00
\.


--
-- Data for Name: group_room_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.group_room_members (id, room_id, user_id, role, nickname, status, notifications_enabled, joined_at, left_at, last_read_at) FROM stdin;
1	1	3	owner	\N	active	t	2026-02-05 10:38:11.656844+00	\N	\N
2	1	2	member	\N	active	t	2026-02-05 10:38:11.683862+00	\N	\N
3	2	2	member	\N	active	t	2026-02-05 10:39:07.212233+00	\N	\N
4	2	3	member	\N	active	t	2026-02-05 10:39:07.226461+00	\N	\N
5	3	3	owner	\N	active	t	2026-02-05 14:29:04.089845+00	\N	\N
6	3	2	member	\N	active	t	2026-02-05 14:29:04.10713+00	\N	\N
\.


--
-- Data for Name: group_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.group_rooms (id, room_code, name, description, room_type, created_by_user_id, is_active, avatar_url, metadata, created_at, updated_at) FROM stdin;
1	149ec1c9fb4944a9ba19f2913156b13b	testechat	\N	group	3	t	\N	\N	2026-02-05 10:38:11.47277+00	2026-02-05 10:38:11.472815+00
2	dm_2_3_7f793310	Direct Message	\N	direct	2	t	\N	\N	2026-02-05 10:39:07.192291+00	2026-02-05 10:39:07.192296+00
3	ee0530812bd34e1d86d70821bb2705e3	teste1	\N	group	3	t	\N	\N	2026-02-05 14:29:04.014504+00	2026-02-05 14:29:04.01457+00
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, room_id, sender_id, receiver_id, sender_user_id, receiver_user_id, group_room_id, content, metadata, created_at) FROM stdin;
1	dm_user1_user2	user2	\N	2	\N	\N	teste	\N	2026-02-05 10:22:31.179692+00
2	dm_user1_user2	user1	\N	3	\N	\N	teste de volta	\N	2026-02-05 10:22:37.918217+00
3	group_dc48e12f8fd342e88bd1c6a31dd8b284	user2	\N	2	\N	\N	teste	\N	2026-02-05 10:25:33.3605+00
4	group_8f613d5a5bf1421cb0928a0dbe67c0b3	user1	\N	3	\N	\N	teste	\N	2026-02-05 10:37:20.218694+00
5	149ec1c9fb4944a9ba19f2913156b13b	user1	\N	3	\N	\N	teste	\N	2026-02-05 10:38:34.536088+00
6	dm_2_3_7f793310	user1	\N	3	\N	\N	teste	\N	2026-02-05 10:39:08.82989+00
7	dm_2_3_7f793310	user2	\N	2	\N	\N	teste	\N	2026-02-05 10:39:18.711069+00
8	dm_2_3_7f793310	user2	\N	2	\N	\N	oiii akdbkasdjas	\N	2026-02-05 10:44:24.728783+00
9	Professor_user1_teste	817017	\N	11	\N	\N	teste	\N	2026-02-05 10:53:18.975473+00
10	Professor_user1_teste	268547	\N	10	\N	\N	teste	\N	2026-02-05 10:53:21.16271+00
11	dm_2_3_7f793310	user1	\N	3	\N	\N	teste	\N	2026-02-05 11:22:55.681951+00
12	Professor_user1_teste	329574	\N	13	\N	\N	teste	\N	2026-02-05 11:23:44.413344+00
13	Professor_user1_teste	171545	\N	12	\N	\N	teste	\N	2026-02-05 11:23:47.742828+00
14	dm_2_3_7f793310	user2	\N	2	\N	\N	dsfdsfsd	\N	2026-02-05 12:04:32.568102+00
15	dm_2_3_7f793310	user2	\N	2	\N	\N	dasdsa	\N	2026-02-05 12:12:43.314881+00
16	dm_2_3_7f793310	user2	\N	2	\N	\N	asdsadsa	\N	2026-02-05 12:13:00.242846+00
17	dm_2_3_7f793310	user1	\N	3	\N	\N	teste	\N	2026-02-05 12:26:17.37375+00
18	dm_2_3_7f793310	user1	\N	3	\N	\N	adasda	\N	2026-02-05 13:02:17.221751+00
19	dm_2_3_7f793310	user1	\N	3	\N	\N	dasdsa	\N	2026-02-05 14:12:28.544248+00
20	dm_2_3_7f793310	user1	\N	3	\N	\N		{"type": "file", "fileId": "04241690-5c5f-4da3-bcbe-e3385683f1e5", "fileName": "AppFinanceira_ER_Diagram.drawio(2).png", "fileSize": 846694, "contentType": "image/png", "downloadUrl": "/api/files/04241690-5c5f-4da3-bcbe-e3385683f1e5"}	2026-02-05 14:16:46.221165+00
21	dm_2_3_7f793310	user1	\N	3	\N	\N		{"type": "file", "fileId": "680b7e0d-7330-4549-b90d-fc679d0e7aa8", "fileName": "AppFinanceira_ER_Diagram.drawio(1).png", "fileSize": 567545, "contentType": "image/png", "downloadUrl": "/api/files/680b7e0d-7330-4549-b90d-fc679d0e7aa8"}	2026-02-05 14:17:02.915337+00
22	dm_2_3_7f793310	user1	\N	3	\N	\N		{"type": "file", "fileId": "4f1b536d-c560-43e4-a00a-42e5933a5b1f", "fileName": "AppFinanceira_ER_Diagram.drawio(1) (1).png", "fileSize": 567545, "contentType": "image/png", "downloadUrl": "/api/files/4f1b536d-c560-43e4-a00a-42e5933a5b1f"}	2026-02-05 14:18:00.430735+00
23	dm_2_3_7f793310	user1	\N	3	\N	\N		{"type": "file", "fileId": "5b160ca9-9f1b-4981-88d9-1e46d78fc9c8", "fileName": "AppFinanceira_ER_Diagram.drawio(2).png", "fileSize": 846694, "contentType": "image/png", "downloadUrl": "/api/files/5b160ca9-9f1b-4981-88d9-1e46d78fc9c8"}	2026-02-05 14:21:25.83185+00
24	dm_2_3_7f793310	user1	\N	3	\N	\N	📎 Ficheiro enviado: AppFinanceira_ER_Diagram.drawio(2).png	\N	2026-02-05 14:21:25.897341+00
25	dm_2_3_7f793310	user1	\N	3	\N	\N		{"type": "file", "fileId": "793628b2-10ea-4b03-a432-cc7e6556b8a7", "fileName": "AppFinanceira_ER_Diagram.drawio(1) (1) (1).png", "fileSize": 567545, "contentType": "image/png", "downloadUrl": "/api/files/793628b2-10ea-4b03-a432-cc7e6556b8a7"}	2026-02-05 14:23:50.917373+00
26	dm_2_3_7f793310	user1	\N	3	\N	\N	📎 Ficheiro enviado: AppFinanceira_ER_Diagram.drawio(1) (1) (1).png	\N	2026-02-05 14:23:50.987124+00
27	dm_2_3_7f793310	user2	\N	2	\N	\N		{"type": "file", "fileId": "60d04093-0152-4a5c-8c39-fb98d975c131", "fileName": "AppFinanceira_ER_Diagram.drawio(1) (1) (1) (1).png", "fileSize": 567545, "contentType": "image/png", "downloadUrl": "/api/files/60d04093-0152-4a5c-8c39-fb98d975c131"}	2026-02-05 14:24:14.250558+00
28	dm_2_3_7f793310	user2	\N	2	\N	\N	📎 Ficheiro enviado: AppFinanceira_ER_Diagram.drawio(1) (1) (1) (1).png	\N	2026-02-05 14:24:14.266757+00
29	group_ee0530812bd34e1d86d70821bb2705e3	user1	\N	3	\N	\N	dasdas	\N	2026-02-05 14:37:15.886104+00
30	group_149ec1c9fb4944a9ba19f2913156b13b	user1	\N	3	\N	\N	asdasda	\N	2026-02-05 14:37:22.6119+00
31	group_ee0530812bd34e1d86d70821bb2705e3	user1	\N	3	\N	\N	asdsadas	\N	2026-02-05 14:51:39.082427+00
32	group_ee0530812bd34e1d86d70821bb2705e3	user2	\N	2	\N	\N	adsadasdas	\N	2026-02-05 14:51:48.763903+00
\.


--
-- Data for Name: professor_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.professor_rooms (id, professor_id, professor_name, room_name, description, is_active, created_at, updated_at) FROM stdin;
1	3	user	Professor_user1_teste	\N	t	2026-02-05 09:33:17.39321+00	2026-02-05 10:48:05.300232+00
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, user_id, token, expires_at, created_at, ip_address, user_agent) FROM stdin;
1	2	qy8kxBLLgka4zqw4UyBRQgAIEOaehJWEe429dOkKAGBg	2026-03-06 17:14:29.595578+00	2026-02-04 17:14:29.599796+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0
2	3	9qaip7f4XUuvmHwnwQqN8QN64RtpMnokCCO6CSa4ruZA	2026-03-06 17:14:50.319417+00	2026-02-04 17:14:50.319933+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
3	3	8jGr5TGUb0mP1Ud9YgVtLAKOx-va4w10qVwDyIe3AGiQ	2026-03-07 09:21:21.260382+00	2026-02-05 09:21:21.264633+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
4	2	RMJyuRdLQEaqqkbI1I62rQZNqW7s8T5EiyvBT2cW1lhQ	2026-03-07 09:21:27.51187+00	2026-02-05 09:21:27.512372+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0
6	2	8H7IvBs5DEiaZSapzOyO2gM1n--rA-K0qQD3N5whRoZw	2026-03-07 09:53:48.555461+00	2026-02-05 09:53:48.556184+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0
7	3	2lcPQH-a60WVbW1VMzWLFAFoXRKj8VsE-fO-AaxA-NxQ	2026-03-07 10:01:43.842427+00	2026-02-05 10:01:43.846314+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
8	3	V24HJPbXy0mhb9Tp40s8rgyndin2xh0kyfCb_NN-dnSg	2026-03-07 10:09:56.822034+00	2026-02-05 10:09:56.822729+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
9	2	AEBGBl_Ax0-ebElK9TgSOAAhFQREf99UKlIXmgdcoW3w	2026-03-07 10:21:48.343801+00	2026-02-05 10:21:48.34965+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0
10	3	qJNOSEFXOU-fk35aEQvEgQPo3x2mViS0GvoB81qojmdQ	2026-03-07 11:20:38.387223+00	2026-02-05 11:20:38.391596+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
11	2	XTh1Z-hGlk-DeS_f8beo9wGNVmITeuN0KiHHb4J5g7yw	2026-03-07 11:23:03.995087+00	2026-02-05 11:23:03.995876+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0
12	3	os16Rk7Ko0O-tDQoswOokwIlLrlj6cpEeTFO_sdXEgoQ	2026-03-07 12:36:18.333973+00	2026-02-05 12:36:18.340286+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
13	2	3vJsbFzxVkSTiYeSKIieXAzFJb4RyTb0GUiWAoZvyp_Q	2026-03-07 12:36:43.441196+00	2026-02-05 12:36:43.44199+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0
14	3	Pgt2OTitXEuyPui_DSSH4Qnw5Grz_4GUemwsJSG-D_iw	2026-03-07 13:42:11.53958+00	2026-02-05 13:42:11.546266+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
15	2	hq_rp4LgxU-lyZA4DRx1gw6ec3SkAQOkCePJlYI7YYKg	2026-03-07 13:42:17.424517+00	2026-02-05 13:42:17.425157+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0
16	3	HZflWKETMkSCXWR7eV1_5w7Vjh6nhnQUejO8Uq9IZPuw	2026-03-07 14:54:37.965246+00	2026-02-05 14:54:37.971083+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
17	2	uEYqtNvDREKbPRzrviUlRgJIRwbkofgUOdU53yNGjrFQ	2026-03-07 14:55:00.643912+00	2026-02-05 14:55:00.644932+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0
18	3	Stfffyevg0a1DqK7dnyPEgTPajsMlnDkeLTmLGUYUGzA	2026-03-07 14:55:35.142065+00	2026-02-05 14:55:35.142175+00	::ffff:192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, display_name, email, external_id, metadata, created_at, password_hash, role, is_active, last_login_at) FROM stdin;
1	admin	Administrator	admin@synget.pt	\N	\N	2026-02-04 17:10:59.18938+00	$2a$11$rBNjxJ7cJqI5tM3LwGnHXOQf5.K5jF5Qhz1X5x5x5x5x5x5x5x5x5	admin	t	\N
4	testuser	Test User	\N	\N	\N	2026-02-04 17:26:17.137845+00	\N	aluno	t	\N
5	user	user	\N	\N	\N	2026-02-04 17:29:06.104869+00	\N	aluno	t	\N
6	804952	user	\N	\N	\N	2026-02-04 17:29:13.548471+00	\N	aluno	t	\N
7	professor1	Prof. Silva	\N	\N	\N	2026-02-04 17:35:28.801329+00	\N	aluno	t	\N
8	aluno1	João Aluno	\N	\N	\N	2026-02-04 17:35:37.720891+00	\N	aluno	t	\N
9	user two	User Two	\N	\N	\N	2026-02-04 17:36:30.593909+00	\N	aluno	t	\N
10	268547	user	\N	\N	\N	2026-02-05 10:53:12.271339+00	\N	aluno	t	\N
11	817017	User Two	\N	\N	\N	2026-02-05 10:53:15.644293+00	\N	aluno	t	\N
12	171545	User Two	\N	\N	\N	2026-02-05 11:23:31.287387+00	\N	aluno	t	\N
13	329574	user	\N	\N	\N	2026-02-05 11:23:33.623988+00	\N	aluno	t	\N
14	536134	user	\N	\N	\N	2026-02-05 11:30:56.794864+00	\N	aluno	t	\N
15	313722	user	\N	\N	\N	2026-02-05 11:31:25.606899+00	\N	aluno	t	\N
16	673341	User Two	\N	\N	\N	2026-02-05 11:31:40.852732+00	\N	aluno	t	\N
17	738925	User Two	\N	\N	\N	2026-02-05 11:31:55.177338+00	\N	aluno	t	\N
2	user2	User Two	user2@gmail.com	\N	\N	2026-02-04 17:14:29.4017+00	$2a$11$Shg1ib/kmsrAbzaMcxue/eq4Oy8wPYhEmzlsUleCIjhMINbmIa6VS	aluno	t	2026-02-05 14:55:00.659905+00
3	user1	user	user1@gmail.com	\N	\N	2026-02-04 17:14:50.308539+00	$2a$11$Y6qGkSUs5Cx4x/mcuaZ.8.GVfEOTP7a8jZmDSvaa9UeYlmA/FfaPO	professor	t	2026-02-05 14:55:35.152692+00
\.


--
-- Data for Name: video_call_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.video_call_participants (id, call_id, user_id, role, joined_at, left_at, duration_seconds, avg_video_quality, avg_audio_quality, had_video, had_audio, had_screen_share, device_type, metadata) FROM stdin;
2	1	2	participant	2026-02-04 17:26:25.994955+00	2026-02-04 17:26:37.614138+00	11	\N	\N	t	t	f	ios	\N
1	1	4	host	2026-02-04 17:26:17.459078+00	2026-02-04 17:26:45.125028+00	27	\N	\N	t	t	f	\N	\N
3	2	5	host	2026-02-04 17:29:06.164765+00	2026-02-04 17:29:16.049925+00	9	\N	\N	t	t	f	\N	\N
4	3	5	host	2026-02-04 17:29:46.99241+00	2026-02-04 17:30:18.766266+00	31	\N	\N	t	t	f	\N	\N
5	4	7	host	2026-02-04 17:35:28.996884+00	\N	\N	\N	\N	t	t	f	\N	\N
6	4	8	participant	2026-02-04 17:35:37.739278+00	\N	\N	\N	\N	t	t	f	\N	\N
8	5	9	participant	2026-02-04 17:36:30.608073+00	2026-02-04 17:37:03.533637+00	32	\N	\N	t	t	f	web	\N
7	5	5	host	2026-02-04 17:36:21.148893+00	2026-02-04 17:37:07.554053+00	46	\N	\N	t	t	f	\N	\N
10	6	9	participant	2026-02-05 10:22:01.231227+00	2026-02-05 10:22:09.537339+00	8	\N	\N	t	t	f	web	\N
9	6	5	host	2026-02-05 10:21:55.745892+00	2026-02-05 10:22:14.807452+00	19	\N	\N	t	t	f	\N	\N
11	7	5	host	2026-02-05 10:24:49.426435+00	2026-02-05 10:24:55.40277+00	5	\N	\N	t	t	f	\N	\N
12	8	5	host	2026-02-05 10:53:06.304993+00	2026-02-05 10:55:33.948372+00	147	\N	\N	t	t	f	\N	\N
13	8	9	participant	2026-02-05 10:53:12.712441+00	2026-02-05 10:55:34.038067+00	141	\N	\N	t	t	f	web	\N
14	9	5	host	2026-02-05 11:23:24.633621+00	2026-02-05 11:23:52.133978+00	27	\N	\N	t	t	f	\N	\N
15	9	9	participant	2026-02-05 11:23:30.603498+00	2026-02-05 11:23:52.178264+00	21	\N	\N	t	t	f	web	\N
17	10	9	participant	2026-02-05 11:31:39.282016+00	2026-02-05 11:33:39.71079+00	120	\N	\N	t	t	f	web	\N
16	10	5	host	2026-02-05 11:30:56.469419+00	2026-02-05 11:34:28.115473+00	211	\N	\N	t	t	f	\N	\N
19	11	9	participant	2026-02-05 11:41:10.888371+00	2026-02-05 11:41:29.390965+00	18	\N	\N	t	t	f	web	\N
18	11	5	host	2026-02-05 11:41:01.632637+00	2026-02-05 11:41:30.452873+00	28	\N	\N	t	t	f	\N	\N
20	12	5	host	2026-02-05 11:44:57.699917+00	2026-02-05 11:45:11.47881+00	13	\N	\N	t	t	f	\N	\N
21	12	9	participant	2026-02-05 11:45:01.640049+00	2026-02-05 11:45:11.555174+00	9	\N	\N	t	t	f	web	\N
22	13	5	host	2026-02-05 12:29:36.465913+00	2026-02-05 12:29:40.240515+00	3	\N	\N	t	t	f	\N	\N
23	14	5	host	2026-02-05 12:52:50.315746+00	2026-02-05 12:56:36.165143+00	225	\N	\N	t	t	f	\N	\N
24	14	9	participant	2026-02-05 12:53:16.875864+00	2026-02-05 12:56:36.225243+00	199	\N	\N	t	t	f	web	\N
25	15	5	host	2026-02-05 12:57:00.792607+00	2026-02-05 13:01:16.925529+00	256	\N	\N	t	t	f	\N	\N
26	16	5	host	2026-02-05 13:42:29.928341+00	2026-02-05 13:43:46.569713+00	76	\N	\N	t	t	f	\N	\N
27	16	9	participant	2026-02-05 13:42:43.246058+00	2026-02-05 13:43:46.59408+00	63	\N	\N	t	t	f	web	\N
28	17	5	host	2026-02-05 14:21:46.129708+00	2026-02-05 14:24:38.188057+00	172	\N	\N	t	t	f	\N	\N
29	18	5	host	2026-02-05 14:35:16.187405+00	2026-02-05 14:35:39.345596+00	23	\N	\N	t	t	f	\N	\N
30	19	5	host	2026-02-05 14:36:15.140526+00	2026-02-05 14:36:27.462817+00	12	\N	\N	t	t	f	\N	\N
31	20	5	host	2026-02-05 14:42:35.664338+00	2026-02-05 14:42:41.814572+00	6	\N	\N	t	t	f	\N	\N
\.


--
-- Data for Name: video_calls; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.video_calls (id, channel_name, call_name, call_type, initiated_by_user_id, status, started_at, ended_at, duration_seconds, max_participants, recording_url, is_recorded, metadata, group_room_id) FROM stdin;
19	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 14:36:15.119233+00	2026-02-05 14:36:27.492087+00	12	1	\N	f	\N	\N
1	test-call-room	\N	video	4	ended	2026-02-04 17:26:17.400215+00	2026-02-04 17:26:45.169587+00	27	2	\N	f	\N	\N
2	test-channel	\N	video	5	ended	2026-02-04 17:29:06.155586+00	2026-02-04 17:29:16.059491+00	9	1	\N	f	\N	\N
3	test-channel	\N	video	5	ended	2026-02-04 17:29:46.977573+00	2026-02-04 17:30:18.780025+00	31	1	\N	f	\N	\N
5	test-channel	\N	video	5	ended	2026-02-04 17:36:21.112819+00	2026-02-04 17:37:07.590317+00	46	2	\N	f	\N	\N
4	aula-matematica	\N	video	7	ended	2026-02-04 17:35:28.936001+00	\N	\N	2	\N	f	\N	\N
20	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 14:42:35.409698+00	2026-02-05 14:42:41.87063+00	6	1	\N	f	\N	\N
6	Professor_user1	Professor_user1	video	5	ended	2026-02-05 10:21:55.446966+00	2026-02-05 10:22:14.853822+00	19	2	\N	f	\N	\N
7	Professor_user1	Professor_user1	video	5	ended	2026-02-05 10:24:49.399755+00	2026-02-05 10:24:55.456912+00	6	1	\N	f	\N	\N
8	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 10:53:06.196222+00	2026-02-05 10:55:34.037285+00	147	2	\N	f	\N	\N
9	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 11:23:24.561857+00	2026-02-05 11:23:52.177769+00	27	2	\N	f	\N	\N
10	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 11:30:56.430313+00	2026-02-05 11:34:28.134086+00	211	2	\N	f	\N	\N
11	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 11:41:01.267393+00	2026-02-05 11:41:30.50879+00	29	2	\N	f	\N	\N
12	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 11:44:57.253181+00	2026-02-05 11:45:11.554171+00	14	2	\N	f	\N	\N
13	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 12:29:36.400431+00	2026-02-05 12:29:40.301152+00	3	1	\N	f	\N	\N
14	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 12:52:50.065932+00	2026-02-05 12:56:36.224611+00	226	2	\N	f	\N	\N
15	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 12:57:00.75721+00	2026-02-05 13:01:17.143197+00	256	1	\N	f	\N	\N
16	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 13:42:29.90946+00	2026-02-05 13:43:46.59389+00	76	2	\N	f	\N	\N
17	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 14:21:46.034563+00	2026-02-05 14:24:38.252788+00	172	1	\N	f	\N	\N
18	Professor_user1_teste	Professor_user1_teste	video	5	ended	2026-02-05 14:35:15.777781+00	2026-02-05 14:35:39.51989+00	23	1	\N	f	\N	\N
\.


--
-- Data for Name: video_room_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.video_room_participants (id, video_room_id, user_id, joined_at, left_at, role) FROM stdin;
\.


--
-- Data for Name: video_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.video_rooms (id, channel_name, host_user_id, host_username, title, is_active, host_joined, started_at, ended_at, total_duration_seconds, max_participants, created_at) FROM stdin;
\.


--
-- Name: chat_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_files_id_seq', 32, true);


--
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contacts_id_seq', 2, true);


--
-- Name: group_room_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.group_room_members_id_seq', 6, true);


--
-- Name: group_rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.group_rooms_id_seq', 3, true);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messages_id_seq', 32, true);


--
-- Name: professor_rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.professor_rooms_id_seq', 1, true);


--
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sessions_id_seq', 18, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 17, true);


--
-- Name: video_call_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.video_call_participants_id_seq', 31, true);


--
-- Name: video_calls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.video_calls_id_seq', 20, true);


--
-- Name: video_room_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.video_room_participants_id_seq', 1, false);


--
-- Name: video_rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.video_rooms_id_seq', 1, false);


--
-- Name: chat_files chat_files_file_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_files
    ADD CONSTRAINT chat_files_file_id_key UNIQUE (file_id);


--
-- Name: chat_files chat_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_files
    ADD CONSTRAINT chat_files_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: group_room_members group_room_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_room_members
    ADD CONSTRAINT group_room_members_pkey PRIMARY KEY (id);


--
-- Name: group_rooms group_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_rooms
    ADD CONSTRAINT group_rooms_pkey PRIMARY KEY (id);


--
-- Name: group_rooms group_rooms_room_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_rooms
    ADD CONSTRAINT group_rooms_room_code_key UNIQUE (room_code);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: professor_rooms professor_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professor_rooms
    ADD CONSTRAINT professor_rooms_pkey PRIMARY KEY (id);


--
-- Name: professor_rooms professor_rooms_room_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professor_rooms
    ADD CONSTRAINT professor_rooms_room_name_key UNIQUE (room_name);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_token_key UNIQUE (token);


--
-- Name: contacts uq_contacts_owner_contact; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT uq_contacts_owner_contact UNIQUE (owner_user_id, contact_user_id);


--
-- Name: professor_rooms uq_professor_rooms_professor; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professor_rooms
    ADD CONSTRAINT uq_professor_rooms_professor UNIQUE (professor_id);


--
-- Name: group_room_members uq_room_members; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_room_members
    ADD CONSTRAINT uq_room_members UNIQUE (room_id, user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: video_call_participants video_call_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_call_participants
    ADD CONSTRAINT video_call_participants_pkey PRIMARY KEY (id);


--
-- Name: video_calls video_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_calls
    ADD CONSTRAINT video_calls_pkey PRIMARY KEY (id);


--
-- Name: video_room_participants video_room_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_room_participants
    ADD CONSTRAINT video_room_participants_pkey PRIMARY KEY (id);


--
-- Name: video_room_participants video_room_participants_video_room_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_room_participants
    ADD CONSTRAINT video_room_participants_video_room_id_user_id_key UNIQUE (video_room_id, user_id);


--
-- Name: video_rooms video_rooms_channel_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_rooms
    ADD CONSTRAINT video_rooms_channel_name_key UNIQUE (channel_name);


--
-- Name: video_rooms video_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_rooms
    ADD CONSTRAINT video_rooms_pkey PRIMARY KEY (id);


--
-- Name: idx_call_participants_call; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_call_participants_call ON public.video_call_participants USING btree (call_id);


--
-- Name: idx_call_participants_joined; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_call_participants_joined ON public.video_call_participants USING btree (joined_at);


--
-- Name: idx_call_participants_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_call_participants_user ON public.video_call_participants USING btree (user_id);


--
-- Name: idx_chat_files_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_files_file_id ON public.chat_files USING btree (file_id);


--
-- Name: idx_chat_files_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_files_is_active ON public.chat_files USING btree (is_active);


--
-- Name: idx_chat_files_message_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_files_message_id ON public.chat_files USING btree (message_id);


--
-- Name: idx_chat_files_room_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_files_room_id ON public.chat_files USING btree (room_id);


--
-- Name: idx_chat_files_uploaded_by_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_files_uploaded_by_user_id ON public.chat_files USING btree (uploaded_by_user_id);


--
-- Name: idx_contacts_contact; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contacts_contact ON public.contacts USING btree (contact_user_id);


--
-- Name: idx_contacts_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contacts_owner ON public.contacts USING btree (owner_user_id);


--
-- Name: idx_contacts_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contacts_status ON public.contacts USING btree (status);


--
-- Name: idx_group_rooms_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_rooms_active ON public.group_rooms USING btree (is_active);


--
-- Name: idx_group_rooms_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_rooms_created_by ON public.group_rooms USING btree (created_by_user_id);


--
-- Name: idx_group_rooms_room_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_rooms_room_code ON public.group_rooms USING btree (room_code);


--
-- Name: idx_messages_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_created_at ON public.messages USING btree (created_at);


--
-- Name: idx_messages_group_room; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_group_room ON public.messages USING btree (group_room_id);


--
-- Name: idx_messages_receiver_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_receiver_user ON public.messages USING btree (receiver_user_id);


--
-- Name: idx_messages_room; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_room ON public.messages USING btree (room_id);


--
-- Name: idx_messages_sender_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_sender_user ON public.messages USING btree (sender_user_id);


--
-- Name: idx_professor_rooms_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_professor_rooms_active ON public.professor_rooms USING btree (is_active);


--
-- Name: idx_professor_rooms_professor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_professor_rooms_professor ON public.professor_rooms USING btree (professor_id);


--
-- Name: idx_professor_rooms_room_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_professor_rooms_room_name ON public.professor_rooms USING btree (room_name);


--
-- Name: idx_room_members_room; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_room_members_room ON public.group_room_members USING btree (room_id);


--
-- Name: idx_room_members_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_room_members_status ON public.group_room_members USING btree (status);


--
-- Name: idx_room_members_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_room_members_user ON public.group_room_members USING btree (user_id);


--
-- Name: idx_sessions_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_expires_at ON public.sessions USING btree (expires_at);


--
-- Name: idx_sessions_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_token ON public.sessions USING btree (token);


--
-- Name: idx_sessions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_user_id ON public.sessions USING btree (user_id);


--
-- Name: idx_users_external_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_external_id ON public.users USING btree (external_id);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_username ON public.users USING btree (username);


--
-- Name: idx_video_calls_channel; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_video_calls_channel ON public.video_calls USING btree (channel_name);


--
-- Name: idx_video_calls_initiator; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_video_calls_initiator ON public.video_calls USING btree (initiated_by_user_id);


--
-- Name: idx_video_calls_room; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_video_calls_room ON public.video_calls USING btree (group_room_id);


--
-- Name: idx_video_calls_started; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_video_calls_started ON public.video_calls USING btree (started_at);


--
-- Name: idx_video_calls_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_video_calls_status ON public.video_calls USING btree (status);


--
-- Name: idx_video_participants_room; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_video_participants_room ON public.video_room_participants USING btree (video_room_id);


--
-- Name: idx_video_participants_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_video_participants_user ON public.video_room_participants USING btree (user_id);


--
-- Name: idx_video_rooms_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_video_rooms_active ON public.video_rooms USING btree (is_active);


--
-- Name: idx_video_rooms_channel; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_video_rooms_channel ON public.video_rooms USING btree (channel_name);


--
-- Name: idx_video_rooms_host; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_video_rooms_host ON public.video_rooms USING btree (host_user_id);


--
-- Name: idx_video_rooms_host_joined; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_video_rooms_host_joined ON public.video_rooms USING btree (host_joined);


--
-- Name: professor_rooms trigger_professor_rooms_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_professor_rooms_updated_at BEFORE UPDATE ON public.professor_rooms FOR EACH ROW EXECUTE FUNCTION public.update_professor_rooms_updated_at();


--
-- Name: chat_files chat_files_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_files
    ADD CONSTRAINT chat_files_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(id) ON DELETE SET NULL;


--
-- Name: chat_files chat_files_uploaded_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_files
    ADD CONSTRAINT chat_files_uploaded_by_user_id_fkey FOREIGN KEY (uploaded_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: video_call_participants fk_call_participants_call; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_call_participants
    ADD CONSTRAINT fk_call_participants_call FOREIGN KEY (call_id) REFERENCES public.video_calls(id) ON DELETE CASCADE;


--
-- Name: video_call_participants fk_call_participants_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_call_participants
    ADD CONSTRAINT fk_call_participants_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: contacts fk_contacts_contact; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT fk_contacts_contact FOREIGN KEY (contact_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: contacts fk_contacts_owner; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT fk_contacts_owner FOREIGN KEY (owner_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages fk_messages_group_room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT fk_messages_group_room FOREIGN KEY (group_room_id) REFERENCES public.group_rooms(id) ON DELETE SET NULL;


--
-- Name: video_calls fk_video_calls_initiator; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_calls
    ADD CONSTRAINT fk_video_calls_initiator FOREIGN KEY (initiated_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: video_calls fk_video_calls_room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_calls
    ADD CONSTRAINT fk_video_calls_room FOREIGN KEY (group_room_id) REFERENCES public.group_rooms(id) ON DELETE SET NULL;


--
-- Name: group_room_members group_room_members_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_room_members
    ADD CONSTRAINT group_room_members_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.group_rooms(id) ON DELETE CASCADE;


--
-- Name: group_room_members group_room_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_room_members
    ADD CONSTRAINT group_room_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: group_rooms group_rooms_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_rooms
    ADD CONSTRAINT group_rooms_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: messages messages_receiver_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_receiver_user_id_fkey FOREIGN KEY (receiver_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: messages messages_sender_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_user_id_fkey FOREIGN KEY (sender_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: professor_rooms professor_rooms_professor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professor_rooms
    ADD CONSTRAINT professor_rooms_professor_id_fkey FOREIGN KEY (professor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: video_room_participants video_room_participants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_room_participants
    ADD CONSTRAINT video_room_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: video_room_participants video_room_participants_video_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_room_participants
    ADD CONSTRAINT video_room_participants_video_room_id_fkey FOREIGN KEY (video_room_id) REFERENCES public.video_rooms(id) ON DELETE CASCADE;


--
-- Name: video_rooms video_rooms_host_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_rooms
    ADD CONSTRAINT video_rooms_host_user_id_fkey FOREIGN KEY (host_user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict NDkWz33r0Vu7PRvdWlHICfjlByrxWtu6QuL9IyaIDm2D5JDHkZ9U7qpw1sSjoE4

