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

--
-- Name: import; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA import;


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: age_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.age_type AS ENUM (
    'new_tree',
    'over_two_years'
);


--
-- Name: capture_approval_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.capture_approval_type AS ENUM (
    'simple_lead',
    'complex_leaf',
    'acacia_like',
    'conifer',
    'fruit',
    'mangrove',
    'palm',
    'timber'
);


--
-- Name: morphology_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.morphology_type AS ENUM (
    'seedling',
    'direct_seedling',
    'fmnr'
);


--
-- Name: rejection_reason_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.rejection_reason_type AS ENUM (
    'not_tree',
    'unapproved_tree',
    'blurry_image',
    'dead',
    'duplicate_image',
    'flag_user',
    'needs_contact_or_review'
);


--
-- Name: makegrid_2d(public.geometry, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.makegrid_2d(bound_polygon public.geometry, width_step integer, height_step integer) RETURNS public.geometry
    LANGUAGE plpgsql
    AS $_$
DECLARE
  Xmin DOUBLE PRECISION;
  Xmax DOUBLE PRECISION;
  Ymax DOUBLE PRECISION;
  X DOUBLE PRECISION;
  Y DOUBLE PRECISION;
  NextX DOUBLE PRECISION;
  NextY DOUBLE PRECISION;
  CPoint public.geometry;
  sectors public.geometry[];
  i INTEGER;
  SRID INTEGER;
BEGIN
  Xmin := ST_XMin(bound_polygon);
  Xmax := ST_XMax(bound_polygon);
  Ymax := ST_YMax(bound_polygon);
  SRID := ST_SRID(bound_polygon);

  Y := ST_YMin(bound_polygon); --current sector's corner coordinate
  i := -1;
  <<yloop>>
  LOOP
    IF (Y >= Ymax) THEN
        EXIT;
    END IF;

    X := Xmin;
    <<xloop>>
    LOOP
      IF (X >= Xmax) THEN
          EXIT;
      END IF;

      CPoint := ST_SetSRID(ST_MakePoint(X, Y), SRID);
      NextX := ST_X(ST_Project(CPoint, $2, radians(90))::geometry);
      NextY := ST_Y(ST_Project(CPoint, $3, radians(0))::geometry);

      IF (NextX > Xmax) THEN
          NextX := Xmax;
      END IF;

      IF (NextX < X) THEN
          NextX := Xmax;
      END IF;

      i := i + 1;
      sectors[i] := ST_MakeEnvelope(X, Y, NextX, NextY, SRID);

      X := NextX;
    END LOOP xloop;
    CPoint := ST_SetSRID(ST_MakePoint(X, Y), SRID);
    NextY := ST_Y(ST_Project(CPoint, $3, radians(0))::geometry);
    Y := NextY;
  END LOOP yloop;

  RETURN ST_Collect(sectors);
END;
$_$;


--
-- Name: token_transaction_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.token_transaction_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                 BEGIN
                    INSERT INTO transaction
                    (token_id, sender_entity_id, receiver_entity_id)
                    VALUES
                    (OLD.id, OLD.entity_id, NEW.entity_id);
                    RETURN NEW;
                 END;
             $$;


--
-- Name: trigger_set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
    END;
    $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: continents; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE import.continents (
    id integer NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    continent character varying(13),
    sqmi double precision,
    sqkm double precision
);


--
-- Name: continents_id_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE import.continents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continents_id_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE import.continents_id_seq OWNED BY import.continents.id;


--
-- Name: contintents_layer_override; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE import.contintents_layer_override (
    id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    name character varying(100)
);


--
-- Name: countries; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE import.countries (
    id integer,
    geom public.geometry(MultiPolygon,4326),
    featurecla character varying(15),
    scalerank integer,
    labelrank integer,
    sovereignt character varying(32),
    sov_a3 character varying(3),
    adm0_dif integer,
    level integer,
    type character varying(17),
    admin character varying(35),
    adm0_a3 character varying(3),
    geou_dif integer,
    geounit character varying(35),
    gu_a3 character varying(3),
    su_dif integer,
    subunit character varying(35),
    su_a3 character varying(3),
    brk_diff integer,
    name character varying(25),
    name_long character varying(35),
    brk_a3 character varying(3),
    brk_name character varying(32),
    brk_group character varying(17),
    abbrev character varying(13),
    postal character varying(4),
    formal_en character varying(52),
    formal_fr character varying(35),
    name_ciawf character varying(45),
    note_adm0 character varying(22),
    note_brk character varying(51),
    name_sort character varying(35),
    name_alt character varying(14),
    mapcolor7 integer,
    mapcolor8 integer,
    mapcolor9 integer,
    mapcolor13 integer,
    pop_est bigint,
    pop_rank integer,
    gdp_md_est double precision,
    pop_year integer,
    lastcensus integer,
    gdp_year integer,
    economy character varying(26),
    income_grp character varying(23),
    wikipedia integer,
    fips_10_ character varying(3),
    iso_a2 character varying(3),
    iso_a3 character varying(3),
    iso_a3_eh character varying(3),
    iso_n3 character varying(3),
    un_a3 character varying(4),
    wb_a2 character varying(3),
    wb_a3 character varying(3),
    woe_id integer,
    woe_id_eh integer,
    woe_note character varying(167),
    adm0_a3_is character varying(3),
    adm0_a3_us character varying(3),
    adm0_a3_un integer,
    adm0_a3_wb integer,
    continent character varying(23),
    region_un character varying(23),
    subregion character varying(25),
    region_wb character varying(26),
    name_len integer,
    long_len integer,
    abbrev_len integer,
    tiny integer,
    homepart integer,
    min_zoom double precision,
    min_label double precision,
    max_label double precision,
    ne_id bigint,
    wikidataid character varying(8),
    name_ar character varying(72),
    name_bn character varying(125),
    name_de character varying(46),
    name_en character varying(44),
    name_es character varying(44),
    name_fr character varying(54),
    name_el character varying(88),
    name_hi character varying(123),
    name_hu character varying(41),
    name_id character varying(46),
    name_it character varying(44),
    name_ja character varying(63),
    name_ko character varying(47),
    name_nl character varying(46),
    name_pl character varying(47),
    name_pt character varying(43),
    name_ru character varying(86),
    name_sv character varying(42),
    name_tr character varying(42),
    name_vi character varying(56),
    name_zh character varying(36)
);


--
-- Name: greenstand_countries; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE import.greenstand_countries (
    gid integer NOT NULL,
    name character varying(254),
    centroid character varying(254),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: greenstand_countries_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE import.greenstand_countries_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: greenstand_countries_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE import.greenstand_countries_gid_seq OWNED BY import.greenstand_countries.gid;


--
-- Name: tanzania_regions; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE import.tanzania_regions (
    id integer NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    "Region_Cod" character varying,
    "Region_Nam" character varying
);


--
-- Name: tanzania_regions_id_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE import.tanzania_regions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tanzania_regions_id_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE import.tanzania_regions_id_seq OWNED BY import.tanzania_regions.id;


--
-- Name: world_continents_simplified; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE import.world_continents_simplified (
    id integer NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    continent character varying(13),
    sqmi double precision,
    sqkm double precision
);


--
-- Name: world_continents_simplified_id_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE import.world_continents_simplified_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: world_continents_simplified_id_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE import.world_continents_simplified_id_seq OWNED BY import.world_continents_simplified.id;


--
-- Name: zoom_level_2; Type: TABLE; Schema: import; Owner: -
--

CREATE TABLE import.zoom_level_2 (
    gid integer NOT NULL,
    name character varying(254),
    cent_lat integer,
    cent_lon integer,
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: zoom_level_2_gid_seq; Type: SEQUENCE; Schema: import; Owner: -
--

CREATE SEQUENCE import.zoom_level_2_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: zoom_level_2_gid_seq; Type: SEQUENCE OWNED BY; Schema: import; Owner: -
--

ALTER SEQUENCE import.zoom_level_2_gid_seq OWNED BY import.zoom_level_2.gid;


--
-- Name: region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region (
    id integer NOT NULL,
    type_id integer,
    name character varying,
    metadata jsonb,
    geom public.geometry(MultiPolygon,4326),
    centroid public.geometry(Point,4326)
);


--
-- Name: tree_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tree_region (
    id integer NOT NULL,
    tree_id integer,
    zoom_level integer,
    region_id integer
);


--
-- Name: trees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trees (
    id integer DEFAULT nextval('public.trees_id_seq'::regclass) NOT NULL,
    time_created timestamp without time zone NOT NULL,
    time_updated timestamp without time zone NOT NULL,
    missing boolean DEFAULT false,
    priority boolean DEFAULT false,
    cause_of_death_id integer,
    planter_id integer,
    primary_location_id integer,
    settings_id integer,
    override_settings_id integer,
    dead integer DEFAULT 0 NOT NULL,
    photo_id integer,
    image_url character varying(200),
    certificate_id integer,
    estimated_geometric_location public.geometry(Point,4326),
    lat numeric,
    lon numeric,
    gps_accuracy integer,
    active boolean DEFAULT true,
    planter_photo_url character varying,
    planter_identifier character varying,
    device_id integer,
    sequence integer,
    note character varying,
    verified boolean DEFAULT false NOT NULL,
    uuid character varying,
    approved boolean DEFAULT false NOT NULL,
    status character varying DEFAULT 'planted'::character varying NOT NULL,
    cluster_regions_assigned boolean DEFAULT false NOT NULL,
    species_id integer,
    planting_organization_id integer,
    payment_id integer,
    contract_id integer,
    token_issued boolean DEFAULT false NOT NULL,
    morphology public.morphology_type,
    age public.age_type,
    species character varying,
    capture_approval_tag public.capture_approval_type,
    rejection_reason public.rejection_reason_type
);


--
-- Name: active_tree_region; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.active_tree_region AS
 SELECT tree_region.id,
    region.id AS region_id,
    region.centroid,
    region.type_id,
    tree_region.zoom_level
   FROM ((public.tree_region
     JOIN public.trees ON ((trees.id = tree_region.tree_id)))
     JOIN public.region ON ((region.id = tree_region.region_id)))
  WHERE (trees.active = true)
  WITH NO DATA;


--
-- Name: api_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_key (
    id integer NOT NULL,
    key character varying,
    tree_token_api_access boolean,
    hash character varying,
    salt character varying,
    name character varying
);


--
-- Name: api_key_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_key_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_key_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_key_id_seq OWNED BY public.api_key.id;


--
-- Name: certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificates (
    id integer NOT NULL,
    donor_id integer,
    token character varying
);


--
-- Name: certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.certificates_id_seq OWNED BY public.certificates.id;


--
-- Name: clusters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clusters (
    id integer NOT NULL,
    count integer,
    zoom_level integer,
    location public.geometry(Point,4326)
);


--
-- Name: clusters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clusters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clusters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clusters_id_seq OWNED BY public.clusters.id;


--
-- Name: contract; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contract (
    id integer NOT NULL,
    author_id integer NOT NULL,
    name character varying NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    contract json NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: contract_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contract_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contract_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contract_id_seq OWNED BY public.contract.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.devices (
    id integer NOT NULL,
    android_id character varying,
    app_version character varying,
    app_build integer,
    manufacturer character varying,
    brand character varying,
    model character varying,
    hardware character varying,
    device character varying,
    serial character varying,
    android_release character varying,
    android_sdk integer,
    sequence bigint,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.devices_id_seq OWNED BY public.devices.id;


--
-- Name: donors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.donors (
    id integer NOT NULL,
    organization_id integer,
    first_name character varying,
    last_name character varying,
    email character varying
);


--
-- Name: donors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.donors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: donors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.donors_id_seq OWNED BY public.donors.id;


--
-- Name: entity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity (
    id integer NOT NULL,
    type character varying,
    name character varying,
    first_name character varying,
    last_name character varying,
    email character varying,
    phone character varying,
    pwd_reset_required boolean DEFAULT false,
    website character varying,
    wallet character varying,
    password character varying,
    salt character varying,
    active_contract_id integer,
    offering_pay_to_plant boolean DEFAULT false NOT NULL,
    tree_validation_contract_id integer,
    logo_url character varying
);


--
-- Name: entity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entity_id_seq OWNED BY public.entity.id;


--
-- Name: entity_manager; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_manager (
    id integer NOT NULL,
    parent_entity_id integer,
    child_entity_id integer,
    active boolean DEFAULT false NOT NULL
);


--
-- Name: entity_manager_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entity_manager_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entity_manager_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entity_manager_id_seq OWNED BY public.entity_manager.id;


--
-- Name: entity_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_role (
    id integer NOT NULL,
    entity_id integer,
    role_name character varying,
    enabled boolean
);


--
-- Name: entity_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entity_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entity_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entity_role_id_seq OWNED BY public.entity_role.id;


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id integer DEFAULT nextval('public.locations_id_seq'::regclass) NOT NULL,
    lat character varying(10) NOT NULL,
    lon character varying(10) NOT NULL,
    gps_accuracy integer,
    planter_id integer
);


--
-- Name: long_running; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.long_running AS
 SELECT pg_stat_activity.pid,
    (now() - pg_stat_activity.query_start) AS duration,
    pg_stat_activity.query,
    pg_stat_activity.state
   FROM pg_stat_activity
  WHERE ((now() - pg_stat_activity.query_start) > '00:05:00'::interval);


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    run_on timestamp without time zone NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: note_trees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_trees (
    tree_id integer,
    note_id integer
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id integer DEFAULT nextval('public.notes_id_seq'::regclass) NOT NULL,
    content text,
    time_created timestamp without time zone NOT NULL,
    planter_id integer
);


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name character varying
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment (
    id integer NOT NULL,
    sender_entity_id integer,
    receiver_entity_id integer,
    date_paid date,
    tree_amt integer,
    usd_amt money,
    local_amt integer,
    paid_by character varying
);


--
-- Name: payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_id_seq OWNED BY public.payment.id;


--
-- Name: payment_list; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.payment_list AS
 SELECT trees.id,
    trees.time_created,
    trees.planter_id AS user_id,
    trees.primary_location_id,
    trees.settings_id,
    trees.override_settings_id,
    trees.dead,
    trees.photo_id,
    trees.image_url,
    trees.certificate_id,
    trees.estimated_geometric_location,
    trees.lat,
    trees.lon,
    trees.gps_accuracy,
    trees.active,
    trees.planter_photo_url,
    trees.planter_identifier,
    trees.device_id,
    trees.sequence,
    trees.note,
    trees.verified,
    trees.uuid,
    trees.approved,
    trees.status,
    trees.cluster_regions_assigned
   FROM public.trees
  WHERE ((trees.approved = true) AND (trees.active = true) AND (trees.device_id = ANY (ARRAY[216, 238, 317, 298, 360, 598])))
  WITH NO DATA;


--
-- Name: pending_update_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pending_update_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pending_update; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pending_update (
    id integer DEFAULT nextval('public.pending_update_id_seq'::regclass) NOT NULL,
    planter_id integer,
    settings_id integer,
    tree_id integer,
    location_id integer
);


--
-- Name: person; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.person AS
 SELECT entity.id,
    entity.first_name,
    entity.last_name,
    entity.email,
    entity.phone,
    entity.pwd_reset_required
   FROM public.entity
  WHERE ((entity.type)::text = 'p'::text);


--
-- Name: photo_trees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.photo_trees (
    tree_id integer,
    photo_id integer
);


--
-- Name: photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.photos (
    id integer DEFAULT nextval('public.photos_id_seq'::regclass) NOT NULL,
    outdated boolean DEFAULT false,
    time_taken timestamp without time zone NOT NULL,
    location_id integer,
    user_id integer,
    base64_image bytea
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planter (
    id integer DEFAULT nextval('public.users_id_seq'::regclass) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    email character varying,
    organization character varying,
    phone text,
    pwd_reset_required boolean DEFAULT false,
    image_url character varying,
    person_id integer,
    organization_id integer
);


--
-- Name: planter_organization; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.planter_organization AS
 SELECT entity.id,
    entity.name,
    entity.phone,
    entity.website
   FROM public.entity
  WHERE ((entity.type)::text = 'o'::text);


--
-- Name: planter_registrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planter_registrations (
    id integer NOT NULL,
    planter_id integer,
    device_id integer,
    first_name character varying,
    last_name character varying,
    organization character varying,
    phone character varying,
    email character varying,
    location_string character varying
);


--
-- Name: planter_registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planter_registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planter_registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planter_registrations_id_seq OWNED BY public.planter_registrations.id;


--
-- Name: planting_organization; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.planting_organization AS
 SELECT entity.id,
    entity.type,
    entity.name,
    entity.first_name,
    entity.last_name,
    entity.email,
    entity.phone,
    entity.website
   FROM public.entity
  WHERE ((entity.type)::text = 'o'::text);


--
-- Name: region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.region_id_seq OWNED BY public.region.id;


--
-- Name: region_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region_type (
    id integer NOT NULL,
    type character varying
);


--
-- Name: region_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.region_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: region_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.region_type_id_seq OWNED BY public.region_type.id;


--
-- Name: region_zoom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region_zoom (
    id integer NOT NULL,
    region_id integer,
    zoom_level integer,
    priority integer
);


--
-- Name: region_zoom_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.region_zoom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: region_zoom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.region_zoom_id_seq OWNED BY public.region_zoom.id;


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id integer DEFAULT nextval('public.settings_id_seq'::regclass) NOT NULL,
    next_update integer DEFAULT 30,
    min_gps_accuracy integer DEFAULT 30
);


--
-- Name: token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token (
    id integer NOT NULL,
    tree_id integer,
    entity_id integer,
    uuid character varying DEFAULT public.uuid_generate_v4()
);


--
-- Name: token_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.token_id_seq OWNED BY public.token.id;


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction (
    id integer NOT NULL,
    token_id integer,
    sender_entity_id integer,
    receiver_entity_id integer,
    processed_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_id_seq OWNED BY public.transaction.id;


--
-- Name: transfer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transfer (
    id integer NOT NULL,
    executing_entity_id integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: transfer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transfer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transfer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transfer_id_seq OWNED BY public.transfer.id;


--
-- Name: tree_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tree_attributes (
    id integer NOT NULL,
    tree_id integer,
    key character varying,
    value character varying
);


--
-- Name: tree_attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tree_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tree_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tree_attributes_id_seq OWNED BY public.tree_attributes.id;


--
-- Name: tree_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tree_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tree_region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tree_region_id_seq OWNED BY public.tree_region.id;


--
-- Name: tree_species_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tree_species_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tree_species; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tree_species (
    id integer DEFAULT nextval('public.tree_species_id_seq'::regclass) NOT NULL,
    name character varying(45) NOT NULL,
    "desc" text NOT NULL,
    active integer NOT NULL,
    value_factor integer
);


--
-- Name: trees_active; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.trees_active AS
 SELECT trees.id,
    trees.time_created,
    trees.time_updated,
    trees.missing,
    trees.priority,
    trees.cause_of_death_id,
    trees.planter_id AS user_id,
    trees.primary_location_id,
    trees.settings_id,
    trees.override_settings_id,
    trees.dead,
    trees.photo_id,
    trees.image_url,
    trees.certificate_id,
    trees.estimated_geometric_location,
    trees.lat,
    trees.lon,
    trees.gps_accuracy,
    trees.active,
    trees.planter_photo_url,
    trees.planter_identifier,
    trees.device_id,
    trees.sequence,
    trees.note,
    trees.verified,
    trees.uuid,
    trees.approved,
    trees.status,
    trees.cluster_regions_assigned
   FROM public.trees
  WHERE (trees.active = true)
  WITH NO DATA;


--
-- Name: trees_approved; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.trees_approved AS
 SELECT trees.id,
    trees.time_created,
    trees.time_updated,
    trees.missing,
    trees.priority,
    trees.cause_of_death_id,
    trees.planter_id AS user_id,
    trees.primary_location_id,
    trees.settings_id,
    trees.override_settings_id,
    trees.dead,
    trees.photo_id,
    trees.image_url,
    trees.certificate_id,
    trees.estimated_geometric_location,
    trees.lat,
    trees.lon,
    trees.gps_accuracy,
    trees.active,
    trees.planter_photo_url,
    trees.planter_identifier,
    trees.device_id,
    trees.sequence,
    trees.note,
    trees.verified,
    trees.uuid,
    trees.approved,
    trees.status,
    trees.cluster_regions_assigned
   FROM public.trees
  WHERE (trees.active = true)
  WITH NO DATA;


--
-- Name: continents id; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY import.continents ALTER COLUMN id SET DEFAULT nextval('import.continents_id_seq'::regclass);


--
-- Name: greenstand_countries gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY import.greenstand_countries ALTER COLUMN gid SET DEFAULT nextval('import.greenstand_countries_gid_seq'::regclass);


--
-- Name: tanzania_regions id; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY import.tanzania_regions ALTER COLUMN id SET DEFAULT nextval('import.tanzania_regions_id_seq'::regclass);


--
-- Name: world_continents_simplified id; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY import.world_continents_simplified ALTER COLUMN id SET DEFAULT nextval('import.world_continents_simplified_id_seq'::regclass);


--
-- Name: zoom_level_2 gid; Type: DEFAULT; Schema: import; Owner: -
--

ALTER TABLE ONLY import.zoom_level_2 ALTER COLUMN gid SET DEFAULT nextval('import.zoom_level_2_gid_seq'::regclass);


--
-- Name: api_key id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_key ALTER COLUMN id SET DEFAULT nextval('public.api_key_id_seq'::regclass);


--
-- Name: certificates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates ALTER COLUMN id SET DEFAULT nextval('public.certificates_id_seq'::regclass);


--
-- Name: clusters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clusters ALTER COLUMN id SET DEFAULT nextval('public.clusters_id_seq'::regclass);


--
-- Name: contract id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract ALTER COLUMN id SET DEFAULT nextval('public.contract_id_seq'::regclass);


--
-- Name: devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices ALTER COLUMN id SET DEFAULT nextval('public.devices_id_seq'::regclass);


--
-- Name: donors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donors ALTER COLUMN id SET DEFAULT nextval('public.donors_id_seq'::regclass);


--
-- Name: entity id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity ALTER COLUMN id SET DEFAULT nextval('public.entity_id_seq'::regclass);


--
-- Name: entity_manager id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_manager ALTER COLUMN id SET DEFAULT nextval('public.entity_manager_id_seq'::regclass);


--
-- Name: entity_role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_role ALTER COLUMN id SET DEFAULT nextval('public.entity_role_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: payment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment ALTER COLUMN id SET DEFAULT nextval('public.payment_id_seq'::regclass);


--
-- Name: planter_registrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planter_registrations ALTER COLUMN id SET DEFAULT nextval('public.planter_registrations_id_seq'::regclass);


--
-- Name: region id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region ALTER COLUMN id SET DEFAULT nextval('public.region_id_seq'::regclass);


--
-- Name: region_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region_type ALTER COLUMN id SET DEFAULT nextval('public.region_type_id_seq'::regclass);


--
-- Name: region_zoom id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region_zoom ALTER COLUMN id SET DEFAULT nextval('public.region_zoom_id_seq'::regclass);


--
-- Name: token id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token ALTER COLUMN id SET DEFAULT nextval('public.token_id_seq'::regclass);


--
-- Name: transaction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction ALTER COLUMN id SET DEFAULT nextval('public.transaction_id_seq'::regclass);


--
-- Name: transfer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transfer ALTER COLUMN id SET DEFAULT nextval('public.transfer_id_seq'::regclass);


--
-- Name: tree_attributes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tree_attributes ALTER COLUMN id SET DEFAULT nextval('public.tree_attributes_id_seq'::regclass);


--
-- Name: tree_region id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tree_region ALTER COLUMN id SET DEFAULT nextval('public.tree_region_id_seq'::regclass);


--
-- Name: continents continents_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY import.continents
    ADD CONSTRAINT continents_pkey PRIMARY KEY (id);


--
-- Name: contintents_layer_override contintents_layer_override_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY import.contintents_layer_override
    ADD CONSTRAINT contintents_layer_override_pkey PRIMARY KEY (id);


--
-- Name: greenstand_countries greenstand_countries_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY import.greenstand_countries
    ADD CONSTRAINT greenstand_countries_pkey PRIMARY KEY (gid);


--
-- Name: tanzania_regions tanzania_regions_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY import.tanzania_regions
    ADD CONSTRAINT tanzania_regions_pkey PRIMARY KEY (id);


--
-- Name: world_continents_simplified world_continents_simplified_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY import.world_continents_simplified
    ADD CONSTRAINT world_continents_simplified_pkey PRIMARY KEY (id);


--
-- Name: zoom_level_2 zoom_level_2_pkey; Type: CONSTRAINT; Schema: import; Owner: -
--

ALTER TABLE ONLY import.zoom_level_2
    ADD CONSTRAINT zoom_level_2_pkey PRIMARY KEY (gid);


--
-- Name: api_key api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_key
    ADD CONSTRAINT api_key_pkey PRIMARY KEY (id);


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: clusters clusters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clusters
    ADD CONSTRAINT clusters_pkey PRIMARY KEY (id);


--
-- Name: contract contract_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract
    ADD CONSTRAINT contract_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: donors donors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donors
    ADD CONSTRAINT donors_pkey PRIMARY KEY (id);


--
-- Name: entity_manager entity_manager_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_manager
    ADD CONSTRAINT entity_manager_pkey PRIMARY KEY (id);


--
-- Name: entity entity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity
    ADD CONSTRAINT entity_pkey PRIMARY KEY (id);


--
-- Name: entity_role entity_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_role
    ADD CONSTRAINT entity_role_pkey PRIMARY KEY (id);


--
-- Name: locations locations_id_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_id_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: notes notes_id_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_id_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: pending_update pending_update_id_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_update
    ADD CONSTRAINT pending_update_id_pkey PRIMARY KEY (id);


--
-- Name: photos photos_id_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_id_pkey PRIMARY KEY (id);


--
-- Name: planter_registrations planter_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planter_registrations
    ADD CONSTRAINT planter_registrations_pkey PRIMARY KEY (id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: region_type region_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region_type
    ADD CONSTRAINT region_type_pkey PRIMARY KEY (id);


--
-- Name: region_zoom region_zoom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region_zoom
    ADD CONSTRAINT region_zoom_pkey PRIMARY KEY (id);


--
-- Name: settings settings_id_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_id_pkey PRIMARY KEY (id);


--
-- Name: token token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_pkey PRIMARY KEY (id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: transfer transfer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_pkey PRIMARY KEY (id);


--
-- Name: tree_attributes tree_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tree_attributes
    ADD CONSTRAINT tree_attributes_pkey PRIMARY KEY (id);


--
-- Name: tree_region tree_region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tree_region
    ADD CONSTRAINT tree_region_pkey PRIMARY KEY (id);


--
-- Name: tree_species tree_species_id_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tree_species
    ADD CONSTRAINT tree_species_id_pkey PRIMARY KEY (id);


--
-- Name: trees trees_id_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_id_pkey PRIMARY KEY (id);


--
-- Name: planter users_id_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planter
    ADD CONSTRAINT users_id_pkey PRIMARY KEY (id);


--
-- Name: active_tree_region_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX active_tree_region_index ON public.active_tree_region USING btree (id);


--
-- Name: active_tree_region_region_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX active_tree_region_region_id_idx ON public.active_tree_region USING btree (region_id);


--
-- Name: active_tree_region_zoom_level_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX active_tree_region_zoom_level_idx ON public.active_tree_region USING btree (zoom_level);


--
-- Name: certificate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX certificate_id_idx ON public.trees USING btree (certificate_id);


--
-- Name: certificates_donors_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX certificates_donors_id_idx ON public.certificates USING btree (donor_id);


--
-- Name: certificates_token_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX certificates_token_idx ON public.certificates USING btree (token);


--
-- Name: donors_organization_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX donors_organization_id_idx ON public.donors USING btree (organization_id);


--
-- Name: entity_wallet_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX entity_wallet_idx ON public.entity USING btree (wallet);


--
-- Name: locations_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_user_id ON public.locations USING btree (planter_id);


--
-- Name: note_trees_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX note_trees_note_id ON public.note_trees USING btree (note_id);


--
-- Name: note_trees_tree_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX note_trees_tree_id ON public.note_trees USING btree (tree_id);


--
-- Name: notes_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notes_user_id ON public.notes USING btree (planter_id);


--
-- Name: payment_receiver_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_receiver_entity_id_idx ON public.payment USING btree (receiver_entity_id);


--
-- Name: payment_sender_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_sender_entity_id_idx ON public.payment USING btree (sender_entity_id);


--
-- Name: pending_update_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pending_update_location_id ON public.pending_update USING btree (location_id);


--
-- Name: pending_update_settings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pending_update_settings_id ON public.pending_update USING btree (settings_id);


--
-- Name: pending_update_tree_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pending_update_tree_id ON public.pending_update USING btree (tree_id);


--
-- Name: pending_update_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pending_update_user_id ON public.pending_update USING btree (planter_id);


--
-- Name: photo_trees_photo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX photo_trees_photo_id ON public.photo_trees USING btree (photo_id);


--
-- Name: photo_trees_tree_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX photo_trees_tree_id ON public.photo_trees USING btree (tree_id);


--
-- Name: photos_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX photos_location_id ON public.photos USING btree (location_id);


--
-- Name: photos_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX photos_user_id ON public.photos USING btree (user_id);


--
-- Name: region_geom_index_gist; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX region_geom_index_gist ON public.region USING gist (geom);


--
-- Name: region_type_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX region_type_type_idx ON public.region_type USING btree (type);


--
-- Name: region_zoom_zoom_level_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX region_zoom_zoom_level_idx ON public.region_zoom USING btree (zoom_level);


--
-- Name: token_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX token_entity_id_idx ON public.token USING btree (entity_id);


--
-- Name: token_tree_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX token_tree_id_idx ON public.token USING btree (tree_id);


--
-- Name: token_trees_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX token_trees_id_idx ON public.token USING btree (tree_id);


--
-- Name: token_uuid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX token_uuid_idx ON public.token USING btree (uuid);


--
-- Name: transaction_receiver_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_receiver_entity_id_idx ON public.transaction USING btree (receiver_entity_id);


--
-- Name: transaction_sender_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_sender_entity_id_idx ON public.transaction USING btree (sender_entity_id);


--
-- Name: tree_region_tree_id_zoom_level_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tree_region_tree_id_zoom_level_idx ON public.tree_region USING btree (tree_id, zoom_level);


--
-- Name: tree_region_zoom_level_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tree_region_zoom_level_idx ON public.tree_region USING btree (zoom_level);


--
-- Name: tree_species_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tree_species_id ON public.tree_species USING btree (id);


--
-- Name: trees_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_active_idx ON public.trees USING btree (active);


--
-- Name: trees_cause_of_death_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_cause_of_death_id ON public.trees USING btree (cause_of_death_id);


--
-- Name: trees_estimated_geometric_location_index_btree; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_estimated_geometric_location_index_btree ON public.trees USING btree (estimated_geometric_location);


--
-- Name: trees_estimated_geometric_location_index_gist; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_estimated_geometric_location_index_gist ON public.trees USING gist (estimated_geometric_location);


--
-- Name: trees_expr_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_expr_idx ON public.trees USING btree ((1)) WHERE active;


--
-- Name: trees_override_settings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_override_settings_id ON public.trees USING btree (override_settings_id);


--
-- Name: trees_payment_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_payment_id_idx ON public.trees USING btree (payment_id);


--
-- Name: trees_planter_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_planter_id_idx ON public.trees USING btree (planter_id);


--
-- Name: trees_planting_organization_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_planting_organization_id_idx ON public.trees USING btree (planting_organization_id);


--
-- Name: trees_primary_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_primary_location_id ON public.trees USING btree (primary_location_id);


--
-- Name: trees_settings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_settings_id ON public.trees USING btree (settings_id);


--
-- Name: trees_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trees_user_id ON public.trees USING btree (planter_id);


--
-- Name: users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email ON public.planter USING btree (email);


--
-- Name: devices set_updated_at_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_timestamp BEFORE UPDATE ON public.devices FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_updated_at();


--
-- Name: token token_transaction_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER token_transaction_trigger AFTER UPDATE ON public.token FOR EACH ROW EXECUTE PROCEDURE public.token_transaction_insert();


--
-- Name: entity_manager entity_manager_child_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_manager
    ADD CONSTRAINT entity_manager_child_entity_id_fk FOREIGN KEY (child_entity_id) REFERENCES public.entity(id);


--
-- Name: entity_manager entity_manager_parent_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_manager
    ADD CONSTRAINT entity_manager_parent_entity_id_fk FOREIGN KEY (parent_entity_id) REFERENCES public.entity(id);


--
-- Name: entity_role entity_role_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_role
    ADD CONSTRAINT entity_role_entity_id_fk FOREIGN KEY (entity_id) REFERENCES public.entity(id);


--
-- Name: locations locations_planter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_planter_id_fk FOREIGN KEY (planter_id) REFERENCES public.planter(id);


--
-- Name: note_trees note_trees_note_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_trees
    ADD CONSTRAINT note_trees_note_id_fkey FOREIGN KEY (note_id) REFERENCES public.notes(id);


--
-- Name: note_trees note_trees_tree_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_trees
    ADD CONSTRAINT note_trees_tree_id_fkey FOREIGN KEY (tree_id) REFERENCES public.trees(id);


--
-- Name: notes notes_planter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_planter_id_fk FOREIGN KEY (planter_id) REFERENCES public.planter(id);


--
-- Name: payment payment_entity_receiver_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_entity_receiver_id_fk FOREIGN KEY (receiver_entity_id) REFERENCES public.entity(id);


--
-- Name: payment payment_entity_sender_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_entity_sender_id_fk FOREIGN KEY (sender_entity_id) REFERENCES public.entity(id);


--
-- Name: pending_update pending_update_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_update
    ADD CONSTRAINT pending_update_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: pending_update pending_update_planter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_update
    ADD CONSTRAINT pending_update_planter_id_fk FOREIGN KEY (planter_id) REFERENCES public.planter(id);


--
-- Name: pending_update pending_update_settings_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_update
    ADD CONSTRAINT pending_update_settings_id_fkey FOREIGN KEY (settings_id) REFERENCES public.settings(id);


--
-- Name: pending_update pending_update_tree_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_update
    ADD CONSTRAINT pending_update_tree_id_fkey FOREIGN KEY (tree_id) REFERENCES public.trees(id);


--
-- Name: photo_trees photo_trees_photo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photo_trees
    ADD CONSTRAINT photo_trees_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES public.photos(id);


--
-- Name: photo_trees photo_trees_tree_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photo_trees
    ADD CONSTRAINT photo_trees_tree_id_fkey FOREIGN KEY (tree_id) REFERENCES public.trees(id);


--
-- Name: photos photos_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: photos photos_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.planter(id);


--
-- Name: planter planter_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planter
    ADD CONSTRAINT planter_organization_id_fk FOREIGN KEY (organization_id) REFERENCES public.entity(id);


--
-- Name: planter planter_person_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planter
    ADD CONSTRAINT planter_person_id_fk FOREIGN KEY (person_id) REFERENCES public.entity(id);


--
-- Name: token token_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_entity_id_fk FOREIGN KEY (entity_id) REFERENCES public.entity(id);


--
-- Name: token token_tree_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_tree_id_fk FOREIGN KEY (tree_id) REFERENCES public.trees(id);


--
-- Name: transaction transaction_entity_receiver_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_entity_receiver_id_fk FOREIGN KEY (receiver_entity_id) REFERENCES public.entity(id);


--
-- Name: transaction transaction_entity_sender_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_entity_sender_id_fk FOREIGN KEY (sender_entity_id) REFERENCES public.entity(id);


--
-- Name: transaction transaction_token_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_token_id_fk FOREIGN KEY (token_id) REFERENCES public.token(id);


--
-- Name: trees trees_cause_of_death_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_cause_of_death_id_fkey FOREIGN KEY (cause_of_death_id) REFERENCES public.notes(id);


--
-- Name: trees trees_override_settings_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_override_settings_id_fkey FOREIGN KEY (override_settings_id) REFERENCES public.settings(id);


--
-- Name: trees trees_payment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_payment_id_fk FOREIGN KEY (payment_id) REFERENCES public.payment(id);


--
-- Name: trees trees_planter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_planter_id_fk FOREIGN KEY (planter_id) REFERENCES public.planter(id);


--
-- Name: trees trees_planting_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_planting_organization_id_fk FOREIGN KEY (planting_organization_id) REFERENCES public.entity(id);


--
-- Name: trees trees_primary_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_primary_location_id_fkey FOREIGN KEY (primary_location_id) REFERENCES public.locations(id);


--
-- Name: trees trees_settings_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_settings_id_fkey FOREIGN KEY (settings_id) REFERENCES public.settings(id);


--
-- Name: TABLE region; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.region FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.region TO treetracker;
GRANT ALL ON TABLE public.region TO treetracker_admin;


--
-- Name: TABLE tree_region; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.tree_region FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.tree_region TO treetracker;
GRANT ALL ON TABLE public.tree_region TO treetracker_admin;


--
-- Name: SEQUENCE trees_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.trees_id_seq TO treetracker;


--
-- Name: TABLE trees; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.trees FROM treetracker;
GRANT ALL ON TABLE public.trees TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.trees TO treetracker;
GRANT SELECT,UPDATE ON TABLE public.trees TO treetracker_manager;
GRANT SELECT ON TABLE public.trees TO token_issuer;


--
-- Name: TABLE active_tree_region; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.active_tree_region TO treetracker_admin;


--
-- Name: TABLE api_key; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.api_key TO treetracker_admin;
GRANT SELECT,INSERT ON TABLE public.api_key TO token_trading_admin;


--
-- Name: COLUMN api_key.tree_token_api_access; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(tree_token_api_access) ON TABLE public.api_key TO token_trading_admin;


--
-- Name: SEQUENCE api_key_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE public.api_key_id_seq TO token_trading_admin;


--
-- Name: TABLE certificates; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.certificates FROM treetracker;
GRANT ALL ON TABLE public.certificates TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.certificates TO treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.certificates TO treetracker_manager;
GRANT SELECT ON TABLE public.certificates TO token_issuer;


--
-- Name: TABLE clusters; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.clusters TO treetracker_admin;


--
-- Name: TABLE contract; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.contract TO treetracker_admin;


--
-- Name: TABLE devices; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.devices FROM treetracker;
GRANT ALL ON TABLE public.devices TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.devices TO treetracker;
GRANT SELECT ON TABLE public.devices TO treetracker_manager;


--
-- Name: TABLE donors; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.donors FROM treetracker;
GRANT ALL ON TABLE public.donors TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.donors TO treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.donors TO treetracker_manager;


--
-- Name: TABLE entity; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.entity FROM treetracker;
GRANT ALL ON TABLE public.entity TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.entity TO treetracker;
GRANT ALL ON TABLE public.entity TO treetracker_manager;
GRANT SELECT,INSERT ON TABLE public.entity TO token_trading_admin;
GRANT SELECT,INSERT ON TABLE public.entity TO token_issuer;


--
-- Name: COLUMN entity.password; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(password) ON TABLE public.entity TO token_trading_admin;


--
-- Name: COLUMN entity.salt; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(salt) ON TABLE public.entity TO token_trading_admin;


--
-- Name: SEQUENCE entity_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE public.entity_id_seq TO token_trading_admin;


--
-- Name: TABLE entity_manager; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.entity_manager TO treetracker_admin;
GRANT SELECT,INSERT ON TABLE public.entity_manager TO treetracker;


--
-- Name: SEQUENCE entity_manager_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE public.entity_manager_id_seq TO treetracker;


--
-- Name: TABLE entity_role; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.entity_role TO treetracker_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.entity_role TO token_trading_admin;


--
-- Name: SEQUENCE entity_role_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE public.entity_role_id_seq TO token_trading_admin;


--
-- Name: SEQUENCE locations_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.locations_id_seq TO treetracker;


--
-- Name: TABLE locations; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.locations FROM treetracker;
GRANT ALL ON TABLE public.locations TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.locations TO treetracker;
GRANT SELECT ON TABLE public.locations TO treetracker_manager;


--
-- Name: TABLE long_running; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.long_running FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.long_running TO treetracker;
GRANT ALL ON TABLE public.long_running TO treetracker_admin;


--
-- Name: TABLE migrations; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.migrations FROM treetracker;
GRANT ALL ON TABLE public.migrations TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.migrations TO treetracker;
GRANT SELECT ON TABLE public.migrations TO treetracker_manager;


--
-- Name: TABLE note_trees; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.note_trees FROM treetracker;
GRANT ALL ON TABLE public.note_trees TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.note_trees TO treetracker;
GRANT SELECT ON TABLE public.note_trees TO treetracker_manager;


--
-- Name: SEQUENCE notes_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.notes_id_seq TO treetracker;


--
-- Name: TABLE notes; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.notes FROM treetracker;
GRANT ALL ON TABLE public.notes TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.notes TO treetracker;
GRANT SELECT ON TABLE public.notes TO treetracker_manager;


--
-- Name: TABLE organizations; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.organizations FROM treetracker;
GRANT ALL ON TABLE public.organizations TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.organizations TO treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.organizations TO treetracker_manager;


--
-- Name: TABLE payment; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.payment FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.payment TO treetracker;
GRANT ALL ON TABLE public.payment TO treetracker_admin;
GRANT SELECT ON TABLE public.payment TO accountant;


--
-- Name: TABLE payment_list; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.payment_list TO treetracker;
GRANT ALL ON TABLE public.payment_list TO treetracker_admin;


--
-- Name: SEQUENCE pending_update_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.pending_update_id_seq TO treetracker;


--
-- Name: TABLE pending_update; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.pending_update FROM treetracker;
GRANT ALL ON TABLE public.pending_update TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.pending_update TO treetracker;
GRANT SELECT ON TABLE public.pending_update TO treetracker_manager;


--
-- Name: TABLE person; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.person FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.person TO treetracker;
GRANT ALL ON TABLE public.person TO treetracker_admin;


--
-- Name: TABLE photo_trees; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.photo_trees FROM treetracker;
GRANT ALL ON TABLE public.photo_trees TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.photo_trees TO treetracker;
GRANT SELECT ON TABLE public.photo_trees TO treetracker_manager;


--
-- Name: SEQUENCE photos_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.photos_id_seq TO treetracker;


--
-- Name: TABLE photos; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.photos FROM treetracker;
GRANT ALL ON TABLE public.photos TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.photos TO treetracker;
GRANT SELECT ON TABLE public.photos TO treetracker_manager;


--
-- Name: SEQUENCE users_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.users_id_seq TO treetracker;


--
-- Name: TABLE planter; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.planter FROM treetracker;
GRANT ALL ON TABLE public.planter TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.planter TO treetracker;
GRANT ALL ON TABLE public.planter TO treetracker_manager;


--
-- Name: TABLE planter_organization; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.planter_organization FROM treetracker;
GRANT ALL ON TABLE public.planter_organization TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.planter_organization TO treetracker;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.planter_organization TO treetracker_manager;


--
-- Name: TABLE planter_registrations; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.planter_registrations FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.planter_registrations TO treetracker;
GRANT ALL ON TABLE public.planter_registrations TO treetracker_admin;


--
-- Name: TABLE planting_organization; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.planting_organization FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.planting_organization TO treetracker;
GRANT ALL ON TABLE public.planting_organization TO treetracker_admin;


--
-- Name: TABLE region_type; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.region_type FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.region_type TO treetracker;
GRANT ALL ON TABLE public.region_type TO treetracker_admin;


--
-- Name: TABLE region_zoom; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.region_zoom FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.region_zoom TO treetracker;
GRANT ALL ON TABLE public.region_zoom TO treetracker_admin;


--
-- Name: SEQUENCE settings_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.settings_id_seq TO treetracker;


--
-- Name: TABLE settings; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.settings FROM treetracker;
GRANT ALL ON TABLE public.settings TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.settings TO treetracker;
GRANT SELECT ON TABLE public.settings TO treetracker_manager;


--
-- Name: TABLE token; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.token FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.token TO treetracker;
GRANT TRIGGER ON TABLE public.token TO doadmin;
GRANT ALL ON TABLE public.token TO treetracker_admin;
GRANT SELECT,INSERT ON TABLE public.token TO token_issuer;


--
-- Name: SEQUENCE token_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.token_id_seq TO token_issuer;


--
-- Name: SEQUENCE tokens_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.tokens_id_seq TO treetracker;


--
-- Name: TABLE transaction; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.transaction FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.transaction TO treetracker;
GRANT ALL ON TABLE public.transaction TO treetracker_admin;
GRANT SELECT ON TABLE public.transaction TO accountant;


--
-- Name: TABLE transfer; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.transfer TO treetracker_admin;
GRANT SELECT,INSERT ON TABLE public.transfer TO treetracker;


--
-- Name: SEQUENCE transfer_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE public.transfer_id_seq TO treetracker;


--
-- Name: TABLE tree_attributes; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.tree_attributes FROM treetracker;
GRANT ALL ON TABLE public.tree_attributes TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.tree_attributes TO treetracker;
GRANT SELECT ON TABLE public.tree_attributes TO treetracker_manager;


--
-- Name: SEQUENCE tree_species_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.tree_species_id_seq TO treetracker;


--
-- Name: TABLE tree_species; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.tree_species FROM treetracker;
GRANT ALL ON TABLE public.tree_species TO treetracker_admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.tree_species TO treetracker;
GRANT SELECT,INSERT ON TABLE public.tree_species TO treetracker_manager;


--
-- Name: TABLE trees_active; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.trees_active FROM treetracker;
GRANT SELECT,INSERT,UPDATE ON TABLE public.trees_active TO treetracker;
GRANT ALL ON TABLE public.trees_active TO treetracker_admin;


--
-- Name: TABLE trees_approved; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.trees_approved TO treetracker;
GRANT ALL ON TABLE public.trees_approved TO treetracker_admin;


--
-- PostgreSQL database dump complete
--

