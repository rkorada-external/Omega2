use BEST
go
/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
 /* DROP PROC PsSECTION_16
*/
IF OBJECT_ID('PsSECTION_16') IS NOT NULL
   BEGIN
   DROP PROC PsSECTION_16
   PRINT '<<< DROPPED PROC PsSECTION_16 >>>'
END
GO

/*
 * creation de la procedure 
*/

create procedure PsSECTION_16
(
@p_PRS_CF     smallint,  -- PRS_CF = 710 pour IFRS et 730 pour EBS
@p_ICLODAT_D  char(8)    -- date trimestre en cours pour EBS
)
with execute as caller as

/***************************************************
Programme: PsSECTION_16
Fichier script associé : ESSSEC16.PRC
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation: 
Description du programme: 
  Descente de la table TCTREST en inventaire

Parametres: 
Conditions d'execution: 
Commentaires:
_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description: : Removed dbo and added ‘with execute as caller as’

[002] 12/08/2013 -=Dch=-   :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
[003] 10/04/2018 65703 Ajout de la colonne CMT_NT
[004] 02/04/2019 R. Cassis :spira:65656 Ajout parametre PRS_CF pour filtrer sur postes IFRS ou EBS et generation mouvements EBS si non existants pour le trimestre
[005] 18/02/2020 R. Cassis :spira:84424 Ajout colonne INCURREDCI_M a la table BEST..TCTREST
[006] 12/06/2020 R. Cassis :spira:86536 Pour toute extraction maintenant, on n'extrait que les données du trimestre en cours - elagage du code
*****************************************************/

declare @erreur int

--[006]
SELECT CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, 
       CONVERT(char(8), CRE_D, 112) + " " + CONVERT(varchar(10), CRE_D, 108), 
       PRS_CF, ACMTRS_NT, SSD_CF, DIV_NT, CUR_CF, CALAMT_M, ENTAMT_M, RETAMT_M, 
       ADMMOD_CT, CONVERT(char(8), CLODAT_D, 112), ORICOD_LS, UPDUSR_CF, CREUSR_CF, 
       CONVERT(char(8), LSTUPD_D, 112) + " " + CONVERT(varchar(10), LSTUPD_D, 108), LSTUPDUSR_CF, CMT_NT, INCURREDCI_M
FROM   BEST..TCTREST 
where  SSD_CF in ( select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF = user_name() )
and    PRS_CF = @p_PRS_CF   --[004]
and    CLODAT_D = @p_ICLODAT_D

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


IF OBJECT_ID('PsSECTION_16') IS NOT NULL
   PRINT '<<< CREATED PROC PsSECTION_16 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC PsSECTION_16 >>>'
go
/*
 * Granting/Revoking Permissions on PsSECTION_16
 */
GRANT EXECUTE ON PsSECTION_16 TO PUBLIC
GO
GRANT EXECUTE ON PsSECTION_16 TO GDBBATCH
go

