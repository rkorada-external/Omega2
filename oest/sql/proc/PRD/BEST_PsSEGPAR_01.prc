use BEST
go

USE BEST
Go

DROP PROC dbo.PsSEGPAR_01
go

IF OBJECT_ID('dbo.PsSEGPAR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSEGPAR_01
   PRINT '<<< DROPPED PROC dbo.PsSEGPAR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSEGPAR_01
     (@p_ssd_cf              USSD_CF,
      @p_lag_cf              ULAG_CF)
as

/***************************************************

Programme: PsSEGPAR_01

Fichier script associé : ESSSEG01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ANB avec Infotool version 2.0 

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TSEGPAR

Parametres: 
       @p_ssd_cf              USSD_CF,
       @p_lag_cf              ULAG_CF 

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


 Select a.clinat_cf,
        a.ordnbr_nt,
        a.pcprsktry_cf,
        c.ctysup_ls,
        a.ssd_cf,
        a.uwgrp_cf,
        b.grp_ls,
        a.cre_d,
        a.creusr_cf,
        a.lstupd_d,
        a.lstupdusr_cf,
        a.seg_nf,
        d.seg_ls
 from TSEGPAR a, BREF..TGRP b, BREF..TCTYSUPL c, TANASEG d
 where a.ssd_cf = @p_ssd_cf
    and c.lag_cf = @p_lag_cf
    and a.ssd_cf = b.ssd_cf
    and a.ssd_cf = d.ssd_cf
    and a.uwgrp_cf = b.grp_cf
    and a.pcprsktry_cf = c.ctysup_cf
    and a.seg_nf = d.seg_nf
 order by a.uwgrp_cf, a.pcprsktry_cf, a.clinat_cf, a.ordnbr_nt 

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TSEGPAR" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSEG01', 'PsSEGPAR_01', 'BEST', 'ANB'
go

IF OBJECT_ID('dbo.PsSEGPAR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSEGPAR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSEGPAR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSEGPAR_01
 */
GRANT EXECUTE ON dbo.PsSEGPAR_01 TO GOMEGA
go

