
USE BEST
Go

/* DROP PROC dbo.PtULT_FC4 */
IF OBJECT_ID('dbo.PtULT_FC4') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_FC4
   PRINT '<<< DROPPED PROC dbo.PtULT_FC4 >>>'
END
go


/* 
*Création de la table temporaire necessaire au calcul des reconstitutions
* -> sert juste à compliler la proc PtULT_FC4, la création effective est faite
* dans le script "ue_begin_b_transaction" de PB.
* La table est détruite après l'insertion de PtULT_FC4 dans la table des proc. 
*/


/*#famrei remplacée par TBEST_FAMREI  (BTEC)  						*/
/* Create table #famrei (									*/
/*							reilin_nt	UINTORD_NT		NULL, */
/*							reirnk_n	tinyint		NULL, */
/*							reiprmbas_r	USHORAT_R		NULL, */
/*							reiprm_m	UAMT_M			NULL, */
/*							reiprm_r	USHORAT_R		NULL  */
/*							)						*/
/*Go													*/



/*
 * creation de la procedure 
*/

create procedure PtULT_FC4
     (
             
             @p_existence_reconst	bit,
             @p_reconst_illimite	bit,
             @p_reconst_gratuite	bit,
             @p_nb_reconst		tinyint,
             @p_assiette_prm		UAMT_M ,
             @p_mt_sinistre_retenu	UAMT_M	,
             @p_mt_prime_retenu		UAMT_M	,
             @p_mt_portee		UAMT_M	,
             @p_part_scor_courante	USHA_R	,
             @p_part_cedee		USHA_R	,
             @p_part_100_cedee		bit,
             @p_contrat			UCTR_NF,
             @p_exercice			UUWY_NF,
             @p_ordre			UUW_NT,
             @p_avenant			UEND_NT,
             @p_section			USEC_NF,
		 @p_usr_cf		     UUPDUSR_CF,
	 	 @p_ssd_cf 		     USSD_CF,
		 @p_prime_reconstitution	UAMT_M	=NULL output
     )
as

/***************************************************

Programme: PtULT_FC4

Fichier script associé : ESTFC4.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

FC4 : Calcul de la prime de Reconstitution.


*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_calcul_prime_reconstitution" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "d_calculPrimeReconstitution" en C sous UNIX.
*******************************************************************************************

	
Parametres:
             
             @p_existence_reconst	bit		: (TFAMLIA) reiexi_b.
             @p_reconst_illimite	bit		: (TFAMLIA) reiunl_b.	
             @p_reconst_gratuite	bit		: (TFAMLIA) reifre_b.
             @p_nb_reconst		tinyint	: (TFAMLIA) reinbr_n.
             @p_assiette_prm		UAMT_M		: (Pt_PMD) comptable, révisé, estimé
             @p_mt_sinistre_retenu	UAMT_M		: (PtULT_RC4).
             @p_mt_prime_retenu		UAMT_M		: (PtULT_RC3).
             @p_mt_portee		UAMT_M		: (TFAMLIA) laycay_m.
             @p_part_scor_courante	USHA_R		: (TFAMLIA) cutsha_r.
             @p_part_cedee		USHA_R		: (TFAMLIA) ridsha_r.
             @p_part_100_cedee		bit		: (TFAMLIA) liaridsha_b.
             @p_contrat			UCTR_NF	: (TCONTR)  ctr_nf.
             @p_exercice			UUWY_NF	: (TCONTR)  uwy_nf.
             @p_ordre			UUW_NT		: (TCONTR)  uw_nt.
             @p_avenant			UEND_NT	: (TCONTR)  end_nt.
             @p_section			USEC_NF	: (TCONTR)  sec_nf.
		 @p_usr_cf		     	UUPDUSR_CF	:  Code utilisateur.
	 	 @p_ssd_cf 		     	USSD_CF	:  Code filiale.
		 @p_prime_reconstitution	UAMT_M	=NULL output
                           

	
CODE RETOUR : Variables output

		

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: L. DEBEVER

Date: 03/09/1997

Version:

Description: Modif suite au remplaçement de #famrei
		 par TBEST_FAMREI (BTEC) 

_________________
MODIFICATION 2

Auteur: M.HA-THUC

Date: 31/03/1998

Version:

Description: 
	- si le montant de la portee = 0 ou la part cedee = 0 ou la part Scor courante = 0
alors on retourne le montant retenu de prime ultime


*****************************************************/

declare		@erreur			int,
			@rowcount			int,
			/*@prime_reconstitution	UAMT_M,*/
			@sinistre_100		UAMT_M,
			@prime_100			UAMT_M,
			@row				int,
			@tranche			int,
			@rang_reconst		int,
			@base_calcul			UAMT_M,
			@clm_tranche			UAMT_M,
			@taux_prm_sur_prm_base	USHORAT_R, /* (TFAMREI) reiprmbas_r */
			@mt_prm_reconst_fixe	UAMT_M,    /* (TFAMREI) reiprm_m */
			@taux_prm_reconst_fixe	USHORAT_R  /* (TFAMREI) reiprm_r */


/*--------------------------				
Destruction TBEST_FAMREI
---------------------------*/

Delete BTEC..TBEST_FAMREI 
	where usr_cf = @p_usr_cf
	 and ssd_cf = @p_ssd_cf


/*--------------------------
Initialisation des variables
---------------------------*/

IF @p_part_100_cedee = 1 
BEGIN
	select @p_part_cedee = 1
END

/*-----------------------------------------------
 Contrôle des données d'entrée de type "diviseur"
------------------------------------------------*/
IF (@p_part_cedee = 0 OR @p_mt_portee = 0 OR @p_part_scor_courante = 0)
BEGIN
	/******************************************/
	/* Modifs du 31/03/1998 - M.HA-THUC	*/
	/* retour de la prime ultime retenue	*/
	/******************************************/
	select @p_prime_reconstitution = @p_mt_prime_retenu
	goto select_final
END


/*--------------------------------------------------------------
 Traitement 
--------------------------------------------------------------*/
set arithabort numeric_truncation off		/* éviter 'truncation error'	*/

select @sinistre_100 = - (@p_mt_sinistre_retenu / @p_part_cedee) / @p_part_scor_courante
select @prime_100    = (@p_mt_prime_retenu / @p_part_cedee) / @p_part_scor_courante


select @p_prime_reconstitution = @p_mt_prime_retenu
select @tranche	=	1


/*--------------------------------------------------
 Reconstitution effectuée si limitée et payante 
-------------------------------------------------*/
IF @p_reconst_illimite = 1 
BEGIN
	goto select_final
END
ELSE
BEGIN
	IF @p_reconst_gratuite = 1
	BEGIN
		goto select_final
	END
END

/*--------------------------------------------
 Contrôle de l'existence de la reconstitution
 Si il n'existe pas on sort
--------------------------------------------*/
IF @p_existence_reconst = 0 
BEGIN
	goto select_final
END

/* ------------------------------------------
 Chargement du tableau de données
 Insert/select de BTRT..TFAMREI -> TBEST..FAMREI
-------------------------------------------*/
/*Insert  	into #famrei */
/* Modif 1 */
Insert into BTEC..TBEST_FAMREI
select 	@p_usr_cf,
		@p_ssd_cf, 
		T.reilin_nt,
		T.reirnk_n,
		IsNull(T.reiprmbas_r,0),
		IsNull(T.reiprm_m,0),
		IsNull(T.reiprm_r,0),
		'',
		'',
		'',
		''
 from BTRT..TFAMREI T
where T.ctr_nf = @p_contrat
  and T.end_nt = @p_avenant
  and T.sec_nf = @p_section
  and T.uwy_nf = @p_exercice
  and T.uw_nt  = @p_ordre
 

select @erreur = @@error, @rowcount = @@rowcount
if @erreur != 0 OR @rowcount = 0 begin goto select_final end 



/*------------------------
 Boucle de calcul 
------------------------*/
select @p_prime_reconstitution = 0


WHILE ( (@sinistre_100 - ( (@tranche - 1) * @p_mt_portee) ) > 0 AND (@tranche <= @p_nb_reconst) )
BEGIN

			select @base_calcul = 0
			select @rang_reconst	=	@tranche
		
			/* ------------------------------------------------------------------------
			 Extraire les montants et taux de BTEC..TBESTFAMREI pour le rang de reconstitution
			--------------------------------------------------------------------------*/
					
			select
				@taux_prm_sur_prm_base 	= reiprmbas_r,
				@mt_prm_reconst_fixe	= reiprm_m,
				@taux_prm_reconst_fixe	= reiprm_r
			/* Modif 1 */
			/*from #famrei */
			from BTEC..TBEST_FAMREI
			where reirnk_n = @rang_reconst
	
			select @erreur = @@error, @rowcount = @@rowcount


			IF @erreur = 0 OR @rowcount != 0 
			BEGIN

				IF	@taux_prm_sur_prm_base > 0
				BEGIN
					select @base_calcul = @prime_100 * @taux_prm_sur_prm_base
				END
				ELSE
				BEGIN
					IF @mt_prm_reconst_fixe > 0
					BEGIN
						select @base_calcul = @mt_prm_reconst_fixe
					END
					ELSE
					BEGIN
						IF @taux_prm_reconst_fixe > 0
						BEGIN
						 	select @base_calcul = @p_assiette_prm * @taux_prm_reconst_fixe
						END
					END
				END

				select @clm_tranche = @sinistre_100 - ( (@tranche -1) * @p_mt_portee)

				/* Correspond à la fonction  "Min(@p_mt_portee, @clm_tranche)" */
				IF @p_mt_portee < @clm_tranche
				BEGIN
					select @clm_tranche = @p_mt_portee
				END 


				select @p_prime_reconstitution = @p_prime_reconstitution + ( (@base_calcul * @clm_tranche) / @p_mt_portee)

			END
			
			select @tranche = @tranche + 1
END


select @p_prime_reconstitution = (@p_prime_reconstitution * @p_part_cedee * @p_part_scor_courante)
select @p_prime_reconstitution = (@p_prime_reconstitution + @p_mt_prime_retenu)



/*----------------
 Select de retour 
-----------------*/
select_final:
/*select @prime_reconstitution*/


/*Drop table #famrei*/

/*--------------------------				
Destruction TBEST_FAMREI
---------------------------*/

Delete BTEC..TBEST_FAMREI 
	where usr_cf = @p_usr_cf
	 and ssd_cf = @p_ssd_cf


set arithabort numeric_truncation on	/* remettre 'truncation error'	*/

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESTFC4', 'PtULT_FC4', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_FC4') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_FC4 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_FC4 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_FC4
 */
GRANT EXECUTE ON dbo.PtULT_FC4 TO GOMEGA
go


/* Destruction table temporaire/reconstitutions */

/* Modif 1 */
/* Drop table #famrei */

/* Go */
