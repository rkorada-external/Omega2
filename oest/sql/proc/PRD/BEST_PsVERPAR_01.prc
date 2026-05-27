/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
 /* DROP PROC dbo.PsVERPAR_01
*/
IF OBJECT_ID('dbo.PsVERPAR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsVERPAR_01
   PRINT '<<< DROPPED PROC dbo.PsVERPAR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsVERPAR_01
     (
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PsVERPAR_01

Fichier script associé : ESSVPA01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME24 (JP BESSY) avec Infotool version 2.0 

Date de creation: 26/11/1997

Description du programme: 

      Sélection du numéro de version le plus récent dans TVERPAR 
      et de son libellé dans TVERSION pour une TagList de la fenêtre ES2700.

Parametres: 
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER

Date: 15/08/1998

Version:

Description: On traite le cas Type de demande = 'J' ('inventaire + SNEM')

*****************************************************/

declare @erreur int,
        @v_segtyp_ct  USEGTYP_CT ,
        @v_date_max   Datetime

/*Proposition de sinistralité */
If @p_reqcod_ct = 'S'
	select @v_segtyp_ct = 'E'

/*Demande d'inventaire */
Else If @p_reqcod_ct = 'I' or @p_reqcod_ct = 'J'
	select @v_segtyp_ct = 'A'

/*Autres cas : On renvoie "" et "" */
Else
	goto retour_rien

select @v_date_max = max(par_d)
 from TVERPAR 
where segtyp_ct = @v_segtyp_ct
  and ssd_cf = @p_ssd_cf

select @erreur = @@error

 if @erreur != 0
   begin
      goto fin
   end

If @v_date_max = NULL
	goto retour_rien

/*------------------SELECT FINAL si Ok--------------------*/
 Select TP.vrs_nf,
        TS.vrs_lm
   from TVERPAR TP, TVERSION TS
  where TP.segtyp_ct = @v_segtyp_ct
    and TP.ssd_cf = @p_ssd_cf
    and TP.par_d = @v_date_max
    and TS.ssd_cf = @p_ssd_cf
    and TS.vrs_nf = TP.vrs_nf

select @erreur = @@error
 if @erreur != 0
   begin
      goto fin
   end

RETURN 0

/*------------------SELECT FINAL si Rien du tout--------------------*/
retour_rien:
   begin
        select NULL, ""
        RETURN 0
   end

/*******************Traitement Echec de la sélection****************/
fin:
   begin
        select NULL, ""
        RAISERROR 20001 "Procedure PsVERPAR_01 has failed"
        return @erreur
   end
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSVPA01', 'PsVERPAR_01', 'BEST', 'ME24'
go

IF OBJECT_ID('dbo.PsVERPAR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsVERPAR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsVERPAR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsVERPAR_01
 */
GRANT EXECUTE ON dbo.PsVERPAR_01 TO GOMEGA
go

