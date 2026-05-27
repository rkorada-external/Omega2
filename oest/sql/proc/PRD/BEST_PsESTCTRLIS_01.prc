USE BEST
Go

/*
 * DROP PROC PsESTCTRLIS_01
 */
IF OBJECT_ID('PsESTCTRLIS_01') IS NOT NULL
BEGIN
    DROP PROC PsESTCTRLIS_01
    PRINT '<<< DROPPED PROC PsESTCTRLIS_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsESTCTRLIS_01
     
with execute as caller as

/***************************************************

Programme: PsESTCTRLIS_01

Fichier script associé : ESSLIS01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 24/06/97

Description du programme: 
     - Séléction de toutes les lignes de la table TESTCTRLIS.
 

Parametres:
 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: HA-THUC
 
Date:   17/09/97

Version: 2

Description : Removed dbo and added ‘with execute as caller as’

[001] 19/05/2014 R. Cassis  :spot:26775 Omega2 1B - Ajout as caller
*****************************************************/


declare @erreur      int,
        @tran_imbr	  bit
        

select @erreur = 0
select @tran_imbr = 1


/* ------------------------------------------------------------
   Sélection des lignes
 -------------------------------------------------------------- */

select 
    CTR_NF,
    UWY_NF,
    UW_NT,
    END_NT,
    SEC_NF,
    DIV_NT,
    UWRSPUSR_CF,
    ADMUSR_CF,
    SECLAB_LM,
    SSD_CF,
    SECACCSTS_CT,
    ESTEND_B,
    EVTCOD_NF,
    CTRNAT_CT,
    ESTUPDTYP_CT,
    LOB_CF,
    SOB_CF,
    PCPRSKTRY_CF,
    ACCADMTYP_CT,
    SCOORGEGP_M,
    SCOGLOEGP_M,
    EGPCUR_CF,
    PMLRAT_R,
    CUTSHA_R,
    RIDSHA_R,
    LIARIDSHA_B,
    SCOEGPCAL_B,
    EGPLESSCO_M,
    PRMFLCRAT_B,
    PRMFIXEFF_R,
    PRMMINEFF_R,
    PRMMAXEFF_R,
    SUPLOATYP_CT,
    PRMEFFLOA_M,
    PRMEFFLOA_R,
    SBJPRMCUR_CF,
    ESTSBJPRM_M,
    DEFSBJPRM_M,
    SBJPRMCPT_M,
    REIEXI_B,
    REIUNL_B,
    REIFRE_B,
    REINBR_N,
    LAYCAP_M,
    FLAPRM_B,
    SBJCPTDEF_B,
    PMDEGPCUR_M,
    CPLACCY_NF,
    SCOLSTMTH_NF,
    convert(char(8),EXP_D,112)
from BTRAV..TESTCTRLIS


select @erreur = @@error

if @erreur != 0  goto fin


               
/**********************************************************************************/

return 0

fin:

return 1
go

/*
 * fin de la procedure 
 */

/*   Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSLIS01', 'PsESTCTRLIS_01', 'BEST', 'ME69'
go

IF OBJECT_ID('PsESTCTRLIS_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsESTCTRLIS_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsESTCTRLIS_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsESTCTRLIS_01
 */
GRANT EXECUTE ON PsESTCTRLIS_01 TO GOMEGA
go
GRANT EXECUTE ON PsESTCTRLIS_01 TO GDBBATCH
go

