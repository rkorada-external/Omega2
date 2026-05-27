use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsEARIPP_01
*/
IF OBJECT_ID('dbo.PsEARIPP_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsEARIPP_01
   PRINT '<<< DROPPED PROC dbo.PsEARIPP_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsEARIPP_01
     (
/*       @p_acy_nf              smallint, */
       @p_end_nt              UEND_NT,
/*       @p_scoendmth_nf        tinyint,
       @p_scostrmth_nf        tinyint, */
       @p_sec_nf              USEC_NF, 
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsEARIPP_01

Fichier script associé : ESSEAR01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TEARIPP

Parametres: 
/*       @p_acy_nf              smallint, */
       @p_end_nt              UEND_NT,
/*       @p_scoendmth_nf        tinyint,
       @p_scostrmth_nf        tinyint, */
       @p_sec_nf              USEC_NF,
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
         @sec_nf              USEC_NF,
         @uw_nt               UUW_NT,
         @uwy_nf              UUWY_NF,
         @cur_cf              UCUR_CF,
         @refprm_m            UAMT_M,
         @wpport_m            UAMT_M,
	   @periode             char(5),
	   @scoendmth1         char(2),
         @scostrmth1           char(2)




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
        @cur_cf = cur_cf,
        @refprm_m = refprm_m,
        @wpport_m = wpport_m
   from TEARIPP  
 	where ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uw_nt = @p_uw_nt
    and uwy_nf = @p_uwy_nf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TEARIPP" /* erreur de modification */
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
        @CUR_CF CUR_CF,
        @REFPRM_M REFPRM_M,
        @WPPORT_M WPPORT_M,
	  @periode periode

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSEAR01', 'PsEARIPP_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsEARIPP_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsEARIPP_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsEARIPP_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsEARIPP_01
 */
GRANT EXECUTE ON dbo.PsEARIPP_01 TO GOMEGA
go

