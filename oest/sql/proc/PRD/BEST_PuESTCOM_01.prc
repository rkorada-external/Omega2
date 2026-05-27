use BEST
go


USE BEST
Go

 /* DROP PROC dbo.PuESTCOM_01
*/
IF OBJECT_ID('dbo.PuESTCOM_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuESTCOM_01
   PRINT '<<< DROPPED PROC dbo.PuESTCOM_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuESTCOM_01
     (
       @p_cmt_nt              UCMT_NT,
       @p_cmtlin_nt           UINTORD_NT,
       @p_cmt_t               UCMT_T,
      @p_erreur       varchar(64)=NULL output
     )
as

/***************************************************

Programme: PuESTCOM_01

Fichier script associé : ESUEST01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Modification d'enregistrement dansTESTCOM 

Parametres: 
       @p_cmt_nt              UCMT_NT,
       @p_cmtlin_nt           UINTORD_NT,
       @p_cmt_t               UCMT_T,

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

update TESTCOM
    set cmt_t = @p_cmt_t
   where cmt_nt = @p_cmt_nt
     and cmtlin_nt = @p_cmtlin_nt

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

exec sp_SCOR_INSPRC 'ESUEST01', 'PuESTCOM_01', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PuESTCOM_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuESTCOM_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuESTCOM_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuESTCOM_01
 */
GRANT EXECUTE ON dbo.PuESTCOM_01 TO GOMEGA
go

