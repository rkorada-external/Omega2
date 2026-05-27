USE BEST
go


IF OBJECT_ID('dbo.PuUNDSTA_01_bis') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuUNDSTA_01_bis
    IF OBJECT_ID('dbo.PuUNDSTA_01_bis') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuUNDSTA_01_bis >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuUNDSTA_01_bis >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuUNDSTA_01_bis
     (
       @p_typetraitement  char(1)
     )

as

/***************************************************

Programme: PuUNDSTA_01_bis

Fichier script associé : ESUUND01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME69 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 
	- Mise a jour des tables TUNDSTA (montants stats par exercice), TCTREST (Primes et sinistres
ultimes), TCTRACC (contrats avec mouvements comptables), TSBJPRM (révisions des assiettes comptables) 
de la base BEST
	- Mise a jour de la table TSECTION de la base TRAITE
	- Mise a jour de la table TSECTION de la base FACULTATIVES
	- Mise a jour des tables TREFCMT (commentaires références), TREMINDER (relances) et
TREMINDUSR (lien relance/utilisateur)
	- cette procédure stockée est utilisée sans que les triggers de BTRT..TSECTION et
BTRT..TFAMLIA soient actifs. Les tables BTRT..TFAMLIA_V et BTRT..TSECTION_V sont mises à jour 
afin de remplacer l'action des triggers
      

Parametres: 
       - @p_typetraitement: le type de traitement est quotidien "Q" ou reprise "R"
       

Conditions d'execution: 


Commentaires:


*****************************************************/

declare @erreur int,
        @tran_imbr	bit,
        @nbligne  smallint,
        @nbtime  smallint,
 	 @numero_max_trefcmt 	int,
	 @numero_avd_treminder  	int,  
	 @numero_max_treminder	int,
	 @numero_max_treminusr	int,
	 @d_str varchar(20)
	 
declare 	@errno		int
declare		@errmsg		varchar(255)

Declare @MaxCre_D   Datetime            

select @erreur = 0
select @tran_imbr = 1



/* -----------------------------------------------------------
	Début de la transaction
   ----------------------------------------------------------- */

if @@trancount = 0
  begin
   select @tran_imbr = 0
  BEGIN TRAN
  end


/* ----------------------------------------------------------------
   Mise a jour de la table des montants stats par exercice (TUNDSTA) 
   ---------------------------------------------------------------- */

update	BEST..TUNDSTA
set	A.CACCPRM_M = B.PRMCPLACC_M,
	A.CACCUPR_M = B.UPRCPLACC_M,
	A.CACCCLM_M = B.CLMCPLACC_M,
	A.CACCACR_M = B.ACRCPLACC_M,
	A.CACCLOA_M = B.CHACPLACC_M,
	A.CACCRESPRM_M = B.RESCPLACC_M,
	A.ACCPRM_M = B.ACCPRM_M,
	A.ACCUPR_M = B.ACCUPR_M,
	A.ACCCLM_M = B.ACCCLM_M,
	A.ACCACR_M = B.ACCACR_M,
	A.ACCLOA_M = B.ACCCHA_M,
	A.LSTUPD_D = getdate(),
	A.ACY_NF = B.ACY_NF,
	A.SCOENDMTH_NF = B.SCOENDMTH_NF	
from	BEST..TUNDSTA A, BTRAV..TESTCPLAMT B
where	A.CTR_NF = B.CTR_NF
	and A.UWY_NF = B.UWY_NF
 	and A.UW_NT = B.UW_NT
	and A.END_NT = B.END_NT
	and A.SEC_NF = B.SEC_NF
    
    select 
 B.PRMCPLACC_M,
 B.UPRCPLACC_M,
 B.CLMCPLACC_M,
 B.ACRCPLACC_M,
 B.CHACPLACC_M,
 B.RESCPLACC_M,
 B.ACCPRM_M,
 B.ACCUPR_M,
 B.ACCCLM_M,
 B.ACCACR_M,
 B.ACCCHA_M,
 getdate(),
 B.ACY_NF,
 B.SCOENDMTH_NF	
from	BEST..TUNDSTA A, BTRAV..TESTCPLAMT B
where	A.CTR_NF = B.CTR_NF
	and A.UWY_NF = B.UWY_NF
 	and A.UW_NT = B.UW_NT
	and A.END_NT = B.END_NT
	and A.SEC_NF = B.SEC_NF
    
select @erreur = @@error

if @erreur != 0  
	begin
		select @errno  = 20010
		select @errmsg = 'Erreur Update BEST..TUNDSTA par BTRAV..TESTCPLAMT '
		goto ERREUR		   
	end

if @tran_imbr = 0
	COMMIT TRAN

return 0

ERREUR:
 	raiserror @errno @errmsg 
 	rollback transaction
 	return @erreur


go
EXEC sp_procxmode 'dbo.PuUNDSTA_01_bis','unchained'
go
IF OBJECT_ID('dbo.PuUNDSTA_01_bis') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuUNDSTA_01_bis >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuUNDSTA_01_bis >>>'
go
GRANT EXECUTE ON dbo.PuUNDSTA_01_bis TO GOMEGA
go
