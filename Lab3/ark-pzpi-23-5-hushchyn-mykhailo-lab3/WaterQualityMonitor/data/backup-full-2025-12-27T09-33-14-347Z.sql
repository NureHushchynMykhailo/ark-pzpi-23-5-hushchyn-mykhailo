--
-- PostgreSQL database dump
--

\restrict AlcEtR4sYRJ31FiJxvE8DHixpw9anNpzhEj3d6d8g5s8a8fhJqIZbfY3xlWAJPj

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

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

ALTER TABLE IF EXISTS ONLY public.user_stations DROP CONSTRAINT IF EXISTS user_stations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_stations DROP CONSTRAINT IF EXISTS user_stations_station_id_fkey;
ALTER TABLE IF EXISTS ONLY public.telemetry DROP CONSTRAINT IF EXISTS telemetry_sensor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.station_thresholds DROP CONSTRAINT IF EXISTS station_thresholds_station_id_fkey;
ALTER TABLE IF EXISTS ONLY public.station_thresholds DROP CONSTRAINT IF EXISTS station_thresholds_parameter_id_fkey;
ALTER TABLE IF EXISTS ONLY public.sensors DROP CONSTRAINT IF EXISTS sensors_station_id_fkey;
ALTER TABLE IF EXISTS ONLY public.sensors DROP CONSTRAINT IF EXISTS sensors_parameter_id_fkey;
ALTER TABLE IF EXISTS ONLY public.controllers DROP CONSTRAINT IF EXISTS controllers_station_id_fkey;
ALTER TABLE IF EXISTS ONLY public.controller_logs DROP CONSTRAINT IF EXISTS controller_logs_controller_id_fkey;
ALTER TABLE IF EXISTS ONLY public.alerts DROP CONSTRAINT IF EXISTS alerts_station_id_fkey;
DROP INDEX IF EXISTS public.idx_telemetry_sensor_time;
DROP INDEX IF EXISTS public.idx_logs_history;
DROP INDEX IF EXISTS public.idx_alerts_dashboard;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.user_stations DROP CONSTRAINT IF EXISTS user_stations_pkey;
ALTER TABLE IF EXISTS ONLY public.telemetry DROP CONSTRAINT IF EXISTS telemetry_pkey;
ALTER TABLE IF EXISTS ONLY public.stations DROP CONSTRAINT IF EXISTS stations_pkey;
ALTER TABLE IF EXISTS ONLY public.station_thresholds DROP CONSTRAINT IF EXISTS station_thresholds_station_id_parameter_id_key;
ALTER TABLE IF EXISTS ONLY public.station_thresholds DROP CONSTRAINT IF EXISTS station_thresholds_pkey;
ALTER TABLE IF EXISTS ONLY public.sensors DROP CONSTRAINT IF EXISTS sensors_pkey;
ALTER TABLE IF EXISTS ONLY public.parameters DROP CONSTRAINT IF EXISTS parameters_pkey;
ALTER TABLE IF EXISTS ONLY public.parameters DROP CONSTRAINT IF EXISTS parameters_code_key;
ALTER TABLE IF EXISTS ONLY public.controllers DROP CONSTRAINT IF EXISTS controllers_pkey;
ALTER TABLE IF EXISTS ONLY public.controller_logs DROP CONSTRAINT IF EXISTS controller_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.alerts DROP CONSTRAINT IF EXISTS alerts_pkey;
ALTER TABLE IF EXISTS ONLY drizzle.__drizzle_migrations DROP CONSTRAINT IF EXISTS __drizzle_migrations_pkey;
ALTER TABLE IF EXISTS drizzle.__drizzle_migrations ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_stations;
DROP TABLE IF EXISTS public.telemetry;
DROP TABLE IF EXISTS public.stations;
DROP TABLE IF EXISTS public.station_thresholds;
DROP TABLE IF EXISTS public.sensors;
DROP TABLE IF EXISTS public.parameters;
DROP TABLE IF EXISTS public.controllers;
DROP TABLE IF EXISTS public.controller_logs;
DROP TABLE IF EXISTS public.alerts;
DROP SEQUENCE IF EXISTS drizzle.__drizzle_migrations_id_seq;
DROP TABLE IF EXISTS drizzle.__drizzle_migrations;
DROP TYPE IF EXISTS public.user_role;
DROP TYPE IF EXISTS public.station_status;
DROP TYPE IF EXISTS public.sensor_type;
DROP TYPE IF EXISTS public.controller_type;
DROP TYPE IF EXISTS public.alert_type;
DROP TYPE IF EXISTS public.action_type;
DROP SCHEMA IF EXISTS drizzle;
--
-- Name: drizzle; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA drizzle;


ALTER SCHEMA drizzle OWNER TO postgres;

--
-- Name: action_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.action_type AS ENUM (
    'start',
    'stop'
);


ALTER TYPE public.action_type OWNER TO postgres;

--
-- Name: alert_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.alert_type AS ENUM (
    'warning',
    'critical'
);


ALTER TYPE public.alert_type OWNER TO postgres;

--
-- Name: controller_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.controller_type AS ENUM (
    'aerator',
    'filter',
    'pump',
    'dispenser_acid',
    'dispenser_alkali',
    'dispenser_chlorine',
    'valve'
);


ALTER TYPE public.controller_type OWNER TO postgres;

--
-- Name: sensor_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.sensor_type AS ENUM (
    'do_meter',
    'turbidity_meter',
    'pressure_sensor',
    'ph_meter',
    'orp_meter',
    'level_sensor',
    'thermometer'
);


ALTER TYPE public.sensor_type OWNER TO postgres;

--
-- Name: station_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.station_status AS ENUM (
    'active',
    'offline',
    'maintenance'
);


ALTER TYPE public.station_status OWNER TO postgres;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'manager',
    'technician',
    'analyst',
    'viewer'
);


ALTER TYPE public.user_role OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: __drizzle_migrations; Type: TABLE; Schema: drizzle; Owner: postgres
--

CREATE TABLE drizzle.__drizzle_migrations (
    id integer NOT NULL,
    hash text NOT NULL,
    created_at bigint
);


ALTER TABLE drizzle.__drizzle_migrations OWNER TO postgres;

--
-- Name: __drizzle_migrations_id_seq; Type: SEQUENCE; Schema: drizzle; Owner: postgres
--

CREATE SEQUENCE drizzle.__drizzle_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE drizzle.__drizzle_migrations_id_seq OWNER TO postgres;

--
-- Name: __drizzle_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: drizzle; Owner: postgres
--

ALTER SEQUENCE drizzle.__drizzle_migrations_id_seq OWNED BY drizzle.__drizzle_migrations.id;


--
-- Name: alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alerts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    station_id uuid NOT NULL,
    type public.alert_type NOT NULL,
    target_role public.user_role NOT NULL,
    message text NOT NULL,
    is_resolved boolean DEFAULT false,
    resolved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.alerts OWNER TO postgres;

--
-- Name: controller_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.controller_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    controller_id uuid NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    activation_percentage numeric(5,2) NOT NULL,
    status_message text,
    CONSTRAINT chk_logs_percentage CHECK (((activation_percentage >= 0.00) AND (activation_percentage <= 100.00)))
);


ALTER TABLE public.controller_logs OWNER TO postgres;

--
-- Name: controllers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.controllers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    station_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    type public.controller_type NOT NULL,
    is_active boolean DEFAULT false
);


ALTER TABLE public.controllers OWNER TO postgres;

--
-- Name: parameters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parameters (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    unit character varying(20) NOT NULL
);


ALTER TABLE public.parameters OWNER TO postgres;

--
-- Name: sensors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sensors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    station_id uuid NOT NULL,
    parameter_id uuid NOT NULL,
    model character varying(100),
    serial_number character varying(100),
    is_active boolean DEFAULT true,
    type public.sensor_type NOT NULL
);


ALTER TABLE public.sensors OWNER TO postgres;

--
-- Name: station_thresholds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.station_thresholds (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    station_id uuid NOT NULL,
    parameter_id uuid NOT NULL,
    min_warning double precision,
    max_warning double precision,
    min_critical double precision,
    max_critical double precision
);


ALTER TABLE public.station_thresholds OWNER TO postgres;

--
-- Name: stations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    latitude double precision,
    longitude double precision,
    status public.station_status DEFAULT 'active'::public.station_status,
    last_seen timestamp with time zone
);


ALTER TABLE public.stations OWNER TO postgres;

--
-- Name: telemetry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telemetry (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sensor_id uuid NOT NULL,
    measured_at timestamp with time zone DEFAULT now(),
    value double precision NOT NULL
);


ALTER TABLE public.telemetry OWNER TO postgres;

--
-- Name: user_stations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_stations (
    user_id uuid NOT NULL,
    station_id uuid NOT NULL,
    assigned_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_stations OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(100),
    role public.user_role DEFAULT 'viewer'::public.user_role,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: __drizzle_migrations id; Type: DEFAULT; Schema: drizzle; Owner: postgres
--

ALTER TABLE ONLY drizzle.__drizzle_migrations ALTER COLUMN id SET DEFAULT nextval('drizzle.__drizzle_migrations_id_seq'::regclass);


--
-- Data for Name: __drizzle_migrations; Type: TABLE DATA; Schema: drizzle; Owner: postgres
--

COPY drizzle.__drizzle_migrations (id, hash, created_at) FROM stdin;
\.


--
-- Data for Name: alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alerts (id, station_id, type, target_role, message, is_resolved, resolved_at, created_at) FROM stdin;
8ca16f7a-b53a-4fbe-80e4-7b57986e4d79	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	warning	technician	pH level exceeded limit (8.6 > 8.5)	f	\N	2025-12-24 19:48:46.801977+02
96b1bf3a-a262-4c51-928f-8add4a422c0e	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	Pressure reaching limit (4.6 Bar). Check filters.	f	\N	2025-12-25 20:06:00.80723+02
9d757df2-be66-4aae-ba20-603ce68d9f23	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	ph_level CRITICAL LOW: 5	f	\N	2025-12-25 20:27:42.026567+02
459c01ca-b734-44a2-9f6b-290dc97ef953	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	temperature UNSTABLE: Trend -6.75	f	\N	2025-12-26 00:20:16.842184+02
21908492-b05e-4781-9eba-051316259ab4	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	temperature CRITICAL LOW: 3	f	\N	2025-12-26 00:26:41.181939+02
4f945c78-54dc-4e28-963e-c4867be30670	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	temperature UNSTABLE: Trend 15.00	f	\N	2025-12-26 00:28:29.381724+02
69545561-6acd-4dbb-bba8-c43af440e503	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.73	f	\N	2025-12-26 11:16:24.176577+02
3a094d1c-dd1b-41c6-adef-d3458471cef0	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	turbidity UNSTABLE: Trend 0.16	f	\N	2025-12-26 11:16:24.177859+02
ba16999e-06ee-4fe3-9841-036c1266ad2e	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.71	f	\N	2025-12-26 11:17:11.16038+02
896e736c-d8ad-4e25-b76f-8e046596ec19	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	turbidity UNSTABLE: Trend 3.92	f	\N	2025-12-26 11:17:16.349787+02
2abebff8-a3d1-4876-8a00-5900f0dd3445	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.69	f	\N	2025-12-26 11:17:16.350127+02
19690e6f-c51b-4a2c-9bba-9cbf3b936e79	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	turbidity UNSTABLE: Trend 3.94	f	\N	2025-12-26 11:17:21.511124+02
dfebd876-8462-4a72-8d57-ae5efbd69fd1	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.67	f	\N	2025-12-26 11:17:26.38415+02
ef73e5ef-7c07-423c-8381-c379495d1df7	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.65	f	\N	2025-12-26 11:17:54.905987+02
ff244b30-c0c6-4413-a7e5-f3f9367a09d7	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	turbidity UNSTABLE: Trend 3.95	f	\N	2025-12-26 11:17:54.981619+02
e6c63235-4d9d-43fb-8b24-7bdc12196e52	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.64	f	\N	2025-12-26 11:17:59.984571+02
57048645-360e-459b-914e-803779e60c45	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	turbidity UNSTABLE: Trend 3.91	f	\N	2025-12-26 11:17:59.985546+02
88797780-c361-45e8-b257-5778bed7d1b8	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.61	f	\N	2025-12-26 11:18:04.999797+02
fe80105b-7430-473b-b0de-be2baa601e35	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	turbidity UNSTABLE: Trend 3.90	f	\N	2025-12-26 11:18:05.0337+02
6d321f75-7523-493c-86f4-1babf302978a	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.60	f	\N	2025-12-26 11:18:10.072997+02
c36e1bb1-d9d4-4b71-8119-b63942f204df	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	temperature CRITICAL LOW: -1.27	f	\N	2025-12-26 11:18:10.156818+02
45bbf2d6-6203-4380-999e-15fd0261cc13	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.59	f	\N	2025-12-26 11:19:37.153706+02
9d090370-845f-4842-8e36-aae3e85d909c	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	temperature CRITICAL LOW: -1.07	f	\N	2025-12-26 11:19:37.223874+02
d7318220-fb16-478d-98bb-6da2294eea46	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.56	f	\N	2025-12-26 11:19:42.198438+02
f7ca3a28-5e7d-4021-a6fb-0458c955f260	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	temperature CRITICAL LOW: -0.86	f	\N	2025-12-26 11:19:42.230088+02
3573b08e-ec01-45c9-a3f9-8f35b8897034	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.55	f	\N	2025-12-26 11:19:47.506932+02
8dc4bbbf-37f4-4f55-b887-7e23da064254	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	temperature CRITICAL LOW: -0.64	f	\N	2025-12-26 11:19:47.571172+02
0e4b15b6-7c1c-491f-a354-88ad46abba50	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	dissolved_oxygen UNSTABLE: Trend 3.54	f	\N	2025-12-26 11:19:52.416409+02
6e6827f0-6053-469e-afd4-330af604d8c1	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	temperature CRITICAL LOW: -0.44	f	\N	2025-12-26 11:19:52.520361+02
6c9ac0e8-2329-4a25-85a1-6210cfc7985e	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	ph_level CRITICAL HIGH: 26.78	f	\N	2025-12-26 11:20:10.759118+02
81e031cf-8a22-4827-b8bb-67c6c6457630	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	water_level UNSTABLE: Trend 14.61	f	\N	2025-12-26 11:20:15.631057+02
280102a4-2bd2-41f9-bebb-526031599060	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	ph_level CRITICAL HIGH: 26.59	f	\N	2025-12-26 11:20:15.632492+02
573152c8-24c2-4928-9414-35625fdb6ba1	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	water_level UNSTABLE: Trend 14.54	f	\N	2025-12-26 11:20:20.686738+02
102d6a0b-eee3-4546-9f13-9c862c643b60	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	ph_level CRITICAL HIGH: 26.4	f	\N	2025-12-26 11:20:20.68825+02
0f671dba-6e70-4fe0-9a60-b47a7e28c8dd	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	dissolved_oxygen CRITICAL LOW: -17.29	f	\N	2025-12-26 11:20:50.472136+02
c697cc37-dd03-4e25-9e2b-16b34f2e91ff	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	critical	admin	dissolved_oxygen CRITICAL LOW: 0	f	\N	2025-12-26 11:20:55.413074+02
795973d6-5b32-4e7a-89a2-f86861664b18	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	Warning Low: Окислювальний потенціал (ORP) is 572.88 mV (Limit: 600)	f	\N	2025-12-26 12:58:44.722+02
6d9f11b6-0c02-4680-9f6a-17a0d84b4a4a	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	Warning Low: Окислювальний потенціал (ORP) is 575.6 mV (Limit: 600)	f	\N	2025-12-26 12:58:49.561+02
0c75dd9c-55b3-4dfd-8fe9-b07fa3ab6fb3	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	Warning Low: Окислювальний потенціал (ORP) is 578.26 mV (Limit: 600)	f	\N	2025-12-26 12:58:54.736+02
f3e0df21-5faa-4ead-9e53-cd3029cb04ba	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	Warning Low: Окислювальний потенціал (ORP) is 580.83 mV (Limit: 600)	f	\N	2025-12-26 12:58:59.978+02
e56376ab-3da1-4626-bbd9-73635578731b	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	Warning Low: Окислювальний потенціал (ORP) is 583.29 mV (Limit: 600)	f	\N	2025-12-26 12:59:04.912+02
48e3516f-3398-4cd1-821d-1b8b994b355a	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	Warning Low: Окислювальний потенціал (ORP) is 585.68 mV (Limit: 600)	f	\N	2025-12-26 12:59:47.194+02
8e4bda27-3a3b-450f-9d30-04ff2e96ef10	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	warning	technician	Warning Low: Окислювальний потенціал (ORP) is 588.01 mV (Limit: 600)	f	\N	2025-12-26 12:59:51.367+02
\.


--
-- Data for Name: controller_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.controller_logs (id, controller_id, "timestamp", activation_percentage, status_message) FROM stdin;
3c6af04f-dc5e-4557-8eb0-bd893d1d2517	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-25 20:01:00.80723+02	30.00	Maintaining Oxygen
a342dc6b-f752-4d5e-a03a-f2594b5783f5	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-25 19:56:00.80723+02	10.00	Slow Feed
c9792fa7-104b-4772-9f3a-63fa0e40fe5c	b2c3d4e5-f6a7-4000-8000-000000000006	2025-12-25 20:04:00.80723+02	100.00	Valve Open
62ad6a53-a970-4079-90a3-e3da2c2d0832	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-25 20:27:42.013+02	100.00	Auto pH+: LogErr=158.1
2c9c0079-7765-4811-8d59-48184fbe40bb	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-25 20:27:42.018+02	0.00	Interlock
1c0a1453-c7e1-4b43-b1fe-79e0acb73688	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-25 20:27:51.688+02	0.00	Auto pH+: LogErr=15.8
627a785a-9e29-4810-a8d4-642fed3b01ec	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-25 20:27:51.692+02	0.00	Interlock
f2bfe973-697d-49d1-91de-8744dc5a9612	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-25 20:28:09.763+02	0.00	Auto pH+: LogErr=15.8
7cc86576-0f69-43e3-bf85-0c500a1aa48b	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-25 20:28:09.766+02	0.00	Interlock
6243971b-e561-46b7-9725-b7421acb3751	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:08:24.168+02	0.00	pH Stable
79309cd0-f1c0-4abe-8eb1-28a9550f94f6	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:08:24.171+02	0.00	pH Stable
4f973d9f-96b2-4ad7-9e1e-3f1f6754e358	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:09:04.241+02	100.00	Auto pH+: LogFactor=15.8
e5c65dec-0ff7-48d1-a44b-b2a7add5ff9f	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:09:04.243+02	0.00	Standby (pH Low)
f769fb48-4824-4ee5-9cba-89495cc3f30d	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:09:31.571+02	4.81	Auto pH+: LogFactor=6.3
9aaade9f-9842-4e32-8c84-22cabbea5274	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:09:31.574+02	0.00	Standby (pH Low)
bc4bf984-d6c9-4d1c-9ffd-be761d214734	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:09:42.473+02	0.00	Auto pH+: LogFactor=7.9
35862d27-ef20-452e-a2e3-14becbbb2747	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:09:42.475+02	0.00	Standby (pH Low)
beeda442-0fa9-42ff-8985-bb4140384123	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:10:02.035+02	0.00	Auto pH+: LogFactor=12.6
338388b6-caef-44bc-b574-8319e90d3aa4	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:10:02.038+02	0.00	Standby (pH Low)
0123f5e1-8ee5-42ff-8a09-e08525fe9c54	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:10:22.464+02	100.00	Auto pH+: LogFactor=15.8
59057209-79d7-46d7-a8d0-65592052998f	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:10:22.466+02	0.00	Standby (pH Low)
d3dfad44-9de2-4b19-9ff3-cb78f06f5b7c	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:10:39.354+02	86.55	Auto pH+: LogFactor=10.0
cd3b2d1d-e691-4b16-abda-d9bdc1e87dcb	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:10:39.357+02	0.00	Standby (pH Low)
3e6f07b4-3c9d-4f99-ab53-cfd4e3c9cc12	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:10:50.94+02	94.62	Auto pH+: LogFactor=7.9
66b5df12-f5ab-4d94-b065-8f3830d94b4e	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:10:50.944+02	0.00	Standby (pH Low)
715dfd91-739d-4fe7-8ec3-e04b41b23a05	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:11:00.808+02	79.81	Auto pH+: LogFactor=6.3
e370d660-5d37-4fc9-8b4c-5e0a36af69e3	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:11:00.812+02	0.00	Standby (pH Low)
25b0d774-1268-4c5f-8ce8-756ae4d46acb	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:11:14.61+02	0.00	pH Stable
cafc7ded-c5ec-46f2-ac1f-dbed130fd441	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:11:14.614+02	0.00	pH Stable
c9e99eb1-0473-457e-9e61-a2cf951f81b2	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:11:32.356+02	0.00	pH Stable
cfd92366-a9c8-4ece-951a-ef706c4199a0	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:11:32.358+02	0.00	pH Stable
51c5f557-265c-4032-8292-6dfb4bef2235	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:11:50.118+02	0.00	pH Stable
58ba8d60-6e57-4ee0-b05d-3c3ef7500520	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:11:50.122+02	0.00	pH Stable
46b3df52-555d-4ed5-8765-e45fd6313e38	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:12:00.778+02	100.00	Auto pH-: LogFactor=50.0
ca46de37-c1cd-45a9-a1bc-2fc54051e8f8	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:12:00.78+02	0.00	Standby (pH High)
25543654-9cf0-4c22-8dd7-9cdbee62c157	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:18:09.555+02	0.00	Auto pH-: LogFactor=7.9
6dc610fc-33e2-401a-b778-b90290e6161c	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:18:09.559+02	0.00	Standby (pH High)
9b06da16-3c60-4aa7-90b7-dc5ce08790d5	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:18:29.345+02	100.00	Auto pH-: LogFactor=7.9
2f685ab3-2a5f-4a5f-97ff-778f4c690849	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:18:29.35+02	0.00	Standby (pH High)
0f0a7482-7665-4697-9026-229e776b2a44	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:18:54.179+02	79.81	Auto pH-: LogFactor=6.3
5162932d-df3c-495c-9e7c-d861893db709	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:18:54.183+02	0.00	Standby (pH High)
996c4f0e-7fc5-4130-8834-833498e4f577	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:19:02.902+02	100.00	Auto pH-: LogFactor=6.3
219aa79e-f50f-4a80-9c09-d41b39167a2b	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:19:02.904+02	0.00	Standby (pH High)
a6a617c2-2955-4c06-9497-cad96fb7c113	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:19:12.222+02	0.00	pH Stable
3ddea2c4-ce4d-44f2-9c4a-f576889e77be	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:19:12.224+02	0.00	pH Stable
8925b78f-40f1-4c6e-88ca-e61d28b89560	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 00:19:16.995+02	98.05	Auto pH-: LogFactor=5.6
9f965850-aebe-4154-9e50-d37f25c4e4f4	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 00:19:16.997+02	0.00	Standby (pH High)
23529cac-3db3-4016-ad2e-a30bf6547b1e	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 00:29:41.057+02	100.00	Auto ORP: Deficit=60, pH-Eff=0.3
cc5f37a8-41bc-42b8-a436-018a03115ab5	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 00:30:24.2+02	21.25	Auto PID: Target=6.5, Err=0.50
d82aa021-05e6-4cd5-8eda-14c571b24950	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:13:32.34+02	0.00	Auto: DO Optimal
a80db1a7-9da3-415c-a824-6d16a2c2cc48	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:32.425+02	0.00	Standby
8839b474-914d-4c7e-bf95-4f203049e7a4	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:13:32.425+02	50.63	Auto ORP: Deficit=75.95000000000005, pH-Eff=1
ea69c870-395a-48f9-a148-bdd1a128334d	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:32.426+02	0.00	Standby
f869931d-eeb3-4e79-9f22-146f1cab2b82	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:13:32.523+02	0.00	pH Stable
ea17ab78-0220-4cc5-a8ab-3466cc783d28	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:13:32.525+02	0.00	pH Stable
5a95f85d-6f3b-4b11-a749-2115e4d46311	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:13:37.321+02	0.00	Auto: DO Optimal
10fd49a3-34f7-449f-8b1d-fa4b89d11d14	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:37.337+02	0.00	Standby
def96ffd-d520-4f20-8ed7-c1345d2f2066	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:37.337+02	0.00	Standby
3f5dcf57-9c46-402c-b838-6a57d8f92b8a	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:13:37.338+02	0.00	pH Stable
0b33d416-ebb5-42bc-9efb-ab657a5a2f09	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:13:37.34+02	0.00	pH Stable
ac8f0406-078d-4387-b610-39d6fa257670	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:13:37.339+02	51.97	Auto ORP: Deficit=77.95000000000005, pH-Eff=1
ec5699b3-06f0-4559-9e33-0d9839135dc7	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:13:42.323+02	0.00	Auto: DO Optimal
9cae7a31-d8a1-484a-b2bd-bbecc67be006	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:13:42.346+02	0.00	pH Stable
55b7dedd-1959-4f07-a503-2e5c06d763f5	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:13:42.352+02	0.00	pH Stable
51525c60-10bf-4b91-a2f3-6c084214d8ea	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:42.352+02	0.00	Standby
ecd6f2d7-8967-4226-b676-7cb867285738	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:42.353+02	0.00	Standby
3d1f1f2b-3023-4dfe-81e8-0e5eba61bc2b	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:13:42.354+02	53.29	Auto ORP: Deficit=79.92999999999995, pH-Eff=1
b08eb35c-3c14-437e-bb6f-591bd8100772	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:13:47.324+02	0.00	Auto: DO Optimal
c1b1d956-030f-48f9-b278-dfc9aa5bf5d0	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:13:47.348+02	0.00	pH Stable
2d9ca0c9-05c1-43fd-905e-ac3bad161d07	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:13:47.351+02	0.00	pH Stable
4efa395f-d950-443e-ae68-dbb605bce0c9	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:47.353+02	0.00	Standby
4d6d7762-f43a-446f-9456-7bdaa55af9b4	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:13:47.354+02	54.61	Auto ORP: Deficit=81.91999999999996, pH-Eff=1
7e4bcef7-75b0-498c-aec0-bcf6a8fffb9d	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:47.354+02	0.00	Standby
e7379b37-059f-4745-b61f-99f4d47350a4	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:13:52.414+02	0.00	Auto: DO Optimal
6c538543-b626-4df9-ac74-ff0c02aba81e	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:52.414+02	0.00	Standby
b39beb78-8c30-4395-9050-87c603c25cfc	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:52.415+02	0.00	Standby
37f65bb0-3f0a-43c1-97d7-d038c4cba2c1	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:13:52.415+02	55.94	Auto ORP: Deficit=83.90999999999997, pH-Eff=1
3d4097b2-d0ed-4a0a-9945-f30ae226de7f	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:13:52.416+02	0.00	pH Stable
2b75499a-10b0-4f65-af46-081293dc42df	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:13:52.417+02	0.00	pH Stable
6bd0c021-816b-44a2-9170-6a323a496dcc	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:13:57.318+02	0.00	Auto: DO Optimal
192d6e60-c957-4aa0-96b9-fd4bb6eb5b25	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:13:57.367+02	0.00	pH Stable
8a1e973a-6ea6-4c89-9aca-b3ba97074c6e	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:57.368+02	0.00	Standby
7a4dc976-082e-438c-8dc8-1eb1074cc68a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:13:57.369+02	0.00	Standby
2deb6828-1e9b-4d6e-a8c5-662f32cbe0ff	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:13:57.369+02	57.27	Auto ORP: Deficit=85.89999999999998, pH-Eff=1
ce4f648a-7fc0-4902-9bb8-df67aecfdb67	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:13:57.369+02	0.00	pH Stable
5f67f4ca-1b49-4d9b-b641-3eb106901edd	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:02.335+02	0.00	Auto: DO Optimal
e38304f3-8325-4c5d-9181-efb7ff006048	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:02.375+02	0.00	pH Stable
4d9a06a0-6413-4f8e-b2d4-34800cdb1e03	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:02.377+02	0.00	pH Stable
e7be221d-5532-41f5-b0ec-d350e2334a52	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:02.377+02	0.00	Standby
e43a944c-9059-411f-967c-71c971552dae	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:07.434+02	59.93	Auto ORP: Deficit=89.88999999999999, pH-Eff=1
b228d149-7c64-4024-9d47-133ef5845d8c	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:12.423+02	61.26	Auto ORP: Deficit=91.88999999999999, pH-Eff=1
db869add-e79d-4b3a-9913-b1291208a27e	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:17.422+02	62.59	Auto ORP: Deficit=93.88999999999999, pH-Eff=1
6b2f6f1e-7b7b-4cab-a5ce-ddda15fd191e	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:02.378+02	58.60	Auto ORP: Deficit=87.89999999999998, pH-Eff=1
2546f05e-d7cb-4dc1-8bb8-f231d785c639	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:07.432+02	0.00	Auto: DO Optimal
6c8619bc-4ce1-414d-9d77-dc6a719396fc	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:07.432+02	0.00	Standby
fb0cab26-c505-4f62-85e5-e2bbe2515912	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:12.422+02	0.00	Standby
15739356-66cd-48e9-9ebe-3fa5523252b6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:17.422+02	0.00	Standby
ae412fbc-8321-44db-9d6c-c6289e1565a7	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:07.877+02	81.22	Auto ORP: Deficit=121.83000000000004, pH-Eff=1
e7119342-4eba-4a0e-85ef-e0fdf96dbabe	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:12.953+02	0.00	Auto PID: Target=6.0, Err=-0.69
87f37dcb-115d-41c4-8115-44d683cce1a3	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:12.955+02	0.00	Standby
5eb7cc37-4a5c-41a8-be31-b5240747f8c7	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:12.957+02	82.55	Auto ORP: Deficit=123.83000000000004, pH-Eff=1
be6b4acc-6326-4dc0-8149-cc9b326976c1	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:12.957+02	0.00	pH Stable
de6a2d8f-f314-404f-beae-bc061ebbfce3	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:12.957+02	0.00	Standby
6d623245-a4f1-4287-963f-c89cc763da4b	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:12.958+02	0.00	pH Stable
5d1d01d6-cf43-4453-8119-6e6c3d581f70	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:17.93+02	0.00	Auto PID: Target=6.0, Err=-0.67
45be8c0b-b03d-4309-bcce-34fb83a22a0d	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:17.931+02	0.00	Standby
3feca1ab-7396-4b1b-b63c-5c4c91bf8fec	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:17.931+02	0.00	Standby
da6a9dfd-ad6f-4e99-a845-5ea2eb6dec93	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:17.932+02	83.88	Auto ORP: Deficit=125.82000000000005, pH-Eff=1
fe5ab128-70f0-4319-acd2-dd713ef94553	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:17.932+02	0.00	pH Stable
a2b1bf49-4d4a-4f3a-b7e2-1a80f2ce36de	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:17.933+02	0.00	pH Stable
45cbc8b0-3ded-454e-b1c0-5d3dc5e4fe5a	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:22.942+02	0.00	Auto PID: Target=6.0, Err=-0.64
9c758d3a-1649-414f-82da-383cbd22c8c4	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:22.945+02	0.00	Standby
e8de9f1a-43cc-4a90-9032-38e017ace8f6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:22.945+02	0.00	Standby
9f9d1d0e-3d35-48ce-9608-ebbb909538a9	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:22.945+02	85.21	Auto ORP: Deficit=127.82000000000005, pH-Eff=1
33580c73-ba74-4dca-a76f-975f6a64e5c2	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:22.945+02	0.00	pH Stable
b5ad39f9-10bc-41a6-8986-b1d444423c2c	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:22.948+02	0.00	pH Stable
e63dfce0-cba6-41b5-aaa5-d4a62e57fe34	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:27.931+02	0.00	Auto PID: Target=6.0, Err=-0.63
a038165d-b509-4996-88a0-70841f1dd21a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:27.931+02	0.00	Standby
859aa2ce-e8b2-4564-8561-d74a900454a2	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:27.933+02	0.00	pH Stable
649ea742-9cf1-4310-afc6-e38423e64fa3	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:27.934+02	86.55	Auto ORP: Deficit=129.82000000000005, pH-Eff=1
f617ed82-714e-4411-9cda-4c5fcc95d304	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:27.932+02	0.00	Standby
5db042c0-8282-47f1-9f95-14ce38710904	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:27.936+02	0.00	pH Stable
a3f4ddf5-f96b-45ba-88e2-4f31af7715eb	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:32.899+02	0.00	Auto PID: Target=6.0, Err=-0.61
c1b86db3-c1c1-4c40-a42c-70483e514d1c	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:32.946+02	0.00	pH Stable
6b4375d8-4efc-4ae3-824b-ebf9866b1bb3	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:32.947+02	0.00	pH Stable
7b254efa-8311-4cc5-ab70-e5da35b238d6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:32.947+02	0.00	Standby
62d6c52b-925b-4076-a308-d603f98d2356	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:32.947+02	0.00	Standby
106ad870-7ce5-4014-8d17-ee533a673d62	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:32.947+02	87.88	Auto ORP: Deficit=131.82000000000005, pH-Eff=1
cb248657-07bc-4095-9c29-fbdfebfb9c2b	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:37.976+02	0.00	Auto PID: Target=6.0, Err=-0.59
25207b87-4bf7-4fbb-8360-43cb09687be3	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:38.089+02	0.00	pH Stable
d7f734e6-788d-4cfa-9a42-75219f80e0d4	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:38.09+02	89.21	Auto ORP: Deficit=133.82000000000005, pH-Eff=1
17ee53cf-1c94-4d1a-8595-13c696ec316d	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:38.092+02	0.00	pH Stable
8210bd20-d5df-4a01-a160-72e22e104357	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:38.093+02	0.00	Standby
91b836d1-dfd2-4eaf-9ec4-7ca3ff806827	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:38.093+02	0.00	Standby
4d3217d2-166a-4192-95c7-02d6b994f7e0	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:42.971+02	0.00	Auto PID: Target=6.0, Err=-0.58
3f42322a-4e98-407f-b2fb-a9ea4b54d081	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:42.972+02	0.00	Standby
46208678-65cc-419e-8b3a-3011e93e33bb	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:42.972+02	0.00	Standby
fa0f8721-f703-4752-946b-38757e4f5adc	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:42.973+02	0.00	pH Stable
afd3e0e1-e6b7-4551-85d7-afbc1c210850	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:42.974+02	90.55	Auto ORP: Deficit=135.82000000000005, pH-Eff=1
3f2cb302-607c-4e8e-b71b-071a46d93a19	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:42.976+02	0.00	pH Stable
bceb356e-74ff-431d-85c6-f779ad9fdaad	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:47.934+02	0.00	Auto PID: Target=6.0, Err=-0.57
ab9d67e9-cc2a-41f5-9550-8f32e87987ca	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:47.977+02	0.00	pH Stable
23794ffa-f57c-4c22-8977-eb0a25d2e8f6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:47.978+02	0.00	Standby
48491532-4344-4148-86a5-47d925fbb315	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:47.979+02	0.00	Standby
4b9b7b55-d60b-4ad8-ad71-bd6b372124ff	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:47.979+02	0.00	pH Stable
c173147e-9b10-4d57-970a-f3fba1498902	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:47.979+02	91.88	Auto ORP: Deficit=137.82000000000005, pH-Eff=1
e78b5b38-719d-41a8-a3ed-a85edca0a2af	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:52.971+02	0.00	Auto PID: Target=6.0, Err=-0.55
ff7fe4b0-33cd-43d3-810d-f03e640f77cf	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:53.028+02	0.00	pH Stable
39739dc0-3895-47c8-bfdd-4c9fc4ff1b59	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:53.028+02	0.00	Standby
f15dc50e-176f-418c-9d48-4bb415b8086a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:53.029+02	0.00	Standby
16334843-722a-494f-aa17-fcf070d08b26	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:53.029+02	93.21	Auto ORP: Deficit=139.80999999999995, pH-Eff=1
9b1a97a4-a745-4056-8849-58cece3cf89f	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:53.029+02	0.00	pH Stable
8600caa2-73ee-4d5e-8d56-9dbc428e5684	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:56.829+02	0.00	Auto PID: Target=6.0, Err=-0.54
a32ab2d2-f0cf-42d2-8236-2623180b488f	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:56.83+02	0.00	Standby
d47ebbfe-241e-4cc5-9508-80541ca7e2b7	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:56.831+02	0.00	Standby
47042766-e8e2-4767-bb2f-a27e3ac98401	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:56.831+02	0.00	pH Stable
43747c80-25be-4d1b-8de9-db2c6daa774e	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:56.832+02	94.54	Auto ORP: Deficit=141.80999999999995, pH-Eff=1
d64a957d-71bf-461f-bc9e-f2bb17491c03	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:56.834+02	0.00	pH Stable
c630b326-d43a-4133-b6ee-2205dd36ef84	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:33:14.019+02	0.00	Auto PID: Target=6.0, Err=-0.51
d1e0f89b-8473-4527-82c7-cbfc0d42c826	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:33:14.083+02	0.00	pH Stable
c62b81d2-2f8a-45f0-bdf2-1e8437368360	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:33:14.085+02	0.00	pH Stable
e2a9fa18-06e2-428c-b43f-ea146eece102	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:33:14.156+02	96.03	Auto ORP: Deficit=144.04999999999995, pH-Eff=1
df4997a7-f7d3-4326-874c-ca6ca69a9145	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:14.159+02	0.00	Standby
094896c8-4d17-4a52-829c-3e7f10413131	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:14.163+02	0.00	Standby
b07bcb5a-5086-4e71-a187-4a6c52f77423	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:19.221+02	0.00	Standby
0bc50f21-5535-44cb-95ee-c37af0de7976	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:33:19.221+02	96.53	Auto ORP: Deficit=144.79999999999995, pH-Eff=1
44ef63c2-1014-434c-a78a-9688d2b36684	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:33:19.221+02	0.00	Auto PID: Target=6.0, Err=-0.49
0f7bbfb6-7bf4-4c10-bb2f-34c7e634c27b	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:19.222+02	0.00	Standby
a3846590-e33b-46ee-a8f8-92f644056958	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:33:19.223+02	0.00	pH Stable
aa576c6a-8b93-4194-85a4-41d41ca0d723	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:33:19.225+02	0.00	pH Stable
80e56304-3c91-458e-b0e3-5365d38d68ca	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:24.115+02	0.00	Standby
a9e0f146-54fe-4e35-badf-05c7a8a40c63	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:24.115+02	0.00	Standby
f02ca1b9-6655-4f16-8850-633872e8ce38	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:33:24.115+02	0.00	pH Stable
02d02f6a-428d-402e-aa33-24779254543b	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:33:24.114+02	0.00	Auto PID: Target=6.0, Err=-0.47
f4483411-3880-4093-b33f-77933c3da375	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:33:24.115+02	97.03	Auto ORP: Deficit=145.54999999999995, pH-Eff=1
8ea9c929-8e98-456e-bf51-5eccc4d99e16	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:33:24.116+02	0.00	pH Stable
71dd934f-9701-4ecb-abfb-245d1e1213d1	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:33:29.08+02	0.00	Auto PID: Target=6.0, Err=-0.45
726e590d-2b88-4eca-9f64-4b5eb4c27773	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:33:29.137+02	0.00	pH Stable
904e554b-b757-4da0-98eb-6b928e6defcb	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:02.377+02	0.00	Standby
4ff54056-ae99-4ef1-9ce1-edac10fc2124	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:07.433+02	0.00	pH Stable
4a176ca5-0b9f-418f-a30e-5d52ab9f3a91	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:07.435+02	0.00	pH Stable
3db71703-686f-4cb6-b304-712048b5e904	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:12.423+02	0.00	pH Stable
94e034be-6e1f-413f-a489-b3f9cbf4b6d7	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:12.425+02	0.00	pH Stable
8b7379cb-27bf-4256-bbe7-d5b5e54cc070	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:17.376+02	0.00	Auto PID: Target=6.0, Err=-1.00
c43d8082-5339-453f-aa3a-49e59851d309	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:17.418+02	0.00	pH Stable
dfac7edc-2e70-42d5-8ebe-f8ac2922ebdd	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:17.42+02	0.00	pH Stable
6d1697e6-d4da-431f-b1cd-dc4b0ab22837	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:07.432+02	0.00	Standby
4ace736e-ae27-4920-b490-368166b81a76	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:12.414+02	0.00	Auto: DO Optimal
46e22577-b1fc-47ad-b743-8341d4715599	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:12.422+02	0.00	Standby
1b3ab36a-13e9-4ad2-9e35-7a3dec6ebab7	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:17.422+02	0.00	Standby
11b41ea3-b1b8-4333-97fa-90385740d898	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:22.384+02	0.00	Auto PID: Target=6.0, Err=-0.98
d98a7c30-4adc-46df-a6f8-cc116b580508	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:22.53+02	0.00	pH Stable
356b4dfd-626b-485a-8d60-217762e1a6f9	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:22.536+02	0.00	pH Stable
4d4c660c-e1bb-44d0-98dd-fc2140355caf	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:22.538+02	0.00	Standby
f135c171-6c53-4b51-9a1b-34862eb8d889	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:22.539+02	0.00	Standby
22e0fb55-cddb-4d1c-8b9f-eccc78db9866	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:22.539+02	63.92	Auto ORP: Deficit=95.88, pH-Eff=1
b203694c-7782-483f-8f80-6cad6c9c5068	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:27.403+02	0.00	Auto PID: Target=6.0, Err=-0.95
e52fb605-9403-4f54-a8c3-1f3c8a22e264	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:27.415+02	0.00	Standby
446f477d-f36d-4df9-a760-180eb76d4d95	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:27.415+02	0.00	pH Stable
d25ee769-9406-4fb3-8dc8-dbd41dfa9898	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:27.416+02	65.25	Auto ORP: Deficit=97.88, pH-Eff=1
12ef138e-38b0-40b4-a678-4845b0d134fe	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:27.415+02	0.00	Standby
b08d6960-5e55-4807-95a7-f3e58824574b	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:27.416+02	0.00	pH Stable
04976d4b-7031-4c2b-8954-fcfe789cd237	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:32.447+02	0.00	Auto PID: Target=6.0, Err=-0.92
3627d264-8878-459a-ab8f-be6314c4d6c1	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:32.447+02	0.00	Standby
f02e214e-4e24-48d6-9638-c6a9129264a0	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:32.449+02	0.00	Standby
1bf14aaa-011a-42bf-bf3e-431e569d4e2c	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:32.449+02	0.00	pH Stable
f660959c-d31a-4134-993f-ecd256a89387	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:32.449+02	66.59	Auto ORP: Deficit=99.88, pH-Eff=1
93a2f475-7402-4220-9b43-79d8097c0ec4	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:32.451+02	0.00	pH Stable
ea9c89ec-5e6d-4f90-be56-44c113305c56	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:37.398+02	0.00	Auto PID: Target=6.0, Err=-0.90
290c9e53-4622-45b1-9f2b-76f057a31409	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:37.426+02	0.00	pH Stable
3848385b-3612-439d-bdc0-92178b58920a	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:37.428+02	0.00	pH Stable
d3d74bb2-4433-4f34-820b-76bac9069e36	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:37.428+02	0.00	Standby
a7a6c275-d129-4c2e-9c73-73e3c8cf0207	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:37.429+02	0.00	Standby
49386143-8d75-40ad-bd6c-387a9b31f656	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:37.429+02	67.92	Auto ORP: Deficit=101.88, pH-Eff=1
0163fc65-9f74-4e4e-b878-993c9bc37aed	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:42.392+02	0.00	Auto PID: Target=6.0, Err=-0.88
f0feb9e6-9980-4bf8-bb8a-e61704ae5dd2	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:42.439+02	0.00	pH Stable
0b35f06c-e6e9-4a48-bd7b-3c86813d6db7	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:42.44+02	0.00	Standby
38c08b99-a127-4be0-9eef-797ce271aec8	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:42.44+02	0.00	Standby
e15453c9-7e36-4ece-a17f-12f1700a0a37	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:42.44+02	0.00	pH Stable
7b4c8c77-5fe2-4ce4-a439-42e8e5b1e59d	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:42.441+02	69.25	Auto ORP: Deficit=103.88, pH-Eff=1
7a2bac0a-b97f-4e51-9d1f-4ef688083dcb	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:47.434+02	0.00	Standby
9ede05b8-06d8-41c7-93a1-2f0ace0c6398	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:47.434+02	0.00	Auto PID: Target=6.0, Err=-0.87
df2db8ad-dc26-40ac-99fc-b348ec7e35f3	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:47.434+02	0.00	Standby
98907133-bd8e-44f7-9b36-bbaf0642f64a	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:47.435+02	0.00	pH Stable
3997f184-71ab-42ce-bcd6-963dadd5c886	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:47.435+02	70.59	Auto ORP: Deficit=105.88, pH-Eff=1
a13b0d48-c66d-4628-adea-2585a822181f	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:47.436+02	0.00	pH Stable
8f5c1e31-976e-44e0-9f1e-14a34cd671c1	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:52.42+02	0.00	Auto PID: Target=6.0, Err=-0.86
447a635f-048a-442c-ac9f-a47c23e31882	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:52.448+02	0.00	pH Stable
9cf5246a-2216-4e10-b002-d89edcb148a3	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:52.45+02	0.00	pH Stable
bf12cf7d-d73b-4b62-aef2-4c76d0ca63ab	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:52.451+02	0.00	Standby
cf92e2dc-6387-40ae-a410-f19af943950a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:52.451+02	0.00	Standby
83cd6080-c1f0-4a36-a6f7-0bf309c653db	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:52.451+02	71.92	Auto ORP: Deficit=107.88, pH-Eff=1
33ac4558-a09b-40af-a9d5-1950e18a97ff	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:14:57.422+02	0.00	Auto PID: Target=6.0, Err=-0.85
7b38c7b0-c914-4646-8aa0-edfc60a3f572	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:14:57.483+02	0.00	pH Stable
aa396f81-6beb-4315-a71f-26ec92a40765	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:57.484+02	0.00	Standby
a30bcabf-1cd0-4ecc-84e6-b47882466922	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:14:57.485+02	0.00	Standby
879a3a7d-2e4c-44ac-a623-b4c6a64c6c8b	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:14:57.485+02	0.00	pH Stable
185437a6-41fc-4269-9dcc-65146443c236	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:14:57.485+02	73.25	Auto ORP: Deficit=109.87, pH-Eff=1
861da78f-16b5-4e84-83f7-0c725ff8fd29	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:27:42.786+02	0.00	Auto PID: Target=6.0, Err=-0.82
42137bc7-ed21-4d23-93ab-2392277a76ce	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:27:42.812+02	0.00	pH Stable
d4a276d7-b676-40e3-90d5-4bc209283ad7	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:27:42.814+02	0.00	pH Stable
441f22dc-7d14-4dc6-857a-274f7cd73293	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:27:42.893+02	75.91	Auto ORP: Deficit=113.87, pH-Eff=1
af892b62-e49a-4d4b-8fea-a4009a1589b1	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:27:42.895+02	0.00	Standby
a0c171b7-11fd-4e6d-b6a3-3ef6d0d67966	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:27:42.897+02	0.00	Standby
be796faa-540f-4aa5-a5f6-4f8b2dbdbc16	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:27:47.921+02	0.00	Standby
37e8a6f6-106d-450f-bdf4-827321818ba3	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:27:47.921+02	0.00	Standby
13e13197-f5a6-401e-8fc6-d2f92bce94dc	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:27:47.921+02	0.00	Auto PID: Target=6.0, Err=-0.80
2e87c403-c0dc-4edb-aef3-86a3766a7837	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:27:47.923+02	76.58	Auto ORP: Deficit=114.87, pH-Eff=1
dfed4307-a5cc-46d3-bfbf-82437a18afe3	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:27:47.922+02	0.00	pH Stable
db6872ad-c0f7-49e2-b177-8eb2193e016c	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:27:47.924+02	0.00	pH Stable
ea24938e-1d75-4c77-88e7-2214adaf8b27	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:27:52.827+02	0.00	Auto PID: Target=6.0, Err=-0.79
790d55c7-055b-4426-92ee-7d4a3484280e	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:27:52.865+02	0.00	pH Stable
3c4c47cc-12d8-4785-8f24-312fadebe153	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:27:52.866+02	0.00	pH Stable
18f22384-19de-409c-b8dc-685ba59ec150	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:27:52.867+02	0.00	Standby
18eeb8c4-293e-4577-b2b1-6a9beeac1e72	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:27:52.867+02	0.00	Standby
ab111536-3c3a-4fb4-8ecb-f5558b0b7a9e	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:27:52.867+02	77.24	Auto ORP: Deficit=115.86000000000001, pH-Eff=1
06500451-49fc-48d0-8b16-e16e67de37e4	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:27:57.898+02	0.00	Auto PID: Target=6.0, Err=-0.76
ea63b1e3-55f6-44ce-b272-34c94023d07e	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:27:57.898+02	0.00	pH Stable
aefa6f13-8314-42d2-b0bb-2eafecaf6279	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:27:57.899+02	0.00	Standby
f1e36191-68c4-4c8e-9c67-b432d235aad6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:27:57.899+02	0.00	Standby
f6a99260-29b2-465b-b2de-b876e0ecef92	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:27:57.9+02	78.57	Auto ORP: Deficit=117.85000000000002, pH-Eff=1
f6d36914-b793-4e88-bd69-31dba141e58c	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:27:57.9+02	0.00	pH Stable
5fdac88a-b46d-47ec-8f3a-c9811750c4af	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:02.875+02	0.00	Standby
96976afa-3919-4165-ab8b-576cbf038e7c	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:02.875+02	0.00	pH Stable
ce8554e1-d50a-4679-829d-c845c3efd396	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:02.876+02	0.00	Auto PID: Target=6.0, Err=-0.73
2f88b26d-2034-4431-8bc2-31ba3bded3fc	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:28:02.878+02	79.89	Auto ORP: Deficit=119.84000000000003, pH-Eff=1
5eed949d-e0b5-4b15-ab64-a6fcdad90767	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:02.878+02	0.00	Standby
d45d0a8d-20eb-402b-8d97-340c1df49ba1	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:02.878+02	0.00	pH Stable
c527214a-5e79-4149-8487-e8ef4b36b664	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:28:07.836+02	0.00	Auto PID: Target=6.0, Err=-0.71
9aa857b4-d999-4c44-a6c6-236967145f25	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:28:07.874+02	0.00	pH Stable
74e0a06e-e42b-48fc-b8a1-9f43adc49adf	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:28:07.876+02	0.00	pH Stable
d96ff85c-bcc9-4a69-b94a-99089773ad50	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:07.877+02	0.00	Standby
99cf895f-c5aa-420a-8e43-f332dd025bf6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:28:07.877+02	0.00	Standby
cb3ca706-5dee-4159-9f1e-bda6366d76c3	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:33:29.138+02	0.00	pH Stable
2e72a60f-4702-4e50-ab3c-5128e8e248d9	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:39.21+02	0.00	Standby
0cfd95ff-6e4e-4746-9e4e-5d20e66ff25b	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:29.14+02	0.00	Standby
ec7330ad-0d2d-4265-ae1f-d068a256b7e1	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:34.137+02	0.00	Standby
3aafd76d-a765-46ba-a241-834cbc542da5	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:33:39.212+02	99.53	Auto ORP: Deficit=149.28999999999996, pH-Eff=1
018f412a-d914-455c-ae4a-45d76c40f939	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:29.14+02	0.00	Standby
1c95dfcb-71e3-42aa-b836-14cf5a084663	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:33:34.137+02	98.53	Auto ORP: Deficit=147.78999999999996, pH-Eff=1
b87918b4-66bf-4247-a2d2-ea6e4fc6d1e2	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:33:39.208+02	0.00	Auto PID: Target=6.0, Err=-0.39
aa148034-deef-40c5-b7d9-523b9c650060	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:33:29.14+02	97.53	Auto ORP: Deficit=146.29999999999995, pH-Eff=1
b5f80b09-375c-4da7-a5e8-8bbb267f382f	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:33:34.068+02	0.00	Auto PID: Target=6.0, Err=-0.42
5757c30a-a2d7-45bf-a24d-c95c5ff7428c	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:33:34.134+02	0.00	pH Stable
a75ba819-0971-499a-881a-5cb50e0105d9	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:33:34.136+02	0.00	pH Stable
1e93904f-e3ad-4965-98bb-0a04c3b6ecc0	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:39.211+02	0.00	Standby
ea58384e-6245-4b01-aeb9-7e24ba353bd6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:33:34.137+02	0.00	Standby
d97618d9-fd0c-4bd5-b74b-ea44aa849a5f	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:33:39.211+02	0.00	pH Stable
7ea43876-349e-4bd2-885d-8bb9b47925c9	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:33:39.214+02	0.00	pH Stable
e786a917-e5cc-4806-9719-f0c7efcb5e09	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:34:23.994+02	0.00	Auto PID: Target=6.0, Err=-0.50
05cd6c88-916c-42ef-9c66-932ebf759176	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:34:24.065+02	0.00	pH Stable
2dbd3a82-e2d6-42f7-bd4c-f22c0fdcf69d	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:34:24.067+02	0.00	pH Stable
3621abbf-4dee-4e1a-b630-9743cd1590d5	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:34:24.073+02	0.00	Standby
94c8953f-6d9a-4cca-a9f4-42685002c9c6	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:34:24.074+02	92.22	Auto ORP: Deficit=138.33000000000004, pH-Eff=1
52ac4cbc-5670-4e96-8bd4-f4928b163697	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:34:24.078+02	0.00	Standby
125176a6-eb26-4724-80f4-76b28a2fe6f1	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:34:28.986+02	0.00	Auto PID: Target=6.0, Err=-0.49
15488f99-58e4-48aa-8077-b069ba5fb017	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:34:28.995+02	0.00	Standby
6dc5fa27-2020-4ce9-982d-ebfb8848bacf	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:34:28.996+02	0.00	Standby
99fb88c9-4362-4d8a-8131-00f057249f7f	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:34:28.996+02	0.00	pH Stable
a525d12d-a181-4e81-80a0-a64575507345	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:34:28.998+02	0.00	pH Stable
c0aedb66-b1fc-4303-a9be-403dd287999b	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:34:28.997+02	91.18	Auto ORP: Deficit=136.76999999999998, pH-Eff=1
d6a50f42-3380-4626-8a33-9e5b8bd116e1	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:37:31.725+02	0.00	Auto PID: Target=6.0, Err=-0.49
4a4cac99-8404-46b7-a79a-67e0fd035d23	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:37:31.788+02	0.00	pH Stable
731cb5eb-ae2c-4e2e-b9c8-e87811153b09	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:31.79+02	0.00	Standby
d1c19c5c-cc33-43ff-b9a3-ce5ca59a55af	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:37:31.791+02	0.00	pH Stable
2914dc0c-405c-4773-9ed8-987b562a1e2d	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:37:31.794+02	92.50	Auto ORP: Deficit=138.75, pH-Eff=1
4231e6a9-7eb9-4d5b-af16-40aa2efe29cd	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:31.797+02	0.00	Standby
b4840c27-fc49-40a9-8388-4853a4de97e7	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:37:36.714+02	0.00	Auto PID: Target=6.0, Err=-0.48
a06b0015-f815-4c27-8501-158647343a73	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:36.736+02	0.00	Standby
9269ebff-dbdb-4f25-8064-73d4f47b2678	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:37:36.737+02	0.00	pH Stable
c1d37aba-8b32-42f7-9483-46a11ed17039	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:37:36.737+02	91.47	Auto ORP: Deficit=137.20000000000005, pH-Eff=1
6e41772e-e514-432c-bd7f-31115677dcb6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:36.737+02	0.00	Standby
5a10f985-b76b-463a-a69e-dfafe622bf8b	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:37:36.738+02	0.00	pH Stable
ff28cd31-77f4-4f33-85fe-0f2e06f6c77f	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:37:41.774+02	0.00	Auto PID: Target=6.0, Err=-0.46
78d83936-f81c-4ccb-8078-44ed68243169	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:41.775+02	0.00	Standby
153abad4-9b4e-465b-b08b-296bfe3ded1f	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:41.775+02	0.00	Standby
a62a0cb4-bb81-40b7-859f-8933dcd73d86	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:37:41.776+02	0.00	pH Stable
fd0312fc-b7d3-44e2-8f9b-6a622cc53daf	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:37:41.776+02	90.43	Auto ORP: Deficit=135.64999999999998, pH-Eff=1
7b31ebd2-315b-48ec-a4dd-afcbdda8c19e	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:37:41.778+02	0.00	pH Stable
664a9fac-e3ea-4a12-beb7-50d7ab6676a7	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:46.786+02	0.00	Standby
ac96b9b4-ab55-4de0-adc3-a1d753c8332d	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:37:46.785+02	0.00	Auto PID: Target=6.0, Err=-0.45
657a4a1b-3ccb-4cd9-98ac-d3c68447b929	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:46.786+02	0.00	Standby
21db3348-7bfc-420c-92f3-601758373654	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:37:46.786+02	0.00	pH Stable
61071df7-c2c5-4948-bd2e-909c9a69ee7e	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:37:46.786+02	89.41	Auto ORP: Deficit=134.12, pH-Eff=1
62c3cccf-3962-4678-857d-f127beb7a035	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:37:46.787+02	0.00	pH Stable
2fd25f10-a781-4b89-ab4b-4fed2e150c11	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:37:51.741+02	0.00	Auto PID: Target=6.0, Err=-0.44
b8a8da57-9d41-4eb5-a270-a35ab33b01d9	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:37:51.784+02	0.00	pH Stable
afe45c5b-e946-4899-9e09-c0f41c95d812	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:51.786+02	0.00	Standby
c398169a-06b9-4bcc-9415-c5d6098f557e	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:37:51.786+02	0.00	pH Stable
673378e2-2341-4e1a-b53b-c505bfa2064c	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:51.786+02	0.00	Standby
a5db7b4e-8952-43f3-b2dc-4edf1e240b02	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:37:51.787+02	88.41	Auto ORP: Deficit=132.61, pH-Eff=1
9ba052a3-d99d-41c2-85a4-7f8973e6942f	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:37:56.764+02	0.00	Auto PID: Target=6.0, Err=-0.40
9b1cf953-4a5a-4fb7-9233-7a006eea5db1	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:37:56.8+02	0.00	pH Stable
cc4b2677-2473-4bc1-a167-e5ea28ad0d00	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:56.801+02	0.00	Standby
c58be45d-b92c-4b85-a388-4b689ff58b8e	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:37:56.801+02	0.00	Standby
04bbbcde-40ac-4dad-a7db-8a2552e6d75e	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:37:56.802+02	0.00	pH Stable
38d9776d-05af-469e-94d6-d6a7fce29ed6	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:37:56.802+02	86.39	Auto ORP: Deficit=129.59000000000003, pH-Eff=1
99a755ff-a6ad-4e53-a045-64f083148c18	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:38:01.806+02	0.00	Auto PID: Target=6.0, Err=-0.37
82d90f71-accf-4735-82c0-6b99fea247fe	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:38:01.825+02	0.00	pH Stable
759f4411-0703-481b-a2ff-d151755caf1d	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:38:01.828+02	0.00	pH Stable
00f5f173-01c4-4bd9-ad09-309b49203c88	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:01.83+02	0.00	Standby
6a0e9b33-192c-4b3a-907d-f347fb510590	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:38:01.83+02	84.42	Auto ORP: Deficit=126.63, pH-Eff=1
f99422d7-d14b-4a89-86a8-69a453de3f0c	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:01.83+02	0.00	Standby
7add8141-ce1f-41ec-b701-d1eb373c05ee	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:38:06.79+02	0.00	Auto PID: Target=6.0, Err=-0.33
4993ed37-1de0-4017-911e-b4b226dcbd5b	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:38:06.825+02	0.00	pH Stable
27f76b09-0c7a-4a59-bf6f-04e34ed68eaa	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:38:06.828+02	0.00	pH Stable
f6f012ee-0c1f-45f6-b71b-13c76c476650	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:06.829+02	0.00	Standby
8ec75783-0263-4673-baf5-c0abfa211f42	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:06.829+02	0.00	Standby
b2fb2473-14f3-4d16-9782-62cc233cd059	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:38:06.829+02	82.49	Auto ORP: Deficit=123.74000000000001, pH-Eff=1
fad760e8-21e9-4213-90da-e5ca0bf7fe96	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:38:11.857+02	0.00	Auto PID: Target=6.0, Err=-0.29
2b814793-f835-4fba-86b7-b5e22513a189	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:11.858+02	0.00	Standby
f4ec9ae0-4754-4a34-8e09-7236b75f63b7	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:11.859+02	0.00	Standby
d07be12a-bf9a-4206-b226-3c0a34fa63ef	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:38:11.86+02	80.62	Auto ORP: Deficit=120.92999999999995, pH-Eff=1
2a423e21-1d15-4d7c-aad6-1bf492a11345	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:38:11.86+02	0.00	pH Stable
0ed31ad3-11f1-4271-9ad5-4451892760f1	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:38:11.862+02	0.00	pH Stable
1058810d-608e-48fd-9f36-d5bd7adb3133	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:38:16.841+02	0.00	Auto PID: Target=6.0, Err=-0.26
1845fd63-3517-4ec0-905d-dc55f5252549	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:38:16.869+02	0.00	pH Stable
306f568f-e783-4b3b-8fdc-5895c92ed6fb	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:38:16.872+02	0.00	pH Stable
f2e8d3cc-863f-49be-8c6c-51a598036a9e	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:16.872+02	0.00	Standby
023e9863-ca3f-45eb-b2d4-2ac9f3256568	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:16.872+02	0.00	Standby
24814ea2-098b-45d2-83d2-d91c478abaaa	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:38:16.873+02	78.80	Auto ORP: Deficit=118.20000000000005, pH-Eff=1
d9eeb874-cb73-410b-9caf-2017a9a71efc	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:38:21.834+02	0.00	Auto PID: Target=6.0, Err=-0.22
bc22d9ac-1ee9-4005-afb0-db9578842836	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:38:21.887+02	0.00	pH Stable
855d4bb2-0903-4404-9f2c-ee5ad7a58658	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:38:21.89+02	0.00	pH Stable
6a9a31e3-3a7f-4d6c-94af-4969f669c9ee	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:21.89+02	0.00	Standby
0b7ab728-2774-4bd5-9028-e42396449218	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:21.89+02	0.00	Standby
51e82aef-d930-405d-a92f-34674e0b4c32	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:38:21.891+02	77.05	Auto ORP: Deficit=115.57000000000005, pH-Eff=1
42d88a7b-0d3a-4387-8cad-2b387679d6bf	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:38:26.827+02	0.00	Auto PID: Target=6.0, Err=-0.18
2afd4fe2-dfa8-4943-8465-d8f9fb0f0f24	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:38:26.88+02	0.00	pH Stable
24dad1d9-a2aa-42e3-8842-a610af986e0d	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:26.88+02	0.00	Standby
3a8886d1-c80e-4719-8f8b-6ee143b55aa6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:26.88+02	0.00	Standby
804dbd26-8be4-4080-9f21-9da2d67a62d7	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:38:26.881+02	0.00	pH Stable
9bfb87cb-856d-4948-ac3a-59988373e6c6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:31.891+02	0.00	Standby
b3ffa6f6-450e-4e50-806c-af7d8918cce2	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:38:26.881+02	75.35	Auto ORP: Deficit=113.01999999999998, pH-Eff=1
9ee88240-2faa-4f28-9513-6a5d2e499af3	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:38:31.835+02	0.00	Auto PID: Target=6.0, Err=-0.15
1882c7ce-874d-4815-9d9d-ab2c9d487efd	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:38:31.884+02	0.00	pH Stable
33cae1eb-4a12-4d1b-ab59-f28651605e5e	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:38:31.888+02	0.00	pH Stable
8bb3f051-abe7-4808-85a0-e86a477dda4f	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:41.922+02	0.00	Standby
95746c5d-5723-4601-9d05-f6d31c0ac3b3	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:46.928+02	0.00	Standby
a9b03215-ac46-4d4d-92e0-68a756126cce	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:38:51.974+02	0.00	pH Stable
ab7e776c-7fe8-48b1-8220-55956fccb529	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:38:51.978+02	0.00	pH Stable
8c0e35e1-1ae6-4e07-9d39-096762785fb1	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:31.891+02	0.00	Standby
2f012230-84dc-4e58-835b-a1bd5fb636ad	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:38:36.947+02	72.14	Auto ORP: Deficit=108.21000000000004, pH-Eff=1
6a159e76-53b3-4640-8e13-052ff6b9e330	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:38:41.921+02	0.00	Auto PID: Target=6.0, Err=-0.08
19d2393e-0c61-47c3-878b-20804006829f	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:38:31.891+02	73.71	Auto ORP: Deficit=110.57000000000005, pH-Eff=1
8ec9bde2-c650-4a6d-8087-f21e0d04bd20	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:38:36.901+02	0.00	Auto PID: Target=6.0, Err=-0.11
3b4b5f78-f501-492f-a7cb-8277104aabf6	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:38:36.945+02	0.00	pH Stable
9599d599-1e7b-4b6c-a9b6-b4921d7706d8	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:38:36.947+02	0.00	pH Stable
7f7f0970-4bb5-423a-bc98-6d4566b050e6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:41.922+02	0.00	Standby
c0183535-14ad-4da4-a3e3-e165b997cdb5	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:51.974+02	0.00	Standby
5e3fd712-d4d0-4b17-95af-395f1717abac	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:36.947+02	0.00	Standby
8e68ed66-e717-44e0-af9d-0d2dd41162a6	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:38:41.923+02	70.62	Auto ORP: Deficit=105.92999999999995, pH-Eff=1
638eb1a2-6d57-47db-9793-1a6d0c2df8ad	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:46.927+02	0.00	Standby
ce340a83-e66c-4d76-831a-b8c5b64214c9	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:38:51.977+02	67.75	Auto ORP: Deficit=101.62, pH-Eff=1
df22efe4-ed9a-466d-a99b-87e3cd53d908	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:36.947+02	0.00	Standby
3db5e371-d9f7-4565-8c8f-55a074cd2b34	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:38:41.923+02	0.00	pH Stable
9787a026-249d-4497-a3ee-4bbb24b147a9	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:38:41.924+02	0.00	pH Stable
ac8ed221-f81a-4503-b9ed-7a725f60aef4	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:38:46.899+02	0.00	Auto PID: Target=6.0, Err=-0.05
2a5c5302-443e-4cef-9349-b3a71d621831	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:38:46.925+02	0.00	pH Stable
6d155667-bef6-4c19-a57f-4303384a84bf	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:38:46.927+02	0.00	pH Stable
d3428702-8420-405d-8b68-491a3641ea00	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:38:46.928+02	69.15	Auto ORP: Deficit=103.73000000000002, pH-Eff=1
b2169808-1989-4a3c-9086-c2acfdb58065	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:38:51.973+02	0.53	Auto PID: Target=6.0, Err=-0.02
ff7a275b-273d-4663-9c21-f2eb2bda0cde	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:38:51.974+02	0.00	Standby
bfe90bcc-4081-4518-92e6-5fc0ade7ecf9	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:48:54.186+02	0.00	Auto PID: Target=6.0, Err=-0.49
82ca0df6-ffe3-408e-b87a-df1ad1df8174	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:48:54.248+02	0.00	pH Stable
5bf358d2-e0a4-4eed-85ff-417d78079b87	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:48:54.251+02	0.00	pH Stable
cfbe6fa9-dccf-4008-b40c-254182c24948	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:48:54.255+02	93.27	Auto ORP: Deficit=139.90999999999997, pH-Eff=1
8c2d5cd8-4578-46ea-b17c-84eb2dc1491b	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:48:54.258+02	0.00	Standby
53897944-f16e-4294-93e6-51b4a8d41cd9	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:48:54.259+02	0.00	Standby
71edfb90-a403-4738-b28b-2a63193d5451	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 10:48:54.262+02	80.26	Auto: VFD Mode | Lvl: 50.9% | Trnd: 0.23
ebb53add-7c3b-4958-b051-3eb95c77f20e	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:48:59.177+02	0.00	Auto PID: Target=6.0, Err=-0.48
b90ae17e-98c3-44ae-afdc-ca73b58d3741	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:48:59.259+02	0.00	pH Stable
a084aa48-19af-4b5b-bad4-79f4d5ddee46	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:48:59.26+02	0.00	Standby
3dd42dcd-73f5-43be-9103-a3db71ab3c39	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:48:59.26+02	0.00	Standby
59aeb8b3-9271-48e1-9591-d7d843c418c9	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:48:59.264+02	92.22	Auto ORP: Deficit=138.33000000000004, pH-Eff=1
03a23d6f-1302-4477-8223-2ff203dc4780	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:48:59.265+02	0.00	pH Stable
c850b88b-4d17-435e-aa3e-bf6a0c33a2ab	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 10:48:59.265+02	80.45	Auto: VFD Mode | Lvl: 50.9% | Trnd: 0.24
1501222c-4b81-477b-a24d-af86551a356b	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:49:04.175+02	0.00	Auto PID: Target=6.0, Err=-0.48
43bdbd9b-6b6c-43ad-844c-9f81e4c13458	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:49:04.218+02	0.00	pH Stable
1293d7a1-6059-4d7a-91c6-be7bc4f78f59	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:49:04.22+02	0.00	pH Stable
f3b6458c-79d1-428b-b127-a396c6222e13	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:49:04.22+02	0.00	Standby
681b407c-ade6-4544-a065-7b8b2890400e	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:49:04.22+02	0.00	Standby
d951151b-70e9-4560-9bd1-b841237ce83c	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:49:04.221+02	91.17	Auto ORP: Deficit=136.76, pH-Eff=1
6becb072-c78e-4e94-8244-a0d96aa8965e	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 10:49:04.222+02	79.83	Auto: VFD Mode | Lvl: 50.9% | Trnd: 0.24
130ed776-6974-47a3-8f77-0490fd4093c1	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 10:49:09.227+02	0.00	Auto PID: Target=6.0, Err=-0.46
4fef614d-b207-4453-93b1-90d918ebddb9	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 10:49:09.29+02	0.00	pH Stable
8a764e47-b1f3-497b-9432-c224e730eab6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:49:09.29+02	0.00	Standby
68e0db22-4799-4f9a-96fc-5b2d61e464e9	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 10:49:09.29+02	0.00	Standby
0a5da6b8-618b-4884-9dd0-8fab994ee178	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 10:49:09.29+02	90.14	Auto ORP: Deficit=135.21000000000004, pH-Eff=1
603d5cfb-420c-4b2c-b0e2-3cf85868c262	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 10:49:09.291+02	81.96	Auto: VFD Mode | Lvl: 50.9% | Trnd: 0.25
cb6862ff-abcb-48f0-96eb-252492565c7b	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 10:49:09.291+02	0.00	pH Stable
ba490e96-c8c8-4b8a-93af-c19274b5402e	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:00:54.147+02	0.00	Auto PID: Target=6.0, Err=-0.68
7494bf6d-9f7e-45f4-808f-d8ecd50daf89	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:00:54.215+02	0.00	pH Stable
07d6734f-6fd4-40c0-8d56-0c8cd4ba1478	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:00:54.217+02	0.00	pH Stable
0e981477-b6e1-4de0-b725-091e3c97cf4a	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:00:54.22+02	94.47	Auto ORP: Deficit=141.71000000000004, pH-Eff=1
d5c1410f-c54a-4ebe-b507-c5df60b7450d	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:00:54.224+02	0.00	Standby
53c3410d-ea47-4f04-8a10-c284c2eb4dd5	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:00:54.227+02	71.64	Auto: VFD Mode | Lvl: 49.9% | Trnd: -0.00
11b8d796-c8b0-4646-9c5c-e8762cf804d8	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:00:54.228+02	100.00	Auto: Predictive Wash (pressure rising fast)
d9cd25b7-797e-4c80-a72c-49cb23c9ea5b	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:00:59.217+02	0.00	Auto PID: Target=6.0, Err=-0.57
54140734-9afc-43bf-ba7f-022a2ca0aa42	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:00:59.276+02	0.00	pH Stable
5935534e-6a13-43fc-9a1b-8d41d680c7a6	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:00:59.279+02	0.00	pH Stable
2d7914ce-3f7e-4ab2-a446-81514bda4bbb	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:00:59.279+02	0.00	Standby
bfaddff8-589b-4a34-9de9-1a64c6659e59	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:00:59.279+02	0.00	Standby
31979a39-d957-4c67-bf41-427dc99410e3	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:00:59.28+02	79.40	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.02
e9632012-459a-4e45-a51d-51ccb9907d31	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:00:59.281+02	94.55	Auto ORP: Deficit=141.82000000000005, pH-Eff=1
2d6ee706-576e-492f-a3ba-91588e1e86e7	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:01:04.234+02	0.00	Auto PID: Target=6.0, Err=-0.59
066b0b57-6e07-4014-b277-b1a4299aeb28	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:01:04.272+02	0.00	pH Stable
47ece0d5-3726-4f63-a7fd-73c20c195530	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:04.273+02	0.00	Standby
522c5196-ba9c-4cbb-97ec-343a56bc1885	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:04.273+02	0.00	Standby
9d23a705-0259-49c1-8351-4132ff177b40	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:01:04.273+02	94.55	Auto ORP: Deficit=141.83000000000004, pH-Eff=1
3fa5529a-69ad-4eb8-a995-4d6f6142ca9d	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:01:04.274+02	0.00	pH Stable
04219994-bb52-481c-bcff-01b0f0fd93bb	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:01:04.308+02	79.77	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.02
66961fdb-2390-4f39-8b24-84c7dc2ef2ec	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:01:09.331+02	0.00	Auto PID: Target=6.0, Err=-0.59
0c374f20-96df-45ae-b806-0b85087cab64	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:01:09.404+02	0.00	pH Stable
e9b89e03-a13f-40cb-a427-a6132f097540	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:01:09.406+02	0.00	pH Stable
fcd95e14-7a1b-4028-b8e7-9b36b242c4d0	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:09.406+02	0.00	Standby
b2091dd7-3f6d-4512-a486-32bbb5f1b242	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:09.407+02	0.00	Standby
3d858396-6e21-40c5-9faf-b8ab528b7e80	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:01:09.407+02	94.54	Auto ORP: Deficit=141.80999999999995, pH-Eff=1
84c7b226-1de8-4a63-98e5-67aec6474683	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:01:09.57+02	78.89	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.02
91e58aa3-24cb-4f79-9f69-80fb2848e2ee	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:01:14.397+02	0.00	Auto PID: Target=6.0, Err=-0.64
9b05693a-7763-48cd-8223-e8d7647be284	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:01:14.426+02	0.00	pH Stable
376c279a-d644-4439-827c-d90c4ebaa46a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:14.426+02	0.00	Standby
b93a250c-a59e-473b-87e3-3b9f15fcb2dd	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:01:14.428+02	0.00	pH Stable
480ba806-8685-4aab-9136-6958bcd10ee5	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:01:14.429+02	94.55	Auto ORP: Deficit=141.82000000000005, pH-Eff=1
505df2fc-da33-494c-8532-4f51212e3454	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:14.455+02	0.00	Standby
8753448b-452f-43d2-9da1-54148c286ea5	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:01:14.456+02	78.87	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.01
7a404bd7-0388-4dbb-a26f-bea280e7e908	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:01:19.526+02	0.00	Auto PID: Target=6.0, Err=-0.59
758a1178-5254-4ace-9e68-e3f34ee0fd54	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:01:19.529+02	0.00	pH Stable
171c0693-2dfa-43e9-bd55-395ead1226d1	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:01:19.529+02	94.53	Auto ORP: Deficit=141.78999999999996, pH-Eff=1
c0513dd3-f34a-47ba-831a-51df56871af5	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:01:19.53+02	0.00	pH Stable
7edcee30-1d6f-472e-8b09-886154bf9545	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:19.552+02	0.00	Standby
57e4d55b-9342-469c-89b0-7a152e28ba25	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:01:19.553+02	79.29	Auto: VFD Mode | Lvl: 50.1% | Trnd: 0.03
2ae80ac6-9350-4646-9332-04406c5a3458	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:19.608+02	0.00	Standby
cb66ab0b-c2ed-4a5a-b606-c510d058258f	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:01:24.55+02	0.00	Auto PID: Target=6.0, Err=-0.59
1b1a9270-b14a-4897-ad7b-8484fc07b1f5	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:01:24.582+02	0.00	pH Stable
2035b75b-ed9b-4d23-b680-e06b89a1618a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:24.584+02	0.00	Standby
79f48d1b-8361-4c6d-adf8-90ad5c9fc9f4	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:01:24.584+02	0.00	pH Stable
1ccf3312-8836-4777-87d0-dad93e6ae8c2	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:29.664+02	0.00	Standby
e084cc06-732e-428a-bb36-58476ba331c4	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:01:24.584+02	94.53	Auto ORP: Deficit=141.79999999999995, pH-Eff=1
79fe5d74-b6da-4c46-89b0-52730c4bd144	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:01:29.665+02	94.53	Auto ORP: Deficit=141.78999999999996, pH-Eff=1
d360aaef-e345-40c0-bae7-484c8280147d	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:01:34.794+02	94.53	Auto ORP: Deficit=141.79999999999995, pH-Eff=1
ff4c0850-71e9-4253-b63f-1c083095624a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:39.902+02	0.00	Standby
cf053336-94a3-494f-beb7-683067e49007	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:01:44.944+02	69.35	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.01
cee4b615-e838-4981-bb05-191b675b7101	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:01:50.008+02	94.51	Auto ORP: Deficit=141.76, pH-Eff=1
aa61c939-42a2-4c30-a428-a58064730a88	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:01:50.049+02	68.91	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.00
12068032-ff68-46c5-9ffa-27c57aee9eb6	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:01:55.161+02	0.00	Auto PID: Target=6.0, Err=-0.56
56ef926e-2ef7-42a8-90ba-584fad7a2a5a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:24.584+02	100.00	Auto: Predictive Wash (pressure rising fast)
821303b7-fe4c-4931-bf5f-308cb3ea7d3c	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:01:24.626+02	81.64	Auto: VFD Mode | Lvl: 50.1% | Trnd: 0.03
6f803a56-ceaa-4eca-b313-9515083b9d9a	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:01:29.636+02	0.00	Auto PID: Target=6.0, Err=-0.55
7d4e3b18-51cf-436a-814f-c1db3974c307	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:01:29.662+02	0.00	pH Stable
3045c3b3-e39f-41bc-ad92-1608e3a69874	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:01:29.664+02	0.00	pH Stable
76d9c01a-99fc-465b-808d-87a92633cd9e	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:34.795+02	0.00	Standby
1deec510-1400-41ad-9f5e-b682fe29abe2	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:39.903+02	0.00	Standby
d85b6822-d493-431e-82b3-e3edc446c102	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:44.943+02	0.00	Standby
cd5dccd9-d379-4bcc-a9f9-8f373934f640	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:29.665+02	100.00	Auto: Predictive Wash (pressure rising fast)
6f5f5f69-afa7-46ef-99de-07f0aa58a105	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:01:29.724+02	80.37	Auto: VFD Mode | Lvl: 50.1% | Trnd: 0.03
fec906e2-8ad7-40ca-b2d8-ebdafb3e8001	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:01:34.722+02	0.00	Auto PID: Target=6.0, Err=-0.57
3b7243a6-f4df-4ca2-981c-bde74b8a20e5	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:01:34.79+02	0.00	pH Stable
908e5c3e-0eed-44ec-8160-e127f07ed21c	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:01:34.793+02	0.00	pH Stable
c4d967a2-ff15-4f5e-bb5d-05b72d0ce069	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:01:39.904+02	79.78	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.02
eb74ec52-00b5-4b57-bfa2-b0a4bcb5d91b	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:01:44.943+02	94.51	Auto ORP: Deficit=141.76, pH-Eff=1
07f356dc-308e-466d-9de0-3aec1a84fd84	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:50.007+02	0.00	Standby
3f4d57c1-fc25-4c9e-9fac-64986e0e2fd1	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:01:55.163+02	94.51	Auto ORP: Deficit=141.76, pH-Eff=1
59b437a6-22d5-4d1c-b5df-e94d2e414c0e	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:02:00.202+02	69.52	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.01
9a7325ed-afa6-4272-b3d6-435ab463bbaa	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:02:05.24+02	94.49	Auto ORP: Deficit=141.74, pH-Eff=1
c3736422-c347-440b-90d2-464467d6c9b7	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:02:10.331+02	0.00	Standby
c429d6a1-076b-437f-a131-108ae8673e43	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:34.795+02	0.00	Standby
7258200c-1b45-4328-86df-76138614acf2	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:01:34.857+02	79.59	Auto: VFD Mode | Lvl: 50.1% | Trnd: 0.03
96ab3fb8-09fd-4590-91df-45de70bc9026	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:01:39.901+02	0.00	Auto PID: Target=6.0, Err=-0.53
1351b624-bd0e-4776-950e-8ef74c4de4d4	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:01:39.903+02	94.51	Auto ORP: Deficit=141.76, pH-Eff=1
18b3f87e-5a4f-46b3-9111-f1ce9eb3d408	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:01:39.905+02	0.00	pH Stable
bcaef1a8-1875-41c4-99ff-79479720692b	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:01:39.91+02	0.00	pH Stable
0ca601b9-a645-464b-b71c-a9862f0ef234	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:01:44.942+02	0.00	Auto PID: Target=6.0, Err=-0.52
f3e67e24-40a3-449b-bb7f-fd71634896f8	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:44.943+02	0.00	Standby
4387369b-0bdf-4baa-8dd4-935b4527cee3	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:01:44.943+02	0.00	pH Stable
6c9eb71c-4991-48a0-85bc-54cf267f79f7	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:01:44.944+02	0.00	pH Stable
e8b1f453-c2f2-457c-910e-5afe7bfdff66	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:01:49.945+02	0.00	Auto PID: Target=6.0, Err=-0.53
5688e3a1-7ef2-41f1-bc1b-579c3f848f38	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:01:50.007+02	0.00	pH Stable
98517be3-0129-4586-aca8-183142e4dd39	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:01:50.008+02	0.00	pH Stable
d36eeee8-7e73-4897-9c68-1132f1ba34e0	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:50.048+02	0.00	Standby
88d3fb0b-1203-44a5-a4e3-66cb9fa6e2ca	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:01:55.163+02	0.00	pH Stable
b62f3e74-6727-451f-980c-20e56bac1fef	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:01:55.164+02	0.00	pH Stable
26b0a846-54f2-42df-a07f-719e212fb82b	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:55.24+02	0.00	Standby
a3050ad9-ddf1-4ea9-ad7a-b060d3f47295	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:01:55.24+02	79.43	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.02
62268f26-41a6-45e4-b7d3-5c6591753929	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:01:55.24+02	0.00	Standby
087c4ea4-8556-4522-92b9-6a98d52a444f	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:02:00.129+02	0.00	Auto PID: Target=6.0, Err=-0.64
20978231-8acb-4d60-ad93-c824b8538e42	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:02:00.198+02	0.00	pH Stable
3e35533c-a5f7-45db-ac82-d30a0e248b72	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:02:00.2+02	0.00	pH Stable
dd2b2df1-d0c2-4450-8a41-186e4e0983c2	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:02:00.201+02	0.00	Standby
2344f679-0fbc-42d1-a6ae-767e84cd1b21	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:02:00.201+02	94.49	Auto ORP: Deficit=141.74, pH-Eff=1
9fe5f3e4-433f-4040-962d-e2df99b3e0c2	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:02:00.201+02	100.00	Auto: Predictive Wash (pressure rising fast)
96796b49-b97d-456e-be99-1f72909f0681	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:02:05.239+02	0.00	Auto PID: Target=6.0, Err=-0.62
f1d77ffc-f589-414f-a55e-e46f1670d649	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:02:05.239+02	0.00	Standby
fe3dadbf-8f4c-4720-8188-42921d9d90de	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:02:05.24+02	0.00	Standby
5ea29c5e-d247-4a2c-8648-e9a08515b21e	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:02:05.24+02	0.00	pH Stable
8228f423-d45f-4384-affb-e53547f85c0e	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:02:05.241+02	0.00	pH Stable
0b98a91f-dec9-48b8-ab2b-97e315c2c833	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:02:05.293+02	69.14	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.01
c2e14879-7aa8-4690-819c-8b9ee921062a	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:02:10.294+02	0.00	Auto PID: Target=6.0, Err=-0.60
9a1a4b79-74d4-4e00-a337-ddd39642a1c8	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:02:10.331+02	0.00	Standby
daf5ad33-bda9-447b-8e60-7f0cf7803c77	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:02:10.331+02	0.00	pH Stable
6691c398-2859-467c-ae19-5db203456caa	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:02:10.331+02	94.49	Auto ORP: Deficit=141.73000000000002, pH-Eff=1
f2a85136-a0c8-4a73-918e-f239cfc6835c	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:02:10.332+02	0.00	pH Stable
b6d246f0-38f4-47d3-b46c-94ef993ba7ad	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:02:10.347+02	69.60	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.01
dd10aee5-0d85-4b82-9089-b2f2a8b211dc	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:11:31.439+02	0.00	Auto PID: Target=6.0, Err=-0.51
60ac31f1-a3da-4808-bcd2-1eb533cecf3a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:31.498+02	0.00	Standby
f50ed90d-caf2-4737-8947-db30c2f52fe4	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:31.501+02	0.00	Standby
13dbb79c-2bee-4e62-983a-08537cac930d	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:11:31.506+02	92.38	Auto ORP: Deficit=138.57000000000005, pH-Eff=1
5a51e0dd-5ef9-4b40-b057-4974ba85d06e	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:11:31.506+02	0.00	pH Stable
04eea885-f1f1-4d28-a8bc-10ec2ab8a76f	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:11:31.508+02	0.00	pH Stable
184ad192-6704-4cb3-9c4c-aa585fb0d484	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:11:31.511+02	81.17	Auto: VFD Mode | Lvl: 50.1% | Trnd: 0.05
34fddc6d-c095-430f-ae12-6a0c25531e7e	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:11:35.981+02	0.00	Auto PID: Target=6.0, Err=-0.49
df00cdc5-7d4d-49e4-99e9-de0264dfa2b6	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:11:36.028+02	0.00	pH Stable
bbb319f4-bd27-4242-b982-2d879c56898d	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:36.029+02	0.00	Standby
057a052d-7a6b-4087-a523-697e5e27bee1	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:11:36.029+02	0.00	pH Stable
389adf0a-0f51-4848-99e4-7366f2de16a1	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:11:36.029+02	90.29	Auto ORP: Deficit=135.42999999999995, pH-Eff=1
3555ce26-43c2-4694-ad16-8ddc2211ea3e	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:36.031+02	0.00	Standby
393145dc-cdcf-4579-a4a6-fcaf791794df	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:11:36.069+02	81.15	Auto: VFD Mode | Lvl: 50.2% | Trnd: 0.06
552e0725-951b-46e0-b7c1-1698fc3208af	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:11:41.545+02	0.00	Auto PID: Target=6.0, Err=-0.44
99731e3e-310d-40b9-ae9c-209ba65bc5ca	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:41.547+02	0.00	Standby
a69481d5-892e-4ea6-a626-36ae3fafb942	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:11:41.547+02	88.27	Auto ORP: Deficit=132.40999999999997, pH-Eff=1
5cfd026f-f004-4ce3-98ae-ea61c6b716dc	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:11:41.547+02	0.00	pH Stable
b6c65b67-289b-4c6f-b886-3141aab817da	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:11:41.549+02	0.00	pH Stable
e4a19417-39d1-400d-82fe-469ac0501301	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:41.611+02	0.00	Standby
0e05219e-2983-4a4f-a48e-8ffd12b49804	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:11:41.611+02	80.54	Auto: VFD Mode | Lvl: 50.2% | Trnd: 0.06
b9885e26-601f-40be-9bb2-604b9fd07f3f	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:11:46.12+02	0.00	Auto PID: Target=6.0, Err=-0.48
8f37f147-4530-4b25-a35f-3d892afcb61d	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:11:46.166+02	0.00	pH Stable
3d7d27b5-fdf9-4f9c-a276-c1ba27cdbfce	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:46.167+02	0.00	Standby
4211b915-1935-4b19-aeb5-d2be0c7c9db3	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:11:46.167+02	86.32	Auto ORP: Deficit=129.48000000000002, pH-Eff=1
25b23f08-53eb-479c-816f-4f1fb0d0d78e	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:11:46.168+02	0.00	pH Stable
bb065e91-c142-401c-8c74-f4cb03e2f458	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:46.169+02	0.00	Standby
a1a4993f-f598-4f13-9020-4e141e2404f3	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:11:46.21+02	80.75	Auto: VFD Mode | Lvl: 50.2% | Trnd: 0.06
25bc98d9-568b-41c0-a871-3ddb0e66c278	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:11:51.194+02	0.00	Auto PID: Target=6.0, Err=-0.48
6da74a1d-8bbc-45d3-92f2-fbf7cdcac4db	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:11:51.233+02	0.00	pH Stable
6b419b47-1095-443a-be58-a2fa144ec770	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:51.234+02	0.00	Standby
d00b13d4-a4c2-45e9-bf08-46586ff79ad4	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:11:51.235+02	0.00	pH Stable
8b682e0d-f38d-45a8-b195-5f8e92f996d2	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:11:51.236+02	84.43	Auto ORP: Deficit=126.63999999999999, pH-Eff=1
1dbdf68c-7caf-43bc-9dbd-3280224fa26d	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:51.252+02	0.00	Standby
544431c0-a451-4536-b17d-761bda0593d6	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:11:51.253+02	78.54	Auto: VFD Mode | Lvl: 50.2% | Trnd: 0.06
7420e0f4-e568-4dda-b26b-342c362c14e4	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:11:56.286+02	0.00	Auto PID: Target=6.0, Err=-0.48
493e0e87-160d-43da-97ce-3febfbc488f3	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:11:56.3+02	0.00	pH Stable
8db61796-69fd-4918-9e5b-17b7e1662336	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:56.302+02	0.00	Standby
c8a69bc7-3b96-4d3b-8598-f747501bd10c	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:11:56.303+02	0.00	pH Stable
a09ade6d-d4fc-4f3d-9993-e40182642533	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:11:56.303+02	82.61	Auto ORP: Deficit=123.90999999999997, pH-Eff=1
4afb01fe-671c-44d5-9f5d-390f00a86d70	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:11:56.374+02	0.00	Standby
9bbe0b73-1668-4278-be5a-ce5584768648	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:11:56.375+02	81.06	Auto: VFD Mode | Lvl: 50.2% | Trnd: 0.06
e8fe4c7d-dda1-4ef8-9156-192099efb8ce	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:12:01.339+02	0.00	Auto PID: Target=6.0, Err=-0.47
7e6d222a-ad83-410e-82c4-2a6a15333851	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:12:01.37+02	0.00	pH Stable
2c221283-028e-4b83-8dd7-cbc9eb514d04	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:01.371+02	0.00	Standby
d1013f00-56a3-4b97-9e6a-ab6a60cd8576	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:12:01.371+02	0.00	pH Stable
be49c09f-7a05-4b73-90ee-f8b0e8ae09ea	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:12:01.372+02	80.85	Auto ORP: Deficit=121.27999999999997, pH-Eff=1
1bec9ba9-5a65-4e82-bd40-44079c5ea616	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:01.43+02	0.00	Standby
32e26cf9-30b2-4513-a378-80a43f25c842	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:12:06.631+02	0.00	pH Stable
f7169840-1a49-4e5c-a165-570a35f4ed87	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:12:06.635+02	0.00	pH Stable
6bbdea3c-a9f6-4270-84d0-2a63f3fdc89d	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:11.573+02	0.00	Standby
699d5f23-4f36-4811-995f-aabdf8b7ce99	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:16.653+02	0.00	Standby
67b798ee-4c7b-4eb6-ab94-35d0625daaef	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:12:01.431+02	79.63	Auto: VFD Mode | Lvl: 50.2% | Trnd: 0.06
5530e29d-fbb5-45de-a034-f7d7e51a5ef3	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:12:06.63+02	0.00	Auto PID: Target=6.0, Err=-0.47
7e0194d5-7c4f-4d44-8116-7adbc6675622	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:12:06.632+02	79.17	Auto ORP: Deficit=118.75, pH-Eff=1
c6c8971b-a6e9-4fe7-9cf4-4430d43c38a6	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:06.71+02	0.00	Standby
0aa1d854-85d6-44f0-b599-ad095e5906af	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:06.716+02	0.00	Standby
293b66eb-4d3b-403a-938f-19ccd920e77a	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:12:06.716+02	79.49	Auto: VFD Mode | Lvl: 50.2% | Trnd: 0.06
f1c33a9b-7d34-427c-8a5f-dc766827e8cd	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:12:11.573+02	0.00	Auto PID: Target=6.0, Err=-0.21
4ff1ac87-c5ef-4975-8e81-7c1e3788952d	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:12:11.574+02	0.00	pH Stable
29385949-3031-48d4-a5f4-7f4ce118fede	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:11.574+02	0.00	Standby
299080a9-37b6-485e-a819-541d6a8ec2f0	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:12:11.574+02	79.47	Auto: VFD Mode | Lvl: 50.5% | Trnd: 0.13
d4100c18-dfcf-44be-8f21-e9b530af9c25	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:12:11.575+02	0.00	pH Stable
99656165-52b2-4392-8345-9e6f26b08bf2	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:12:11.575+02	77.52	Auto ORP: Deficit=116.27999999999997, pH-Eff=1
fcf4d3dd-74b8-4c3a-8f63-297083cf1555	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:12:16.652+02	0.00	Auto PID: Target=6.0, Err=-0.20
7aa13c7a-eebc-4b05-a1ca-b191e9d59285	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:12:16.653+02	0.00	pH Stable
3cf91ba0-f31c-4522-8bde-61208236b03a	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:12:16.653+02	80.10	Auto: VFD Mode | Lvl: 50.5% | Trnd: 0.14
3c62fbc5-8d7e-418d-b9b0-da14c5f1429a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:16.653+02	0.00	Standby
b37767c2-df6c-427e-b336-06939c7ca4dd	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:12:16.654+02	75.93	Auto ORP: Deficit=113.89999999999998, pH-Eff=1
2486a541-1d8b-40f6-bd13-9cfb5a0cec0b	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:12:16.654+02	0.00	pH Stable
97b94419-b537-4560-bc1c-f2dd5047eda3	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:12:21.737+02	0.00	Auto PID: Target=6.0, Err=-0.19
5cdbe1cd-b538-4d4f-b57f-faa6c8f810bd	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:21.739+02	0.00	Standby
aab8c1f2-b2bd-4dad-bb73-da25a66e84bd	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:12:21.739+02	74.40	Auto ORP: Deficit=111.60000000000002, pH-Eff=1
052cc27b-97eb-454a-bd4a-351a8af47bd8	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:12:21.739+02	0.00	pH Stable
da8e47e6-61e4-4f0b-b742-7d089fd28133	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:12:21.741+02	0.00	pH Stable
0a6c16ef-90a1-4cb5-a0d8-371c9c8a25f2	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:21.783+02	0.00	Standby
d2c8c12c-cd70-4430-acbc-62428bb42dbb	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:12:21.784+02	78.45	Auto: VFD Mode | Lvl: 50.6% | Trnd: 0.15
c9eab1f3-bf01-48c6-aa43-820b58aa7e29	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:12:26.75+02	0.00	Auto PID: Target=6.0, Err=-0.14
d190dd85-af76-46ac-8cba-c2ec3965d122	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:12:26.798+02	0.00	pH Stable
1dba6078-2acc-4c77-a9c3-97f675fa338c	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:26.798+02	0.00	Standby
887e60f5-c68e-4ff2-995f-dda22e108c64	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:12:26.799+02	0.00	pH Stable
a7cb5902-8845-4822-b00f-0f0a06777ff6	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:12:26.799+02	72.91	Auto ORP: Deficit=109.37, pH-Eff=1
2403b906-70ee-47cd-b0ec-282d52ead74b	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:26.829+02	0.00	Standby
775cdbb3-5c32-4cff-a065-95c2c8403a3e	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:12:26.83+02	79.47	Auto: VFD Mode | Lvl: 50.6% | Trnd: 0.16
90eeda1e-c500-4ec6-979f-263c5c725d16	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:12:31.92+02	0.00	Auto PID: Target=6.0, Err=-0.10
36dcd99d-892c-478a-8acb-527cf268a93a	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:12:31.923+02	71.47	Auto ORP: Deficit=107.21000000000004, pH-Eff=1
a980f2dd-1d77-4c85-aae3-eed1944f4387	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:12:31.924+02	0.00	pH Stable
147a1fde-48d2-437f-89af-67debe7f7c1b	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:12:31.926+02	0.00	pH Stable
a23051e4-2d00-421f-8e60-b4032b517e64	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:31.986+02	0.00	Standby
273f921d-6f56-45d1-a094-459bf8b85e10	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:12:31.988+02	81.37	Auto: VFD Mode | Lvl: 50.6% | Trnd: 0.17
1f4577fe-a988-48d7-8e20-ebdfe282f22c	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:31.988+02	0.00	Standby
1f3252f6-1bf3-4cb1-aae9-534ee9f63c18	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:12:37.052+02	0.00	Auto PID: Target=6.0, Err=-0.17
0a128f02-062f-4bc1-b335-1e4b5d2f004d	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:37.053+02	0.00	Standby
8da4c04d-8e47-496f-ab6b-518e0c7fcff7	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:12:37.053+02	81.86	Auto: VFD Mode | Lvl: 50.7% | Trnd: 0.18
5063a35e-74dc-419e-afaa-f90139405358	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:12:37.054+02	0.00	pH Stable
38d2ea83-b8a0-4079-a13b-7a69c433b002	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:12:37.054+02	70.09	Auto ORP: Deficit=105.13999999999999, pH-Eff=1
87ad48ab-1d76-4046-bd32-d64f76e99e64	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:12:37.054+02	0.00	Standby
846f5e40-0cd8-4949-94c4-1ffcabd011a4	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:12:37.055+02	0.00	pH Stable
4af49892-3a19-4f5c-bff3-6a359d32c4ab	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:14:37.845+02	68.75	Auto ORP: Deficit=103.12, pH-Eff=1
5458e630-e7ea-4691-b2bd-7c04cef72b36	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:14:37.901+02	0.00	Standby
96712b29-ce1e-403b-b824-000cacbc78fd	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:14:37.909+02	0.00	Auto PID: Target=6.0, Err=-0.14
349dbbef-d4a0-4627-ad48-3080c064dfe5	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:14:37.909+02	0.00	pH Stable
a9deaa2b-3c89-4aa2-9afd-be1adcfcb8a3	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:14:37.914+02	0.00	pH Stable
311e84c4-175d-454e-8735-579315e9883f	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:14:37.983+02	0.00	Standby
3f31a73b-c706-4d8c-9f28-0dfd941645b0	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:14:37.99+02	79.90	Auto: VFD Mode | Lvl: 50.7% | Trnd: 0.18
c28b47dc-9816-4d2f-b2b0-42e6b1a9efcb	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:14:42.871+02	0.00	Auto PID: Target=6.0, Err=-0.10
b4dd11e0-1cd6-4f31-ac9b-b7c0f24bacea	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:14:42.918+02	0.00	pH Stable
a4bbedb4-adf5-4dce-8a45-d629846e76f1	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:14:42.918+02	0.00	Standby
0758667a-7faf-464a-a474-2989d518a0ef	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:14:42.921+02	0.00	pH Stable
1c6c7c32-7c94-4b8c-b9a4-e0a75cf89b20	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:14:42.922+02	67.45	Auto ORP: Deficit=101.17999999999995, pH-Eff=1
f8b74d3f-d6c4-4c21-acdd-778d8478f8ab	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:14:42.947+02	0.00	Standby
3749c5ed-3376-4e16-b53a-f4f3c2204449	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:14:42.947+02	81.61	Auto: VFD Mode | Lvl: 50.7% | Trnd: 0.19
e1235932-575c-41b2-983c-a02dbf5de8a1	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:14:47.936+02	0.00	Auto PID: Target=6.0, Err=-0.07
7a2043b2-dff2-4fd8-b624-4816352981ed	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:14:47.992+02	0.00	pH Stable
5d474bb5-5847-4242-af47-d52e814359e2	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:14:47.993+02	66.20	Auto ORP: Deficit=99.29999999999995, pH-Eff=1
f07c046b-0aef-4af0-9127-6befe176600c	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:14:47.993+02	0.00	Standby
233c0a3b-b6b1-492d-b8d8-a0f71d71d1b7	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:14:47.994+02	0.00	pH Stable
ce629ad3-d9c2-46f4-90c2-aa8cd347260b	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:14:48.035+02	0.00	Standby
4e9b7620-e983-4236-9bda-3cdfeeb5c764	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:14:48.036+02	79.52	Auto: VFD Mode | Lvl: 50.7% | Trnd: 0.19
867574a0-7f6c-4280-b997-14f3eb57f2b3	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:14:53.231+02	0.00	Auto PID: Target=6.0, Err=-0.04
906580db-ff20-4b93-acd0-638a18e39656	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:14:53.232+02	65.00	Auto ORP: Deficit=97.5, pH-Eff=1
bebd24d8-cce4-457b-b541-4e4ef7179263	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:14:53.233+02	0.00	pH Stable
ebb635c3-8970-43fe-9cae-9ce5ecc03fd6	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:14:53.234+02	0.00	pH Stable
a6598a29-6c79-4e54-9d5c-f2fc69450dd1	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:14:53.29+02	0.00	Standby
61935349-a358-4a18-b00a-e2b99714bd96	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:14:53.296+02	79.78	Auto: VFD Mode | Lvl: 50.8% | Trnd: 0.20
7adc56c5-c3c2-40b6-9393-6fb4098800f7	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:14:53.397+02	0.00	Standby
854d4da6-7b40-4065-afbd-8c65d453f6dc	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:14:58.109+02	0.81	Auto PID: Target=6.0, Err=-0.01
4a3d264c-eee5-43d7-ab2c-b726b6ab7c65	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:14:58.18+02	0.00	pH Stable
8d69be08-fdf9-4aa3-85b3-16e4b7e83b65	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:14:58.181+02	0.00	pH Stable
a5c04d8d-1281-4858-b08e-57c84ce3b25d	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:14:58.181+02	63.83	Auto ORP: Deficit=95.75, pH-Eff=1
192e6666-94c5-44a7-b317-6b1a759899c1	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:14:58.182+02	0.00	Standby
992dc608-b42d-47c7-814c-25dacf50f563	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:14:58.271+02	0.00	Standby
0f5e6153-2268-419b-bcc2-84e0252f6e4d	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:14:58.271+02	78.69	Auto: VFD Mode | Lvl: 50.8% | Trnd: 0.21
e8121eda-dd15-4d87-8e6c-b8a703246b7f	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:16:08.952+02	1.37	Auto PID: Target=6.0, Err=0.01
7b42d74a-9ff3-49a7-998d-4f8c3efb53b7	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:16:09.01+02	0.00	pH Stable
d82b2873-45a8-4857-8295-9b82a5e19da8	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:16:09.012+02	0.00	pH Stable
a7dbc60e-c404-4e1d-a562-ba0e59320556	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:16:09.012+02	62.69	Auto ORP: Deficit=94.03999999999996, pH-Eff=1
8dd0b6e3-0061-449c-8b1e-473e5a82740a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:16:09.019+02	0.00	Standby
14113413-a1b0-4627-a7a3-c43e81170cc9	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:16:09.023+02	81.56	Auto: VFD Mode | Lvl: 50.9% | Trnd: 0.22
5f568e6f-b524-4c22-9c4b-1212864b8c7a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:16:09.119+02	0.00	Standby
58bd600a-e8d1-4247-96dd-b9238cacbab2	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:16:13.923+02	2.49	Auto PID: Target=6.0, Err=0.05
f6676855-e310-4ddf-b84e-6ca45204cfdf	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:16:14.003+02	0.00	pH Stable
5bd50091-c321-4dc7-8c0f-69503bb1982a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:16:14.004+02	0.00	Standby
c26cec8d-376a-4fb6-9d40-000bb9552e19	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:16:14.005+02	0.00	pH Stable
52e11996-5914-4a71-8f76-c3b6eba3da02	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:16:14.006+02	61.62	Auto ORP: Deficit=92.42999999999995, pH-Eff=1
e5a71bd6-6581-4e7a-b4cc-9e1820d67c25	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:16:19.095+02	0.00	Standby
19424750-b307-4f96-a9f1-34c45dc16090	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:16:19.095+02	0.00	Standby
8c8b3a44-97bd-4603-8fc4-01b54d3a280c	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:16:19.098+02	81.39	Auto: VFD Mode | Lvl: 50.9% | Trnd: 0.23
31e92224-01f4-4b51-a395-076dd2b93271	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:16:24.168+02	0.00	Auto: DO Optimal
8fedcefd-8573-4671-aee1-5bbb3f38b35e	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:16:24.169+02	0.00	Standby
5a34d7fd-1250-4537-af24-6d3d84a4defa	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:16:24.169+02	0.00	Standby
2fd959fb-ca51-4dd9-b751-72473537a2bf	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:16:14.006+02	82.12	Auto: VFD Mode | Lvl: 50.9% | Trnd: 0.23
f435d012-6584-453b-910c-0fc1e66b0ebe	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:16:14.006+02	0.00	Standby
84a53574-642c-4afc-9232-5b118fda3576	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:16:18.995+02	3.61	Auto PID: Target=6.0, Err=0.09
96420c57-2344-475a-9700-7889c88d7a9b	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:16:19.093+02	0.00	pH Stable
9f04700d-dc3b-445f-8810-3f96f03401b5	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:16:19.096+02	0.00	pH Stable
3a395bcd-0ec6-43d6-b5e7-3a134d3e9fcd	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:16:19.097+02	60.57	Auto ORP: Deficit=90.85000000000002, pH-Eff=1
85066815-d482-4755-8a56-09bef5deeae7	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:16:24.171+02	0.00	pH Stable
db585654-21bc-4dea-b706-73ed90407455	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:16:24.172+02	59.54	Auto ORP: Deficit=89.30999999999995, pH-Eff=1
c880816c-15fc-43fa-89ea-4d64d71773c4	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:16:24.174+02	0.00	pH Stable
46ba2309-f690-44b5-b153-c09f88caf27d	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:16:24.169+02	86.41	Auto: VFD Mode | Lvl: 63.4% | Trnd: 3.36
bc22ff5e-1eac-4d25-9e44-d4a40853cc81	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:17:11.155+02	0.00	Auto: DO Optimal
327d9656-19ef-4e9f-be17-e95b0c030ac1	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:17:11.192+02	58.55	Auto ORP: Deficit=87.83000000000004, pH-Eff=1
ccb173fd-fb34-444e-8131-a6fc9fa63dbe	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:17:11.218+02	0.00	pH Stable
975f5dc5-b3c5-44ea-a912-c61282491989	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:17:11.221+02	0.00	pH Stable
11f6f39d-3c33-4355-84be-2cfb317d3e38	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:17:11.23+02	0.00	Standby
6b3f77d2-e438-46aa-8bd1-d55296380860	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:17:11.231+02	86.78	Auto: VFD Mode | Lvl: 63.4% | Trnd: 3.36
c0d41b4b-b6ba-47e7-b081-05ad2a7de901	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:17:11.265+02	0.00	Standby
9b145272-6e8e-443f-8299-b153c0c4e674	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:17:16.344+02	100.00	Auto: turbidity Limit
821c3439-7574-4899-b697-ece99a3a132e	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:17:16.343+02	0.00	Auto: DO Optimal
fca8be28-2620-4db3-94de-f9c44b714f73	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:17:16.345+02	0.00	pH Stable
ff26c435-d942-4860-b7d2-4a89d44fe029	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:17:16.346+02	57.61	Auto ORP: Deficit=86.41999999999996, pH-Eff=1
df1e9f5e-d249-4d9d-8083-85dcc94f34eb	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:17:16.348+02	0.00	pH Stable
4ab68165-dda0-4741-a133-5c0e652bed0a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:17:16.402+02	0.00	Standby
4874f05f-aec9-4ec3-8f45-a67641dd2793	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:17:16.403+02	86.64	Auto: VFD Mode | Lvl: 63.3% | Trnd: 3.35
a35f1767-a87a-4e9c-a5fb-afe7554c9c2e	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:17:21.508+02	0.00	Auto: DO Optimal
b38adac9-e0c6-42f2-8837-db36ac053fb1	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:17:21.508+02	0.00	Standby
4f808c7b-cbdd-4940-9ace-c5615d54c112	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:17:21.508+02	100.00	Auto: turbidity Limit
07313d01-7c0a-45b8-9774-03a87990aa41	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:17:21.509+02	85.57	Auto: VFD Mode | Lvl: 63.3% | Trnd: 3.33
2e1eb37d-22f0-4907-97dd-0b7d415d75d6	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:17:21.509+02	0.00	pH Stable
67557960-9d99-4193-b4b5-b76659cb07dd	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:17:21.51+02	56.69	Auto ORP: Deficit=85.03999999999996, pH-Eff=1
a255bc07-3b4a-4704-a0c6-86c792e50bb5	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:17:21.511+02	0.00	pH Stable
0aaeb23d-5959-4eee-a30a-6844f9ab6455	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:17:26.379+02	0.00	Auto: DO Optimal
c3ab2eaa-de4a-4c12-acc1-54cf8ca0c6fc	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:17:26.429+02	0.00	pH Stable
4bcdf250-9c54-4d0c-b178-03d5df222e89	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:17:26.43+02	100.00	Auto: turbidity Limit
7947e6bc-d71c-4b6f-a720-12f3c3eae5a0	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:17:26.43+02	0.00	pH Stable
a18f3673-d23b-4b2a-80e7-c04f6d90295a	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:17:26.43+02	55.79	Auto ORP: Deficit=83.69000000000005, pH-Eff=1
18d81b78-13fc-42bb-b702-6d8a7ac12864	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:17:26.44+02	0.00	Standby
ca087b42-6d38-4c80-b839-77815155424a	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:17:26.441+02	85.48	Auto: VFD Mode | Lvl: 63.3% | Trnd: 3.33
83f93f51-6080-484a-a0a9-fdd1d996655b	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:17:54.9+02	0.00	Auto: DO Optimal
7d49dce6-8ace-4c1a-b27c-52697d3eea21	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:17:54.947+02	0.00	pH Stable
0fe78783-f2be-42c7-9c93-7efb0a23ec96	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:17:54.95+02	0.00	pH Stable
0d722f5c-1bda-468e-8284-8e1eae77c508	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:17:54.978+02	100.00	Auto: turbidity Limit
eccd2873-9aca-41bb-aaee-23ddf440f8f9	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:17:54.979+02	54.95	Auto ORP: Deficit=82.41999999999996, pH-Eff=1
3ca48bc9-5db0-45ba-b8a4-4b2575391a3c	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:17:55.046+02	85.70	Auto: VFD Mode | Lvl: 63.3% | Trnd: 3.33
63fc0391-ff9f-4603-ba9e-3f42e442de95	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:17:55.05+02	100.00	Auto: Predictive Wash (pressure rising fast)
1ecc8cb4-6c03-45f6-9161-b598488cc2d4	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:17:59.979+02	0.00	Auto: DO Optimal
3833a331-e3e8-4bb9-af2f-e10a0b1137f9	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:17:59.982+02	0.00	pH Stable
b28abe71-169f-46c5-b8fc-5b87dde47a28	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:17:59.982+02	100.00	Auto: turbidity Limit
d7b9dfb7-6dc6-40f9-bd67-01bc50dc5dc2	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:17:59.984+02	0.00	pH Stable
449fac74-5da7-4040-873c-4dd1a4cab045	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:17:59.984+02	54.11	Auto ORP: Deficit=81.16999999999996, pH-Eff=1
8f233819-460d-4459-8b95-7641eee6ad9b	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:18:00.034+02	0.00	Standby
619dfbaa-00df-4923-813c-6904851b75c3	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:18:00.035+02	85.05	Auto: VFD Mode | Lvl: 63.2% | Trnd: 3.32
46a83ef0-4a10-493c-9a3c-395903dbe688	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:18:04.997+02	0.00	Auto: DO Optimal
be439f71-084e-4d05-a4e6-98a05ae8975a	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:18:05.03+02	0.00	pH Stable
ceaa814e-336d-40f3-b2e1-7809c3f5701f	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:18:05.031+02	100.00	Auto: turbidity Limit
ad84e692-4cfa-4386-a7b7-324d4409a798	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:18:05.031+02	0.00	pH Stable
d398b029-62cd-44e4-847c-5c51fa9735f2	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:18:05.032+02	53.32	Auto ORP: Deficit=79.98000000000002, pH-Eff=1
f8de4028-4904-4dba-a29c-a5d3fdda365f	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:18:05.061+02	0.00	Standby
a1ad8b0b-0576-4dbc-be96-4b4f79be7ca4	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:18:05.061+02	87.56	Auto: VFD Mode | Lvl: 63.2% | Trnd: 3.31
d97021c2-e93e-439c-932c-933f52abd74d	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:18:10.069+02	0.00	Auto: DO Optimal
f955d0f0-fe91-4285-8073-796ee96b87f3	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:18:10.109+02	0.00	pH Stable
6d2eb1d3-16f9-4df8-98ca-826e522564ab	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:18:10.11+02	100.00	Auto: turbidity Limit
98921b63-7488-484d-8b44-5ada9ddcd69c	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:18:10.111+02	0.00	pH Stable
c9617e58-f167-4481-b6ef-cc8217f38bfc	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:18:10.112+02	52.55	Auto ORP: Deficit=78.82000000000005, pH-Eff=1
5b85692e-9ce1-4cbb-8dca-daa72630ea05	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:18:10.155+02	0.00	Standby
75453dbf-9fc5-4949-bceb-0eee52970be4	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:18:10.156+02	85.73	Auto: VFD Mode | Lvl: 63.1% | Trnd: 3.30
5947961a-0a2b-46fc-a831-a3f08d6394c2	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:19:37.147+02	0.00	Auto: DO Optimal
45073f2f-851b-4055-a716-5d89ea688f2e	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:19:37.213+02	0.00	pH Stable
0ce6fbad-f2ee-49ee-ad4f-ba57759a0c50	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:19:37.215+02	0.00	pH Stable
b58bef92-13b9-4f06-a495-1b0b46d8503c	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:19:37.215+02	100.00	Auto: turbidity Limit
16a77687-00a6-4ab2-8fff-322913e960de	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:19:37.216+02	51.80	Auto ORP: Deficit=77.70000000000005, pH-Eff=1
baa2e59f-73f2-4cc7-a580-06ad116edd8d	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:19:37.219+02	0.00	Standby
d811609a-7ccb-4177-a432-d0faefd33a1f	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:19:37.221+02	88.26	Auto: VFD Mode | Lvl: 63.2% | Trnd: 3.32
91654dba-bd80-4e8d-81a4-d720fe88e0ee	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:19:42.187+02	0.00	Auto: DO Optimal
728a6980-8fff-4eb4-9061-25944e928c66	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:19:42.226+02	0.00	pH Stable
8d78ae9d-fd6b-4887-a038-dc0b454d76bf	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:19:42.228+02	0.00	pH Stable
221a9a2d-6e9e-45a6-9a1c-641c4337770e	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:19:42.228+02	100.00	Auto: turbidity Limit
88f224d8-3b7d-45ea-8817-69b9426e0968	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:19:42.228+02	0.00	Standby
f1b22f7a-8f9e-493d-8cd4-0a6cc2758124	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:19:42.229+02	51.07	Auto ORP: Deficit=76.60000000000002, pH-Eff=1
e82785d4-f749-46d7-a3d6-506974a78eb1	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:19:42.229+02	85.88	Auto: VFD Mode | Lvl: 63.2% | Trnd: 3.31
6988c346-c2d9-4327-bc80-5994503c833e	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:19:47.499+02	0.00	Auto: DO Optimal
b9bf1843-e8db-4d58-8ccf-c8ed4aa37f67	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:19:47.5+02	0.00	Standby
23408c8a-3f86-4220-aaf8-3a8c8fb994c2	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:19:47.503+02	100.00	Auto: turbidity Limit
b2ae47ca-1019-4c99-920b-aa700257d9e5	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:19:47.504+02	88.45	Auto: VFD Mode | Lvl: 63.2% | Trnd: 3.31
901f6341-e4ef-4c70-be0d-a4c00bd85116	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:19:47.505+02	0.00	pH Stable
c0e0f1ef-44a0-49cf-8ab6-9368100ab72b	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:19:47.505+02	50.36	Auto ORP: Deficit=75.53999999999996, pH-Eff=1
c191763a-8b43-432b-b542-6f4ea1eaefa4	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:19:47.509+02	0.00	pH Stable
84f7fcae-e2bb-4458-b2f5-60ec7e1e8663	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:19:52.413+02	49.68	Auto ORP: Deficit=74.51999999999998, pH-Eff=1
e96ec67b-3069-4820-ba31-2e3b8395b6ab	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:19:52.413+02	0.00	pH Stable
5791bece-0495-4830-b3b0-4f22fd80dc3b	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:19:52.412+02	0.00	Auto: DO Optimal
347d3269-2a92-4835-86dd-d1ae7e282237	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:19:52.415+02	0.00	pH Stable
4400def8-4967-4adc-9184-0c3b656fd212	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:19:52.438+02	100.00	Auto: turbidity Limit
0206ca72-99dd-4947-ac70-969bd73a3131	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:19:52.519+02	0.00	Standby
675dde21-a73c-4e92-9a0c-683e6766eb74	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:19:52.52+02	86.71	Auto: VFD Mode | Lvl: 63.2% | Trnd: 3.31
f618c4fa-bc84-412a-a11d-b68a86c0e368	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:20:05.556+02	0.00	Auto PID: Target=6.0, Err=-0.49
95d31ddc-7d62-4d14-8f34-ce5773886437	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:20:05.62+02	0.00	pH Stable
c041227b-679a-4801-9d82-1885de6b4bb4	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:20:05.62+02	93.87	Auto ORP: Deficit=140.80999999999995, pH-Eff=1
8ac49554-b007-4c27-8742-b6bb0131fa2b	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:20:05.623+02	0.00	pH Stable
f8a84802-08a7-4d30-9e20-3022f9a1186a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:05.622+02	0.00	Standby
16068040-ccd9-421b-8a02-a42c334c1af9	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:05.626+02	0.00	Standby
b8333ec0-d463-4502-a885-5705bbecb119	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:20:05.63+02	70.52	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.00
a2a35da4-273a-421b-abcf-db61570ed893	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:20:10.751+02	0.00	Auto PID: Target=6.0, Err=-0.45
f003c313-93d8-440b-b05c-f275dd85f141	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:10.751+02	0.00	Standby
6fef94ab-86e9-4763-8f45-664913ecec9f	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:20:10.751+02	80.00	Auto: VFD Mode | Lvl: 50.1% | Trnd: 0.04
49d3eebc-7790-4bd8-a984-47a352cc3b6c	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:10.752+02	0.00	Standby
21fa0a34-d88e-444d-a73c-f6221b4665e5	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:20:10.752+02	91.74	Auto ORP: Deficit=137.61, pH-Eff=1
4a58ec16-8782-4615-a55c-a3102671ee9e	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:20:10.753+02	100.00	Auto pH-: LogFactor=9527303589816260608.0
41fab3f9-0a76-4f94-98ee-63df11392e59	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:20:10.755+02	0.00	Standby (pH High)
2b43fc3d-3b06-44ad-a529-7634a02d89be	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:20:15.625+02	0.00	Auto PID: Target=6.0, Err=-0.43
642fb795-82db-4d55-b647-ec99dff8f2a3	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:15.626+02	0.00	Standby
e616b4ff-8c5c-4493-8d8e-b1492ad10141	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:15.626+02	0.00	Standby
76e33e5b-9b98-476f-a648-98d990d2bc83	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:20:15.626+02	100.00	Auto pH-: LogFactor=6151343854061905920.0
8e65d359-63d8-448f-8c84-1b41ec882de2	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:20:15.626+02	95.81	Auto: VFD Mode | Lvl: 79.2% | Trnd: 7.31
0273ea5f-06ce-4362-bcf8-a7701ec3211f	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:20:15.626+02	89.67	Auto ORP: Deficit=134.51, pH-Eff=1
d9c70c6a-ba03-48b5-be10-9f292dd6e983	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:20:15.628+02	0.00	Standby (pH High)
b220bf93-0f80-420c-8817-a515df1e391b	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:20:20.683+02	0.00	Auto PID: Target=6.0, Err=-0.39
6a19575f-e30c-46aa-88a6-c8c2b32f3f74	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:20.684+02	0.00	Standby
b8776257-0dad-437e-a176-480c609659a3	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:20.684+02	0.00	Standby
422128d1-2498-4221-a0a9-6f14903febb5	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:20:20.684+02	92.96	Auto: VFD Mode | Lvl: 79.0% | Trnd: 7.27
9ffb6c23-9eca-45af-b8d6-56a54a50beec	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:20:20.684+02	87.68	Auto ORP: Deficit=131.51999999999998, pH-Eff=1
1df879d0-3c63-4f24-8c77-a469a954470a	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:20:20.684+02	100.00	Auto pH-: LogFactor=3971641173621394432.0
d7c74f56-7f97-4fdb-95dd-b2231a42b7fb	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:20:20.686+02	0.00	Standby (pH High)
2eac97bc-329b-4b8e-bc85-fe5b3553e570	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:20:45.282+02	92.61	Auto ORP: Deficit=138.91999999999996, pH-Eff=1
8810b0da-8b58-48c2-aa60-6530ddd6b8a7	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:45.335+02	0.00	Standby
2b2aeb0c-e9a6-4503-b61d-9fbe6a8f5090	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:20:45.353+02	0.00	pH Stable
15acf572-bd9e-448c-8f91-12ef2ebf9d6b	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:20:45.357+02	0.00	pH Stable
bd6006a3-78b1-4f98-a92e-b166cb6c2e75	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:20:45.357+02	0.00	Auto PID: Target=6.0, Err=-0.51
44e42f0c-dfd5-4313-8963-8865b14ae440	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:45.399+02	0.00	Standby
36325ea5-6378-40de-9d89-94b3f4ba5995	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:20:45.5+02	71.31	Auto: VFD Mode | Lvl: 49.9% | Trnd: -0.02
7f111b77-959c-4340-ade1-70bbcb3deab2	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:20:50.468+02	100.00	Auto PID: Target=6.0, Err=23.29
2771e15a-4483-42f0-99cd-98e142a070af	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:50.468+02	0.00	Standby
3ac059ec-07da-4e01-89a4-006ec64e8468	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:50.469+02	0.00	Standby
c8f55db3-588c-4f4f-82b1-084c8a49df59	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:20:50.47+02	79.54	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.02
1db2957d-9522-4f0c-a812-64e57241be6c	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:20:50.47+02	90.52	Auto ORP: Deficit=135.77999999999997, pH-Eff=1
13226b31-5b85-4da6-a775-53e4ac3954bb	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:20:50.47+02	0.00	pH Stable
17835ddd-11e2-4294-b406-83226e7d1b31	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:20:50.472+02	0.00	pH Stable
0f972c6b-6336-4149-b8b3-fbcdb2f24a64	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:20:55.409+02	100.00	Auto PID: Target=6.0, Err=6.00
0aadc75a-9c27-412a-82ce-a604a78bfa76	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:20:55.435+02	0.00	pH Stable
1f558d80-dc82-4b37-a023-f8a55073ac1e	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:55.435+02	0.00	Standby
c318508b-9459-402b-b297-082ed62b1dcb	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:20:55.435+02	88.50	Auto ORP: Deficit=132.75, pH-Eff=1
e01f158f-b3cb-481f-bf6c-9b1308ab9934	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:20:55.436+02	0.00	pH Stable
ecbc8e43-42ab-4c84-9b58-0f743f059c25	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:20:55.481+02	0.00	Standby
94a9d8aa-3587-4d4a-9b64-5ee526169472	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:20:55.482+02	78.25	Auto: VFD Mode | Lvl: 50.1% | Trnd: 0.03
11e5161d-72c7-4aa6-a501-2ede201361b1	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:21:20.096+02	0.00	Auto PID: Target=6.0, Err=-0.65
13d96573-746f-4ecf-a4ac-cb75fbe91396	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:21:20.168+02	0.00	pH Stable
6b0095fd-f135-4db0-b514-eda14f6f1ec2	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:21:20.172+02	0.00	pH Stable
9e169e54-3ac3-45ab-88ca-ccf8ad846c63	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:20.21+02	0.00	Standby
0e686a99-e31c-4ec4-baba-b3d3f900b731	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:21:20.211+02	92.60	Auto ORP: Deficit=138.89999999999998, pH-Eff=1
c1817be9-aea9-45d9-82f8-3543e5db6387	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:21:20.314+02	79.80	Auto: VFD Mode | Lvl: 50.0% | Trnd: 0.02
51ea46aa-692d-4330-a1c0-3e2f82a56c9f	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:20.315+02	0.00	Standby
94634dd5-d658-46d5-bc6c-129f8d15ff09	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:21:25.25+02	0.00	Auto PID: Target=6.0, Err=-0.62
5a30d771-f5c5-4d68-a139-8ae716208f31	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:25.252+02	0.00	Standby
b87f572a-4855-4846-bf7d-6621753ad700	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:25.252+02	0.00	Standby
a2dfd24d-ffce-48ed-bffa-5e00e4361f5f	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:21:25.253+02	0.00	pH Stable
5fd42b19-cbbf-4738-80a8-8ae7d2bb2f08	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:21:25.254+02	90.51	Auto ORP: Deficit=135.76999999999998, pH-Eff=1
76a53c09-0c9d-45f8-b7fd-22233222bb82	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:21:25.255+02	0.00	pH Stable
74edd3d6-a40f-4a6f-afe3-b7aab5dfeb32	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:21:25.322+02	79.95	Auto: VFD Mode | Lvl: 50.1% | Trnd: 0.03
2b14c7d6-bfef-4688-8ecf-22ab09e8bbfe	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:21:30.25+02	0.00	Auto PID: Target=6.0, Err=-0.58
4f866031-0400-42b9-b111-605d4ed8a9ae	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:30.25+02	0.00	Standby
1f2360b4-2ba2-45c3-8be4-d7e3a595b4ac	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:21:30.251+02	88.50	Auto ORP: Deficit=132.75, pH-Eff=1
2c874fc9-8393-4528-8807-558d4cd46b94	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:21:30.252+02	0.00	pH Stable
1000bc95-af2b-4841-b45e-0929f0c91fce	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:21:30.254+02	0.00	pH Stable
e7bb0ab4-1012-4e46-9cfc-3be75d87adca	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:30.338+02	0.00	Standby
9dfe1fe2-8da6-4d6b-9a61-2fe25f023add	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:21:30.338+02	80.04	Auto: VFD Mode | Lvl: 50.1% | Trnd: 0.04
2014e8f8-3d75-4a5f-984d-f3880bbf33f8	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:21:35.399+02	0.00	Auto PID: Target=6.0, Err=-0.57
6ed205f2-6c5e-4981-b846-153f863455b9	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:35.4+02	0.00	Standby
a3068c64-7539-4d12-a554-0702819d64f8	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:21:35.401+02	0.00	pH Stable
f65707cf-7497-4582-b692-5cd8fb0a08d4	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:21:35.402+02	86.56	Auto ORP: Deficit=129.84000000000003, pH-Eff=1
5a85cdad-4bcd-4eca-adf7-2c75009e88e0	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:21:35.404+02	0.00	pH Stable
459eb48d-9da9-4bd4-b633-6c2dca190f54	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:35.471+02	0.00	Standby
d0c1fac4-596c-4e99-8c51-f337eaa03ba5	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:21:35.474+02	81.41	Auto: VFD Mode | Lvl: 50.2% | Trnd: 0.05
5b72ea68-f547-40a7-b672-41f142ebadde	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:21:40.579+02	0.00	Auto PID: Target=6.0, Err=-0.54
a91f5537-0597-4aa2-b1fd-5d1a542fba87	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:40.579+02	0.00	Standby
094f4202-854f-4dbd-98bd-4c677d924ddb	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:40.579+02	0.00	Standby
df000b6c-7664-4f57-ba97-63b9488b4a14	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:21:40.579+02	0.00	pH Stable
8b462890-ab35-4e8d-9ab5-a942a73ebde8	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:21:40.58+02	78.74	Auto: VFD Mode | Lvl: 50.2% | Trnd: 0.06
75463ea3-6b18-466a-aa27-edebef3d733a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:44.941+02	0.00	Standby
c94d47a9-9f33-42ef-86dd-04511ca249a9	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:21:49.973+02	86.63	Auto ORP: Deficit=129.94000000000005, pH-Eff=1
35270394-9227-4bfd-8873-6cd042e55451	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:50+02	0.00	Standby
a586c7c1-db5b-408f-87ca-3c26b6c0413c	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:21:40.581+02	0.00	pH Stable
da542e03-5dc1-4ca6-8c83-e9dcb48ac19c	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:21:40.581+02	84.69	Auto ORP: Deficit=127.02999999999997, pH-Eff=1
7120bd7d-4385-42c1-9476-3757a5bf97c4	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:21:44.861+02	0.00	Auto PID: Target=6.0, Err=-0.50
1de5bf6a-1e18-436c-9b90-08c5d49c07a5	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:21:44.861+02	0.00	pH Stable
1d23da15-39ba-4797-89ac-177945f8be76	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:21:44.863+02	0.00	pH Stable
79a20d84-182a-4124-8cd5-78420cf39637	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:44.941+02	0.00	Standby
ea5dd160-b95c-4128-95be-3d127531c00a	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 11:21:44.941+02	82.86	Auto ORP: Deficit=124.28999999999996, pH-Eff=1
0d693185-fcb2-4d6f-8745-cb1ddfeaf9c4	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:21:45.023+02	80.40	Auto: VFD Mode | Lvl: 50.3% | Trnd: 0.08
36d11e2b-22c3-4625-b8a5-fe5705e084e8	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 11:21:49.921+02	0.00	Auto PID: Target=6.0, Err=-0.49
9e35c1e2-2f84-4bba-9849-b66f1fe7201f	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 11:21:49.972+02	0.00	pH Stable
3661700f-ae50-4a3a-80b0-4d8fa9715b00	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 11:21:49.973+02	0.00	pH Stable
3d3d0a97-3018-4076-bb83-d6a7e01e120d	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 11:21:49.973+02	0.00	Standby
9167321f-dc6d-4559-806b-3da4b8d30c40	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 11:21:50.001+02	80.33	Auto: VFD Mode | Lvl: 50.3% | Trnd: 0.09
69240baa-855f-4b1f-aaee-ff5ab127dbc1	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 12:58:44.653+02	0.00	Auto PID: Target=6.0, Err=-0.45
6e870564-8890-4765-8290-eccba7e702e8	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:58:44.715+02	0.00	Standby
d5eabae4-b1fb-41ea-9c22-26a838a77809	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 12:58:49.511+02	0.00	Auto PID: Target=6.0, Err=-0.41
a9138fc4-c06a-4b74-9a9e-c20452d46939	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 12:58:49.556+02	0.00	pH Stable
d559e246-7b81-4b3d-aac2-9898a78b1e8a	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 12:58:49.557+02	0.00	pH Stable
66f43802-b597-4e92-acb0-cc3585dd8752	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 12:58:49.573+02	79.84	Auto: VFD Mode | Lvl: 50.4% | Trnd: 0.11
ed6cd9db-c082-45af-83db-adec718ca6f5	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 12:58:54.726+02	0.00	Auto PID: Target=6.0, Err=-0.39
769ada63-bfd1-4b7a-aec4-752ebbf85c81	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:58:54.727+02	0.00	Standby
9fd8a3cf-db33-42cb-a85d-eaa64dddbba0	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:58:59.972+02	0.00	Standby
887d5623-aa7a-4411-9c11-c1562d2d8ee7	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:59:04.907+02	0.00	Standby
94cff857-85ba-4d6f-94b2-a52e37600ed8	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 12:59:47.18+02	0.00	pH Stable
3fd838df-98fc-48a1-ac61-9a4112bc438f	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 12:59:47.182+02	0.00	pH Stable
81182b05-b763-4760-a124-7a582f52c05d	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 12:59:47.19+02	76.21	Auto ORP: Deficit=114.32000000000005, pH-Eff=1
be34afcc-03ec-4612-85f9-8c8ff2b1218b	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 12:59:51.353+02	80.67	Auto: VFD Mode | Lvl: 50.6% | Trnd: 0.03
ff86be5a-ce63-4d63-9edd-6947f5d59c81	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 12:59:51.353+02	0.00	pH Stable
bdb5a928-ac48-43ed-9c5f-af2826b9153a	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 12:59:51.36+02	0.00	pH Stable
ecf7076b-7238-47cb-a98f-ab7129f2c404	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 12:58:44.713+02	0.00	pH Stable
e731af80-d53b-4cc3-8183-5f1007f80c1f	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 12:58:44.716+02	0.00	pH Stable
d15c220c-8f5e-4af3-bc4e-43f9a4fd5c47	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:58:44.727+02	0.00	Standby
0cdca234-f55b-447c-ac7b-62cad9430a69	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 12:58:49.556+02	82.93	Auto ORP: Deficit=124.39999999999998, pH-Eff=1
455748bb-cad5-430f-8130-50c452821679	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:58:49.572+02	0.00	Standby
2e01c20b-554e-46a6-9d54-0f6ad2b9c3f2	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 12:58:54.728+02	0.00	pH Stable
de0b46c2-c65c-44c0-a920-cfb67f64a054	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 12:58:54.731+02	78.53	Auto: VFD Mode | Lvl: 50.5% | Trnd: 0.12
66d5080f-fc79-4a56-ba18-ab2b0819bd63	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 12:58:54.733+02	0.00	pH Stable
54929d9b-ec8c-45b5-b0e5-24ddbb2cd754	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 12:58:59.97+02	0.00	Auto PID: Target=6.0, Err=-0.34
95a6d644-682a-452d-bd4b-6ed1844d0e30	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:58:59.971+02	0.00	Standby
ffe645f6-50e3-401c-977c-14bc5569c42c	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 12:58:59.973+02	79.45	Auto ORP: Deficit=119.16999999999996, pH-Eff=1
0ca4d75c-0ba3-4f65-b672-b3795f0d083c	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:59:04.907+02	0.00	Standby
b158d3f9-f1c9-404b-983c-809702003190	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 12:59:04.908+02	0.00	pH Stable
b9b0b8ab-0892-4d12-88b3-d1919cbbb87f	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 12:59:04.909+02	80.17	Auto: VFD Mode | Lvl: 50.5% | Trnd: 0.04
bd619bd8-ec32-402c-8651-88fedded060d	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 12:59:04.91+02	0.00	pH Stable
d5645d26-a6b5-4840-acf5-48e6bd9d73c0	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:59:47.188+02	0.00	Standby
0fba59ef-84b5-4814-b939-0426f5e69731	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 12:59:47.193+02	79.04	Auto: VFD Mode | Lvl: 50.6% | Trnd: 0.03
9a1e3d7c-e71f-417d-beeb-839a27468d7a	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 12:59:51.351+02	0.00	Auto PID: Target=6.0, Err=-0.27
ad282752-27f7-43ce-afef-765685d0ec9e	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:59:51.352+02	0.00	Standby
6c8b1f4c-15f5-441d-9bca-92f4a2a72282	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 12:58:44.715+02	84.75	Auto ORP: Deficit=127.12, pH-Eff=1
ce276804-afd5-478d-a981-12ac08c5e9fc	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 12:58:44.727+02	78.70	Auto: VFD Mode | Lvl: 50.3% | Trnd: 0.10
189c36bc-fd55-4b66-bd03-40be92f76c01	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:58:49.555+02	0.00	Standby
e13f4682-da19-4e17-af73-e46aef0ff3d7	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:58:54.727+02	0.00	Standby
1d981dc1-fb94-4e2c-828b-8551f840afa9	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 12:58:54.728+02	81.16	Auto ORP: Deficit=121.74000000000001, pH-Eff=1
a1eb1757-672b-4845-8950-0a5ee8f9c073	b2c3d4e5-f6a7-4000-8000-000000000002	2025-12-26 12:58:59.972+02	0.00	pH Stable
4c805fc9-0f65-42a9-a576-929a6c961c92	b2c3d4e5-f6a7-4000-8000-000000000005	2025-12-26 12:58:59.972+02	80.67	Auto: VFD Mode | Lvl: 50.5% | Trnd: 0.04
1f3e4cae-fb50-403d-9714-28d465c6389c	b2c3d4e5-f6a7-4000-8000-000000000007	2025-12-26 12:58:59.975+02	0.00	pH Stable
2cc202d6-a485-4161-b575-05b9681d254a	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 12:59:04.906+02	0.00	Auto PID: Target=6.0, Err=-0.33
77216474-4220-451c-b104-7c0fe9be841d	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 12:59:04.908+02	77.81	Auto ORP: Deficit=116.71000000000004, pH-Eff=1
d4f6ea56-81c8-4e08-8781-f8703a755a94	b2c3d4e5-f6a7-4000-8000-000000000001	2025-12-26 12:59:47.115+02	0.00	Auto PID: Target=6.0, Err=-0.30
53fcc0bc-fff8-4253-983e-eeb65cd45f7a	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:59:47.189+02	0.00	Standby
281edd59-662b-467b-8dfe-34c4a0e3fe65	b2c3d4e5-f6a7-4000-8000-000000000004	2025-12-26 12:59:51.353+02	0.00	Standby
4ec25cbe-0b80-49a2-ab9e-72f976ce49cd	b2c3d4e5-f6a7-4000-8000-000000000003	2025-12-26 12:59:51.355+02	74.66	Auto ORP: Deficit=111.99000000000001, pH-Eff=1
\.


--
-- Data for Name: controllers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.controllers (id, station_id, name, type, is_active) FROM stdin;
b2c3d4e5-f6a7-4000-8000-000000000006	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	City Inlet Valve	valve	t
b2c3d4e5-f6a7-4000-8000-000000000001	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	Main Aerator	aerator	f
b2c3d4e5-f6a7-4000-8000-000000000005	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	Main Intake Pump	pump	t
b2c3d4e5-f6a7-4000-8000-000000000002	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	Acid Pump (pH-)	dispenser_acid	f
b2c3d4e5-f6a7-4000-8000-000000000004	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	Backwash Pump	filter	f
b2c3d4e5-f6a7-4000-8000-000000000003	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	Chlorine Injector	dispenser_chlorine	t
b2c3d4e5-f6a7-4000-8000-000000000007	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	Alkali Pump (pH+)	dispenser_alkali	f
\.


--
-- Data for Name: parameters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parameters (id, code, name, unit) FROM stdin;
104c2560-5a3d-4562-9781-630d4a973001	dissolved_oxygen	Розчинений кисень (DO)	mg/L
204c2560-5a3d-4562-9781-630d4a973002	ph_level	Рівень pH	pH
304c2560-5a3d-4562-9781-630d4a973003	orp	Окислювальний потенціал (ORP)	mV
404c2560-5a3d-4562-9781-630d4a973004	turbidity	Каламутність (Turbidity)	NTU
504c2560-5a3d-4562-9781-630d4a973005	pressure	Тиск у системі	Bar
604c2560-5a3d-4562-9781-630d4a973006	water_level	Рівень води в резервуарі	%
704c2560-5a3d-4562-9781-630d4a973007	temperature	Температура води	°C
\.


--
-- Data for Name: sensors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sensors (id, station_id, parameter_id, model, serial_number, is_active, type) FROM stdin;
a1b2c3d4-e5f6-4000-8000-000000000001	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	104c2560-5a3d-4562-9781-630d4a973001	OxyGuard-Pro	SN-DO-101	t	do_meter
a1b2c3d4-e5f6-4000-8000-000000000002	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	204c2560-5a3d-4562-9781-630d4a973002	Atlas-pH-Industrial	SN-PH-202	t	ph_meter
a1b2c3d4-e5f6-4000-8000-000000000003	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	304c2560-5a3d-4562-9781-630d4a973003	Redox-Gold-X	SN-ORP-303	t	orp_meter
a1b2c3d4-e5f6-4000-8000-000000000004	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	404c2560-5a3d-4562-9781-630d4a973004	TurbiMax-Laser	SN-TB-505	t	turbidity_meter
a1b2c3d4-e5f6-4000-8000-000000000005	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	504c2560-5a3d-4562-9781-630d4a973005	Baro-Press-10	SN-BAR-808	t	pressure_sensor
a1b2c3d4-e5f6-4000-8000-000000000006	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	604c2560-5a3d-4562-9781-630d4a973006	UltraSonic-LvL	SN-LVL-707	t	level_sensor
a1b2c3d4-e5f6-4000-8000-000000000007	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	704c2560-5a3d-4562-9781-630d4a973007	PT100-Immersion	SN-TMP-606	t	thermometer
\.


--
-- Data for Name: station_thresholds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.station_thresholds (id, station_id, parameter_id, min_warning, max_warning, min_critical, max_critical) FROM stdin;
8fb6e8cb-33f7-4c6a-8e28-140a3be584ea	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	104c2560-5a3d-4562-9781-630d4a973001	5	10	3	15
d11da833-2225-45f5-92a4-647f4d9aa31b	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	204c2560-5a3d-4562-9781-630d4a973002	6.5	8.5	5.5	9.5
9fa46a3e-7795-4a6d-8747-d6dd03257502	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	304c2560-5a3d-4562-9781-630d4a973003	600	800	300	900
fd3c8e0b-9aec-4bd0-9755-09d74d6299bb	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	404c2560-5a3d-4562-9781-630d4a973004	0	5	0	10
18fec49c-d5f2-4cbe-b582-0a838935f2c6	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	504c2560-5a3d-4562-9781-630d4a973005	2	4.5	0.5	6
0a66a61f-2db2-4a08-b083-f4716274ea6b	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	604c2560-5a3d-4562-9781-630d4a973006	20	90	10	98
14871510-682e-45e7-928f-616af4fb814d	98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	704c2560-5a3d-4562-9781-630d4a973007	10	25	4	35
\.


--
-- Data for Name: stations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stations (id, name, latitude, longitude, status, last_seen) FROM stdin;
9a255bcb-fd28-48fe-ab17-b1beffa91017	Test1	12321312	1123310	active	\N
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Kyiv Water Processing	50.4501	30.5234	active	\N
b5f2c4e0-8d1a-11ee-b9d1-0242ac120002	Lviv Pumping Station	49.8397	24.0297	maintenance	\N
98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b	Station "Dnipro-Alpha"	50.4501	30.5234	active	\N
\.


--
-- Data for Name: telemetry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.telemetry (id, sensor_id, measured_at, value) FROM stdin;
0947fc35-5c43-4f69-9ded-0ac8dde4f4f4	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:10:16.702+02	7.97
aa502652-8bd6-4e42-815a-4658ce4257ae	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:10:16.703+02	7
08c752b0-a73a-45e7-8a4c-df95b114e3bf	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:10:16.703+02	697.98
019d66f1-bebe-473f-803c-504544318410	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:10:16.704+02	3.02
fe6c89fe-2f31-4e83-bddd-42a6034ce1b1	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:10:16.704+02	0.5
3371fb62-c84c-4fb7-b0f4-ba0eff5de542	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:10:16.705+02	49.98
2c068298-96bb-4f3c-bd86-845f06828440	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:10:16.705+02	19.99
a8ef318c-8047-426b-9779-7789a05a486f	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:10:21.712+02	7.96
a1efb702-c80f-4ae4-a5f5-5f789eefeafa	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:10:21.712+02	7
2e3ed077-ed74-471d-afd1-7d5cb8996e3f	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:10:21.712+02	696.99
1da6f073-6cf2-40a8-acaa-a5f41e734ce6	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:10:21.712+02	0.5
64b6d785-7d33-4eff-9236-fd5af8ef19d0	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:10:21.713+02	3.02
a68d4b51-b943-411c-8b1b-cc6e6d2c073b	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:10:21.713+02	49.99
fb3f2126-cc00-41d7-ac6d-8dce15a68ce5	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:10:21.713+02	19.99
202765ac-1241-4bb8-823e-eae0ab49f1ba	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:10:26.73+02	7.94
5b1ad755-7576-47cf-a0bd-8f985c220097	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:10:26.731+02	7
a23e46d5-37ed-47fb-ad86-50446adbed01	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:10:26.731+02	695.99
205ddca9-7cad-4a38-a4fa-c07dd1c90f23	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:10:26.731+02	0.5
8ffabe93-3b97-4eac-b94e-ffff03ee5ee5	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:10:26.731+02	3.02
54347247-e9b8-4c9c-8e34-1d07b273d6eb	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:10:26.732+02	49.99
725f3462-48eb-42a7-a4a6-585cae82095d	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:10:26.732+02	19.99
345ba513-4424-4304-ae5a-b34fec0e3fbd	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:10:31.737+02	7.93
9b9d8b1e-73e3-415b-a80e-7bab3af93972	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:10:31.738+02	7.01
8f06e431-3bfd-4a95-8949-9c9dde298158	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:10:31.738+02	695
cbef0182-fa77-410d-a755-58bb437c7321	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:10:31.738+02	0.49
3b9c6c1c-0f3d-4808-85c4-690a029c6447	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:10:31.738+02	3.02
2a16ad50-e7e4-4b50-a406-542b63f61157	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:10:31.738+02	49.98
43d13c66-6605-46fe-852b-eba7486cec61	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:10:31.738+02	19.98
31d95771-a4c3-47b3-8d2d-015d48aaeb28	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:10:36.755+02	7.91
27b09a17-c06c-4a34-b2ef-041f368155a8	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:10:36.756+02	7.02
14ee910f-a73f-4cf5-92dd-9aa690f08095	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:10:36.756+02	694
56342bd8-b8e9-4fbd-a63b-ca07530edd0a	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:10:36.756+02	0.49
5986cb82-eb63-4bad-8b6e-4ad5e3a0de60	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:10:36.756+02	3.02
f616661e-402d-4421-94dc-c1beb73c3b7a	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:10:36.757+02	49.98
19e78e3c-8374-427f-855d-0e57f272a6ac	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:10:36.757+02	19.97
6358e7d6-dcf1-4e19-af85-b47b8c001e7f	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:10:41.77+02	7.88
3589cf35-f0b6-4d38-956e-3210c2afff9d	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:10:41.771+02	7.03
2da90b53-0547-44b7-a0fa-9b8f6019e213	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:10:41.771+02	692
5a5215a6-3a4d-4bf8-96a7-f90980e17502	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:10:41.771+02	19.96
76155021-28dc-4af9-872e-cbac833a1663	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:10:41.771+02	0.49
ccae0c2e-fdd5-423a-a38d-59f7367adaad	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:10:41.771+02	3.02
6accb94f-dc94-403f-92de-fc277ea49ef8	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:10:41.771+02	49.98
379fe175-c0b3-4e78-9603-4cc92925e290	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:10:46.782+02	7.84
79be63d8-e3c9-4283-9b78-603d78375344	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:10:46.783+02	7.04
9c59a215-2f31-453d-9b32-7fdaf4231ce8	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:10:46.783+02	690.01
9785274a-3aad-4f48-867c-e805d27c5b92	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:10:46.783+02	0.48
7e9e4c2c-7f9f-4250-b677-b87f8f5a9962	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:10:46.784+02	3.03
803ca60a-6230-476c-bf05-1f29443cdb51	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:10:46.784+02	19.95
7ba4f12d-6d82-4c63-9f8e-6c931ca54c67	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:10:46.784+02	49.98
86825826-1ec7-4c21-ab77-9d64169009c4	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:10:51.799+02	7.82
dbbd2a95-aa85-4562-86df-c034cac907ed	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:10:51.799+02	7.05
c77630e0-e66a-48dd-acce-426e514b855a	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:10:51.8+02	688.02
906b0279-daf1-499e-be42-a6af21f9da57	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:10:51.8+02	0.48
59b8619c-bcfb-4813-b538-3756fcf0367d	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:10:51.801+02	3.04
46b53784-a48e-462a-a68d-5126fbcf3105	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:10:51.801+02	49.98
33bdd0be-7a1a-4316-82ea-52bcfb145765	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:10:51.801+02	19.93
f7fed82a-5760-47a1-8772-0165fe26e156	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:10:56.808+02	7.8
1168888a-f822-4a64-becd-8d15ea28ba46	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:10:56.808+02	7.05
7ce53f89-4656-49b1-a3ce-fec6a43c7df6	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:10:56.808+02	686.02
196638d0-c69a-4263-ab1d-8c9ca1e3a855	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:10:56.809+02	0.48
39b1b35b-02b1-4a59-bede-082fd3fbe3a0	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:10:56.809+02	3.04
d7c03d1e-9c02-46f2-836c-978b9f527558	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:10:56.809+02	49.98
b8b29c5b-11dc-467c-ad46-7d701ca651f0	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:10:56.81+02	19.93
ee3c5449-36e7-406f-a13b-3662f4cf6c6d	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:11:01.821+02	7.77
666ab227-fc99-441f-8f52-8c85979da45f	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:11:01.821+02	7.05
1bd1e40f-fbba-4422-858a-7edd456852de	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:11:01.822+02	684.02
d08c26e0-ee7a-4007-a875-3093badf1512	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:11:01.823+02	19.92
758d3881-b97f-4907-a688-8d3d82d2115b	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:11:01.822+02	0.48
cbc0de0a-5702-4e01-a7f7-8b609c9de2a3	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:11:01.822+02	3.05
3146c455-8d7b-465b-8057-50a4d87a13d9	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:11:01.823+02	49.98
f0963e39-e350-4175-93ed-6155b3ff09eb	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:11:06.835+02	7.75
a2f90269-58a8-40a8-9c5d-37d43ab77a91	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:11:06.835+02	7.04
b453a056-0428-4942-aaea-6cd3655cf418	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:11:06.836+02	682.02
3c8407f1-a9e9-41ce-a267-37d4dfbb4d36	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:11:06.836+02	0.48
b6ae33cc-7e1a-483c-8e8e-ef232998ccab	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:11:06.836+02	3.05
e88057f7-4aa2-4cbd-88af-c19d60377e8e	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:11:06.836+02	49.98
c4bf5386-77e0-4cd6-8796-b17ec179506c	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:11:06.837+02	19.92
5578ced5-e25c-4c3d-96d1-a79afab814bb	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:13:32.243+02	7.17
5a61d845-c63c-499d-b446-3c1203646065	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:13:32.243+02	624.05
cc4e6943-e76c-4fa8-ad1e-985516944941	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:13:32.243+02	0.58
2899d6df-6e94-49ce-9143-1a8034f61fd4	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:13:32.243+02	3.03
a36d8ae6-b4c1-4837-8a03-a27512613f7d	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:13:32.244+02	50.01
41658c06-1e3d-489f-84eb-f5fd21fe018c	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:13:32.244+02	19.66
1b187967-23f4-4cd8-9177-56cee076e860	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:13:32.243+02	7.02
9bee0a79-6b96-449a-9aa5-8a6c440373db	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:13:37.249+02	7.14
ddc24258-bc4a-4ece-8783-ad6a7642d197	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:13:37.249+02	7.02
a91e24be-72c9-42c2-b0f9-586cb0373209	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:13:37.25+02	622.05
59a0a225-7b73-4e69-baa6-799bcabe3b02	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:13:37.25+02	0.57
b61b83b1-6276-4f29-9f22-8fa6f8c4a0dd	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:13:37.25+02	3.04
b67cb4aa-02ee-455f-9436-f3f13ce9f094	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:13:37.25+02	50.01
6442e3b2-5f3c-4a06-a22b-e8b7946bce36	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:13:37.25+02	19.66
a6ba4e84-564f-4b10-88d0-2d252a2511f7	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:13:42.254+02	7.12
18e028a9-5bd9-4832-a7b1-0e0de994a75d	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:13:42.254+02	7.02
73020d26-70b0-485b-8070-86f22836413d	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:13:42.254+02	620.07
7f5d5cbf-7739-4ade-a80e-03ed83633e3e	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:13:42.255+02	0.57
f120c87f-3b6f-471e-b307-001e65172553	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:13:42.255+02	3.04
62cefb48-8ff4-41a6-bbf0-178b91f2f9e6	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:13:42.255+02	50.01
6d2eb6c6-92ac-4ca4-a84e-20527e5f6595	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:13:42.255+02	19.66
bbe85dd7-2e27-410c-91d7-44ec21797651	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:13:47.26+02	7.1
c989e966-1b74-470a-a4c8-4492c593d660	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:13:47.26+02	7.03
7d7fb598-96c3-419d-937e-600d9a11fbad	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:13:47.26+02	0.56
56a33f0b-ba8c-43be-be20-06d3ffc3c647	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:13:47.26+02	618.08
4491c2c1-7123-45dd-92a5-8d3848e8388b	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:13:47.261+02	19.66
54978c6a-eda8-484c-8627-8a206b2de460	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:13:47.261+02	50.01
6a799351-2668-4f8b-9354-0f582ede67cb	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:13:47.26+02	3.04
6a311020-a377-43df-838b-8c7dbd990d69	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:13:52.267+02	7.09
78f4c1f3-7727-4d6b-a338-5f8bccbf2b5b	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:13:52.268+02	7.04
2326bdee-39d8-4eda-b8e6-533a4117efd4	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:13:52.268+02	616.09
c4607a3f-ef43-4324-9efd-eca1f0b724e4	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:13:57.277+02	19.65
7a1861d1-16c2-452c-8034-af65e1f950ef	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:02.287+02	19.64
645feaae-b657-4f5a-bd20-142e40e1f407	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:07.297+02	50.02
3b546a9a-abda-4134-ab1a-c823d6cdcf48	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:12.309+02	19.62
2cd0c13b-04a3-45df-90a2-26ce0948e1c4	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:17.315+02	19.61
886231d5-0330-43fa-a962-7d396108c32c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:13:52.268+02	0.56
d5177f58-1e26-470b-b55f-d551028cd9a7	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:13:57.277+02	3.05
43e62ec0-9c4e-43c5-acee-9b438977bb5d	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:02.286+02	612.1
c63f5caa-68a7-4ea1-9515-5ea16c9e9087	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:07.295+02	7.04
a986966b-f8b0-43dd-a692-eed439c7a38c	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:12.309+02	50.02
d772e299-5b7e-4cb7-9913-9d0d2576e31e	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:17.315+02	50.02
af94dca8-d58e-4677-9ed2-41060ca9a423	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:13:52.268+02	3.05
6612f484-4167-40de-85a7-4962089d9246	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:13:57.277+02	0.56
dfdf149b-60ee-4e9f-b1bb-4333a2b0a697	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:02.286+02	0.56
e49c32a1-3818-43ae-8f46-f74a438e9a96	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:07.296+02	610.11
c45fd2c8-fa5b-4eb2-bcc3-0d8c29a91132	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:12.309+02	608.11
bde7d9d1-885f-4324-b6a1-b4ae946e48de	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:17.315+02	606.11
843087ad-650f-4a88-9d48-4ecd7d42c693	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:13:52.268+02	50.02
9a92b28d-25b9-4c18-acd4-a7f957825c7e	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:13:52.268+02	19.66
a49cd896-05c3-49ec-9e6f-74cb06860bfc	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:13:57.276+02	7.07
9d1063dc-c848-4cef-b4e6-c2ef7916e954	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:13:57.277+02	7.04
d2e993d5-7178-4d86-bb75-d111d2253221	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:02.285+02	7.06
4d09b51e-5422-485d-9c97-5bc25a419e65	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:02.286+02	7.04
3b4201e4-bc9a-4bba-9d3a-a7c2b6358221	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:07.297+02	0.57
8c2bf34f-8d84-47a3-a2aa-775264b03ff6	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:12.309+02	0.57
e71e820f-1b04-4d7f-a942-9d386f6a4f1f	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:17.315+02	3.05
4a4315d8-08f6-4378-bb07-0d78b9aaca24	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:13:57.277+02	614.1
db8389b7-fae2-4e30-8d21-8c161915bf42	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:02.287+02	50.01
26f03887-79ac-48e1-a61c-bcc491413036	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:07.297+02	3.05
2b587834-8986-47b7-bb0d-224ad1f6e35d	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:12.309+02	3.05
d7f5695f-ec88-41b6-b7db-7dbcf7f4a6d6	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:17.315+02	0.57
24bd5c76-ef10-4644-821b-07b13f8cf7e9	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:13:57.277+02	50.01
eb284623-242d-4244-9119-b7631022c426	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:02.286+02	3.05
5b36ad0b-61fa-44fa-87df-cc88c3c7c3d5	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:07.296+02	7.04
b488affd-7407-4c2f-92e4-54f35646a7ee	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:07.297+02	19.64
0c26bc0e-576a-4a09-9c81-8931d01faa80	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:12.308+02	7.03
54bbde2e-f73a-4861-8c6d-a3cbb0962b52	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:12.309+02	7.04
4c990eae-1d6c-43c5-bee8-71a331695a48	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:17.314+02	7
5262a282-9059-4a44-a189-66039576f514	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:17.314+02	7.04
32bf5e3c-51a3-4f8b-a67f-f0a749b9e9ba	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:22.321+02	6.98
059a2edf-e397-46f9-84eb-54d24eb10917	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:22.321+02	7.03
1eb5cdab-bd32-440c-b2c1-a476670a2d7c	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:22.321+02	604.12
cd61e46d-7d3e-4167-b70a-bab3e61983bc	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:22.321+02	0.58
fc517dfa-c189-4276-b961-9627c8a3795d	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:22.321+02	3.04
44edc39e-2914-4479-853c-50425ff93dcd	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:22.321+02	50.01
8508cfb1-f1c5-4331-8962-04c4d969c9fc	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:22.322+02	19.59
bbec803b-0ea1-41b7-aaca-37fe7cdd2319	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:27.326+02	6.95
39a3027b-4b91-4ccf-b708-04403b33197c	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:27.327+02	7.03
35c24a50-9563-4a03-b6e6-5fdf8e2fd12a	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:27.327+02	602.12
b7834872-5656-4729-93e6-359d192d636c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:27.327+02	0.58
02f391a3-1077-4200-b8aa-5c4467516536	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:27.327+02	3.04
5bb3f942-2271-44d8-916b-d99067122c2e	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:27.327+02	50.01
bd6280a3-e1c3-4aed-9d70-05d8786a570b	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:27.327+02	19.58
9fb0a1bb-71e9-42e5-8797-8646b4fc57ce	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:32.331+02	6.92
7b1cdc76-604e-49f1-8bcf-d8514e292391	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:32.331+02	7.02
a6699633-f813-4762-a050-eca5e999c360	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:32.331+02	600.12
73c455c9-3e26-4365-aadc-d61a4f8961c6	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:32.331+02	0.58
5ac83575-e005-4126-8c3e-3b325cc634d9	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:32.331+02	3.03
934bdbea-e05d-4773-b735-649582c89372	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:32.332+02	50
401c32e7-46c0-41b2-b5c5-d2179528d8b8	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:32.332+02	19.57
24be9e99-fe23-481f-bd33-820672a5ab61	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:37.338+02	6.9
1d076b1c-ab15-4292-877a-b5603f110949	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:37.339+02	7.02
a79be73b-f22d-4953-b57a-1943cb750935	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:37.34+02	3.03
786ca34b-59ea-4206-ad1e-c805262efe38	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:37.339+02	598.12
5d2c29d6-dffc-4c52-aca2-e2d9f87c8f75	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:37.34+02	0.59
f64f2d9b-3ebf-454c-a233-e0bd962eba85	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:37.34+02	49.99
d5ba93fb-227c-4af0-acae-c0cc75d70283	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:37.34+02	19.55
3a2c21c3-70c9-4491-9399-91cbc8c0cbbf	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:42.345+02	6.88
960f240f-a4b4-4a67-a394-f585d65e4f53	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:42.345+02	7.02
385513b1-cfbc-4d48-84d6-e6aea5c17186	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:42.345+02	596.12
39e3e3bb-9540-42d4-a695-13b3b0e1fcbd	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:42.345+02	0.59
4c1a1c4e-a6bb-4f50-9bcd-b5d098543df7	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:42.345+02	3.03
d591de79-e89b-4670-9f9a-2ee94b0a1270	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:42.345+02	49.99
39c2b3c3-ec8a-48c0-a280-999493332d6f	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:42.345+02	19.54
0bd4bc08-4ae0-4bbe-8892-dd8fb7cffd66	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:47.35+02	6.87
218f036d-71bd-4b73-80ca-a670198d4de6	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:47.351+02	7.02
dd9e48ff-efde-414e-88e3-44056b633310	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:47.351+02	594.12
ae5085ab-b390-43e1-9991-fd3518afc02d	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:47.351+02	0.6
4998cff9-5fd7-474b-80f3-ebfceacc9272	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:47.351+02	3.03
21f3ef9b-c01b-446b-b582-a0c319b5eee9	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:47.351+02	49.98
1c3d40ab-c651-4e99-8cb1-ee6aa5cc1aeb	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:47.351+02	19.52
ed44e619-52d6-404b-adb7-bd68fa090423	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:52.356+02	6.86
fc607f1b-cf78-4416-a069-3f542248782d	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:52.357+02	7.03
90184c7e-32d4-401d-8a3c-21c2198c083f	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:52.357+02	592.12
bcea8b4e-75ed-4d45-9aa5-fce3e773158c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:52.357+02	0.6
97dfaa30-9d99-4047-b474-740d9d3ac80a	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:52.357+02	3.03
22c3cc7e-d71f-489f-a3a1-decbe00c5879	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:52.357+02	49.98
987963a5-d489-4955-a994-0030e95f855b	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:52.358+02	19.5
61f2a9d3-2db2-43a5-83f5-c0c2d73555e7	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:14:57.364+02	6.85
dd00803e-8947-4133-b4c4-eda55a8db59f	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:14:57.364+02	7.03
9382ea27-f074-480f-be0b-ac73fca8fea0	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:14:57.364+02	590.13
6e7bb949-21fb-427b-8d2c-0c51d8fefd73	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:14:57.364+02	0.62
cf2c1633-0252-40d6-a795-614d417bb47b	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:14:57.364+02	3.03
f66d7bd6-6f92-469a-a6a1-b5382efe8766	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:14:57.365+02	49.99
4ac8d2fc-8237-4866-b7ff-6f76c80a09cf	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:14:57.365+02	19.49
e6a99b0b-1652-42a5-96a9-7f55061bd46d	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:27:42.709+02	6.82
5135b220-521b-4e71-a9b5-81fa0b754103	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:27:42.709+02	7.04
d98ee370-acf9-40c6-b02d-268f03d8a04b	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:27:42.709+02	586.13
55924c4d-cad2-4d0a-9618-d1ffaf8ee357	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:27:42.709+02	0.64
183ed40e-6580-4b20-95ed-cd6011ce357f	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:27:42.71+02	3.04
e577aaae-d5e9-4ef0-8fc6-914b4f3b8e73	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:27:42.71+02	49.99
6bf89c5a-fc65-41ee-aebd-9d695cffead6	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:27:42.71+02	19.47
83eae707-212c-43be-9c70-503284d4daea	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:27:47.726+02	6.8
83921158-92c3-40f9-8cd2-80435b752906	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:27:47.726+02	7.04
a552f39f-b20d-4959-ac70-524336a92a42	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:27:47.726+02	585.13
314d8fae-0728-4be0-a78b-d196133a344a	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:27:47.727+02	0.64
1fe8a1d6-e8bc-4379-9144-4e71714b1d9d	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:27:47.727+02	3.04
1744fb97-b4cc-4b0a-ae05-b5bbe08baa8e	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:27:47.727+02	49.98
ffad0190-6540-4c88-890b-e939bb4218a1	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:27:47.727+02	19.46
cb7b849d-d777-44f5-b94a-bc5679e92ee9	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:27:52.743+02	6.79
dcc0cb8f-4208-4b58-adf1-5b22d3350762	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:27:52.743+02	7.04
8d16b0ea-5c5b-4f43-b655-6924ffb33db1	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:27:52.744+02	584.14
f46a58ba-d7a2-4239-abb5-87a367d84e54	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:27:52.744+02	0.64
6b8aa1ef-63b7-490a-b2a1-aeb46451933e	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:27:52.744+02	3.03
efcdfbda-3f29-4583-b315-2940687238bc	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:27:52.745+02	49.98
3f5a80f6-4c21-4bb9-98eb-f178c08ea772	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:27:52.745+02	19.45
41b3697f-bfc2-4325-bb56-79e7b68209db	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:27:57.757+02	6.76
1d6e9562-6efc-4e2a-b5f9-370034b4c22f	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:27:57.758+02	7.04
af8abeb9-9b18-4b01-9551-ed21a557ec9b	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:27:57.758+02	582.15
30913ae3-d394-4041-afc9-241493dc885e	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:27:57.759+02	0.64
663f2413-a777-4f50-9e33-b22017f42351	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:27:57.759+02	3.03
6c4081be-f673-4692-a0f2-359fa386da21	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:27:57.759+02	49.97
47f69973-9956-4bb5-92e9-96dc26fe5c4c	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:27:57.76+02	19.44
d3e5253a-41d9-4f2b-882b-a9aecd767295	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:02.771+02	6.73
9185b19a-1c02-4bc9-adb5-60335670083d	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:02.771+02	7.04
74bc4679-8022-4d1a-bbc2-48f181cc4ada	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:02.772+02	580.16
68f7196f-9d36-4ca4-a39d-1fc93f5f99e0	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:02.772+02	0.64
b76e6c17-b089-407d-93ad-99562861661f	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:02.772+02	3.02
c4c8ae12-a23f-4d41-bdb1-29d7fdd370cb	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:02.773+02	49.97
58fc267b-5ee6-41f1-8367-6383a66c4e11	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:02.773+02	19.42
472ffad0-9492-4cab-99de-e96f63eb624b	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:07.784+02	6.71
9c04ef35-3db8-43fe-a5c5-1efb89b7f65d	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:07.785+02	7.04
b170786f-ace3-47c4-9cbc-c88389be57c7	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:07.785+02	578.17
15a53cb2-b081-4316-97ab-f839b614d112	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:07.786+02	0.64
12c97ef9-5444-4a7b-85fc-88326bd5f2ed	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:07.786+02	3.02
acf5367c-a1d5-446f-a487-f36d8707c186	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:07.786+02	49.97
0cd2a4e7-96ce-4d18-92bf-d2df6361cfd1	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:07.787+02	19.4
8fe22aa7-b77b-4e4f-a5ef-75f3af60bc80	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:12.798+02	6.69
3a1d5735-6c20-45d1-8782-d507ccf86cdf	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:12.799+02	7.04
57af32aa-e1dd-4bae-8410-2b529904e279	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:17.814+02	7.04
0e84cc44-377f-4fc6-b879-259654543cb6	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:12.799+02	576.17
8e146af8-de90-47f3-962b-2c9a8d61feba	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:17.814+02	0.65
d7c9628b-d4c6-4c2c-a631-68bbf41d06a1	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:12.8+02	0.65
fc893b44-289c-431f-9e0f-01591d64c110	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:17.815+02	49.97
839fa111-22d2-4e1d-b260-e7be1fd87786	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:12.8+02	3.01
731a22ec-aea6-4e10-a626-e705f205fe01	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:17.814+02	574.18
fb443dd0-16bc-4e7b-82a8-483c494289c3	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:12.801+02	49.97
852e6ca3-0fed-4f54-88bb-b4f1f84ce474	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:12.801+02	19.38
59df1099-6ed2-48f2-8444-161e6c892628	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:17.813+02	6.67
fe67298a-6fe3-413d-ab78-d8776818e2b0	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:17.814+02	3.01
30421ae2-cd3c-4792-8d6f-ac9848b12b10	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:17.815+02	19.37
43c3ef9b-f30f-45db-83ef-e1d8f801652e	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:22.824+02	6.64
32b5882e-ddb1-4113-8ab6-77f9b2d1d271	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:22.824+02	7.04
8562013f-7a1d-4f80-bc34-fa9952f4a073	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:22.825+02	572.18
e23065f2-8f92-4138-8daa-ae6f3a971227	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:22.825+02	3.02
3748c1c5-4267-4839-8fb3-d46642a30dbb	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:22.825+02	0.66
dadfe7b8-db85-4b1f-9343-4f5dbe782cdb	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:22.826+02	19.35
6d80916a-14cb-4e85-a932-8bfc9f0e7bfc	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:22.826+02	49.97
7d9f3bbf-45ea-4563-a071-6a2aac524c94	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:27.836+02	6.63
a554551c-8310-4d04-b799-6dd6e2d8279f	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:27.837+02	7.05
3b3694b6-8bff-4b39-b89a-217afd097f49	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:27.837+02	570.18
e3dc38ed-66f4-4a5b-8c26-30a597909003	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:27.838+02	0.66
bdbe30c2-6db8-404c-96db-b50549792878	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:27.838+02	3.02
27302343-10fc-4aba-919f-2c2b1166b44f	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:27.839+02	49.97
9520b0c6-1f72-4460-acd1-df2eec207ff6	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:27.839+02	19.34
57df64f3-9e31-47b6-9611-8ce110458466	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:32.852+02	6.61
9f3adc86-1ad3-4850-b453-c83d8645d846	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:32.853+02	7.06
abc92ddb-49e6-4605-9073-16de938a65fd	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:32.853+02	568.18
b7c56664-4512-4bd5-af77-17dd7a868ac4	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:32.853+02	0.67
49a58e9a-6f01-41bc-8df9-684daa72cffa	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:32.853+02	3.03
d44c9a1f-2e6f-4487-807f-6886e6bdb1ed	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:32.853+02	49.96
0cd8f83c-52f3-4e34-b6df-ef7a9ceb7da3	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:32.853+02	19.33
22ceb93c-f793-47b0-9f1f-59f1329115c2	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:37.866+02	6.59
f03173d9-4ef8-43bd-b5e9-43f5349f0031	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:37.866+02	7.06
31037199-cf75-4dcb-a1a2-658e27a95ab3	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:37.867+02	566.18
824127c3-762e-452c-982a-72e4a322fa55	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:37.867+02	0.67
71d36d27-a543-47ab-a91f-7798258bcfd9	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:37.867+02	3.03
17febb5e-8d61-4b2b-ad6d-737b720edc38	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:37.867+02	49.95
a2e12427-39a3-424e-9216-bbf97545d607	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:37.868+02	19.32
936a65c6-b6d9-4135-8269-f60d6dac2e6b	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:42.878+02	6.58
1deaa0cf-c6fb-4977-ae95-cf4172dc4179	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:42.879+02	7.06
dbf693a1-8aa7-4b53-984f-0af56c9dfda9	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:42.879+02	564.18
fba7433a-757f-4d3f-9b62-86b75aa37ac5	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:42.879+02	0.68
a2418cc3-a619-441f-8d79-d7168533db1b	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:42.879+02	3.04
6433b870-5f56-480f-b35a-2571fede4f51	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:42.88+02	49.95
1d589fad-1a7c-4d7d-a6ae-8ee7c42a502e	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:42.88+02	19.31
857d8d45-10b0-4b43-864d-6bcfd02b6e81	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:47.886+02	6.57
ecd7859b-9705-4ab9-b041-7f2bff70d502	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:47.887+02	7.06
c772f2f5-d6e0-48ac-aab5-6d70d886430c	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:47.887+02	562.18
29b209da-e245-476c-be5b-cfbf2b3ffcfa	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:47.887+02	0.68
4d446498-f15f-4db5-9f54-cf5c5e43d9a7	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:47.887+02	3.05
303fe12e-1b15-48b7-b111-b2f888c44949	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:47.887+02	49.95
51caa9df-aea3-41fc-84b3-e3677fab0a51	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:47.887+02	19.31
8e713498-9ff2-4d9f-aafe-007fc11d234a	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:52.894+02	6.55
c79b126a-1482-4792-86bd-7c2694b8c324	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:52.895+02	7.05
edf4e31e-de55-416b-8d62-f0320cf5b814	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:52.895+02	560.19
4087ee3e-b644-47f6-bf71-022c56d3406f	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:52.895+02	0.69
2bf680bc-c22b-408b-9559-e36db41e7f03	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:52.895+02	3.06
407bb93a-299d-4548-b0a6-72857bfa7953	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:52.895+02	49.96
7d93ee97-0ea7-42b8-b90a-bf656af96fe3	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:52.896+02	19.29
89fe9ca3-4223-40d2-9d0e-906bdf66def1	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:28:56.646+02	6.54
69443fb5-d564-4360-a9d7-b36ae2759858	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:28:56.647+02	7.07
1d86d988-5d52-4c6d-9ad9-421d624499b7	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:28:56.647+02	558.19
2a440327-20e8-45ac-bd28-f5d878e6c3dd	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:28:56.647+02	0.71
6af87e5f-ec0b-4e2f-a6eb-ec2ab4260639	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:28:56.647+02	3.05
e41589ee-4847-43e2-a840-c4a3d66460a3	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:28:56.647+02	49.98
312a4645-9b10-4b8b-bcbd-16fca7d8369a	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:28:56.648+02	19.28
622a6ced-54bb-4bc9-bbcc-3da65b7623e5	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:33:13.973+02	6.51
bf30fd65-9ccc-4e37-b49f-32f3172c2f49	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:33:13.974+02	7.06
854e2cdb-621c-4b3f-a2a0-8fd617484612	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:33:13.974+02	555.95
47554191-ec11-4c11-9071-4bd9c4d6b07d	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:33:13.974+02	0.73
fd39461a-9347-4fc3-9d94-db44508a126e	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:33:13.974+02	2.9
599bebcb-fc42-46a2-9676-dea7d3b7f4f4	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:33:13.975+02	19.27
31538358-5f82-4609-8eb9-b8e033970cac	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:33:13.975+02	49.98
f2750b4e-3781-45b6-9d87-1cc9508d8099	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:33:18.989+02	6.49
1e91c798-e00d-4c5d-99bf-891631497cbb	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:33:18.99+02	7.06
30dd057c-1778-4cb5-841d-ab5a7ac62128	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:33:18.99+02	555.2
d41a8506-7b01-4611-ba3f-2449cbd47d4c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:33:18.991+02	0.73
d3fd1520-6de1-46d0-9c48-49505df17fc4	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:33:18.991+02	2.86
19a450f0-43e4-403d-95b3-0a8ab7fd22b8	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:33:18.991+02	49.98
6637d5fe-9535-49c8-a747-626109967876	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:33:18.992+02	19.27
4d63c5f1-7bd9-4725-abe4-4f96347c9a01	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:33:24.005+02	6.47
8d72af87-d586-424e-b1be-63e534cf16a9	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:33:24.006+02	7.06
83de9ac8-e267-4897-b0b8-5e40beb18dc9	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:33:24.006+02	554.45
8d5c96e7-83f9-47c9-aa02-bdeb3699d349	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:33:24.006+02	0.73
396e0701-848e-4099-995c-01c9d7d36737	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:33:24.006+02	2.82
51d9cf1a-f3d4-4810-a43c-b15cf479e28b	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:33:24.006+02	49.98
d5e3e641-ba45-4099-87f0-62a962856a38	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:33:24.007+02	19.27
1f826c4d-6dff-4f73-8ec3-fbd13141a8c9	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:33:29.019+02	6.45
a092ba02-2833-4f3c-833b-76a6c03cbeaf	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:33:29.019+02	7.06
4e38fc32-9cc1-4cb7-a015-32b46c86fdeb	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:33:29.019+02	553.7
180c27bb-838f-4a23-9cc7-d2460169cd59	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:33:29.02+02	0.74
3e220cfc-f913-4082-8423-efaa7ee09e4b	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:33:29.02+02	2.78
23e42b54-0c87-41e1-aad3-b3e37614d1dc	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:33:29.02+02	49.98
0a1db5bb-d0ba-4638-8f06-2f5846a640e1	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:33:29.02+02	19.26
7148569c-5554-4c36-bf0d-631abda0fa77	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:33:34.025+02	6.42
df3ea58a-b858-471b-945c-059eea3bf323	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:33:34.026+02	7.06
587b9d30-057e-4245-ad73-603936f66699	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:33:34.026+02	552.21
36c2cf07-738a-4dd1-8974-6fb0c40825b6	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:33:34.026+02	0.75
3f2fb0f7-c763-4d8f-8020-e8ba5e63c546	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:33:34.026+02	2.7
d71f7ae6-7b1a-4550-a582-7d52d3ee1533	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:33:34.026+02	49.98
edbf7e8b-acdc-41c5-a4b3-aa010343938c	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:33:34.026+02	19.26
3348b033-ab9a-4969-8bb6-b126249efdd2	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:33:39.032+02	6.39
3f198f68-1b36-49e6-988a-15f9004bb006	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:33:39.032+02	7.05
7c50f0c0-9ea3-4f05-aa16-30b5a5a153b1	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:33:39.032+02	550.71
54534323-4252-462c-a479-259c64f8af4b	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:33:39.032+02	0.76
eb1aed1c-30cf-4f0c-8075-15e08b01fa93	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:33:39.032+02	2.63
e399992f-4a76-4a19-bf13-333560249bf4	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:33:39.032+02	49.98
c6534c3e-2eef-4586-aa6e-c170dce27ba4	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:33:39.032+02	19.27
54997870-1f73-4879-8418-0aa25813f219	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:34:23.919+02	6.5
80f01f81-0f79-42d9-a0dd-12eb3a2ffd23	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:34:23.919+02	7.08
be1917a1-c6b9-41e5-b988-6744501ad23c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:34:23.92+02	0.74
956da482-e4a4-4fe4-9020-7f19642d7ee4	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:34:23.92+02	561.67
564d658d-bf06-42f0-a01b-5df9c1130580	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:34:23.92+02	2.99
5f3ecfa7-2215-4660-9d41-9ff570d02bd5	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:34:23.921+02	19.27
0b59b1af-fad8-422e-9094-9ea3229befab	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:34:23.92+02	50.86
240bc8af-9414-4c23-82d3-3bb0be42d5f2	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:34:28.928+02	6.49
be8154c6-51db-4536-ac8e-81c3ac3a76da	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:34:28.928+02	7.08
f92c1e6d-ff66-406c-ab0d-4f3e44c515b0	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:34:28.928+02	563.23
e56bc59a-26a4-48e5-8479-cbcc053dca68	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:34:28.929+02	0.73
fc02d2a4-32c7-494c-a59e-0ff04aed9264	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:34:28.929+02	2.95
f054776e-a46c-42c6-ac11-e7c485afe2f5	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:34:28.929+02	51.3
a35fd5e6-3775-4ef7-9378-b8c4735563e8	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:34:28.929+02	19.27
4001eed7-7cac-46db-b2ae-e19daf0a283b	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:37:31.625+02	6.49
98df5e18-7ace-44f8-a70f-fbee217e9c75	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:37:31.626+02	7.08
b4e66459-033e-4ebc-80d5-1c58d02e888b	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:37:31.626+02	0.74
b88b71f0-86f1-43b3-9c02-d0b34addae04	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:37:31.626+02	561.25
19b6123c-bbe2-45ae-bdeb-4f40f6b7ab98	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:37:31.627+02	2.98
a5c9f670-6786-460c-849d-671ae6818247	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:37:31.627+02	50.86
4b8525a6-fd87-44fe-a448-824a1a8161a9	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:37:31.627+02	19.28
bdb34c6d-8b03-4c33-9880-fad2ab9584d8	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:37:36.644+02	6.48
0946acf8-f0f1-4144-bab3-a9f4678c8920	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:37:36.645+02	7.07
fc9aed67-fb13-4050-8900-d3e729425ac2	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:37:36.645+02	562.8
9edaa8b7-b050-455d-9f3b-1ffc4d607477	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:37:36.646+02	0.75
a828b0f8-0704-4aab-b459-7432a6d2b867	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:37:36.646+02	2.95
6859918f-f9ff-4968-88f4-20366852b5bc	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:37:36.646+02	51.29
c347f8be-aea3-4faa-87fc-7b1848a5f044	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:37:36.646+02	19.27
6abd6f69-7451-42a2-afd4-35874fc3ba0f	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:37:41.659+02	6.46
99eaa1e4-2e85-424e-9a56-69ffa01c5eac	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:37:41.66+02	7.07
1775fb92-0b8a-4176-b1d0-7a8cc70d3b33	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:37:41.66+02	564.35
873e7c3b-d74f-45d7-a041-96bac0683560	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:37:41.661+02	0.76
d1e73ffa-0cfa-4212-bdc4-6e665944d95c	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:37:41.661+02	2.92
7bfcadc1-85d4-4a3d-b6c1-ae0924289303	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:37:41.661+02	51.72
ff6f4f0b-dc58-4ab9-8669-7cf7d8b19af9	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:37:41.662+02	19.27
7056964c-18b5-4374-8266-01e58d52f3b4	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:37:46.677+02	6.45
537ca386-df77-4131-92ee-7e4969fc3043	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:37:46.677+02	7.07
e3da3c0e-cfd9-4cff-b675-6c89c19ba5dc	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:37:46.677+02	565.88
52d5d39f-e10e-4781-a104-942edd1f05a1	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:37:46.677+02	0.76
71b357b2-0f25-4b92-91cd-71a38ac60ed7	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:37:46.677+02	2.9
f726c205-5c75-40e1-b09c-a8cdd72786d4	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:37:46.677+02	52.16
99de7245-7422-4684-a695-5a097822d853	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:37:46.678+02	19.26
f6eb832e-d0a8-4326-b613-cc86fa3d9ba9	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:37:51.692+02	6.44
12f5520a-c5fd-476f-80b5-ab26eeaf995f	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:37:51.692+02	7.06
15d36d63-2e96-41dc-a8ff-e67427eadc31	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:37:51.692+02	567.39
f1c4bfd8-bfa6-4515-890b-9df0dd3cbf8d	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:37:51.693+02	0.76
57ebba5e-9435-4445-a05c-770542ed386a	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:37:51.693+02	2.87
4dee0a41-150b-444a-b4b7-f6ada6302b42	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:37:51.693+02	52.6
870d4280-c849-4795-a1bc-e87479b68ba5	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:37:51.693+02	19.26
b341fb67-7ce5-4cb8-9b03-c99859b95e07	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:37:56.709+02	6.4
766d8ce7-a6e0-4f3a-8346-b374fd5ecd8f	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:37:56.71+02	7.06
16544de6-81af-4e29-b73c-6aef271ebb52	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:37:56.71+02	570.41
f7d47ed2-3c2c-4013-be78-eb8d9da4a45d	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:37:56.71+02	0.77
560607b6-e306-42cb-8a67-62ef7ba1d81f	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:37:56.71+02	2.82
c1fa9da1-f82e-4abc-82a5-5a8c8bd27798	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:37:56.711+02	53.47
1da22fdb-d86d-4d9d-b2ef-1d2c7d6ea341	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:37:56.711+02	19.26
a69c01c9-e8d9-49b9-be5d-92c5dd111427	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:38:01.724+02	6.37
be833d36-b3ef-44bf-bcc2-45cd5ae89374	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:38:01.724+02	7.06
8d72f3ad-d6b3-4e4d-8411-b40576f43836	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:38:01.724+02	573.37
223d6356-9cc1-4a75-861b-36be86f66c97	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:38:01.725+02	0.78
8b5f30b8-28c5-4e39-979c-664c16ac362a	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:38:01.725+02	2.77
b0628b83-0cc3-4894-b425-69f5937c0269	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:38:01.725+02	54.35
ef12244a-f9bb-4ff2-82e2-99c2307be6cb	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:38:01.726+02	19.26
68f54269-e1a2-46df-8b4e-c72be74e80c6	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:38:06.734+02	6.33
9db320bd-d262-4ed7-abdb-f4883124ad45	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:38:06.734+02	7.07
b99a7ead-6627-43fd-a3c0-7ae74fcc7eb9	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:38:06.735+02	576.26
76ef2e2e-8a9f-4401-99e3-06abd5766576	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:38:06.735+02	0.79
d52cd757-3f70-4691-9358-e7813a86aa2b	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:38:06.735+02	2.72
f8d66db6-b545-4b6e-bd36-a08da492f6fe	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:38:06.735+02	55.22
d7173414-abb0-483f-a466-2f33145da8e4	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:38:06.735+02	19.27
469a63c4-8070-4720-9a85-d1c1a4a83ed6	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:38:11.743+02	6.29
7786e819-d5c3-4a10-b53b-e8f4f40f8eab	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:38:11.743+02	7.08
54516b3d-1839-456c-a3b3-70ced1ffc2d4	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:38:11.743+02	579.07
91ba95a5-94e4-49e2-b3b3-4bc068969e36	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:38:11.743+02	0.79
4cd6ade7-0aeb-4c6d-a362-372c5f24d536	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:38:11.743+02	2.67
50926aa0-c36a-499f-9825-e28c637a3f5b	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:38:11.744+02	56.1
340f1240-1ade-48de-8223-ee245c4127ab	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:38:11.744+02	19.27
88144230-c506-4b67-b4a6-ee9cd42c2747	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:38:16.759+02	6.26
b649f9d3-6adc-4b5d-a7bb-ec787e8efd2b	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:38:16.759+02	7.09
28ba6c69-2856-48a7-b004-a3d1cb82d857	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:38:16.759+02	581.8
05033f9c-ff1d-42f6-aad6-9bf79862af52	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:38:16.759+02	0.8
960f6acd-deaf-45c5-a683-f5bcb363b3cb	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:38:16.759+02	2.63
3e96e05e-b499-4033-b1fb-352224336066	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:38:16.759+02	56.98
7fc6cbbf-7815-4a4b-8150-4fd8f389e5c7	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:38:16.759+02	19.28
eb5306d0-35cd-4b0a-9f7b-df19843b7776	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:38:21.776+02	6.22
c10698ca-c13e-405c-b9bc-e869cfce8d3c	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:38:21.776+02	7.09
2a793d1f-1a04-4440-89e6-8e0f1fcd9571	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:38:21.776+02	584.43
7deb63e3-b41b-48f9-96f2-d90875e52733	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:38:21.777+02	2.59
fed187dc-2f14-44f3-8b25-54ab82bcd9fd	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:38:21.777+02	0.81
7d6b450a-d62d-485f-b142-212bbbe32026	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:38:21.778+02	57.86
f2c3f333-f10c-4bde-8039-338eaad5442e	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:38:21.778+02	19.28
b77cf444-b897-4cfb-9985-cf8936949909	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:38:26.784+02	6.18
7b4fb3c0-8f95-49e1-82ad-3bd648e6a16b	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:38:26.784+02	7.1
e1bed1d5-164f-4342-80b8-2d3e88029de8	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:38:26.784+02	586.98
c3371b27-83b0-4f75-8512-e70fed40e821	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:38:26.784+02	0.82
7b0856a3-c4ce-476e-b81b-934348d75ae9	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:38:26.784+02	2.55
8d46fbc7-8838-41af-981f-85c95dc51803	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:38:26.785+02	58.74
b2e93f33-521d-4d7c-a5b0-c596518dedbd	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:38:26.785+02	19.28
fbdd5147-e5a1-4772-b1d3-780e71201b35	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:38:31.793+02	6.15
3289c3ee-cfb9-48a0-8940-dea20d6f23ba	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:38:31.793+02	7.1
f62b8fdc-2dae-47b4-89f8-fcc224c92ea7	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:38:31.793+02	589.43
7458a421-4ddc-4d6f-ab5d-5648699f2f8a	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:38:31.794+02	0.83
d98e2465-70ad-4c5e-98bd-3bcd431da956	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:38:31.794+02	2.51
895fd8b0-5aa5-4991-a3fe-a809a1050b2a	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:38:31.794+02	59.62
6d705cb5-596e-4a1f-800c-5f34534f3217	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:38:31.794+02	19.28
334efec6-76fa-48a1-a5a2-af12e812587e	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:38:36.804+02	6.11
a4e43cd6-d7fd-4601-8085-cd9640bb858d	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:38:36.804+02	7.11
3bf72e3f-9a11-4258-ab92-46f845e03bf4	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:38:36.805+02	591.79
c2a6c628-b2a4-4fbe-bba1-d331c1cb4ba6	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:38:36.805+02	0.84
8e9cf5b8-8e00-4a3f-bc72-2b0dd0409318	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:38:36.805+02	2.49
41306fbd-c646-462f-8300-14a1138e4876	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:38:36.806+02	60.49
c3d0a4f1-6adb-41a6-b789-17e2a60682cb	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:38:36.806+02	19.28
a38e66bc-afa8-489f-85cb-f9eca15c7111	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:38:41.82+02	6.08
d7a25a91-debc-4212-9646-62a5c8ddc034	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:38:41.82+02	7.12
350f83e1-1ef8-493d-b8ab-c59762fd0b2d	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:38:41.821+02	594.07
99de900e-99e9-45eb-aa22-d63c610c2f82	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:38:41.821+02	0.85
670e9cb2-734c-461c-b97b-61d92e5e0d27	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:38:41.821+02	2.48
a14bf858-1e09-4385-8db3-6f64fe3e6895	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:38:41.821+02	61.37
c0c8e5a5-06f3-481f-a2af-5f5b425ca8c6	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:38:41.821+02	19.28
fcf06ac7-dc7c-436f-9ca8-0887d9f07148	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:38:46.836+02	6.05
196b56f1-9ab6-4c57-8b61-58566e588a8e	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:38:46.837+02	7.14
258f0caf-ae03-40df-aefa-9548c1b1201b	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:38:51.852+02	2.46
ff87f56d-7aa9-4dd4-942f-92918e9468c0	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:38:46.837+02	596.27
32890a0a-5703-4d1c-9bd7-2e5ff56e4b8b	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:38:51.85+02	6.02
0e953491-9790-4544-bb1e-f2eab5abdb27	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:38:46.837+02	0.85
f6a429ed-496c-4af1-abe2-e24a625ad314	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:38:51.851+02	598.38
8ce89902-6cc4-4f87-949d-b784a6b78947	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:38:46.837+02	2.47
a26f666e-1567-4ee3-ab4d-b79dd15ef6e9	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:38:51.851+02	7.14
e5c0c7c4-b8ff-4346-bed8-02781d035436	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:38:46.837+02	62.24
60b1d3c0-3e21-4553-9c2e-e15f21196e51	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:38:51.851+02	0.86
fe337789-a3ff-4840-bf84-d702db9ba35b	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:38:46.837+02	19.28
18254d2d-2b7c-4092-9165-c706ff03bd52	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:38:51.852+02	63.12
001160fc-e90e-4c11-91cf-7695d8a5f69b	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:38:51.852+02	19.29
1ead4703-ed0c-4c33-ba18-2f2fb6ee3296	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:48:54.092+02	6.49
d762ba7b-a2f5-44a0-a21f-95cb3d536c02	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:48:54.093+02	7.07
c149b0ac-a0f5-43bb-8ac9-00d4c825f817	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:48:54.093+02	560.09
7f0c53f4-9b88-444e-9c99-1a1481b16e40	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:48:54.094+02	0.72
19df5d18-0b6c-4eb1-a389-d6ff8d84875a	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:48:54.094+02	2.97
3e88a33c-7150-48c1-b5f3-069b661c4326	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:48:54.095+02	19.27
a9cd64c3-cbdc-46e0-a0b7-76e9aeb87714	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:48:54.095+02	50.88
4e2f16ac-4321-4688-aabf-398fb71e03ce	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:48:59.104+02	6.48
5957d420-86c2-4ebd-803e-a326b796df49	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:48:59.104+02	7.07
c030d0c8-41f5-4d72-ae36-2d56560840a8	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:48:59.105+02	561.67
efa54e7f-cea0-4e45-814c-ec3a1d8e1388	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:48:59.105+02	3.02
34139b2c-3ed7-4b8b-b1c6-16eeb3ad7c8a	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:48:59.105+02	50.9
967946d7-3dee-4883-abb8-8bcefa3d3f61	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:48:59.105+02	0.72
6a08e33a-3369-450c-bdc1-5e634214b292	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:48:59.106+02	19.28
37901519-1ee3-41e4-953f-85fa6b0ac222	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:49:04.123+02	6.48
f1866af6-6958-4f51-bb16-d93be2c7eabe	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:49:04.124+02	7.07
970236c9-a70b-4360-b4a7-b917ab2dd8ba	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:49:04.124+02	563.24
db144aa0-a25c-4354-ac4c-bd93075394d0	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:49:04.125+02	0.72
793e4273-79d4-4bae-a4c3-7148ffb471ca	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:49:04.127+02	3.07
ad60f1ea-619c-4e8e-8848-59a5eea85b9e	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:49:04.128+02	50.92
85b8d91e-223c-4ba5-99fa-efe095ac5803	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:49:04.128+02	19.29
86c9f5d1-e063-404e-bac6-dc86ab31684e	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 10:49:09.144+02	6.46
538f70aa-4318-484e-a527-1f06d7886b45	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 10:49:09.144+02	7.06
de614282-92f6-4d13-b125-c1bdc880fa12	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 10:49:09.144+02	564.79
d166670f-4a50-4809-9e89-58141e4fda9e	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 10:49:09.145+02	0.73
77b2a14f-11c3-4780-ad5b-641978f85a6e	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 10:49:09.145+02	3.11
c615ecaa-9804-4e9c-b2cb-5f3d9b3923a8	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 10:49:09.146+02	50.94
f51186b3-b0e5-4a60-b482-0d7cb5a38be8	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 10:49:09.146+02	19.3
11f01c7e-ff2f-4744-8422-38f3d97bec80	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:00:54.021+02	6.68
4f310bed-2437-41ee-a4c0-654145377c0e	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:00:54.03+02	6.92
a251a869-28b4-4188-a0b7-38f0c2b7c9ca	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:00:54.038+02	558.29
a6183cb8-533a-4af5-a7ad-be15686c8aca	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:00:54.053+02	0.71
e9f8623a-905c-4352-9ad5-90f52a8bbcc1	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:00:54.069+02	49.94
fe46a27d-6195-492f-805d-8c2d220a23e9	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:00:54.061+02	4.07
2655d276-2950-470b-bf6e-74a40812f735	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:00:54.077+02	19.07
39e1055d-35c9-4cd5-8d19-49b321f32e32	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:00:59.104+02	6.57
ccfc413b-b7b2-4203-9020-bf257866cec5	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:00:59.117+02	7
12fa8677-8a45-4635-a18e-977c5b0a29ef	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:00:59.135+02	0.68
fcb8e71a-26ea-4cf2-afa7-b0555597c05f	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:00:59.151+02	3.09
e1b99f5b-6284-42ad-bc4e-50a4a1c983e8	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:00:59.126+02	558.18
54faf973-d99a-4d9a-a853-3870ac142e3c	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:00:59.159+02	50.02
8755ea15-1684-4408-bfbe-3c9f58df7fd3	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:00:59.167+02	19.18
4126a396-e39f-4068-a31e-718e111c04fc	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:01:04.19+02	6.59
2cd31183-ce81-453f-a9a0-a94f6bf6b2e0	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:01:04.197+02	7.04
87ccb71e-fbeb-46fc-a157-20b4e2020684	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:01:04.207+02	558.17
14ba3efb-f106-4bec-8f28-a81bf5d462df	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:01:04.215+02	0.71
6113fd99-ada6-41b6-a338-0ddbbcb0d0fd	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:01:04.224+02	3.4
394ae47d-b7e5-45ce-940e-eb029e7fa112	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:01:04.234+02	50.05
f46c51f9-0ea2-4828-962f-988a9f51b4ca	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:01:04.243+02	19.25
11d3a5f1-1a5b-41da-8876-f734c0601a90	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:01:09.268+02	6.59
43bff473-7393-4267-9991-bd4836eb7696	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:01:09.277+02	7.01
0c885478-0d81-4ad6-b21f-e5b6e14ed364	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:01:09.286+02	558.19
5c63e55f-6c1c-453a-93c1-14b0b3bdde72	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:01:09.295+02	0.7
ecf56f01-5535-4e39-8ec6-392d5d1e63ba	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:01:09.304+02	3.65
a4e87afd-6e8e-43f0-a7a3-6e6bac23cb06	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:01:09.32+02	19.3
52fb99b5-41c1-4945-86b0-1dc2cfece548	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:01:09.312+02	50.05
34e9bcf7-453d-46fa-80bc-a401088ada8e	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:01:14.342+02	6.64
bbd004c5-4bcc-40c1-aae6-dad0a86ddbf6	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:01:14.352+02	7.03
7ed2d853-3880-4734-91fa-6450eeb6ce60	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:01:14.36+02	558.18
b28b63c5-32e8-4d62-bb80-68409af18ef0	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:01:14.375+02	0.77
0b1d9442-5410-435f-be83-a28dbc032f7e	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:01:14.389+02	3.78
9e5ffbd8-7aff-4d2f-8b2e-b88cb1b6caf6	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:01:14.401+02	50.01
70e89ce3-7642-41a1-8fb2-e2522d322f35	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:01:14.411+02	19.35
ce06d2d5-7850-4eb6-b0ad-68518c7b6757	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:01:19.431+02	6.59
7e741efc-3227-4eeb-9d8d-1a220fb60fa8	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:01:19.44+02	7.05
5f348308-c59f-4c70-baa7-842fdee74e29	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:01:19.449+02	558.21
18916f2e-eec5-426b-b215-027e1da22576	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:01:19.466+02	3.99
d4d3cb5f-09c1-45a5-8d74-595ebb9277d6	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:01:19.475+02	50.06
173c8e10-2853-4e24-b005-17932a9f1019	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:01:19.484+02	19.37
24636f9b-544b-4879-a4e5-7304b16b86e7	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:01:19.458+02	0.74
c91646c1-2f5d-4330-ad0f-07b580401efb	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:01:24.499+02	6.59
4a6ffa6a-994b-4520-93c8-6bdce7c8d400	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:01:24.508+02	7.08
b7daeca2-c80f-43a0-8546-4647e6379196	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:01:24.517+02	558.2
202c6ec5-9939-4a0c-b5e1-a7a04c987e1c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:01:24.525+02	0.7
dc4c4140-7041-4781-9d16-2def81ca07e3	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:01:24.534+02	4.14
636f074b-0c88-46a2-a7c8-eefae4f59b2c	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:01:24.542+02	50.07
31f851c3-8324-4ac3-9a87-9c04a66dc8d6	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:01:24.551+02	19.4
d4825a75-9ca1-47ea-a8d7-96fa7d695719	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:01:29.575+02	6.55
337d7865-797e-43bd-b60e-7dde78eb33a7	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:01:29.584+02	7.08
c16444e0-801e-4dc3-a2df-ae2d878af3a8	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:01:29.593+02	558.21
83d8c039-2d7a-4a89-b491-09bd6241aa3d	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:01:29.601+02	0.74
9486d07f-3a3a-498a-ab3c-02190594136c	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:01:29.61+02	4.18
cf3af21d-0344-4a69-9859-89d1affc8dfb	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:01:29.619+02	50.08
4d87c89b-136a-44a5-b874-a1f529b92495	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:01:29.629+02	19.41
dcc85653-0b99-47e5-bb35-fd4ec594e990	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:01:34.655+02	6.57
7e1f1ec2-96b6-47a5-aa04-94fd4260b010	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:01:34.665+02	7.08
8dc5efe3-f11e-466d-9a4a-685eb378b1bb	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:01:34.673+02	558.2
165db279-df38-479f-a818-363e3569bd8a	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:01:34.681+02	0.76
329567a2-8ee5-405b-b784-d3df1481a1fa	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:01:34.69+02	3.65
edd4c400-652f-4af5-9d08-90db70f00869	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:01:34.714+02	19.42
4a01b494-28f7-46cb-900e-a9dacf947eec	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:01:34.706+02	50.06
31b5140a-ae75-4412-9de7-4df662f98987	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:01:39.74+02	6.53
d3527fd3-f122-4a31-ae94-bdb3032be178	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:01:39.75+02	7.1
8da59479-7b5d-462c-bbae-8504373666ef	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:01:39.758+02	558.24
b7dd46e0-10ee-496d-a977-b35e5c07b347	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:01:39.767+02	0.73
cd29fb3b-7b7f-4e97-b28f-8f660c7e03b6	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:01:39.776+02	3.73
db1a533d-a66a-4d96-8cff-59c70455fa9d	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:01:39.784+02	50.04
0e89ca6c-2fb5-4ac1-a6fc-3ed27b237290	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:01:39.793+02	19.46
4f4a41ad-fd83-4aa7-9d03-3c1b2eb7ca73	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:01:44.81+02	6.52
02cc8ff1-f010-490a-998c-c684e5af1b1b	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:01:44.825+02	7.11
c83e2f7e-5a27-48dd-b799-96a88ccda551	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:01:44.833+02	558.24
07d687c0-6c7e-4e58-8cfd-3087059f5200	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:01:44.841+02	0.78
01dcbdff-abf1-48c4-92ff-b15bcf53d03c	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:01:44.85+02	3.85
781ab528-b78a-4820-9f00-0f497817b2e2	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:01:44.859+02	49.99
647afb31-55b8-46bc-b51e-7bb109019d48	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:01:44.866+02	19.43
0ccadb12-422a-4b89-87ee-bfb77a7d5a0d	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:01:49.893+02	6.53
05080595-1632-4779-beb6-7ccf51875ba8	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:01:49.902+02	7.13
b06bf6a6-e149-447d-abcf-681d5d83543d	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:01:49.928+02	3.96
3eadda9e-637d-43a3-aaca-bbb2f10171e6	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:01:54.984+02	7.15
29e8f9cf-e1ba-49a5-811e-c4c3e09f7fe1	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:02:00.115+02	19.49
fac80999-4480-468f-ad7d-4081790c1480	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:01:49.91+02	558.24
97209116-b7aa-430e-8e55-2e8feba3e17c	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:01:49.937+02	49.97
ad43067b-b849-4625-8ba6-153281f0aa38	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:01:54.974+02	6.56
0e6d3774-e156-4a6f-9879-00f354ef5a4c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:01:49.919+02	0.79
f1a65015-8484-4157-b44d-086abbdc0204	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:01:49.945+02	19.42
82c8eed6-9871-4dd1-8d55-e811db338f30	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:01:54.992+02	558.24
120c6d3c-5fd0-4960-af1e-88de17bc80ef	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:01:54.999+02	0.73
be36d380-be19-4614-a343-bde80c4442be	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:01:55.015+02	50.04
081c5027-2bb4-44d2-948c-7eab363b6dec	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:01:55.007+02	3.96
8b922caa-6c43-46a4-a1be-fcf5009a703d	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:01:55.024+02	19.44
e4cd4ee4-315e-41d1-b5cd-584046586589	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:02:00.05+02	6.64
6b31520f-d268-4a2d-adfe-ed27f8a81ed4	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:02:00.062+02	7.12
d28acafa-d2a3-42f1-af25-6da04e9ae628	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:02:00.082+02	558.26
ddf19b69-7cb2-43b8-a9fd-c365ce3bd8f8	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:02:00.091+02	0.77
657d18a0-046a-4959-ae0f-50d2885819a4	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:02:00.1+02	4.08
2a559474-fb49-486e-b3ca-afe288729166	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:02:00.107+02	50
b72ae0c0-338d-4670-96d1-03a57d36a30a	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:02:05.148+02	6.62
66d48025-50a3-479f-bec9-0160c094b98f	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:02:05.157+02	7.15
c211a8eb-598b-44a3-bdbd-71561fcee5a1	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:02:05.166+02	558.26
e6f3214c-c753-4cfb-8577-b38cf4526f95	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:02:05.174+02	0.73
c6fead14-e906-4e7a-9fb4-afe95b140f4c	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:02:05.183+02	3.57
15fda55e-afbb-4983-8ff1-ca754be97078	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:02:05.192+02	50
7dd1b036-7c10-466c-83ca-e4652cff096b	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:02:05.2+02	19.55
60099056-b9e0-4222-8370-216af8748d35	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:02:10.225+02	6.6
c278db29-3b93-48e2-80c5-cf96077de2b4	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:02:10.234+02	7.12
09b7ce5e-e216-4d9d-ab7a-8ec658ff724d	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:02:10.242+02	558.27
6cf81c82-09f8-4bb0-834a-4cc129015b0c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:02:10.249+02	0.68
b09ded55-7c90-4472-9085-45991aa334cd	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:02:10.258+02	3.61
a4af38c9-f58d-4a72-8e22-2c032c6ec77d	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:02:10.266+02	50
3b4b057d-7649-499c-8dbc-4054e50802f0	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:02:10.275+02	19.54
f9dee35b-3494-4d86-aeac-92c85bf52186	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:11:30.844+02	6.51
702206f5-7c32-41ce-b515-788c98d69f7c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:11:30.873+02	0.73
c7839d14-312e-4dcf-be7d-20f22b8bbd06	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:11:30.882+02	3.12
ea050b4a-9c99-4334-ba90-5700324287f7	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:11:30.855+02	7.07
9874a1bb-92f0-47ba-9211-eddeab83dcb6	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:11:30.865+02	561.43
7740d1bf-09cc-4540-b5bd-50a7c31a1686	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:11:30.899+02	19.27
e9d4f0e9-cb3a-42a7-9f76-dc41dc8e9782	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:11:30.891+02	50.15
c1c5cb5e-4fbf-4d6c-a9ba-4665c0068872	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:11:35.916+02	6.49
b123f8fc-b4f3-44f0-b4bf-c0e1791539a8	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:11:35.928+02	7.06
fe737b2f-3180-4c4e-97b4-2abe8c3c0a8f	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:11:35.938+02	564.57
5d9e745e-c465-481f-bac8-9604bf99d5c4	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:11:35.948+02	0.75
162dee5c-3dca-4fc3-b7a1-173b523ed3c7	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:11:35.958+02	3.22
cb843533-2565-405c-bea0-bca2efed87d0	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:11:35.967+02	50.19
ad9612e8-6a18-412a-bd18-2d4387e0df03	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:11:35.976+02	19.28
ce554bc7-5fdc-4f99-8d3f-10cf8bddaac2	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:11:40.992+02	6.44
ad261190-d3d7-4aa2-8f3b-bbf681825873	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:11:41.005+02	7.08
f005ac73-06d7-497d-95fa-ade2893cb809	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:11:41.015+02	567.59
13830532-d01c-447d-91fa-de728e84799f	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:11:41.024+02	0.74
4c609d02-12ce-424e-adff-2f2f21de6f1f	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:11:41.042+02	50.21
d3f57077-a68d-46e7-9d69-edc151711276	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:11:41.032+02	3.29
c050f654-4749-4dcd-b492-47dbc560e97e	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:11:41.051+02	19.29
26c4ae19-a80a-4449-bb84-b6c850a7ef5e	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:11:46.067+02	6.48
72ebe8c2-2db4-4109-a980-8a90ce102332	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:11:46.08+02	7.06
20bf8199-421a-4dec-920c-488a0dd221f1	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:11:46.09+02	570.52
5244c6e4-2b96-4fb0-81d9-10797cf66b77	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:11:46.099+02	0.75
3594533c-c865-4bea-93ec-a61ada329ca4	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:11:46.107+02	3.35
adf76bf2-510f-4b1c-8dde-a30cdd3ec2c2	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:11:46.116+02	50.18
b295250b-fb1a-41f6-90a3-1dd747cc6e13	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:11:46.125+02	19.28
e86048a5-c852-40e6-b21a-93bbdb178ce2	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:11:51.141+02	6.48
42e2d15f-6855-4f8f-be0a-6ee565162e19	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:11:51.156+02	7.06
827a4040-e290-4a78-b362-753f306704fe	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:11:51.176+02	0.75
a8288536-c6f7-4d79-bc05-423eb3c3299e	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:11:51.166+02	573.36
c7e520d5-6999-4376-baa2-2c02835dc694	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:11:51.184+02	3.44
88208c58-fc3b-4dd7-bf00-149af9fed5d8	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:11:51.194+02	50.18
db72ed96-7d2f-4d2b-a40f-51d1d6773b87	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:11:51.203+02	19.27
93ee1801-9213-4ab3-8947-e0d6467ff34d	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:11:56.217+02	6.48
8d985cf7-e650-41b0-ab28-ba42090b83a9	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:11:56.229+02	7.05
3665a67b-df75-437c-87f7-2ec9da95b61b	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:11:56.238+02	576.09
a990d96f-86dd-4b57-9182-4b2e78e491fd	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:11:56.247+02	0.78
e8368e75-b59a-4279-ac20-72956519f896	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:11:56.257+02	3.52
ee8332e1-0cb1-467d-92af-28a5dbd6c39c	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:11:56.267+02	50.18
9c3d7505-41a0-413b-a76f-a61e8cde6de0	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:11:56.276+02	19.29
45f93495-ff7f-4cfc-88ad-a428586faf61	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:12:01.289+02	6.47
41e84bca-3555-4099-9db5-e7fbae20af47	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:12:01.3+02	7.04
e4d67757-446f-4c48-9377-6ac355289cb1	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:12:01.309+02	578.72
c20fb672-c106-49d7-823d-1e6528e7499d	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:12:01.319+02	0.75
0d91372b-eda2-4e06-a16b-7d28268533b9	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:12:01.33+02	3.58
01098ef7-6cdc-46bd-b09d-2ed84bc424e4	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:12:01.345+02	50.19
1ac01d17-e2e1-46e6-b386-e60975065b7b	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:12:01.354+02	19.29
bf102460-8859-4835-8a74-1f692c10b8dc	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:12:06.367+02	6.47
f87e8b41-aac7-4813-bba6-6d6ac91a9165	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:12:06.379+02	7.06
94047a56-cc74-482b-a51b-c7dc155b5dbb	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:12:06.389+02	581.25
900e0afc-a1ea-4111-9e66-d57d6bcc77d0	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:12:06.399+02	0.76
9ce46474-5cf1-4a6f-a361-96ac716c9a4c	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:12:06.419+02	50.19
c478b712-ff2f-4718-9b65-37ddcd0a04b7	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:12:06.408+02	3.62
82dababf-37f0-41a8-b60e-4632d52f9ff7	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:12:06.429+02	19.31
4fcce687-cba4-4ae9-81d8-fad12039b7a3	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:12:11.439+02	6.21
4694bc35-120a-43ba-add0-b79f02767bf0	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:12:11.451+02	7.04
17cdde2b-d422-467c-8678-63ed47fcd8dc	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:12:11.46+02	583.72
e471ad82-0446-483e-9759-385980e4cef2	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:12:11.469+02	0.76
29e39be9-aabd-4481-97e2-405e11169fa5	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:12:11.479+02	3.67
a3843f60-6024-49e6-a3c6-e44b3fc7d3a2	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:12:11.488+02	50.48
f77e42cc-16be-420c-b301-545d5435a671	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:12:11.498+02	19.29
72094120-8a77-4e70-8401-a69ad86e4b91	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:12:16.511+02	6.2
cf224081-ef69-4457-8bc1-d287af7d1cb6	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:12:16.522+02	7.04
8f9540e8-c105-48bb-a638-5c0600f84d3d	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:12:16.533+02	586.1
b10576f6-c3c2-44ec-968b-dcee4e423f53	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:12:16.543+02	0.76
8d4b3999-ba53-47f4-a350-33474dfb9e06	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:12:16.553+02	3.71
de248e4a-3013-417a-8d30-9c19d0406fa0	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:12:16.563+02	50.51
071f10dc-d99a-4db8-98d1-c27c478a2161	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:12:16.614+02	19.29
0e1c77da-f596-434a-bdfc-73c966691b7b	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:12:21.631+02	6.19
f534589f-4a47-4878-af37-272c0ad1f6bf	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:12:21.645+02	7.03
d90c027e-9730-4bf7-ae17-376c01feb1da	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:12:21.654+02	588.4
ed6098a3-87ea-4bf5-b059-ca16d5d784c9	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:12:21.663+02	0.76
1aafd9d1-312c-490b-8d25-d631e10ac923	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:12:21.673+02	3.74
6a7efaa5-9eee-45ee-bd25-801a422c0bd1	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:12:21.681+02	50.56
72daae3d-5ca3-4e04-93ac-6e3aa9b4486f	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:12:21.691+02	19.32
e248d5fa-d9e1-4029-a0a7-855ac016f31a	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:12:26.708+02	6.14
08838da5-8a3c-4a26-aa92-f2cbeb069bbb	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:12:26.72+02	7.02
d72261fd-7904-4f46-9117-85da620d0936	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:12:26.729+02	590.63
ad5ebc30-98e9-46aa-aee4-048c1d8291df	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:12:26.738+02	0.86
39792d1c-9681-4169-b46f-2d87d5898f1d	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:12:26.749+02	3.75
20dfeb82-c580-465c-8eed-fdf0d64f1d2f	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:12:31.794+02	7.02
7e933734-a0d3-46bb-9d1c-4b6b95c3da46	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:12:36.902+02	3.79
cd311c05-a65f-4e45-9481-12b5e24e51ea	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:12:26.758+02	50.61
39eb4e2c-e3e6-404d-a9cf-26ebace50581	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:12:31.782+02	6.1
1fab4172-7692-46b5-a56c-70215b1dcea0	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:12:36.922+02	19.3
c18fe278-1626-4282-bee8-dbc42dfb18a2	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:12:26.769+02	19.3
2a860a74-6a7f-40ae-8c31-935adea7615f	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:12:31.804+02	592.79
423bbde6-994a-41de-96b8-71b58a23514c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:12:31.814+02	0.86
62ac33d1-1ad9-4ade-b153-079f891cccb4	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:12:31.826+02	3.76
e6e030e1-3901-44da-8772-2997403d0051	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:12:31.835+02	50.65
43f9a2fe-6638-4871-bc6b-08014482e05d	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:12:31.848+02	19.3
247a4adb-4fd4-47c1-8242-537292d30ebc	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:12:36.862+02	6.17
371e4d66-2b48-4395-a7d2-ebf2fd5e7192	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:12:36.872+02	7.03
860b5e1d-d788-4096-8a54-902320bb4bbd	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:12:36.882+02	594.86
44d70492-ca0b-42b2-9bdf-66b0787be683	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:12:36.892+02	0.89
aa3a3bf6-c377-4594-beca-b2b15a4f3571	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:12:36.912+02	50.68
ab4add1f-1035-4812-a2dd-ba335d36fd3e	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:14:37.768+02	596.88
1121131d-6aef-44b8-8d0e-84cc538dfb3b	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:14:37.759+02	7.05
c074971d-96c6-4b5e-b795-51d51d3660e9	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:14:37.749+02	6.14
f75eb1e2-540f-4695-be06-358a3fa0c6ee	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:14:37.778+02	0.88
3c3165a8-7fc9-42da-b0c4-9a9f44753459	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:14:37.787+02	3.82
ef87e818-9f4e-4278-8a95-a53f93897834	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:14:37.807+02	19.31
bac5f6ae-4efb-4216-a51f-6645914376aa	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:14:37.797+02	50.68
3d05bf35-8e7f-4e21-92de-056da3eb08c7	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:14:42.822+02	6.1
2a5c3b08-1b0c-4557-8927-5ddc0aeb9b4b	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:14:42.833+02	7.05
2d03141b-6796-4660-9ac1-93a03c7c9a9d	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:14:42.842+02	598.82
5f6f5b3c-0c1d-4328-9c99-a628559d0a44	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:14:42.853+02	0.89
318f607f-4b7d-4aad-b7be-eff384d53fa5	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:14:42.863+02	3.86
d2b56e76-938d-4260-8bc5-c0b7c3a60128	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:14:42.874+02	50.7
3a3e7cd2-0c83-4fe1-b5f4-839a16f49157	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:14:42.883+02	19.32
3cad37fa-3b7b-4417-b05a-1416237014bc	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:14:47.894+02	6.07
25ed3cc4-255e-491f-9984-48fa1a3c68c8	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:14:47.904+02	7.06
e6daa555-a507-47d1-b4b1-ed57ce7e8f9d	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:14:47.916+02	600.7
2fab014f-b423-4ece-bba1-b378deed3cb1	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:14:47.927+02	0.89
3bc8baef-8276-4ff3-84f6-93afe4eaf813	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:14:47.936+02	3.89
1fcc1720-cab9-4dfb-89ed-3da69d04f01b	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:14:47.945+02	50.71
58817771-2bb2-4873-b9e5-fe1fe5d9ade4	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:14:47.954+02	19.34
aea34bab-840a-4ec7-923e-8e4be57c0665	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:14:52.964+02	6.04
20efc8fb-1072-44ac-b7a4-cc1ef6fe53df	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:14:52.973+02	7.06
e0c56ac2-4ece-4a14-a3b6-7a892e1fb5d1	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:14:52.983+02	602.5
131e43db-fbb8-42a9-9ecd-a2c07543a256	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:14:53.003+02	3.91
bc392302-fd9e-43ec-9da4-09eff5fe9d97	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:14:53.014+02	50.75
6664f8a4-b49b-4436-9691-35c8f54917e9	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:14:53.024+02	19.33
b2ab55c4-358a-44f2-ba14-17d67d3d2da5	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:14:52.993+02	0.9
f9fd7270-4baa-4e1b-94d2-2a343680cd73	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:14:58.032+02	6.01
08680455-1ef7-49ec-b5c6-c011a8216e2f	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:14:58.055+02	7.07
2992debb-6aa6-48bc-9e59-7932f7720611	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:14:58.078+02	604.25
204393f5-4af8-4c4f-b5e1-e77cb8ccdf7a	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:14:58.102+02	0.92
bbedab37-b4da-43cf-b6c3-a19e834a8f2d	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:14:58.124+02	3.91
c334c775-e581-4ff0-be7d-9b2a77911605	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:14:58.148+02	50.79
3d311439-8bc3-4a38-ad16-63c9aac4b54f	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:14:58.172+02	19.34
adb6dea1-64f2-4e7c-9ece-e3eaa07d03c1	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:16:08.783+02	5.99
bb301e1b-990f-4389-8cf1-47ce8ebbe19e	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:16:08.793+02	7.07
bc77eded-3ec6-45ff-bbb0-fea5a71ca51e	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:16:08.804+02	605.96
ec188ef7-dae9-46a4-8f4a-678c3563b5c3	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:16:08.814+02	0.95
d9e7af61-86d3-443e-b86a-1dd32d032557	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:16:08.843+02	19.35
c667f2c0-aafa-44b7-be9f-61ee00be88bb	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:16:08.833+02	50.85
e62707fe-64cf-48c0-96f4-c1524606246d	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:16:08.824+02	3.93
7f86d09a-2f41-41d1-a38e-be3a7ffd9ca6	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:16:13.858+02	5.95
6b28380e-886d-4d90-8153-1bd9150602ba	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:16:13.87+02	7.08
336e7bfc-d025-4984-8112-6df91e6cbc55	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:16:13.882+02	607.57
6b14ece3-96d1-479f-812a-9bda2d64dda0	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:16:13.892+02	0.96
051404a2-f746-4a64-bb61-cd7eb9fc9026	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:16:13.902+02	3.94
712d1b95-4bf1-4e97-964e-62a442ac7903	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:16:13.914+02	50.87
be638489-8fc6-4f9d-8e72-0ba9f0a90fe9	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:16:13.924+02	19.36
43db60a0-75af-4fd6-b2a0-d8fc88591c33	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:16:18.945+02	5.91
ec4cbd16-b0d2-4393-bb1a-6e89de4f146f	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:16:18.96+02	7.1
cff2b92b-5eec-4937-9a00-f531c5271a6e	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:16:18.973+02	609.15
12b87e07-38a7-4bf4-b504-7006ee740011	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:16:18.983+02	0.98
5bc76c37-0e44-480d-a5ad-082ccdf09362	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:16:18.992+02	3.97
9806a6ff-45f4-4c09-941e-ed96a99dad25	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:16:19.003+02	50.87
294bb966-d518-4af6-8f65-1d05f727a3a0	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:16:19.013+02	19.38
9cee294e-ce38-485e-9ed6-9a0f109b4213	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:16:24.027+02	14
c475a53f-c8b8-4b17-a9f0-c4e4d9c09015	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:16:24.039+02	7.11
2cdbccc9-0c6d-431d-b13e-8cd9e9134f7e	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:16:24.049+02	610.69
45d2b15e-0707-4a63-a002-327e0b50b6a1	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:16:24.061+02	1
e2cbcf17-aecd-4091-9e41-2aabbb1bd0f3	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:16:24.07+02	3.97
4fe4ec8f-cf3e-4a1d-90a4-15b0177b458a	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:16:24.08+02	63.4
60d7322c-193b-4b20-82f5-2e7f8baa0788	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:16:24.089+02	26.25
a65b06c9-5969-4c4a-ac20-f6487374dbae	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:17:11.083+02	13.96
a24ae5ca-986a-42e2-b449-ce3c4e4ef989	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:17:11.108+02	612.17
e8cd95e6-4d57-45ed-9d77-6116236a78dd	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:17:11.095+02	7.1
15623a03-2d12-462f-af5c-2892e0116da4	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:17:11.128+02	3.98
99bea3c7-31c1-4e2a-9107-e4cbd80d5dd3	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:17:11.14+02	63.39
16ed75c0-1241-4211-8e19-3cdb93e06cd0	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:17:11.118+02	1
aa074662-989e-4a66-b5c7-71c2fdcc11ef	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:17:11.151+02	26.19
35c2f4f7-dc3d-4cb1-b282-9c30c56dc3cc	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:17:16.17+02	13.94
6460a712-4a55-4b4d-b8f7-08e34de1c2c0	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:17:16.181+02	7.11
a83497e6-fdde-478c-abe0-d9183948bd29	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:17:16.191+02	613.58
f4885aac-e854-48fa-bcf4-25ea31eb98ce	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:17:16.201+02	8.53
141ec537-9394-4bd9-85f1-4f7f71250007	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:17:16.21+02	4
0bb9cc47-113b-44f7-99ff-64c5edc1a0f6	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:17:16.22+02	63.34
20b79365-27d1-4576-813e-058653b4e970	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:17:16.23+02	26.15
198b1f35-f77c-46df-8fc0-62d9ef2b3924	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:17:21.245+02	13.93
0944c5bc-4d73-43f3-bb84-d4c10b68b9fb	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:17:21.26+02	7.12
3003d1cd-625b-40bf-acdb-f60071b0f450	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:17:21.272+02	614.96
bf779059-bec3-4197-9d16-a7b2c89cfbab	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:17:21.283+02	8.56
e18042a3-df6e-4efe-8219-3367d6d95f00	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:17:21.292+02	4.02
b82d3ecf-2dda-4672-8d71-5a7df9400f72	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:17:21.301+02	63.29
398f16a2-7198-4742-b420-7c67c8063454	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:17:21.31+02	26.1
41b7691d-6d27-4dd3-a963-1c7424465796	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:17:26.326+02	13.89
84ed8c1d-9734-4e31-8061-931ba1dd1285	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:17:26.339+02	7.12
8121fdd9-219f-4f28-9c53-42513368e485	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:17:26.35+02	616.31
a9bf5fa2-2a8d-46c8-9494-fcd4f12621f5	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:17:26.359+02	8.56
bf0ff685-addc-46dd-8e2b-29d096d233b3	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:17:26.37+02	4.04
fb05de1d-a58f-4243-a322-e51a1f69173a	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:17:26.38+02	63.28
e1b316d8-7bd7-49c9-acbc-fe5590ad1f4c	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:17:26.39+02	26.07
943ab099-54e9-48ec-bdea-9aef5f345996	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:17:54.802+02	13.86
3ed54dc9-07d4-4d44-b4b1-5cef7922d637	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:17:54.815+02	7.1
7412bbd5-3504-463b-9be4-afb5039b37dd	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:17:54.827+02	617.58
926465ca-42f4-4da7-85bc-6d884366f9e8	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:17:54.837+02	8.59
c9df1790-084d-4a65-bb0c-0511de364db1	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:17:54.866+02	26.02
0c11fd27-6916-4515-b752-a10a90c6d117	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:17:54.857+02	63.27
07aaf0c0-e5fc-4eea-9713-3d067c41edcf	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:17:54.847+02	4.07
771f8f41-5ee0-43ae-8046-f5880bf58876	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:17:59.876+02	13.83
2c6b3a5f-cf8f-45c2-895a-0d933652eafd	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:17:59.887+02	7.09
f615beb7-75cf-4aec-83ef-2f2fe883f52b	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:17:59.928+02	63.23
5c745f42-b72b-4954-9be5-4c20d42240ce	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:18:04.946+02	13.78
19018318-83df-4fa7-ad56-6811e1775436	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:18:04.957+02	7.11
1b49e346-8d03-48c0-9a91-0a25a1dd300a	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:18:05.016+02	26.06
be63b08e-0d3d-41be-b6d7-b9f0315c2907	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:18:10.055+02	8.49
03c05e33-8f8e-4f78-8703-3479944036f6	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:18:10.085+02	-1.27
6a4d63e0-1947-4908-a586-ab0a74a822b1	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:17:59.897+02	618.83
fa31a1ff-cb9f-4620-854e-2977f7d756bc	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:17:59.918+02	3.8
a3d1e6df-6faa-4ee9-b56c-41c7091bad8b	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:18:04.969+02	620.02
aa2282e8-d119-41ed-a29c-9453b8103338	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:18:04.995+02	3.83
02b23848-d431-444a-8b56-a0e75e51ff31	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:18:10.045+02	621.18
0a0a7074-f49f-4edd-9934-da17f60068e9	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:18:10.065+02	3.86
4e57b91b-6a43-4a56-be54-e9821525ce86	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:17:59.907+02	8.5
4ed25174-dad2-4b73-b6dd-cddbebc74fb3	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:17:59.938+02	25.97
579f6384-8587-49b0-acf1-81127103809b	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:18:04.978+02	8.49
bcdb5df8-8857-4aaf-a990-889e8c8d547c	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:18:05.005+02	63.2
4dfc92bc-7f66-4b3d-8041-aa8e5a7dbcfa	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:18:10.022+02	13.74
c750682c-2793-4622-b595-2d4a8ee2c0f7	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:18:10.035+02	7.13
6d9ba173-9de9-4f04-85fe-49a3dcfef394	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:18:10.075+02	63.15
4ed42313-6536-4b71-b9d5-2fa1f1eb85f7	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:19:37.023+02	13.73
d56b4b6a-41e9-4a03-961c-e21d75fc8901	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:19:37.033+02	7.15
f681613a-160c-4632-936f-91960d8607a3	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:19:37.044+02	622.3
811f6cea-c210-4750-87b4-6f247d51494e	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:19:37.055+02	8.53
c79b21eb-7d7f-4b3a-b903-dc9eb2b820d3	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:19:37.065+02	3.89
cc827b0b-53de-43ff-a114-1757fa93bfb6	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:19:37.074+02	63.22
a764b030-a8ea-47d9-9ad6-6d900b8c81af	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:19:37.083+02	-1.07
e939c107-27df-4402-b78d-af9173f35251	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:19:42.101+02	13.68
f247a191-5c8c-414a-8291-eeaef12f8fa2	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:19:42.113+02	7.16
19f18ee3-aaa6-4da3-b437-3dbaf2a052a4	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:19:42.125+02	623.4
b38cdb23-76d8-4326-8b15-24d16fa5612b	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:19:42.139+02	8.52
372ce6cd-7eec-4939-ad79-1005bed58788	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:19:42.15+02	3.92
65fad8c0-e170-4fc8-b8cb-3f8179df45eb	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:19:42.16+02	63.21
d0611c83-5977-47d7-afe4-adcaa7572db2	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:19:42.17+02	-0.86
a80b5352-0652-4dae-8164-b960922ce9b6	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:19:47.18+02	13.65
1b3b9d2b-60b6-40e0-903c-05d8f377615a	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:19:47.191+02	7.17
f5acec87-910e-4a88-b176-62159efc9fd8	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:19:47.202+02	624.46
4191f1ee-7100-41b1-acd6-c37fd3a1bc9c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:19:47.212+02	8.51
fd829d6a-8dad-4761-aecb-1d29ad861549	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:19:47.222+02	3.66
2fc64ff7-9317-4e17-9e99-4f7db0e831d8	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:19:47.232+02	63.2
9c65afe6-985c-41bb-be59-128e5f679ef1	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:19:47.242+02	-0.64
2449c7ab-f523-4da6-8313-7f4920b0abdc	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:19:52.264+02	13.63
a789788a-f0ae-45a8-9922-aece15720b58	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:19:52.319+02	625.48
07c29955-76b2-4ddc-9f7f-ea11dbb78738	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:19:52.289+02	7.15
6b07ff2a-d693-482f-9a46-bc05a374f3ae	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:19:52.35+02	8.51
357a8038-cd41-4015-bbce-2d8c8a8a95df	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:19:52.379+02	3.83
5dcc21f3-8260-4d79-9542-36c010751990	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:19:52.407+02	63.2
afa6721d-600a-4e42-b589-a3c75ae2ae2e	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:19:52.427+02	-0.44
0cf145d1-239f-4016-9b91-4fc2dbaef9a8	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:20:05.333+02	6.49
f2954acc-e54d-4aed-b25f-ffb1a5ad8d0e	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:20:05.351+02	559.19
8caaf7da-c4b7-4676-93f4-6a047da624d8	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:20:05.342+02	7.08
3cdf73ed-c5ac-4eb3-856f-25084e260f59	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:20:05.36+02	0.72
0bd89457-681d-4221-a75a-12eb75dfb8e9	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:20:05.368+02	3.17
abca9762-64a2-460f-bd45-86ee94370e41	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:20:05.378+02	49.95
c68c95a4-7b87-4dea-8335-5a71e08ec57d	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:20:05.386+02	19.28
3bef641d-33e3-4083-b490-9b3d1d6fc117	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:20:10.403+02	6.45
77d72861-e698-443d-b94f-c9ab081bb4f5	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:20:10.413+02	26.78
52e0445e-9413-45d6-8dc5-ee91203eb8fa	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:20:10.423+02	562.39
6cf2fc78-5d45-4a8a-9094-b73cf39b1c6a	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:20:10.433+02	0.71
9675e731-8ea6-43bc-8ab1-8d7adbed5d7c	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:20:10.442+02	3.23
4c67b200-c9d3-49b6-84b0-54750742d9da	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:20:10.452+02	50.1
ca3a493b-53a8-42de-ad01-f65864face24	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:20:10.461+02	19.3
984f3317-3077-41a0-ad6a-9fec8401ea9b	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:20:15.475+02	6.43
a34cefc7-2229-4332-93f7-f7944927dbc7	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:20:15.484+02	26.59
08e9aa76-929d-4baa-bb1b-520a1067cda8	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:20:15.495+02	565.49
2ffc2b4f-2780-4ae6-bc5f-dd38d7124d11	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:20:15.506+02	0.74
9f82ea3b-a748-4122-8ec6-38196158fa04	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:20:15.515+02	3.3
578e2fbb-5b3b-4579-925f-a2cfcb8f06fe	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:20:15.525+02	79.18
93f7dc7b-0e56-497a-a709-cdc3045ea41b	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:20:15.533+02	19.29
3d9b6251-7ed6-4ecb-82ca-4b6f6a79acb0	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:20:20.545+02	6.39
80cbc738-e6ee-4719-b2b1-087025c56432	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:20:20.555+02	26.4
319dca61-202f-4e91-a876-b8a66857a7a2	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:20:20.566+02	568.48
1caff7bb-9bfd-4808-86a3-52da8318c3af	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:20:20.574+02	0.75
a2a20dd4-1319-4789-ba70-78398533b502	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:20:20.583+02	3.42
6eebe3fe-fd94-4368-8eeb-10e011d2db80	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:20:20.593+02	79.04
824d43ac-9d88-47fc-90f6-9842fa8dd019	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:20:20.602+02	19.31
550718b0-b772-49b2-bf80-a18d358c3aa0	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:20:45.219+02	561.08
388d0e30-5e01-4ca5-be90-c61739171a0e	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:20:45.228+02	0.73
e5322feb-94dd-43a2-8790-8843998cb404	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:20:45.209+02	6.88
968fcc12-a3c5-450c-9f19-344d2ceb2d3c	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:20:45.197+02	6.51
443667c8-efb8-4df2-8b97-4b08d6d086cb	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:20:45.238+02	3.18
2e44cf7f-bee5-435d-bc85-3bd40c292ed8	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:20:45.256+02	19.3
ca2cf165-ee1d-43fa-9d1f-f34a62be5da3	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:20:45.247+02	49.86
c845ed84-778b-45cd-a0d5-a75c654b2216	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:20:50.272+02	-17.29
7c51e040-d92d-4abf-a1c8-375a9d2e4dcd	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:20:50.283+02	6.87
506e00e9-8c76-46ca-9c74-70b75676b992	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:20:50.294+02	564.22
739c121d-a2ec-408e-860e-ba21d249c69a	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:20:50.303+02	0.76
47d30746-632f-4796-a7a3-afee67c571b2	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:20:50.312+02	3.26
9e7d9e2b-b98b-4f83-b966-c3d74c8232c6	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:20:50.322+02	50.02
81d31919-91e3-49a1-9a95-ef55925d52fb	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:20:50.331+02	19.32
e714e3d5-6440-490d-8e55-7be991974985	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:20:55.349+02	0
c2cca8e2-3581-480f-9c4f-42b97ad5fb19	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:20:55.359+02	6.89
45ee20e1-1b0f-4c82-b87c-72edef66fb2f	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:20:55.369+02	567.25
e253b80c-529e-4353-88d2-b8eae00671a5	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:20:55.379+02	0.78
18a4733f-d0e2-4a5e-9451-5720c46d339c	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:20:55.388+02	3.33
4f2c1449-8081-4fcf-9583-cb3371145ef9	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:20:55.398+02	50.06
e7e5d5a5-d896-460e-91cb-2c701aeeb5f0	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:20:55.407+02	19.32
488e431e-befe-4acb-b32e-9db2d9f4580e	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:21:20.007+02	6.65
c3a26da7-dafe-4372-be99-3ac9e358bbd5	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:21:20.017+02	7.07
ee952491-9d2e-4a61-9a1c-dd1c1d02f103	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:21:20.027+02	561.1
de1c7878-c087-4536-80cc-509810cf4d31	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:21:20.037+02	0.71
62474487-477f-4229-b83e-a4d86c67c08b	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:21:20.053+02	50.03
20d44989-543c-4b09-90de-b327b73f947e	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:21:20.045+02	3.16
18d896e8-4111-4312-9a60-2d35041e539f	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:21:20.061+02	19.31
7e4fa772-642a-477e-8db7-484ebb6e2ee4	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:21:25.081+02	6.62
b6fc47ad-4f56-482a-bd61-2373aa4e4cff	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:21:25.093+02	7.06
21eb3c7e-1b36-4092-b38b-d6d4d1ff84c3	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:21:25.103+02	564.23
3481a648-b350-448f-862b-089cc34c8b13	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:21:25.111+02	0.7
efa670be-45ee-4df7-9fcd-2564fafb7959	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:21:25.12+02	3.25
0d573a2f-4871-420a-839c-a2155dceeff9	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:21:25.13+02	50.08
7561ff16-3a75-4c39-9a93-8b9dd3cae663	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:21:25.138+02	19.3
ace3a0c6-349b-4e41-958e-5de402601e8d	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:21:30.153+02	6.58
e21ce049-75ac-410f-919c-ae9c498ecb58	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:21:30.164+02	7.05
5c2c2b98-e5b9-4b65-ae96-bc52a7939b63	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:21:30.173+02	567.25
7f5ab875-4654-443b-bb5b-66b7f58c9f0c	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:21:30.181+02	0.73
55cbed0f-0b6f-4224-86d9-7ec9fde7144f	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:21:30.19+02	3.31
366da398-8764-41bc-874e-e05c73e0986f	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:21:30.199+02	50.11
1cac5f43-f2e2-438a-9f98-42e6ce678e77	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:21:30.207+02	19.3
b26d310c-314d-4105-9aad-f79fa4000bbd	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:21:35.224+02	6.57
ca8edbb3-dc07-4f49-9010-b71c10c692ff	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:21:35.236+02	7.07
8b25572f-9427-4410-a325-f49338368687	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:21:35.246+02	570.16
c46b0854-7671-4554-8bae-59669cf97114	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:21:40.347+02	3.48
81ecd3b4-2cd2-405a-8b54-a26d06454bbc	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:21:35.254+02	0.74
5ecf8688-b6b9-48d8-8f6a-ba1bcb3b38fc	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:21:35.265+02	3.39
1667f773-b345-4104-aa92-c0dfd3844223	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:21:35.284+02	19.31
53a7fa01-bf78-4675-a83c-0af5855db92a	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:21:35.274+02	50.16
237b0d21-319c-4f79-bb98-b15a6f3e9447	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:21:40.301+02	6.54
3b85c1df-5fbb-4bc0-ac16-b6e7e3aa2abe	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:21:40.315+02	7.06
232f93b6-0cea-4e19-b597-9e5280b589ce	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:21:40.325+02	572.97
faed0da8-8f7a-46a1-aeda-67fae649ddd0	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:21:40.357+02	50.2
3e4ee1b5-92f6-4c93-b66c-c39b611ed57f	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:21:44.797+02	6.5
349c8222-2f1e-4657-b146-4c41a7e9e8ab	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:21:44.816+02	7.06
dc11bccd-7eda-4718-b55c-ec2dc42a64fd	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:21:44.825+02	575.71
b23ceba3-fa98-4839-b038-2e14033391a4	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:21:44.833+02	0.75
4019fecc-6e3c-4dee-b70e-bb38be3becfc	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:21:44.843+02	3.52
0d30ceff-1c10-4613-98d5-e4b36788d043	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:21:44.851+02	50.27
8b0ba5c9-6a2d-426c-b035-719a316ff238	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:21:44.862+02	19.35
40134385-247f-40b8-9bc0-455861fa5b00	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 11:21:49.878+02	6.49
5a314475-b694-42ec-998f-7b2b7b12cfc3	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 11:21:49.889+02	7.05
1b3e0057-0fbd-4c67-88c1-fdf02425b09c	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 11:21:49.901+02	570.06
6b1c3520-e4d8-4fb2-9961-8b3f7d6ec885	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:21:49.911+02	0.76
7f3297d7-d150-4d86-a621-a0306677111c	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 11:21:49.921+02	3.58
b83af59a-976b-432c-8529-da39078e363a	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 11:21:49.932+02	50.32
58fcf57e-3a3a-48cd-913c-100ed25d2540	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:21:49.942+02	19.35
79f5c34b-eeb1-468c-96dc-7ab2d9025701	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 11:21:40.337+02	0.76
8ad1516a-1ff0-4e20-add2-25f4d4406e12	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 11:21:40.367+02	19.34
ed93290d-000b-4021-a0b2-4bbf0017ae2d	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:58:44.338+02	6.45
c61cb50b-ca45-4e34-8406-bd51f45fbba5	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:58:44.359+02	572.88
629a5670-b5db-4d61-928b-ea1fd3246657	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:58:44.401+02	50.34
b0288f30-abbc-4fe8-a312-49f73847c237	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:58:44.413+02	19.37
60f14297-b9c7-4599-9231-6edf0497629b	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:58:49.447+02	6.41
9d4d371f-842b-433a-8781-c5f143241387	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:58:49.463+02	7.07
db939a46-dce5-4043-ada3-306f5e616338	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:58:49.481+02	0.78
d8fe35bb-7be5-40c4-a97a-a8482e514faf	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:58:49.502+02	50.39
e3ae317a-bcfb-4720-85bb-be10b4168f7a	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:58:49.512+02	19.39
06c8d4c4-f304-45fa-b4f3-7fee6035673e	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:58:54.539+02	6.39
7e4e157c-d674-42bf-bede-4dcd6518ea1e	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:58:54.558+02	578.26
c50ee359-07d8-45ab-b70d-9c8b354eafb0	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:58:54.568+02	0.8
555d892c-f008-4a8e-b885-92ef393ffdfc	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:58:59.638+02	7.07
7bfa3bdc-7278-4db7-9c95-d0662fe777f7	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:58:59.682+02	50.52
d950e84c-534e-4325-9904-34aef3e02e29	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:58:59.693+02	19.39
f70c9ef5-beac-43aa-9351-df305a337b01	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:59:04.72+02	6.33
3e0f88ed-c3a8-44a9-810c-f4ae9b353443	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:59:04.741+02	583.29
aef16d00-ad83-4fdb-b7fe-7ed9e80d86e7	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:59:04.779+02	19.4
635f1255-d5be-44b7-83e2-bf115ffff9f3	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:59:45.779+02	6.3
7787e6b9-5964-45e0-b407-47858d7d10b9	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:59:45.808+02	0.81
f1f25168-feba-4c2b-9b6f-40661a03a877	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:59:45.836+02	19.42
85495545-effd-4c4f-a98c-d7c3446827e8	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:59:45.827+02	50.58
16bc508b-89dd-443e-808f-4aae07f52faa	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:59:50.856+02	6.27
f8b1a28a-a538-4699-8c58-c4c33872f101	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:59:50.89+02	0.83
0ff98ff5-f85e-4683-a7be-a4383fc5c514	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:59:50.899+02	3.63
7b768e14-7d28-4095-b617-212e2e90af47	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:59:50.914+02	19.43
7226f5e0-cdef-4833-961e-e7e7b315d59f	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:58:44.348+02	7.07
d0f71026-e63d-47b2-916a-72b6f28b501f	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:58:44.373+02	0.78
87c8074d-90a2-442c-9c3a-a55d47eb042d	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:58:44.386+02	3.61
93559adb-2631-4e41-a45a-2288bc7fec29	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:58:49.473+02	575.6
7d7cb5ab-94b7-4818-8fcf-c00272c513e5	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:58:49.492+02	3.52
9304d685-4c80-4496-8d48-b7eebf861f27	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:58:54.548+02	7.08
f4777247-bcaa-49a6-aa03-8c2e3785657a	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:58:54.579+02	3.54
868e648a-a23c-4d59-9cf2-7255d8ad2f4e	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:58:54.588+02	50.45
a5249f84-7cd4-4102-8166-3400815d02da	a1b2c3d4-e5f6-4000-8000-000000000007	2025-12-26 12:58:54.596+02	19.4
9589b27a-01ea-4bbc-9267-cd8a7a20fa88	a1b2c3d4-e5f6-4000-8000-000000000001	2025-12-26 12:58:59.627+02	6.34
cc8deca8-72d4-47c3-8e09-8ab29f439aa8	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:58:59.648+02	580.83
d0ba0db0-a96a-4381-84ce-e0573c10c4fb	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:58:59.661+02	0.77
ffbb1589-f5d0-4183-8641-e618f46ac2c5	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:58:59.673+02	3.55
7c68238b-74b7-4cc5-a05c-b8a28adc4662	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:59:04.73+02	7.08
184c4592-5f56-478d-aa54-7886c86b4728	a1b2c3d4-e5f6-4000-8000-000000000004	2025-12-26 12:59:04.75+02	0.78
856304eb-7c68-4e0a-bbc7-3f69cfe05ca8	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:59:04.76+02	3.56
6a13edf3-86c1-4d5f-8eb2-a14a4e775afc	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:59:04.769+02	50.54
5dea867e-87c8-416d-80b9-aa6950d8f240	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:59:45.789+02	7.09
3a263091-48b5-4de7-b870-4462b3c861f3	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:59:45.799+02	585.68
ada00072-7c87-4703-98ae-cc83a8246e49	a1b2c3d4-e5f6-4000-8000-000000000005	2025-12-26 12:59:45.816+02	3.61
9825afa6-909d-4cf9-88ec-3f08e7eb6453	a1b2c3d4-e5f6-4000-8000-000000000002	2025-12-26 12:59:50.87+02	7.1
89190499-f87a-4b10-9041-6b6fb0f24986	a1b2c3d4-e5f6-4000-8000-000000000003	2025-12-26 12:59:50.88+02	588.01
55ad0677-f1db-456a-a805-b32980190554	a1b2c3d4-e5f6-4000-8000-000000000006	2025-12-26 12:59:50.907+02	50.63
\.


--
-- Data for Name: user_stations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_stations (user_id, station_id, assigned_at) FROM stdin;
3422b448-2460-4fd2-9183-8000de6f8343	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2025-12-24 20:03:46.801977+02
f47ac10b-58cc-4372-a567-0e02b2c3d479	b5f2c4e0-8d1a-11ee-b9d1-0242ac120002	2025-12-24 20:03:46.801977+02
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, full_name, role, created_at) FROM stdin;
4f45cc15-29dc-4916-9546-9014c9d587f8	user@example.com	$2b$10$NMNQlL4n9Hk2hF27GekDDuzQ/USd/0c0w7K.AY/Xn.QQLND1dDBwm	string	admin	2025-12-21 16:47:43.065293+02
3422b448-2460-4fd2-9183-8000de6f8343	tech@iot.com	$2b$10$NMNQlL4n9Hk2hF27GekDDuzQ/USd/0c0w7K.AY/Xn.QQLND1dDBwm	John Technician	technician	2025-12-24 20:03:46.801977+02
d290f1ee-6c54-4b01-90e6-d701748f0851	admin@iot.com	$2b$10$NMNQlL4n9Hk2hF27GekDDuzQ/USd/0c0w7K.AY/Xn.QQLND1dDBwm	System Administrator	admin	2025-12-24 20:03:46.801977+02
f47ac10b-58cc-4372-a567-0e02b2c3d479	manager@iot.com	$2b$10$NMNQlL4n9Hk2hF27GekDDuzQ/USd/0c0w7K.AY/Xn.QQLND1dDBwm	Site Manager	manager	2025-12-24 20:03:46.801977+02
29c4dcfe-da49-4b9e-ae8b-71d40f5d794f	user@example1.com	$2b$10$p1EGTC8srmIqW/P2qar62.MKPASGHj.bjDKAv3gujsh6P6o/pp8r6	string	admin	2025-12-27 02:02:32.47758+02
\.


--
-- Name: __drizzle_migrations_id_seq; Type: SEQUENCE SET; Schema: drizzle; Owner: postgres
--

SELECT pg_catalog.setval('drizzle.__drizzle_migrations_id_seq', 1, false);


--
-- Name: __drizzle_migrations __drizzle_migrations_pkey; Type: CONSTRAINT; Schema: drizzle; Owner: postgres
--

ALTER TABLE ONLY drizzle.__drizzle_migrations
    ADD CONSTRAINT __drizzle_migrations_pkey PRIMARY KEY (id);


--
-- Name: alerts alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (id);


--
-- Name: controller_logs controller_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.controller_logs
    ADD CONSTRAINT controller_logs_pkey PRIMARY KEY (id);


--
-- Name: controllers controllers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.controllers
    ADD CONSTRAINT controllers_pkey PRIMARY KEY (id);


--
-- Name: parameters parameters_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_code_key UNIQUE (code);


--
-- Name: parameters parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_pkey PRIMARY KEY (id);


--
-- Name: sensors sensors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensors
    ADD CONSTRAINT sensors_pkey PRIMARY KEY (id);


--
-- Name: station_thresholds station_thresholds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.station_thresholds
    ADD CONSTRAINT station_thresholds_pkey PRIMARY KEY (id);


--
-- Name: station_thresholds station_thresholds_station_id_parameter_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.station_thresholds
    ADD CONSTRAINT station_thresholds_station_id_parameter_id_key UNIQUE (station_id, parameter_id);


--
-- Name: stations stations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stations
    ADD CONSTRAINT stations_pkey PRIMARY KEY (id);


--
-- Name: telemetry telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetry
    ADD CONSTRAINT telemetry_pkey PRIMARY KEY (id);


--
-- Name: user_stations user_stations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_stations
    ADD CONSTRAINT user_stations_pkey PRIMARY KEY (user_id, station_id);


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
-- Name: idx_alerts_dashboard; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_alerts_dashboard ON public.alerts USING btree (station_id, target_role) WHERE (is_resolved = false);


--
-- Name: idx_logs_history; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_logs_history ON public.controller_logs USING btree (controller_id, "timestamp" DESC);


--
-- Name: idx_telemetry_sensor_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_telemetry_sensor_time ON public.telemetry USING btree (sensor_id, measured_at DESC);


--
-- Name: alerts alerts_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_station_id_fkey FOREIGN KEY (station_id) REFERENCES public.stations(id) ON DELETE CASCADE;


--
-- Name: controller_logs controller_logs_controller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.controller_logs
    ADD CONSTRAINT controller_logs_controller_id_fkey FOREIGN KEY (controller_id) REFERENCES public.controllers(id) ON DELETE CASCADE;


--
-- Name: controllers controllers_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.controllers
    ADD CONSTRAINT controllers_station_id_fkey FOREIGN KEY (station_id) REFERENCES public.stations(id) ON DELETE CASCADE;


--
-- Name: sensors sensors_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensors
    ADD CONSTRAINT sensors_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameters(id);


--
-- Name: sensors sensors_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensors
    ADD CONSTRAINT sensors_station_id_fkey FOREIGN KEY (station_id) REFERENCES public.stations(id) ON DELETE CASCADE;


--
-- Name: station_thresholds station_thresholds_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.station_thresholds
    ADD CONSTRAINT station_thresholds_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameters(id) ON DELETE CASCADE;


--
-- Name: station_thresholds station_thresholds_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.station_thresholds
    ADD CONSTRAINT station_thresholds_station_id_fkey FOREIGN KEY (station_id) REFERENCES public.stations(id) ON DELETE CASCADE;


--
-- Name: telemetry telemetry_sensor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetry
    ADD CONSTRAINT telemetry_sensor_id_fkey FOREIGN KEY (sensor_id) REFERENCES public.sensors(id) ON DELETE CASCADE;


--
-- Name: user_stations user_stations_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_stations
    ADD CONSTRAINT user_stations_station_id_fkey FOREIGN KEY (station_id) REFERENCES public.stations(id) ON DELETE CASCADE;


--
-- Name: user_stations user_stations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_stations
    ADD CONSTRAINT user_stations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict AlcEtR4sYRJ31FiJxvE8DHixpw9anNpzhEj3d6d8g5s8a8fhJqIZbfY3xlWAJPj

