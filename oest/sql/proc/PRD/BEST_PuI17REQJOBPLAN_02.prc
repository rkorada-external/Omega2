USE BEST
Go

 /* DROP PROC dbo.PuI17REQJOBPLAN_02
*/
IF OBJECT_ID('dbo.PuI17REQJOBPLAN_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuI17REQJOBPLAN_02
   PRINT '<<< DROPPED PROC dbo.PuI17REQJOBPLAN_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuI17REQJOBPLAN_02
     (	
		@p_norme_cf varchar(10),
      	@p_cre_d		UUPD_D,
	    @p_balsheyea_nf	smallint,
	    @p_balshtmth_nf	tinyint,
	    @p_clodat_d	    UUPD_D
     )

as

/***************************************************

Programme: PuI17REQJOBPLAN_02
Fichier script associé : BEST_PuI17REQJOBPLAN_02.prc
Domaine : (ES) Estimation
Base principale : BEST
Version: 1.0
Auteur: L.DOAN
Date de creation:  17/11/2020

Description du programme: 
	- Mise a jour de la date de traitement ( LAUNCH_D ) dans BEST..I17REQJOBPLAN 
          pour les filiales d'un inventaire SAP dont reqcod est dans  ('POSO','POCO','INVO')

Parametres: 
	- @p_norme_cf : norme de traitement
    	- @p_cre_d : la date de traitement 
	- @p_balsheyea_nf : année ( période comptable )
	- @p_balshtmth_nf : mois ( période comptable )
	- @p_clodat_d : libellé d'inventaire
       
Conditions d'execution: 

Commentaires:
_________________
MODIFICATION 1
Auteur:	
Date:
Version:
Description:	
-----------------------------------------------
[001] 19/02/2020 L. DOAN     :spira:83904 - Update run date into ti17reqjobplan table from getdate not cre_d
[002] 15/10/2020 L. DOAN     :spira:83904 - Update run date into ti17reqjobplan table from getdate not cre_d
[003] 23/10/2020 L. DOAN     :spira:87596 - new architecute EBS&IFRS4 : remove checking closing date
[004] 17/11/2020 L. DOAN     :spira:84234 - planning AOC
*****************************************************/

-- -----------------------------------------------------------
-- Déclaration Variables
-- -----------------------------------------------------------

declare @erreur int, @tran_imbr	bit


select @erreur = 0
select @tran_imbr = 1

declare @recod       	varchar(10)
declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
declare @mesg      		char(70)
declare @MAJ_M      	char(26)
declare @lignes        integer
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

-- -----------------------------------------------------------
-- Début de la transaction
-- -----------------------------------------------------------

if @@trancount = 0
  begin
   select @tran_imbr = 0
  BEGIN TRAN
  end


-- -----------------------------------------------------------
-- Début de la transaction
-- -----------------------------------------------------------


/* update LAUNCH_D */
update BEST..TI17REQJOBPLAN 
set	LAUNCH_D = getdate()   --@p_cre_d   --, DBCLO_D = @p_dbclo_d  [101]
from BEST..TI17REQJOBPLAN  A
where 
--A.BALSHEYEA_NF = @p_balsheyea_nf 
--and   A.BALSHTMTH_NF = @p_balshtmth_nf 
--and   convert( char(8), A.CLODAT_D, 112 ) = @p_clodat_d
A.REQCOD_CT in ('POSO','POCO','INVO')
and   A.LAUNCH_D     = NULL
and   A.SITE_CF      = @site_cf
and   A.DBCLO_D      <= @p_cre_d               

--select @erreur = @@error
select @erreur=@@error,@lignes=@@rowcount,@mesg="cre_d="+convert( char(8), @p_cre_d, 112 )+", balsheyea="+cast( @p_balsheyea_nf as char(4))+", balshtmth=" +cast( @p_balshtmth_nf as char(2))+", clodat_d="+convert( char(8), @p_clodat_d, 112 ), @MAJ_M=convert(char(26),getdate(),109)

if @erreur != 0  goto fin

print 'Maj BEST..TI17REQJOBPLAN %1! : lignes  %2! at %3!' ,@mesg ,@lignes,@MAJ_M


/**********************************************************************************/

   
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

IF OBJECT_ID('dbo.PuI17REQJOBPLAN_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuI17REQJOBPLAN_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuI17REQJOBPLAN_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuI17REQJOBPLAN_02
 */
GRANT EXECUTE ON dbo.PuI17REQJOBPLAN_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuI17REQJOBPLAN_02 TO GDBBATCH
go

