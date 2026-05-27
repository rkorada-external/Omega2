use BSTA
go

/*
 * DROP PROC */
IF OBJECT_ID('dbo.PsTACCTRN_HISTO_LIGHT_ID') IS NOT NULL
BEGIN
    DROP PROC dbo.PsTACCTRN_HISTO_LIGHT_ID
    PRINT '<<< DROPPED PROC dbo.PsTACCTRN_HISTO_LIGHT_ID >>>'
END
ELSE
    PRINT '<<< dbo.PsTACCTRN_HISTO_LIGHT_ID NOT HERE >>>'
go

/*
 * creation de la procedure PsTACCTRN_HISTO_LIGHT_ID */
create procedure dbo.PsTACCTRN_HISTO_LIGHT_ID

as
/***************************************************
Programme:                  PsTACCTRN_HISTO_LIGHT_ID
Fichier script associé :    ESSAC101.PRC
Domaine :                   (ES) Estimation
Base principale :           BSTA
Version:                    1
Auteur:                     GWENDAL bonnerue
Date de creation:           25/08/2015
Description du programme :  récupérer l'historique des contrats liés aux fins de rez dans le cadre de l'EST26a
*****************************************************/
declare @erreur int

------- On selectionne les mouvements  quotidien de BCTA..TACCTRN flagués dans BCTA..TDRYTRN
------- on l'enrichissant avec d'autres info du contrat acceptation
------- UNION ALL est utilisé car le contrat peut être FAC ou Traité


SELECT
  a.TRN_NT,
   a.SSD_CF,
   a.ESB_CF,
   a.TRNALN_NT,
   a.CTR_NF,
   a.UWY_NF,
   a.UW_NT,
   a.END_NT,
   a.SEC_NF,
   a.ALN_NF,
   a.REB_NF,
   a.ACCTYP_CF,
   a.APR_NT,
   a.PRG_NT,
   a.PRGORD_NT,
   a.CLI_NF,
   a.GRP_CF,
   a.SNTACC_NT,
   a.SCOSTRMTH_NF,
   a.SCOENDMTH_NF,
   a.ACY_NF, 
   a.BLCSHT_D,
   a.TRNSTS_CT,
   a.TRNCOD_CF,
   a.CTRNCOD_CF,
   a.ORICURAMT_M,
   a.CURAMT100_M,
   a.CUR_CF,
   a.SHA_R,
   a.CNVCUR_CF,
   a.CNVAMT_M,
   a.MTH_B,
   a.MTH_D,
   a.VLD_D,
   a.GENLDGTRF_D,
   a.STL_D,
   a.OCCYEA_NF,
   a.INCFMT_CT,
   a.LSTUPD_D,
   a.LSTUPDUSR_CF,
   a.LOB_CF,
   a.SOB_CF,
   a.TOP_CF,
   a.NAT_CF,
   a.SUBNAT_CF,
   a.GAR_CF,
   a.USRCRTCOD_CT,
   a.USRCRTVAL_LM,
   a.PRMLIN_NT,
   a.CED_NF,
   a.LSTTRN_B,
   a.RSVRLSFLG_B,
   a.CLM_NF,
   a.RETFLG_CT,
   a.PAYNBR_NF,
   a.PAYTYP_CT

FROM BSTA..TACCTRN_HISTO a, 
     BTRAVI..TACCTRN_HISTO_LIGHT b
      
where a.CTR_NF = b.CTR_NF 
AND a.CTR_NF =  b.CTR_NF 
AND a.SEC_NF = b.SEC_NF 
AND a.ACY_NF  = b.ACY_NF
go

IF OBJECT_ID('dbo.PsTACCTRN_HISTO_LIGHT_ID') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsTACCTRN_HISTO_LIGHT_ID >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsTACCTRN_HISTO_LIGHT_ID >>>'
go

/*
 * Granting/Revoking Permissions on PsTACCTRN_HISTO_LIGHT_ID */
GRANT EXECUTE ON dbo.PsTACCTRN_HISTO_LIGHT_ID TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTACCTRN_HISTO_LIGHT_ID TO GDBBATCH
go