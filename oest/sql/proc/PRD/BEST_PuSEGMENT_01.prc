USE BEST
Go

/*
 * DROP PROC dbo.PuSEGMENT_01
 */
IF OBJECT_ID('dbo.PuSEGMENT_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PuSEGMENT_01
    PRINT '<<< DROPPED PROC dbo.PuSEGMENT_01 >>>'
END
go


/*
 * creation de la procedure 
*/

create procedure PuSEGMENT_01
(
	@p_ssd_cf	USSD_CF,
	@p_vrs_nf	numeric( 10, 0 ),
	@p_segtyp_ct	char(1)
)
     
as

/***************************************************

Programme: PuSEGMENT_01

Fichier script associé : ESUSEG02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 15/12/97

Description du programme: 
     - Mise à jour de la table BEST..TSEGMENT
 

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


declare 	@erreur     	int
            
select @erreur = 0


/* ----------------------------------------------------------------
   Mise a jour de la table BEST..TSEGMENT
---------------------------------------------------------------- */

update BEST..TSEGMENT
set    SEG_LL = SEGEST.SEG_LL,
       CUR_CF = SEGEST.CUR_CF,
       SEGNAT_CT = SEGEST.SEGNAT_CT,
       CTRRET_B = SEGEST.CTRRET_B
from   BEST..TSEGMENT SEGMENT, BTRAV..ESTPERISEGEST SEGEST
where  SEGMENT.VRS_NF = @p_vrs_nf
and	SEGMENT.SSD_CF = @p_ssd_cf
and	SEGMENT.SEGTYP_CT = @p_segtyp_ct

and	SEGEST.SEG_NF=SEGMENT.SEG_NF
and	SEGEST.SSD_CF = SEGMENT.SSD_CF
and	SEGEST.SEGTYP_CT = SEGMENT.SEGTYP_CT
and    SEGEST.UWY_NF = ( select max (SEGEST2.UWY_NF)
				from BTRAV..ESTPERISEGEST SEGEST2
				where 
					SEGEST2.SEG_NF = SEGEST.SEG_NF
				and	SEGEST2.SSD_CF = SEGEST.SSD_CF
				and	SEGEST2.SEGTYP_CT = SEGEST.SEGTYP_CT
			)


/*
update BEST..TSEGMENT
set    SEG_LL = SEGEST.SEG_LL,
       CUR_CF = SEGEST.CUR_CF,
       SEGNAT_CT = SEGEST.SEGNAT_CT,
       CTRRET_B = SEGEST.CTRRET_B
from   BEST..TSEGMENT SEGMENT, BTRAV..ESTPERISEGEST SEGEST
where  SEGMENT.VRS_NF = @p_vrs_nf
and	SEGMENT.SSD_CF = @p_ssd_cf
and	SEGMENT.SEGTYP_CT = @p_segtyp_ct
and	SEGMENT.SEG_NF=SEGEST.SEG_NF
--having SEGEST.UWY_NF = max( SEGEST.UWY_NF )
*/
select @erreur = @@error
if @erreur != 0  
goto fin

               
/**********************************************************************************/

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

exec sp_SCOR_INSPRC 'ESUSEG02', 'PuSEGMENT_01', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PuSEGMENT_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PuSEGMENT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PuSEGMENT_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuSEGMENT_01
 */
GRANT EXECUTE ON dbo.PuSEGMENT_01 TO GOMEGA
go

