use BEST
go


USE BEST
Go

/* DROP PROC dbo.PuAUTPAR_01
*/
IF OBJECT_ID('dbo.PuAUTPAR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuAUTPAR_01
   PRINT '<<< DROPPED PROC dbo.PuAUTPAR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuAUTPAR_01
     (
       @p_ssd_cf              USSD_CF,
       @p_ctrnat_ct           char(1),
       @p_lob_cf              ULOB_CF,
       @p_pcprsktry_cf        UCTY_CF,
       @p_sob_cf              USOB_CF,
       @p_limper_r            USHORAT_R,
       @p_quanum_nb           tinyint,
       @p_erreur              varchar(64)=NULL output
     )
as

/***************************************************

Programme: PuAUTPAR_01

Fichier script associé : ESUAUT01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: Gordana DIMCEA avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Modification d'enregistrement dansTAUTPAR 

Parametres: 
       @p_ssd_cf              USSD_CF,
       @p_ctrnat_ct           char(1),
       @p_lob_cf              ULOB_CF,
       @p_pcprsktry_cf        UCTY_CF,
       @p_sob_cf              USOB_CF,
       @p_limper_r            USHORAT_R,
       @p_quanum_nb           tinyint,

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

update TAUTPAR
   set limper_r = @p_limper_r ,
       quanum_nb = @p_quanum_nb
   where ssd_cf = @p_ssd_cf
     and ctrnat_ct = @p_ctrnat_ct
     and lob_cf = @p_lob_cf
     and pcprsktry_cf = @p_pcprsktry_cf
     and sob_cf = @p_sob_cf


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

exec sp_SCOR_INSPRC 'ESUAUT01', 'PuAUTPAR_01', 'BEST', 'ME08'
go

IF OBJECT_ID('dbo.PuAUTPAR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuAUTPAR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuAUTPAR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuAUTPAR_01
 */
GRANT EXECUTE ON dbo.PuAUTPAR_01 TO GOMEGA
go

