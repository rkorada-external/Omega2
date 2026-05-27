USE BEST
Go

/*
 * DROP PROC dbo.PiLABOCY_01
 */
IF OBJECT_ID('dbo.PiLABOCY_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PiLABOCY_01
    PRINT '<<< DROPPED PROC dbo.PiLABOCY_01 >>>'
END
go


/*
 * creation de la procedure 
*/

create procedure PiLABOCY_01
(
	@p_ssd_cf	USSD_CF,
	@p_vrs_nf	numeric( 10, 0 ),
	@p_segtyp_ct	char(1)
)
     
as

/***************************************************

Programme: PiLABOCY_01

Fichier script associé : ESILAB01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 17/12/97

Description du programme: 
  	- insertion dans la table BEST..TLABOCY
	- insertion dans la table BEST..TSEGEST
 

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


/****************************************/
/* Remplissage des tables d'estimations */
/****************************************/

/* Table TLABOCY */
/*****************/

insert into BEST..TLABOCY ( VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, CRE_D, OCCYEA_NF, SPIRAT_R )
select @p_vrs_nf, SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, @cre_d, OCCYEA_NF, SPIRAT_R
from   BTRAV..ESTPERILABOCY

select @erreur = @@error
if @erreur != 0 
goto fin


/* Table TSEGEST */
/*****************/

insert into BEST..TSEGEST (VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, CRE_D, CUR_CF, PRMAMT_M, CLMAMT_M, LOSRAT_R, AMORAT_CT)
select @p_vrs_nf, SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, @cre_d, CUR_CF, PRMAMT_M, CLMAMT_M, LOSRAT_R, AMORAT_CT
from   BTRAV..ESTPERISEGEST

select @erreur = @@error
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

exec sp_SCOR_INSPRC 'ESILAB01', 'PiLABOCY_01', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PiLABOCY_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PiLABOCY_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PiLABOCY_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiLABOCY_01
 */
GRANT EXECUTE ON dbo.PiLABOCY_01 TO GOMEGA
go

