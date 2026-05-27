use BEST
go


USE BEST
/*
 * DROP PROC dbo.PsFAMCOTP_01
 */
IF OBJECT_ID('dbo.PsFAMCOTP_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsFAMCOTP_01
    PRINT '<<< DROPPED PROC dbo.PsFAMCOTP_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsFAMCOTP_01
     (
       @p_ctr_nf              UCTR_NF, 
       @p_end_nt              UEND_NT,	
       @p_sec_nf              USEC_NF,
       @p_uwy_nf              UUWY_NF,
       @p_uw_nt               UUW_NT
     )
as

/***************************************************

Programme: PsFAMCOTP_01

Fichier script associé : ESSFAM01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

	- Déclaration des variables
	- Select BTRT..TFAMCOTP (lecture famille tarification et primes )
	- Select final des variables
	


Parametres: 
       @p_ctr_nf              UCTR_NF,      : Contrat
       @p_uwy_nf              UUWY_NF,      : Exercice
       @p_uw_nt               UUW_NT,	       : N° d'ordre
       @p_end_nt              UEND_NT,      : Avenant
       @p_sec_nf              USEC_NF,      : Section
     
      

Conditions d'execution: 


Commentaires:


_________________
MODIFICATION 1

Auteur: K. SUGANDH	

Date: 27/05/2014

Version:

Description: Changes for TRT83

*****************************************************/

declare 	@erreur         int

/*--------------------------- ------
  Déclaration table TFAMCOTP (TRAITE)
------------------------------------*/
declare	@prmflcrat_b        bit,			/* taux de prime variable (fixe) ?			*/
		@prmfixeff_r        USHORAT_R,		/* taux effectif fixe					*/
		@prmmineff_r        USHORAT_R,		/* taux effectif minimum					*/
		@prmmaxeff_r        USHORAT_R,		/* taux effectif maximum					*/
		@suploatyp_ct       USHORAT_R,		/* type de chargement					*/
		@prmeffloa_m        UAMT_M,		/* montant du chargement effectif			*/
		@prmeffloa_r        USHORAT_R,		/* taux de chargement effectif				*/
		@sbjprmcur_cf       UCUR_CF,		/* devise de l'assiette de prime			*/
		@estsbjprm_m        UAMT_M,		/* montant de l'assiette de prime estimé		*/
		@defsbjprm_m        UAMT_M,		/* montant de l'assiette de prime définitive	*/
		@sbjprmcpt_m        UAMT_M,		/* montant de l'assiette comptable			*/
		@flaprm_b           bit,			/* prime forfaitaire ?					*/
		@sbjcptdef_b        bit,			/* top assiette définitive				*/
		@prvprm_b           bit,			/* prime provisionnelle ?				*/
		@minprvpr1_m        UAMT_M,		/* montant minimum 1 prime provisionnelle		*/
		@prvprmcu1_cf       UCUR_CF,		/* devise prime provisionnelle 1			*/
		@minprvpr2_m        UAMT_M,		/* montant minimum 2 prime provisionnelle		*/
		@prvprmcu2_cf       UCUR_CF,		/* devise prime provisionnelle 2			*/
		@minprvpr3_m        UAMT_M,		/* montant minimum 3 prime provisionnelle		*/
		@prvprmcu3_cf       UCUR_CF,		/* devise prime provisionnelle 3			*/
		@minprvpr4_m        UAMT_M,		/* montant minimum 4 prime provisionnelle		*/  -- modif 1
		@prvprmcu4_cf       UCUR_CF,		/* devise prime provisionnelle 4			*/	-- modif 1
		@minprvpr5_m        UAMT_M,		/* montant minimum 5 prime provisionnelle		*/	-- modif 1
		@prvprmcu5_cf       UCUR_CF		/* devise prime provisionnelle 5			*/		-- modif 1

/*****************************************************************************************
  TRAITE
*******************************************************************************************/
IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%" 
begin

	select		@prmflcrat_b = prmflcrat_b,
			@prmfixeff_r = prmfixeff_r,
			@prmmineff_r = prmmineff_r,
			@prmmaxeff_r = prmmaxeff_r,
			@suploatyp_ct = suploatyp_ct,
			@prmeffloa_m  = prmeffloa_m,
			@prmeffloa_r  = prmeffloa_r,
			@sbjprmcur_cf = sbjprmcur_cf,
			@estsbjprm_m  = estsbjprm_m,
			@defsbjprm_m  = defsbjprm_m,
			@sbjprmcpt_m  = sbjprmcpt_m,
			@flaprm_b     = flaprm_b,
			@sbjcptdef_b  = sbjcptdef_b,
			@prvprm_b     = prvprm_b,
			@minprvpr1_m  = minprvpr1_m,
			@prvprmcu1_cf = prvprmcu1_cf,
			@minprvpr2_m  = minprvpr2_m,
			@prvprmcu2_cf = prvprmcu2_cf,
			@minprvpr3_m  = minprvpr3_m,
			@prvprmcu3_cf = prvprmcu3_cf,
			@minprvpr4_m  = minprvpr4_m,	-- modif 1
			@prvprmcu4_cf = prvprmcu4_cf,	-- modif 1
			@minprvpr5_m  = minprvpr5_m,	-- modif 1
			@prvprmcu5_cf = prvprmcu5_cf	-- modif 1
	  from BTRT..TFAMCOTP
	 where ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt
         and sec_nf = @p_sec_nf
         and uwy_nf = @p_uwy_nf
         and uw_nt  = @p_uw_nt

	select @erreur = @@error
	if @erreur != 0 begin raiserror 20005 "APPLICATIF;BTRT..TFAMCOTP" goto fin end
end
  
/*-----------------
 Select final
-----------------*/

select 	@p_ctr_nf			ctr_nf,	
		@p_end_nt			end_nt,
		@p_sec_nf			sec_nf,
		@p_uwy_nf			uwy_nf,
		@p_uw_nt			uw_nt,	
		@prmflcrat_b			prmflcrat_b,
		IsNull(@prmfixeff_r,0)	prmfixeff_r,
		IsNull(@prmmineff_r,0)	prmmineff_r,
		IsNull(@prmmaxeff_r,0)	prmmaxeff_r,
		IsNull(@suploatyp_ct,0)	suploatyp_ct,
		IsNull(@prmeffloa_m,0)	prmeffloa_m,
		IsNull(@prmeffloa_r,0)	prmeffloa_r,
		@sbjprmcur_cf		sbjprmcur_cf,
		IsNull(@estsbjprm_m,0)	estsbjprm_m,
		IsNull(@defsbjprm_m,0)	defsbjprm_m,
		IsNull(@sbjprmcpt_m,0)	sbjprmcpt_m,
		@flaprm_b			flaprm_b,
		@sbjcptdef_b			sbjcptdef_b,
		@prvprm_b			prvprm_b,
		IsNull(@minprvpr1_m,0)	minprvpr1_m,
		@prvprmcu1_cf		prvprmcu1_cf,
		IsNull(@minprvpr2_m,0)	minprvpr2_m,
		@prvprmcu2_cf		prvprmcu2_cf,
		IsNull(@minprvpr3_m,0)	minprvpr3_m,
		@prvprmcu3_cf		prvprmcu3_cf,
		IsNull(@minprvpr4_m,0)	minprvpr4_m,	-- modif 1
		@prvprmcu4_cf		prvprmcu4_cf,		-- modif 1
		IsNull(@minprvpr5_m,0)	minprvpr5_m,	-- modif 1
		@prvprmcu5_cf		prvprmcu5_cf		-- modif 1



fin:
return @erreur
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSFAM01', 'PsFAMCOTP_01', 'BEST', 'ME34'
go
IF OBJECT_ID('dbo.PsFAMCOTP_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsFAMCOTP_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsFAMCOTP_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsFAMCOTP_01
 */
GRANT EXECUTE ON dbo.PsFAMCOTP_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsFAMCOTP_01 TO GDBBATCH
go

