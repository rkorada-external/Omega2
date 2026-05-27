use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsACCTRN_03
*/
IF OBJECT_ID('dbo.PsACCTRN_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsACCTRN_03
   PRINT '<<< DROPPED PROC dbo.PsACCTRN_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsACCTRN_03
     (
       @p_esb_cf              UESB_CF,
       @p_ssd_cf              USSD_CF,
       @p_trn_nt              numeric
     )
as

/***************************************************

Programme: PsACCTRN_03

Fichier script associé : ESSACC03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME65 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TACCTRNE

Parametres: 
       @p_esb_cf              UESB_CF,
       @p_ssd_cf              USSD_CF,
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


 Select esb_cf,
        ssd_cf,
        trn_nt,
        acctyp_cf,
        acy_nf,
        aln_nf,
        apr_nt,
        blcsht_d,
        ced_nf,
        cli_nf,
        clm_nf,
        cnvamt_m,
        cnvcur_cf,
        ctr_nf,
        ctrncod_cf,
        cur_cf,
        curamt100_m,
        end_nt,
        epstatus,
        gar_cf,
        genldgtrf_d,
        grp_cf,
        incfmt_ct,
        lob_cf,
        lsttrn_b,
        lstupd_d,
        lstupdusr_cf,
        mth_b,
        mth_d,
        nat_cf,
        occyea_nf,
        oricuramt_m,
        paynbr_nf,
        paytyp_ct,
        prg_nt,
        prgord_nt,
        prmlin_nt,
        reb_nf,
        retflg_ct,
        rsvrlsflg_b,
        scoendmth_nf,
        scostrmth_nf,
        sec_nf,
        sha_r,
        sntacc_nt,
        sob_cf,
        stl_d,
        subnat_cf,
        top_cf,
        trnaln_nt,
        trncod_cf,
        trnsts_ct,
        usrcrtcod_ct,
        usrcrtval_lm,
        uw_nt,
        uwy_nf,
        vld_d
   from TACCTRNE
  where esb_cf = @p_esb_cf
    and ssd_cf = @p_ssd_cf
    and trn_nt = @p_trn_nt

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TACCTRNE" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSACC03', 'PsACCTRN_03', 'BEST', 'ME65'
go

IF OBJECT_ID('dbo.PsACCTRN_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsACCTRN_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsACCTRN_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsACCTRN_03
 */
GRANT EXECUTE ON dbo.PsACCTRN_03 TO GOMEGA
go

