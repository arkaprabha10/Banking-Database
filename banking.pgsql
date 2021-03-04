--
-- PostgreSQL database dump
--

-- Dumped from database version 10.14
-- Dumped by pg_dump version 10.14

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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: details(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.details() RETURNS TABLE(b character varying)
    LANGUAGE plpgsql
    AS $$
declare
i RECORD;
begin
for i in (
select account_details_2.account_number from
account_details_2 join account_details_3 on
account_details_2.account_number=account_details_3.account_number
and Recurring_Status = True order by account_details_3.Balance desc limit
5)
loop b:=(i.account_number);
return next;
end loop;
end;
$$;


ALTER FUNCTION public.details() OWNER TO postgres;

--
-- Name: details1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.details1() RETURNS TABLE(b character varying, number character varying, number1 character varying, number3 character varying)
    LANGUAGE plpgsql
    AS $$
declare
i RECORD;
begin
for i in (select customer_id,account_number,administrator_id,bank_name from
account_type where auditor_id='81224')
loop
b:=(i.customer_id);number:=(i.account_number);number1:=(i.administrator_id);number3:=(i.bank_name);
return next;
end loop;
end;
$$;


ALTER FUNCTION public.details1() OWNER TO postgres;

--
-- Name: details3(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.details3() RETURNS TABLE(b character varying, number character varying)
    LANGUAGE plpgsql
    AS $$
declare
i RECORD;
begin
for i in (select account_number,balance from account_details_3 where
balance=(select max(balance) from account_details_3 where balance < (select
max(balance) from account_details_3)))
loop b:=(i.account_number);number:=(i.balance);
return next;
end loop;
end;
$$;


ALTER FUNCTION public.details3() OWNER TO postgres;

--
-- Name: details4(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.details4() RETURNS TABLE(b character varying, number character varying)
    LANGUAGE plpgsql
    AS $$
declare
i RECORD;
begin
for i in (SELECT customer_id FROM account_type EXCEPT SELECT
account_number FROM account_details_3 WHERE balance between '1200' and '9000'
)
loop b:=(i.customer_id);
return next;
end loop;
end;
$$;


ALTER FUNCTION public.details4() OWNER TO postgres;

--
-- Name: details5(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.details5() RETURNS TABLE(b character varying, number character varying)
    LANGUAGE plpgsql
    AS $$
declare
i RECORD;
begin
for i in (SELECT Customer_Name FROM Customer WHERE Customer_ID IN
(SELECT Customer_ID FROM Service_Provider WHERE Administrator_ID='6591280989')
)
loop b:=(i.Customer_Name);
return next;
end loop;
end;
$$;


ALTER FUNCTION public.details5() OWNER TO postgres;

--
-- Name: func_1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.func_1() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if (new.bank_name is NULL)
then UPDATE administrator SET bank_name = 'Gringotts' WHERE administrator_id = new.administrator_id;
raise notice 'Updated to default bank!';
end if;
return new;
end
$$;


ALTER FUNCTION public.func_1() OWNER TO postgres;

--
-- Name: func_3(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.func_3() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if(new.balance < 100)
then raise notice 'Balance must be in 3 digits';
return old;
end if;
return new;
end
$$;


ALTER FUNCTION public.func_3() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_details_1; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_details_1 (
    account_number character(20) NOT NULL,
    credit_card_number integer
);


ALTER TABLE public.account_details_1 OWNER TO postgres;

--
-- Name: account_details_2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_details_2 (
    account_number character(20) NOT NULL,
    debit_card_number integer
);


ALTER TABLE public.account_details_2 OWNER TO postgres;

--
-- Name: account_details_3; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_details_3 (
    account_number character(20) NOT NULL,
    balance numeric(8,2),
    recurring_status boolean
);


ALTER TABLE public.account_details_3 OWNER TO postgres;

--
-- Name: account_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_type (
    customer_id character(20) NOT NULL,
    account_category character(20),
    account_number character(20) NOT NULL,
    administrator_id character(20),
    service_provider_id character(20),
    auditor_id character(20),
    bank_name character(20)
);


ALTER TABLE public.account_type OWNER TO postgres;

--
-- Name: administrator; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.administrator (
    audit_details numeric(4,2),
    auditor_id character(20),
    administrator_id character(20) NOT NULL,
    administrator_name character(20),
    bank_name character(20)
);


ALTER TABLE public.administrator OWNER TO postgres;

--
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    customer_id character(20) NOT NULL,
    customer_name character(20),
    account_number character(20),
    pass_word character(20),
    auditor_id character(20)
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- Name: admin; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.admin AS
 SELECT count(customer.customer_id) AS count,
    administrator.administrator_id
   FROM (public.customer
     JOIN public.administrator ON ((customer.auditor_id = administrator.auditor_id)))
  GROUP BY administrator.administrator_id;


ALTER TABLE public.admin OWNER TO postgres;

--
-- Name: audit; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.audit AS
 SELECT count(customer.customer_id) AS count,
    customer.auditor_id
   FROM public.customer
  GROUP BY customer.auditor_id;


ALTER TABLE public.audit OWNER TO postgres;

--
-- Name: auditor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditor (
    auditor_id character(20) NOT NULL,
    auditor_name character(20),
    audit_stage integer
);


ALTER TABLE public.auditor OWNER TO postgres;

--
-- Name: bank; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bank (
    bank_name character(20) NOT NULL,
    policy_version numeric(4,2)
);


ALTER TABLE public.bank OWNER TO postgres;

--
-- Name: cheque_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cheque_details (
    account_number character(20) NOT NULL,
    cheques_encashed integer,
    cheque_payments numeric(8,2),
    check_books_issues integer,
    cheque_status boolean
);


ALTER TABLE public.cheque_details OWNER TO postgres;

--
-- Name: credit_card; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.credit_card (
    account_number character(20) NOT NULL,
    expiry_date date,
    maximum_limit integer,
    credit_card_status boolean
);


ALTER TABLE public.credit_card OWNER TO postgres;

--
-- Name: debit_card; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.debit_card (
    account_number character(20) NOT NULL,
    expiry_date date,
    debit_card_status boolean
);


ALTER TABLE public.debit_card OWNER TO postgres;

--
-- Name: detail; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.detail AS
 SELECT customer.customer_name,
    customer.customer_id,
    account_type.account_number,
    account_type.account_category,
    account_type.bank_name
   FROM (public.customer
     JOIN public.account_type ON ((customer.customer_id = account_type.customer_id)));


ALTER TABLE public.detail OWNER TO postgres;

--
-- Name: encashment_details_1; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.encashment_details_1 (
    payment_id character(20) NOT NULL,
    account_number character(20) NOT NULL,
    cheque_number character(20)
);


ALTER TABLE public.encashment_details_1 OWNER TO postgres;

--
-- Name: encashment_details_2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.encashment_details_2 (
    payment_id character(20) NOT NULL,
    amount integer
);


ALTER TABLE public.encashment_details_2 OWNER TO postgres;

--
-- Name: login_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.login_details (
    customer_id character(20) NOT NULL,
    pass_word character(20)
);


ALTER TABLE public.login_details OWNER TO postgres;

--
-- Name: payment_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_details (
    account_number character(20),
    payment_id character(20) NOT NULL,
    beneficiary_account_number character(20),
    amount integer
);


ALTER TABLE public.payment_details OWNER TO postgres;

--
-- Name: recurring_payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recurring_payment (
    account_number character(20) NOT NULL,
    beneficiary_account character(20),
    recurring_amount integer
);


ALTER TABLE public.recurring_payment OWNER TO postgres;

--
-- Name: service_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service_provider (
    service_provider_id character(20) NOT NULL,
    service_provider_name character(20),
    audit_details numeric(4,2),
    auditor_id character(20),
    administrator_id character(20),
    customer_id character(20) NOT NULL
);


ALTER TABLE public.service_provider OWNER TO postgres;

--
-- Data for Name: account_details_1; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_details_1 (account_number, credit_card_number) FROM stdin;
5.43593E+15         	842045
5.57274E+15         	910396
5.12088E+15         	547558
5.43859E+15         	866231
5.37984E+15         	383283
5.19309E+15         	475026
5.29511E+15         	765554
5.29656E+15         	953075
5.39921E+15         	834921
5.5909E+15          	256319
5.58388E+15         	488428
5.51585E+15         	682428
5.40256E+15         	911941
5.45129E+15         	386597
5.35408E+15         	454667
5.33129E+15         	946175
5.44355E+15         	923549
5.45387E+15         	399314
5.32034E+15         	413749
5.17317E+15         	234394
5.27297E+15         	858322
5.23303E+15         	612782
5.19242E+15         	80676
5.26682E+15         	811869
5.54189E+15         	435260
5.59783E+15         	925363
5.50673E+15         	785239
5.21178E+15         	332168
5.12286E+15         	990832
5.42259E+15         	282198
5.24686E+15         	954606
5.52315E+15         	485062
5.41355E+15         	775827
5.28728E+15         	82157
5.33399E+15         	40208
5.17497E+15         	537904
5.42549E+15         	328241
5.19965E+15         	718519
5.24415E+15         	842941
5.11899E+15         	667331
5.20861E+15         	550490
5.59799E+15         	79722
5.21491E+15         	669067
5.34633E+15         	542465
5.29166E+15         	120046
5.24125E+15         	756911
5.51983E+15         	352121
5.15732E+15         	773011
5.48996E+15         	543936
5.48911E+15         	467712
5.58899E+15         	612372
5.12366E+15         	141825
5.13689E+15         	761906
5.22086E+15         	22842
5.13054E+15         	991850
5.10223E+15         	645058
5.55436E+15         	203960
5.43986E+15         	203082
5.31086E+15         	986257
5.12735E+15         	783693
5.52871E+15         	938229
5.28326E+15         	323003
5.54925E+15         	721985
5.2668E+15          	720005
5.19175E+15         	813919
5.17919E+15         	560048
5.35645E+15         	301723
5.50605E+15         	271895
5.19764E+15         	712806
5.48052E+15         	203483
5.10153E+15         	732083
5.12909E+15         	318248
5.55847E+15         	271348
5.31603E+15         	836958
5.18561E+15         	52951
5.30618E+15         	554797
5.13861E+15         	856156
5.52918E+15         	165645
5.14233E+15         	532875
5.29565E+15         	598630
5.51685E+15         	480711
5.34252E+15         	862405
5.16679E+15         	665225
5.47116E+15         	89122
5.51033E+15         	131996
5.50933E+15         	564183
5.2983E+15          	122792
5.26903E+15         	58321
5.10219E+15         	474568
5.358E+15           	704374
5.35899E+15         	558743
5.2215E+15          	698592
5.18903E+15         	871731
5.23525E+15         	520515
5.19227E+15         	696446
5.43205E+15         	606978
5.13392E+15         	432251
5.40563E+15         	689587
5.21621E+15         	815313
5.57094E+15         	134014
\.


--
-- Data for Name: account_details_2; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_details_2 (account_number, debit_card_number) FROM stdin;
5.43593E+15         	519280
5.57274E+15         	931455
5.12088E+15         	341100
5.43859E+15         	634495
5.37984E+15         	22835
5.19309E+15         	731921
5.29511E+15         	41190
5.29656E+15         	649826
5.39921E+15         	15321
5.5909E+15          	642875
5.58388E+15         	374068
5.51585E+15         	992780
5.40256E+15         	839945
5.45129E+15         	600542
5.35408E+15         	795213
5.33129E+15         	470250
5.44355E+15         	287928
5.45387E+15         	445517
5.32034E+15         	669457
5.17317E+15         	362054
5.27297E+15         	73829
5.23303E+15         	607381
5.19242E+15         	818183
5.26682E+15         	646568
5.54189E+15         	49269
5.59783E+15         	809031
5.50673E+15         	948755
5.21178E+15         	558085
5.12286E+15         	750334
5.42259E+15         	73875
5.24686E+15         	912076
5.52315E+15         	688052
5.41355E+15         	289250
5.28728E+15         	408732
5.33399E+15         	682068
5.17497E+15         	325551
5.42549E+15         	218289
5.19965E+15         	352051
5.24415E+15         	304789
5.11899E+15         	944424
5.20861E+15         	745
5.59799E+15         	170085
5.21491E+15         	697000
5.34633E+15         	163116
5.29166E+15         	67644
5.24125E+15         	837676
5.51983E+15         	148753
5.15732E+15         	338842
5.48996E+15         	100755
5.48911E+15         	402485
5.58899E+15         	761208
5.12366E+15         	855875
5.13689E+15         	334899
5.22086E+15         	50301
5.13054E+15         	841053
5.10223E+15         	70232
5.55436E+15         	569567
5.43986E+15         	285845
5.31086E+15         	907079
5.12735E+15         	413098
5.52871E+15         	162288
5.28326E+15         	738299
5.54925E+15         	666151
5.2668E+15          	613951
5.19175E+15         	559236
5.17919E+15         	401201
5.35645E+15         	828051
5.50605E+15         	149531
5.19764E+15         	22412
5.48052E+15         	876708
5.10153E+15         	272756
5.12909E+15         	120201
5.55847E+15         	170599
5.31603E+15         	962172
5.18561E+15         	372455
5.30618E+15         	967292
5.13861E+15         	156744
5.52918E+15         	898951
5.14233E+15         	904667
5.29565E+15         	819982
5.51685E+15         	449422
5.34252E+15         	907477
5.16679E+15         	433234
5.47116E+15         	258724
5.51033E+15         	549456
5.50933E+15         	96863
5.2983E+15          	496767
5.26903E+15         	648560
5.10219E+15         	407794
5.358E+15           	764484
5.35899E+15         	977210
5.2215E+15          	27830
5.18903E+15         	114697
5.23525E+15         	544134
5.19227E+15         	111938
5.43205E+15         	759337
5.13392E+15         	521540
5.40563E+15         	163870
5.21621E+15         	7386
5.57094E+15         	218096
\.


--
-- Data for Name: account_details_3; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_details_3 (account_number, balance, recurring_status) FROM stdin;
5.43593E+15         	74469.00	f
5.57274E+15         	83778.00	t
5.12088E+15         	1676.00	t
5.43859E+15         	46821.00	f
5.37984E+15         	82911.00	f
5.19309E+15         	33597.00	f
5.29511E+15         	8871.00	f
5.29656E+15         	66356.00	f
5.39921E+15         	36205.00	t
5.5909E+15          	10200.00	f
5.58388E+15         	13361.00	t
5.51585E+15         	6888.00	t
5.40256E+15         	43956.00	t
5.45129E+15         	26964.00	f
5.35408E+15         	46296.00	f
5.33129E+15         	81497.00	f
5.44355E+15         	44420.00	f
5.45387E+15         	68246.00	f
5.32034E+15         	33652.00	t
5.17317E+15         	6316.00	f
5.27297E+15         	53381.00	t
5.23303E+15         	68954.00	f
5.19242E+15         	31951.00	t
5.26682E+15         	82807.00	f
5.54189E+15         	24558.00	t
5.59783E+15         	83717.00	t
5.50673E+15         	63260.00	t
5.21178E+15         	5233.00	f
5.12286E+15         	14122.00	t
5.42259E+15         	21630.00	t
5.24686E+15         	27879.00	f
5.52315E+15         	50951.00	t
5.41355E+15         	80803.00	t
5.28728E+15         	32577.00	f
5.33399E+15         	49904.00	f
5.17497E+15         	11756.00	t
5.42549E+15         	35404.00	f
5.19965E+15         	14748.00	f
5.24415E+15         	81940.00	f
5.11899E+15         	42387.00	t
5.20861E+15         	78192.00	f
5.59799E+15         	60669.00	f
5.21491E+15         	24060.00	f
5.34633E+15         	75049.00	f
5.29166E+15         	68996.00	f
5.24125E+15         	2636.00	f
5.51983E+15         	33502.00	t
5.15732E+15         	25521.00	t
5.48996E+15         	78837.00	f
5.48911E+15         	30262.00	t
5.58899E+15         	79786.00	t
5.12366E+15         	53172.00	t
5.13689E+15         	4573.00	f
5.22086E+15         	71564.00	t
5.13054E+15         	7660.00	t
5.10223E+15         	79177.00	f
5.55436E+15         	21337.00	t
5.43986E+15         	72445.00	t
5.31086E+15         	59738.00	f
5.12735E+15         	88701.00	f
5.52871E+15         	39489.00	t
5.28326E+15         	44862.00	t
5.54925E+15         	50474.00	t
5.2668E+15          	72662.00	t
5.19175E+15         	9613.00	f
5.17919E+15         	8574.00	f
5.35645E+15         	24579.00	t
5.50605E+15         	84643.00	f
5.19764E+15         	70759.00	f
5.48052E+15         	67522.00	f
5.10153E+15         	82403.00	f
5.12909E+15         	29990.00	f
5.55847E+15         	10424.00	t
5.31603E+15         	66765.00	t
5.18561E+15         	51699.00	t
5.30618E+15         	87582.00	t
5.13861E+15         	96347.00	f
5.52918E+15         	7134.00	f
5.14233E+15         	64130.00	f
5.29565E+15         	47592.00	f
5.51685E+15         	88486.00	f
5.34252E+15         	38104.00	f
5.16679E+15         	45822.00	f
5.47116E+15         	89652.00	t
5.51033E+15         	45530.00	t
5.50933E+15         	69815.00	f
5.2983E+15          	15968.00	f
5.26903E+15         	85042.00	f
5.10219E+15         	19009.00	f
5.358E+15           	2576.00	t
5.35899E+15         	83741.00	t
5.2215E+15          	90620.00	f
5.18903E+15         	82625.00	f
5.23525E+15         	36435.00	f
5.19227E+15         	40958.00	t
5.43205E+15         	50487.00	t
5.13392E+15         	37761.00	f
5.40563E+15         	61248.00	f
5.21621E+15         	56323.00	t
5.57094E+15         	65353.00	t
\.


--
-- Data for Name: account_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_type (customer_id, account_category, account_number, administrator_id, service_provider_id, auditor_id, bank_name) FROM stdin;
51516               	Current             	5.43593E+15         	6591280989          	5.52112E+15         	41445               	Gringotts           
85820               	Savings             	5.57274E+15         	3687598091          	5.22059E+15         	25954               	Gringotts           
92538               	Current             	5.12088E+15         	8600365895          	5.54259E+15         	98971               	Gringotts           
31554               	Savings             	5.43859E+15         	3156620572          	5.58024E+15         	81224               	Gringotts           
94914               	Current             	5.37984E+15         	9240093888          	5.23787E+15         	52934               	Gringotts           
86418               	Savings             	5.19309E+15         	0772427985          	5.12783E+15         	54208               	Gringotts           
9140                	Current             	5.29511E+15         	8146816319          	5.42011E+15         	24253               	Gringotts           
6569                	Savings             	5.29656E+15         	3765992793          	5.56939E+15         	10976               	Gringotts           
4118                	Current             	5.39921E+15         	6501774679          	5.54795E+15         	28954               	Gringotts           
11854               	Savings             	5.5909E+15          	5872994732          	5.23883E+15         	51254               	Gringotts           
85671               	Current             	5.58388E+15         	2999339791          	5.19038E+15         	41445               	Gringotts           
78933               	Savings             	5.51585E+15         	2500608078          	5.39923E+15         	25954               	Gringotts           
81129               	Current             	5.40256E+15         	1175693089          	5.16083E+15         	98971               	Gringotts           
76420               	Savings             	5.45129E+15         	4383631372          	5.37629E+15         	81224               	Gringotts           
15936               	Current             	5.35408E+15         	5965202007          	5.54082E+15         	52934               	Gringotts           
38662               	Savings             	5.33129E+15         	3840737835          	5.23381E+15         	54208               	Gringotts           
46928               	Current             	5.44355E+15         	5150633322          	5.38871E+15         	24253               	Gringotts           
71405               	Savings             	5.45387E+15         	6954057699          	5.29114E+15         	10976               	Gringotts           
8886                	Current             	5.32034E+15         	6793473624          	5.51823E+15         	28954               	Gringotts           
76862               	Savings             	5.17317E+15         	3076160406          	5.52954E+15         	51254               	Gringotts           
76226               	Current             	5.27297E+15         	2927065725          	5.33452E+15         	41445               	Gringotts           
92176               	Savings             	5.23303E+15         	7456711857          	5.40079E+15         	25954               	Gringotts           
86002               	Current             	5.19242E+15         	6602972422          	5.27255E+15         	98971               	Gringotts           
91584               	Savings             	5.26682E+15         	1967701810          	5.21646E+15         	81224               	Gringotts           
16947               	Current             	5.54189E+15         	4754379096          	5.13939E+15         	52934               	Gringotts           
53427               	Savings             	5.59783E+15         	6591280989          	5.13404E+15         	54208               	Gringotts           
92741               	Current             	5.50673E+15         	3687598091          	5.57911E+15         	24253               	Gringotts           
21939               	Savings             	5.21178E+15         	8600365895          	5.19075E+15         	10976               	Gringotts           
30296               	Current             	5.12286E+15         	3156620572          	5.59892E+15         	28954               	Gringotts           
40703               	Savings             	5.42259E+15         	9240093888          	5.5047E+15          	51254               	Gringotts           
74830               	Current             	5.24686E+15         	0772427985          	5.57825E+15         	41445               	Gringotts           
60114               	Savings             	5.52315E+15         	8146816319          	5.1015E+15          	25954               	Gringotts           
22880               	Current             	5.41355E+15         	3765992793          	5.32549E+15         	98971               	Gringotts           
21407               	Savings             	5.28728E+15         	6501774679          	5.48858E+15         	81224               	Gringotts           
87766               	Current             	5.33399E+15         	5872994732          	5.21907E+15         	52934               	Gringotts           
94472               	Savings             	5.17497E+15         	2999339791          	5.21914E+15         	54208               	Gringotts           
54285               	Current             	5.42549E+15         	2500608078          	5.34421E+15         	24253               	Gringotts           
20513               	Savings             	5.19965E+15         	1175693089          	5.30217E+15         	10976               	Gringotts           
60024               	Current             	5.24415E+15         	4383631372          	5.31317E+15         	28954               	Gringotts           
6843                	Savings             	5.11899E+15         	5965202007          	5.28526E+15         	51254               	Gringotts           
16516               	Current             	5.20861E+15         	3840737835          	5.54095E+15         	41445               	Gringotts           
9080                	Savings             	5.59799E+15         	5150633322          	5.2879E+15          	25954               	Gringotts           
78872               	Current             	5.21491E+15         	6954057699          	5.51267E+15         	98971               	Gringotts           
72988               	Savings             	5.34633E+15         	6793473624          	5.33379E+15         	81224               	Gringotts           
22453               	Current             	5.29166E+15         	3076160406          	5.31549E+15         	52934               	Gringotts           
17494               	Savings             	5.24125E+15         	2927065725          	5.34522E+15         	54208               	Gringotts           
59260               	Current             	5.51983E+15         	7456711857          	5.43248E+15         	24253               	Gringotts           
12752               	Savings             	5.15732E+15         	6602972422          	5.11597E+15         	10976               	Gringotts           
56426               	Current             	5.48996E+15         	1967701810          	5.51124E+15         	28954               	Gringotts           
41891               	Savings             	5.48911E+15         	4754379096          	5.22529E+15         	51254               	Gringotts           
73841               	Current             	5.58899E+15         	6591280989          	5.19878E+15         	41445               	Gringotts           
3612                	Savings             	5.12366E+15         	3687598091          	5.36329E+15         	25954               	Gringotts           
74765               	Current             	5.13689E+15         	8600365895          	5.40927E+15         	98971               	Gringotts           
47267               	Savings             	5.22086E+15         	3156620572          	5.22287E+15         	81224               	Gringotts           
53658               	Current             	5.13054E+15         	9240093888          	5.43642E+15         	52934               	Gringotts           
51235               	Savings             	5.10223E+15         	0772427985          	5.16931E+15         	54208               	Gringotts           
40594               	Current             	5.55436E+15         	8146816319          	5.11345E+15         	24253               	Gringotts           
78385               	Savings             	5.43986E+15         	3765992793          	5.36785E+15         	10976               	Gringotts           
88084               	Current             	5.31086E+15         	6501774679          	5.33283E+15         	28954               	Gringotts           
66912               	Savings             	5.12735E+15         	5872994732          	5.41701E+15         	51254               	Gringotts           
89765               	Current             	5.52871E+15         	2999339791          	5.24965E+15         	41445               	Gringotts           
11486               	Savings             	5.28326E+15         	2500608078          	5.24742E+15         	25954               	Gringotts           
17189               	Current             	5.54925E+15         	1175693089          	5.46847E+15         	98971               	Gringotts           
58014               	Savings             	5.2668E+15          	4383631372          	5.10317E+15         	81224               	Gringotts           
5381                	Current             	5.19175E+15         	5965202007          	5.4202E+15          	52934               	Gringotts           
9264                	Savings             	5.17919E+15         	3840737835          	5.44895E+15         	54208               	Gringotts           
44905               	Current             	5.35645E+15         	5150633322          	5.40201E+15         	24253               	Gringotts           
33940               	Savings             	5.50605E+15         	6954057699          	5.36055E+15         	10976               	Gringotts           
56805               	Current             	5.19764E+15         	6793473624          	5.37469E+15         	28954               	Gringotts           
13746               	Savings             	5.48052E+15         	3076160406          	5.52272E+15         	51254               	Gringotts           
93653               	Current             	5.10153E+15         	2927065725          	5.39001E+15         	41445               	Gringotts           
77716               	Savings             	5.12909E+15         	7456711857          	5.45547E+15         	25954               	Gringotts           
60011               	Current             	5.55847E+15         	6602972422          	5.10059E+15         	98971               	Gringotts           
57351               	Savings             	5.31603E+15         	1967701810          	5.41242E+15         	81224               	Gringotts           
31360               	Current             	5.18561E+15         	4754379096          	5.57871E+15         	52934               	Gringotts           
67750               	Savings             	5.30618E+15         	6591280989          	5.53877E+15         	54208               	Gringotts           
14080               	Current             	5.13861E+15         	3687598091          	5.34102E+15         	24253               	Gringotts           
97390               	Savings             	5.52918E+15         	8600365895          	5.49042E+15         	10976               	Gringotts           
36135               	Current             	5.14233E+15         	3156620572          	5.33235E+15         	28954               	Gringotts           
96109               	Savings             	5.29565E+15         	9240093888          	5.36306E+15         	51254               	Gringotts           
66061               	Current             	5.51685E+15         	0772427985          	5.45972E+15         	41445               	Gringotts           
29068               	Savings             	5.34252E+15         	8146816319          	5.19605E+15         	25954               	Gringotts           
81225               	Current             	5.16679E+15         	3765992793          	5.48687E+15         	98971               	Gringotts           
4741                	Savings             	5.47116E+15         	6501774679          	5.35017E+15         	81224               	Gringotts           
96923               	Current             	5.51033E+15         	5872994732          	5.1777E+15          	52934               	Gringotts           
78576               	Savings             	5.50933E+15         	2999339791          	5.35853E+15         	54208               	Gringotts           
45580               	Current             	5.2983E+15          	2500608078          	5.10381E+15         	24253               	Gringotts           
17362               	Savings             	5.26903E+15         	1175693089          	5.38134E+15         	10976               	Gringotts           
91894               	Current             	5.10219E+15         	4383631372          	5.35489E+15         	28954               	Gringotts           
79510               	Savings             	5.358E+15           	5965202007          	5.50859E+15         	51254               	Gringotts           
37844               	Current             	5.35899E+15         	3840737835          	5.43871E+15         	41445               	Gringotts           
3690                	Savings             	5.2215E+15          	5150633322          	5.31827E+15         	25954               	Gringotts           
68750               	Current             	5.18903E+15         	6954057699          	5.39408E+15         	98971               	Gringotts           
75479               	Savings             	5.23525E+15         	6793473624          	5.5114E+15          	81224               	Gringotts           
85283               	Current             	5.19227E+15         	3076160406          	5.26641E+15         	52934               	Gringotts           
47198               	Savings             	5.43205E+15         	2927065725          	5.29521E+15         	54208               	Gringotts           
16853               	Current             	5.13392E+15         	7456711857          	5.165E+15           	24253               	Gringotts           
72864               	Savings             	5.40563E+15         	6602972422          	5.22928E+15         	10976               	Gringotts           
66277               	Current             	5.21621E+15         	1967701810          	5.32008E+15         	28954               	Gringotts           
74231               	Savings             	5.57094E+15         	4754379096          	5.1087E+15          	51254               	Gringotts           
\.


--
-- Data for Name: administrator; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.administrator (audit_details, auditor_id, administrator_id, administrator_name, bank_name) FROM stdin;
11.00	41445               	6591280989          	Kai                 	Gringotts           
15.00	25954               	3687598091          	Addison             	Gringotts           
8.00	98971               	8600365895          	Heather             	Gringotts           
3.00	81224               	3156620572          	Iona                	Gringotts           
18.00	52934               	9240093888          	Ulric               	Gringotts           
12.00	54208               	0772427985          	Price               	Gringotts           
8.00	24253               	8146816319          	Galvin              	Gringotts           
3.00	10976               	3765992793          	Lacey               	Gringotts           
19.00	28954               	6501774679          	Kadeem              	Gringotts           
3.00	51254               	5872994732          	Scott               	Gringotts           
19.00	41445               	2999339791          	Jason               	Gringotts           
8.00	25954               	2500608078          	Adam                	Gringotts           
4.00	98971               	1175693089          	Thor                	Gringotts           
20.00	81224               	4383631372          	Aphrodite           	Gringotts           
11.00	52934               	5965202007          	Liberty             	Gringotts           
8.00	54208               	3840737835          	Charlotte           	Gringotts           
15.00	24253               	5150633322          	Mannix              	Gringotts           
7.00	10976               	6954057699          	Madaline            	Gringotts           
20.00	28954               	6793473624          	Evelyn              	Gringotts           
11.00	51254               	3076160406          	Dean                	Gringotts           
8.00	41445               	2927065725          	Nicole              	Gringotts           
2.00	25954               	7456711857          	Celeste             	Gringotts           
14.00	98971               	6602972422          	TaShya              	Gringotts           
16.00	81224               	1967701810          	Cherokee            	Gringotts           
6.00	52934               	4754379096          	Lois                	Gringotts           
18.00	52934               	9240093889          	Arka                	Gringotts           
\.


--
-- Data for Name: auditor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auditor (auditor_id, auditor_name, audit_stage) FROM stdin;
41445               	Maggy               	2
25954               	Plato               	10
98971               	Micah               	5
81224               	Lana                	4
52934               	Jordan              	5
54208               	Fredericka          	8
24253               	Tiger               	9
10976               	Leslie              	4
28954               	Xander              	3
51254               	Zane                	5
\.


--
-- Data for Name: bank; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bank (bank_name, policy_version) FROM stdin;
Gringotts           	20.20
\.


--
-- Data for Name: cheque_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cheque_details (account_number, cheques_encashed, cheque_payments, check_books_issues, cheque_status) FROM stdin;
5.19309E+15         	0	0.00	0	t
5.29511E+15         	0	0.00	0	t
5.29656E+15         	0	0.00	0	t
5.39921E+15         	0	0.00	0	t
5.5909E+15          	0	0.00	0	t
5.58388E+15         	0	0.00	0	f
5.51585E+15         	0	0.00	0	f
5.40256E+15         	0	0.00	0	f
5.45129E+15         	0	0.00	0	t
5.35408E+15         	0	0.00	0	t
5.33129E+15         	0	0.00	0	f
5.44355E+15         	0	0.00	0	f
5.45387E+15         	0	0.00	0	f
5.32034E+15         	0	0.00	0	f
5.17317E+15         	0	0.00	0	f
5.27297E+15         	0	0.00	0	f
5.23303E+15         	0	0.00	0	t
5.19242E+15         	0	0.00	0	f
5.26682E+15         	0	0.00	0	t
5.54189E+15         	0	0.00	0	t
5.59783E+15         	0	0.00	0	f
5.50673E+15         	0	0.00	0	f
5.21178E+15         	0	0.00	0	f
5.12286E+15         	0	0.00	0	f
5.42259E+15         	0	0.00	0	f
5.24686E+15         	0	0.00	0	t
5.52315E+15         	0	0.00	0	t
5.41355E+15         	0	0.00	0	f
5.28728E+15         	0	0.00	0	f
5.33399E+15         	0	0.00	0	t
5.17497E+15         	0	0.00	0	f
5.42549E+15         	0	0.00	0	f
5.19965E+15         	0	0.00	0	f
5.24415E+15         	0	0.00	0	f
5.11899E+15         	0	0.00	0	f
5.20861E+15         	0	0.00	0	t
5.59799E+15         	0	0.00	0	t
5.21491E+15         	0	0.00	0	f
5.34633E+15         	0	0.00	0	t
5.29166E+15         	0	0.00	0	f
5.24125E+15         	0	0.00	0	f
5.51983E+15         	0	0.00	0	f
5.15732E+15         	0	0.00	0	t
5.48996E+15         	0	0.00	0	f
5.48911E+15         	0	0.00	0	t
5.58899E+15         	0	0.00	0	t
5.12366E+15         	0	0.00	0	t
5.13689E+15         	0	0.00	0	f
5.22086E+15         	0	0.00	0	t
5.13054E+15         	0	0.00	0	t
5.10223E+15         	0	0.00	0	f
5.55436E+15         	0	0.00	0	f
5.43986E+15         	0	0.00	0	t
5.31086E+15         	0	0.00	0	t
5.12735E+15         	0	0.00	0	f
5.52871E+15         	0	0.00	0	f
5.28326E+15         	0	0.00	0	t
5.54925E+15         	0	0.00	0	f
5.2668E+15          	0	0.00	0	f
5.19175E+15         	0	0.00	0	t
5.17919E+15         	0	0.00	0	t
5.35645E+15         	0	0.00	0	f
5.50605E+15         	0	0.00	0	f
5.19764E+15         	0	0.00	0	f
5.48052E+15         	0	0.00	0	f
5.10153E+15         	0	0.00	0	t
5.12909E+15         	0	0.00	0	t
5.55847E+15         	0	0.00	0	t
5.31603E+15         	0	0.00	0	f
5.18561E+15         	0	0.00	0	f
5.30618E+15         	0	0.00	0	f
5.13861E+15         	0	0.00	0	f
5.52918E+15         	0	0.00	0	t
5.14233E+15         	0	0.00	0	t
5.29565E+15         	0	0.00	0	f
5.51685E+15         	0	0.00	0	f
5.34252E+15         	0	0.00	0	t
5.16679E+15         	0	0.00	0	f
5.47116E+15         	0	0.00	0	t
5.51033E+15         	0	0.00	0	t
5.50933E+15         	0	0.00	0	t
5.2983E+15          	0	0.00	0	t
5.26903E+15         	0	0.00	0	t
5.10219E+15         	0	0.00	0	f
5.358E+15           	0	0.00	0	f
5.35899E+15         	0	0.00	0	f
5.2215E+15          	0	0.00	0	f
5.18903E+15         	0	0.00	0	f
5.23525E+15         	0	0.00	0	f
5.19227E+15         	0	0.00	0	t
5.43205E+15         	0	0.00	0	f
5.13392E+15         	0	0.00	0	t
5.40563E+15         	0	0.00	0	f
5.21621E+15         	0	0.00	0	f
5.57094E+15         	0	0.00	0	f
5.43593E+15         	10	1000.00	0	t
5.57274E+15         	10	2000.00	0	t
5.12088E+15         	10	3000.00	0	t
5.37984E+15         	10	5000.00	0	t
5.43859E+15         	10	4000.00	0	t
\.


--
-- Data for Name: credit_card; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credit_card (account_number, expiry_date, maximum_limit, credit_card_status) FROM stdin;
5.43593E+15         	2022-07-15	963701	f
5.57274E+15         	2023-10-19	167234	f
5.12088E+15         	2030-01-12	202487	f
5.43859E+15         	2023-12-29	430322	t
5.37984E+15         	2026-09-09	406340	t
5.19309E+15         	2020-01-22	961965	t
5.29511E+15         	2025-10-14	871070	f
5.29656E+15         	2027-10-31	534685	f
5.39921E+15         	2027-03-13	147340	t
5.5909E+15          	2022-09-11	108405	f
5.58388E+15         	2024-02-16	572622	f
5.51585E+15         	2027-10-19	496117	t
5.40256E+15         	2023-10-23	401183	f
5.45129E+15         	2022-05-24	638070	t
5.35408E+15         	2032-09-02	451710	t
5.33129E+15         	2030-12-18	187428	t
5.44355E+15         	2023-11-14	471206	f
5.45387E+15         	2020-09-11	980319	f
5.32034E+15         	2028-07-01	44804	f
5.17317E+15         	2032-07-23	466652	t
5.27297E+15         	2027-07-07	778204	f
5.23303E+15         	2030-09-09	87184	f
5.19242E+15         	2027-07-11	219357	t
5.26682E+15         	2024-05-15	106052	f
5.54189E+15         	2027-02-20	276262	f
5.59783E+15         	2027-03-29	116097	f
5.50673E+15         	2023-05-10	536876	t
5.21178E+15         	2020-08-29	361716	f
5.12286E+15         	2028-03-03	840497	f
5.42259E+15         	2023-02-17	420785	f
5.24686E+15         	2024-08-04	713922	t
5.52315E+15         	2026-08-21	282011	f
5.41355E+15         	2021-04-17	534860	f
5.28728E+15         	2024-02-15	272337	t
5.33399E+15         	2022-07-12	472431	f
5.17497E+15         	2024-07-01	39147	t
5.42549E+15         	2033-05-26	482627	t
5.19965E+15         	2029-07-27	235608	f
5.24415E+15         	2022-10-02	514573	f
5.11899E+15         	2029-01-22	484665	t
5.20861E+15         	2028-09-23	944054	f
5.59799E+15         	2027-10-06	745433	t
5.21491E+15         	2022-10-04	860322	t
5.34633E+15         	2026-02-04	859920	f
5.29166E+15         	2021-09-05	263613	t
5.24125E+15         	2030-11-25	322580	t
5.51983E+15         	2023-12-08	546177	t
5.15732E+15         	2030-12-21	96960	f
5.48996E+15         	2025-05-26	785700	f
5.48911E+15         	2021-05-15	703713	t
5.58899E+15         	2020-12-20	493296	t
5.12366E+15         	2023-09-20	832997	f
5.13689E+15         	2028-08-12	920999	t
5.22086E+15         	2030-10-09	537011	t
5.13054E+15         	2025-08-22	857354	f
5.10223E+15         	2026-09-26	449945	f
5.55436E+15         	2023-09-25	156054	f
5.43986E+15         	2020-03-30	710077	f
5.31086E+15         	2027-02-08	160523	f
5.12735E+15         	2033-05-20	527095	f
5.52871E+15         	2025-11-03	683861	f
5.28326E+15         	2021-05-28	941012	t
5.54925E+15         	2030-02-25	810224	t
5.2668E+15          	2028-09-11	876069	f
5.19175E+15         	2021-08-31	654101	f
5.17919E+15         	2025-08-04	525822	t
5.35645E+15         	2026-01-15	182741	t
5.50605E+15         	2031-08-29	214072	f
5.19764E+15         	2024-02-11	820366	f
5.48052E+15         	2029-03-07	16118	f
5.10153E+15         	2026-12-01	254149	f
5.12909E+15         	2031-09-28	39149	t
5.55847E+15         	2025-08-13	281663	t
5.31603E+15         	2025-03-28	198314	f
5.18561E+15         	2032-02-11	542963	f
5.30618E+15         	2026-12-10	561856	t
5.13861E+15         	2026-01-23	937486	t
5.52918E+15         	2029-10-19	379269	f
5.14233E+15         	2026-02-26	396708	t
5.29565E+15         	2025-02-11	276485	t
5.51685E+15         	2026-07-23	347792	f
5.34252E+15         	2021-09-17	657205	t
5.16679E+15         	2023-05-27	776780	t
5.47116E+15         	2028-02-22	554569	t
5.51033E+15         	2030-04-29	135807	f
5.50933E+15         	2027-01-16	29716	t
5.2983E+15          	2028-04-18	35278	f
5.26903E+15         	2021-10-07	101926	t
5.10219E+15         	2026-11-23	648505	t
5.358E+15           	2031-12-30	294155	f
5.35899E+15         	2029-06-08	607868	t
5.2215E+15          	2025-08-12	389760	f
5.18903E+15         	2032-09-04	257149	t
5.23525E+15         	2032-12-19	518175	t
5.19227E+15         	2029-11-28	44623	t
5.43205E+15         	2025-01-30	302153	f
5.13392E+15         	2026-02-09	852298	t
5.40563E+15         	2031-01-11	626601	t
5.21621E+15         	2023-04-03	396704	t
5.57094E+15         	2032-03-04	39602	f
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer (customer_id, customer_name, account_number, pass_word, auditor_id) FROM stdin;
85820               	Caleb               	5.38545E+15         	ZPM15GCY0NN         	25954               
92538               	Nigel               	5.31162E+15         	KRL76SFI2DY         	98971               
31554               	Abel                	5.50156E+15         	COO20HJL0EL         	81224               
94914               	Wyatt               	5.19405E+15         	KKY80PRB3NV         	52934               
86418               	Robin               	5.42207E+15         	ELF56ARE6VV         	54208               
9140                	Rafael              	5.23442E+15         	GAN33GXE2CC         	24253               
6569                	Riley               	5.55956E+15         	LWM84XWX4ED         	10976               
4118                	Charlotte           	5.49162E+15         	ZHV98DXQ1GR         	28954               
11854               	Charissa            	5.49767E+15         	NUR57CFQ8TN         	51254               
85671               	Hu                  	5.30496E+15         	HTD64LOT9VC         	41445               
78933               	Shaine              	5.11282E+15         	DWJ23BJW6FB         	25954               
81129               	Madonna             	5.39836E+15         	DXA61UDX6SB         	98971               
76420               	Kadeem              	5.39174E+15         	RHW81ZSJ1QX         	81224               
15936               	Francis             	5.51626E+15         	UFC24IAL2MG         	52934               
38662               	Roth                	5.15456E+15         	VRN35BUU9WS         	54208               
46928               	Curran              	5.10448E+15         	LBZ68MZQ0IJ         	24253               
71405               	Xantha              	5.36235E+15         	EUZ14GCE8EC         	10976               
8886                	Adara               	5.47807E+15         	GGV12TZQ3HS         	28954               
76862               	Nola                	5.58912E+15         	VZV23UBU5LU         	51254               
76226               	Zahir               	5.5477E+15          	QFB17PBG3TD         	41445               
92176               	Hop                 	5.26919E+15         	BEN50OKQ8OU         	25954               
86002               	Shaine              	5.40458E+15         	PQC22FLY3UM         	98971               
91584               	Calvin              	5.36624E+15         	NTG25HLF1YT         	81224               
16947               	Claire              	5.35535E+15         	OKM06AZZ3BP         	52934               
53427               	Shelly              	5.56073E+15         	WNY82IBM1MX         	54208               
92741               	Laurel              	5.5287E+15          	KUD15GNF5WK         	24253               
21939               	Melinda             	5.13087E+15         	QSO89PHV9UF         	10976               
30296               	Hilary              	5.51376E+15         	TVL03EXT5CZ         	28954               
40703               	Flynn               	5.16201E+15         	CMQ77FEH9CA         	51254               
74830               	Brooke              	5.12068E+15         	UIY26VBW4VO         	41445               
60114               	Oprah               	5.54169E+15         	JFH69VLU3DZ         	25954               
22880               	Renee               	5.54368E+15         	TBP32RZY1BK         	98971               
21407               	Madonna             	5.17858E+15         	GNS41ECK7SM         	81224               
87766               	Chantale            	5.26106E+15         	BHU50VML6DE         	52934               
94472               	Channing            	5.57907E+15         	QOA93YUQ0QE         	54208               
54285               	Acton               	5.43578E+15         	JUZ73CRG1ZK         	24253               
20513               	Kylan               	5.35128E+15         	WKM87EAT8GT         	10976               
60024               	Jada                	5.57859E+15         	AGH55XOP7AF         	28954               
6843                	Darryl              	5.48076E+15         	SIB34UEJ3TT         	51254               
16516               	Willa               	5.13853E+15         	YIK57KFX2AW         	41445               
9080                	Isabelle            	5.20306E+15         	DKK29RKP3CY         	25954               
78872               	Ivory               	5.10896E+15         	OBG47NZD3EX         	98971               
72988               	Mark                	5.18179E+15         	NVZ21NPI6CQ         	81224               
22453               	Blaze               	5.58657E+15         	QME32DYF4BQ         	52934               
17494               	Quamar              	5.56223E+15         	PGM65TBR6OP         	54208               
59260               	Harding             	5.28488E+15         	JXX10YLY8JS         	24253               
12752               	Berk                	5.45708E+15         	UAC41BAA9MO         	10976               
56426               	Lamar               	5.40601E+15         	RTW67XLC9HJ         	28954               
41891               	Aristotle           	5.20495E+15         	XIR06CEZ9XE         	51254               
73841               	Rama                	5.50436E+15         	HMJ64YEM0VZ         	41445               
3612                	Emma                	5.42734E+15         	PTB96ZSB4GB         	25954               
74765               	Aaron               	5.48978E+15         	WFI11UQO8TG         	98971               
47267               	Forrest             	5.55668E+15         	IZI76UOG1OD         	81224               
53658               	Curran              	5.59333E+15         	XWN28UWM4EO         	52934               
51235               	Jeremy              	5.27759E+15         	PMW40OTH8XM         	54208               
40594               	Willow              	5.49754E+15         	YXQ52RJC3PE         	24253               
78385               	Eaton               	5.15449E+15         	GIG12KUC2EK         	10976               
88084               	Jemima              	5.46732E+15         	IHW82RFR7ZU         	28954               
66912               	Gloria              	5.22757E+15         	ACM70ZNF7NZ         	51254               
89765               	Reed                	5.19188E+15         	TRB17HRO0XV         	41445               
11486               	Cameran             	5.11817E+15         	KGR16KJQ8WR         	25954               
17189               	Mira                	5.55559E+15         	GFZ44VTA8CS         	98971               
58014               	Ferdinand           	5.46531E+15         	AXU23RKA4RJ         	81224               
5381                	Cathleen            	5.45579E+15         	BLV96JSF7DT         	52934               
9264                	Aristotle           	5.29791E+15         	FPQ65ROB3MA         	54208               
44905               	Azalia              	5.42825E+15         	OWS97HAE0ZM         	24253               
33940               	Alan                	5.52935E+15         	MKX42HQS5AJ         	10976               
56805               	Rose                	5.54509E+15         	LON25JZD4LW         	28954               
13746               	Dieter              	5.18097E+15         	VJV34DIB6HE         	51254               
93653               	Kelsie              	5.29132E+15         	JHM07VTR3YJ         	41445               
77716               	Chancellor          	5.15762E+15         	TRM69BAV7YO         	25954               
60011               	Paloma              	5.56492E+15         	IGD99RZI7OL         	98971               
57351               	Charity             	5.5052E+15          	NHL83XAE7BF         	81224               
31360               	Lisandra            	5.26357E+15         	RFP21VQE4VI         	52934               
67750               	Vincent             	5.45679E+15         	WXV22JWC2HZ         	54208               
14080               	Irene               	5.301E+15           	JTX19PAO5ZL         	24253               
97390               	Raven               	5.45619E+15         	ZAF92QWD6CK         	10976               
36135               	Reese               	5.2454E+15          	FLJ20DWY2ZU         	28954               
96109               	Benedict            	5.4677E+15          	AQC59XJX8JW         	51254               
66061               	Kerry               	5.34682E+15         	JTC98LIR4OJ         	41445               
29068               	Eleanor             	5.31806E+15         	AZJ15MOC4JH         	25954               
81225               	Aretha              	5.15414E+15         	NZA10DHC0UC         	98971               
4741                	Aretha              	5.54162E+15         	QFR10DVF0YC         	81224               
96923               	Lillith             	5.53772E+15         	DRS47ZTK6EX         	52934               
78576               	Tatum               	5.21301E+15         	UUI24ETO5RX         	54208               
45580               	Chava               	5.20005E+15         	OZR65RRB4WT         	24253               
17362               	Deanna              	5.1784E+15          	EGJ79XOJ5WQ         	10976               
91894               	Lars                	5.20901E+15         	AHV90FSH3LT         	28954               
79510               	Oliver              	5.56789E+15         	AKK86APV9OJ         	51254               
37844               	Norman              	5.27569E+15         	TSL77EFE5CU         	41445               
3690                	Fredericka          	5.23796E+15         	KWS16HLN9RN         	25954               
68750               	Sophia              	5.27013E+15         	MTR88ABG4QR         	98971               
75479               	Heather             	5.50423E+15         	UIF22DNS1MB         	81224               
85283               	Lee                 	5.21168E+15         	LNV39MHQ2ZH         	52934               
47198               	Emmanuel            	5.2458E+15          	KAY63ODA8JL         	54208               
16853               	Eden                	5.4018E+15          	UZQ25JVE4LN         	24253               
72864               	Chancellor          	5.15157E+15         	ORY94JYK3IZ         	10976               
66277               	Xanthus             	5.56739E+15         	RYQ54MXG7DI         	28954               
74231               	Hayes               	5.41879E+15         	QQD28HNC6DP         	51254               
51516               	Lucy                	5.49491E+15         	LIG34AWS8SH         	41445               
\.


--
-- Data for Name: debit_card; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.debit_card (account_number, expiry_date, debit_card_status) FROM stdin;
5.43593E+15         	2030-09-09	t
5.57274E+15         	2030-10-31	t
5.12088E+15         	2029-11-29	f
5.43859E+15         	2031-03-11	t
5.37984E+15         	2029-02-21	f
5.19309E+15         	2021-03-27	t
5.29511E+15         	2029-07-11	f
5.29656E+15         	2028-08-18	f
5.39921E+15         	2022-08-10	f
5.5909E+15          	2033-10-09	f
5.58388E+15         	2032-10-26	f
5.51585E+15         	2020-09-04	f
5.40256E+15         	2027-07-29	t
5.45129E+15         	2032-02-03	t
5.35408E+15         	2028-03-09	t
5.33129E+15         	2023-03-16	t
5.44355E+15         	2029-04-25	t
5.45387E+15         	2031-04-18	f
5.32034E+15         	2022-01-10	t
5.17317E+15         	2020-10-25	t
5.27297E+15         	2029-01-23	t
5.23303E+15         	2028-08-27	t
5.19242E+15         	2033-01-05	t
5.26682E+15         	2030-01-28	f
5.54189E+15         	2027-12-21	f
5.59783E+15         	2026-10-20	t
5.50673E+15         	2027-09-18	t
5.21178E+15         	2029-05-19	t
5.12286E+15         	2032-02-20	f
5.42259E+15         	2026-09-17	t
5.24686E+15         	2032-07-19	t
5.52315E+15         	2026-12-20	t
5.41355E+15         	2032-08-01	f
5.28728E+15         	2024-12-30	t
5.33399E+15         	2022-08-29	t
5.17497E+15         	2027-06-12	t
5.42549E+15         	2025-06-13	f
5.19965E+15         	2029-10-12	t
5.24415E+15         	2028-04-04	f
5.11899E+15         	2028-03-19	f
5.20861E+15         	2033-04-03	f
5.59799E+15         	2028-12-25	t
5.21491E+15         	2030-11-26	f
5.34633E+15         	2021-11-03	f
5.29166E+15         	2028-06-02	t
5.24125E+15         	2027-04-07	t
5.51983E+15         	2026-06-17	f
5.15732E+15         	2022-03-17	t
5.48996E+15         	2031-10-01	f
5.48911E+15         	2032-01-21	f
5.58899E+15         	2022-03-17	f
5.12366E+15         	2022-07-02	t
5.13689E+15         	2024-01-03	f
5.22086E+15         	2032-07-17	t
5.13054E+15         	2030-07-12	f
5.10223E+15         	2021-03-27	t
5.55436E+15         	2022-08-04	t
5.43986E+15         	2027-01-29	t
5.31086E+15         	2027-02-22	t
5.12735E+15         	2022-12-22	f
5.52871E+15         	2020-06-11	f
5.28326E+15         	2023-10-29	f
5.54925E+15         	2021-11-09	t
5.2668E+15          	2025-10-30	f
5.19175E+15         	2020-07-09	t
5.17919E+15         	2022-11-23	t
5.35645E+15         	2029-01-16	f
5.50605E+15         	2021-02-20	t
5.19764E+15         	2021-10-12	f
5.48052E+15         	2022-06-20	t
5.10153E+15         	2027-02-20	f
5.12909E+15         	2033-10-03	f
5.55847E+15         	2029-09-26	f
5.31603E+15         	2025-05-02	t
5.18561E+15         	2020-07-18	f
5.30618E+15         	2021-01-18	f
5.13861E+15         	2026-11-03	t
5.52918E+15         	2028-05-12	t
5.14233E+15         	2031-07-30	t
5.29565E+15         	2032-07-29	f
5.51685E+15         	2021-09-21	f
5.34252E+15         	2021-01-13	f
5.16679E+15         	2020-05-29	t
5.47116E+15         	2030-07-19	t
5.51033E+15         	2024-09-27	t
5.50933E+15         	2025-08-13	t
5.2983E+15          	2027-09-09	f
5.26903E+15         	2031-01-04	t
5.10219E+15         	2032-05-10	f
5.358E+15           	2030-10-28	f
5.35899E+15         	2021-11-08	t
5.2215E+15          	2021-09-06	t
5.18903E+15         	2029-03-04	t
5.23525E+15         	2020-06-06	f
5.19227E+15         	2028-10-26	f
5.43205E+15         	2026-10-22	t
5.13392E+15         	2030-10-03	f
5.40563E+15         	2026-01-03	f
5.21621E+15         	2030-09-13	f
5.57094E+15         	2019-12-17	t
\.


--
-- Data for Name: encashment_details_1; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.encashment_details_1 (payment_id, account_number, cheque_number) FROM stdin;
I9F5U6              	5.43593E+15         	LLI81FEO7UO         
W3X3O9              	5.57274E+15         	RWB72EUE6VR         
K5Y6K3              	5.12088E+15         	IYQ39LBE4CM         
G0X3H1              	5.43859E+15         	XBD29WRF6VU         
Y5B5Z6              	5.37984E+15         	RAA59GTK0OO         
G0O5L2              	5.43593E+15         	JZX14LZT0KI         
N4G0M9              	5.57274E+15         	YSV36VXD4LE         
I2A7P7              	5.12088E+15         	QKK28ZZR6NH         
I9W4G9              	5.43859E+15         	NDK73PJD1ZY         
D8S4Q7              	5.37984E+15         	SWZ79VVG6ZS         
F2K8W8              	5.43593E+15         	NSS76FYS8NO         
V9Y2P4              	5.57274E+15         	JGG09WRI3AT         
L9H4I9              	5.12088E+15         	VEA59IZJ3BR         
W6Y6N8              	5.43859E+15         	NWZ51LSP1FB         
A3N4C1              	5.37984E+15         	CII11RVG5FF         
K9M8O5              	5.43593E+15         	VQQ45RRI4QH         
A2A5Z0              	5.57274E+15         	XFW54PDR6TB         
I5R0W6              	5.12088E+15         	UWA73VSG3OI         
R1B9Y6              	5.43859E+15         	VFY44UOZ4XH         
M0L4X2              	5.37984E+15         	KHY25JYW3SR         
C0X3L0              	5.43593E+15         	LCZ13ZXE2MD         
Q4Q0J0              	5.57274E+15         	ERN34VVW2ZM         
H0Y0J4              	5.12088E+15         	YTK78GYQ3GB         
O3K8F0              	5.43859E+15         	IBK33YCL3OL         
F3U7T8              	5.37984E+15         	OBD99QUP0YR         
M4R5E0              	5.43593E+15         	IMJ06EJT0ZK         
U6H1J5              	5.57274E+15         	NCV22JOJ6GI         
Z3Y1X4              	5.12088E+15         	DGT66XQR7LS         
P8R7H0              	5.43859E+15         	UUH47TPX8JE         
K8H4V1              	5.37984E+15         	KNP58RZH6PD         
J1U8V8              	5.43593E+15         	BQD29WZE9VF         
T7C3D4              	5.57274E+15         	IXJ75DQY6WR         
O8B1F8              	5.12088E+15         	XHY84QQP8OK         
T5T7L0              	5.43859E+15         	OGC78EOW2EA         
Q7G2N6              	5.37984E+15         	ZVT62JDM2GB         
E5E8P9              	5.43593E+15         	CYB99CHF3QQ         
M5J4B7              	5.57274E+15         	KFV77XSH0MH         
T4L4N7              	5.12088E+15         	WLB56YTJ2SA         
D3E0P5              	5.43859E+15         	RDL55NBS4HQ         
H0F8N0              	5.37984E+15         	EBU85LGC1PJ         
K1R9A2              	5.43593E+15         	QOZ85NMW3ZM         
B9X6S3              	5.57274E+15         	ZCJ04UJT2MV         
K3Y9I3              	5.12088E+15         	YAX70CFF0OG         
F0A0K4              	5.43859E+15         	CNU18KPU0GX         
E0X2V5              	5.37984E+15         	DNN54PKN6DM         
M3G7I8              	5.43593E+15         	GME47NGB1AP         
L9B0B5              	5.57274E+15         	CSE55OOH2BI         
G7H1V8              	5.12088E+15         	EOX42XSD3FY         
E4W5G5              	5.43859E+15         	UED08OHL1WR         
D1S2L7              	5.37984E+15         	GGY25DNY8RW         
\.


--
-- Data for Name: encashment_details_2; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.encashment_details_2 (payment_id, amount) FROM stdin;
I9F5U6              	100
W3X3O9              	200
K5Y6K3              	300
G0X3H1              	400
Y5B5Z6              	500
G0O5L2              	100
N4G0M9              	200
I2A7P7              	300
I9W4G9              	400
D8S4Q7              	500
F2K8W8              	100
V9Y2P4              	200
L9H4I9              	300
W6Y6N8              	400
A3N4C1              	500
K9M8O5              	100
A2A5Z0              	200
I5R0W6              	300
R1B9Y6              	400
M0L4X2              	500
C0X3L0              	100
Q4Q0J0              	200
H0Y0J4              	300
O3K8F0              	400
F3U7T8              	500
M4R5E0              	100
U6H1J5              	200
Z3Y1X4              	300
P8R7H0              	400
K8H4V1              	500
J1U8V8              	100
T7C3D4              	200
O8B1F8              	300
T5T7L0              	400
Q7G2N6              	500
E5E8P9              	100
M5J4B7              	200
T4L4N7              	300
D3E0P5              	400
H0F8N0              	500
K1R9A2              	100
B9X6S3              	200
K3Y9I3              	300
F0A0K4              	400
E0X2V5              	500
M3G7I8              	100
L9B0B5              	200
G7H1V8              	300
E4W5G5              	400
D1S2L7              	500
\.


--
-- Data for Name: login_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.login_details (customer_id, pass_word) FROM stdin;
51516               	LIG34AWS8SH         
85820               	ZPM15GCY0NN         
92538               	KRL76SFI2DY         
31554               	COO20HJL0EL         
94914               	KKY80PRB3NV         
86418               	ELF56ARE6VV         
9140                	GAN33GXE2CC         
6569                	LWM84XWX4ED         
4118                	ZHV98DXQ1GR         
11854               	NUR57CFQ8TN         
85671               	HTD64LOT9VC         
78933               	DWJ23BJW6FB         
81129               	DXA61UDX6SB         
76420               	RHW81ZSJ1QX         
15936               	UFC24IAL2MG         
38662               	VRN35BUU9WS         
46928               	LBZ68MZQ0IJ         
71405               	EUZ14GCE8EC         
8886                	GGV12TZQ3HS         
76862               	VZV23UBU5LU         
76226               	QFB17PBG3TD         
92176               	BEN50OKQ8OU         
86002               	PQC22FLY3UM         
91584               	NTG25HLF1YT         
16947               	OKM06AZZ3BP         
53427               	WNY82IBM1MX         
92741               	KUD15GNF5WK         
21939               	QSO89PHV9UF         
30296               	TVL03EXT5CZ         
40703               	CMQ77FEH9CA         
74830               	UIY26VBW4VO         
60114               	JFH69VLU3DZ         
22880               	TBP32RZY1BK         
21407               	GNS41ECK7SM         
87766               	BHU50VML6DE         
94472               	QOA93YUQ0QE         
54285               	JUZ73CRG1ZK         
20513               	WKM87EAT8GT         
60024               	AGH55XOP7AF         
6843                	SIB34UEJ3TT         
16516               	YIK57KFX2AW         
9080                	DKK29RKP3CY         
78872               	OBG47NZD3EX         
72988               	NVZ21NPI6CQ         
22453               	QME32DYF4BQ         
17494               	PGM65TBR6OP         
59260               	JXX10YLY8JS         
12752               	UAC41BAA9MO         
56426               	RTW67XLC9HJ         
41891               	XIR06CEZ9XE         
73841               	HMJ64YEM0VZ         
3612                	PTB96ZSB4GB         
74765               	WFI11UQO8TG         
47267               	IZI76UOG1OD         
53658               	XWN28UWM4EO         
51235               	PMW40OTH8XM         
40594               	YXQ52RJC3PE         
78385               	GIG12KUC2EK         
88084               	IHW82RFR7ZU         
66912               	ACM70ZNF7NZ         
89765               	TRB17HRO0XV         
11486               	KGR16KJQ8WR         
17189               	GFZ44VTA8CS         
58014               	AXU23RKA4RJ         
5381                	BLV96JSF7DT         
9264                	FPQ65ROB3MA         
44905               	OWS97HAE0ZM         
33940               	MKX42HQS5AJ         
56805               	LON25JZD4LW         
13746               	VJV34DIB6HE         
93653               	JHM07VTR3YJ         
77716               	TRM69BAV7YO         
60011               	IGD99RZI7OL         
57351               	NHL83XAE7BF         
31360               	RFP21VQE4VI         
67750               	WXV22JWC2HZ         
14080               	JTX19PAO5ZL         
97390               	ZAF92QWD6CK         
36135               	FLJ20DWY2ZU         
96109               	AQC59XJX8JW         
66061               	JTC98LIR4OJ         
29068               	AZJ15MOC4JH         
81225               	NZA10DHC0UC         
4741                	QFR10DVF0YC         
96923               	DRS47ZTK6EX         
78576               	UUI24ETO5RX         
45580               	OZR65RRB4WT         
17362               	EGJ79XOJ5WQ         
91894               	AHV90FSH3LT         
79510               	AKK86APV9OJ         
37844               	TSL77EFE5CU         
3690                	KWS16HLN9RN         
68750               	MTR88ABG4QR         
75479               	UIF22DNS1MB         
85283               	LNV39MHQ2ZH         
47198               	KAY63ODA8JL         
16853               	UZQ25JVE4LN         
72864               	ORY94JYK3IZ         
66277               	RYQ54MXG7DI         
74231               	QQD28HNC6DP         
\.


--
-- Data for Name: payment_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_details (account_number, payment_id, beneficiary_account_number, amount) FROM stdin;
5.43593E+15         	T6K3O2              	5.57274E+15         	100
5.57274E+15         	W9P1R8              	5.12088E+15         	200
5.12088E+15         	R1Q3E3              	5.43859E+15         	300
5.43859E+15         	S8D9F0              	5.37984E+15         	400
5.37984E+15         	G8C0J8              	5.43593E+15         	500
5.43593E+15         	K9R3X6              	5.57274E+15         	100
5.57274E+15         	J7W8Z6              	5.12088E+15         	200
5.12088E+15         	G0U2O6              	5.43859E+15         	300
5.43859E+15         	G8Z5L8              	5.37984E+15         	400
5.37984E+15         	F9T9O2              	5.43593E+15         	500
5.43593E+15         	F1D2B4              	5.57274E+15         	100
5.57274E+15         	C3E0E1              	5.12088E+15         	200
5.12088E+15         	S5R5P9              	5.43859E+15         	300
5.43859E+15         	T3O7H3              	5.37984E+15         	400
5.37984E+15         	I1O3K1              	5.43593E+15         	500
5.43593E+15         	N9P3K1              	5.57274E+15         	100
5.57274E+15         	X6T5X8              	5.12088E+15         	200
5.12088E+15         	Z3X1R3              	5.43859E+15         	300
5.43859E+15         	L5S4F8              	5.37984E+15         	400
5.37984E+15         	P4Q5T3              	5.43593E+15         	500
5.43593E+15         	T2V9V6              	5.57274E+15         	100
5.57274E+15         	G4M6W1              	5.12088E+15         	200
5.12088E+15         	G6P5Z8              	5.43859E+15         	300
5.43859E+15         	E3M9V1              	5.37984E+15         	400
5.37984E+15         	T3Y4F0              	5.43593E+15         	500
5.43593E+15         	Q7K9D9              	5.57274E+15         	100
5.57274E+15         	W9Z4E5              	5.12088E+15         	200
5.12088E+15         	H7Z2A2              	5.43859E+15         	300
5.43859E+15         	Q8F8F7              	5.37984E+15         	400
5.37984E+15         	X6L5D1              	5.43593E+15         	500
5.43593E+15         	H1U9S3              	5.57274E+15         	100
5.57274E+15         	F5M6U3              	5.12088E+15         	200
5.12088E+15         	U7N7M2              	5.43859E+15         	300
5.43859E+15         	D4P6Z1              	5.37984E+15         	400
5.37984E+15         	S6N0R4              	5.43593E+15         	500
5.43593E+15         	W2H8S0              	5.57274E+15         	100
5.57274E+15         	D0R3F4              	5.12088E+15         	200
5.12088E+15         	R1O2U5              	5.43859E+15         	300
5.43859E+15         	M3F8D0              	5.37984E+15         	400
5.37984E+15         	M2L6J9              	5.43593E+15         	500
5.43593E+15         	C9O9W1              	5.57274E+15         	100
5.57274E+15         	R1Y1D9              	5.12088E+15         	200
5.12088E+15         	O3N7Z1              	5.43859E+15         	300
5.43859E+15         	E7Z9S1              	5.37984E+15         	400
5.37984E+15         	H8E2A2              	5.43593E+15         	500
5.43593E+15         	Q6X1C0              	5.57274E+15         	100
5.57274E+15         	O1P7O7              	5.12088E+15         	200
5.12088E+15         	M6A6S2              	5.43859E+15         	300
5.43859E+15         	G5D4A3              	5.37984E+15         	400
5.37984E+15         	A5B0O0              	5.43593E+15         	500
\.


--
-- Data for Name: recurring_payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recurring_payment (account_number, beneficiary_account, recurring_amount) FROM stdin;
5.43593E+15         	5.45679E+15         	30791
5.57274E+15         	5.301E+15           	43848
5.12088E+15         	5.45619E+15         	48588
5.43859E+15         	5.2454E+15          	77818
5.37984E+15         	5.4677E+15          	27908
5.19309E+15         	5.34682E+15         	97554
5.29511E+15         	5.31806E+15         	21016
5.29656E+15         	5.15414E+15         	49592
5.39921E+15         	5.54162E+15         	78495
5.5909E+15          	5.53772E+15         	16603
5.58388E+15         	5.21301E+15         	14036
5.51585E+15         	5.20005E+15         	71119
5.40256E+15         	5.1784E+15          	1270
5.45129E+15         	5.20901E+15         	74122
5.35408E+15         	5.56789E+15         	45336
5.33129E+15         	5.27569E+15         	46160
5.44355E+15         	5.23796E+15         	76755
5.45387E+15         	5.27013E+15         	78674
5.32034E+15         	5.50423E+15         	33071
5.17317E+15         	5.21168E+15         	64476
5.27297E+15         	5.2458E+15          	98861
5.23303E+15         	5.4018E+15          	6881
5.19242E+15         	5.15157E+15         	33130
5.26682E+15         	5.56739E+15         	4589
5.54189E+15         	5.41879E+15         	35626
5.59783E+15         	5.49491E+15         	31640
5.50673E+15         	5.38545E+15         	87263
5.21178E+15         	5.31162E+15         	17242
5.12286E+15         	5.50156E+15         	24372
5.42259E+15         	5.19405E+15         	85692
5.24686E+15         	5.42207E+15         	74214
5.52315E+15         	5.23442E+15         	76156
5.41355E+15         	5.55956E+15         	87624
5.28728E+15         	5.49162E+15         	36237
5.33399E+15         	5.49767E+15         	50659
5.17497E+15         	5.30496E+15         	36598
5.42549E+15         	5.11282E+15         	44244
5.19965E+15         	5.39836E+15         	81580
5.24415E+15         	5.39174E+15         	81136
5.11899E+15         	5.51626E+15         	68469
5.20861E+15         	5.15456E+15         	83929
5.59799E+15         	5.10448E+15         	66533
5.21491E+15         	5.36235E+15         	22715
5.34633E+15         	5.47807E+15         	17331
5.29166E+15         	5.58912E+15         	15929
5.24125E+15         	5.5477E+15          	69610
5.51983E+15         	5.26919E+15         	49744
5.15732E+15         	5.40458E+15         	90721
5.48996E+15         	5.36624E+15         	29894
5.48911E+15         	5.35535E+15         	57963
5.58899E+15         	5.56073E+15         	6898
5.12366E+15         	5.5287E+15          	30174
5.13689E+15         	5.13087E+15         	91329
5.22086E+15         	5.51376E+15         	2235
5.13054E+15         	5.16201E+15         	42604
5.10223E+15         	5.12068E+15         	91449
5.55436E+15         	5.54169E+15         	83085
5.43986E+15         	5.54368E+15         	82953
5.31086E+15         	5.17858E+15         	47746
5.12735E+15         	5.26106E+15         	80198
5.52871E+15         	5.57907E+15         	17034
5.28326E+15         	5.43578E+15         	25062
5.54925E+15         	5.35128E+15         	13191
5.2668E+15          	5.57859E+15         	59581
5.19175E+15         	5.48076E+15         	39388
5.17919E+15         	5.13853E+15         	25563
5.35645E+15         	5.20306E+15         	23611
5.50605E+15         	5.10896E+15         	51647
5.19764E+15         	5.18179E+15         	8278
5.48052E+15         	5.58657E+15         	40159
5.10153E+15         	5.56223E+15         	78804
5.12909E+15         	5.28488E+15         	24305
5.55847E+15         	5.45708E+15         	64246
5.31603E+15         	5.40601E+15         	77110
5.18561E+15         	5.20495E+15         	75686
5.30618E+15         	5.50436E+15         	23132
5.13861E+15         	5.42734E+15         	90454
5.52918E+15         	5.48978E+15         	17530
5.14233E+15         	5.55668E+15         	9053
5.29565E+15         	5.59333E+15         	24017
5.51685E+15         	5.27759E+15         	55044
5.34252E+15         	5.49754E+15         	391
5.16679E+15         	5.15449E+15         	15453
5.47116E+15         	5.46732E+15         	42178
5.51033E+15         	5.22757E+15         	61514
5.50933E+15         	5.19188E+15         	8832
5.2983E+15          	5.11817E+15         	33269
5.26903E+15         	5.55559E+15         	97704
5.10219E+15         	5.46531E+15         	49581
5.358E+15           	5.45579E+15         	16215
5.35899E+15         	5.29791E+15         	47578
5.2215E+15          	5.42825E+15         	61188
5.18903E+15         	5.52935E+15         	18329
5.23525E+15         	5.54509E+15         	40246
5.19227E+15         	5.18097E+15         	65714
5.43205E+15         	5.29132E+15         	94019
5.13392E+15         	5.15762E+15         	81067
5.40563E+15         	5.56492E+15         	21358
5.21621E+15         	5.5052E+15          	31061
5.57094E+15         	5.26357E+15         	97591
\.


--
-- Data for Name: service_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.service_provider (service_provider_id, service_provider_name, audit_details, auditor_id, administrator_id, customer_id) FROM stdin;
5.52112E+15         	Quinn               	9.00	41445               	6591280989          	51516               
5.22059E+15         	Jin                 	3.00	25954               	3687598091          	85820               
5.54259E+15         	Timothy             	9.00	98971               	8600365895          	92538               
5.58024E+15         	Cody                	1.00	81224               	3156620572          	31554               
5.23787E+15         	Macon               	7.00	52934               	9240093888          	94914               
5.12783E+15         	Walter              	2.00	54208               	0772427985          	86418               
5.42011E+15         	Kenyon              	4.00	24253               	8146816319          	9140                
5.56939E+15         	Cooper              	5.00	10976               	3765992793          	6569                
5.54795E+15         	Mia                 	9.00	28954               	6501774679          	4118                
5.23883E+15         	Stuart              	2.00	51254               	5872994732          	11854               
5.19038E+15         	Henry               	5.00	41445               	2999339791          	85671               
5.39923E+15         	Audra               	6.00	25954               	2500608078          	78933               
5.16083E+15         	Quinlan             	7.00	98971               	1175693089          	81129               
5.37629E+15         	Lillith             	6.00	81224               	4383631372          	76420               
5.54082E+15         	Colby               	2.00	52934               	5965202007          	15936               
5.23381E+15         	Chaney              	6.00	54208               	3840737835          	38662               
5.38871E+15         	Wilma               	8.00	24253               	5150633322          	46928               
5.29114E+15         	Florence            	5.00	10976               	6954057699          	71405               
5.51823E+15         	Cameron             	9.00	28954               	6793473624          	8886                
5.52954E+15         	Zane                	3.00	51254               	3076160406          	76862               
5.33452E+15         	Jonah               	3.00	41445               	2927065725          	76226               
5.40079E+15         	Buckminster         	2.00	25954               	7456711857          	92176               
5.27255E+15         	Mara                	8.00	98971               	6602972422          	86002               
5.21646E+15         	Owen                	2.00	81224               	1967701810          	91584               
5.13939E+15         	Orson               	7.00	52934               	4754379096          	16947               
5.13404E+15         	Adam                	9.00	54208               	6591280989          	53427               
5.57911E+15         	Brock               	8.00	24253               	3687598091          	92741               
5.19075E+15         	Jasmine             	3.00	10976               	8600365895          	21939               
5.59892E+15         	Robert              	4.00	28954               	3156620572          	30296               
5.5047E+15          	Kamal               	9.00	51254               	9240093888          	40703               
5.57825E+15         	Cameron             	5.00	41445               	0772427985          	74830               
5.1015E+15          	Gloria              	8.00	25954               	8146816319          	60114               
5.32549E+15         	Uriah               	9.00	98971               	3765992793          	22880               
5.48858E+15         	Hope                	2.00	81224               	6501774679          	21407               
5.21907E+15         	Bernard             	3.00	52934               	5872994732          	87766               
5.21914E+15         	Aurelia             	10.00	54208               	2999339791          	94472               
5.34421E+15         	Keelie              	1.00	24253               	2500608078          	54285               
5.30217E+15         	Emery               	5.00	10976               	1175693089          	20513               
5.31317E+15         	Indira              	2.00	28954               	4383631372          	60024               
5.28526E+15         	Lareina             	7.00	51254               	5965202007          	6843                
5.54095E+15         	Neil                	1.00	41445               	3840737835          	16516               
5.2879E+15          	Baker               	7.00	25954               	5150633322          	9080                
5.51267E+15         	Geoffrey            	9.00	98971               	6954057699          	78872               
5.33379E+15         	Cain                	2.00	81224               	6793473624          	72988               
5.31549E+15         	Kim                 	7.00	52934               	3076160406          	22453               
5.34522E+15         	Serena              	1.00	54208               	2927065725          	17494               
5.43248E+15         	Sade                	5.00	24253               	7456711857          	59260               
5.11597E+15         	Courtney            	4.00	10976               	6602972422          	12752               
5.51124E+15         	Lucas               	8.00	28954               	1967701810          	56426               
5.22529E+15         	Edward              	3.00	51254               	4754379096          	41891               
5.19878E+15         	Giacomo             	8.00	41445               	6591280989          	73841               
5.36329E+15         	Callum              	9.00	25954               	3687598091          	3612                
5.40927E+15         	Uriel               	1.00	98971               	8600365895          	74765               
5.22287E+15         	Raja                	5.00	81224               	3156620572          	47267               
5.43642E+15         	Isabelle            	1.00	52934               	9240093888          	53658               
5.16931E+15         	Martha              	1.00	54208               	0772427985          	51235               
5.11345E+15         	Mohammad            	4.00	24253               	8146816319          	40594               
5.36785E+15         	Elliott             	2.00	10976               	3765992793          	78385               
5.33283E+15         	Clarke              	7.00	28954               	6501774679          	88084               
5.41701E+15         	Allen               	5.00	51254               	5872994732          	66912               
5.24965E+15         	Dennis              	5.00	41445               	2999339791          	89765               
5.24742E+15         	Risa                	7.00	25954               	2500608078          	11486               
5.46847E+15         	Levi                	2.00	98971               	1175693089          	17189               
5.10317E+15         	Melanie             	3.00	81224               	4383631372          	58014               
5.4202E+15          	Lee                 	2.00	52934               	5965202007          	5381                
5.44895E+15         	Noble               	6.00	54208               	3840737835          	9264                
5.40201E+15         	Blossom             	9.00	24253               	5150633322          	44905               
5.36055E+15         	Meghan              	10.00	10976               	6954057699          	33940               
5.37469E+15         	Shannon             	5.00	28954               	6793473624          	56805               
5.52272E+15         	Jelani              	10.00	51254               	3076160406          	13746               
5.39001E+15         	Bruce               	6.00	41445               	2927065725          	93653               
5.45547E+15         	Mariko              	8.00	25954               	7456711857          	77716               
5.10059E+15         	Brennan             	7.00	98971               	6602972422          	60011               
5.41242E+15         	Uma                 	8.00	81224               	1967701810          	57351               
5.57871E+15         	Alan                	2.00	52934               	4754379096          	31360               
5.53877E+15         	Nathan              	10.00	54208               	6591280989          	67750               
5.34102E+15         	Felix               	1.00	24253               	3687598091          	14080               
5.49042E+15         	Tiger               	3.00	10976               	8600365895          	97390               
5.33235E+15         	Kerry               	3.00	28954               	3156620572          	36135               
5.36306E+15         	Edward              	7.00	51254               	9240093888          	96109               
5.45972E+15         	Christian           	9.00	41445               	0772427985          	66061               
5.19605E+15         	Scarlett            	2.00	25954               	8146816319          	29068               
5.48687E+15         	Sonya               	2.00	98971               	3765992793          	81225               
5.35017E+15         	Karleigh            	6.00	81224               	6501774679          	4741                
5.1777E+15          	Rigel               	1.00	52934               	5872994732          	96923               
5.35853E+15         	Buckminster         	10.00	54208               	2999339791          	78576               
5.10381E+15         	Calista             	9.00	24253               	2500608078          	45580               
5.38134E+15         	Chanda              	8.00	10976               	1175693089          	17362               
5.35489E+15         	Ursa                	3.00	28954               	4383631372          	91894               
5.50859E+15         	Alfreda             	4.00	51254               	5965202007          	79510               
5.43871E+15         	Aileen              	4.00	41445               	3840737835          	37844               
5.31827E+15         	Samson              	9.00	25954               	5150633322          	3690                
5.39408E+15         	Cherokee            	10.00	98971               	6954057699          	68750               
5.5114E+15          	Anastasia           	10.00	81224               	6793473624          	75479               
5.26641E+15         	Zenia               	4.00	52934               	3076160406          	85283               
5.29521E+15         	Rose                	4.00	54208               	2927065725          	47198               
5.165E+15           	Grant               	9.00	24253               	7456711857          	16853               
5.22928E+15         	Cullen              	5.00	10976               	6602972422          	72864               
5.32008E+15         	Orson               	4.00	28954               	1967701810          	66277               
5.1087E+15          	Louis               	8.00	51254               	4754379096          	74231               
\.


--
-- Name: account_details_1 account_details_1_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_details_1
    ADD CONSTRAINT account_details_1_pkey PRIMARY KEY (account_number);


--
-- Name: account_details_2 account_details_2_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_details_2
    ADD CONSTRAINT account_details_2_pkey PRIMARY KEY (account_number);


--
-- Name: account_details_3 account_details_3_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_details_3
    ADD CONSTRAINT account_details_3_pkey PRIMARY KEY (account_number);


--
-- Name: account_type account_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_type
    ADD CONSTRAINT account_type_pkey PRIMARY KEY (customer_id, account_number);


--
-- Name: administrator administrator_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administrator
    ADD CONSTRAINT administrator_pkey PRIMARY KEY (administrator_id);


--
-- Name: auditor auditor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditor
    ADD CONSTRAINT auditor_pkey PRIMARY KEY (auditor_id);


--
-- Name: bank bank_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bank
    ADD CONSTRAINT bank_pkey PRIMARY KEY (bank_name);


--
-- Name: cheque_details cheque_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cheque_details
    ADD CONSTRAINT cheque_details_pkey PRIMARY KEY (account_number);


--
-- Name: credit_card credit_card_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_card
    ADD CONSTRAINT credit_card_pkey PRIMARY KEY (account_number);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- Name: debit_card debit_card_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.debit_card
    ADD CONSTRAINT debit_card_pkey PRIMARY KEY (account_number);


--
-- Name: login_details login_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_details
    ADD CONSTRAINT login_details_pkey PRIMARY KEY (customer_id);


--
-- Name: encashment_details_1 payment_details_1_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.encashment_details_1
    ADD CONSTRAINT payment_details_1_pkey PRIMARY KEY (payment_id);


--
-- Name: encashment_details_2 payment_details_2_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.encashment_details_2
    ADD CONSTRAINT payment_details_2_pkey PRIMARY KEY (payment_id);


--
-- Name: payment_details payment_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_details
    ADD CONSTRAINT payment_details_pkey PRIMARY KEY (payment_id);


--
-- Name: recurring_payment recurring_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_payment
    ADD CONSTRAINT recurring_payment_pkey PRIMARY KEY (account_number);


--
-- Name: service_provider service_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_provider
    ADD CONSTRAINT service_provider_pkey PRIMARY KEY (service_provider_id, customer_id);


--
-- Name: account_details_3 bal; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER bal BEFORE INSERT ON public.account_details_3 FOR EACH ROW EXECUTE PROCEDURE public.func_3();


--
-- Name: administrator def_bank; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER def_bank AFTER INSERT ON public.administrator FOR EACH ROW EXECUTE PROCEDURE public.func_1();


--
-- Name: account_type account_type_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_type
    ADD CONSTRAINT account_type_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.account_details_1(account_number) ON DELETE CASCADE;


--
-- Name: account_type account_type_administrator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_type
    ADD CONSTRAINT account_type_administrator_id_fkey FOREIGN KEY (administrator_id) REFERENCES public.administrator(administrator_id) ON DELETE CASCADE;


--
-- Name: account_type account_type_auditor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_type
    ADD CONSTRAINT account_type_auditor_id_fkey FOREIGN KEY (auditor_id) REFERENCES public.auditor(auditor_id) ON DELETE CASCADE;


--
-- Name: account_type account_type_bank_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_type
    ADD CONSTRAINT account_type_bank_name_fkey FOREIGN KEY (bank_name) REFERENCES public.bank(bank_name) ON DELETE CASCADE;


--
-- Name: account_type account_type_service_provider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_type
    ADD CONSTRAINT account_type_service_provider_id_fkey FOREIGN KEY (service_provider_id, customer_id) REFERENCES public.service_provider(service_provider_id, customer_id) ON DELETE CASCADE;


--
-- Name: administrator administrator_auditor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administrator
    ADD CONSTRAINT administrator_auditor_id_fkey FOREIGN KEY (auditor_id) REFERENCES public.auditor(auditor_id);


--
-- Name: administrator administrator_bank_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administrator
    ADD CONSTRAINT administrator_bank_name_fkey FOREIGN KEY (bank_name) REFERENCES public.bank(bank_name);


--
-- Name: cheque_details cheque_details_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cheque_details
    ADD CONSTRAINT cheque_details_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.account_details_1(account_number) ON DELETE CASCADE;


--
-- Name: credit_card credit_card_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_card
    ADD CONSTRAINT credit_card_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.account_details_1(account_number) ON DELETE CASCADE;


--
-- Name: customer customer_auditor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_auditor_id_fkey FOREIGN KEY (auditor_id) REFERENCES public.auditor(auditor_id);


--
-- Name: debit_card debit_card_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.debit_card
    ADD CONSTRAINT debit_card_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.account_details_2(account_number) ON DELETE CASCADE;


--
-- Name: login_details login_details_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_details
    ADD CONSTRAINT login_details_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON DELETE CASCADE;


--
-- Name: encashment_details_1 payment_details_1_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.encashment_details_1
    ADD CONSTRAINT payment_details_1_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.cheque_details(account_number) ON DELETE CASCADE;


--
-- Name: payment_details payment_details_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_details
    ADD CONSTRAINT payment_details_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.cheque_details(account_number) ON DELETE CASCADE;


--
-- Name: recurring_payment recurring_payment_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_payment
    ADD CONSTRAINT recurring_payment_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.account_details_3(account_number) ON DELETE CASCADE;


--
-- Name: service_provider service_provider_administrator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_provider
    ADD CONSTRAINT service_provider_administrator_id_fkey FOREIGN KEY (administrator_id) REFERENCES public.administrator(administrator_id);


--
-- Name: service_provider service_provider_auditor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_provider
    ADD CONSTRAINT service_provider_auditor_id_fkey FOREIGN KEY (auditor_id) REFERENCES public.auditor(auditor_id);


--
-- Name: service_provider service_provider_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_provider
    ADD CONSTRAINT service_provider_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);


--
-- PostgreSQL database dump complete
--

