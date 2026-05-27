USE BEST
GO
/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
/*
 * DROP PROC PsREQJOB_05
 */
IF OBJECT_ID('PsREQJOB_05') IS NOT NULL
BEGIN
    DROP PROC PsREQJOB_05
    PRINT '<<< DROPPED PROC PsREQJOB_05 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsREQJOB_05
( 
  @SSDs 	varchar(100),
  @segtyp_ct   char(1),
  @cre_d  char(8)
)
with execute as caller as

/***************************************************
Programme: PsREQJOB_05
Fichier script associé : ESSREQ05.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME69 avec Infotool version 2.0 (AUTO)
Date de creation: 
Description du programme: 
      - Sélection des filiales ayant demandé l'inventaire
Parametres: 
		 @SSDs 	varchar(100)  
		 @segtyp_ct 	char(1)     
     @cre_d  char(8)
Conditions d'execution: 
Commentaires:
_________________
MODIFICATION 1
Auteur: M.HA-THUC
Date: 06/08/1998
Version:
Description:	la liste des filiales à comptabiliser n'est plus issue 
	du paramètre @SSDs. On la détermine directement à partir de BEST..TVERPAR

_________________
MODIFICATION 2
Auteur: M. DJELLOULI
Date: 31/08/2004
Version:
Description:	Prendre la VRS_NF dans TREQJOB, ne pas la chercher de nouveau (faux)
_________________
Modification - Removed dbo and added ‘with execute as caller as’
[100] 30/09/2013 P. Pezout :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 16/02/2018 R. Cassis :spira:64014 Pour fiabiliser l'extraction de la treqjob, on se base sur le dbclo et le cre_d qui sont à ce moment-là la date de comptabilisation tech trimestrielle
*****************************************************/

declare @erreur      int

select @erreur = 0

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

if @erreur != 0
	begin
   		raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
	end

/* Truncate de la table de travail */
/***********************************/

truncate table BTRAV..TESTSSDTMP

-- DEBUT MOD02

-- /* Insertion des lignes dans BTRAV..TESTSSDTMP */
-- /***********************************************/
-- 
-- select SSD_CF, SEGTYP_CT, VRS_NF
-- into   #SSDTMP
-- from	BEST..TVERPAR
-- where 	SEGTYP_CT = @segtyp_ct
-- group by SSD_CF
-- having	PAR_D = max( PAR_D )

-- insert into BTRAV..TESTSSDTMP
-- select distinct s.SSD_CF, s.SEGTYP_CT, s.VRS_NF
-- from 	#SSDTMP s, BEST..TREQJOB r
-- where 	s.SSD_CF = r.SSD_CF 
-- and	r.reqcod_ct in ('I', 'J') and r.launch_d = null 

--[101]
insert into BTRAV..TESTSSDTMP
select distinct SSD_CF, @segtyp_ct, VRS_NF
from  BEST..TREQJOB
where reqcod_ct in ('I', 'J') 
and   DBCLO_D = (select max(dbclo_d) from best..treqjob b
                 where b.dbclo_d <= @cre_d   ---launch_d = null 
                 and   b.reqcod_ct in ('I', 'J'))
and   SITE_CF = @site_cf

-- FIN MOD02

select @erreur = @@error

if @erreur != 0  goto fin

return 0

fin:
return 1

go


IF OBJECT_ID('PsREQJOB_05') IS NOT NULL
    PRINT '<<< CREATED PROC PsREQJOB_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsREQJOB_05 >>>'
go
/*
 * Granting/Revoking Permissions on PsREQJOB_05
 */
GRANT EXECUTE ON PsREQJOB_05 TO GOMEGA
go
GRANT EXECUTE ON PsREQJOB_05 TO GDBBATCH
go

