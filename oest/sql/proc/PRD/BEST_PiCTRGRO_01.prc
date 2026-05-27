USE BEST
Go

/*
 * DROP PROC dbo.PiCTRGRO_01
 */
IF OBJECT_ID('dbo.PiCTRGRO_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PiCTRGRO_01
    PRINT '<<< DROPPED PROC dbo.PiCTRGRO_01 >>>'
END
go


/*
 * creation de la procedure 
*/

create procedure PiCTRGRO_01
(
	@p_ssd_cf	USSD_CF,
	@p_vrs_nf	numeric( 10, 0 ),
	@p_segtyp_ct	char(1)
)
     
as

/***************************************************

Programme: PiCTRGRO_01

Fichier script associé : ESIGRO01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 15/12/97

Description du programme: 
       - insertion dans la table BEST..TCTRGRO
  	- insertion dans la table BEST..TLABOCY
	- insertion dans la table BEST..TSEGEST
	- insertion dans la table BEST..TSEGMENT
 

Parametres:
 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: 
 
Date:   

Version:

Description:

*****************************************************/


declare 	@erreur     	int,
		@cre_d		datetime
            
  
select @erreur = 0
select @cre_d = getdate()


/* insertion de lignes dans la table BEST..TCTRGRO */
/***************************************************/


insert into BEST..TCTRGRO ( CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, DIV_NT )
select CTR_NF, END_NT, SEC_NF, @p_vrs_nf, SSD_CF, SEGTYP_CT, SEG_NF, 0
from   BTRAV..ESTPERICTRGRO
where	SSD_CF = @p_ssd_cf
and	SEGTYP_CT = @p_segtyp_ct

select @erreur = @@error
if @erreur != 0  
goto fin


/* insertion de lignes dans la table BEST..TLABOCY */
/***************************************************/

insert into BEST..TLABOCY ( VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, CRE_D, OCCYEA_NF, SPIRAT_R )
select @p_vrs_nf, SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, @cre_d, OCCYEA_NF, SPIRAT_R
from   BTRAV..ESTPERILABOCY
where	SSD_CF = @p_ssd_cf
and	SEGTYP_CT = @p_segtyp_ct

select @erreur = @@error
if @erreur != 0  
goto fin


/* insertion de lignes dans la table BEST..TSEGEST */
/***************************************************/

insert into BEST..TSEGEST (VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, CRE_D, CUR_CF, PRMAMT_M, CLMAMT_M, LOSRAT_R, AMORAT_CT)
select @p_vrs_nf, SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, @cre_d, CUR_CF, PRMAMT_M, CLMAMT_M, LOSRAT_R, AMORAT_CT
from   BTRAV..ESTPERISEGEST
where	SSD_CF = @p_ssd_cf
and	SEGTYP_CT = @p_segtyp_ct

select @erreur = @@error
if @erreur != 0  
goto fin


/* insertion de lignes dans la table BEST..TSEGMENT */
/****************************************************/

insert into BEST..TSEGMENT ( VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF )
select distinct @p_vrs_nf, SSD_CF, SEGTYP_CT, SEG_NF
from   BTRAV..ESTPERICTRGRO
where	SSD_CF = @p_ssd_cf
and	SEGTYP_CT = @p_segtyp_ct

select @erreur = @@error
if @erreur != 0  
goto fin


               
/**********************************************************************************/


/**************************************/
/* MISE A JOUR DES TABLES ESTIMATIONS */
/**************************************/

/* enrichissement des lignes insérées dans BEST..TCTRGRO */
/*********************************************************/

exec @erreur = BEST..PuCTRGRO_01 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct with recompile
if @erreur != 0  
goto fin


/* enrichissement des lignes insérées dans BEST..TSEGMENT */
/**********************************************************/

exec @erreur = BEST..PuSEGMENT_01 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct with recompile
if @erreur != 0  
goto fin

fin:
   if @erreur != 0
   begin
   return @erreur
   end


return 0
go


/*
 * fin de la procedure 
 */

/*   Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESUGRO01', 'PiCTRGRO_01', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PiCTRGRO_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PiCTRGRO_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PiCTRGRO_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiCTRGRO_01
 */
GRANT EXECUTE ON dbo.PiCTRGRO_01 TO GOMEGA
go

