use BEST
go
IF OBJECT_ID('dbo.PsSEGEST_01') IS NOT NULL
BEGIN
  DROP PROC dbo.PsSEGEST_01
  PRINT '<<< DROPPED PROC dbo.PsSEGEST_01 >>>'
END
go
create procedure PsSEGEST_01
with execute as caller as
/***************************************************
Programme: PsSEGEST_01
Fichier script associé : ESSSEG04.PRC
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: ME69
Date de creation: 
Description du programme: 
	Descente de la table BEST..TSEGEST pour la version active de chaque
filiale en fichier binaire.
Parametres: 
Conditions d'execution: 
Commentaires:
_________________
MODIFICATIONS
1 R. Cassis 04/09/2012  :spot:24041 - Refonte de la requete pour prendre tous les segtyp necessaires à Solvency
2 -=Dch=-   07/08/2013  :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
5 Florent   04/06/2015 :spot:28694 Segmentation VIE, ici sélection uniquement des dommages !
*****************************************************/
declare @erreur int
select @erreur = 0

declare @curr_usr UUPDUSR_CF 
select @curr_usr = suser_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr

/**************************************/
/* Descente de la table BEST..TSEGEST */
/**************************************/
SELECT   t1.*
INTO #tversion
FROM  BEST..TVERSION t1 inner join #ssds S1 on t1.SSD_CF = S1.SSD_CF 
WHERE VRSSTS_CT = "CO"
AND   VRSACC_D <> NULL
AND   VRSACC_D = (select max(VRSACC_D) FROM BEST..TVERSION t2 inner join #ssds S2 on t2.SSD_CF = S2.SSD_CF
                  where t1.SSD_CF    = t2.SSD_CF 
                  and   t1.SEGTYP_CT = t2.SEGTYP_CT )

select A.VRS_NF, A.SSD_CF, A.SEGTYP_CT, A.SEG_NF, A.UWY_NF, convert(char(8), A.CRE_D, 112), 
       A.CUR_CF, A.PRMAMT_M, A.CLMAMT_M, A.LOSRAT_R, A.AMORAT_CT
from   BEST..TSEGEST A, BTRAV..TESTSSDVRS B
where exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=A.SSD_CF)
and    A.SSD_CF = B.SSD_CF
and    A.VRS_NF = B.VRS_NF
and    A.SEGTYP_CT in ('A','E','S') --= B.SEGTYP_CT
and    A.CRE_D = ( select max( C.CRE_D ) 
                   from BEST..TSEGEST C
                   where A.VRS_NF    = C.VRS_NF
                   and   A.SSD_CF    = C.SSD_CF
                   and   A.SEGTYP_CT = C.SEGTYP_CT
                   and   A.SEG_NF    = C.SEG_NF
                   and   A.UWY_NF    = C.UWY_NF
                   and   A.ACY_NF    = C.ACY_NF )
UNION
select A.VRS_NF, A.SSD_CF, A.SEGTYP_CT, A.SEG_NF, A.UWY_NF, convert(char(8), A.CRE_D, 112), 
       A.CUR_CF, A.PRMAMT_M, A.CLMAMT_M, A.LOSRAT_R, A.AMORAT_CT
from   BEST..TSEGEST A, #tversion B
where  A.SSD_CF = B.SSD_CF
and exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=A.SSD_CF)
and    A.VRS_NF = B.VRS_NF
and    A.SEGTYP_CT in ('T','U') --= B.SEGTYP_CT
and    A.CRE_D = ( select max( C.CRE_D ) 
                   from  BEST..TSEGEST C
                   where A.VRS_NF    = C.VRS_NF
                   and   A.SSD_CF    = C.SSD_CF
                   and   A.SEGTYP_CT = C.SEGTYP_CT
                   and   A.SEG_NF    = C.SEG_NF
                   and   A.UWY_NF    = C.UWY_NF
                   and   A.ACY_NF    = C.ACY_NF )
order by A.VRS_NF, A.SSD_CF, A.SEGTYP_CT, A.SEG_NF, A.UWY_NF

select @erreur = @@error

if @erreur != 0
begin
   return @erreur
end

return 0
go
IF OBJECT_ID('dbo.PsSEGEST_01') IS NOT NULL
  PRINT '<<< CREATED PROC dbo.PsSEGEST_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC dbo.PsSEGEST_01 >>>'
go
GRANT EXECUTE ON dbo.PsSEGEST_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSEGEST_01 TO GDBBATCH
go
