use BEST
go


USE BEST
Go

/* DROP PROC dbo.PtULT_RT0 */
IF OBJECT_ID('dbo.PtULT_RT0') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_RT0
   PRINT '<<< DROPPED PROC dbo.PtULT_RT0 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_RT0
     (
       @p_ctrnat_ct           char(1),
       @p_flaprm_b            bit,
       @p_lob_cf              ULOB_CF,
       @p_sob_cf              USOB_CF,
       @p_pcprsktry_cf        UCTY_CF,
       @p_accadmtyp_ct        UACCADMTYP_CT,
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PtULT_RT0

Fichier script associé : ESTRT0.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

  RT0 : Extraction du paramètrage des automatismes :
      	  Pour anticiper toute évolution des régles de gestion définissant la période de
      	  basculement d'une affaire de "Récent" à "Ancien", l'appel de la procédure lecture
      	  du paramètrage des automatismes est effectué pour toutes les natures d'affaire.

*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_extraction_param_auto" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "d_ExtractionParamAuto" en C sous UNIX.
*******************************************************************************************

	
Parametres:

		@p_ctrnat_ct           char(1)        : (TAUTPAR)		nature_affaire. 
                                           			      		'P'=>Proportionnel.
                                           			      		'N'=>Non/prop.
                                           			      		'F'=>Facultative.
		@p_flaprm_b            bit            : (TFAMCOTP)	prime_forfaitaire.
		@p_lob_cf              ULOB_CF        : (TSECTION)	lob.
		@p_sob_cf              USOB_CF        : (TSECTION)	sob.
		@p_pcprsktry_cf        UCTY_CF        : (TSECTION)	territorialite.
		@p_accadmtyp_ct        UACCADMTYP_CT  : (TSECTION)	type_comptable.
		@p_ssd_cf              USSD_CF        : (TSECTION)	filiale.
				
		     
	
Code retour: 
				 @nb_trimestres    (BEST..TAUTPAR "quanum_nb").
				 @taux_parametrage (BEST..TAUTPAR "limper_r").


Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER (ME01)

Date: 10/07/1997

Version:

Description: Transfert des traitements dans PtULT_RT0b

*****************************************************/

declare	@erreur           int,
		@rowcount         int,
	  	@nb_trimestres    tinyint,
		@taux_parametrage USHORAT_R


execute @erreur = BEST..PtULT_RT0b    
       @p_ctrnat_ct,
       @p_flaprm_b,
       @p_lob_cf,
       @p_sob_cf,
       @p_pcprsktry_cf,
       @p_accadmtyp_ct,
       @p_ssd_cf,
	 @taux_parametrage   output, 
	 @nb_trimestres     output

 				
	 if @erreur != 0 begin goto fin end

	
/*----------------
 Select de retour 
-----------------*/
select_final:
select @taux_parametrage, @nb_trimestres


fin:


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESTRT0', 'PtULT_RT0', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_RT0') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_RT0 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_RT0 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_RT0
 */
GRANT EXECUTE ON dbo.PtULT_RT0 TO GOMEGA
go

