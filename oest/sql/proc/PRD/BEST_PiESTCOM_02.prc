use BEST
go
IF OBJECT_ID('dbo.PiESTCOM_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiESTCOM_02
    IF OBJECT_ID('dbo.PiESTCOM_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiESTCOM_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiESTCOM_02 >>>'
END
go
create procedure PiESTCOM_02
     (
       @p_cmtlin_nt           UINTORD_NT,
       @p_cmt_t               UCMT_T,
       @p_cmt_nt              UCMT_NT output,
      @p_erreur	varchar(64)=NULL output
)
as

/***************************************************

Programme: PiESTCOM_02

Fichier script associé : ESIEST02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:

      Insertion d'enregistrement dans TESTCOM

Parametres:
       @p_cmt_nt              UCMT_NT,
       @p_cmtlin_nt           UINTORD_NT,
       @p_cmt_t               UCMT_T,
       @p_erreur	varchar(64)=NULL output

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:  J. Ribot

Date:   12 03 2008

Version:

Description:   SPOT15091 init   @tran_imbr	bit

*****************************************************/

declare @erreur int,
        @tran_imbr	bit

select @tran_imbr = 1             -- JR SPOT15091 12/03/2008

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end


insert into TESTCOM
      (
                cmt_nt,
                cmtlin_nt,
                cmt_t
      )
 values
      (
        @p_cmt_nt,
        @p_cmtlin_nt,
        @p_cmt_t
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

if @tran_imbr = 0
   COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur
go
IF OBJECT_ID('dbo.PiESTCOM_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiESTCOM_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiESTCOM_02 >>>'
go
GRANT EXECUTE ON dbo.PiESTCOM_02 TO GOMEGA
go
