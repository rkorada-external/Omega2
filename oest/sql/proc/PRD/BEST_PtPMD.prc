use BEST
go

use BEST
go

USE BEST
/*
 * DROP PROC dbo.PtPMD
 */
IF OBJECT_ID('dbo.PtPMD') IS NOT NULL
BEGIN
    DROP PROC dbo.PtPMD
    PRINT '<<< DROPPED PROC dbo.PtPMD >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtPMD
	(
		@p_prvprm_b		bit,
		@p_minprvpr1_m	UAMT_M,
		@p_prvprmcu1_cf	UCUR_CF,
		@p_minprvpr2_m	UAMT_M,
		@p_prvprmcu2_cf	UCUR_CF,
		@p_minprvpr3_m	UAMT_M,
		@p_prvprmcu3_cf	UCUR_CF,
		@p_minprvpr4_m	UAMT_M,		-- modif 2
		@p_prvprmcu4_cf	UCUR_CF,	-- modif 2
		@p_minprvpr5_m	UAMT_M,		-- modif 2
		@p_prvprmcu5_cf	UCUR_CF,	-- modif 2
		@p_egpcur_cf 	UCUR_CF,
		@p_sbjprmcur_cf	UCUR_CF,
		@p_estsbjprm_m	UAMT_M,
		@p_defsbjprm_m	UAMT_M,
		@p_sbjprmcpt_m	UAMT_M,
		@p_prmeffloa_m	UAMT_M,
		@p_uwy_nf		UUWY_NF,
		@p_ssd_cf		USSD_CF,
		@p_sbjcptdef_b 	bit,
		@p_laycap_m		UAMT_M,	
		@p_liacur_cf	UCUR_CF
	) 
as

/***************************************************

Programme: PtPMD

Fichier script associé : ESTPMD.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34

Date de creation: 26/06/1997

Description du programme: 

	- Si prime provisionnelle (prvprm_b = 1)
		=> Calcul de la PMD en devise aliment 
	
	- Si devise aliment (egpcur_cf) <> devise assiette (sbjprmcur_cf)
		=> convertion en devise aliment des montants suivant :
			- montant de l'assiette estimé (estsbjprm_m)
			- montant de l'assiette définitive (defsbjprm_m)
			- montant de l'assiette comptable (sbjprmcpt_m)
			- montant de chargement effectif (prmeffloa_m)

	- Si top assiette définitive (sbjcptdef_b)= 1
		=> l'assiette de prime = montant de l'assiette comptable
	  sinon si il existe une assiette définitive alors
		=> l'assiette de prime = montant de l'assiette définitive
	  sinon
		=> l'assiette de prime = montant de l'assiette estimé


Parametres: 
      		@p_prvprm_b		bit,		/* prime provisionnelle ?				*/
		@p_minprvpr1_m	UAMT_M,	/* montant minimum 1 prime provisionnelle		*/
		@p_prvprmcu1_cf	UCUR_CF,	/* devise prime provisionnelle 1			*/
		@p_minprvpr2_m	UAMT_M,	/* montant minimum 2 prime provisionnelle		*/
		@p_prvprmcu2_cf	UCUR_CF,	/* devise prime provisionnelle 2			*/
		@p_minprvpr3_m	UAMT_M,	/* montant minimum 3 prime provisionnelle		*/
		@p_prvprmcu3_cf	UCUR_CF	/* devise prime provisionnelle 3			*/
		@p_minprvpr4_m	UAMT_M,	/* montant minimum 4 prime provisionnelle		*/	-- modif 2
		@p_prvprmcu4_cf	UCUR_CF	/* devise prime provisionnelle 4			*/		-- modif 2
		@p_minprvpr5_m	UAMT_M,	/* montant minimum 5 prime provisionnelle		*/	-- modif 2
		@p_prvprmcu5_cf	UCUR_CF	/* devise prime provisionnelle 5			*/		-- modif 2
		@p_egpcur_cf		UCUR_CF,	/* devise de l'aliment					*/
		@p_sbjprmcur_cf	UCUR_CF,	/* devise de l'assiette					*/
		@p_estsbjprm_m	UAMT_M,	/* montant de l'assiette de prime estimé		*/
		@p_defsbjprm_m	UAMT_M,	/* montant de l'assiette de prime définitive	*/
		@p_sbjprmcpt_m	UAMT_M,	/* montant de l'assiette comptable			*/
		@p_prmeffloa_m	UAMT_M,	/* montant du chargement effectif			*/
		@p_uwy_nf    	UUWY_NF,	/* exercice							*/
		@p_ssd_cf		USSD_CF,	/* filiale							*/
      		@p_sbjcptdef_b 	bit    	/* top assiette definitive				*/
		@p_laycap_m		UAMT_M,	/* montant portée */
		@p_liacur_cf		UCUR_CF	/* devise engagement */		
	
		
Conditions d'execution: 


Commentaires:


_________________
MODIFICATIONS

1	L.DEBEVER	10/07/1997	Transfert des traitements dans PtPMD1
2 	K.SUGANDH	27/05/2014	Changes for TRT83 Added new parameters		

*****************************************************/

declare @erreur int
declare @pmd_m UAMT_M
declare @assiette_prime	UAMT_M
declare @clmact_m	UAMT_M



execute @erreur = BEST..PtPMD1    
		@p_prvprm_b,
		@p_minprvpr1_m,
		@p_prvprmcu1_cf,
		@p_minprvpr2_m,
		@p_prvprmcu2_cf,
		@p_minprvpr3_m,
		@p_prvprmcu3_cf,
		@p_minprvpr4_m,		-- modif 2
		@p_prvprmcu4_cf,	-- modif 2
		@p_minprvpr5_m,		-- modif 2
		@p_prvprmcu5_cf,	-- modif 2
		@p_egpcur_cf,
		@p_sbjprmcur_cf,
		@p_estsbjprm_m	output,
		@p_defsbjprm_m	output,
		@p_sbjprmcpt_m	output,
		@p_prmeffloa_m	output,
		@p_uwy_nf,
		@p_ssd_cf,
		@p_sbjcptdef_b,
		@pmd_m			output,
		@assiette_prime	output,
		@clmact_m		output,
		@p_laycap_m  		output,
		@p_liacur_cf
 				
	 if @erreur != 0 begin goto fin end


/*---------------------
     Select final
-----------------------*/
SELECT 	@pmd_m			pmd_m,
		@p_prmeffloa_m	prmeffloa_m,
		@p_estsbjprm_m	estsbjprm_m,
		@p_defsbjprm_m 	defsbjprm_m,
		@p_sbjprmcpt_m 	sbjprmcpt_m,
		@assiette_prime	assiette_prime,
		@clmact_m 		clmact_m,
		@p_laycap_m         laycap_m	

fin:


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESTPMD', 'PtPMD', 'BEST', 'ME34'
go
IF OBJECT_ID('dbo.PtPMD') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtPMD >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtPMD >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtPMD
 */
GRANT EXECUTE ON dbo.PtPMD TO GOMEGA
go
GRANT EXECUTE ON dbo.PtPMD TO GDBBATCH
go


