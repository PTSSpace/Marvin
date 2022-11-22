--
-- PostgreSQL database dump
--

-- Dumped from database version 12.12 (Ubuntu 12.12-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.12 (Ubuntu 12.12-0ubuntu0.20.04.1)

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
-- Name: marvin; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA marvin;


ALTER SCHEMA marvin OWNER TO postgres;

--
-- Name: SCHEMA marvin; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA marvin IS 'standard public schema';


--
-- Name: change_trigger(); Type: FUNCTION; Schema: marvin; Owner: invadm
--

CREATE FUNCTION marvin.change_trigger() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$ 
        BEGIN
 
                IF      TG_OP = 'INSERT'
 
                THEN
 
                        INSERT INTO marvin.t_history (tabname, schemaname, operation, new_val)
 
                                VALUES (TG_RELNAME, TG_TABLE_SCHEMA, TG_OP, row_to_json(NEW));
 
                        RETURN NEW;
 
                ELSIF   TG_OP = 'UPDATE'
 
                THEN
 
                        INSERT INTO marvin.t_history (tabname, schemaname, operation, new_val, old_val)
 
                                VALUES (TG_RELNAME, TG_TABLE_SCHEMA, TG_OP,
 
                                        row_to_json(NEW), row_to_json(OLD));
 
                        RETURN NEW;
 
                ELSIF   TG_OP = 'DELETE'
 
                THEN
 
                        INSERT INTO marvin.t_history (tabname, schemaname, operation, old_val)
 
                                VALUES (TG_RELNAME, TG_TABLE_SCHEMA, TG_OP, row_to_json(OLD));
 
                        RETURN OLD;
 
                END IF;
 
        END;
 
$$;


ALTER FUNCTION marvin.change_trigger() OWNER TO invadm;

--
-- Name: component_location_update_insert_history(); Type: FUNCTION; Schema: marvin; Owner: invadm
--

CREATE FUNCTION marvin.component_location_update_insert_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$    begin
       
       
         insert into location_history (c_id,created_at,user_name,ln_id)
         values (new.c_id, now(), new.user_name, new.ln_id);
       
       return new;
    end;
$$;


ALTER FUNCTION marvin.component_location_update_insert_history() OWNER TO invadm;

--
-- Name: product_location_update_insert_history(); Type: FUNCTION; Schema: marvin; Owner: invadm
--

CREATE FUNCTION marvin.product_location_update_insert_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$    
   begin
       --if new.ln_id != old.ln_id
       --then 
         insert into location_history (p_id,created_at,user_name,ln_id)
         values (new.p_id, now(), new.user_name, new.ln_id);
       --end if;
       return new;
    end;
$$;


ALTER FUNCTION marvin.product_location_update_insert_history() OWNER TO invadm;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: attachments; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.attachments (
    attachment_id macaddr DEFAULT (concat('01', "substring"(md5((random())::text), 3, 10)))::macaddr NOT NULL,
    part_id macaddr,
    c_id macaddr,
    cp_id bigint,
    p_id macaddr,
    supplier_id integer,
    t_id integer,
    user_name character varying(64),
    created_at timestamp with time zone DEFAULT now(),
    filename character varying(256),
    filetype character varying(32),
    design_id macaddr,
    description character varying(512)
);


ALTER TABLE marvin.attachments OWNER TO invadm;

--
-- Name: TABLE attachments; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.attachments IS 'data about attachments on Filesystem';


--
-- Name: COLUMN attachments.description; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.attachments.description IS 'description of attachment';


--
-- Name: c_nn_p_state_name; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.c_nn_p_state_name (
    cpsn_id integer NOT NULL,
    name character varying(64),
    user_name character varying(128),
    description text
);


ALTER TABLE marvin.c_nn_p_state_name OWNER TO invadm;

--
-- Name: TABLE c_nn_p_state_name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.c_nn_p_state_name IS 'Name of c_nn_p_state ids';


--
-- Name: COLUMN c_nn_p_state_name.cpsn_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.c_nn_p_state_name.cpsn_id IS 'id of c_nn_p state';


--
-- Name: COLUMN c_nn_p_state_name.name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.c_nn_p_state_name.name IS 'name of components_nn_products state, ie name of integration state (eg reserved, integrated)';


--
-- Name: c_nn_p_state_name_cpsn_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.c_nn_p_state_name_cpsn_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.c_nn_p_state_name_cpsn_id_seq OWNER TO invadm;

--
-- Name: c_nn_p_state_name_cpsn_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.c_nn_p_state_name_cpsn_id_seq OWNED BY marvin.c_nn_p_state_name.cpsn_id;


--
-- Name: component; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.component (
    c_id macaddr DEFAULT (concat('01', "substring"(md5((random())::text), 3, 10)))::macaddr NOT NULL,
    batch_no character varying(128),
    notes text,
    qty integer,
    part_no character varying(64),
    project_id integer DEFAULT 1,
    user_name character varying(64) DEFAULT 'pts'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    ln_id integer,
    sn_id integer,
    supplier_id integer,
    order_no character varying(128),
    origin_country character varying(128),
    revision_no character varying(128),
    hermetically_sealed boolean,
    serial_no character varying(256),
    part_id macaddr,
    type_id integer,
    short_name character varying(128),
    order_date timestamp with time zone,
    date_code character varying(128),
    delivery_date timestamp with time zone,
    hr_component_id integer NOT NULL,
    hw_use_id integer,
    est_delivery_date timestamp with time zone,
    coc_id character varying(128)
);


ALTER TABLE marvin.component OWNER TO invadm;

--
-- Name: TABLE component; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.component IS 'electrical and other components that are subunits of a PCB';


--
-- Name: COLUMN component.c_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.c_id IS 'UID in format of macaddress with 01 as prefix';


--
-- Name: COLUMN component.batch_no; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.batch_no IS 'batch number ';


--
-- Name: COLUMN component.qty; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.qty IS 'Number of components in that batch. Will often be 1 (especially where batch is a serial no)';


--
-- Name: COLUMN component.part_no; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.part_no IS 'distributor part Number from Digikey or mouser';


--
-- Name: COLUMN component.project_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.project_id IS 'ID of project the component/s are part of';


--
-- Name: COLUMN component.user_name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.user_name IS 'Creator of Component (eg Paul)';


--
-- Name: COLUMN component.created_at; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.created_at IS 'Time of creation';


--
-- Name: COLUMN component.sn_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.sn_id IS 'state name table primary ';


--
-- Name: COLUMN component.supplier_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.supplier_id IS 'id for distributor';


--
-- Name: COLUMN component.order_no; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.order_no IS 'Order Number';


--
-- Name: COLUMN component.origin_country; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.origin_country IS 'country of origin/manufacturing country';


--
-- Name: COLUMN component.revision_no; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.revision_no IS 'Revision Number';


--
-- Name: COLUMN component.hermetically_sealed; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.hermetically_sealed IS 'obvious';


--
-- Name: COLUMN component.serial_no; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.serial_no IS 'serial number of component';


--
-- Name: COLUMN component.part_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.part_id IS 'foreign key to parts table';


--
-- Name: COLUMN component.type_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.type_id IS 'type of component (electrical component / pts asset / measuring equipment)';


--
-- Name: COLUMN component.short_name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.short_name IS 'short name for reference';


--
-- Name: COLUMN component.date_code; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.component.date_code IS 'date code';


--
-- Name: component_hr_component_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.component_hr_component_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.component_hr_component_id_seq OWNER TO invadm;

--
-- Name: component_hr_component_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.component_hr_component_id_seq OWNED BY marvin.component.hr_component_id;


--
-- Name: component_type; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.component_type (
    type_id integer NOT NULL,
    name character varying(64)
);


ALTER TABLE marvin.component_type OWNER TO invadm;

--
-- Name: component_type_type_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.component_type_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.component_type_type_id_seq OWNER TO invadm;

--
-- Name: component_type_type_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.component_type_type_id_seq OWNED BY marvin.component_type.type_id;


--
-- Name: components_nn_products; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.components_nn_products (
    c_id macaddr,
    p_id macaddr,
    qty integer NOT NULL,
    cp_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    cpsn_id integer,
    user_name character varying(64)
);


ALTER TABLE marvin.components_nn_products OWNER TO invadm;

--
-- Name: TABLE components_nn_products; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.components_nn_products IS 'table setting relationships between products and components (product x contains components z, y and w)';


--
-- Name: COLUMN components_nn_products.cp_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.components_nn_products.cp_id IS 'Primary key, not relevant for user';


--
-- Name: COLUMN components_nn_products.created_at; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.components_nn_products.created_at IS 'timestamp of creation of link (first time the component has been associated to product)';


--
-- Name: components_nn_products_cp_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.components_nn_products_cp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.components_nn_products_cp_id_seq OWNER TO invadm;

--
-- Name: components_nn_products_cp_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.components_nn_products_cp_id_seq OWNED BY marvin.components_nn_products.cp_id;


--
-- Name: design; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.design (
    design_id macaddr DEFAULT (concat('01', "substring"(md5((random())::text), 3, 10)))::macaddr NOT NULL,
    name character varying(128),
    user_name character varying(64),
    parent_design_id macaddr,
    link_design_source character varying(512),
    project_id integer
);


ALTER TABLE marvin.design OWNER TO invadm;

--
-- Name: TABLE design; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.design IS 'PCB or Mechanical design of a product';


--
-- Name: COLUMN design.design_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.design.design_id IS 'did of design';


--
-- Name: COLUMN design.name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.design.name IS 'name of design';


--
-- Name: COLUMN design.link_design_source; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.design.link_design_source IS 'Link to design definition';


--
-- Name: COLUMN design.project_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.design.project_id IS 'project reference';


--
-- Name: suppliers; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.suppliers (
    supplier_id integer NOT NULL,
    supplier_name character varying(128),
    address character varying(512),
    parent_supplier_id integer,
    notes text
);


ALTER TABLE marvin.suppliers OWNER TO invadm;

--
-- Name: TABLE suppliers; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.suppliers IS 'List of distributors and manufacturers as well as other suppliers';


--
-- Name: COLUMN suppliers.supplier_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.suppliers.supplier_id IS 'Primary key, not important for user';


--
-- Name: COLUMN suppliers.supplier_name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.suppliers.supplier_name IS 'Common Name (XYZ GmbH)';


--
-- Name: COLUMN suppliers.parent_supplier_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.suppliers.parent_supplier_id IS 'In case distributer gets bought by another one and they merge';


--
-- Name: distributor_d_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.distributor_d_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.distributor_d_id_seq OWNER TO invadm;

--
-- Name: distributor_d_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.distributor_d_id_seq OWNED BY marvin.suppliers.supplier_id;


--
-- Name: hardware_use_tye; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.hardware_use_tye (
    hw_use_id integer NOT NULL,
    hw_use_name character varying,
    hw_use_description text
);


ALTER TABLE marvin.hardware_use_tye OWNER TO invadm;

--
-- Name: hardware_use_tye_hw_use_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.hardware_use_tye_hw_use_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.hardware_use_tye_hw_use_id_seq OWNER TO invadm;

--
-- Name: hardware_use_tye_hw_use_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.hardware_use_tye_hw_use_id_seq OWNED BY marvin.hardware_use_tye.hw_use_id;


--
-- Name: life_cycle; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.life_cycle (
    id integer NOT NULL,
    status character varying(255)
);


ALTER TABLE marvin.life_cycle OWNER TO invadm;

--
-- Name: life_cycle_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.life_cycle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.life_cycle_id_seq OWNER TO invadm;

--
-- Name: life_cycle_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.life_cycle_id_seq OWNED BY marvin.life_cycle.id;


--
-- Name: ln_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.ln_id_seq
    START WITH 4
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.ln_id_seq OWNER TO invadm;

--
-- Name: location_history; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.location_history (
    lh_id integer NOT NULL,
    p_id macaddr,
    c_id macaddr,
    created_at timestamp with time zone,
    user_name character varying(32),
    ln_id integer
);


ALTER TABLE marvin.location_history OWNER TO invadm;

--
-- Name: TABLE location_history; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.location_history IS 'history of location of components/products';


--
-- Name: COLUMN location_history.lh_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.location_history.lh_id IS 'Primary key, not important for user';


--
-- Name: COLUMN location_history.created_at; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.location_history.created_at IS 'time when created';


--
-- Name: COLUMN location_history.ln_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.location_history.ln_id IS 'ID of location';


--
-- Name: location_history_lh_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.location_history_lh_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.location_history_lh_id_seq OWNER TO invadm;

--
-- Name: location_history_lh_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.location_history_lh_id_seq OWNED BY marvin.location_history.lh_id;


--
-- Name: location_name; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.location_name (
    ln_id integer DEFAULT nextval('marvin.ln_id_seq'::regclass) NOT NULL,
    name character varying(64) NOT NULL,
    address text,
    "user" character varying(32),
    ln_parent_id integer,
    ln_type character varying(128),
    ln_description character varying
);


ALTER TABLE marvin.location_name OWNER TO invadm;

--
-- Name: TABLE location_name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.location_name IS 'maps location id for name and address (also used for dropdown menus) ';


--
-- Name: COLUMN location_name.ln_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.location_name.ln_id IS 'primary key';


--
-- Name: COLUMN location_name.name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.location_name.name IS 'Name of location';


--
-- Name: COLUMN location_name.address; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.location_name.address IS 'Address of location';


--
-- Name: COLUMN location_name."user"; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.location_name."user" IS 'user who put it in the location';


--
-- Name: COLUMN location_name.ln_type; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.location_name.ln_type IS 'Type of storage container';


--
-- Name: COLUMN location_name.ln_description; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.location_name.ln_description IS 'Storage items description';


--
-- Name: parts; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.parts (
    part_id macaddr DEFAULT (concat('01', "substring"(md5((random())::text), 3, 10)))::macaddr NOT NULL,
    notes text,
    manufacturer_no character varying(128),
    user_name character varying(64) DEFAULT 'pts'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    part_name character varying(256),
    min_nominal_operating_temp_c real,
    max_nominal_operating_temp_c real,
    min_nonnominal_operating_temp_c real,
    max_nonnominal_operating_temp_c real,
    t_j_max real,
    p_d_max real,
    v_cc_max real,
    data_sheet_no character varying(512),
    tin_free boolean,
    pb_free_finish boolean,
    coc_no character varying(128),
    rohs boolean,
    reach boolean,
    data_sheet_date date,
    data_sheet_revision character varying(128),
    supplier_id integer,
    fk_parts_life_cycle integer,
    specs marvin.hstore,
    octopart_url character varying(256)
);


ALTER TABLE marvin.parts OWNER TO invadm;

--
-- Name: COLUMN parts.specs; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.parts.specs IS 'specs as found on ontopart';


--
-- Name: product_type; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.product_type (
    p_type_id integer NOT NULL,
    name character varying(128)
);


ALTER TABLE marvin.product_type OWNER TO invadm;

--
-- Name: TABLE product_type; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.product_type IS 'Contains product type definitions (ID,Name) which the product table can refer to.';


--
-- Name: COLUMN product_type.p_type_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.product_type.p_type_id IS 'ID of product type (products table refers to this)';


--
-- Name: COLUMN product_type.name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.product_type.name IS 'Name of product type';


--
-- Name: product_type_p_type_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.product_type_p_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.product_type_p_type_id_seq OWNER TO invadm;

--
-- Name: product_type_p_type_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.product_type_p_type_id_seq OWNED BY marvin.product_type.p_type_id;


--
-- Name: products; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.products (
    p_id macaddr DEFAULT (concat('01', "substring"(md5((random())::text), 3, 10)))::macaddr NOT NULL,
    parent_p_id macaddr,
    panel_no character varying(32),
    name character varying(64),
    project_id integer DEFAULT 1,
    user_name character varying(64) DEFAULT 'pts'::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    supplier_id integer,
    picture_front_type character varying(32),
    picture_back_type character varying(32),
    ln_id integer,
    sn_id integer,
    design_id macaddr,
    user_name_allocation character varying,
    p_type_id integer
);


ALTER TABLE marvin.products OWNER TO invadm;

--
-- Name: TABLE products; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.products IS 'Products containing components ';


--
-- Name: COLUMN products.p_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.p_id IS 'Universally unique ID in format of macaddress with 01 as prefix';


--
-- Name: COLUMN products.parent_p_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.parent_p_id IS 'This is for referencing to other Products to generate product trees in a sense that one product contains another';


--
-- Name: COLUMN products.panel_no; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.panel_no IS 'Number of the panel the PCB was produced in';


--
-- Name: COLUMN products.name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.name IS 'Name or serial Number of Product (eg. OBC XY) ';


--
-- Name: COLUMN products.project_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.project_id IS 'Associated Project';


--
-- Name: COLUMN products.user_name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.user_name IS 'username of creator';


--
-- Name: COLUMN products.created_at; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.created_at IS 'time of creation';


--
-- Name: COLUMN products.picture_front_type; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.picture_front_type IS 'mime type of image (jpg, pdf)';


--
-- Name: COLUMN products.picture_back_type; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.picture_back_type IS 'mime type of back picture';


--
-- Name: COLUMN products.ln_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.ln_id IS 'location name id';


--
-- Name: COLUMN products.sn_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.sn_id IS 'state name table primary ';


--
-- Name: COLUMN products.design_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.design_id IS 'ID of Design ';


--
-- Name: COLUMN products.user_name_allocation; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.user_name_allocation IS 'If this field is not null the product is oney referring th this specific user and not to a product. On the product page you can see all components a user is using';


--
-- Name: COLUMN products.p_type_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.products.p_type_id IS 'product type id - foreign key to product_type';


--
-- Name: project; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.project (
    project_id integer NOT NULL,
    name character varying(64)
);


ALTER TABLE marvin.project OWNER TO invadm;

--
-- Name: TABLE project; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.project IS 'Project id and names';


--
-- Name: project_project_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.project_project_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.project_project_id_seq OWNER TO invadm;

--
-- Name: project_project_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.project_project_id_seq OWNED BY marvin.project.project_id;


--
-- Name: state_name; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.state_name (
    sn_id integer NOT NULL,
    name character varying(128),
    description text
);


ALTER TABLE marvin.state_name OWNER TO invadm;

--
-- Name: TABLE state_name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.state_name IS 'State of component (ordered, received, flight ready, etc)';


--
-- Name: test_name; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.test_name (
    tn_id integer NOT NULL,
    name character varying(128),
    description text,
    link character varying
);


ALTER TABLE marvin.test_name OWNER TO invadm;

--
-- Name: TABLE test_name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.test_name IS 'defenition of test for components/products (also used for dropdown menus)';


--
-- Name: COLUMN test_name.tn_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.test_name.tn_id IS 'primary key';


--
-- Name: COLUMN test_name.name; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.test_name.name IS 'Name ofState (e.g. in procurement)';


--
-- Name: COLUMN test_name.description; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.test_name.description IS 'description of state (in procurement - the action of obtaining an item, ie it was decided to buy but is not in storage jet)';


--
-- Name: COLUMN test_name.link; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.test_name.link IS 'link to test Protocol';


--
-- Name: state_name_description_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.state_name_description_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.state_name_description_seq OWNER TO invadm;

--
-- Name: state_name_description_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.state_name_description_seq OWNED BY marvin.test_name.description;


--
-- Name: state_name_sn_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.state_name_sn_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.state_name_sn_id_seq OWNER TO invadm;

--
-- Name: state_name_sn_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.state_name_sn_id_seq OWNED BY marvin.state_name.sn_id;


--
-- Name: t_history; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.t_history (
    id integer NOT NULL,
    tstamp timestamp without time zone DEFAULT now(),
    schemaname text,
    tabname text,
    operation text,
    who text DEFAULT CURRENT_USER,
    new_val json,
    old_val json
);


ALTER TABLE marvin.t_history OWNER TO invadm;

--
-- Name: t_history_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.t_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.t_history_id_seq OWNER TO invadm;

--
-- Name: t_history_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.t_history_id_seq OWNED BY marvin.t_history.id;


--
-- Name: test_name_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.test_name_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.test_name_id_seq OWNER TO invadm;

--
-- Name: test_name_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.test_name_id_seq OWNED BY marvin.test_name.tn_id;


--
-- Name: test_nn_component; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.test_nn_component (
    t_nn_c_id integer NOT NULL,
    t_id integer,
    c_id macaddr,
    user_name character varying(64),
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE marvin.test_nn_component OWNER TO invadm;

--
-- Name: test_nn_component_t_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.test_nn_component_t_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.test_nn_component_t_id_seq OWNER TO invadm;

--
-- Name: test_nn_component_t_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.test_nn_component_t_id_seq OWNED BY marvin.test_nn_component.t_id;


--
-- Name: test_nn_component_t_nn_c_id_seq; Type: SEQUENCE; Schema: marvin; Owner: invadm
--

CREATE SEQUENCE marvin.test_nn_component_t_nn_c_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marvin.test_nn_component_t_nn_c_id_seq OWNER TO invadm;

--
-- Name: test_nn_component_t_nn_c_id_seq; Type: SEQUENCE OWNED BY; Schema: marvin; Owner: invadm
--

ALTER SEQUENCE marvin.test_nn_component_t_nn_c_id_seq OWNED BY marvin.test_nn_component.t_nn_c_id;


--
-- Name: tests; Type: TABLE; Schema: marvin; Owner: invadm
--

CREATE TABLE marvin.tests (
    t_id integer DEFAULT nextval('marvin.project_project_id_seq'::regclass) NOT NULL,
    p_id macaddr,
    c_id macaddr,
    tn_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_name character varying(64) DEFAULT 'pts'::character varying,
    link character varying(512),
    notes text,
    passed boolean,
    test_date timestamp with time zone,
    design_id macaddr,
    supplier_id integer,
    description character varying(256)
);


ALTER TABLE marvin.tests OWNER TO invadm;

--
-- Name: TABLE tests; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON TABLE marvin.tests IS 'Performed tests on components and products';


--
-- Name: COLUMN tests.t_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.tests.t_id IS 'primary key';


--
-- Name: COLUMN tests.p_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.tests.p_id IS 'product key';


--
-- Name: COLUMN tests.c_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.tests.c_id IS 'component key';


--
-- Name: COLUMN tests.tn_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.tests.tn_id IS 'Test name key (refers to test performed)';


--
-- Name: COLUMN tests.created_at; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.tests.created_at IS 'time when this state was applied';


--
-- Name: COLUMN tests.link; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.tests.link IS 'Link to KB ';


--
-- Name: COLUMN tests.passed; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.tests.passed IS 'true if test was passed successfully';


--
-- Name: COLUMN tests.design_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.tests.design_id IS 'ID of design ';


--
-- Name: COLUMN tests.supplier_id; Type: COMMENT; Schema: marvin; Owner: invadm
--

COMMENT ON COLUMN marvin.tests.supplier_id IS 'test supplier';


--
-- Name: c_nn_p_state_name cpsn_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.c_nn_p_state_name ALTER COLUMN cpsn_id SET DEFAULT nextval('marvin.c_nn_p_state_name_cpsn_id_seq'::regclass);


--
-- Name: component hr_component_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.component ALTER COLUMN hr_component_id SET DEFAULT nextval('marvin.component_hr_component_id_seq'::regclass);


--
-- Name: component_type type_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.component_type ALTER COLUMN type_id SET DEFAULT nextval('marvin.component_type_type_id_seq'::regclass);


--
-- Name: components_nn_products cp_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.components_nn_products ALTER COLUMN cp_id SET DEFAULT nextval('marvin.components_nn_products_cp_id_seq'::regclass);


--
-- Name: hardware_use_tye hw_use_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.hardware_use_tye ALTER COLUMN hw_use_id SET DEFAULT nextval('marvin.hardware_use_tye_hw_use_id_seq'::regclass);


--
-- Name: life_cycle id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.life_cycle ALTER COLUMN id SET DEFAULT nextval('marvin.life_cycle_id_seq'::regclass);


--
-- Name: location_history lh_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.location_history ALTER COLUMN lh_id SET DEFAULT nextval('marvin.location_history_lh_id_seq'::regclass);


--
-- Name: product_type p_type_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.product_type ALTER COLUMN p_type_id SET DEFAULT nextval('marvin.product_type_p_type_id_seq'::regclass);


--
-- Name: project project_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.project ALTER COLUMN project_id SET DEFAULT nextval('marvin.project_project_id_seq'::regclass);


--
-- Name: state_name sn_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.state_name ALTER COLUMN sn_id SET DEFAULT nextval('marvin.state_name_sn_id_seq'::regclass);


--
-- Name: suppliers supplier_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.suppliers ALTER COLUMN supplier_id SET DEFAULT nextval('marvin.distributor_d_id_seq'::regclass);


--
-- Name: t_history id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.t_history ALTER COLUMN id SET DEFAULT nextval('marvin.t_history_id_seq'::regclass);


--
-- Name: test_name tn_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.test_name ALTER COLUMN tn_id SET DEFAULT nextval('marvin.test_name_id_seq'::regclass);


--
-- Name: test_nn_component t_nn_c_id; Type: DEFAULT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.test_nn_component ALTER COLUMN t_nn_c_id SET DEFAULT nextval('marvin.test_nn_component_t_nn_c_id_seq'::regclass);


--
-- Name: hardware_use_tye Primary_hw_use_id; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.hardware_use_tye
    ADD CONSTRAINT "Primary_hw_use_id" PRIMARY KEY (hw_use_id);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (attachment_id);


--
-- Name: c_nn_p_state_name c_nn_p_state_name_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.c_nn_p_state_name
    ADD CONSTRAINT c_nn_p_state_name_pkey PRIMARY KEY (cpsn_id);


--
-- Name: component component_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.component
    ADD CONSTRAINT component_pkey PRIMARY KEY (c_id);


--
-- Name: component_type component_type_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.component_type
    ADD CONSTRAINT component_type_pkey PRIMARY KEY (type_id);


--
-- Name: components_nn_products components_nn_products_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.components_nn_products
    ADD CONSTRAINT components_nn_products_pkey PRIMARY KEY (cp_id);


--
-- Name: design design_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.design
    ADD CONSTRAINT design_pkey PRIMARY KEY (design_id);


--
-- Name: suppliers distributor_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.suppliers
    ADD CONSTRAINT distributor_pkey PRIMARY KEY (supplier_id);


--
-- Name: life_cycle life_cycle_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.life_cycle
    ADD CONSTRAINT life_cycle_pkey PRIMARY KEY (id);


--
-- Name: location_history location_history_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.location_history
    ADD CONSTRAINT location_history_pkey PRIMARY KEY (lh_id);


--
-- Name: location_name location_name_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.location_name
    ADD CONSTRAINT location_name_pkey PRIMARY KEY (ln_id);


--
-- Name: parts parts_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.parts
    ADD CONSTRAINT parts_pkey PRIMARY KEY (part_id);


--
-- Name: product_type product_type_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (p_type_id);


--
-- Name: products products_name_unique; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.products
    ADD CONSTRAINT products_name_unique UNIQUE (name);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (p_id);


--
-- Name: project project_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (project_id);


--
-- Name: test_name state_name_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.test_name
    ADD CONSTRAINT state_name_pkey PRIMARY KEY (tn_id);


--
-- Name: state_name state_name_pkey1; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.state_name
    ADD CONSTRAINT state_name_pkey1 PRIMARY KEY (sn_id);


--
-- Name: tests state_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.tests
    ADD CONSTRAINT state_pkey PRIMARY KEY (t_id);


--
-- Name: t_history t_history_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.t_history
    ADD CONSTRAINT t_history_pkey PRIMARY KEY (id);


--
-- Name: test_nn_component test_nn_component_pkey; Type: CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.test_nn_component
    ADD CONSTRAINT test_nn_component_pkey PRIMARY KEY (t_nn_c_id);


--
-- Name: index_part_id; Type: INDEX; Schema: marvin; Owner: invadm
--

CREATE INDEX index_part_id ON marvin.component USING btree (part_id);


--
-- Name: components_nn_products cnnp_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER cnnp_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.components_nn_products FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: component component_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER component_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.component FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: component component_location_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER component_location_history AFTER INSERT OR UPDATE ON marvin.component FOR EACH ROW EXECUTE FUNCTION marvin.component_location_update_insert_history();


--
-- Name: design design_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER design_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.design FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: location_name location_name_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER location_name_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.location_name FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: parts parts_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER parts_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.parts FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: products products_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER products_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.products FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: products products_location_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER products_location_history AFTER INSERT OR UPDATE ON marvin.products FOR EACH ROW EXECUTE FUNCTION marvin.product_location_update_insert_history();


--
-- Name: project project_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER project_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.project FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: state_name state_name_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER state_name_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.state_name FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: suppliers suppliers_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER suppliers_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.suppliers FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: test_name test_name_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER test_name_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.test_name FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: test_nn_component test_nn_component_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER test_nn_component_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.test_nn_component FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: tests tests_history; Type: TRIGGER; Schema: marvin; Owner: invadm
--

CREATE TRIGGER tests_history BEFORE INSERT OR DELETE OR UPDATE ON marvin.tests FOR EACH ROW EXECUTE FUNCTION marvin.change_trigger();


--
-- Name: component component_project_id_fkey; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.component
    ADD CONSTRAINT component_project_id_fkey FOREIGN KEY (project_id) REFERENCES marvin.project(project_id) ON UPDATE CASCADE;


--
-- Name: components_nn_products components_nn_products_C_ID_fkey; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.components_nn_products
    ADD CONSTRAINT "components_nn_products_C_ID_fkey" FOREIGN KEY (c_id) REFERENCES marvin.component(c_id) ON UPDATE RESTRICT;


--
-- Name: components_nn_products components_nn_products_P_ID_fkey; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.components_nn_products
    ADD CONSTRAINT "components_nn_products_P_ID_fkey" FOREIGN KEY (p_id) REFERENCES marvin.products(p_id) ON UPDATE RESTRICT;


--
-- Name: design design_project_id_fkey; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.design
    ADD CONSTRAINT design_project_id_fkey FOREIGN KEY (project_id) REFERENCES marvin.project(project_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: component fk_component_component_type; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.component
    ADD CONSTRAINT fk_component_component_type FOREIGN KEY (type_id) REFERENCES marvin.component_type(type_id);


--
-- Name: component fk_component_location_name; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.component
    ADD CONSTRAINT fk_component_location_name FOREIGN KEY (ln_id) REFERENCES marvin.location_name(ln_id);


--
-- Name: component fk_component_parts; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.component
    ADD CONSTRAINT fk_component_parts FOREIGN KEY (part_id) REFERENCES marvin.parts(part_id);


--
-- Name: component fk_component_state_name; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.component
    ADD CONSTRAINT fk_component_state_name FOREIGN KEY (sn_id) REFERENCES marvin.state_name(sn_id);


--
-- Name: component fk_component_suppliers; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.component
    ADD CONSTRAINT fk_component_suppliers FOREIGN KEY (supplier_id) REFERENCES marvin.suppliers(supplier_id);


--
-- Name: components_nn_products fk_components_nn_products_c_nn_p_state_name; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.components_nn_products
    ADD CONSTRAINT fk_components_nn_products_c_nn_p_state_name FOREIGN KEY (cpsn_id) REFERENCES marvin.c_nn_p_state_name(cpsn_id);


--
-- Name: design fk_design_design; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.design
    ADD CONSTRAINT fk_design_design FOREIGN KEY (parent_design_id) REFERENCES marvin.design(design_id);


--
-- Name: location_history fk_location_history_location_name; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.location_history
    ADD CONSTRAINT fk_location_history_location_name FOREIGN KEY (ln_id) REFERENCES marvin.location_name(ln_id);


--
-- Name: products fk_products_design; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.products
    ADD CONSTRAINT fk_products_design FOREIGN KEY (design_id) REFERENCES marvin.design(design_id);


--
-- Name: products fk_products_location_name; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.products
    ADD CONSTRAINT fk_products_location_name FOREIGN KEY (ln_id) REFERENCES marvin.location_name(ln_id);


--
-- Name: products fk_products_state_name; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.products
    ADD CONSTRAINT fk_products_state_name FOREIGN KEY (sn_id) REFERENCES marvin.state_name(sn_id);


--
-- Name: products fk_products_suppliers; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.products
    ADD CONSTRAINT fk_products_suppliers FOREIGN KEY (supplier_id) REFERENCES marvin.suppliers(supplier_id);


--
-- Name: test_nn_component fk_test_nn_component_component; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.test_nn_component
    ADD CONSTRAINT fk_test_nn_component_component FOREIGN KEY (c_id) REFERENCES marvin.component(c_id);


--
-- Name: test_nn_component fk_test_nn_component_tests; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.test_nn_component
    ADD CONSTRAINT fk_test_nn_component_tests FOREIGN KEY (t_id) REFERENCES marvin.tests(t_id);


--
-- Name: parts parts_fk_parts_life_cycle_foreign; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.parts
    ADD CONSTRAINT parts_fk_parts_life_cycle_foreign FOREIGN KEY (fk_parts_life_cycle) REFERENCES marvin.life_cycle(id);


--
-- Name: products products_p_type_id_fkey; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.products
    ADD CONSTRAINT products_p_type_id_fkey FOREIGN KEY (p_type_id) REFERENCES marvin.product_type(p_type_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: products products_parent_p_id_fkey; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.products
    ADD CONSTRAINT products_parent_p_id_fkey FOREIGN KEY (parent_p_id) REFERENCES marvin.products(p_id) ON UPDATE RESTRICT;


--
-- Name: products products_project_id_fkey; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.products
    ADD CONSTRAINT products_project_id_fkey FOREIGN KEY (project_id) REFERENCES marvin.project(project_id) ON UPDATE CASCADE;


--
-- Name: tests state_c_id_fkey; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.tests
    ADD CONSTRAINT state_c_id_fkey FOREIGN KEY (c_id) REFERENCES marvin.component(c_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: tests state_p_id_fkey; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.tests
    ADD CONSTRAINT state_p_id_fkey FOREIGN KEY (p_id) REFERENCES marvin.products(p_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: tests state_sn_id_fkey; Type: FK CONSTRAINT; Schema: marvin; Owner: invadm
--

ALTER TABLE ONLY marvin.tests
    ADD CONSTRAINT state_sn_id_fkey FOREIGN KEY (tn_id) REFERENCES marvin.test_name(tn_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

