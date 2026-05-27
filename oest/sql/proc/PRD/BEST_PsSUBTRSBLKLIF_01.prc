USE BEST
go
IF OBJECT_ID('dbo.PsSUBTRSBLKLIF_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsSUBTRSBLKLIF_01
    IF OBJECT_ID('dbo.PsSUBTRSBLKLIF_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsSUBTRSBLKLIF_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsSUBTRSBLKLIF_01 >>>'
END
go
/*
 * creation de la procedure 
 */

create procedure dbo.PsSUBTRSBLKLIF_01
	
as

/***************************************************

Programme: PsSUBTRSBLKLIF_01
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
MODIFICATION 1
Auteur:
Date:
Version:
Description:
*****************************************************/
 
   
 
 SELECT BLOCK_NF ,  
        PCPTRS_CF, 
        TRS_CF,
        SUBTRS_CF, 
        RANKORDER_NB, 
        LSTUPD_D, 
        LSTUPDUSR_CF
   FROM BREF..TSUBTRSBLOCKLIFEST 
  ORDER BY PCPTRS_CF,
           TRS_CF,
           SUBTRS_CF  
go
EXEC sp_procxmode 'dbo.PsSUBTRSBLKLIF_01', 'unchained'
go
IF OBJECT_ID('dbo.PsSUBTRSBLKLIF_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsSUBTRSBLKLIF_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsSUBTRSBLKLIF_01 >>>'
go
GRANT EXECUTE ON dbo.PsSUBTRSBLKLIF_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSUBTRSBLKLIF_01 TO GDBBATCH
go
