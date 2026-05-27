use BEST
go

/*
 * DROP PROC PsTRSLNK_02
 */
IF OBJECT_ID('PsTRSLNK_02') IS NOT NULL
BEGIN
    DROP PROC PsTRSLNK_02
    PRINT '<<< DROPPED PROC PsTRSLNK_02 >>>'
END
go

/*
 * creation de la procedure */
create procedure PsTRSLNK_02 

as

/***************************************************

Programme: PsTRSLNK_02

Fichier script associé : BEST_PsTRSLNK_02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME69 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TTRSLNK

Parametres: 
       

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: M.HA-THUC

Date: 28/05/98

Version:

Description: rajout d'un code à 713 et 714

_________________
MODIFICATION 2

Auteur: M.HA-THUC

Date: 12/10/98

Version:

Description: rajout d'un code à 717
_________________
MODIFICATION 3

Auteur: S. LLORENTE
Date: 12/12/2000

Version:

Description: rajout d'un code à 750
_________________
MODIFICATION    [004]
Auteur:         D.GATIBELZA
Date:           13/02/2009
Version:        9.1
Description:    ESTDOM16593 Comptabilisation IFRS dans les chaines Inventaire
                rajout des codes 610 et 611
_________________
MODIFICATION    [005]
  JF VDV       26/06/2012 [23390] - SOLVENCY II - ajout code 730
[006] 27/12/2013 R. Cassis :spot:25427 Centralization ajout grant
[007] -=Dch=-  14/09/2015 :spot:29162 Impact Retro P&c
[008] -=MZM=-  22/07/2021 :spira 95950 AE I17 INI et STD  : Ajout Poste 740
[009] -=NLD=-  02/09/2021 :spira 91998 O2/SAP interface management - EBS common transaction in dedicated file : Ajout Poste 640
[010] -=MZM=-  29/10/2021 :spira 87852 Retro TAX MANAGEMENT  : Ajout Poste 51
[011] -=JBD=-  08/29/2022 :spira 105393 add 900 as PRS
*****************************************************/


select PRS_CF, ACMTRS_NT,DETTRS_CF
from	BREF..TTRSLNK
where	PRS_CF in (	50,  51, 500, 600 , 610 , 611, 640, 710 , 711 , 712 , 713 , 714 , 717 , 730 , 740, 750, 751, 755, 900)

order 	by DETTRS_CF asc


/*
 * fin de la procedure  */

go
IF OBJECT_ID('PsTRSLNK_02') IS NOT NULL
    PRINT '<<< CREATED PROC PsTRSLNK_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsTRSLNK_02 >>>'
go
/*
 * Granting/Revoking Permissions on PsTRSLNK_02 */
GRANT EXECUTE ON PsTRSLNK_02 TO GOMEGA,GDBBATCH
go


