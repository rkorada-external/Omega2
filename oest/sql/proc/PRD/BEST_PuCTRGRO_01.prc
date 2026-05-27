USE BEST
Go

/*
 * DROP PROC dbo.PuCTRGRO_01
 */
IF OBJECT_ID('dbo.PuCTRGRO_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PuCTRGRO_01
    PRINT '<<< DROPPED PROC dbo.PuCTRGRO_01 >>>'
END
go


/*
 * creation de la procedure 
*/

create procedure PuCTRGRO_01
(
	@p_ssd_cf	USSD_CF,
	@p_vrs_nf	numeric( 10, 0 ),
	@p_segtyp_ct	char(1)
)
     
as

/***************************************************

Programme: PuCTRGRO_01

Fichier script associé : ESUGRO01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 15/12/97

Description du programme: 
     - Mise à jour de la table BEST..TCTRGRO
 

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

/* ----------------------------------------------------------------
   Mise a jour de la table BEST..TCTRGRO
---------------------------------------------------------------- */


update BEST..TCTRGRO
set    DIV_NT=RED.DIV_NT, 
       CED_NF=RED.CED_NF,
       UWGRP_CF=RED.UWGRP_CF,
       LOB_CF=RED.LOB_CF,
       SOB_CF=RED.SOB_CF,
       TOP_CF=RED.TOP_CF,
       NAT_CF=RED.NAT_CF,
       SUBNAT_CF=RED.SUBNAT_CF,
       PCPRSKTRY_CF=RED.PCPRSKTRY_CF,
       SECINC_D=RED.SECINC_D,
       SECCAN_D=RED.EXP_D,
       CTRRET_B=RED.CTRRET_B,
       CRE_D=@cre_d
from   BEST..TCTRGRO CTRGRO, BTRAV..ESTPERIRED RED
where  CTRGRO.SSD_CF=@p_ssd_cf 
and 	CTRGRO.SEGTYP_CT=@p_segtyp_ct 
and 	CTRGRO.VRS_NF=@p_vrs_nf
and 	CTRGRO.CTR_NF=RED.CTR_NF 
and 	CTRGRO.END_NT=RED.END_NT 
and 	CTRGRO.SEC_NF=RED.SEC_NF
and 	CTRGRO.SSD_CF=RED.SSD_CF
and	CTRGRO.SEGTYP_CT=RED.SEGTYP_CT


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

exec sp_SCOR_INSPRC 'ESUGRO01', 'PuCTRGRO_01', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PuCTRGRO_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PuCTRGRO_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PuCTRGRO_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuCTRGRO_01
 */
GRANT EXECUTE ON dbo.PuCTRGRO_01 TO GOMEGA
go

