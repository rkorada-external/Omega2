use BEST
go

IF OBJECT_ID ('dbo.PiLIFNEWBIZ_02') IS NOT NULL
   BEGIN
      DROP PROCEDURE dbo.PiLIFNEWBIZ_02

      IF OBJECT_ID ('dbo.PiLIFNEWBIZ_02') IS NOT NULL
         PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiLIFNEWBIZ_02 >>>'
      ELSE
         PRINT '<<< DROPPED PROCEDURE dbo.PiLIFNEWBIZ_02 >>>'
   END
go

/***** create procedure dbo.PiLIFNEWBIZ_02 *****/
create procedure dbo.PiLIFNEWBIZ_02(
	@p_ssd_cf	USSD_CF,
	@p_esb_cf   UESB_CF,
	@p_usr_cf	UUSR_CF,
	@p_batch_mode UL16 = NULL )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: P.-E. Marx
Date de creation: 10/12/2015
Description du programme:
---------------------------
Controls the coherence of an uploaded New Business file.
If everything is OK, lines are inserted into BEST..TLIFNEWBIZ.
Behavior :
----------------------------
A temporary table is filled with the file's values from a BTRAV table.
When the number of lines differs then anomalies are written in the anomalies table.
Blocking errors mean that no insertion is done in BEST..TLIFNEWBIZ
_________________
Modification 1 - [68527]
Author: Lilian Wernert
Date: 20/06/2018
Description: [68527] - ACY_NF not correctly displayed in the GUI
_________________
Modification 2 - [73848]
Author: Lilian Wernert
Date: 12/12/2018
Description: [73848] - ACY_NF not correctly displayed in the GUI
***************************************************/
declare @erreur				int,
		@error_type			int,
        @tran_imbr			bit,
        @MsgAnomalie		varchar(120),
        @NumMsgAnomalie		varchar(120),	/* Anomaly message identifier */
        @MsgGlobalAnomalie	varchar(240),	/* Final anomaly message */
		@cre_d				datetime,		/* current date */
		@nbligne_testnewbiz	int,			/* number of lines in the input table */
		@nbligne_tempnewbiz	int,			/* number of lines after treatment */
		@nbligne_tctrano	int,				/* number of anomalies lines */
		@blcshtyea_nf 		smallint,
		@blcshtmth_nf 		tinyint,
		@specend_d 			datetime,
		@account_d 			datetime,
		@closing_b 			bit

select @erreur = 0
select @tran_imbr = 1
select @cre_d = getdate()
select @error_type = -1
select @MsgAnomalie = ""
select @NumMsgAnomalie = " - Autres Anomalies Trouvées N° "

/* ------------------------------------------------------------
   Creating temporary tables
 -------------------------------------------------------------- */

create table #TLIFNEWBIZ1 (
	SSD_CF			USSD_CF			NULL,
	ESB_CF			UESB_CF			NULL,
	CTR_NF			UCTR_NF			NULL,
	END_NT			UEND_NT			NULL,
	SEC_NF			USEC_NF			NULL,
	ACY_NF			UUWY_NF			NULL,
	ACMTRS_NT		smallint		NULL,
	CRE_D			UUPD_D			NULL,
	NEWBIZ_R		decimal(9,6)	NULL,
	CREUSR_CF		UUPDUSR_CF		NULL,
	NUMLINE_NT		int	default 0	NULL
 )

-- Deleting anomalies lines

Execute BEST..PdCTRANO_07 @p_ssd_cf,@p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Accès BEST..PdCTRANO_07'
	goto ErreurNorm
    end

-- We remove from btrav..EST_ESID0881_TESTLIFNEWBIZ all subsidiary lines different from the subsidiary
-- use as parameter, it is normally rarely fall in this case, it means
-- that the user has mistakenly entered several subsidiaries in the file

-- Delete the existing lines from BTRAV..EST_ESID0881_TESTLIFNEWBIZ with the appropriate subsidiary from input file and last updated usr_cf

DELETE btrav..EST_ESID0881_TESTLIFNEWBIZ
where
    SSD_CF		!= @p_ssd_cf
and ESB_CF		!= @p_esb_cf
and	CREUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur nettoyage table BTRAV'
	goto ErreurNorm
    end

-- *********************************************************************************************
-- Calculating and storing of number of lines in the table users btrav..EST_ESID0881_TESTLIFNEWBIZ
-- **********************************************************************************************

-- Count the number of lines from btrav..EST_ESID0881_TESTLIFNEWBIZ uploaded from input file

select @nbligne_testnewbiz = count(*) FROM btrav..EST_ESID0881_TESTLIFNEWBIZ
where
	SSD_CF		= @p_ssd_cf
and ESB_CF		= @p_esb_cf
and	CREUSR_CF	= @p_usr_cf


-- **************************************************************************************
--																						*
--       FIRST STEP : AUTOMATIC UPDATING IN SOME FIELDS									*
--																						*
-- **************************************************************************************

-- access to the  BREF..TCALEND table to determinate the entry period
-- -------------------------------------------------------------------

Execute	@erreur = BREF..PsCALEND_02
		@cre_d,
		'E',
		@blcshtyea_nf output,
		@blcshtmth_nf output,
		@specend_d output,
		@account_d output,
		@closing_b output

if @erreur != 0
	begin
	select @MsgAnomalie = 'Erreur Accès BREF..PsCALEND_02'
	goto ErreurNorm
	end

UPDATE btrav..EST_ESID0881_TESTLIFNEWBIZ
SET		CRE_D		= @cre_d
FROM	btrav..EST_ESID0881_TESTLIFNEWBIZ
WHERE	SSD_CF		= @p_ssd_cf
AND		ESB_CF		= @p_esb_cf
AND		CREUSR_CF	= @p_usr_cf

select @erreur = @@error

if @erreur != 0
	begin
	select @MsgAnomalie = "Erreur MAJ btrav..EST_ESID0881_TESTLIFNEWBIZ - Date / user"
	goto ErreurNorm
	end

-- [68527] - START
/*UPDATE btrav..EST_ESID0881_TESTLIFNEWBIZ
SET		ACY_NF		= ACY_NF - @blcshtyea_nf    -- Accounting years are counted relatively in New Business
FROM	btrav..EST_ESID0881_TESTLIFNEWBIZ
WHERE	SSD_CF		= @p_ssd_cf
AND		ESB_CF		= @p_esb_cf
AND		CREUSR_CF	= @p_usr_cf*/
-- [68527] - END

select @erreur = @@error

if @erreur != 0
	begin
	select @MsgAnomalie = "Erreur MAJ btrav..EST_ESID0881_TESTLIFNEWBIZ - ACY"
	goto ErreurNorm
	end

	
-- **********************************************************************************
--																					*
--						SECOND STEP: CHECKING OF CONSISTENCY						*
--			The labels of anomalies below are in the table BREF..TMESSAGE			*
--							it is  referenced by message number						*
--																					*
-- **********************************************************************************

-- -------------------------------------------------------------------------*
--						CHECKING OF ACCOUNTING YEAR							*
--						It should be between 0 and 4						*
--							otherwise message 531							*
-- -------------------------------------------------------------------------*

-- [73848] - START
INSERT into #TLIFNEWBIZ1
select	SSD_CF, ESB_CF, CTR_NF, END_NT, SEC_NF, ACY_NF, ACMTRS_NT, CRE_D, NEWBIZ_R, CREUSR_CF, NUMLINE_NT
FROM	btrav..EST_ESID0881_TESTLIFNEWBIZ
where 	SSD_CF = @p_ssd_cf
and ESB_CF = @p_esb_cf
and	CREUSR_CF = @p_usr_cf
--and ACY_NF BETWEEN 0 AND 4
and ACY_NF - @blcshtyea_nf BETWEEN 0 AND 4
-- [73848] - END

select @erreur = @@error
if @erreur != 0
	begin
	select @MsgAnomalie = 'Erreur Génération TLIFNEWBIZ1 - Anomalie(s) liee(s) a l''annee de compte'
	goto ErreurAno
	end

-- compare the number of lines between EST_ESID0881_TESTLIFNEWBIZ and #TLIFNEWBIZ1
-- generation of an anomaly => anomaly 531
-- --------------------------------------------------------------------------

select @nbligne_tempnewbiz = count(*) FROM #TLIFNEWBIZ1
if ( @nbligne_tempnewbiz = Null ) Select @nbligne_tempnewbiz = 0

if ( @nbligne_tempnewbiz != @nbligne_testnewbiz )
	begin
	select @error_type = 531
	select @MsgAnomalie = 'Anomalie(s) liee(s) au taux'
	select @NumMsgAnomalie = @NumMsgAnomalie + '531 '

	INSERT INTO BTRAV..EST_ESID0881_TCTRANO (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, BLOCKING_B, ESB_CF,UWY_NF,ACY_NF)
	SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "N", @p_usr_cf, @error_type, NUMLINE_NT, 1, ESB_CF,0,ACY_NF
	FROM btrav..EST_ESID0881_TESTLIFNEWBIZ
	WHERE NUMLINE_NT NOT IN (SELECT NUMLINE_NT FROM #TLIFNEWBIZ1)
		and SSD_CF	= @p_ssd_cf
		and ESB_CF	= @p_esb_cf
		and CREUSR_CF	= @p_usr_cf
	end

-- Purge de  #TLIFNEWBIZ1 avant réutilisation
-- ---------------------------------------

DELETE #TLIFNEWBIZ1


-- -------------------------------------------------------------------------*
--						CHECKING OF RATE VALUE								*
--					Rate has to be less than 100%							*
--						otherwise message 5024								*
-- -------------------------------------------------------------------------*

INSERT into #TLIFNEWBIZ1
select	SSD_CF, ESB_CF, CTR_NF, END_NT, SEC_NF, ACY_NF, ACMTRS_NT, CRE_D, NEWBIZ_R, CREUSR_CF, NUMLINE_NT
FROM	btrav..EST_ESID0881_TESTLIFNEWBIZ
where 	SSD_CF = @p_ssd_cf
and 	ESB_CF = @p_esb_cf
and		CREUSR_CF = @p_usr_cf
and 	NEWBIZ_R <= 100

select @erreur = @@error
if @erreur != 0
	begin
	select @MsgAnomalie = 'Erreur Génération TLIFNEWBIZ1 - Anomalie(s) liee(s) au libelle d''inventaire'
	goto ErreurAno
	end

-- compare the number of lines between EST_ESID0881_TESTLIFNEWBIZ and #TLIFNEWBIZ1
-- generation of an anomaly => anomaly 5024
-- --------------------------------------------------------------------------

select @nbligne_tempnewbiz = count(*) FROM #TLIFNEWBIZ1
if ( @nbligne_tempnewbiz = Null ) Select @nbligne_tempnewbiz = 0

if ( @nbligne_tempnewbiz != @nbligne_testnewbiz )
	begin
	select @error_type = 5024
	select @MsgAnomalie = 'Anomalie(s) liee(s) au taux'
	select @NumMsgAnomalie = @NumMsgAnomalie + '5024 '

	INSERT INTO BTRAV..EST_ESID0881_TCTRANO (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, BLOCKING_B, ESB_CF,UWY_NF,ACY_NF)
	SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "N", @p_usr_cf, @error_type, NUMLINE_NT, 0, ESB_CF,0,ACY_NF
	FROM btrav..EST_ESID0881_TESTLIFNEWBIZ
	WHERE NUMLINE_NT NOT IN (SELECT NUMLINE_NT FROM #TLIFNEWBIZ1)
		and SSD_CF	= @p_ssd_cf
		and ESB_CF	= @p_esb_cf
		and CREUSR_CF	= @p_usr_cf
	end

-- Purge de  #TLIFNEWBIZ1 avant réutilisation
-- ---------------------------------------

DELETE #TLIFNEWBIZ1


-- -------------------------------------------------------------------------*
--						CHECKING OF RATE VALUE								*
--						Rate has to be positive								*
--						otherwise message 5025								*
-- -------------------------------------------------------------------------*

INSERT into #TLIFNEWBIZ1
select	SSD_CF, ESB_CF, CTR_NF, END_NT, SEC_NF, ACY_NF, ACMTRS_NT, CRE_D, NEWBIZ_R, CREUSR_CF, NUMLINE_NT
FROM	btrav..EST_ESID0881_TESTLIFNEWBIZ
where	SSD_CF = @p_ssd_cf
and		ESB_CF = @p_esb_cf
and		CREUSR_CF = @p_usr_cf
and		NEWBIZ_R >= 0

select @erreur = @@error
if @erreur != 0
	begin
	select @MsgAnomalie = 'Erreur Génération TLIFNEWBIZ1 - Anomalie(s) liee(s) au libelle d''inventaire'
	goto ErreurAno
	end

-- compare the number of lines between EST_ESID0881_TESTLIFNEWBIZ and #TLIFNEWBIZ1
-- generation of an anomaly => anomaly 5025
-- --------------------------------------------------------------------------

select @nbligne_tempnewbiz = count(*) FROM #TLIFNEWBIZ1
if ( @nbligne_tempnewbiz = Null ) Select @nbligne_tempnewbiz = 0

if ( @nbligne_tempnewbiz != @nbligne_testnewbiz )
	begin
	select @error_type = 5025
	select @MsgAnomalie = 'Anomalie(s) liee(s) au taux'
	select @NumMsgAnomalie = @NumMsgAnomalie + '5025 '

	INSERT INTO BTRAV..EST_ESID0881_TCTRANO (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, BLOCKING_B, ESB_CF,UWY_NF,ACY_NF)
	SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "N", @p_usr_cf, @error_type, NUMLINE_NT, 0, ESB_CF,0,ACY_NF
	FROM btrav..EST_ESID0881_TESTLIFNEWBIZ
	WHERE NUMLINE_NT NOT IN (SELECT NUMLINE_NT FROM #TLIFNEWBIZ1)
		and SSD_CF	= @p_ssd_cf
		and ESB_CF	= @p_esb_cf
		and CREUSR_CF	= @p_usr_cf
	end

-- Purge de  #TLIFNEWBIZ1 avant réutilisation
-- ---------------------------------------

DELETE #TLIFNEWBIZ1

-- -------------------------------------------------------------------------*
--						CHECKING OF ACC T CODE								*
--			Transaction code must be authorized for the grid				*
--						otherwise message 5026								*
-- -------------------------------------------------------------------------*

INSERT into #TLIFNEWBIZ1
select	SSD_CF, ESB_CF, CTR_NF, END_NT, SEC_NF, ACY_NF, ACMTRS_NT, CRE_D, NEWBIZ_R, CREUSR_CF, NUMLINE_NT
FROM	btrav..EST_ESID0881_TESTLIFNEWBIZ a
where 	a.SSD_CF = @p_ssd_cf
and		a.ESB_CF = @p_esb_cf
and		a.CREUSR_CF = @p_usr_cf
and EXISTS(SELECT 1 FROM BTRAV..EST_ESID0881_NEWBIZVAL b
			WHERE	a.CTR_NF = b.CTR_NF
			AND		a.END_NT = b.END_NT
			AND		a.SEC_NF = b.SEC_NF
			AND		a.ACMTRS_NT = b.ACMTRS_NT
)

select @erreur = @@error
if @erreur != 0
	begin
	select @MsgAnomalie = 'Erreur Génération TLIFNEWBIZ1 - Anomalie(s) liee(s) au libelle d''inventaire'
	goto ErreurAno
	end

-- compare the number of lines between EST_ESID0881_TESTLIFNEWBIZ and #TLIFNEWBIZ1
-- generation of an anomaly => anomaly 5026
-- --------------------------------------------------------------------------

select @nbligne_tempnewbiz = count(*) FROM #TLIFNEWBIZ1
if ( @nbligne_tempnewbiz = Null ) Select @nbligne_tempnewbiz = 0

if ( @nbligne_tempnewbiz != @nbligne_testnewbiz )
	begin
	select @error_type = 5026
	select @MsgAnomalie = 'Anomalie(s) liee(s) au poste'
	select @NumMsgAnomalie = @NumMsgAnomalie + '5026 '

	INSERT INTO BTRAV..EST_ESID0881_TCTRANO (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT, BLOCKING_B, ESB_CF,UWY_NF,ACY_NF)
	SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "N", @p_usr_cf, @error_type, NUMLINE_NT, 1, ESB_CF,0,ACY_NF
	FROM btrav..EST_ESID0881_TESTLIFNEWBIZ
	WHERE NUMLINE_NT NOT IN (SELECT NUMLINE_NT FROM #TLIFNEWBIZ1)
		and SSD_CF		= @p_ssd_cf
		and ESB_CF		= @p_esb_cf
		and CREUSR_CF	= @p_usr_cf
	end

-- Purge de  #TLIFNEWBIZ1 avant réutilisation
-- ---------------------------------------

DELETE #TLIFNEWBIZ1


-- -------------------------------------------------------------------------*
--						FINAL SELECTION OF VALUES							*
--		Only values different from the existing ones are inserted			*
--						No associated error message							*
-- -------------------------------------------------------------------------*

INSERT into #TLIFNEWBIZ1
select	SSD_CF, ESB_CF, CTR_NF, END_NT, SEC_NF, ACY_NF, ACMTRS_NT, CRE_D, NEWBIZ_R, CREUSR_CF, NUMLINE_NT
FROM	btrav..EST_ESID0881_TESTLIFNEWBIZ a
where	a.SSD_CF = @p_ssd_cf
and		a.ESB_CF = @p_esb_cf
and		a.CREUSR_CF = @p_usr_cf
and NOT EXISTS (SELECT 1 FROM BTRAV..EST_ESID0881_NEWBIZVAL b
				WHERE	a.CTR_NF = b.CTR_NF
				AND		a.END_NT = b.END_NT
				AND		a.SEC_NF = b.SEC_NF
				AND		a.ACMTRS_NT = b.ACMTRS_NT
				AND		a.NEWBIZ_R = (case a.ACY_NF 
									when 0 then b.NEWBIZ0_R
									when 1 then b.NEWBIZ1_R
									when 2 then b.NEWBIZ2_R
									when 3 then b.NEWBIZ3_R
									when 4 then b.NEWBIZ4_R
									else 0
									end)
)

select @erreur = @@error
if @erreur != 0
	begin
	select @MsgAnomalie = 'Erreur Génération TLIFNEWBIZ1 - Elimination des valeurs existantes'
	goto ErreurAno
	end


-- **********************************************************************************
-- Following thiese checks, values are inserted if no blocking error was detected	*
-- **********************************************************************************

IF EXISTS(SELECT 1 FROM BTRAV..EST_ESID0881_TCTRANO
		WHERE 	BLOCKING_B = 1
		AND		SSD_CF = @p_ssd_cf
		AND		ESB_CF = @p_esb_cf
		AND		SEG_NF = @p_usr_cf)
	BEGIN
	goto Fin
	END


-- **********************************************************************************
--																					*
--					THIRD STEP: ADAPTATION OF VALUES TO TABLE						*
--		Small adjustment made to the rates to accomodate the database format		*
--																					*
-- **********************************************************************************

UPDATE	#TLIFNEWBIZ1
SET		NEWBIZ_R	= NEWBIZ_R/100   -- New Business rates are in decimal(9,8) format
FROM	#TLIFNEWBIZ1
WHERE	SSD_CF		= @p_ssd_cf
AND		ESB_CF		= @p_esb_cf
AND		CREUSR_CF	= @p_usr_cf

select @erreur = @@error

if @erreur != 0
	begin
	select @MsgAnomalie = "Erreur MAJ btrav..EST_ESID0881_TESTLIFNEWBIZ - Rate"
	goto ErreurNorm
	end


-- **********************************************************************
-- Insertion into the table BEST..TLIFNEWBIZ if the checks are OK		*
-- **********************************************************************

-- -------------------------------------------------------------
-- Beginning of the transaction
-- --------------------------------------------------------------

if @@trancount = 0
	begin
		select @tran_imbr = 0
		BEGIN TRAN
	end

-- [73848] - START
UPDATE #TLIFNEWBIZ1
SET		ACY_NF		= ACY_NF - @blcshtyea_nf    -- Accounting years are counted relatively in New Business
FROM	#TLIFNEWBIZ1
WHERE	SSD_CF		= @p_ssd_cf
AND		ESB_CF		= @p_esb_cf
AND		CREUSR_CF	= @p_usr_cf
-- [73848] - END

INSERT	into BEST..TLIFNEWBIZ
		(CTR_NF, END_NT, SEC_NF, ACY_NF, ACMTRS_NT, CRE_D, NEWBIZ_R, CREUSR_CF)
select	CTR_NF, END_NT, SEC_NF, ACY_NF, ACMTRS_NT, CRE_D, NEWBIZ_R, CREUSR_CF
FROM	#TLIFNEWBIZ1

select @erreur = @@error
if @erreur != 0  goto ErreurMAJ

-- *****************************************************************************************
-- Removing lines of btrav..EST_ESID0881_TESTLIFNEWBIZ for the subsidiary and the user
-- *****************************************************************************************

Fin:
--TODO: insert anomalies
INSERT INTO BEST..TCTRANO
Select DISTINCT
	   CTR_NF,
	   END_NT,
	   SEC_NF,
	   VRS_NF,
	   SSD_CF,
	   SEGTYP_CT,
	   SEG_NF,
	   ANO_CT,
	   NUMLINE_NT+1,
	   UWY_NF,
	   ACY_NF
From BTRAV..EST_ESID0881_TCTRANO
WHERE	SSD_CF = @p_ssd_cf
AND		ESB_CF = @p_esb_cf
AND		SEG_NF = @p_usr_cf

DELETE btrav..EST_ESID0881_TESTLIFNEWBIZ
where
	SSD_CF		= @p_ssd_cf
and ESB_CF		= @p_esb_cf
and	CREUSR_CF	= @p_usr_cf

select @erreur = @@error
if @erreur != 0  goto ErreurMAJ

-- -----------------------------------------------------------
--  End of the transaction
-- ------------------------------------------------------------

if @tran_imbr = 0
    COMMIT TRAN
    return 0

-- **********************************************************************************
--								if anomaly detection								*
-- **********************************************************************************

ErreurNorm:
	Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie + @NumMsgAnomalie
	raiserror 20113 @MsgGlobalAnomalie
	return 1


ErreurAno:
	if @p_batch_mode != 'batch'
		BEGIN
			Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie + @NumMsgAnomalie
			raiserror 20113 @MsgGlobalAnomalie
		END    
	return 1

ErreurMAJ:
	if @tran_imbr = 0 ROLLBACK TRAN

	Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie + @NumMsgAnomalie
	raiserror 20113 @MsgGlobalAnomalie
	return 1




EXEC sp_procxmode 'dbo.PiLIFNEWBIZ_02', 'unchained'
go

IF OBJECT_ID ('dbo.PiLIFNEWBIZ_02') IS NOT NULL
	PRINT '<<< CREATED PROCEDURE dbo.PiLIFNEWBIZ_02 >>>'
ELSE
	PRINT '<<< FAILED CREATING PROCEDURE dbo.PiLIFNEWBIZ_02 >>>'
go

GRANT EXECUTE ON dbo.PiLIFNEWBIZ_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiLIFNEWBIZ_02 TO GDBBATCH
go
