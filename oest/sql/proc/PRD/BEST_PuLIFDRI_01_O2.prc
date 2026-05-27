use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PiLIFDRI_01
*/


IF OBJECT_ID('dbo.PuLIFDRI_01_O2') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuLIFDRI_01_O2
   PRINT '<<< DROPPED PROC dbo.PuLIFDRI_01_O2 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PuLIFDRI_01_O2
     (
       @p_acy_nf              smallint,
       @p_balshey_nf          smallint,
       @p_balshtmth_nf        tinyint,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_autupd_b            bit,
       @p_cmt_nt              UCMT_NT,
       @p_comacc_b            bit,
       @p_creusr_cf           UUPDUSR_CF,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,
       @p_ssd_cf              USSD_CF,
       @p_erreur	varchar(64)=NULL output,
	   @p_respropag_b  bit
     )
as

/***************************************************

Programme: PuLIFDRI_01_O2

Fichier script associé : ESUDRI01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: G Buisson

Date de creation: 24/02/2003

Description du programme:

      Mise a jour d'enregistrement dans TLIFDRI
      ou Insertion si inexistant
      Utilise uniquement pour creation commentaire general
      dans appli estimation acceptation ou retro

Parametres:
       @p_acy_nf              smallint,
       @p_balshey_nf          smallint,
       @p_balshtmth_nf        tinyint,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_autupd_b            bit,
       @p_cmt_nt              UCMT_NT,
       @p_comacc_b            bit,
       @p_creusr_cf           UUPDUSR_CF,
       @p_lstupd_d     UUPD_D=NULL output,
       @p_lstupdusr_cf     UUPDUSR_CF=NULL output,
       @p_ssd_cf              USSD_CF,
       @p_erreur	varchar(64)=NULL output
	   @p_respropag_b  bit  -- EST 22 
	   

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:         G. Buisson

Date:           05/01/2004

Version:

Description:    On force la filiale avec les 2 premiers caracteres
                du contrat (probleme du a la filialisation vie)
__________________
MODIFICATION 2

Auteur:         Sohal Sinha

Date:           24/02/2014

Version:

Description:    Modification done for the contract numbering changes to remove substring

__________________
MODIFICATION 3

Auteur:         Amit Deshpande

Date:           08/07/2014

Version:

Description:   Modification added for EST 22 evo card for adding reserve propagation B column

__________________
MODIFICATION 4

Auteur:         A. Deshpande

Date:           16/10/2014

Version:

Description:    Changes for spira #031392 (change type of respropag_b to bit)

*****************************************************/

declare @erreur int,
        @tran_imbr	bit,
        @ssd_cf USSD_CF

select @erreur = 0
select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

--select @ssd_cf = convert(tinyint,substring(@p_ctr_nf, 1, 2))

/***********************************************************************************/
/* Insertion ou update dans TLIFDRI                                                          */
/***********************************************************************************/

if exists (select 1
           from   TLIFDRI
           where  ctr_nf       = @p_ctr_nf
           and    end_nt       = @p_end_nt
           and    sec_nf       = @p_sec_nf
           and    uwy_nf       = @p_uwy_nf
           and    uw_nt        = @p_uw_nt
           and    balshey_nf   = 1900
           and    balshtmth_nf = 1
           and    acy_nf       = 1900
           and    ssd_cf       = @p_ssd_cf)

    begin
        update TLIFDRI
        set    cmt_nt = @p_cmt_nt,
               lstupd_d = getdate(),
               lstupdusr_cf = user
        where  ctr_nf       = @p_ctr_nf
        and    end_nt       = @p_end_nt
        and    sec_nf       = @p_sec_nf
        and    uwy_nf       = @p_uwy_nf
        and    uw_nt        = @p_uw_nt
        and    balshey_nf   = 1900
        and    balshtmth_nf = 1
        and    acy_nf       = 1900
        and    ssd_cf       = @p_ssd_cf
     end
else
     begin
        insert into TLIFDRI (
                acy_nf,
                balshey_nf,
                balshtmth_nf,
                cre_d,
                ctr_nf,
                end_nt,
                sec_nf,
                uw_nt,
                uwy_nf,
                autupd_b,
                cmt_nt,
                comacc_b,
                creusr_cf,
                lstupd_d,
                lstupdusr_cf,
                ssd_cf,
				respropag_b)
        values(
                1900,
                1900,
                1,
                getdate(),
                @p_ctr_nf,
                0,
                @p_sec_nf,
                1,
                @p_uwy_nf,
                0,
                @p_cmt_nt,
                0,
                @p_creusr_cf,
                getdate(),
                user,
                @p_ssd_cf,
				@p_respropag_b)
     end

select @erreur = @@error
if @@transtate = 2
  begin
   select @p_erreur = "ERREUR TRIGGER"
   goto fin
  end

if @erreur != 0
  begin
   if @erreur = 2601
 	   select @p_erreur = "20002 APPLICATIF;2601;"   /* cle dupliquée */
   else
 	   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

   goto fin
  end

select @p_lstupdusr_cf = lstupdusr_cf,
       @p_lstupd_d = lstupd_d
from TLIFDRI
       where acy_nf = @p_acy_nf
         and balshey_nf = @p_balshey_nf
         and balshtmth_nf = @p_balshtmth_nf
         and ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt
         and sec_nf = @p_sec_nf
         and uw_nt = @p_uw_nt
         and uwy_nf = @p_uwy_nf

select @erreur = @@error
if @erreur != 0
   select @p_erreur = "20011 APPLICATIF;" + convert(varchar(10),@erreur) + ";"


if @tran_imbr = 0
   COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur

go

/*
 * fin de la procedure
 */

IF OBJECT_ID('dbo.PuLIFDRI_01_O2') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuLIFDRI_01_O2 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuLIFDRI_01_O2 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiLIFDRI_01
 */
GRANT EXECUTE ON dbo.PuLIFDRI_01_O2 TO GOMEGA
go

