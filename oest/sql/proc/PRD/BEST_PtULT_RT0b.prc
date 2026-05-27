USE BEST
Go

/* DROP PROC dbo.PtULT_RT0b */
IF OBJECT_ID('dbo.PtULT_RT0b') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_RT0b
   PRINT '<<< DROPPED PROC dbo.PtULT_RT0b >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_RT0b
     (
       @p_ctrnat_ct           char(1),
       @p_flaprm_b            bit,
       @p_lob_cf              ULOB_CF,
       @p_sob_cf              USOB_CF,
       @p_pcprsktry_cf        UCTY_CF,
       @p_accadmtyp_ct        UACCADMTYP_CT,
       @p_ssd_cf              USSD_CF,
	 @p_taux_parametrage	USHORAT_R=NULL output, 
	@p_nb_trimestres   	tinyint=NULL output	     )
as

/***************************************************

Programme: PtULT_RT0b

Fichier script associé : ESTRT0b.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 (L.DEBEVER)

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
	 	@p_taux_parametrage	USHORAT_R=NULL output, 
		 @p_nb_trimestres   	tinyint=NULL output				
		     
	
Code retour: 
			variables  output


Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER (ME01)

Date: 15/0/1998

Version:

Description: Mode de gestion pour type comptable 4 et 5

*****************************************************/

declare	@erreur           int,
		@rowcount         int

/*===============================================================================
 Traitement 
================================================================================*/

	/* --------------------------------------------------------------------------
      Affaire Non/proportionnelle avec saisie d'assiette comptable 
	   (affaire non tarifé forfaitairement) 
   ----------------------------------------------------------------------------*/
	IF @p_ctrnat_ct = "N" AND @p_flaprm_b = 0 
   	BEGIN
		select @erreur		= 0
		select @p_nb_trimestres	= 0
		select @p_taux_parametrage	= 0
		goto select_final
	END 

	/* --------------------------------------------------------------------------
      Affaire proportionnelle de type comptable 1, 3 (seul le nbre de
	   trimestre forcé à 4 est utilisé pour déterminer l'age du contrat)
  	 ----------------------------------------------------------------------------*/
	/* Modif 1 : rajout Type comptable 4 ou 5 */
	IF @p_ctrnat_ct = "P" AND (@p_accadmtyp_ct = 1 OR @p_accadmtyp_ct = 3 ) 
   	BEGIN
		select @erreur		= 0
		select @p_nb_trimestres	= 4
		select @p_taux_parametrage	= 0
		goto select_final
	END


	/*--------------------------------------------------------------------------
	   Autres affaires 
	   (lecture du taux de paramètrage et du nombre de trimestres) 
   	----------------------------------------------------------------------------*/
	
	/*-------------------------------------------------------------------------------
	 Select avec comme condition :
 	"nature de l'affaire", "lob", "territorialite", "sob"
	--------------------------------------------------------------------------------*/
      select @p_taux_parametrage = isnull(limper_r,0), 
             @p_nb_trimestres    = isnull(quanum_nb,0)
	  from TAUTPAR 
       where ssd_cf	= @p_ssd_cf       and
          	( ctrnat_ct	= @p_ctrnat_ct    and
            	lob_cf		= @p_lob_cf       and
            	pcprsktry_cf	= @p_pcprsktry_cf and
            	sob_cf		= @p_sob_cf
             ) 

	select @rowcount = @@rowcount, @erreur = @@error
	if @rowcount != 0 and @erreur = 0 begin goto select_final end



	/*-------------------------------------------------------------------------------
	 Si aucune valeur trouvé dans le précédent select, on recherche plus large
	 Select avec comme condition :
	 "nature de l'affaire", "lob", "territorialite", (sob_cf : NULL ou "")
	--------------------------------------------------------------------------------*/
	select	 @p_taux_parametrage = isnull(limper_r,0), 
          	 @p_nb_trimestres    = isnull(quanum_nb,0)
 	  from TAUTPAR 
	 where ssd_cf		= @p_ssd_cf          and
          	( ctrnat_ct		= @p_ctrnat_ct       and
           	  lob_cf		= @p_lob_cf          and 
           	  pcprsktry_cf	= @p_pcprsktry_cf    and
           	  (sob_cf		= NULL OR sob_cf = "")
          	)
 
	select @rowcount = @@rowcount, @erreur = @@error
	if @rowcount != 0 and @erreur = 0 begin goto select_final end


	/*-------------------------------------------------------------------------------
	 Si aucune valeur trouvé dans le précédent select, on recherche plus large
	 Select avec comme condition :
	 "nature de l'affaire", "lob", (territorialite et sob_cf : NULL ou "")
	--------------------------------------------------------------------------------*/ 
	select @p_taux_parametrage = isnull(limper_r,0), 
		 @p_nb_trimestres    = isnull(quanum_nb,0)
	  from TAUTPAR 
	 where ssd_cf		= @p_ssd_cf                  and
		( ctrnat_ct		= @p_ctrnat_ct               and
		  lob_cf		= @p_lob_cf                  and
           	  (pcprsktry_cf	= NULL OR pcprsktry_cf = "") and
           	  (sob_cf 		= NULL OR sob_cf = "")
          	)

	select @rowcount = @@rowcount, @erreur = @@error
	if @rowcount != 0 and @erreur = 0 begin goto select_final end

	/*-------------------------------------------------------------------------------
	 Si aucune valeur trouvé dans le précédent select, on recherche plus large
	 Select avec comme condition :
	 "nature de l'affaire",(lob ,territorialite et sob_cf : NULL ou "")
	--------------------------------------------------------------------------------*/  
	select @p_taux_parametrage = isnull(limper_r,0), 
		 @p_nb_trimestres    = isnull(quanum_nb,0)
        from TAUTPAR 
       where ssd_cf		= @p_ssd_cf                  and
		( ctrnat_ct		= @p_ctrnat_ct               and
		  (lob_cf		= NULL OR lob_cf ="")        and
		  (pcprsktry_cf	= NULL OR pcprsktry_cf = "") and
		  (sob_cf		= NULL OR sob_cf = "")
             )

	select @rowcount = @@rowcount, @erreur = @@error
	if @rowcount != 0 and @erreur = 0 begin goto select_final end



	/*-------------------------------------------------------------------------------
 	Si aucune valeur trouvé dans les précédent select, on force au valeur suivante :
 	Taux de paramètrage = 95 %
 	Nombre de trimestres = 8
	--------------------------------------------------------------------------------*/ 
	select @erreur           = 0
	select @p_taux_parametrage = 0.95 
	select @p_nb_trimestres    = 8

	
/*----------------
 Select de retour 
-----------------*/
select_final:


return @erreur
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESTRT0b', 'PtULT_RT0b', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PtULT_RT0b') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_RT0b >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_RT0b >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_RT0b
 */
GRANT EXECUTE ON dbo.PtULT_RT0b TO GOMEGA
go

