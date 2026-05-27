/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
/*
 * DROP PROC dbo.PsSUBSID_02
 */
IF OBJECT_ID('dbo.PsSUBSID_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSUBSID_02
    PRINT '<<< DROPPED PROC dbo.PsSUBSID_02 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsSUBSID_02
as

/***************************************************

Programme: PsSUBSID_02

Fichier script associé : ESSSUB02.PRC

Domaine : (ES) Estimation

Base principale : BREF

Version: 1

Auteur: 

Date de creation: 

Description du programme: 

      Sélection d'enregistrements dans TSUBSUD et TLOB

Parametres: 


Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: F. BOULAROT

Date: 11/05/1998

Version:

Description: Il faut rajouté un libellé pour l'alimentation du
fichier permanent FLIBEL1
_________________
MODIFICATION 2

Auteur: KBagwe

Date: 16/04/2013

Version:

Description: Replacing obsolete table TLOBH.

*****************************************************/

declare @erreur int

create table #templiblob(
       SSD_CF        USSD_CF     NULL,
       LOB_CF        ULOB_CF     NULL,
       SSDOMGLAG_CF  ULAG_CF     NULL,
       SSD_LS        UL16        NULL,
       SSDCUR_CF     UCUR_CF     NULL,
       LOB_HS        UL16        NULL)

insert #templiblob
Select A.ssd_cf,
	 B.lob_cf,
       A.ssdomglag_cf,
       A.ssd_ls, 
	 A.ssdcur_cf,
	 B.lob_gs  								--Mod 2
from BREF..TSUBSID A, BREF..TLOBL B			--Mod 2
where A.ssdomglag_cf = B.lag_cf				--Mod 2
and A.SSD_CF in ( select s.SSD_CF from BREF..TBATCHSSD s where s.BATCHUSER_CF = suser_name() )
and  Exists (Select * From Bref..Tlobesb C Where A.Ssd_Cf = C.Ssd_Cf And C.Lob_Cf=B.Lob_Cf ) 			--Mod 2

insert #templiblob
select  ssd_cf,
        '98',
        ssdomglag_cf,
        ssd_ls, 
        ssdcur_cf,
        'Indetermin.'  
from BREF..TSUBSID 
where ssd_cf < 99
and SSD_CF in ( select s.SSD_CF from BREF..TBATCHSSD s where s.BATCHUSER_CF = suser_name() )

select * from #templiblob
order by ssd_cf,lob_cf


return 0
go
IF OBJECT_ID('dbo.PsSUBSID_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsSUBSID_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSUBSID_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSUBSID_02
 */
GRANT EXECUTE ON dbo.PsSUBSID_02 TO GOMEGA
go

