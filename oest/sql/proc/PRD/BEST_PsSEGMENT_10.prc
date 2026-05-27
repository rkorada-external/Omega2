use BEST
go


USE BEST
Go

 /* DROP PROC dbo.PsSEGMENT_10
*/
IF OBJECT_ID('dbo.PsSEGMENT_10') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSEGMENT_10
   PRINT '<<< DROPPED PROC dbo.PsSEGMENT_10 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSEGMENT_10
     (
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric
     )
as

/***************************************************

Programme: PsSEGMENT_10

Fichier script associé : ESSSEG10.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TSEGMENT

Parametres: 
       @p_segtyp_ct           USEGTYP_CT, : Type segment
       @p_ssd_cf              USSD_CF,    : Filiale
       @p_vrs_nf              numeric,    : Version

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
declare @vrsloc_b bit

/* -------------------------------------------------------------------
   Contrôle si "vrsloc_b" est égal à 1 alors
   select interdit et renvoi message d'erreur à l'application 
---------------------------------------------------------------------*/
select @vrsloc_b = vrsloc_b 
 from TVERSION
 where segtyp_ct = @p_segtyp_ct
   and ssd_cf = @p_ssd_cf
   and vrs_nf = @p_vrs_nf

if @vrsloc_b = 1 begin	raiserror 20002 "ESTIMATION" return @erreur end

/*-------------------
  Select TSEGMENT
-------------------*/
 Select seg_nf,
        seg_ll,
        cur_cf,
	  @p_segtyp_ct,
        @p_ssd_cf,
        @p_vrs_nf 
   from TSEGMENT
  where segtyp_ct = @p_segtyp_ct
    and ssd_cf = @p_ssd_cf
    and vrs_nf = @p_vrs_nf
    

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TSEGMENT" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSEG10', 'PsSEGMENT_10', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PsSEGMENT_10') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSEGMENT_10 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSEGMENT_10 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSEGMENT_10
 */
GRANT EXECUTE ON dbo.PsSEGMENT_10 TO GOMEGA
go

