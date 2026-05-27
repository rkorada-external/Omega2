USE BEST
Go

/*
 * DROP PROC dbo.PuSEGMENT_02
 */
IF OBJECT_ID('dbo.PuSEGMENT_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PuSEGMENT_02
    PRINT '<<< DROPPED PROC dbo.PuSEGMENT_02 >>>'
END
go


/*
 * creation de la procedure 
*/

create procedure PuSEGMENT_02
(
	@p_ssd_cf	USSD_CF,
	@p_vrs_nf	numeric( 10, 0 ),
	@p_segtyp_ct	char(1)
)
     
as

/***************************************************

Programme: PuSEGMENT_02

Fichier script associé : ESUSEG03.PRC

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
            
select @erreur  = 0


/* ----------------------------------------------------------------
   Mise a jour de la table BEST..TSEGMENT
---------------------------------------------------------------- */


update BEST..TSEGMENT
set    ANO_B=1
from   BEST..TSEGMENT SEGMENT, BEST..TSEGANO SEGANO
where  SEGANO.VRS_NF=@p_vrs_nf 
and 	SEGANO.SEGTYP_CT=@p_segtyp_ct 
and 	SEGANO.SSD_CF=@p_ssd_cf
and 	SEGANO.VRS_NF=SEGMENT.VRS_NF 
and 	SEGANO.SSD_CF=SEGMENT.SSD_CF
and 	SEGANO.SEGTYP_CT=SEGMENT.SEGTYP_CT 
and 	SEGANO.SEG_NF=SEGMENT.SEG_NF

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

exec sp_SCOR_INSPRC 'ESUSEG03', 'PuSEGMENT_02', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PuSEGMENT_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PuSEGMENT_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PuSEGMENT_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuSEGMENT_02
 */
GRANT EXECUTE ON dbo.PuSEGMENT_02 TO GOMEGA
go

