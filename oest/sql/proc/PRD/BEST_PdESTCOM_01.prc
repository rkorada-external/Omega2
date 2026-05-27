use BEST
go


USE BEST
Go

 /* DROP PROC dbo.PdESTCOM_01
*/
IF OBJECT_ID('dbo.PdESTCOM_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdESTCOM_01
   PRINT '<<< DROPPED PROC dbo.PdESTCOM_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdESTCOM_01
     (
       @p_cmt_nt              UCMT_NT,
       @p_erreur       varchar(64)=NULL output
     )
as

/***************************************************

Programme: PdESTCOM_01

Fichier script associé : ESDEST01.PRC


Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      suppression d'enregistrement dans TESTCOM

Parametres: 
       @p_cmt_nt              UCMT_NT, : N° du commentaire


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

delete TESTCOM
  where cmt_nt = @p_cmt_nt
 

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

exec sp_SCOR_INSPRC 'ESDEST01', 'PdESTCOM_01', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PdESTCOM_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdESTCOM_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdESTCOM_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdESTCOM_01
 */
GRANT EXECUTE ON dbo.PdESTCOM_01 TO GOMEGA
go

