use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
 /* DROP PROC dbo.PsSECTION_12
*/
IF OBJECT_ID('dbo.PsSECTION_12') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSECTION_12
   PRINT '<<< DROPPED PROC dbo.PsSECTION_12 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_12
     (
       @p_segtyp_ct           char(1),
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PsSECTION_12

Fichier script associé : ESSSEC12.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Estimation - Actuariat (Lot 6)

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

declare @erreur int

-- Actuariat

-- ATTENTION VRS_NF ENLEVE DU HAVING !!!!!

DECLARE @vrs_nf numeric(10,0)

SELECT @vrs_nf=(SELECT VRS_NF
                FROM   TVERPAR
                GROUP  BY SSD_CF, SEGTYP_CT
                HAVING SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct and PAR_D=MAX(PAR_D))

SELECT CTRULT.CTR_NF, CTRULT.END_NT, CTRULT.SEC_NF, CTRULT.UWY_NF, CTRULT.UW_NT, SEG_NF, RETAMTPRM_M, RETAMTCLM_M, NULL, RETAMT_M, ADMMOD_CT
FROM   BEST..TCTRULT CTRULT, BEST..TCTRGRO CTRGRO, BEST..TCTREST CTREST
GROUP  BY CTRULT.CTR_NF, CTRULT.END_NT, CTRULT.SEC_NF, CTRULT.UWY_NF, CTRULT.UW_NT
HAVING CTRULT.SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
       and CTREST.PRS_CF=1 and CTREST.ACMTRS_NT=2000
       and CTRULT.CRE_D=MAX(CTRULT.CRE_D) and CTREST.CRE_D=MAX(CTREST.CRE_D)
       and CTRULT.CTR_NF=CTRGRO.CTR_NF and CTRULT.END_NT=CTRGRO.END_NT and CTRULT.SEC_NF=CTRGRO.SEC_NF
       and CTRULT.CTR_NF=CTREST.CTR_NF and CTRULT.END_NT=CTREST.END_NT and CTRULT.SEC_NF=CTREST.SEC_NF and CTRULT.UWY_NF=CTREST.UWY_NF and CTRULT.UW_NT=CTREST.UW_NT
      

   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSEC12', 'PsSECTION_12', 'BEST', 'ME31'
go

IF OBJECT_ID('dbo.PsSECTION_12') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSECTION_12 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_12 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_12
 */
GRANT EXECUTE ON dbo.PsSECTION_12 TO GOMEGA
go

