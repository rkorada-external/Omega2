/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go

/* DROP PROC dbo.PdREQJOB_01
*/
IF OBJECT_ID('dbo.PdREQJOB_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdREQJOB_01
   PRINT '<<< DROPPED PROC dbo.PdREQJOB_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdREQJOB_01
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
      @p_erreur       varchar(64)=NULL output
     )
as

/***************************************************

Programme: PdREQJOB_01

Fichier script associé : ESDREQ01.PRC


Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME24 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      suppression d'enregistrement dans TREQJOB

Parametres: 
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,

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

delete TREQJOB
  where balsheyea_nf = @p_balsheyea_nf
    and balshtmth_nf = @p_balshtmth_nf
    and convert(varchar(8),clodat_d) = convert(varchar(8),@p_clodat_d)
    and convert(varchar(17),cre_d) = convert(varchar(17),@p_cre_d)
    and reqcod_ct = @p_reqcod_ct
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

exec sp_SCOR_INSPRC 'ESDREQ01', 'PdREQJOB_01', 'BEST', 'ME24'
go

IF OBJECT_ID('dbo.PdREQJOB_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdREQJOB_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdREQJOB_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdREQJOB_01
 */
GRANT EXECUTE ON dbo.PdREQJOB_01 TO public
go

