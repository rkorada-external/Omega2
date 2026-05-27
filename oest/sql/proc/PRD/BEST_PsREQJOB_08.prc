/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
 /* DROP PROC dbo.PsREQJOB_08
*/
IF OBJECT_ID('dbo.PsREQJOB_08') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsREQJOB_08
   PRINT '<<< DROPPED PROC dbo.PsREQJOB_08 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsREQJOB_08
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PsREQJOB_08

Fichier script associé : ESSREQ08.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME24 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TREQJOB + Libellé de la version dans TVERSION
                                              + Période exceptionnelle

Parametres: 
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int,
        @v_segtyp_ct  USEGTYP_CT

/*Proposition de sinistralité */
If @p_reqcod_ct = 'S'
	select @v_segtyp_ct = 'E'

/*Demande d'inventaire */
Else If @p_reqcod_ct = 'I'
	select @v_segtyp_ct = 'A'

/*Autres cas */
Else
	select @v_segtyp_ct = ''

 Select TR.balsheyea_nf,
        TR.balshtmth_nf,
        TR.clodat_d,
        TR.cre_d,
        TR.reqcod_ct,
        TR.ssd_cf,
        TR.cloper_ls,
        TR.dbclo_d,
        TR.launch_d,
        TR.updusr_cf,
        TR.vrs_nf,
        TV.vrs_lm,
        TC.specend_d,
        TC.account_d
   from BEST..TREQJOB  TR, BEST..TVERSION  TV, BREF..TCALEND  TC
  where TR.balsheyea_nf = @p_balsheyea_nf
    and TR.balshtmth_nf = @p_balshtmth_nf
    and TR.clodat_d = @p_clodat_d
    and TR.cre_d = @p_cre_d
    and TR.reqcod_ct = @p_reqcod_ct
    and TR.ssd_cf = @p_ssd_cf
    and TV.ssd_cf = @p_ssd_cf
    and TR.vrs_nf *= TV.vrs_nf
    and TV.segtyp_ct = @v_segtyp_ct
    and TC.blcshtyea_nf = @p_balsheyea_nf
    and TR.balshtmth_nf *= TC.blcshtmth_nf


   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSREQ08', 'PsREQJOB_08', 'BEST', 'ME24'
go

IF OBJECT_ID('dbo.PsREQJOB_08') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsREQJOB_08 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsREQJOB_08 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsREQJOB_08
 */
GRANT EXECUTE ON dbo.PsREQJOB_08 TO public
go

