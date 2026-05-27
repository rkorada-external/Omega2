use BEST
go

IF OBJECT_ID('dbo.PdCTRFIC_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdCTRFIC_01
   PRINT '<<< DROPPED PROC dbo.PdCTRFIC_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PdCTRFIC_01
     (
       @p_liftrttyp_cf        char(2),
       @p_pcprsktry_cf        UCTY_CF,
       @p_ssd_cf              USSD_CF,
       @p_uwgrp_cf            UGRP_CF,
       @p_ced_nf              UCLI_NF,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,
       @p_erreur              varchar(64)=NULL output
     )
as

/***************************************************

Programme: PdCTRFIC_01

Fichier script associé : ESDFIC01.PRC


Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ANB avec Infotool version 2.0

Date de creation:

Description du programme:

      suppression d'enregistrement dans TCTRFIC

Parametres:
       @p_liftrttyp_cf        char(2),
       @p_pcprsktry_cf        UCTY_CF,
       @p_ssd_cf              USSD_CF,
       @p_uwgrp_cf            UGRP_CF,
       @p_ced_nf              UCLI_NF,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,

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
        @tran_imbr	bit,
        @nbligne  smallint,
        @nbtime   smallint

select @erreur    = 0
select @tran_imbr = 1

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

If @p_ced_nf = null select @p_ced_nf = 0

delete TCTRFIC
  where liftrttyp_cf  = @p_liftrttyp_cf
    and pcprsktry_cf  = @p_pcprsktry_cf
    and ssd_cf        = @p_ssd_cf
    and uwgrp_cf      = @p_uwgrp_cf
    and ced_nf        = @p_ced_nf

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

select @p_lstupdusr_cf  = lstupdusr_cf,
       @p_lstupd_d      = lstupd_d
from TCTRFIC
       where liftrttyp_cf = @p_liftrttyp_cf
         and pcprsktry_cf = @p_pcprsktry_cf
         and ssd_cf       = @p_ssd_cf
         and uwgrp_cf     = @p_uwgrp_cf
         and ced_nf       = @p_ced_nf

select @erreur = @@error, @nbtime = @@rowcount
if @erreur != 0
   select @p_erreur = "20011 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

if @nbligne = 0
  begin
   if @nbtime = 0
     begin
      select @p_erreur = "20012 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
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

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESDFIC01', 'PdCTRFIC_01', 'BEST', 'ANB'
go

IF OBJECT_ID('dbo.PdCTRFIC_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdCTRFIC_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdCTRFIC_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdCTRFIC_01
 */
GRANT EXECUTE ON dbo.PdCTRFIC_01 TO GOMEGA
go

