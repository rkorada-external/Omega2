USE BEST
Go

 /* DROP PROC dbo.PsPERITRT_04
*/
IF OBJECT_ID('dbo.PsPERITRT_04') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsPERITRT_04
   PRINT '<<< DROPPED PROC dbo.PsPERITRT_04 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsPERITRT_04
     (
      	@p_segtyp_ct           char(1),
       @p_ssd_cf              tinyint
     )

as

/***************************************************

Programme: PsPERITRT_04

Fichier script associé : ESSSEC48.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME69 

Date de creation: 

Description du programme: 
	- génération d'une table intermédiaire identique à BTRT..TFAMRSVP mais où le champs
ERNPRMADM_B est défini en DEFAULT 1 au lieu de DEFAULT 0
	- procédure appelant PsPERITRT_05 ( génération du périmètre pour les affaires TRT
dans le cadre de la segmentation )
      

Parametres: 
       - @p_segtyp_ct : type de segmentation ( 'A' ou 'E' )
       - @p_ssd_cf : n° filiale 
       

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 

Auteur:	

Date:		

Version:	

Description:	

************************************************************************************/

declare @erreur      int
        
select @erreur = 0


/* creation d'une table temporaire #TFAMRSVP */
/* ----------------------------------------- */

create table #TFAMRSVP(
    CTR_NF       UCTR_NF              NOT NULL,
    UWY_NF       UUWY_NF              NOT NULL,
    UW_NT        UUW_NT               DEFAULT  1,
    END_NT       UEND_NT              DEFAULT  0,
    SEC_NF       USEC_NF              NOT NULL,
    ERNPRMADM_B  tinyint                  NULL,
    POLDURMTH_NF UPERIOD              DEFAULT 12,
    INSPOL_R     USHORAT_R            DEFAULT 1 )
	

/* Alimentation de la table #TFAMRSVP */
/* ---------------------------------- */

insert into #TFAMRSVP
select CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, ERNPRMADM_B, POLDURMTH_NF, INSPOL_R
from BTRT..TFAMRSVP

select @erreur = @@error

if @erreur != 0  goto fin


/* Création d'un index sur la table temporaire #TFAMRSVP */
/* ---------------------------------------------------- */

create index IFAMRSVP on #TFAMRSVP( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF ) 


/* Lancement de la proc qui génère le perimètre des affaires TRT */
/* ------------------------------------------------------------- */

exec BEST..PsPERITRT_05 @p_segtyp_ct, @p_ssd_cf

select @erreur = @@error

if @erreur != 0  goto fin


/***********************************************************************************/

   
return 0

fin:
return 1

go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSEC48', 'PsPERITRT_04', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PsPERITRT_04') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsPERITRT_04 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsPERITRT_04 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsPERITRT_04
 */
GRANT EXECUTE ON dbo.PsPERITRT_04 TO GOMEGA
go

