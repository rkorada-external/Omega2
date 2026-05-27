USE BEST
go
IF OBJECT_ID('dbo.PsTCTRGRO_ONE') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTCTRGRO_ONE
    IF OBJECT_ID('dbo.PsTCTRGRO_ONE') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTCTRGRO_ONE >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTCTRGRO_ONE >>>'
END
go

/***************************************************

Programme: PsTCTRGRO_ONE
Fichier script associ� : ESCJ0662.cmd
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: David Da Silva Teixeira
Date de creation: 11/04/2023
Description du programme: 
    - Extraction SSD_CF pour les CTRGRO Onerous 
Parametres: 
Conditions d'execution: 
Commentaires:
[001]  11/04/2023  DaD  108809  New proc
[002]  26/04/2024  DaD  111529  replace the NOT IN by IN with theses statuses and reduced to 12 and 14 for fac, 12 for trt
*****************************************************/
create procedure dbo.PsTCTRGRO_ONE
  (
  @P_PRDSIT_CF    varchar(4) = 'SGP1'
  )
as

    declare @erreur int
    select @erreur = 0

    SELECT distinct 
        T3.SSD_CF,
        null,
        T3.CTR_NF,
        T3.END_NT,
        T3.SEC_NF,
        T3.UWY_NF,
        T3.UW_NT
    FROM BTRT..TCONTR T1, BTRT..TSECTION T3, BTRT..TSECIFRS T2, BREF..TSUBSID T4
    WHERE T1.CTR_NF = T2.CTR_NF
        AND T1.UWY_NF = T2.UWY_NF
        AND T1.UW_NT = T2.UW_NT
        AND T1.END_NT = T2.END_NT
        AND T1.CTR_NF = T3.CTR_NF
        AND T1.UWY_NF = T3.UWY_NF
        AND T1.UW_NT = T3.UW_NT
        AND T1.END_NT = T3.END_NT
        AND T2.SEC_NF = T3.SEC_NF
        AND T1.CTRSTS_CT IN (12)
        AND T2.FRCIFRSBTCH_NT = 1                     --Onerous forced by users
        AND T3.SECACCSTS_CT != 9
        AND T1.SSD_CF = T4.SSD_CF
        AND T3.SSD_CF = T4.SSD_CF
        AND T4.PRDSIT_CF = @P_PRDSIT_CF
    UNION
    SELECT distinct 
        T3.SSD_CF,
        null,
        T3.CTR_NF,
        T3.END_NT,
        T3.SEC_NF,
        T3.UWY_NF,
        T3.UW_NT
    FROM BFAC..TCONTR T1, BFAC..TSECTION T3, BFAC..TSECIFRS T2, BREF..TSUBSID T4
    WHERE T1.CTR_NF = T2.CTR_NF
        AND T1.UWY_NF = T2.UWY_NF
        AND T1.UW_NT = T2.UW_NT
        AND T1.END_NT = T2.END_NT
        AND T1.CTR_NF = T3.CTR_NF
        AND T1.UWY_NF = T3.UWY_NF
        AND T1.UW_NT = T3.UW_NT
        AND T1.END_NT = T3.END_NT
        AND T2.SEC_NF = T3.SEC_NF
        AND T1.CTRSTS_CT IN (12, 14)
        AND T2.FRCIFRSBTCH_NT = 1                     --Onerous forced by users
        AND T3.SECACCSTS_CT != 9
        AND T1.SSD_CF = T4.SSD_CF
        AND T3.SSD_CF = T4.SSD_CF
        AND T4.PRDSIT_CF = @P_PRDSIT_CF

    select @erreur = @@error
    if @erreur != 0
    begin
        return @erreur
    end

    return 0

go
IF OBJECT_ID('dbo.PsTCTRGRO_ONE') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTCTRGRO_ONE >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTCTRGRO_ONE >>>'
go
GRANT EXECUTE ON dbo.PsTCTRGRO_ONE TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTCTRGRO_ONE TO GDBBATCH
go
