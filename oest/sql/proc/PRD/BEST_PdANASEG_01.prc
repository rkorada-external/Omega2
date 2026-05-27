use BEST
go

USE BEST
Go

DROP PROC dbo.PdANASEG_01
go

IF OBJECT_ID('dbo.PdANASEG_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdANASEG_01
   PRINT '<<< DROPPED PROC dbo.PdANASEG_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdANASEG_01
     (
       @p_seg_nf              USEG_NF,
       @p_ssd_cf              USSD_CF,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,
      @p_erreur       varchar(64)=NULL output
     )
as

/***************************************************

Programme: PdANASEG_01

Fichier script associé : ESDANA01.PRC


Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ANB avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      suppression d'enregistrement dans TANASEG

Parametres: 
       @p_seg_nf              USEG_NF,
       @p_ssd_cf              USSD_CF,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,

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
        @nbtime   smallint

select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

delete TANASEG
  where seg_nf = @p_seg_nf
    and ssd_cf = @p_ssd_cf

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
   

select @p_lstupdusr_cf = lstupdusr_cf,
       @p_lstupd_d = lstupd_d                        
from TANASEG
       where seg_nf = @p_seg_nf
         and ssd_cf = @p_ssd_cf
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

exec sp_SCOR_INSPRC 'ESDANA01', 'PdANASEG_01', 'BEST', 'ANB'
go

IF OBJECT_ID('dbo.PdANASEG_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdANASEG_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdANASEG_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdANASEG_01
 */
GRANT EXECUTE ON dbo.PdANASEG_01 TO GOMEGA
go

