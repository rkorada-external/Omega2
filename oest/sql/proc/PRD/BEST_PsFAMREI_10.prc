use BEST
go


USE BEST
/*
 * DROP PROC dbo.PsFAMREI_10
 */
IF OBJECT_ID('dbo.PsFAMREI_10') IS NOT NULL
BEGIN
    DROP PROC dbo.PsFAMREI_10
    PRINT '<<< DROPPED PROC dbo.PsFAMREI_10 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsFAMREI_10
     (
       @p_ctr_nf              UCTR_NF, 
       @p_end_nt              UEND_NT,	
       @p_sec_nf              USEC_NF,
       @p_uwy_nf              UUWY_NF,
       @p_uw_nt               UUW_NT
     )
as

/***************************************************

Programme: PsFAMREI_10

Fichier script associé : ESSFAM10.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

	- Select BTRT..TFAMREI (lecture famille reconstitution )

	


Parametres: 
       @p_ctr_nf              UCTR_NF,      : Contrat
       @p_uwy_nf              UUWY_NF,      : Exercice
       @p_uw_nt               UUW_NT,	     : N° d'ordre
       @p_end_nt              UEND_NT,      : Avenant
       @p_sec_nf              USEC_NF,      : Section
     
      

Conditions d'execution: 


Commentaires:


_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare 	@erreur         int


	select		ctr_nf,
			uwy_nf,
			uw_nt,
			end_nt,
			sec_nf,
			reilin_nt,
			reirnk_n,
			reiprmbas_r,
			reiprm_m,
			reiprm_r
	  from BTRT..TFAMREI
	 where ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt
         and sec_nf = @p_sec_nf
         and uwy_nf = @p_uwy_nf
         and uw_nt  = @p_uw_nt

	select @erreur = @@error
	if @erreur != 0 begin raiserror 20005 "APPLICATIF;BTRT..TFAMREI" goto fin end


fin:
return @erreur
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSFAM10', 'PsFAMREI_10', 'BEST', 'ME34'
go
IF OBJECT_ID('dbo.PsFAMREI_10') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsFAMREI_10 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsFAMREI_10 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsFAMREI_10
 */
GRANT EXECUTE ON dbo.PsFAMREI_10 TO GOMEGA
go

