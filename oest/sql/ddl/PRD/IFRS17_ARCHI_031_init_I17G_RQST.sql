---------------------------------------------------------------
-- IFRS17_ARCHI_03_init_REQSTsql
---------------------------------------------------------------

USE BEST
go




delete BEST..TI17REQJOB
delete BEST..TI17REQJOBPLAN

delete BEST..TI17PERMFIL 
delete  BEST..TI17REQCHN 
delete  BEST..TI17CHN  
delete  BEST..TI17FNC 
delete BEST..TI17REQ
go

if exists(select 1 from sysindexes i where i.name = 'PK_TI17PERFIL' and 
           (i.status2&2) = 2 and i.id = object_id('TI17PERFIL'))
   alter table TI17PERFIL
      drop constraint PK_TI17PERFIL
go

if exists (select 1
            from  sysobjects
            where id = object_id('TI17PERFIL')
            and   type = 'U')
   drop table TI17PERFIL
go


		
--
-- TI17REQ TABLE INSERT STATEMENTS
--

--- IFRS 17 Groupe
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GMINV',   'Monthly INV IFRS 17 Group')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GMINVB',  'Monthly INV IFRS 17 Group technical booking	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GMPOS',   'Monthly POS IFRS 17 Group	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GMPOSB', 'Monthly POS IFRS 17 Group booking	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GMPOC',  'Monthly POC IFRS 17 Group	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GMPOCB', 'Monthly POC IFRS 17 Group booking	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GQINV',    'Quarterly INV IFRS 17 Group	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GQINVB',  'Quarterly INV IFRS 17 Group technical booking	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GQPOS',   'Quarterly POS IFRS 17 Group	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GQPOSB', 'Quarterly POS IFRS 17 Group booking	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GQPOC',   'Quarterly POC IFRS 17 Group	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GQPOCB', 'Quarterly POC IFRS 17 Group booking	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GYINV',     'Yearly INV IFRS 17 Group	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GYINVB',   'Yearly  INV IFRS 17 Group technical booking	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GYPOS',    'Yearly  POS IFRS 17 Group	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GYPOSB',  'Yearly  POS IFRS 17 Group booking	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GYPOC',    'Yearly  POC IFRS 17 Group	')
INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ('I17GYPOCB',  'Yearly  POC IFRS 17 Group booking	')


-- Post omega

	-- EBS
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'POSE','Post omega Social EBS4')
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'BookingPOSE ','Post omega Social EBS4 Booking')
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'BookingPOSEAnnuel','Post omega Social EBS4 Booking annuel')
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'BookingPOCE','Booking Post omega conso EBS')
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'BookingPOCEAnnuel','Post omega conso annuel EBS ')
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'POCE','Post omega conso EBS')

	-- IFRS 4
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'POSI','Post omega Social  IFRS4')
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'BookingPOSI','Booking Post omega Social  IFRS4')
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'BookingPOSIAnnuel','Booking annuel Post omega Social IFRS4')
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'POCI','Post omega conso IFRS4')
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'BookingPOCI','Booking Post omega conso IFRS4')
	INSERT INTO BEST..TI17REQ ( REQCOD_CT, REQCOD_LL )         VALUES ( 'BookingPOCIAnnuel ','Booking Post omega conso IFRS4')


go

--select * from BEST..TI17REQ


go


