use BEST
go


USE BEST
Go

/* DROP PROC dbo.PiESTCOM_01
*/
IF OBJECT_ID('dbo.PiESTCOM_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiESTCOM_01
   PRINT '<<< DROPPED PROC dbo.PiESTCOM_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiESTCOM_01
     (
       @p_ssd_cf              int,
       @p_cmt_t               UCMT_T,
       @p_cmt_nt              UCMT_NT output,
       @p_erreur	varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiESTCOM_01

Fichier script associé : ESIEST01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO) 

Date de creation: 

Description du programme: 

      Insertion d'enregistrement dans TESTCOM

Parametres: 
       @p_cmt_nt              UCMT_NT,
       @p_cmt_t               UCMT_T,
       @p_erreur	varchar(64)=NULL output

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
        @num_idt   int

select @erreur = 0
select @tran_imbr = 1		 		
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end 

select @num_idt = 0
select @num_idt = isnull(max(cmt_nt),0) from TESTCOM
select @num_idt = @num_idt + 1

insert into TESTCOM
      (
                cmt_nt,
                cmtlin_nt,
                cmt_t
      )
 values
      (
        @num_idt,
        1,
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

/* ------------------------------
   Retour du N° de commentaire 
---------------------------------*/
select @p_cmt_nt = @num_idt

if @tran_imbr = 0
   COMMIT TRAN

return 0

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

exec sp_SCOR_INSPRC 'ESIEST01', 'PiESTCOM_01', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PiESTCOM_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiESTCOM_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiESTCOM_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiESTCOM_01
 */
GRANT EXECUTE ON dbo.PiESTCOM_01 TO GOMEGA
go

