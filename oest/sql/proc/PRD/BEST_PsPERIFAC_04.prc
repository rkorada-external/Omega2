USE BEST
Go

 /* DROP PROC dbo.PsPERIFAC_04
*/
IF OBJECT_ID('dbo.PsPERIFAC_04') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsPERIFAC_04
   PRINT '<<< DROPPED PROC dbo.PsPERIFAC_04 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsPERIFAC_04
     (
      	@p_segtyp_ct           char(1),
       @p_ssd_cf              tinyint
     )

as

/***************************************************

Programme: PsPERIFAC_04

Fichier script associé : ESSSEC50.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME69 

Date de creation: 

Description du programme: 
	- génération d'une table intermédiaire regroupant la dernière ligne de BEST..TCTRULT
( CRE_D maxi ) pour un CASEX donné afin de récupérer le champs ADMMODPRM_CT
	- procédure appelant PsPERIFAC_05 ( génération du périmètre pour les affaires FAC )
      

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


/* creation d'une table temporaire #TCTRULT */
/* ---------------------------------------- */

create table #TCTRULT(
	CTR_NF		UCTR_NF		not null,
	END_NT		UEND_NT		not null,
	SEC_NF		USEC_NF		not null,
	UWY_NF		UUWY_NF		not null,
	UW_NT		UUW_NT			not null,
	ADMMODPRM_CT	char(1)		DEFAULT 'M',
	CRE_D		datetime		null )
	

/* Recherche de la dernière ligne de TCTRULT pour un CASEX donné */
/* ------------------------------------------------------------- */

insert into #TCTRULT
select T1.CTR_NF, T1.END_NT, T1.SEC_NF, T1.UWY_NF, T1.UW_NT, T1.ADMMODPRM_CT, T1.CRE_D
from BEST..TCTRULT T1
where T1.SSD_CF = @p_ssd_cf
and T1.CRE_D = ( select max( T3.CRE_D )
	from BEST..TCTRULT T3
	where 	T1.CTR_NF = T3.CTR_NF and
              T1.END_NT = T3.END_NT and
              T1.SEC_NF = T3.SEC_NF and
              T1.UWY_NF= T3.UWY_NF  and
              T1.UW_NT = T3.UW_NT )

select @erreur = @@error

if @erreur != 0  goto fin


/* Création d'un index sur la table temporaire #TCTRULT */
/* ---------------------------------------------------- */

create index ICTRULT on #TCTRULT ( CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT )


/* Lancement de la proc qui génère le perimètre des affaires FAC */
/* ------------------------------------------------------------- */

exec BEST..PsPERIFAC_05 @p_segtyp_ct, @p_ssd_cf

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

exec sp_SCOR_INSPRC 'ESSSEC50', 'PsPERIFAC_04', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PsPERIFAC_04') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsPERIFAC_04 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsPERIFAC_04 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsPERIFAC_04
 */
GRANT EXECUTE ON dbo.PsPERIFAC_04 TO GOMEGA
go

