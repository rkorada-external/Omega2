USE BEST
GO

/*
 * DROP PROC dbo.PsCTRULT_11  */
IF OBJECT_ID('dbo.PsCTRULT_11') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCTRULT_11
    PRINT '<<< DROPPED PROC dbo.PsCTRULT_11 >>>'
END
go

/*
 * creation de la procedure  */
create procedure PsCTRULT_11 (
    @p_ctr_nf              UCTR_NF,	
    @p_end_nt              UEND_NT,	
    @p_sec_nf              USEC_NF,
    @p_uwy_nf              UUWY_NF,
    @p_uw_nt               UUW_NT
)
as

/***************************************************
Programme: PsCTRULT_11

Fichier script associé : ESSCTR11.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

	- Création table temporaire #ctrult	
	- Insert/Select de BEST..TCTRULT  -->#ctrult
   	- Update #ctrult (calcul de S/P Proposes en %)
   	- Update #ctrult (calcul de S/P Manuels en %)
   	- Update #ctrult (calcul de S/P Retenus en %)
   	- Update #ctrult (calcul de S/P Reconstitués en %)
	- Select de #ctrult
	- Suppression table temporaire #ctrult
Parametres: 
       @p_ctr_nf              UCTR_NF,      : Contrat
       @p_end_nt              UEND_NT,      : Avenant
       @p_sec_nf              USEC_NF,      : Section
       @p_uwy_nf              UUWY_NF,      : Exercice
       @p_uw_nt               UUW_NT        : N° ordre
_________________
MODIFICATION    [001]
Auteur:         D.GATIBELZA
Date:		    30/09/2009
Version:        9.1
Description:	ESTDOM15043 Ultimes  Revisions des regles de gestion et corrections de l'écran estimation des ultimes
*****************************************************/

declare @erreur     int

create table #ctrult (
				ctr_nf             UCTR_NF        NULL,
				end_nt             UEND_NT        NULL,
				sec_nf             USEC_NF        NULL,
				uwy_nf             UUWY_NF        NULL,
				uw_nt              UUW_NT         NULL,
				ssd_cf             USSD_CF        NULL,
				cre_d              UUPD_D         NULL,
				admmodprm_ct       char(1)        NULL,
				calamtprm_m        UAMT_M         NULL,
				entamtprm_m        UAMT_M         NULL,
				retamtprm_m        UAMT_M         NULL,
				resprm_m           UAMT_M         NULL,
				updusr_cf          char(10)       NULL,
				admmodclm_ct       char(1)        NULL,
				sp_proposes        UAMT_M         NULL,       
				sp_manuels         UAMT_M         NULL,
				sp_retenus         UAMT_M         NULL,
				sp_reconst         UAMT_M         NULL,
				oricod_ls          UL16           NULL,
				calamtclm_m        UAMT_M         NULL,
				entamtclm_m        UAMT_M         NULL,
				retamtclm_m        UAMT_M         NULL,
				cur_cf             UCUR_CF        NULL,
				div_nt             UDIV_NT        NULL,
				lstupd_d           UUPD_D         NULL,
    				lstupdusr_cf       UUPDUSR_CF     NULL        
             	  )

set arithabort numeric_truncation off /* éviter 'truncation error' */
/*-------------------------------------------
 Insert/Select de BEST..TCTRULT  --> #ctrult
---------------------------------------------*/
Insert into #ctrult
select ctr_nf,
       end_nt,
       sec_nf,
       uwy_nf,
       uw_nt,
       ssd_cf,
       cre_d,
       admmodprm_ct,
       isnull(calamtprm_m,0) calamtprm_m,
       isnull(entamtprm_m,0) entamtprm_m,
       isnull(retamtprm_m,0) retamtprm_m,
       isnull(resprm_m,0) resprm_m,
       updusr_cf,
       admmodclm_ct,
       0,
       0,
       0,
       0,
       oricod_ls,
       isnull(calamtclm_m,0) calamtclm_m,
       isnull(entamtclm_m,0) entamtclm_m,
       isnull(retamtclm_m,0) retamtclm_m,
       cur_cf,
       div_nt,
       lstupd_d,
       lstupdusr_cf
  from TCTRULT
 where ctr_nf = @p_ctr_nf
   and end_nt = @p_end_nt
   and sec_nf = @p_sec_nf 
   and uwy_nf = @p_uwy_nf
   and uw_nt  = @p_uw_nt
 

select @erreur = @@error
if @erreur != 0 begin raiserror 20001 '20001 APPLICATIF;TCTRULT->#ctrult;' goto fin end

/*---------------------------
 Calcul du S/P Proposes (%)
 Update de #ctrult --> #ctrult
----------------------------*/
update #ctrult
-- [001] retour en arrière:
    set sp_proposes = -(calamtclm_m/calamtprm_m) * 100
-- [001] set sp_proposes = -(calamtclm_m/retamtprm_m) * 100 
  from #ctrult 
-- [001]
 where calamtprm_m <> 0
--[001] where retamtprm_m <> 0	/* Empêche la division par zéro */

select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;sp_proposes #ctrult->#ctrult;' goto fin end

/*---------------------------
 Calcul du S/P Manuels (%)
 Update de #ctrult --> #ctrult
----------------------------*/
update #ctrult
set sp_manuels = -(entamtclm_m/entamtprm_m)*100 
/*   set sp_manuels = -(entamtclm_m/retamtprm_m)*100 */
  from #ctrult 
 where entamtprm_m <> 0	/* Empêche la division par zéro */

select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;sp_manuels #ctrult->#ctrult;' goto fin end


/*---------------------------
 Calcul du S/P Retenus (%)
 Update de #ctrult --> #ctrult
----------------------------*/

update #ctrult
   set sp_retenus = -(retamtclm_m/retamtprm_m)*100 
  from #ctrult 
 where retamtprm_m <> 0	/* Empêche la division par zéro */

select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF; sp_retenus #ctrult->#ctrult;' goto fin end



/*-----------------------------
 Calcul du S/P Reconstitués (%)
 Update de #ctrult --> #ctrult
------------------------------*/

update #ctrult
   set sp_reconst = -(retamtclm_m/resprm_m)*100 
  from #ctrult 
 where retamtprm_m <> 0 and resprm_m <> 0	/* Empêche la division par zéro */

select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF; sp_reconst #ctrult->#ctrult;' goto fin end


/*-----------------
 Select final
-----------------*/
select * from #ctrult

select @erreur = @@error
if @erreur != 0 begin raiserror 20005 '20005 APPLICATIF;#liste;' goto fin end

/* --------------------------------
Suppression de la table temporaire
----------------------------------*/
fin:
drop table #ctrult

set arithabort numeric_truncation on /* remettre 'truncation error' */

return @erreur
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSCTR11', 'PsCTRULT_11', 'BEST', 'ME34'
go
IF OBJECT_ID('dbo.PsCTRULT_11') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCTRULT_11 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCTRULT_11 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCTRULT_11
 */
GRANT EXECUTE ON dbo.PsCTRULT_11 TO GOMEGA
go

