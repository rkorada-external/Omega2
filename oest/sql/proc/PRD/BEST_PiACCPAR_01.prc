USE BEST
GO
IF OBJECT_ID('dbo.PiACCPAR_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiACCPAR_01
    IF OBJECT_ID('dbo.PiACCPAR_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE BEST..PiACCPAR_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE BEST..PiACCPAR_01 >>>'
END
GO

/*
 * creation de la procedure
*/

create procedure PiACCPAR_01
     (
       @p_acmtrs_nt           smallint,
       @p_adjcod_ct           tinyint,
       @p_adjsig_b            bit,
       @p_dettrs_cf           UDETTRS_CF,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,
       @p_position_nt         smallint,
       @p_retcod_ct           tinyint,
       @p_spimod_ct           tinyint,
       @p_restec           tinyint,
       @p_resdac           tinyint,
       @p_resfin           tinyint,
       @p_sumrisk          tinyint,
       @p_lob_cf           tinyint,
       @p_erreur	      varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiACCPAR_01

Fichier script associé : ESIACC01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ANB avec Infotool version 2.0

Date de creation:

Description du programme:

      Insertion d'enregistrement dans TACCPAR

Parametres:
       @p_acmtrs_nt           smallint,
       @p_adjcod_ct           tinyint,
       @p_adjsig_b            bit,
       @p_dettrs_cf           UDETTRS_CF,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,
       @p_position_nt         smallint,
       @p_retcod_ct           tinyint,
       @p_spimod_ct           tinyint,
       @p_erreur	      varchar(64)=NULL output

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1 [001]

Auteur:        Tony RIPERT

Date:          09/11/2010

Version:       10

Description:   Ajout les flags resultats et lob_cf

*****************************************************/

declare @erreur int,
        @tran_imbr	bit

select @erreur = 0
select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

insert into TACCPAR
      (
                acmtrs_nt,
                prs_cf,
                adjcod_ct,
                adjsig_b,
                cre_d,
                creusr_cf,
                dettrs_cf,
                lstupd_d,
                lstupdusr_cf,
                position_nt,
                retcod_ct,
                spimod_ct,
                restec_b,  --[001]
                resdac_b,
                resfin_b,
                sumrisk_b,
                lob_cf
      )
 values
      (
        @p_acmtrs_nt,
        500,
        @p_adjcod_ct,
        @p_adjsig_b,
        getdate(),
        user,
        @p_dettrs_cf,
        getdate(),
        user,
        @p_position_nt,
        @p_retcod_ct,
        @p_spimod_ct,
         @p_restec,
         @p_resdac,
         @p_resfin,
         @p_sumrisk,
         @p_lob_cf
      )

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
from TACCPAR
       where acmtrs_nt = @p_acmtrs_nt
         and prs_cf = 500

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

GO
EXEC sp_procxmode 'dbo.PiACCPAR_01', 'unchained'
GO
IF OBJECT_ID('dbo.PiACCPAR_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE BEST..PiACCPAR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE BEST..PiACCPAR_01 >>>'
GO
GRANT EXECUTE ON dbo.PiACCPAR_01 TO GOMEGA
GO
