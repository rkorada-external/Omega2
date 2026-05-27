USE BEST
go
IF OBJECT_ID('dbo.PsLIFDRI_ALL_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFDRI_ALL_01
    IF OBJECT_ID('dbo.PsLIFDRI_ALL_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFDRI_ALL_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFDRI_ALL_01 >>>'
END
go
/*
 * creation de la procedure 
 */

create procedure dbo.PsLIFDRI_ALL_01
	(
	@p_balshtyea_nf	 smallint,
    @p_balshtmth_nf  tinyint
	)
with execute as caller as

/***************************************************

Programme: PsLIFDRI_ALL_01
Fichier script associé : 
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: R. BEN EZZINE
Date de creation: 07/01/2014
Description du programme: 

Parametres: aucun
Conditions d'execution: 
Commentaires: servira en estimation pour la fonction 
_________________
[001] 07/16/2014 R. BEN EZZINE :spot:25773 Ajout du champs RESPROPAG_B
[002] 08/27/2014 S. GOLDSTEIN  :spot:27290 Ajout des colonnes END_NT et SEC_NF dans les sous requêtes
[003] 09/23/2014 R. BEN EZZINE :spot:25773 Ajout des paramètres en entrée @p_balshtyea_nf et @p_balshtmth_nf
[004] 02/06/2016 S. BEHAGUE :spot:30300 Ajout du champs SEGUPD_B EST39 
***********************************************************************/

SELECT    A.CTR_NF
        , A.END_NT
        , A.SEC_NF
        , A.UWY_NF
        , A.UW_NT
        , A.ACY_NF
        , A.SSD_CF
        , A.BALSHEY_NF
        , A.BALSHTMTH_NF
        , A.AUTUPD_B
        , A.COMACC_B
        , A.RESPROPAG_B --[001]
        , A.SEGUPD_B        --[004]
        , Convert(Char(8), A.CRE_D, 112) + ' ' + Convert(Char, A.CRE_D, 108) CRE_D
        , A.CMT_NT
        , A.CREUSR_CF
        , Convert(Char, A.LSTUPD_D, 109) LSTUPD_D
        , A.LSTUPDUSR_CF
 FROM     BEST..TLIFDRI  A
        , BTRAV..TESTSSD E
 WHERE    A.SSD_CF     = E.SSD_CF
   AND    A.BALSHEY_NF = ( SELECT    Max(B.BALSHEY_NF) 
                           FROM      BEST..TLIFDRI B
                           WHERE     B.CTR_NF = A.CTR_NF
                             AND     B.END_NT = A.END_NT                   --[002]
                             AND     B.ACY_NF = A.ACY_NF
                           GROUP BY  B.CTR_NF
                                   , B.END_NT                              --[002]
                                   , B.ACY_NF
                         )
  AND     A.CRE_D      = ( SELECT    Max(C.CRE_D)
                           FROM      BEST..TLIFDRI C
                           WHERE     C.CTR_NF = A.CTR_NF
                             AND     C.END_NT = A.END_NT                   --[002]
                             AND     C.SEC_NF = A.SEC_NF                   --[002]
                             AND     C.ACY_NF = A.ACY_NF
                           GROUP BY  C.CTR_NF
                                   , C.END_NT                              --[002]
                                   , C.SEC_NF
                                   , C.ACY_NF                              --[002]
                         )
  AND     A.CTR_NF    != '         '
  AND     A.UWY_NF     = A.ACY_NF
--[003] 
  AND  ( A.BALSHEY_NF   < @p_balshtyea_nf OR A.BALSHTMTH_NF !> @p_balshtmth_nf)
ORDER BY  A.CTR_NF
        , A.SEC_NF
        , A.ACY_NF
        , A.AUTUPD_B
        , A.COMACC_B
        , A.BALSHEY_NF

RETURN 0
go
EXEC sp_procxmode 'dbo.PsLIFDRI_ALL_01', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFDRI_ALL_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFDRI_ALL_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFDRI_ALL_01 >>>'
go
GRANT EXECUTE ON dbo.PsLIFDRI_ALL_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFDRI_ALL_01 TO GDBBATCH
go
