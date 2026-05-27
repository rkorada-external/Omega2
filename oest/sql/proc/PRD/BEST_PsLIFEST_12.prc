USE BEST
go
IF OBJECT_ID('dbo.PsLIFEST_12') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFEST_12
    IF OBJECT_ID('dbo.PsLIFEST_12') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFEST_12 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFEST_12 >>>'
END
go
-- creation de la procedure

create procedure PsLIFEST_12
	(
	@p_balshtyea_nf	 smallint
    )
with execute as caller as

/***************************************************

Programme: PsLIFEST_12

Fichier script associé : ESSEST09.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME27 avec Infotool version 2.0

Date de creation:

Description du programme:

      Sélection d'enregistrement dans TLIFEST

Parametres:

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1
Auteur: ANB
Date: 10/9/98
Version: 2
Description: Ajout du test sur le bilan en cours
_________________
MODIFICATION 2
Auteur: GIBU
Date: 04/09/2003
Version: 3
Description: Ajout du parametre BALSHTMTH_NF pour limiter extraction
             Suite au deblocage de la saisie en periode exceptionnelle
             il est possible d'avoir des lignes sur une periode
             posterieure a celle a traiter. Il ne faut pas les prendre
_________________
MODIFICATION 3
Auteur      : T.RIPERT
Date        : 04/09/2003
Version     : 3
Description : Exclusion des postes 1900 et 1901
_________________
MODIFICATION 4
Auteur      : JF VDV
Date        : 10.1
Description : [20198] - Eviter les doublons dans TLIFEST (cas inventaire en journee)
_________________
MODIFICATION 5
Description : Removed dbo and added ?with execute as caller as?
[006] 06/01/2014 R. BEN EZZINE :spot:25427  - Extraction des derniers mouvements uniquement pour insertion en incremental dans la Tlifest
_________________
MODIFICATION 5
Description : Removed dbo and added ?with execute as caller as?
[006] 15/05/2014 R. BEN EZZINE - version 2B
*****************************************************/


SELECT  SSD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        ACY_NF,
        convert(char(8),CRE_D,112) + ' ' + convert(char(8),CRE_D,108),
        PRS_CF,
        ACMTRS_NT,
        BALSHEY_NF,
        BALSHTMTH_NF,
        CUR_CF,
        ESTMNT_M,
        INDSUP_B,
        ORICOD_LS,
        CREUSR_CF,
        LSTUPD_D,
        LSTUPDUSR_CF,
        DETTRNCOD_CF,
        DETTRS_CF= ' ',
        GAAP_NT,  
        DIFF_M,
        PROPAGATION_B,
        ACM_NF,
        ORICTR_NF,
        ORISEC_NF,
        ORIUWY_NF,
        UPD_NF        = ' ',
        LOB_CF        = '  ',
        ACCSTS_CT     = 0,
        ACCADMTYP_CT  = 0,
        ESTCRB_CT     = NULL,
        CED_NF        = NULL,
        BRK_NF        = 0,
        SPIMOD_CT     = NULL,
        PAY_NF        = NULL,
        NAT_CF        = NULL,
        GANPAYORD_NT  = NULL,
        ADJCOD_CT     = NULL,
        RETCOD_CT     = NULL,
        ACCRET_B      = 0,
        ESB_CF        = 0,
        LIFTRTTYP_CF  = ' ',
        UWGRP_CF      = 0,
        CNATYP_CT     = 0,
        RENOUV_B      = 0,
        CLOPRD        = 0,
        DBCLO_D       = 0, 
        ORICRE_D      = 0, 
        ORISSD_CF     = 0,
        BATCH_B       = 0,
        NBCOLNEW      = 0,
        NBCOL         = 0

  FROM BEST..TLIFEST a
  where a.BALSHEY_NF    = @p_balshtyea_nf
  and acmtrs_nt%10 in (3,4)
  and SSD_CF in (1,2,3,4,5,6,7,12,15,16,17,18,19,23)
 and a.CRE_D=(select max(b.CRE_D) from BEST..TLIFEST b
                where b.CTR_NF=a.CTR_NF
                and      b.END_NT=a.END_NT
                and b.UWY_NF=a.UWY_NF
                and b.UW_NT=a.UW_NT
                and b.SEC_NF=a.SEC_NF
                and b.ACY_NF=a.ACY_NF
                and b.BALSHEY_NF=a.BALSHEY_NF
                and b.BALSHTMTH_NF=a.BALSHTMTH_NF
                and b.PRS_CF=a.PRS_CF
                and b.ACMTRS_NT=a.ACMTRS_NT
                and b.GAAP_NT=a.GAAP_NT
                and b.DETTRNCOD_CF=a.DETTRNCOD_CF )

return 0
go
EXEC sp_procxmode 'dbo.PsLIFEST_12', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFEST_12') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFEST_12 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFEST_12 >>>'
go
GRANT EXECUTE ON dbo.PsLIFEST_12 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFEST_12 TO GDBBATCH
go
