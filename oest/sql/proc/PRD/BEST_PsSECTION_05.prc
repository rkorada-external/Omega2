use BEST
go

IF OBJECT_ID('dbo.PsSECTION_05') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsSECTION_05
    IF OBJECT_ID('dbo.PsSECTION_05') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsSECTION_05 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsSECTION_05 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PsSECTION_05
     (
       @p_segtyp_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_seg_d               char(8)
     )
as

/***************************************************

Programme: PsSECTION_05

Fichier script associé : ESSSEC05.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:
	- création du fichier périmètre (S/I)ADPERIFCT

Parametres:

Conditions d'execution:
Test:
BEST..PsSECTION_05 '1' , 2 , '20180501' 

Commentaires:

[002] 19/08/2013 -=Dch=-   :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
[003] 05/02/2018 MZM : spira 42213 Arret des estimations pour Traites invalides CTRLCK_B = 1 et Fac Dont Avenant invalides CTRLCK_B =0 
[004] 15/06/2018 MZM : spira 69160 Calcul des TAxes en anomalie : Pour les FAC : CTRLCK_B = 1 
[005] 09/05/2018 MNA : spot 61503 ajout de la colonne TAXBAS_CT
[006] 12/07/2019 MIS : spira 79763 force TAXBAS_CF a 1

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


--------------------------------------------------------------------
-- Périmètre de souscription pour les traités et les facs SFFPERIFCT
--------------------------------------------------------------------

-- Cas multifiliale

if @p_ssd_cf = 00
BEGIN
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, @p_segtyp_ct, SECTION.SSD_CF, TAX_R, TAXLIN_NT, TAXTYP_CT, CNATYP_CT, 1 AS TAXBAS_CF
FROM   BTRT..TSECTION SECTION,
       BTRT..TCONTR CONTR,
       BTRT..TFAMCHGT FAMCHGT
WHERE SECSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRLCK_B <> 1 --[003]
and   SECINC_D<=@date_maxTRT
and   LOB_CF<>'30' and LOB_CF<>'31'
and   SECTION.CTR_NF=FAMCHGT.CTR_NF and SECTION.UWY_NF=FAMCHGT.UWY_NF and SECTION.UW_NT=FAMCHGT.UW_NT and SECTION.END_NT=FAMCHGT.END_NT and SECTION.SEC_NF=FAMCHGT.SEC_NF
and   SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
and   SECTION.SSD_CF in ( select SSD_CF from #ssds )
UNION ALL
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, @p_segtyp_ct, SECTION.SSD_CF, TAX_R, TAXLIN_NT, TAXTYP_CT,  CNATYP_CT, 1 AS TAXBAS_CF
FROM BFAC..TSECTION SECTION,
     BFAC..TCONTR CONTR,
     BFAC..TFAMCHGT FAMCHGT
WHERE SECSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRLCK_B = 1 --[003] [004]
and   SECINC_D<=@date_maxTRT
and   LOB_CF<>'30' and LOB_CF<>'31'
and   SECTION.CTR_NF=FAMCHGT.CTR_NF and SECTION.UWY_NF=FAMCHGT.UWY_NF and SECTION.UW_NT=FAMCHGT.UW_NT and SECTION.END_NT=FAMCHGT.END_NT and SECTION.SEC_NF=FAMCHGT.SEC_NF
and   SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
and   isnull(FAMCHGT.TAXREF_CT,1) not in (2, 3)
and   SECTION.SSD_CF in ( select SSD_CF from #ssds )
END

-- Cas monofiliale

ELSE
BEGIN
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, @p_segtyp_ct, SECTION.SSD_CF, TAX_R, TAXLIN_NT, TAXTYP_CT,  CNATYP_CT, 1 AS TAXBAS_CF
FROM BTRT..TSECTION SECTION,
     BTRT..TCONTR CONTR,
     BTRT..TFAMCHGT FAMCHGT
WHERE SECSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRLCK_B <> 1 --[003]
and   SECINC_D<=@date_maxTRT
and   LOB_CF<>'30' and LOB_CF<>'31'
and   SECTION.SSD_CF=@p_ssd_cf
and   SECTION.CTR_NF=FAMCHGT.CTR_NF and SECTION.UWY_NF=FAMCHGT.UWY_NF and SECTION.UW_NT=FAMCHGT.UW_NT and SECTION.END_NT=FAMCHGT.END_NT and SECTION.SEC_NF=FAMCHGT.SEC_NF
and   SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
UNION ALL
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, @p_segtyp_ct, SECTION.SSD_CF, TAX_R, TAXLIN_NT, TAXTYP_CT,  CNATYP_CT , 1 AS TAXBAS_CF
FROM BFAC..TSECTION SECTION,
     BFAC..TCONTR CONTR,
     BFAC..TFAMCHGT FAMCHGT
WHERE SECSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
and   CTRLCK_B = 1 --[003] [004]
and   SECINC_D<=@date_maxTRT
and   LOB_CF<>'30' and LOB_CF<>'31'
and   SECTION.SSD_CF=@p_ssd_cf
and   SECTION.CTR_NF=FAMCHGT.CTR_NF and SECTION.UWY_NF=FAMCHGT.UWY_NF and SECTION.UW_NT=FAMCHGT.UW_NT and SECTION.END_NT=FAMCHGT.END_NT and SECTION.SEC_NF=FAMCHGT.SEC_NF
and   SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
and   isnull(FAMCHGT.TAXREF_CT,1) not in (2, 3)
END

   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0
go
IF OBJECT_ID('dbo.PsSECTION_05') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsSECTION_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsSECTION_05 >>>'
go
GRANT EXECUTE ON dbo.PsSECTION_05 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSECTION_05 TO GDBBATCH
go
 
