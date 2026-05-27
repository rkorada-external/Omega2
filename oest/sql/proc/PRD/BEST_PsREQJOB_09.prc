USE BEST
Go
/* DROP PROC dbo.PsREQJOB_09
*/
IF OBJECT_ID('dbo.PsREQJOB_09') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsREQJOB_09
   PRINT '<<< DROPPED PROC dbo.PsREQJOB_09 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsREQJOB_09
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            char(8),
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
	    @p_cre_d               datetime
     )
as

/***************************************************

Programme: PsREQJOB_09

Fichier script associé : ESSREQ09.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME24 (JP BESSY) avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: Controle unicite des demandes inventaires pour un jour donne, un type une filiale
Parametres:
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            char(8),
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
	     @p_cre_d               datetime

Conditions d'execution:
Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER
Date: 20/04/1998
Description: Rajout @p_cre_d

_________________
MODIFICATION 2    -> MOD002

Auteur: O.GIRAUX
Date: 08/08/2002
Description: Rajout de convert lors des comparaisons des @p_cre_d,
             pour ne pas comparer l'heure forcement differente entre 2 demandes
             faites le meme jour !!!
             +
             Pour les demandes de type D ou Z: on ne doit avoir qu'une seule demande
             toutes filiales confondues: ex on ne peut avoir demande de type D sur filiales 2 et une
             demande de type D sur la filiale 4.
             Pour les autres demandes, c'est une seule par filiale. ( 2 demandes de type I sur
             filiale 4 par ex sont interdites )

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare @erreur      int

declare @site_cf        varchar(10)
Execute @erreur = BEST..PsSITE_01 @p_ssd_cf,'2',@site_cf output

declare @ret bit

If Exists( Select 1
             from BEST..TREQJOBPLAN
             where
                balsheyea_nf                         = @p_balsheyea_nf
                and balshtmth_nf                     = @p_balshtmth_nf
                and convert(varchar(8),clodat_d,112) = @p_clodat_d
		            and convert(char(9),cre_d,112)       = convert(char(9),@p_cre_d,112)   -- MOD002
                and reqcod_ct                        = @p_reqcod_ct
                and site_cf                          = @site_cf
                and (
                        (reqcod_ct not in ("Z","M","C","D","V","A","L") and ssd_cf = @p_ssd_cf )
                        OR
                        reqcod_ct in ("Z","M","C","D","V","A","L")
                     )
              )
   select @ret = 1
Else
   select @ret = 0

/*************** Select FINAL ***************/

 Select @ret

return 0
go

/*
 * fin de la procedure
 */

IF OBJECT_ID('dbo.PsREQJOB_09') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsREQJOB_09 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsREQJOB_09 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsREQJOB_09
 */
GRANT EXECUTE ON dbo.PsREQJOB_09 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsREQJOB_09 TO GDBBATCH
go

