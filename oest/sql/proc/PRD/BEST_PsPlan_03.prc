USE BEST
go
IF OBJECT_ID('dbo.PsPlan_03') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsPlan_03
    IF OBJECT_ID('dbo.PsPlan_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsPlan_03 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsPlan_03 >>>'
END
go
/*
 * creation de la procedure */
create procedure PsPlan_03  (
    @p_DBCLO_D        char(8)
)
/* 
 BEST..PsPlan_03       @p_DBCLO_D    = '20210728'  
   
*/
with execute as caller as
/***************************************************
Programme: PsPlan_03
Fichier script associé : BEST_PsPlan_03.prc
Domaine : (ES)Estimation
Base principale: BEST
Version: 1
Auteur: M. NAJI refonte de PsPlan_02 pour IFR17

Date de creation: 29/06/2018
Description du programme: generation des fichiers PLAN
      Sélection d'enregistrement dans TI17REQJOBPLAN
Parametres:
      @p_CRE_D      UUPD_D
Conditions d'execution:
Commentaires:
[001] 02/12/2020 M.NAJI  :Spira:92023  Planification avec T17REQJOBPLAN
[002] 30/11/2021  M.NAJI  :Spira:99667  isnull(NORME_CF,"") dans le where 
[003] 06/12/2021 M.NAJI  : spira 100737 fix planification local 
*/ 

-- Recherche des dates dans BREF..TCALEND
-----------------------------------------------------------------------------------------

declare @site_cf        varchar(10),
        @erreur             int,
		@suser_Name     varchar(20)
		
select  @suser_Name = suser_Name()

Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output
 


select NORME0_CF = case when NORME_CF  = NULL THEN  REQCOD_CT else NORME_CF   end,
* 
into #TI17REQJOBPLAN0
from BEST..TI17REQJOBPLAN
where  launch_d = NULL 
and  SITE_CF=  @site_cf or SITE_CF = "ALL"


select NORME0_CF ,
        REQCOD_CT,
        max( DBCLO_D)  dbclo_d 
into #TI17REQJOBPLAN1 
from  #TI17REQJOBPLAN0
where launch_d = NULL
and dbclo_d <=  @p_DBCLO_D 
AND SITE_CF = @site_cf
group by 
    NORME0_CF ,
    REQCOD_CT
order by 1,2, 3 desc
 
select NORME0_CF ,
        count(*) REQCOD_COUNT
into #TI17REQJOBPLAN2 
from #TI17REQJOBPLAN1 
group by NORME0_CF
having count(*) >= 1

select t0.*
into #TI17REQJOBPLAN3
from #TI17REQJOBPLAN1  t1
JOIN  #TI17REQJOBPLAN2  t2 on t1.NORME0_CF = t2.NORME0_CF
JOIN #TI17REQJOBPLAN0  t0 on  t0.NORME0_CF = t1.NORME0_CF  AND t0.REQCOD_CT = t1.REQCOD_CT and  t0.DBCLO_D=t1.DBCLO_D and t0.SITE_CF =@site_cf

/*
select * from  #TI17REQJOBPLAN1 
select * from  #TI17REQJOBPLAN2 
select * from  #TI17REQJOBPLAN3
select  @@servername ,  @suser_Name , @site_cf  
*/


	select rf.REQCOD_CT,j.CLOTYP_CT, f.CHAIN_CT, rf.IDF_CT,"I4I"  from BEST..TI17REQFNC  rf
	LEFT outer JOIN #TI17REQJOBPLAN3 j on rf.REQCOD_CT = j.REQCOD_CT 
	LEFT outer JOIN  BEST..TI17FNC f on  rf.IDF_CT = f.IDF_CT   
	where rf .REQCOD_CT = 'ALL'
	UNION
	select r.REQCOD_CT, j.CLOTYP_CT , f.CHAIN_CT, rf.IDF_CT,j.NORME_CF 
	from BEST..TI17REQ r
	JOIN #TI17REQJOBPLAN3 j on r.REQCOD_CT = j.REQCOD_CT 
	LEFT outer JOIN  BEST..TI17REQFNC rf on ( r.REQCOD_CT like rf.REQCOD_CT  )  
	LEFT outer JOIN  BEST..TI17FNC f on ( rf.IDF_CT = f.IDF_CT  )  
    --	LEFT outer JOIN  BEST..TI17REQCHN rc on ( r.REQCOD_CT = rc.REQCOD_CT or rc.REQCOD_CT = 'ALL' )  where CHAIN_CT != null  order by 1 
    order by rf.IDF_CT

if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end

return 0
go
EXEC sp_procxmode 'dbo.PsPlan_03', 'unchained'
go
IF OBJECT_ID('dbo.PsPlan_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsPlan_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsPlan_03 >>>'
go
GRANT EXECUTE ON dbo.PsPlan_03 TO GDBBATCH
go
