USE BEST
GO

 /* DROP PROC dbo.PsTCONTR_19
*/
IF OBJECT_ID('dbo.PsTCONTR_19') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsTCONTR_19
   PRINT '<<< DROPPED PROC dbo.PsTCONTR_19 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsTCONTR_19  ( @p_ctr_nf  UCTR_NF,
                                                        @p_s_typ     Char(1) )

as

/***************************************************

Programme: PsTCONTR_19

Fichier script associé : best_PsTCONTR_19.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME57

Date de creation: 20/04/2004

Description du programme:
   Recherche des contrat avec ctrtyp_ct à '19'

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
declare @uwy_nf int

IF @p_s_typ = 'A'
BEGIN

       select @uwy_nf = max(uwy_nf) from btrt..tcontr where ctr_nf =  @p_ctr_nf

        SELECT 	ctrsts_ct
        FROM   BTRT..TCONTR
        WHERE      ctr_nf    = @p_ctr_nf
        and              uwy_nf  = @uwy_nf

           select @erreur = @@error

           if @erreur != 0
           begin
              return @erreur
           end
END
ELSE
BEGIN

       select @uwy_nf = max(RTY_NF) from BRET..TRETCTR where retctr_nf =  @p_ctr_nf

      SELECT  retctrsts_ct
        FROM   BRET..TRETCTR
        WHERE      RETCTR_NF    = @p_ctr_nf
        and              RTY_NF          = @uwy_nf

           select @erreur = @@error

           if @erreur != 0
           begin
              return @erreur
           end
END

return 0
go



exec sp_SCOR_INSPRC 'ESSSEC21', 'PsTCONTR_19', 'BEST', 'ME57'
go

IF OBJECT_ID('dbo.PsTCONTR_19') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsTCONTR_19 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsTCONTR_19 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsTCONTR_19
 */
GRANT EXECUTE ON dbo.PsTCONTR_19 TO GOMEGA
go

