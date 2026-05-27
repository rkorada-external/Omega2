USE BEST
Go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PdSCHCHG_03
*/
IF OBJECT_ID('dbo.PdSCHCHG_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdSCHCHG_03
   PRINT '<<< DROPPED PROC dbo.PdSCHCHG_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdSCHCHG_03
     (
       @p_usr_cf              UUPDUSR_CF ,
      @p_erreur       varchar(64)=NULL output
     )
as

/***************************************************

Programme: PdSCHCHG_03

Fichier script associé : ESDCHG03.PRC


Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)

Date de creation: 

Description du programme: 

      suppression d'enregistrement dans TESTSCH

Parametres: 

       @p_usr_cf              UUPDUSR_CF 

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

delete BEST..TESTSCH
  where usr_cf =  @p_usr_cf

select @erreur = @@error, @nbligne = @@rowcount

select @nbligne

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

exec sp_SCOR_INSPRC 'ESDCHG03', 'PdSCHCHG_03', 'BSTA', 'ME01'
go

IF OBJECT_ID('dbo.PdSCHCHG_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdSCHCHG_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdSCHCHG_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdSCHCHG_03
 */
GRANT EXECUTE ON dbo.PdSCHCHG_03 TO GOMEGA
go

