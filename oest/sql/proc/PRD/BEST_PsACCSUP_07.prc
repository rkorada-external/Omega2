use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsACCSUP_07
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsACCSUP_07') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsACCSUP_07
   PRINT '<<< DROPPED PROC dbo.PsACCSUP_07 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsACCSUP_07
     (
       @p_trn_nt              numeric
     )
as

/***************************************************

Programme: PsACCSUP_07

Fichier script associé : ESSACC07.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TACCSUP
	-> Cette proc ne sert qu'à maquetter dw_liste de la fenêtre de recherche 
	'Ecritures de service' (w_recherche_es0001), la proc lancée étant Pfes0001

Parametres: 
       @p_trn_nt              numeric

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


 Select  trn_nt,
	 acctrn_nt,
	 acctyp_nf,
        acy_nf,
        amt_m,
        balshey_nf,
        balshrday_nf,
        balshrmth_nf,
        ctr_nf,
        cur_cf,
        end_nt,
        entpermth_nf,
        entpery_nf,
        esb_cf,
	 plc_nt,
        retacy_nf,
        retamt_m,
        retctr_nf,
        retcur_cf,
        retend_nt,
        retrty_nf,
        retscoendmth_nf,
        retscostrmth_nf,
        retsec_nf,
        retuw_nt,
        scoendmth_nf,
        scostrmth_nf,
        sec_nf,
        ssd_cf,
        trncod_cf,
        uw_nt,
        uwy_nf,
        valpermth_nf,
        valpery_nf
   from TACCSUP
  where trn_nt = @p_trn_nt

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TACCSUP" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSACC07', 'PsACCSUP_07', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsACCSUP_07') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsACCSUP_07 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsACCSUP_07 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsACCSUP_07
 */
GRANT EXECUTE ON dbo.PsACCSUP_07 TO GOMEGA
go

