use BEST
go

/*
 * DROP PROC dbo.PsSECTION_22
 */
IF OBJECT_ID('dbo.PsSECTION_22') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSECTION_22
    PRINT '<<< DROPPED PROC dbo.PsSECTION_22 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_22
     (
       @p_segtyp_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_seg_d               char(8)
     )
as

/***************************************************

Programme: PsSECTION_22

Fichier script associé : ESSSEC22.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

Création du fichier périmètre SFFPERICASE

Parametres: 

Conditions d'execution: 


Commentaires:

[002] 12/08/2013 -=Dch=-   :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
[003] 02/02/2018 MZM : spira 42213 Arret des estimations pour Traites invalides CTRLCK_B = 1 et Fac Dont Avenant invalides CTRLCK_B =0 
[004] 15/06/2018 MZM : spira 69160 Taxes errones sur FAC : Positionner CTRLCK = 1

*****************************************************/

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr


declare @erreur int

-----------------------
-- Filtre sur les dates
-----------------------

declare @date_maxTRT datetime, @date_maxFAC datetime

EXEC BEST..PsSECTION_32 @date_maxTRT output, @date_maxFAC output, @p_seg_d



---------------------------------------------------------------------
-- Périmètre de souscription pour les traités et les facs SFFPERIPRMD
---------------------------------------------------------------------

-- Cas multifiliale

if @p_ssd_cf = 00
BEGIN
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, CONVERT(char(8), PRMDUE_D, 112), PRMDUE_M, PRMDUECUR_CF, PRMLIN_NT, @p_segtyp_ct, SECTION.SSD_CF
FROM	 BTRT..TSECTION SECTION, 
	 BTRT..TCONTR CONTR, 
       BTRT..TFAMPRMD FAMPRMD
WHERE	 SECSTS_CT IN(14, 15, 16, 17, 18, 19)
     	 and CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
         and CTRLCK_B <> 1 /* [003] */		 
      	 and SECINC_D<=@date_maxTRT
       and LOB_CF<>'30' and LOB_CF<>'31'
       and SECTION.CTR_NF=FAMPRMD.CTR_NF and SECTION.END_NT=FAMPRMD.END_NT and SECTION.SEC_NF=FAMPRMD.SEC_NF and SECTION.UWY_NF=FAMPRMD.UWY_NF and SECTION.UW_NT=FAMPRMD.UW_NT
	 and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
	 and SECTION.SSD_CF in ( select SSD_CF from #ssds)
UNION ALL
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, CONVERT(char(8), PRMDUE_D, 112), PRMDUE_M, PRMDUECUR_CF, PRMLIN_NT, @p_segtyp_ct, SECTION.SSD_CF
FROM	 BFAC..TSECTION SECTION, 
	 BFAC..TCONTR CONTR, 
       BFAC..TFAMPRMD FAMPRMD
WHERE	 SECSTS_CT IN(14, 15, 16, 17, 18, 19)
     	 and CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
         and CTRLCK_B = 1 /* [003] [004]*/		 
      	 and SECINC_D<=@date_maxTRT
       and LOB_CF<>'30' and LOB_CF<>'31'
       and SECTION.CTR_NF=FAMPRMD.CTR_NF and SECTION.END_NT=FAMPRMD.END_NT and SECTION.SEC_NF=FAMPRMD.SEC_NF and SECTION.UWY_NF=FAMPRMD.UWY_NF and SECTION.UW_NT=FAMPRMD.UW_NT
	 and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
 	 and SECTION.SSD_CF in ( select SSD_CF from #ssds)
END


-- Cas monofiliale

ELSE
BEGIN
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, CONVERT(char(8), PRMDUE_D, 112), PRMDUE_M, PRMDUECUR_CF, PRMLIN_NT,  @p_segtyp_ct, SECTION.SSD_CF
FROM	 BTRT..TSECTION SECTION, 
	 BTRT..TCONTR CONTR, 
  BTRT..TFAMPRMD FAMPRMD
WHERE	 SECSTS_CT IN(14, 15, 16, 17, 18, 19)
     	 and CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
         and CTRLCK_B <> 1 /* [003] */		 
      	 and SECINC_D<=@date_maxTRT
       and LOB_CF<>'30' and LOB_CF<>'31'
       and SECTION.SSD_CF=@p_ssd_cf
       and SECTION.CTR_NF=FAMPRMD.CTR_NF and SECTION.END_NT=FAMPRMD.END_NT and SECTION.SEC_NF=FAMPRMD.SEC_NF and SECTION.UWY_NF=FAMPRMD.UWY_NF and SECTION.UW_NT=FAMPRMD.UW_NT
	 and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
UNION ALL
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, CONVERT(char(8), PRMDUE_D, 112), PRMDUE_M, PRMDUECUR_CF, PRMLIN_NT,  @p_segtyp_ct, SECTION.SSD_CF
FROM	 BFAC..TSECTION SECTION, 
	 BFAC..TCONTR CONTR, 
       BFAC..TFAMPRMD FAMPRMD
WHERE	 SECSTS_CT IN(14, 15, 16, 17, 18, 19)
     	 and CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
         and CTRLCK_B = 1 /* [003] [004] */		 
      	 and SECINC_D<=@date_maxTRT
       and LOB_CF<>'30' and LOB_CF<>'31'
       and SECTION.SSD_CF=@p_ssd_cf
       and SECTION.CTR_NF=FAMPRMD.CTR_NF and SECTION.END_NT=FAMPRMD.END_NT and SECTION.SEC_NF=FAMPRMD.SEC_NF and SECTION.UWY_NF=FAMPRMD.UWY_NF and SECTION.UW_NT=FAMPRMD.UW_NT
	 and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
END



   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0
go
IF OBJECT_ID('dbo.PsSECTION_22') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsSECTION_22 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_22 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_22
 */
GRANT EXECUTE ON dbo.PsSECTION_22 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSECTION_22 TO GDBBATCH
go

