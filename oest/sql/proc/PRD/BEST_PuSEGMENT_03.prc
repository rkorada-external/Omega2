USE BEST
Go

/*
 * DROP PROC dbo.PuSEGMENT_03
 */
IF OBJECT_ID('dbo.PuSEGMENT_03') IS NOT NULL
BEGIN
    DROP PROC dbo.PuSEGMENT_03
    PRINT '<<< DROPPED PROC dbo.PuSEGMENT_03 >>>'
END
go


/*
 * creation de la procedure 
*/

create procedure PuSEGMENT_03
(
	@p_ssd_cf	USSD_CF,
	@p_vrs_nf	numeric( 10, 0 ),
	@p_segtyp_ct	char(1)
)
     
as

/***************************************************

Programme: PuSEGMENT_03

Fichier script associé : ESUSEG04.PRC

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
from   BEST..TSEGMENT SEGMENT, BEST..TCTRANO CTRANO
where  CTRANO.VRS_NF=@p_vrs_nf 
and 	CTRANO.SEGTYP_CT=@p_segtyp_ct 
and 	CTRANO.SSD_CF=@p_ssd_cf
and 	CTRANO.VRS_NF=SEGMENT.VRS_NF
and 	CTRANO.SSD_CF=SEGMENT.SSD_CF
and 	CTRANO.SEGTYP_CT=SEGMENT.SEGTYP_CT 
and 	CTRANO.SEG_NF=SEGMENT.SEG_NF 

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

exec sp_SCOR_INSPRC 'ESUSEG03', 'PuSEGMENT_03', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PuSEGMENT_03') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PuSEGMENT_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PuSEGMENT_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuSEGMENT_03
 */
GRANT EXECUTE ON dbo.PuSEGMENT_03 TO GOMEGA
go

