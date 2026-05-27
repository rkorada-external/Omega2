use BEST
go

use BEST
go

USE BEST
/*
 * DROP PROC dbo.PtPMD1
 */
IF OBJECT_ID('dbo.PtPMD1') IS NOT NULL
BEGIN
    DROP PROC dbo.PtPMD1
    PRINT '<<< DROPPED PROC dbo.PtPMD1 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtPMD1
	(
		@p_prvprm_b		bit,
		@p_minprvpr1_m	UAMT_M,
		@p_prvprmcu1_cf	UCUR_CF,
		@p_minprvpr2_m	UAMT_M,
		@p_prvprmcu2_cf	UCUR_CF,
		@p_minprvpr3_m	UAMT_M,
		@p_prvprmcu3_cf	UCUR_CF,
		@p_minprvpr4_m	UAMT_M, --modif 01
		@p_prvprmcu4_cf	UCUR_CF, --modif 01
		@p_minprvpr5_m	UAMT_M, --modif 01
		@p_prvprmcu5_cf	UCUR_CF, --modif 01
		@p_egpcur_cf 	UCUR_CF,
		@p_sbjprmcur_cf	UCUR_CF,
		@p_estsbjprm_m	UAMT_M=NULL output,
		@p_defsbjprm_m	UAMT_M=NULL output,
		@p_sbjprmcpt_m	UAMT_M=NULL output,
		@p_prmeffloa_m	UAMT_M=NULL output,
		@p_uwy_nf		UUWY_NF,
		@p_ssd_cf		USSD_CF,
		@p_sbjcptdef_b 	bit,
		@p_pmd_m	      UAMT_M=NULL output,
		@p_assiette_prime	UAMT_M=NULL output,
		@p_clmact_m		UAMT_M=NULL output,
		@p_laycap_m		UAMT_M=NULL output,
		@p_liacur_cf		UCUR_CF	
	) 
as

/***************************************************

Programme: PtPMD1

Fichier script associ? : ESTPMD1.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 (L.DEBEVER) 

Date de creation: 10/07/1997
Description du programme: 

	- Si prime provisionnelle (prvprm_b = 1)
		=> Calcul de la PMD en devise aliment 
	
	- Si devise aliment (egpcur_cf) <> devise assiette (sbjprmcur_cf)
		=> convertion en devise aliment des montants suivant :
			- montant de l'assiette estim? (estsbjprm_m)
			- montant de l'assiette d?finitive (defsbjprm_m)
			- montant de l'assiette comptable (sbjprmcpt_m)
			- montant de chargement effectif (prmeffloa_m)

	- Si top assiette d?finitive (sbjcptdef_b)= 1
		=> l'assiette de prime = montant de l'assiette comptable
	  sinon si il existe une assiette d?finitive alors
		=> l'assiette de prime = montant de l'assiette d?finitive
	  sinon
		=> l'assiette de prime = montant de l'assiette estim?


Parametres: 
      		@p_prvprm_b		bit,		/* prime provisionnelle ?				*/
		@p_minprvpr1_m	UAMT_M,	/* montant minimum 1 prime provisionnelle		*/
		@p_prvprmcu1_cf	UCUR_CF,	/* devise prime provisionnelle 1			*/
		@p_minprvpr2_m	UAMT_M,	/* montant minimum 2 prime provisionnelle		*/
		@p_prvprmcu2_cf	UCUR_CF,	/* devise prime provisionnelle 2			*/
		@p_minprvpr3_m	UAMT_M,	/* montant minimum 3 prime provisionnelle		*/
		@p_prvprmcu3_cf	UCUR_CF	/* devise prime provisionnelle 3			*/
		@p_egpcur_cf		UCUR_CF,	/* devise de l'aliment					*/
		@p_sbjprmcur_cf	UCUR_CF,	/* devise de l'assiette					*/
		@p_estsbjprm_m	UAMT_M,	/* montant de l'assiette de prime estim?		*/
		@p_defsbjprm_m	UAMT_M,	/* montant de l'assiette de prime d?finitive	*/
		@p_sbjprmcpt_m	UAMT_M,	/* montant de l'assiette comptable			*/
		@p_prmeffloa_m	UAMT_M,	/* montant du chargement effectif			*/
		@p_uwy_nf    		UUWY_NF,	/* exercice							*/
		@p_ssd_cf		USSD_CF,	/* filiale							*/
      		@p_sbjcptdef_b 	bit,      	/* top assiette definitive				*/
		@p_pmd_m		UAMT_M=NULL output,
		@p_assiette_prime	UAMT_M=NULL output,
		@p_clmact_m		UAMT_M=NULL output  /* sinistralit? pure actuarielle          */
		@p_laycap_m		UAMT_M,	/* montant port?e */
		@p_liacur_cf		UCUR_CF	/* devise engagement */		

Conditions d'execution: 


Commentaires:


_________________
MODIFICATION 01

Auteur:Renu T.
Date:23/05/2014
Version:1.1
Description: MOdification added for TRT 83

*****************************************************/

declare 	@erreur         	int,
		@taux1_r  		ULNGDEC,
		@taux2_r    		ULNGDEC,
		@pos_d			datetime
		


set arithabort numeric_truncation off /* ?viter 'truncation error' */

-- Initialisation date pour les conversions 
SELECT @pos_d = convert(char(4), @p_uwy_nf-1) + "1231" /* date du 31/12/exercice-1 au format AAAAMMJJ */


/*----- R?cup?ration du taux pour la devise de l'aliment --------*/
exec BCTA..PsCURQUO_02 @p_ssd_cf, @p_egpcur_cf, @pos_d, @taux2_r output


/*--------------------------------------
   Calcul du PMD en devise aliment
-------------------------------------*/
IF @p_prvprm_b = 1
	BEGIN

		/*----- Montant PMD 1  en devise de l'aliment ----------------------*/
		exec BCTA..PsCURQUO_02 @p_ssd_cf, @p_prvprmcu1_cf, @pos_d, @taux1_r output		

		IF @taux1_r != NULL
			BEGIN
				select @p_minprvpr1_m = Isnull(@p_minprvpr1_m,0) * ( @taux1_r / @taux2_r)
			END

		/*----- Montant PMD 2  en devise de l'aliment ----------------------*/
		exec BCTA..PsCURQUO_02 @p_ssd_cf, @p_prvprmcu2_cf, @pos_d, @taux1_r output

		IF @taux1_r != NULL
			BEGIN
				select @p_minprvpr2_m = IsNull(@p_minprvpr2_m,0) * ( @taux1_r / @taux2_r)
			END

		/*----- Montant PMD 3  en devise de l'aliment ----------------------*/
		exec BCTA..PsCURQUO_02 @p_ssd_cf, @p_prvprmcu3_cf, @pos_d, @taux1_r output

		IF @taux1_r != NULL
			BEGIN
				select @p_minprvpr3_m = IsNull(@p_minprvpr3_m,0) * ( @taux1_r / @taux2_r)
			END
		--modif 01 start
		/*----- Montant PMD 4  en devise de l'aliment ----------------------*/
		exec BCTA..PsCURQUO_02 @p_ssd_cf, @p_prvprmcu4_cf, @pos_d, @taux1_r output

		IF @taux1_r != NULL
			BEGIN
				select @p_minprvpr4_m = IsNull(@p_minprvpr4_m,0) * ( @taux1_r / @taux2_r)
			END
		/*----- Montant PMD 5  en devise de l'aliment ----------------------*/
		exec BCTA..PsCURQUO_02 @p_ssd_cf, @p_prvprmcu5_cf, @pos_d, @taux1_r output

		IF @taux1_r != NULL
			BEGIN
				select @p_minprvpr5_m = IsNull(@p_minprvpr5_m,0) * ( @taux1_r / @taux2_r)
			END

		-- Prime provisionnelle
		SELECT @p_pmd_m = IsNull(@p_minprvpr1_m, 0) + IsNull(@p_minprvpr2_m, 0) + IsNull(@p_minprvpr3_m, 0) + IsNull(@p_minprvpr4_m, 0) + IsNull(@p_minprvpr5_m, 0)
		
		--modif 01 end
	END
ELSE   
	BEGIN
		SELECT @p_pmd_m = 0
	END


/*-------------------------
-------------------------------------------
  Si devise aliment <> devise engagement
	=>  Convertion des montants en fonction des la devise aliment
--------------------------------------------------------------------*/
IF  (@p_egpcur_cf <> @p_liacur_cf) 
	BEGIN
		/*----- R?cup?ration du taux pour la devise de l'assiette --------*/
		exec BCTA..PsCURQUO_02 @p_ssd_cf, @p_liacur_cf, @pos_d, @taux1_r output

		IF @taux1_r != NULL 
			BEGIN

				select @p_laycap_m = isnull(@p_laycap_m,0) * ( @taux1_r / @taux2_r)

			END
      END


/*-------------------------
-------------------------------------------
  Si devise aliment <> devise assiette 
	=>  Convertion des montants en fonction des la devise aliment
--------------------------------------------------------------------*/
IF  (@p_egpcur_cf <> @p_sbjprmcur_cf) 
	BEGIN
		/*----- R?cup?ration du taux pour la devise de l'assiette --------*/
		exec BCTA..PsCURQUO_02 @p_ssd_cf, @p_sbjprmcur_cf, @pos_d, @taux1_r output

		IF @taux1_r != NULL 
			BEGIN

				select @p_estsbjprm_m = isnull(@p_estsbjprm_m,0) * ( @taux1_r / @taux2_r)
				select @p_defsbjprm_m = IsNull(@p_defsbjprm_m,0) * ( @taux1_r / @taux2_r)
				select @p_sbjprmcpt_m = isnull(@p_sbjprmcpt_m,0) * ( @taux1_r / @taux2_r)
				select @p_prmeffloa_m = IsNull(@p_prmeffloa_m,0) * ( @taux1_r / @taux2_r)
				select @p_clmact_m = IsNull(@p_clmact_m,0) * ( @taux1_r / @taux2_r)
			END
      END


/*-------------------------------------------------------------------------
	D?termination de l'assiette de prime tel que:
	
	si le Top assiette d?finitive = 1 alors
		l'assiette de prime = montant de l'assiette comptable
	sinonsi il existe une assiette d?finitive alors
		l'assiette de prime = montant de l'assiette d?finitive
	sinon
		l'assiette de prime = montant de l'assiette estim?
--------------------------------------------------------------------------*/
IF @p_sbjcptdef_b = 1
BEGIN
		select @p_assiette_prime = @p_sbjprmcpt_m	/* assiette comptable */
END
ELSE
BEGIN
		IF @p_defsbjprm_m <> 0 AND @p_defsbjprm_m != NULL
		BEGIN
				 select @p_assiette_prime = @p_defsbjprm_m	/* assiette d?finitive */
		END
		ELSE
		BEGIN
				 select @p_assiette_prime = @p_estsbjprm_m	/* assiette estim? */
		END
END


/*---------------------
     Select final
-----------------------*/



fin:
set arithabort numeric_truncation on /* remettre 'truncation error' */

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESTPMD1', 'PtPMD1', 'BEST', 'ME01'
go
IF OBJECT_ID('dbo.PtPMD1') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtPMD1 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtPMD1 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtPMD1
 */
GRANT EXECUTE ON dbo.PtPMD1 TO GOMEGA
go
grant execute on dbo.PtPMD1 to GDBBATCH
go
