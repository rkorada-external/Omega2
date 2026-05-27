use BEST
go

/*
 * DROP PROC dbo.PdACCTRNF_01
 */
IF OBJECT_ID('dbo.PdACCTRNF_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PdACCTRNF_01
    PRINT '<<< DROPPED PROC dbo.PdACCTRNF_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdACCTRNF_01
	(
	   @AnneePerCmp    smallint,       -- Annee de periode de compte
         @MoisPerCmp     tinyint	    -- Mois de periode de compte
      )
as

/***************************************************

Programme: PdACCTRNF_01

Fichier script associé : ESDANF01.PRC


Domaine : (ES) Estimation

Base principale : BCTA

Version: 1

Auteur: ME21 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      purge de la table TACCTRNF de la base BCTA par période de compte

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
        
select @erreur = 0

delete BCTA..TACCTRNF
from  BCTA..TACCTRNF
where (     (    ( datepart(yy,BLCSHT_D) =  @AnneePerCmp)
             and ( datepart(mm,BLCSHT_D) <= @MoisPerCmp )  )
        or  (datepart(yy,BLCSHT_D) <=  @AnneePerCmp )
      )

return @erreur

go
IF OBJECT_ID('dbo.PdACCTRNF_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PdACCTRNF_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PdACCTRNF_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdACCTRNF_01
 */
GRANT EXECUTE ON dbo.PdACCTRNF_01 TO GOMEGA
go

