USE BEST
go
IF OBJECT_ID('dbo.PuCTRFIC_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuCTRFIC_01_O2
    IF OBJECT_ID('dbo.PuCTRFIC_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuCTRFIC_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuCTRFIC_01_O2 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure dbo.PuCTRFIC_01_O2
     (
       @p_liftrttyp_cf        char(2),
       @p_pcprsktry_cf        UCTY_CF,
       @p_ssd_cf              USSD_CF,
       @p_uwgrp_cf            UGRP_CF,
       @p_ced_nf              UCLI_NF,
       @p_cre_d               UUPD_D,
       @p_creusr_cf           UUPDUSR_CF,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
	   @p_esb_cf			  UESB_CF,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,
       @p_erreur              varchar(64)=NULL output
     )
as

/***************************************************

Programme: PuCTRFIC_01_O2

Fichier script associé : ESUCTR01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ANB avec Infotool version 2.0

Date de creation:

Description du programme:

      Modification d'enregistrement dansTCTRFIC

Parametres:
       @p_liftrttyp_cf        char(2),
       @p_pcprsktry_cf        UCTY_CF,
       @p_ssd_cf              USSD_CF,
       @p_uwgrp_cf            UGRP_CF,
       @p_ced_nf              UCLI_NF,
       @p_cre_d               UUPD_D,
       @p_creusr_cf           UUPDUSR_CF,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:    T.RIPERT

Date:      24/06/2010

Version:

Description:  Ajout la cédante
  _________________
MODIFICATION 2
Auteur:       Jérémy CHOCHON
Date:         08/07/2012
Version:
Description:	Ajout de la colonne ESB_CF

*****************************************************/

declare @erreur int,
        @tran_imbr	bit,
        @nbligne  smallint,
        @nbtime  smallint

select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

If @p_ced_nf = null select @p_ced_nf = 0

update TCTRFIC
    set ctr_nf        = @p_ctr_nf,
        end_nt        = @p_end_nt,
        lstupd_d      = getdate(),
        lstupdusr_cf  = user,
        ced_nf        = @p_ced_nf
   where liftrttyp_cf = @p_liftrttyp_cf
     and pcprsktry_cf = @p_pcprsktry_cf
     and ssd_cf       = @p_ssd_cf
     and uwgrp_cf     = @p_uwgrp_cf
     and ced_nf       = @p_ced_nf
	 and esb_cf		  = @p_esb_cf

select @erreur = @@error, @nbligne = @@rowcount

if @@transtate = 2
  begin
   select @p_erreur = "ERREUR TRIGGER"
   goto fin
  end

if @erreur != 0
  begin
   select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
   goto fin
  end


select  @p_lstupdusr_cf = lstupdusr_cf,
        @p_lstupd_d     = lstupd_d
from    TCTRFIC
where   liftrttyp_cf      = @p_liftrttyp_cf
        and pcprsktry_cf  = @p_pcprsktry_cf
        and ssd_cf        = @p_ssd_cf
        and uwgrp_cf      = @p_uwgrp_cf
        and ced_nf        = @p_ced_nf
		and esb_cf		  = @p_esb_cf
select @erreur = @@error, @nbtime = @@rowcount
if @erreur != 0
   select @p_erreur = "20011 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

if @nbligne = 0
  begin
   if @nbtime = 0
     begin
      select @p_erreur = "20012 TONY UPDATE APPLICATIF;" + convert(varchar(10),@erreur) + ";"
      goto fin
     end
   else
     begin
      select @p_erreur = "20013 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
      goto fin
     end
  end

if @tran_imbr = 0
	COMMIT TRAN

return @erreur

fin:
if @tran_imbr = 0
	ROLLBACK TRAN

return @erreur
go
EXEC sp_procxmode 'dbo.PuCTRFIC_01_O2', 'unchained'
go
IF OBJECT_ID('dbo.PuCTRFIC_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuCTRFIC_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuCTRFIC_01_O2 >>>'
go
GRANT EXECUTE ON dbo.PuCTRFIC_01_O2 TO GOMEGA
go
