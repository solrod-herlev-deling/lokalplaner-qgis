CREATE SCHEMA IF NOT EXISTS lokalplan;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE EXTENSION IF NOT EXISTS POSTGIS;

SET search_path TO lokalplan, public;


/*
  ╔════════════════════════════════════════════════════════╗
  ║ Konventioner:                                          ║
  ╠════════════════════════════════════════════════════════╣
  ║ kolonnenavne fra plansystem er skrevet med stort,      ║
  ║ andre kolonnenavne er med småt.                        ║
  ║                                                        ║
  ╚════════════════════════════════════════════════════════╝
*/

/*
####################################################
#  Opslagstabeller                                 #
####################################################
*/

/* Korttyper */
DROP TABLE IF EXISTS korttype CASCADE;
CREATE TABLE korttype
(
  korttype_id integer NOT NULL,
  korttype_tekst varchar(20),
  CONSTRAINT korttype_id_pkey PRIMARY KEY (korttype_id)
);

/* Plangrænser */
DROP TABLE IF EXISTS planstatus CASCADE;
CREATE TABLE planstatus
(
  planstatus_id integer NOT NULL,
  planstatus_tekst varchar(20),
  CONSTRAINT planstatus_id_pkey PRIMARY KEY (planstatus_id)
);
INSERT INTO planstatus (planstatus_id, planstatus_tekst) VALUES
  (1,'kladde'),
  (2,'forslag'),
  (3,'vedtaget'),
  (4,'aflyst'),
  (7,'slettet'); /* Slettet = planen er slettet, og ikke: den har været gældende som aflyst indikerer. Skal vi have en kladdestatus, der gør planen privat - dvs. ikke kommer på teknisk kort? Måske en opdater status-knap, der med det samme giver samme status som i plansystem.*/

/* Byggeri */

/* Arealudlæg */
DROP TABLE IF EXISTS areal_udlaeg_type CASCADE;
CREATE TABLE areal_udlaeg_type
(
  areal_udlaeg_type_id serial NOT NULL,
  typenavn character varying,
  CONSTRAINT areal_udlaeg_type_pkey PRIMARY KEY (areal_udlaeg_type_id)
);

/* Zonestatus, Plantype */

DROP TABLE IF EXISTS lokalplandelomraade_fzone CASCADE;
CREATE TABLE lokalplandelomraade_fzone
(
  zonekode integer,
  zonetekst varchar(20),
  CONSTRAINT lokalplandelomraade_fzone_pkey PRIMARY KEY (zonekode)
);
INSERT INTO lokalplandelomraade_fzone (zonekode,zonetekst) VALUES
  (1,'Byzone'),
  (2,'Landzone'),
  (3,'Sommerhusområde');

DROP TABLE IF EXISTS lokalplanomraade_zone CASCADE;
CREATE TABLE lokalplanomraade_zone
(
  zonekode integer,
  zonetekst varchar(50),
  CONSTRAINT lokalplanomraade_zone_pkey PRIMARY KEY (zonekode)
);
INSERT INTO lokalplanomraade_zone (zonekode,zonetekst) VALUES
  (1,'Byzone'),
  (2,'Landzone'),
  (3,'Sommerhusområde'),
  (4,'Byzone og landzone'),
  (5,'Sommerhusområde og landzone'),
  (6,'Byzone og sommerhusområde'),
  (7,'Byzone, landzone og sommerhusområde');

DROP TABLE IF EXISTS lokalplan_plantype CASCADE;
CREATE TABLE lokalplan_plantype
(
  plantypekode decimal(3,1),
  plantypetekst varchar(30),
  CONSTRAINT lokalplan_plantypekode_pkey PRIMARY KEY (plantypekode)
);
INSERT INTO lokalplan_plantype (plantypekode,plantypetekst) VALUES
  (20.1, 'Lokalplaner'),
  (20.2, 'Byplanvedtægt'),
  (20.3, 'Temalokalplaner');

DROP TABLE IF EXISTS delomraade_plantype CASCADE;
CREATE TABLE delomraade_plantype
(
  plantypekode decimal(3,1),
  plantypetekst varchar(30),
  CONSTRAINT delomraade_plantype_pkey PRIMARY KEY (plantypekode)
);
INSERT INTO delomraade_plantype (plantypekode,plantypetekst) VALUES
  (30.1,'Lokalplan-delområde'),
  (30.2,'Byplanvedtægt-delområde'),
  (30.3,'Temalokalplan-delområde');


DROP TABLE IF EXISTS generel_anvendelse CASCADE;
CREATE TABLE generel_anvendelse
(
  generel_anvendelseskode integer,
  generel_anvendelsestekst varchar(35),
  CONSTRAINT generel_anvendelseskode_pkey PRIMARY KEY (generel_anvendelseskode)
);
INSERT INTO generel_anvendelse (generel_anvendelseskode,generel_anvendelsestekst) VALUES
  (11, '11 - Boligområde'),
  (21, '21 - Blandet bolig og erhverv'),
  (31, '31 - Erhvervsområde'),
  (41, '41 - Centerområde'),
  (51, '51 - Rekreativt område'),
  (61, '61 - Sommerhusområde'),
  (71, '71 - Område til offentlige formål'),
  (81, '81 - Tekniske anlæg'),
  (91, '91 - Landområde'),
  (96, '96 - Andet');

DROP TABLE IF EXISTS specifik_anvendelse CASCADE;
CREATE TABLE specifik_anvendelse
(
  specifik_anvendelseskode integer,
  specifik_anvendelsestekst varchar(65),
  CONSTRAINT specifik_anvendelseskode_pkey PRIMARY KEY (specifik_anvendelseskode)
);
INSERT INTO specifik_anvendelse (specifik_anvendelseskode,specifik_anvendelsestekst) VALUES
  (1100, '1100 - Boligområde'),
  (1110, '1110 - Boligområde - Åben lav'),
  (1120, '1120 - Boligområde - Tæt lav'),
  (1130, '1130 - Etagebolig'),
  (1140, '1140 - Blandet boligområde'),
  (2110, '2110 - Blandet byområde'),
  (2120, '2120 - Landsbyområde'),
  (2130, '2130 - Jordbrugsparceller'),
  (2140, '2140 - Blandet bolig og erhverv'),
  (3110, '3110 - Kontor og serviceerhverv'),
  (3120, '3120 - Lettere industri'),
  (3130, '3130 - Tungere industri'),
  (3140, '3140 - Industri med særlige beliggenhedskrav'),
  (3150, '3150 - Havneerhverv'),
  (3160, '3160 - Erhvervsområde'),
  (4110, '4110 - Bycenter'),
  (4120, '4120 - Bydelscenter'),
  (4130, '4130 - Mindre butiksområder'),
  (4140, '4140 - Område til butiksformål'),
  (4150, '4150 - Skilte/facade regulering'),
  (4160, '4160 - Bygningsbevarende reguleringer'),
  (5110, '5110 - Rekreativt grønt område'),
  (5111, '5111 - Kolonihaver'),
  (5120, '5120 - Idrætsanlæg'),
  (5121, '5121 - Golfbaner'),
  (5122, '5122 - Støjende fritidsanlæg'),
  (5123, '5123 - Lystbådehavn'),
  (5130, '5130 - Feriecentre'),
  (5131, '5131 - Campingplads'),
  (5140, '5140 - Forlystelsesanlæg'),
  (5150, '5150 - Rekreativt område'),
  (6110, '6110 - Sommerhusområde'),
  (7110, '7110 - Uddannelsesinstitutioner'),
  (7120, '7120 - Sundhedsinstitutioner'),
  (7130, '7130 - Sociale institutioner'),
  (7140, '7140 - Kulturelle institutioner'),
  (7150, '7150 - Administration'),
  (7160, '7160 - Kirker og kirkegårde'),
  (7170, '7170 - Område til offentlige formål'),
  (8110, '8110 - Forsyningsanlæg'),
  (8111, '8111 - Vindmølleanlæg'),
  (8120, '8120 - Deponeringsanlæg'),
  (8130, '8130 - Rensningsanlæg'),
  (8140, '8140 - Trafikanlæg'),
  (8150, '8150 - Tekniske anlæg'),
  (8160, '8160 - Biogasanlæg'),
  (9110, '9110 - Jordbrugsområde'),
  (9120, '9120 - Naturområde'),
  (9130, '9130 - Militærområde'),
  (9140, '9140 - Råstofområde'),
  (9150, '9150 - Landområder'),
  (9610, '9610 - Andet');

DROP TABLE IF EXISTS konkret_anvendelse CASCADE;
CREATE TABLE konkret_anvendelse
(
  konkret_anvendelseskode integer,
  konkret_anvendelsestekst varchar(65),
  CONSTRAINT konkret_anvendelseskode_pkey PRIMARY KEY (konkret_anvendelseskode)
);
INSERT INTO konkret_anvendelse (konkret_anvendelseskode,konkret_anvendelsestekst) VALUES
  (1, 'Åben lav bolig'),
  (2, 'Åben lav fremherskende'),
  (4, 'Tæt lav'),
  (5, 'Tæt lav fremherskende'),
  (7, 'Etagebolig'),
  (8, 'Etagebolig fremherskende'),
  (10, 'Blanding af boligtyper'),
  (12, 'Blandet bolig og erhvervsbebyggelse'),
  (13, 'Landsbybebyggelse'),
  (15, 'Jordbrugsparceller'),
  (20, 'Fælleshus/forsamlingshus'),
  (30, 'Mindre butiksareal (samlet under 1000 m²)'),
  (32, 'Større butiksareal (samlet over 1000m²)'),
  (35, 'Butiksgade blandet med bolig'),
  (40, 'Opholdsareal i tilknytning til boligområde'),
  (41, 'Fælles friareal i tilknytning til flere boligbebyggelser'),
  (42, 'Legeplads'),
  (43, 'Bypark'),
  (44, 'Grøn kile'),
  (45, 'Branddam/gadekær'),
  (46, 'Udendørsscene/amfiteater'),
  (50, 'Parkeringsareal'),
  (51, 'Lastbilparkering'),
  (52, 'Vejareal'),
  (60, 'Fodboldbane'),
  (61, 'Tennisbane'),
  (63, 'Motorsportsanlæg'),
  (65, 'Skydebane'),
  (67, 'Lystbådehavn'),
  (69, 'Golfbane'),
  (75, 'Andre idrætsanlæg'),
  (80, 'Forlystelsespark'),
  (82, 'Svømmehal/vandland'),
  (85, 'Dyrepark/ZOO'),
  (90, 'Hotel'),
  (91, 'Kursus og konferencecenter'),
  (92, 'Vandrerhjem'),
  (93, 'Feriehusbebyggelse'),
  (97, 'Sommerhuse'),
  (98, 'Campingplads'),
  (99, 'Lejrplads'),
  (110, 'Kontorerhverv og offentlig administration'),
  (111, 'Kontor og serviceerhverv'),
  (113, 'Kontor og serviceerhverv med detailhandel'),
  (115, 'Letter industri'),
  (118, 'Tungere industri'),
  (125, 'Industri med særlige beliggenhedskrav'),
  (130, 'Havneerhverv'),
  (140, 'Kommunikationsanlæg (mobiltelemaster mv.)'),
  (145, 'Højspændingstracé'),
  (146, 'Forsyningsledning'),
  (160, 'Skole'),
  (162, 'Gymnasium'),
  (165, 'Universitet'),
  (168, 'Anden videregående uddannelse'),
  (175, 'Højskole'),
  (190, 'Daginstitution'),
  (200, 'Hospital'),
  (210, 'Ældrecenter'),
  (212, 'Ældreboliger'),
  (220, 'Anden social institution'),
  (230, 'Museum'),
  (235, 'Teater/kulturhus'),
  (240, 'Kirke'),
  (241, 'Kirkegård'),
  (250, 'Kraftvarmeværk'),
  (251, 'Kraftværk'),
  (252, 'Halmkraftværk'),
  (256, 'Vindmølleanlæg'),
  (270, 'Losseplads'),
  (272, 'Containerplads'),
  (280, 'Rensningsanlæg'),
  (281, 'Overløbsbassin'),
  (300, 'Busterminal'),
  (301, 'Jernbanestation'),
  (302, 'Baneanlæg'),
  (330, 'Jordbrugsområde'),
  (331, 'Gartneri'),
  (333, 'Naturområde'),
  (334, 'Skov'),
  (335, 'Strandareal'),
  (336, 'Engareal'),
  (337, 'Mose'),
  (350, 'Militært område'),
  (360, 'Råstofområde');

/* ********************************************************************************************
  ╔════════════════════════════════════════════════════════╗
  ║ Registreringer                                         ║
  ╚════════════════════════════════════════════════════════╝
*********************************************************************************************** */

/*
  ╔════════════════════════════════════════════════════════╗
  ║ Lokalplan                                              ║
  ╚════════════════════════════════════════════════════════╝
*/

DROP TABLE IF EXISTS lokalplan CASCADE; -- Kerne som andre registreringer kan 
CREATE TABLE lokalplan
(
  lokalplan_id uuid NOT NULL,
  brugernavn varchar(35),
  PLANID integer,
  KOMNR integer DEFAULT 269,
  OBJEKTKODE integer DEFAULT 20,
  PLANNR varchar(30) NOT NULL,
  PLANNAVN varchar(130) NOT NULL,
  PLANTYPE decimal(3,1) REFERENCES lokalplan_plantype (plantypekode),
  ANVGEN integer REFERENCES generel_anvendelse (generel_anvendelseskode),
  ANVSPEC integer REFERENCES specifik_anvendelse (specifik_anvendelseskode),
  ANVKONKRET integer REFERENCES konkret_anvendelse (konkret_anvendelseskode),
  MEGAWATT decimal(8), -- (obligatorisk for vindmøller - jeg har ikke lavet et tjek og behandler den som frivillig)
  ZONE Integer REFERENCES lokalplanomraade_zone (zonekode), -- zone er et reserveret ord i sql-standarden, men ikke i postgresql, hvis der bliver problemer kommer det i anførselstegn.. feltet er obligatorisk
  DOKLINK varchar(254),
  planstatus integer NOT NULL REFERENCES planstatus (planstatus_id), -- i plansystem opdateres status automatisk ud fra: ”DATOFORSLAG”, ”DATOVEDT” og ”DATOAFLYST 
  CONSTRAINT lokalplan_id_pkey PRIMARY KEY (lokalplan_id) -- lokalplanomraade_id -> versions_id
);

/*
  ╔════════════════════════════════════════════════════════╗
  ║ Plangrænser                                            ║
  ╚════════════════════════════════════════════════════════╝
*/
DROP TABLE IF EXISTS lokalplanomraade CASCADE;
CREATE TABLE lokalplanomraade
(
  lp_id uuid NOT NULL REFERENCES lokalplan (lokalplan_id),
  versions_id uuid NOT NULL, -- ny
  gyldig_fra timestamp with time zone NOT NULL, -- Start systemtid ny
  gyldig_til timestamp with time zone, -- Slut systemtid ny,
  brugernavn varchar(35),
  wkb_geometry geometry(MULTIPOLYGON, 25832),
  CONSTRAINT lokalplanomraade_pkey PRIMARY KEY (versions_id)
);

DROP TABLE IF EXISTS lokalplandelomraade CASCADE;
CREATE TABLE lokalplandelomraade
(
  lokalplandelomraade_id uuid NOT NULL,
  lp_id uuid NOT NULL REFERENCES lokalplan (lokalplan_id),
  versions_id uuid NOT NULL, -- ny
  gyldig_fra timestamp with time zone NOT NULL, -- Start systemtid ny
  gyldig_til timestamp with time zone, -- Slut systemtid ny,
  brugernavn varchar(35),
  PLANID integer,
  LOKPLAN_ID integer, -- Dette skal udfyldes med plansystems id for lokalplanen - det sker med en triggerfunktion når lokalplanens planid udfyldes
  OBJEKTKODE integer DEFAULT 30,
  DELNR varchar(5),
  PLANTYPE decimal(3,1) REFERENCES delomraade_plantype (plantypekode),
  ANVGEN integer REFERENCES generel_anvendelse (generel_anvendelseskode),
  ANVSPEC integer REFERENCES specifik_anvendelse (specifik_anvendelseskode),
  ANVKONKRET integer REFERENCES konkret_anvendelse (konkret_anvendelseskode),
  FZONE integer REFERENCES lokalplandelomraade_fzone (zonekode),
  delomraade_navn character varying,
  wkb_geometry geometry(MULTIPOLYGON, 25832),
  CONSTRAINT lokalplandelomraade_pkey PRIMARY KEY (versions_id)
);

/*
  ╔════════════════════════════════════════════════════════╗
  ║ Matrikulære                                            ║
  ╚════════════════════════════════════════════════════════╝
*/
DROP TABLE IF EXISTS planlagt_matrikelskel CASCADE;
CREATE TABLE planlagt_matrikelskel
(
  planlagt_matrikelskel_id uuid NOT NULL,
  lp_id uuid NOT NULL REFERENCES lokalplan (lokalplan_id),
  versions_id uuid NOT NULL, -- ny
  gyldig_fra timestamp with time zone NOT NULL, -- Start systemtid ny
  gyldig_til timestamp with time zone, -- Slut systemtid ny,
  brugernavn varchar(35),
  wkb_geometry geometry(LINESTRING, 25832),
  CONSTRAINT planlagt_matrikelskel_pkey PRIMARY KEY (versions_id)
);

DROP TABLE IF EXISTS planlagt_udlagt_vej_sti CASCADE;
CREATE TABLE planlagt_udlagt_vej_sti
(
  planlagt_udlagt_vej_sti_id uuid NOT NULL,
  lp_id uuid NOT NULL REFERENCES lokalplan (lokalplan_id),
  versions_id uuid NOT NULL, -- ny
  gyldig_fra timestamp with time zone NOT NULL, -- Start systemtid ny
  gyldig_til timestamp with time zone, -- Slut systemtid ny,
  brugernavn varchar(35),
  wkb_geometry geometry(LINESTRING, 25832),
  CONSTRAINT planlagt_udlagt_vej_sti_pkey PRIMARY KEY (versions_id)
);

/*
  ╔════════════════════════════════════════════════════════╗
  ║ Byggeri                                                ║
  ╚════════════════════════════════════════════════════════╝
*/
DROP TABLE IF EXISTS byggefelt CASCADE; -- Hvordan løser vi fx 'med mulighed for højlager?'
CREATE TABLE byggefelt
(
  byggefelt_id uuid NOT NULL,
  lp_id uuid NOT NULL REFERENCES lokalplan (lokalplan_id),
  versions_id uuid NOT NULL,
  gyldig_fra timestamp with time zone NOT NULL,
  gyldig_til timestamp with time zone,
  brugernavn varchar(35),
  max_etager integer,
  med_udnyttet_tagetage boolean,
  med_kaelder boolean,
  kommentar varchar, --- FX 'med tagterasse' som label på byggefelterne
  wkb_geometry geometry(POLYGON, 25832),
  CONSTRAINT byggefelt_pkey PRIMARY KEY (versions_id)
);

DROP TABLE IF EXISTS byggelinje CASCADE;
CREATE TABLE byggelinje
(
  byggelinje_id uuid NOT NULL,
  lp_id uuid NOT NULL REFERENCES lokalplan (lokalplan_id),
  versions_id uuid NOT NULL, -- ny
  gyldig_fra timestamp with time zone NOT NULL, -- Start systemtid ny
  gyldig_til timestamp with time zone, -- Slut systemtid ny,
  brugernavn varchar(35),
  wkb_geometry geometry(LINESTRING, 25832),
  CONSTRAINT byggelinje_pkey PRIMARY KEY (versions_id)
);


/*
  ╔════════════════════════════════════════════════════════╗
  ║ Trafikale                                              ║
  ╚════════════════════════════════════════════════════════╝
*/
DROP TABLE IF EXISTS overkoersel CASCADE;
CREATE TABLE overkoersel
(
  overkoersel_id uuid NOT NULL,
  lp_id uuid NOT NULL REFERENCES lokalplan (lokalplan_id),
  versions_id uuid NOT NULL, -- ny
  gyldig_fra timestamp with time zone NOT NULL, -- Start systemtid ny
  gyldig_til timestamp with time zone, -- Slut systemtid ny,
  brugernavn varchar(35),
  wkb_geometry geometry(POLYGON, 25832),
  CONSTRAINT overkoersel_pkey PRIMARY KEY (versions_id)
);

DROP TABLE IF EXISTS planlagt_vej_sti CASCADE;
CREATE TABLE planlagt_vej_sti
(
  planlagt_vej_sti_id uuid NOT NULL,
  lp_id uuid NOT NULL REFERENCES lokalplan (lokalplan_id),
  versions_id uuid NOT NULL, -- ny
  gyldig_fra timestamp with time zone NOT NULL, -- Start systemtid ny
  gyldig_til timestamp with time zone, -- Slut systemtid ny,
  brugernavn varchar(35),
  wkb_geometry geometry(POLYGON, 25832),
  CONSTRAINT planlagt_vej_sti_pkey PRIMARY KEY (versions_id)
);


DROP TABLE IF EXISTS oversigtsareal CASCADE;
CREATE TABLE oversigtsareal
(
  oversigtsareal_id uuid NOT NULL,
  lp_id uuid NOT NULL REFERENCES lokalplan (lokalplan_id),
  versions_id uuid NOT NULL, -- ny
  gyldig_fra timestamp with time zone NOT NULL, -- Start systemtid ny
  gyldig_til timestamp with time zone, -- Slut systemtid ny,
  brugernavn varchar(35),
  wkb_geometry geometry(POLYGON, 25832),
  CONSTRAINT oversigtsareal_pkey PRIMARY KEY (versions_id)
);

/* parkeringsareal mangler ()
	Antal pladser? Antal handicappladser?
*/

/*
  ╔════════════════════════════════════════════════════════╗
  ║  Grønne arealer                                        ║
  ╚════════════════════════════════════════════════════════╝
*/

/* Grønne arealer (polygon) 
	
*/

/* plantebaelte mangler (polygon)*/

/* enkeltstaaende_trae mangler (punkt)
	art (frivillig)
	status (bevaringsværdigt, fremtidigt, eksisterende?)
*/

/* stoejhegn? mangler (Linje)
	
*/

/*
  ╔════════════════════════════════════════════════════════╗
  ║  Arealanvendelse                                       ║
  ╚════════════════════════════════════════════════════════╝
*/

/* arealanvendelse/opholdsareal? med fritekst-type mangler */




/*
####################################################
#  Views                                           #
####################################################
*/
/* Et view med delområder, hvor der kun vises linjer, og uden overlap - også overlap med lokalplangrænser undgås. */

/* Skal her konsekvensrettes noget for kun at udstille bestemte, der fx ikke er aflyst? Med lp_id kan vi gøre det i views, der trækker på dette.. */

DROP VIEW IF EXISTS lp_delomr_linjer CASCADE;

CREATE VIEW lp_delomr_linjer AS
	SELECT linjer.id,
		   linjer.lp_id,
		   linjer.geom
	FROM
	
		(SELECT
			ROW_NUMBER() over() AS id, -- En unik værdi, som QGIS kan bruge til primærnøgle
			sl.lp_id, -- Lokalplan id, hvis der skal filtreres så kun den aktive lokalplan skal vises
			ST_SetSRID(ST_MakeLine(
				ST_PointN((sl.g).geom,n),
				ST_PointN((sl.g).geom,n+1)
			), 25832) AS geom -- Her splittes linjerne fra sl op i enkelte linjestykker
		FROM
			(select (st_dump(st_boundary((st_dump(wkb_geometry)).geom))) as g, lp_id from lokalplandelomraade WHERE lokalplandelomraade.gyldig_til IS NULL) as sl -- multipolygoner -> polygoner -> boundary-linjer(multilinestring) -> linestring
		
			CROSS JOIN generate_series(1,10000) AS n -- Bruges til at iterere når linjesegmenterne dannes, kan undgås med lateral join jf. PostGIS In Action 8.3.2
		WHERE n < ST_NPoints((sl.g).geom)
		GROUP BY geom, lp_id) AS linjer, -- ved grupperingen bliver linjestykker, der er identiske og i samme lokalplan fjernet - så bliver der kun en enkelt linje hvert sted. (Hvis der er snappet.. :-| )
		
		(SELECT ST_Union(ST_Buffer(ST_Boundary(wkb_geometry),1)) AS geom FROM lokalplanomraade) AS lp_geom
		
	WHERE NOT ST_WITHIN(linjer.geom, lp_geom.geom);

/*  Et view der viser alle lokalplanerne og deres id'er, der bruges til at lave drop-downliste til valg af lokalplan */

DROP VIEW IF EXISTS v_lp_dropdown CASCADE;

CREATE VIEW v_lp_dropdown AS
	SELECT lokalplanomraade.lp_id AS dropdown_id,
           lokalplan.PLANNAVN AS PLANNAVN,
		   lokalplan.PLANNR AS PLANNR,
		   lokalplanomraade.wkb_geometry AS wkb_geometry
	FROM lokalplan.lokalplanomraade, lokalplan.lokalplan
    WHERE lokalplan.lokalplan_id = lokalplanomraade.lp_id AND lokalplanomraade.gyldig_til IS NULL;

/*
############################################################
#  Views der viser gældende versioner af registreringer    #
############################################################
*/

DROP VIEW IF EXISTS v_lokalplanomraade CASCADE;

CREATE VIEW v_lokalplanomraade AS
	SELECT lokalplanomraade.lp_id AS lp_id,
	       lokalplanomraade.versions_id AS versions_id,
		   lokalplan.PLANID AS PLANID,
           lokalplan.KOMNR AS KOMNR,
           lokalplan.OBJEKTKODE AS OBJEKTKODE,
           lokalplan.PLANNR AS PLANNR,
           lokalplan.PLANNAVN AS PLANNAVN,
           lokalplan.PLANTYPE AS PLANTYPE,
           lokalplan.ANVGEN AS ANVGEN,
           lokalplan.ANVSPEC AS ANVSPEC,
           lokalplan.ANVKONKRET AS ANVKONKRET,
           lokalplan.MEGAWATT AS MEGAWATT,
           lokalplan.ZONE AS ZONE,
           lokalplan.DOKLINK AS DOKLINK,
           lokalplan.planstatus AS PLANSTATUS,
		   lokalplan.PLANNR || ' ' || lokalplan.PLANNAVN AS nummer_navn,
		   lokalplanomraade.gyldig_fra AS gyldig_fra,
		   lokalplanomraade.gyldig_til AS gyldig_til,
		   lokalplanomraade.brugernavn AS brugernavn,
		   lokalplanomraade.wkb_geometry AS wkb_geometry
	FROM lokalplan.lokalplanomraade, lokalplan.lokalplan
    WHERE lokalplan.lokalplan_id = lokalplanomraade.lp_id AND lokalplanomraade.gyldig_til IS NULL;

DROP VIEW IF EXISTS v_lokalplandelomraade CASCADE;

CREATE VIEW v_lokalplandelomraade AS
	SELECT * from lokalplandelomraade
	WHERE lokalplandelomraade.gyldig_til IS NULL;

DROP VIEW IF EXISTS v_planlagt_matrikelskel CASCADE;

CREATE VIEW v_planlagt_matrikelskel AS
	SELECT * from planlagt_matrikelskel
	WHERE planlagt_matrikelskel.gyldig_til IS NULL;

DROP VIEW IF EXISTS v_planlagt_udlagt_vej_sti CASCADE;

CREATE VIEW v_planlagt_udlagt_vej_sti AS
	SELECT * from planlagt_udlagt_vej_sti
	WHERE planlagt_udlagt_vej_sti.gyldig_til IS NULL;

DROP VIEW IF EXISTS v_byggefelt CASCADE;

CREATE VIEW v_byggefelt AS
	SELECT * from byggefelt
	WHERE byggefelt.gyldig_til IS NULL;

DROP VIEW IF EXISTS v_byggelinje CASCADE;

CREATE VIEW v_byggelinje AS
	SELECT * from byggelinje
	WHERE byggelinje.gyldig_til IS NULL;

DROP VIEW IF EXISTS v_overkoersel CASCADE;

CREATE VIEW v_overkoersel AS
	SELECT * from overkoersel
	WHERE overkoersel.gyldig_til IS NULL;

-- DROP VIEW IF EXISTS v_adgangsvej CASCADE;

-- CREATE VIEW v_adgangsvej AS
	-- SELECT * from adgangsvej
	-- WHERE adgangsvej.gyldig_til IS NULL;

DROP VIEW IF EXISTS v_planlagt_vej_sti CASCADE;

CREATE VIEW v_planlagt_vej_sti AS
	SELECT * from planlagt_vej_sti
	WHERE planlagt_vej_sti.gyldig_til IS NULL;

DROP VIEW IF EXISTS v_oversigtsareal CASCADE;

CREATE VIEW v_oversigtsareal AS
	SELECT * from oversigtsareal
	WHERE oversigtsareal.gyldig_til IS NULL;

/*
####################################################
#  Procedurer                                      #
####################################################
*/

/* Trigger der opdaterer lokalplan-id for delområderne, når en lokalplan får tildelt et id fra plansystem. */

CREATE OR REPLACE FUNCTION plansystem_id_tilfoejet()
	RETURNS trigger AS
$$
BEGIN
	IF NEW.planid IS NOT NULL THEN
		UPDATE lokalplandelomraade
			SET lokplan_id = NEW.planid
			WHERE lp_id =  NEW.lokalplanomraade_id;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER plansystem_id_tilfoejet
	AFTER UPDATE ON lokalplan
	FOR EACH ROW
	EXECUTE PROCEDURE plansystem_id_tilfoejet();

/*
####################################################
# Procedurer der opdaterer views                   #
####################################################
*/
/* **************** */
/* Lokalplanområde: */
/* **************** */
CREATE OR REPLACE FUNCTION lokalplanomraade_oprettet()
	RETURNS trigger AS
$$
BEGIN
	-- initialization
	new.lp_id = uuid_generate_v1();
	new.versions_id = uuid_generate_v1();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	new.gyldig_fra = current_timestamp;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	new.gyldig_til = NULL;
	-- insert i lokalplan og lokalplanomraade:
	INSERT INTO lokalplan.lokalplan (lokalplan_id, brugernavn, PLANID, KOMNR, OBJEKTKODE, PLANNR, PLANNAVN, PLANTYPE, ANVGEN, ANVSPEC, ANVKONKRET, MEGAWATT, ZONE, DOKLINK, planstatus)
		VALUES (new.lp_id, new.brugernavn, new.PLANID, new.KOMNR, new.OBJEKTKODE, new.PLANNR, new.PLANNAVN, new.PLANTYPE, new.ANVGEN, new.ANVSPEC, new.ANVKONKRET, new.MEGAWATT, new.ZONE, new.DOKLINK, new.PLANSTATUS);
	INSERT INTO lokalplan.lokalplanomraade (versions_id, lp_id, gyldig_fra, gyldig_til, brugernavn, wkb_geometry)
		VALUES (new.versions_id, new.lp_id, new.gyldig_fra, new.gyldig_til, new.brugernavn, new.wkb_geometry);
	
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS lokalplanomraade_oprettet ON v_lokalplanomraade;   

CREATE TRIGGER lokalplanomraade_oprettet
	INSTEAD OF INSERT ON v_lokalplanomraade
	FOR EACH ROW
	EXECUTE PROCEDURE lokalplanomraade_oprettet();

CREATE OR REPLACE FUNCTION lokalplanomraade_aendret()
	RETURNS trigger AS
$$
BEGIN
	IF old.lp_id <> new.lp_id THEN
		RAISE EXCEPTION 'Der kan ikke ændres lokalplans id på lokalplanområderne.';
	END IF;
	
	UPDATE lokalplan.lokalplan
		SET brugernavn = new.brugernavn,
		    PLANID = new.PLANID,
		    KOMNR = new.KOMNR,
		    OBJEKTKODE = new.OBJEKTKODE,
		    PLANNR = new.PLANNR,
		    PLANNAVN = new.PLANNAVN,
		    PLANTYPE = new.PLANTYPE,
		    ANVGEN = new.ANVGEN,
		    ANVSPEC = new.ANVSPEC,
		    ANVKONKRET = new.ANVKONKRET,
		    MEGAWATT = new.MEGAWATT,
		    ZONE = new.ZONE,
		    DOKLINK = new.DOKLINK,
		    planstatus = new.planstatus
	WHERE new.lp_id = lokalplan.lokalplan_id;
	
	UPDATE lokalplan.lokalplanomraade -- Den gamle version af lokalplanomraadet får et gyldig_til timestamp.
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE new.versions_id = versions_id;
	
	INSERT INTO lokalplan.lokalplanomraade (lp_id, versions_id, gyldig_fra, gyldig_til, brugernavn, wkb_geometry)
		VALUES (new.lp_id, uuid_generate_v1(), CURRENT_TIMESTAMP, NULL, new.brugernavn, new.wkb_geometry);
	
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS lokalplanomraade_aendret ON v_lokalplanomraade;   

CREATE TRIGGER lokalplanomraade_aendret
	INSTEAD OF UPDATE ON v_lokalplanomraade
	FOR EACH ROW
	EXECUTE PROCEDURE lokalplanomraade_aendret();

CREATE OR REPLACE FUNCTION lokalplanomraade_slettet()
	RETURNS trigger AS
$$
BEGIN
	IF NOT EXISTS (SELECT '1' FROM lokalplan.lokalplanomraade WHERE versions_id = old.versions_id AND gyldig_til IS NULL) THEN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
		RETURN NULL;
	END IF;
	
	UPDATE lokalplan.lokalplanomraade
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE versions_id = old.versions_id;
	
	UPDATE lokalplan.lokalplan
		SET planstatus = 7
		WHERE lokalplan_id = old.lp_id;
	
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS lokalplanomraade_slettet ON v_lokalplanomraade;   

CREATE TRIGGER lokalplanomraade_slettet
	INSTEAD OF DELETE ON v_lokalplanomraade
	FOR EACH ROW
	EXECUTE PROCEDURE lokalplanomraade_slettet();

/* ******************* */
/* lokalplandelomraade */
/* ******************* */
CREATE OR REPLACE FUNCTION lokalplandelomraade_oprettet()
	RETURNS trigger AS
$$
BEGIN
	-- initialization
	new.lokalplandelomraade_id = uuid_generate_v1();
	new.versions_id = uuid_generate_v1();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	new.gyldig_fra = current_timestamp;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	new.gyldig_til = NULL;
	-- insert i lokalplandelomraade:
	INSERT INTO lokalplan.lokalplandelomraade (	lokalplandelomraade_id, lp_id, versions_id,
												gyldig_fra, gyldig_til, brugernavn, PLANID,
												LOKPLAN_ID, OBJEKTKODE, DELNR, PLANTYPE,
												ANVGEN, ANVSPEC, ANVKONKRET, FZONE, delomraade_navn,
												wkb_geometry)
		VALUES (new.lokalplandelomraade_id, new.lp_id, new.versions_id,
				new.gyldig_fra, new.gyldig_til, new.brugernavn, new.PLANID,
				new.LOKPLAN_ID, new.OBJEKTKODE, new.DELNR, new.PLANTYPE,
				new.ANVGEN, new.ANVSPEC, new.ANVKONKRET, new.FZONE, new.delomraade_navn,
				new.wkb_geometry);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS lokalplandelomraade_oprettet ON v_lokalplandelomraade;   

CREATE TRIGGER lokalplandelomraade_oprettet
	INSTEAD OF INSERT ON v_lokalplandelomraade
	FOR EACH ROW
	EXECUTE PROCEDURE lokalplandelomraade_oprettet();

CREATE OR REPLACE FUNCTION lokalplandelomraade_aendret()
	RETURNS trigger AS
$$
BEGIN
	UPDATE lokalplan.lokalplandelomraade -- Den gamle version af lokalplanomraadet får et gyldig_til timestamp.
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE new.versions_id = versions_id;
		
	INSERT INTO lokalplan.lokalplandelomraade (
		lokalplandelomraade_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		PLANID,
		LOKPLAN_ID,
		OBJEKTKODE,
		DELNR,
		PLANTYPE,
		ANVGEN,
		ANVSPEC,
		ANVKONKRET,
		FZONE,
		delomraade_navn,
		wkb_geometry
	)
	VALUES (
		new.lokalplandelomraade_id,
		new.lp_id,
		uuid_generate_v1(),
		CURRENT_TIMESTAMP,
		NULL,
		new.brugernavn,
		new.PLANID,
		new.LOKPLAN_ID,
		new.OBJEKTKODE,
		new.DELNR,
		new.PLANTYPE,
		new.ANVGEN,
		new.ANVSPEC,
		new.ANVKONKRET,
		new.FZONE,
		new.delomraade_navn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS lokalplandelomraade_aendret ON v_lokalplandelomraade;   

CREATE TRIGGER lokalplanomraade_aendret
	INSTEAD OF UPDATE ON v_lokalplandelomraade
	FOR EACH ROW
	EXECUTE PROCEDURE lokalplandelomraade_aendret();

CREATE OR REPLACE FUNCTION lokalplandelomraade_slettet()
	RETURNS trigger AS
$$
BEGIN
	IF NOT EXISTS (SELECT '1' FROM lokalplan.lokalplandelomraade WHERE versions_id = old.versions_id AND gyldig_til IS NULL) THEN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
		RETURN NULL;
	END IF;
	
	UPDATE lokalplan.lokalplandelomraade
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE versions_id = old.versions_id;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS lokalplandelomraade_slettet ON v_lokalplandelomraade;   

CREATE TRIGGER lokalplandelomraade_slettet
	INSTEAD OF DELETE ON v_lokalplandelomraade
	FOR EACH ROW
	EXECUTE PROCEDURE lokalplandelomraade_slettet();

/* ********************* */
/* planlagt_matrikelskel */
/* ********************* */
CREATE OR REPLACE FUNCTION planlagt_matrikelskel_oprettet()
	RETURNS trigger AS
$$
BEGIN
	-- initialization
	new.planlagt_matrikelskel_id = uuid_generate_v1();
	new.versions_id = uuid_generate_v1();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	new.gyldig_fra = current_timestamp;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	new.gyldig_til = NULL;
	-- insert i planlagt_matrikelskel:
	INSERT INTO lokalplan.planlagt_matrikelskel (
		planlagt_matrikelskel_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
	)
		VALUES (
		new.planlagt_matrikelskel_id,
		new.lp_id,
		new.versions_id,
		new.gyldig_fra,
		new.gyldig_til,
		new.brugernavn,
		new.wkb_geometry
		);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS planlagt_matrikelskel_oprettet ON v_planlagt_matrikelskel;   

CREATE TRIGGER planlagt_matrikelskel_oprettet
	INSTEAD OF INSERT ON v_planlagt_matrikelskel
	FOR EACH ROW
	EXECUTE PROCEDURE planlagt_matrikelskel_oprettet();

CREATE OR REPLACE FUNCTION planlagt_matrikelskel_aendret()
	RETURNS trigger AS
$$
BEGIN
	UPDATE lokalplan.planlagt_matrikelskel
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE new.versions_id = versions_id;
		
	INSERT INTO lokalplan.lokalplanomraade (
		planlagt_matrikelskel_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
			)
	VALUES (
		new.planlagt_matrikelskel_id,
		new.lp_id,
		uuid_generate_v1(),
		CURRENT_TIMESTAMP,
		NULL,
		new.brugernavn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS planlagt_matrikelskel_aendret ON v_planlagt_matrikelskel;   

CREATE TRIGGER planlagt_matrikelskel_aendret
	INSTEAD OF UPDATE ON v_planlagt_matrikelskel
	FOR EACH ROW
	EXECUTE PROCEDURE planlagt_matrikelskel_aendret();

CREATE OR REPLACE FUNCTION planlagt_matrikelskel_slettet()
	RETURNS trigger AS
$$
BEGIN
	IF NOT EXISTS (SELECT '1' FROM lokalplan.planlagt_matrikelskel WHERE versions_id = old.versions_id AND gyldig_til IS NULL) THEN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
		RETURN NULL;
	END IF;
	
	UPDATE lokalplan.planlagt_matrikelskel
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE versions_id = old.versions_id;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS planlagt_matrikelskel_slettet ON v_planlagt_matrikelskel;   

CREATE TRIGGER planlagt_matrikelskel_slettet
	INSTEAD OF DELETE ON v_planlagt_matrikelskel
	FOR EACH ROW
	EXECUTE PROCEDURE planlagt_matrikelskel_slettet();

/* *********************** */
/* planlagt_udlagt_vej_sti */
/* *********************** */
CREATE OR REPLACE FUNCTION planlagt_udlagt_vej_sti_oprettet()
	RETURNS trigger AS
$$
BEGIN
	-- initialization
	new.planlagt_udlagt_vej_sti_id = uuid_generate_v1();
	new.versions_id = uuid_generate_v1();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	new.gyldig_fra = current_timestamp;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	new.gyldig_til = NULL;
	-- insert i planlagt_udlagt_vej_sti:
	INSERT INTO lokalplan.planlagt_udlagt_vej_sti (
		planlagt_udlagt_vej_sti_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
	)
		VALUES (
		new.planlagt_udlagt_vej_sti_id,
		new.lp_id,
		new.versions_id,
		new.gyldig_fra,
		new.gyldig_til,
		new.brugernavn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS planlagt_udlagt_vej_sti_oprettet ON v_planlagt_udlagt_vej_sti;   

CREATE TRIGGER planlagt_udlagt_vej_sti_oprettet
	INSTEAD OF INSERT ON v_planlagt_udlagt_vej_sti
	FOR EACH ROW
	EXECUTE PROCEDURE planlagt_udlagt_vej_sti_oprettet();

CREATE OR REPLACE FUNCTION planlagt_udlagt_vej_sti_aendret()
	RETURNS trigger AS
$$
BEGIN
	UPDATE lokalplan.planlagt_udlagt_vej_sti
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE new.versions_id = versions_id;
		
	INSERT INTO lokalplan.planlagt_udlagt_vej_sti (
		planlagt_udlagt_vej_sti_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
			)
	VALUES (
		new.planlagt_udlagt_vej_sti_id,
		new.lp_id,
		uuid_generate_v1(),
		CURRENT_TIMESTAMP,
		NULL,
		new.brugernavn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS planlagt_udlagt_vej_sti_aendret ON v_planlagt_udlagt_vej_sti;   

CREATE TRIGGER planlagt_udlagt_vej_sti_aendret
	INSTEAD OF UPDATE ON v_planlagt_udlagt_vej_sti
	FOR EACH ROW
	EXECUTE PROCEDURE planlagt_udlagt_vej_sti_aendret();

CREATE OR REPLACE FUNCTION planlagt_udlagt_vej_sti_slettet()
	RETURNS trigger AS
$$
BEGIN
	IF NOT EXISTS (SELECT '1' FROM lokalplan.planlagt_udlagt_vej_sti WHERE versions_id = old.versions_id AND gyldig_til IS NULL) THEN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
		RETURN NULL;
	END IF;
	
	UPDATE lokalplan.planlagt_udlagt_vej_sti
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE versions_id = old.versions_id;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS planlagt_udlagt_vej_sti_slettet ON v_planlagt_udlagt_vej_sti;   

CREATE TRIGGER planlagt_udlagt_vej_sti_slettet
	INSTEAD OF DELETE ON v_planlagt_udlagt_vej_sti
	FOR EACH ROW
	EXECUTE PROCEDURE planlagt_udlagt_vej_sti_slettet();

/* ********* */
/* byggefelt */
/* ********* */
CREATE OR REPLACE FUNCTION byggefelt_oprettet()
	RETURNS trigger AS
$$
BEGIN
	-- initialization
	new.byggefelt_id = uuid_generate_v1();
	new.versions_id = uuid_generate_v1();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	new.gyldig_fra = current_timestamp;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	new.gyldig_til = NULL;
	-- insert i byggefelt:
	INSERT INTO lokalplan.byggefelt (
		byggefelt_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		max_etager,
		med_udnyttet_tagetage,
		med_kaelder,
		kommentar,
		wkb_geometry
	)
		VALUES (
		new.byggefelt_id,
		new.lp_id,
		new.versions_id,
		new.gyldig_fra,
		new.gyldig_til,
		new.brugernavn,
		new.max_etager,
		new.med_udnyttet_tagetage,
		new.med_kaelder,
		new.kommentar,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS byggefelt_oprettet ON v_byggefelt;   

CREATE TRIGGER byggefelt_oprettet
	INSTEAD OF INSERT ON v_byggefelt
	FOR EACH ROW
	EXECUTE PROCEDURE byggefelt_oprettet();

CREATE OR REPLACE FUNCTION byggefelt_aendret()
	RETURNS trigger AS
$$
BEGIN
	UPDATE lokalplan.byggefelt
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE new.versions_id = versions_id;
		
	INSERT INTO lokalplan.byggefelt (
		byggefelt_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		max_etager,
		med_udnyttet_tagetage,
		med_kaelder,
		kommentar,
		wkb_geometry
	)
	VALUES (
		new.byggefelt_id,
		new.lp_id,
		uuid_generate_v1(),
		CURRENT_TIMESTAMP,
		NULL,
		new.brugernavn,
		new.max_etager,
		new.med_udnyttet_tagetage,
		new.med_kaelder,
		new.kommentar,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS byggefelt_aendret ON v_byggefelt;   

CREATE TRIGGER byggefelt_aendret
	INSTEAD OF UPDATE ON v_byggefelt
	FOR EACH ROW
	EXECUTE PROCEDURE byggefelt_aendret();

CREATE OR REPLACE FUNCTION byggefelt_slettet()
	RETURNS trigger AS
$$
BEGIN
	IF NOT EXISTS (SELECT '1' FROM lokalplan.byggefelt WHERE versions_id = old.versions_id AND gyldig_til IS NULL) THEN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
		RETURN NULL;
	END IF;
	
	UPDATE lokalplan.byggefelt
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE versions_id = old.versions_id;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS byggefelt_slettet ON v_byggefelt;   

CREATE TRIGGER byggefelt_slettet
	INSTEAD OF DELETE ON v_byggefelt
	FOR EACH ROW
	EXECUTE PROCEDURE byggefelt_slettet();

/* ********** */
/* byggelinje */
/* ********** */
CREATE OR REPLACE FUNCTION byggelinje_oprettet()
	RETURNS trigger AS
$$
BEGIN
	-- initialization
	new.byggelinje_id = uuid_generate_v1();
	new.versions_id = uuid_generate_v1();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	new.gyldig_fra = current_timestamp;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	new.gyldig_til = NULL;
	-- insert i byggelinje:
	INSERT INTO lokalplan.byggelinje (
		byggelinje_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
	)
		VALUES (
		new.byggelinje_id,
		new.lp_id,
		new.versions_id,
		new.gyldig_fra,
		new.gyldig_til,
		new.brugernavn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS byggelinje_oprettet ON v_byggelinje;   

CREATE TRIGGER byggelinje_oprettet
	INSTEAD OF INSERT ON v_byggelinje
	FOR EACH ROW
	EXECUTE PROCEDURE byggelinje_oprettet();

CREATE OR REPLACE FUNCTION byggelinje_aendret()
	RETURNS trigger AS
$$
BEGIN
	UPDATE lokalplan.byggelinje
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE new.versions_id = versions_id;
		
	INSERT INTO lokalplan.byggelinje (
		byggelinje_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
	)
	VALUES (
		new.byggelinje_id,
		new.lp_id,
		uuid_generate_v1(),
		CURRENT_TIMESTAMP,
		NULL,
		new.brugernavn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS byggelinje_aendret ON v_byggelinje;   

CREATE TRIGGER byggelinje_aendret
	INSTEAD OF UPDATE ON v_byggelinje
	FOR EACH ROW
	EXECUTE PROCEDURE byggelinje_aendret();

CREATE OR REPLACE FUNCTION byggelinje_slettet()
	RETURNS trigger AS
$$
BEGIN
	IF NOT EXISTS (SELECT '1' FROM lokalplan.byggelinje WHERE versions_id = old.versions_id AND gyldig_til IS NULL) THEN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
		RETURN NULL;
	END IF;
	
	UPDATE lokalplan.byggelinje
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE versions_id = old.versions_id;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS byggelinje_slettet ON v_byggelinje;   

CREATE TRIGGER byggelinje_slettet
	INSTEAD OF DELETE ON v_byggelinje
	FOR EACH ROW
	EXECUTE PROCEDURE byggelinje_slettet();

/* *********** */
/* overkoersel */
/* *********** */
CREATE OR REPLACE FUNCTION overkoersel_oprettet()
	RETURNS trigger AS
$$
BEGIN
	-- initialization
	new.overkoersel_id = uuid_generate_v1();
	new.versions_id = uuid_generate_v1();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	new.gyldig_fra = current_timestamp;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	new.gyldig_til = NULL;
	-- insert i overkoersel:
	INSERT INTO lokalplan.overkoersel (
		overkoersel_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
	)
		VALUES (
		new.overkoersel_id,
		new.lp_id,
		new.versions_id,
		new.gyldig_fra,
		new.gyldig_til,
		new.brugernavn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS overkoersel_oprettet ON v_overkoersel;   

CREATE TRIGGER overkoersel_oprettet
	INSTEAD OF INSERT ON v_overkoersel
	FOR EACH ROW
	EXECUTE PROCEDURE overkoersel_oprettet();

CREATE OR REPLACE FUNCTION overkoersel_aendret()
	RETURNS trigger AS
$$
BEGIN
	UPDATE lokalplan.overkoersel
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE new.versions_id = versions_id;
		
	INSERT INTO lokalplan.overkoersel (
		overkoersel_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
	)
	VALUES (
		new.overkoersel_id,
		new.lp_id,
		uuid_generate_v1(),
		CURRENT_TIMESTAMP,
		NULL,
		new.brugernavn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS overkoersel_aendret ON v_overkoersel;   

CREATE TRIGGER overkoersel_aendret
	INSTEAD OF UPDATE ON v_overkoersel
	FOR EACH ROW
	EXECUTE PROCEDURE overkoersel_aendret();

CREATE OR REPLACE FUNCTION overkoersel_slettet()
	RETURNS trigger AS
$$
BEGIN
	IF NOT EXISTS (SELECT '1' FROM lokalplan.overkoersel WHERE versions_id = old.versions_id AND gyldig_til IS NULL) THEN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
		RETURN NULL;
	END IF;
	
	UPDATE lokalplan.overkoersel
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE versions_id = old.versions_id;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS overkoersel_slettet ON v_overkoersel;   

CREATE TRIGGER overkoersel_slettet
	INSTEAD OF DELETE ON v_overkoersel
	FOR EACH ROW
	EXECUTE PROCEDURE overkoersel_slettet();

/* **************** */
/* planlagt_vej_sti */
/* **************** */
CREATE OR REPLACE FUNCTION planlagt_vej_sti_oprettet()
	RETURNS trigger AS
$$
BEGIN
	-- initialization
	new.planlagt_vej_sti_id = uuid_generate_v1();
	new.versions_id = uuid_generate_v1();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	new.gyldig_fra = current_timestamp;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	new.gyldig_til = NULL;
	-- insert i overkoersel:
	INSERT INTO lokalplan.planlagt_vej_sti (
		planlagt_vej_sti_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
	)
		VALUES (
		new.planlagt_vej_sti_id,
		new.lp_id,
		new.versions_id,
		new.gyldig_fra,
		new.gyldig_til,
		new.brugernavn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS planlagt_vej_sti_oprettet ON v_planlagt_vej_sti;   

CREATE TRIGGER planlagt_vej_sti_oprettet
	INSTEAD OF INSERT ON v_planlagt_vej_sti
	FOR EACH ROW
	EXECUTE PROCEDURE planlagt_vej_sti_oprettet();

CREATE OR REPLACE FUNCTION planlagt_vej_sti_aendret()
	RETURNS trigger AS
$$
BEGIN
	UPDATE lokalplan.planlagt_vej_sti
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE new.versions_id = versions_id;
		
	INSERT INTO lokalplan.planlagt_vej_sti (
		planlagt_vej_sti_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
	)
	VALUES (
		new.planlagt_vej_sti_id,
		new.lp_id,
		uuid_generate_v1(),
		CURRENT_TIMESTAMP,
		NULL,
		new.brugernavn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS planlagt_vej_sti_aendret ON v_planlagt_vej_sti;   

CREATE TRIGGER planlagt_vej_sti_aendret
	INSTEAD OF UPDATE ON v_planlagt_vej_sti
	FOR EACH ROW
	EXECUTE PROCEDURE planlagt_vej_sti_aendret();

CREATE OR REPLACE FUNCTION planlagt_vej_sti_slettet()
	RETURNS trigger AS
$$
BEGIN
	IF NOT EXISTS (SELECT '1' FROM lokalplan.planlagt_vej_sti WHERE versions_id = old.versions_id AND gyldig_til IS NULL) THEN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
		RETURN NULL;
	END IF;
	
	UPDATE lokalplan.planlagt_vej_sti
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE versions_id = old.versions_id;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS planlagt_vej_sti_slettet ON v_planlagt_vej_sti;   

CREATE TRIGGER planlagt_vej_sti_slettet
	INSTEAD OF DELETE ON v_planlagt_vej_sti
	FOR EACH ROW
	EXECUTE PROCEDURE planlagt_vej_sti_slettet();

/* ************** */
/* oversigtsareal */
/* ************** */
CREATE OR REPLACE FUNCTION oversigtsareal_oprettet()
	RETURNS trigger AS
$$
BEGIN
	-- initialization
	new.oversigtsareal_id = uuid_generate_v1();
	new.versions_id = uuid_generate_v1();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	new.gyldig_fra = current_timestamp;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	new.gyldig_til = NULL;
	-- insert i overkoersel:
	INSERT INTO lokalplan.oversigtsareal (
		oversigtsareal_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
	)
		VALUES (
		new.oversigtsareal_id,
		new.lp_id,
		new.versions_id,
		new.gyldig_fra,
		new.gyldig_til,
		new.brugernavn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS oversigtsareal_oprettet ON v_oversigtsareal;   

CREATE TRIGGER oversigtsareal_oprettet
	INSTEAD OF INSERT ON v_oversigtsareal
	FOR EACH ROW
	EXECUTE PROCEDURE oversigtsareal_oprettet();

CREATE OR REPLACE FUNCTION oversigtsareal_aendret()
	RETURNS trigger AS
$$
BEGIN
	UPDATE lokalplan.oversigtsareal
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE new.versions_id = versions_id;
		
	INSERT INTO lokalplan.oversigtsareal (
		oversigtsareal_id,
		lp_id,
		versions_id,
		gyldig_fra,
		gyldig_til,
		brugernavn,
		wkb_geometry
	)
	VALUES (
		new.oversigtsareal_id,
		new.lp_id,
		uuid_generate_v1(),
		CURRENT_TIMESTAMP,
		NULL,
		new.brugernavn,
		new.wkb_geometry
	);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS oversigtsareal_aendret ON v_oversigtsareal;   

CREATE TRIGGER oversigtsareal_aendret
	INSTEAD OF UPDATE ON v_oversigtsareal
	FOR EACH ROW
	EXECUTE PROCEDURE oversigtsareal_aendret();

CREATE OR REPLACE FUNCTION oversigtsareal_slettet()
	RETURNS trigger AS
$$
BEGIN
	IF NOT EXISTS (SELECT '1' FROM lokalplan.oversigtsareal WHERE versions_id = old.versions_id AND gyldig_til IS NULL) THEN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
		RETURN NULL;
	END IF;
	
	UPDATE lokalplan.oversigtsareal
		SET gyldig_til = CURRENT_TIMESTAMP
		WHERE versions_id = old.versions_id;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS oversigtsareal_slettet ON v_oversigtsareal;   

CREATE TRIGGER oversigtsareal_slettet
	INSTEAD OF DELETE ON v_oversigtsareal
	FOR EACH ROW
	EXECUTE PROCEDURE oversigtsareal_slettet();	

/*
####################################################
#  Permissions                                     #
####################################################
*/
	

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA lokalplan TO lokalplan_qgis; -- test ændres til lokalplan!
GRANT SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA lokalplan TO lokalplan_qgis; -- test ændres til lokalplan!

GRANT ALL ON SCHEMA lokalplan TO lokalplan_qgis;

REVOKE UPDATE ON TABLE lp_delomr_linjer FROM lokalplan_qgis; -- viewet med lokalplandelområdegrænser skal ikke fremstå som redigerbart
REVOKE INSERT ON TABLE lp_delomr_linjer FROM lokalplan_qgis;
REVOKE DELETE ON TABLE lp_delomr_linjer FROM lokalplan_qgis;

SET search_path TO "$user",public;