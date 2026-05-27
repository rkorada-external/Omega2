use BEST
go

IF OBJECT_ID('dbo.PsCTRFIC_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCTRFIC_01
    PRINT '<<< DROPPED PROC dbo.PsCTRFIC_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsCTRFIC_01
     (@p_ssd_cf              USSD_CF,
      @p_lag_cf              ULAG_CF)
as

/***************************************************

Programme: PsCTRFIC_01

Fichier script associé : ESSCTR01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ANB avec Infotool version 2.0

Date de creation:

Description du programme:

      Sélection d'enregistrement dans TCTRFIC

Parametres:
       @p_ssd_cf              USSD_CF,
       @p_lag_cf              ULAG_CF

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:       Tony RIPERT

Date:         15/03/2010

Version:

Description:

  SPOT 19211 : Ajout la colonne CED_NF (cédante)

*****************************************************/

declare @erreur int,
        @p_null int

 Select a.uwgrp_cf,
        b.grp_ls,
        a.pcprsktry_cf,
        c.ctysup_ls,
        a.liftrttyp_cf,
        a.ctr_nf,
        a.end_nt,
        a.ssd_cf,
        a.cre_d,
        a.creusr_cf,
        a.lstupd_d,
        a.lstupdusr_cf,
        case when a.ced_nf=0 then @p_null else a.ced_nf end
  from  BEST..TCTRFIC a,
        BREF..TGRP b,
        BREF..TCTYSUPL c
  where a.ssd_cf = @p_ssd_cf
    and c.lag_cf = @p_lag_cf
    and a.ssd_cf = b.ssd_cf
    and a.uwgrp_cf = b.grp_cf
    and a.pcprsktry_cf = c.ctysup_cf
  order by a.uwgrp_cf, a.pcprsktry_cf, a.liftrttyp_cf, a.ctr_nf, a.ced_nf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCTRFIC" /* erreur de modification */
      return @erreur
   end



return 0
go
IF OBJECT_ID('dbo.PsCTRFIC_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCTRFIC_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCTRFIC_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCTRFIC_01
 */
GRANT EXECUTE ON dbo.PsCTRFIC_01 TO GOMEGA
go

