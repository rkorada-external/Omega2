use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PdACCSUP_01
*/

USE BEST
Go


IF OBJECT_ID('dbo.PdACCSUP_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdACCSUP_01
   PRINT '<<< DROPPED PROC dbo.PdACCSUP_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdACCSUP_01
     (
       @p_trn_nt              numeric,
       @p_acctyp_nf           tinyint,
       @p_lstupd_d     	  UUPD_D=NULL output,
       @p_lstupdusr_cf    	  UUPDUSR_CF=NULL output,
       @p_erreur       	  varchar(64)=NULL output
     )
as

/***************************************************

Programme: PdACCSUP_01

Fichier script associé : ESDSUP01.PRC


Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)

Date de creation: 

Description du programme: 

      suppression d'enregistrement dans TACCSUP

Parametres: 
       @p_trn_nt              numeric,
       @p_acctyp_nf              tinyint,
       @p_lstupd_d     	  UUPD_D=NULL output,
       @p_lstupdusr_cf   	  UUPDUSR_CF=NULL output,

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



/* Suppression de l'écriture passée en paramètre                                   */

delete TACCSUP
  where trn_nt = @p_trn_nt

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
  


/* Si l'écriture passée en paramètre est de type '1',                            */
/*  suppression des écritures de type '0' rattachées                             */

IF   @p_acctyp_nf = 1 

BEGIN

	delete TACCSUP
 	 where  acctrn_nt =  @p_trn_nt
		 and acctyp_nf = 0

	select @erreur = @@error
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
   
END



/* Variables output                                                                */ 

select @p_lstupdusr_cf = lstupdusr_cf,
       @p_lstupd_d = lstupd_d                        
from TACCSUP
       where trn_nt = @p_trn_nt
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

exec sp_SCOR_INSPRC 'ESDSUP01', 'PdACCSUP_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PdACCSUP_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdACCSUP_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdACCSUP_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdACCSUP_01
 */
GRANT EXECUTE ON dbo.PdACCSUP_01 TO GOMEGA
go

