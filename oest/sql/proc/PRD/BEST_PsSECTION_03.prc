use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */

 /* DROP PROC dbo.PsSECTION_03
*/
IF OBJECT_ID('dbo.PsSECTION_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSECTION_03
   PRINT '<<< DROPPED PROC dbo.PsSECTION_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_03
     (
       @p_segtyp_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_seg_d               char(8)
     )
as

/***************************************************

Programme: PsSECTION_03

Fichier script associé : ESSSEC03.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Création du fichier périmètre SFFPERIFR

Parametres: 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: Y.Bourdaillet 

Date: 16/12/98

Version:

Description: rajout du bit de prorata temporis dans le périmètre
		(REIPROTMP_B de la table BTRT..TFAMREI)

--*******************************************************

[002] 12/08/2013 -=Dch=-   :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
[003] 05/02/2018 MZM : spira 42213 Arret des estimations pour Traites invalides CTRLCK_B = 1 et Fac Dont Avenant invalides CTRLCK_B =0  
[004] 29/09/2020 MZM : spira 89714 INI - Variable Premiums : Ajout REIPRMPTP_R : Info de gratuite pour le calcul des Reinstatements Premiums


*****************************************************/


declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr


declare @erreur int

-----------------------
-- Filtre sur les dates
-----------------------

declare @date_maxTRT datetime, @date_maxFAC datetime

EXEC BEST..PsSECTION_32 @date_maxTRT output, @date_maxFAC output, @p_seg_d


-------------------------------------------------------
-- Périmètre de souscription pour les traités SFFPERIFR
-------------------------------------------------------

-- Cas multifiliale

if @p_ssd_cf = 00
BEGIN
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, REILIN_NT, REIPRM_M, REIPRM_R, REIPRMBAS_R, REIRNK_N, @p_segtyp_ct, SECTION.SSD_CF, REIPROTMP_B, REIPRMPTP_R
FROM	 BTRT..TSECTION SECTION, 
	 BTRT..TCONTR CONTR, 
       BTRT..TFAMREI FAMREI
WHERE	 SECSTS_CT IN(14, 15, 16, 17, 18, 19)
     	 and CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
		 and CTRLCK_B <> 1 /* [003] */ 
      	 and SECINC_D<=@date_maxTRT
       and LOB_CF<>'30' and LOB_CF<>'31'
       and SECTION.CTR_NF=FAMREI.CTR_NF and SECTION.END_NT=FAMREI.END_NT and SECTION.SEC_NF=FAMREI.SEC_NF and SECTION.UWY_NF=FAMREI.UWY_NF and SECTION.UW_NT=FAMREI.UW_NT
	 and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
	 and SECTION.SSD_CF in ( select SSD_CF from #ssds )
END


-- Cas monofiliale

ELSE
BEGIN
SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, REILIN_NT, REIPRM_M, REIPRM_R, REIPRMBAS_R, REIRNK_N, @p_segtyp_ct, SECTION.SSD_CF, REIPROTMP_B, REIPRMPTP_R
FROM	 BTRT..TSECTION SECTION, 
	 BTRT..TCONTR CONTR, 
       BTRT..TFAMREI FAMREI
WHERE	 SECSTS_CT IN(14, 15, 16, 17, 18, 19)
     	 and CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
		 and CTRLCK_B <> 1 /* [003] */		 
      	 and SECINC_D<=@date_maxTRT
       and LOB_CF<>'30' and LOB_CF<>'31'
       and SECTION.SSD_CF=@p_ssd_cf
       and SECTION.CTR_NF=FAMREI.CTR_NF and SECTION.END_NT=FAMREI.END_NT and SECTION.SEC_NF=FAMREI.SEC_NF and SECTION.UWY_NF=FAMREI.UWY_NF and SECTION.UW_NT=FAMREI.UW_NT
	 and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
END



   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

IF OBJECT_ID('dbo.PsSECTION_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSECTION_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_03
 */
GRANT EXECUTE ON dbo.PsSECTION_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSECTION_03 TO GDBBATCH
go

