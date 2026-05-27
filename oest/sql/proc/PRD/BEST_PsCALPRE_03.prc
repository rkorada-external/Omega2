use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsCALPRE_03
*/
IF OBJECT_ID('dbo.PsCALPRE_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCALPRE_03
   PRINT '<<< DROPPED PROC dbo.PsCALPRE_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCALPRE_03
     (
/*       @p_acy_nf              smallint, */
       @p_end_nt              UEND_NT,
/*       @p_scoendmth_nf        tinyint,
       @p_scostrmth_nf        tinyint, */
       @p_sec_nf              numeric,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsCALPRE_03

Fichier script associé : ESSCAL03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER - OME01)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TCALPRE

Parametres: 
/*       @p_acy_nf              smallint, */
       @p_end_nt              UEND_NT,
/*       @p_scoendmth_nf        tinyint,
       @p_scostrmth_nf        tinyint, */
       @p_sec_nf              numeric,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_ctr_nf              UCTR_NF

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int,
         @acy_nf              smallint,
         @ctr_nf              UCTR_NF,
         @end_nt              UEND_NT,
         @scoendmth_nf        tinyint,
         @scostrmth_nf        tinyint,
         @sec_nf              numeric,
         @uw_nt               UUW_NT,
         @uwy_nf              UUWY_NF,
         @brestprm_m          UAMT_M,
         @brrecprm_m          UAMT_M,
         @cur_cf              UCUR_CF,
         @estprm_m            UAMT_M,
         @recprm_m            UAMT_M,
         @ssd_cf              USSD_CF,
         @urnestprm_m         UAMT_M,
         @urnrecprm_m         UAMT_M,
	   @periode             char(5),
	   @scoendmth1         char(2),
         @scostrmth1           char(2),
	   @mt_prov  		UAMT_M


/*****************************************************************************/
/* Select                                                                    */
/*****************************************************************************/

 Select @acy_nf = acy_nf,
        @ctr_nf = ctr_nf,
        @end_nt = end_nt,
        @scoendmth_nf = scoendmth_nf,
        @scostrmth_nf = scostrmth_nf,
        @sec_nf = sec_nf,
        @uw_nt = uw_nt,
        @uwy_nf = uwy_nf,
        @brestprm_m = brestprm_m,
        @brrecprm_m = brrecprm_m,
        @cur_cf = cur_cf,
        @estprm_m = estprm_m,
        @recprm_m = recprm_m,
        @ssd_cf = ssd_cf,
        @urnestprm_m = urnestprm_m,
        @urnrecprm_m = urnrecprm_m
   from TCALPRE
  where ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uw_nt = @p_uw_nt
    and uwy_nf = @p_uwy_nf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCALPRE" /* erreur de modification */
      return @erreur
   end

If @scostrmth_nf < 10
	begin 
 	  select @scostrmth1 = "0" + convert(char(2), @scostrmth_nf) 
	end
else
	begin
 	  select @scostrmth1 = convert(char(2), @scostrmth_nf)
	end


If @scoendmth_nf < 10 
	begin 
 	  select @scoendmth1 = "0" + convert(char(2), @scoendmth_nf)
	end
else
	begin
 	  select @scoendmth1 = convert(char(2), @scoendmth_nf)
	end
	
select @periode = @scostrmth1 + "-" + @scoendmth1

select @mt_prov = @urnestprm_m + @urnrecprm_m

/*****************************************************************************/
/* Select final                                                              */
/*****************************************************************************/

 Select @ACY_NF ACY_NF,
        @CTR_NF CTR_NF,
        @END_NT END_NT,
        @SCOENDMTH_NF SCOENDMTH_NF,
        @SCOSTRMTH_NF SCOSTRMTH_NF,
        @SEC_NF SEC_NF,
        @UW_NT UW_NT,
        @UWY_NF UWY_NF,
        @BRESTPRM_M BRESTPRM_M,
        @BRRECPRM_M BRRECPRM_M,
        @CUR_CF CUR_CF,
        @ESTPRM_M ESTPRM_M,
        @RECPRM_M RECPRM_M,
        @SSD_CF SSD_CF,
        @URNESTPRM_M URNESTPRM_M,
        @URNRECPRM_M URNRECPRM_M,
	  @periode periode,
	  @mt_prov  mt_prov

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSCAL03', 'PsCALPRE_03', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsCALPRE_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCALPRE_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCALPRE_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCALPRE_03
 */
GRANT EXECUTE ON dbo.PsCALPRE_03 TO GOMEGA
go

