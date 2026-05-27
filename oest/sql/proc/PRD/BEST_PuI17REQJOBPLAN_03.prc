USE BEST
Go

 /* DROP PROC dbo.PuI17REQJOBPLAN_03
*/
IF OBJECT_ID('dbo.PuI17REQJOBPLAN_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuI17REQJOBPLAN_03
   PRINT '<<< DROPPED PROC dbo.PuI17REQJOBPLAN_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuI17REQJOBPLAN_03
     (	
      	@p_cre_d		UUPD_D,
	    @p_balsheyea_nf	smallint,
	    @p_balshtmth_nf	tinyint,
	    @p_clodat_d	    UUPD_D
     )

as

/***************************************************

Programme: PuI17REQJOBPLAN_03
Fichier script associé : BEST_PuI17REQJOBPLAN_03.prc
Domaine : (ES) Estimation
Base principale : BEST
Version: 1.0
Auteur: J. Bonneau-Dillon
Date de creation:  11/24/2021

Description du programme: 
	- Mise a jour de la date de traitement ( LAUNCH_D ) dans BEST..I17REQJOBPLAN 

Parametres: 
  - @p_cre_d : la date de traitement 
	- @p_balsheyea_nf : année ( période comptable )
	- @p_balshtmth_nf : mois ( période comptable )
	- @p_clodat_d : libellé d'inventaire
       
Conditions d'execution: 

Commentaires:
_________________
MODIFICATION 001  [MOD001]
Auteur:				J.Bonneau-Dillon
Date:					12/14/2021
Version:			1
Description:	Spira 100737
-----------------------------------------------

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
UPDATE BEST..TI17REQJOBPLAN 
	SET	LAUNCH_D = getdate()
		WHERE REQCOD_CT in ('A', 'V', 'Z') -- [MOD001]
			AND LAUNCH_D = NULL
			AND SITE_CF in (@site_cf, 'ALL')
			AND DBCLO_D <= @p_cre_d               

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

IF OBJECT_ID('dbo.PuI17REQJOBPLAN_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuI17REQJOBPLAN_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuI17REQJOBPLAN_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuI17REQJOBPLAN_03
 */
GRANT EXECUTE ON dbo.PuI17REQJOBPLAN_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuI17REQJOBPLAN_03 TO GDBBATCH
go

