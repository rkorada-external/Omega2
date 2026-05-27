USE BEST
Go

 /* DROP PROC dbo.PuREQJOB_07
*/
IF OBJECT_ID('dbo.PuREQJOB_07') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuREQJOB_07
   PRINT '<<< DROPPED PROC dbo.PuREQJOB_07 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuREQJOB_07
     (
      	@p_cre_d		    UUPD_D,
	      @p_balsheyea_nf	smallint,
	      @p_balshtmth_nf	tinyint,
	      @p_clodat_d	    UUPD_D,
	      @p_dbclo_d		  UUPD_D,
	      @p_clodatmax_d	varchar(8)
     )

as

/***************************************************

Programme: PuREQJOB_07
Fichier script associé : BEST_PuREQJOB_07.prc
Domaine : (ES) Estimation
Base principale : BEST
Version: 5.1
Auteur: M.DJELLOULI
Date de creation:  21/07/2005

Description du programme: 
	- Mise a jour de la date de traitement ( LAUNCH_D ) dans BEST..TREQJOB 
        pour les filiales d'un inventaire de Type T ou F (PostOmega)

Parametres: 
       - @p_cre_d : la date de traitement 
	- @p_balsheyea_nf : année ( période comptable )
	- @p_balshtmth_nf : mois ( période comptable )
	- @p_clodat_d : libellé d'inventaire
	- @p_dbclo_d : date d'arrété
       
Conditions d'execution: 

Commentaires:
_________________
MODIFICATION 1
Auteur:	
Date:
Version:
Description:	
-----------------------------------------------
[001] 13/05/2011 R. Cassis   :spot:21408  - Ajout Modification de la table TREQJOBPLAN
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 18/03/2016 R. CASSIS   :spot:29504  - Update run date into treqjobplan table from getdate not cre_d
*****************************************************/

-- -----------------------------------------------------------
-- Déclaration Variables
-- -----------------------------------------------------------

declare @erreur int, @tran_imbr	bit

select @erreur = 0
select @tran_imbr = 1

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
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

/* 1er cas: si libellé d'inventaire = CLODAT1_D */

update BEST..TREQJOB
set	LAUNCH_D = getdate()   --@p_cre_d   --, DBCLO_D = @p_dbclo_d  [101]
from BEST..TREQJOB A
where A.BALSHEYEA_NF = @p_balsheyea_nf
and   A.BALSHTMTH_NF = @p_balshtmth_nf
and   convert( char(8), A.CLODAT_D, 112 ) = @p_clodat_d
and   (A.REQCOD_CT   = "F" or A.REQCOD_CT = "T")
and   A.LAUNCH_D     = NULL
and   A.SITE_CF      = @site_cf
and   A.CRE_D        = (select min (C.CRE_D) 
                        from BEST..TREQJOB C
                        where  C.SSD_CF = A.SSD_CF
                        and    C.BALSHEYEA_NF = A.BALSHEYEA_NF
                        and	 C.BALSHTMTH_NF = A.BALSHTMTH_NF
                        and    C.CLODAT_D  = A.CLODAT_D
                        and    ( C.REQCOD_CT = "F" or C.REQCOD_CT = "T" )
                        and    C.LAUNCH_D = NULL
                        and    C.SITE_CF  = @site_cf
		                   )               

select @erreur = @@error
if @erreur != 0  goto fin

--[001] [101]
update BEST..TREQJOBPLAN
set	LAUNCH_D = getdate()   -- @p_cre_d   --, DBCLO_D = @p_dbclo_d
from BEST..TREQJOBPLAN A, BEST..TREQJOB C
where A.BALSHEYEA_NF = @p_balsheyea_nf
and   A.BALSHTMTH_NF = @p_balshtmth_nf
and   convert( char(8), A.CLODAT_D, 112 ) = @p_clodat_d
and   (A.REQCOD_CT   = "F" or A.REQCOD_CT = "T")
and   A.LAUNCH_D     = NULL
and   A.SITE_CF      = @site_cf
and   A.ID_NF        = C.ID_NF
and   C.CRE_D        is not NULL
/*
and   A.CRE_D = (select min (C.CRE_D) 
                 from BEST..TREQJOBPLAN C
                 where  C.SSD_CF       = A.SSD_CF
                 and    C.BALSHEYEA_NF = A.BALSHEYEA_NF
                 and	  C.BALSHTMTH_NF = A.BALSHTMTH_NF
                 and    C.CLODAT_D     = A.CLODAT_D
                 and    ( C.REQCOD_CT  = "F" or C.REQCOD_CT = "T" )
                 and    C.LAUNCH_D     = NULL
                 and    C.SITE_CF      = @site_cf
          		  )
*/
select @erreur = @@error
if @erreur != 0  goto fin

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

IF OBJECT_ID('dbo.PuREQJOB_07') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuREQJOB_07 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuREQJOB_07 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuREQJOB_07
 */
GRANT EXECUTE ON dbo.PuREQJOB_07 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuREQJOB_07 TO GDBBATCH
go

