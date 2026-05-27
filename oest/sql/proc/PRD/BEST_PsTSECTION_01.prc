USE BEST
GO

 /* DROP PROC dbo.PsTSECTION_01
*/
IF OBJECT_ID('dbo.PsTSECTION_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsTSECTION_01
   PRINT '<<< DROPPED PROC dbo.PsTSECTION_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsTSECTION_01  ( @p_ctr_nf  UCTR_NF,
                                                        @p_sec_nf   USEC_NF,
                                                        @p_uwy_nf  UUWY_NF,
                                                        @p_end_nt   UEND_NT,
                                                        @p_uw_nt    UUW_NT,
                                                        @p_s_typ     Char(1) )

as

/***************************************************

Programme: PsTSECTION_01

Fichier script associé : best_PsTSECTION_01.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME57

Date de creation: 20/04/2004

Description du programme:
   Recherche des contrat avec lob_cf = '30' ou '31'

Parametres:

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:  M.SPAGNOLI

Date:    27/04/2004

Version:

Description:  On va chercher le   estcrb_ct dans ctr et plus dans sec


*****************************************************/

declare @erreur int   , @s_lob char(2)


IF @p_s_typ = 'A'
BEGIN
         SELECT 	b.LOB_CF , a.estcrb_ct
        FROM   BTRT..TCONTR a, BTRT..TSECTION b
        WHERE     a.ctr_nf = b.ctr_nf
        and             a.uwy_nf = b.uwy_nf
        and             a.end_nt = b.end_nt
        and             a.uw_nt = b.uw_nt
        and             a.ctr_nf    = @p_ctr_nf
        and             b.sec_nf   = @p_sec_nf
        and             a.uwy_nf  = @p_uwy_nf
        and             a.end_nt  = @p_end_nt
        and             a.uw_nt   = @p_uw_nt


           select @erreur = @@error

           if @erreur != 0
           begin
              return @erreur
           end
END
ELSE
BEGIN
         SELECT 	LOB_CF , ""
        FROM   BRET..TRETSEC
        WHERE      RETCTR_NF    = @p_ctr_nf
        and              RETSEC_NF    = @p_sec_nf
        and              RTY_NF          = @p_uwy_nf
       -- and          end_nt  = @p_end_nt
        --and          uw_nt   = @p_uw_nt


           select @erreur = @@error

           if @erreur != 0
           begin
              return @erreur
           end
END

return 0
go



exec sp_SCOR_INSPRC 'ESSSEC21', 'PsTSECTION_01', 'BEST', 'ME57'
go

IF OBJECT_ID('dbo.PsTSECTION_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsTSECTION_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsTSECTION_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsTSECTION_01
 */
GRANT EXECUTE ON dbo.PsTSECTION_01 TO GOMEGA
go

