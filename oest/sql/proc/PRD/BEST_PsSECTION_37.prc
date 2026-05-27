/*
 * DROP PROC dbo.PsSECTION_37
 */
USE BEST
GO
IF OBJECT_ID('dbo.PsSECTION_37') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSECTION_37
    PRINT '<<< DROPPED PROC dbo.PsSECTION_37 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_37
as

/***************************************************

Programme: PsSECTION_37

Fichier script associé : ESSSEC37.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Mise a jour de la table TSECTION de la base BTRT et BFAC a partir de la table ESTSECTION (BTRAV)
	  Comme on enleve les triggers pour la base traite avant la proc il faut mettre a jour TSECTION_V.
Parametres: 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int , 
        @tran_imbr	bit
		
select @erreur = 0
select @tran_imbr = 1		

/* -----------------------------------------------------------
	Début de la transaction
   ----------------------------------------------------------- */

if @@trancount = 0
  begin
   select @tran_imbr = 0
  BEGIN TRAN
  end


/*************************************************************/
/***************MISE A JOUR DE BTRT..TSECTION*****************/
/* ATTENTION LES TRIGGERS ONT ETE DROPPES AVANT LE LANCEMENT */
/* DE LA PROC. LA MAJ D AUTRES JOURS CHAMPS DE BTRT..TSECTION*/
/* DOIT ETRE REALISEE EN COHERENCE AVEC L ACTION DES TRIGGERS*/
/*************************************************************/
/*************************************************************/

-- Mise a jour de BTRT..TSECTION

UPDATE BTRT..TSECTION
SET    ESTUPDTYP_CT=TRAV.ESTUPDTYP_CT,
       ESTCRB_CT=TRAV.ESTCRB_CT
FROM   BTRT..TSECTION SECTION, BTRAV..ESTSECTION TRAV
WHERE   SECTION.CTR_NF=TRAV.CTR_NF
	and SECTION.END_NT=TRAV.END_NT 
	and SECTION.SEC_NF=TRAV.SEC_NF
	and SECTION.UWY_NF=TRAV.UWY_NF
	and SECTION.UW_NT=TRAV.UW_NT 
	
select @erreur = @@error

if @erreur != 0  goto fin 
	
-- Mise a jour de BTRT..TSECTION_V

UPDATE BTRT..TSECTION_V
SET    ESTUPDTYP_CT=TRAV.ESTUPDTYP_CT,
       ESTCRB_CT=TRAV.ESTCRB_CT
FROM   BTRT..TSECTION_V SECTION, BTRAV..ESTSECTION TRAV
WHERE   SECTION.CTR_NF=TRAV.CTR_NF
	and SECTION.UWY_NF=TRAV.UWY_NF
	and SECTION.UW_NT=TRAV.UW_NT 
	and SECTION.SEC_NF=TRAV.SEC_NF
	and SECTION.END_NT=( select max( END_NT )
						from	BTRT..TSECTION_V 
						where	CTR_NF=TRAV.CTR_NF
						and 	UWY_NF=TRAV.UWY_NF
						and 	UW_NT=TRAV.UW_NT 
						and 	SEC_NF=TRAV.SEC_NF )
	
select @erreur = @@error

if @erreur != 0  goto fin 

-- Mise a jour de BFAC..TSECTION

UPDATE BFAC..TSECTION
SET    ESTUPDTYP_CT=TRAV.ESTUPDTYP_CT
FROM   BFAC..TSECTION SECTION, BTRAV..ESTSECTION TRAV
WHERE   SECTION.CTR_NF=TRAV.CTR_NF
	and SECTION.END_NT=TRAV.END_NT
	and SECTION.SEC_NF=TRAV.SEC_NF
	and SECTION.UWY_NF=TRAV.UWY_NF
	and SECTION.UW_NT=TRAV.UW_NT 

select @erreur = @@error

if @erreur != 0  goto fin 

/****** fin de la transaction*****/
if @tran_imbr = 0
	COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
	ROLLBACK TRAN

return @erreur
go	

IF OBJECT_ID('dbo.PsSECTION_37') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsSECTION_37 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_37 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_37
 */
GRANT EXECUTE ON dbo.PsSECTION_37 TO GOMEGA
go

