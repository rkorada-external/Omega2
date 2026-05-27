USE BEST
go

IF OBJECT_ID('PsLIFEST_18_O2') IS NOT NULL
BEGIN
  DROP PROCEDURE PsLIFEST_18_O2
  IF OBJECT_ID('PsLIFEST_18_O2') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE PsLIFEST_18_O2 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE PsLIFEST_18_O2 >>>'
END
go
create procedure PsLIFEST_18_O2 (
	@p_ssd_cf       USSD_CF,
 	@p_esb_cf       UESB_CF,
	@p_usr_cf       UUSR_CF,
	@p_fileno_nt		int
)
with execute as caller as
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : L. Wernert 
Creation date     : 16/03/2020
Description       : 82192 -> Format control on automatic upload estimate input files
										Technical choice imposed by V. Goron and P. POUX
_________________
MODIFICATION 1
Auteur: L. Wernert
Date: 23/09/2020
Version: 2
Description: 87213 -> Insert CUR_CF et ESTMNT_M in a work table for the acknowledge process 
_________________
*****************************************************/
declare @error_code int,
				@erreur int

CREATE TABLE #EST_ESIJ0810_TCTRANO (
  CTR_NF UCTR_NF null,
  END_NT UEND_NT not null,
  SEC_NF int null,
  VRS_NF numeric(10, 0) not null,
  SSD_CF USSD_CF not null,
  SEGTYP_CT USEGTYP_CT not null,
  SEG_NF USEG_NF not null,
  ANO_CT int not null,
  NUMLINE_NT int default 0  not null,
  UWY_NF int null,
  ACY_NF int null,
  BLOCKING_B UBOOLEAN_B null,
  ESB_CF UESB_CF not null,
  USR_CF UUSR_CF not null,
  GAAP_NT int null,
  DETTRNCOD_CF char(5) null
)

/*** ACCEPT ***/
-- Acceptance contract missing
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	p.CTR_NF, 0, p.SEC_NF, 1,
	@p_ssd_cf, 'L', @p_usr_cf, 30117,
	p.NUMLINE_NT, p.UWY_NF, p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	(p.CTR_NF = '' OR p.CTR_NF IS NULL) AND 
	p.SEC_NF IS NOT NULL AND 
	p.UWY_NF IS NOT NULL AND
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end
	
	
-- 250: Acceptance must be 9 (upper case) characters
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	SUBSTRING(p.CTR_NF,1,9) as CTR_NF, 
	0, p.SEC_NF, 1, @p_ssd_cf, 'L', 
	@p_usr_cf, 250, p.NUMLINE_NT, 
	p.UWY_NF, p.ACY_NF, 1, @p_esb_cf, 
	@p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p 
LEFT OUTER JOIN 
	BTRT..TCONTR tcontr ON 
		p.CTR_NF = tcontr.CTR_NF AND 
		p.UWY_NF = tcontr.UWY_NF 
WHERE
	(p.CTR_NF != '' AND p.CTR_NF IS NOT NULL) AND
	(len(p.CTR_NF) < 9) AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf
	
select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end
	
	
-- Acceptance section missing
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	p.CTR_NF, 0, p.SEC_NF, 1,
	@p_ssd_cf, 'L', @p_usr_cf, 30118,
	p.NUMLINE_NT, p.UWY_NF, p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	(p.CTR_NF != '' AND p.CTR_NF IS NOT NULL) AND
	p.SEC_NF IS NULL AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- 260: Acceptance section number must be between 0 and 255
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	p.CTR_NF, 0, p.SEC_NF, 1,
	@p_ssd_cf, 'L', @p_usr_cf, 260,
	p.NUMLINE_NT, p.UWY_NF, p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	p.SEC_NF IS NOT NULL AND
	(p.SEC_NF < 0 OR p.SEC_NF > 255) AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Acceptance U/W Year missing
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	p.CTR_NF, 0, p.SEC_NF, 1,
	@p_ssd_cf, 'L', @p_usr_cf, 30120,
	p.NUMLINE_NT, p.UWY_NF, p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	(p.CTR_NF != '' AND p.CTR_NF IS NOT NULL) AND
	p.UWY_NF IS NULL AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- U/W Year must be between 1950 and 2050
/*select @error_code = 80003
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	p.CTR_NF, 0, p.SEC_NF, 1,
	@p_ssd_cf, 'L', @p_usr_cf, @error_code,
	p.NUMLINE_NT, p.UWY_NF, p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	p.UWY_NF IS NOT NULL AND
	(p.UWY_NF < 1950 OR p.UWY_NF > 2050) AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO"
	return @erreur
end*/

/*** ACCEPT - END ***/


/*** RETRO ***/
-- Retrocession contract missing
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	p.RETCTR_NF, 0, p.SEC_NF, 1,
	@p_ssd_cf, 'L', @p_usr_cf, 30117,
	p.NUMLINE_NT, p.UWY_NF, p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	(p.RETCTR_NF = '' OR p.RETCTR_NF IS NULL) AND 
	p.RETSEC_NF IS NOT NULL AND
	p.RTY_NF IS NOT NULL AND
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end



-- 313: Retro contract must be 9 (upper case) characters
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	SUBSTRING(p.RETCTR_NF,1,9), 
	0, p.RETSEC_NF, 1, @p_ssd_cf, 
	'L', @p_usr_cf, 313, p.NUMLINE_NT, 
	p.RTY_NF, p.ACY_NF, 1, @p_esb_cf, 
	@p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
LEFT OUTER JOIN 
	BRET..TRETCTR tret ON 
		p.CTR_NF = tret.RETCTR_NF AND 
		p.UWY_NF = tret.RTY_NF
WHERE
	(p.RETCTR_NF != '' AND p.RETCTR_NF IS NOT NULL) AND
	(len(p.RETCTR_NF) < 9) AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf


-- Retrocession section missing
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	p.RETCTR_NF, 0, p.RETSEC_NF, 1,
	@p_ssd_cf, 'L', @p_usr_cf, 30119,
	p.NUMLINE_NT, p.UWY_NF, p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	(p.RETCTR_NF != '' AND p.RETCTR_NF IS NOT NULL) AND 
	p.RETSEC_NF IS NULL AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Retro section number must be between 0 and 255
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	p.RETCTR_NF, 0, p.RETSEC_NF, 1,
	@p_ssd_cf, 'L', @p_usr_cf, 260,
	p.NUMLINE_NT, p.UWY_NF, p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	p.RETSEC_NF IS NOT NULL AND 
	(p.RETSEC_NF < 0 OR p.RETSEC_NF > 255) AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Retrocession U/W Year missing
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	p.RETCTR_NF, 0, p.RETSEC_NF, 1,
	@p_ssd_cf, 'L', @p_usr_cf, 30129,
	p.NUMLINE_NT, p.RTY_NF, p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	(p.RETCTR_NF != '' AND p.RETCTR_NF IS NOT NULL) AND 
	p.RTY_NF IS NULL AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Retro U/W Year must be between 1950 and 2050
/*select @error_code = 80005
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	p.RETCTR_NF, 0, p.RETSEC_NF, 1,
	@p_ssd_cf, 'L', @p_usr_cf, @error_code,
	p.NUMLINE_NT, p.RTY_NF, p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	(p.RETCTR_NF != '' AND p.RETCTR_NF IS NOT NULL) AND 
	(p.RTY_NF < 1950 OR p.RTY_NF > 2050) AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" 
	return @erreur
end*/

/*** RETRO - END ***/

-- Accounting Month missing
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 30122,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	p.ACM_NF IS NULL AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Accounting Month must be equal to 3,6,9,12,13
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 30123,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	p.ACM_NF NOT IN (3,6,9,12,13) AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Accounting Year missing
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT 
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 30121,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	p.ACY_NF IS NULL AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Currency missing
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 30124,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	(p.CUR_CF = '' OR p.CUR_CF IS NULL) AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Currency format is incorrect
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 267,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	(p.CUR_CF !=  '' AND p.CUR_CF IS NOT NULL) AND
	(len(p.CUR_CF) != 3) AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- 315: Transaction Code is mandatory
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 315,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	p.DETTRNCOD_CF IS NULL AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Transaction Code must be an integer of 5 characters
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 30131,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, SUBSTRING(p.DETTRNCOD_CF,1,5)
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	(ISNUMERIC(p.DETTRNCOD_CF) != 1 OR CONVERT(int,p.DETTRNCOD_CF) < 10000 OR CONVERT(int,p.DETTRNCOD_CF) > 99999) AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- GAAP number is mandatory
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 30125,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	p.GAAP_NT IS NULL AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- GAAP number must be between 1 and 5
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 30126,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	(p.GAAP_NT < 1 OR p.GAAP_NT > 5) AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Amount missing
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 30127,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	p.ESTMNT_M IS NULL AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Amount too big
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 30128,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	p.ESTMNT_M = -999999999999999.999 AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end

-- wrong file format, not 12 fields 
INSERT INTO #EST_ESIJ0810_TCTRANO
SELECT
	CASE 
		WHEN p.CTR_NF != '' AND p.CTR_NF IS NOT NULL 
		THEN p.CTR_NF
		ELSE p.RETCTR_NF 
	END as CTR_NF,
	0,
	CASE 
		WHEN p.SEC_NF IS NOT NULL 
		THEN p.SEC_NF
		ELSE p.RETSEC_NF 
	END as SEC_NF, 
	1,
	@p_ssd_cf, 'L', @p_usr_cf, 20017,
	p.NUMLINE_NT,
	CASE 
		WHEN p.UWY_NF IS NOT NULL 
		THEN p.UWY_NF
		ELSE p.RTY_NF 
	END as UWY_NF, 
	p.ACY_NF, 1, 
	@p_esb_cf, @p_usr_cf, p.GAAP_NT, p.DETTRNCOD_CF
FROM 
	BTRAV..EST_ESIJ0810_PERIMETER p
WHERE
	p.ESTMNT_M = -999999999999999.998 AND 
	p.SSD_CF = @p_ssd_cf AND 
	p.ESB_CF = @p_esb_cf AND 
	p.USR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20006 "APPLICATIF;#EST_ESIJ0810_TCTRANO" /* inserting error */
	return @erreur
end


-- Store CUR_CF and ESTMNT_M for the acknowledge process
INSERT INTO BTRAV..EST_ESIJ0810_FILECONTENT
SELECT
	@p_fileno_nt as FILENO_NT, NUMLINE_NT, CUR_CF, ESTMNT_M, SSD_CF, ESB_CF, USR_CF
FROM
	BTRAV..EST_ESIJ0810_PERIMETER
	
	
-- Final select
SELECT 
	*
FROM 
	#EST_ESIJ0810_TCTRANO
	

DROP TABLE #EST_ESIJ0810_TCTRANO

go
EXEC sp_procxmode 'PsLIFEST_18_O2', 'unchained'
go
IF OBJECT_ID('PsLIFEST_18_O2') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE PsLIFEST_18_O2 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE PsLIFEST_18_O2 >>>'
go
GRANT EXECUTE ON PsLIFEST_18_O2 TO GOMEGA
go
GRANT EXECUTE ON PsLIFEST_18_O2 TO GDBBATCH
go
