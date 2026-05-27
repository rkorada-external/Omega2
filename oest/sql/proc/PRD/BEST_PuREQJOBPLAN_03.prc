/** Alter Procedure Script **/

use BEST
go


IF OBJECT_ID('dbo.PuREQJOBPLAN_03') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PuREQJOBPLAN_03
  IF OBJECT_ID('dbo.PuREQJOBPLAN_03') IS NOT NULL
  PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuREQJOBPLAN_03 >>>'
  ELSE
  PRINT '<<< DROPPED PROCEDURE dbo.PuREQJOBPLAN_03 >>>'
END
go

/* 
 * creation de la procedure */
create procedure PuREQJOBPLAN_03 (
  @p_CRE_D  char(8),
  @p_IS_CHECK  tinyint = 0
)
with execute as caller as
/***************************************************
Programme: PuREQJOBPLAN_03
Fichier script associé : BEST_PuTI17toTreqJobPlan_01.prc
Domaine : (ES)Estimation
Base principale: BEST  
Version: 1
Auteur: M. NAJI

Date de creation: 29/06/2018
Description du programme: si une demande est créé dans TI17REQJOBPLAN on crée la màªme dans TREQJOBPLAN
 Parametres:
 @p_CRE_D DBCLO_D
Conditions d'execution:
Commentaires: 
[001] 07/10/2020 M.NAJI :Spira 87596 mise à  jour TREQJOBPLAN à  partir de TI17REQJOBPLAN
[002] 06/01/2021 M.NAJI :Spira 87596 Suppression du blanc dans le REQCOD_CT
[003] 04/03/2021 M.NAJI :Spira 91531 pour mixer des demandes "D","T","F","C" et autres come "A" 
[004] 27/04/2021 M.NAJI :Spira 91531 Suppression des job non exécutées
[005] 10/05/2021 M.NAJI :Spira 91531 Suppression de la gestion de l'ancien mode 
[006] 20/10/2021 M.NAJI : Spira 100571 add REQCOD_CT A","L","M","R","V","Y","Z"
execute BEST..PuREQJOBPLAN_03  '20220212' ,1
--select * from  BEST..TREQJOBPLAN where DBCLO_D='20210716'  and SITE_CF = "FRA1"
--select * from  BEST..TREQJOB where DBCLO_D='20210716'  and SITE_CF = "FRA1"
[007] Hugues.R: site in ALL
[008] 04/11/2021 BRIK.M : correct 'M' and 'R' requests
[009] 20/10/2021 M.NAJI : Spira 100571 fix bug
[010] 26/01/2021 M.NAJI : Spira 101811 clean TREQJOB
[011] 16/02/2021 M.NAJI  : Spira 101811 clean TREQJOB
[012] 23/03/2022 M.NAJI  : Spira 96729 ne pas copier les demande SAP dans TRQJOBPLAN 
[013] 13/01/2023 MiS    :Spira 108414 modification Delete
*/

declare @erreur int  
		
    
declare @site_cf        varchar(10) 
declare @suser_Name     varchar(20) 
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output
if @erreur != 0
	begin
   		raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
end

Select *
into #TREQJOBPLAN
FROM   best..ti17reqjobplan
Where  DBCLO_D <= @p_CRE_D -- @dbclo_d
And     LAUNCH_D Is NULL
and     SITE_CF = @site_cf -- @site_cf 
--and  NORME_CF not like 'I17%'
and  NORME_CF in ('I4I','EBSE','I4L' ) 
and  REQCOD_CT not like '%P' 
--- [006]
insert into #TREQJOBPLAN (SSD_CF, BALSHEYEA_NF, BALSHTMTH_NF, CLODAT_D, REQCOD_CT, CRE_D, DBCLO_D, LAUNCH_D, CLOTYP_CT, NORME_CF, CLOPER_LS, VRS_NF, UPDUSR_CF, START_D, END_D, SITE_CF,  CMT_NT)
Select SSD_CF, BALSHEYEA_NF, BALSHTMTH_NF, CLODAT_D, REQCOD_CT, CRE_D, DBCLO_D, LAUNCH_D, CLOTYP_CT, NORME_CF, CLOPER_LS, VRS_NF, UPDUSR_CF, START_D, END_D, SITE_CF,  CMT_NT
FROM   best..ti17reqjobplan
Where  DBCLO_D <= @p_CRE_D -- @dbclo_d
And     LAUNCH_D Is NULL
-- 007
and     SITE_CF in (@site_cf, 'ALL') -- @site_cf 
--and  NORME_CF not like 'I17%'
--- [008] Remove "R" & 'M' from criteria
and  REQCOD_CT in ("A","L","V","Y","Z")
--and  NORME_CF not like 'I17%'


--- [008] select 'R' & 'M' only on today's date
insert into #TREQJOBPLAN (SSD_CF, BALSHEYEA_NF, BALSHTMTH_NF, CLODAT_D, REQCOD_CT, CRE_D, DBCLO_D, LAUNCH_D, CLOTYP_CT, NORME_CF, CLOPER_LS, VRS_NF, UPDUSR_CF, START_D, END_D, SITE_CF,  CMT_NT)
Select SSD_CF, BALSHEYEA_NF, BALSHTMTH_NF, CLODAT_D, REQCOD_CT, CRE_D, DBCLO_D, LAUNCH_D, CLOTYP_CT, NORME_CF, CLOPER_LS, VRS_NF, UPDUSR_CF, START_D, END_D, SITE_CF,  CMT_NT
FROM   best..ti17reqjobplan
Where  DBCLO_D = @p_CRE_D -- @dbclo_d
And     LAUNCH_D Is NULL
and     SITE_CF in (@site_cf, 'ALL') -- @site_cf 
and  REQCOD_CT in ("M","R")

update #TREQJOBPLAN
set UPDUSR_CF ="ESCJ" 
 
------------- INV IFRS4

--REQCOD_CT of TI17REQJOBPLAN in ( I4IMINV, I4IYINV, I4IQINV ) 
update #TREQJOBPLAN
set    REQCOD_CT = 'D' ,
        VRS_NF=0,
        CLOPER_LS = CASE 
                                WHEN SITE_CF='FRA1' THEN '1,2,3,4,5,6,7,12,15,16,17,18,19,23'
                                WHEN SITE_CF='SGP1' THEN '20,22,24'
                                WHEN SITE_CF='USA1' THEN '10,11,13,14,25,26,27'
                            END
where REQCOD_CT in ("I4IMINV","I4IYINV","I4IQINV")

------------- BOOKING INV IFRS4
-- -REQCOD_CT of TI17REQJOBPLAN in (  I4IMINVB, I4IYINVB,I4IQINVB )
update #TREQJOBPLAN 
set    REQCOD_CT = 'C' ,
        VRS_NF=null,
        CLOPER_LS = 'Technical BOOKING'
where REQCOD_CT in ("I4IMINVB","I4IYINVB","I4IQINVB")


------------- BOOKING INV IFRS4
-- INV EBS => ISO POSE
--/!\ attention il faut lister les paramà¨tres du POS EBS, pour que Kouassi puisse arbitre leur utilisation pour le INV EBS
-- -REQCOD_CT of TI17REQJOBPLAN in (  EBSEMINV, EBSEYINV, EBSEQINV)
update #TREQJOBPLAN
set    REQCOD_CT = 'T' ,
        VRS_NF=1,
        CLOPER_LS = 'POST OMEGA SOCIAL EBS'
where REQCOD_CT in ("EBSEMINV","EBSEYINV", "EBSEQINV")


------------- BOOKING INV EBS
-- -REQCOD_CT of TI17REQJOBPLAN in ( EBSEMINVB, EBSEYINVB, EBSEQINVB )
update #TREQJOBPLAN
set    REQCOD_CT = 'F' ,
        VRS_NF=1,
        CLOPER_LS="BOOKING POST OMEGA SOCIAL EBS"
        where REQCOD_CT in ("EBSEMINVB", "EBSEYINVB", "EBSEQINVB")

------------- POS
-- -REQCOD_CT of TI17REQJOBPLAN in ( EBSEYPOS, EBSEQPOS)  ==> POSE
update #TREQJOBPLAN
set    REQCOD_CT = 'T' ,
        VRS_NF=1,
        CLOPER_LS='POST OMEGA SOCIAL EBS'
        where REQCOD_CT in ('EBSEYPOS', 'EBSEQPOS')
-- -REQCOD_CT of TI17REQJOBPLAN in ( I4IYPOS, I4IQPOS)  ==> POSI
update #TREQJOBPLAN
set    REQCOD_CT = 'T' ,
        VRS_NF=0,
        CLOPER_LS='POST OMEGA SOCIAL IFRS'
        where REQCOD_CT in ('I4IYPOS', 'I4IQPOS')


------------- POC
-- -REQCOD_CT of TI17REQJOBPLAN in ( EBSEYPOC, EBSEQPOC ) ==> POCE
update #TREQJOBPLAN
set    REQCOD_CT = 'T' ,
        VRS_NF=1,
        CLOPER_LS='POST OMEGA CONSO EBS'
        where REQCOD_CT in ('EBSEYPOC', 'EBSEQPOC')

-- -REQCOD_CT of TI17REQJOBPLAN in ( I4IYPOC, I4IQPOC  ) ==> POCI
update #TREQJOBPLAN
set    REQCOD_CT = 'T' ,
        VRS_NF=0,
        CLOPER_LS='POST OMEGA CONSO IFRS'
        where REQCOD_CT in ('I4IYPOC', 'I4IQPOC')

------------- POS BOOKING
-- -REQCOD_CT of TI17REQJOBPLAN in ( I4IYPOSB, I4IQPOSB ) 
update #TREQJOBPLAN
set    REQCOD_CT = 'F' ,
        VRS_NF=0,
        CLOPER_LS='BOOKING POST OMEGA SOCIAL IFRS'
        where REQCOD_CT in ('I4IYPOSB', 'I4IQPOSB')


-- -REQCOD_CT of TI17REQJOBPLAN in ( EBSEYPOSB, EBSEQPOSB ) 
update #TREQJOBPLAN
set    REQCOD_CT = 'F' ,
        VRS_NF=1,
        CLOPER_LS='BOOKING POST OMEGA SOCIAL EBS'
        where REQCOD_CT in ('EBSEYPOSB', 'EBSEQPOSB')




------------- POC BOOKING
-- -REQCOD_CT of TI17REQJOBPLAN in ( I4IYPOCB, I4IQPOCB ) 
update #TREQJOBPLAN
set    REQCOD_CT = 'F' ,
        VRS_NF=0,
        CLOPER_LS='BOOKING POST OMEGA CONSO IFRS'
        where REQCOD_CT in ('I4IYPOCB', 'I4IQPOCB')


-- -REQCOD_CT of TI17REQJOBPLAN in ( EBSEYPOCB, EBSEQPOCB ) 
update #TREQJOBPLAN
set    REQCOD_CT = 'F' ,
        VRS_NF=1, 
        CLOPER_LS='BOOKING POST OMEGA CONSO EBS'
        where REQCOD_CT in ('EBSEYPOCB', 'EBSEQPOCB')


--------Création des demandes T en plus de la demande F------------------------------------------- 
select * into #TREQJOBPLAN1
from #TREQJOBPLAN
where REQCOD_CT = 'F' 

update #TREQJOBPLAN1
set    REQCOD_CT = 'T' 


Select @erreur = @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;cur_I17reqjobplan" 
    Return @erreur
End


declare @max_dbclo date
select @max_dbclo=max( DBCLO_D)  from #TREQJOBPLAN
print '@max_dbclo="%1!"  ',@max_dbclo

declare @IS_NEW_MODE char(1)


--[004] 
print 'Delete all requests ("D","T","F","C") with launchD null BEST..TREQJOBPLAN ',@site_cf 
-- [011]
delete  BEST..TREQJOB where id_nf in (select id_nf from BEST..TREQJOBPLAN where SITE_CF = @site_cf and launch_d = null and REQCOD_CT in ("D","T","F","C"))
delete  BEST..TREQJOBPLAN where SITE_CF = @site_cf and launch_d = null and REQCOD_CT in ("D","T","F","C")  

--[006]
--[008] delete M and R from criteria
delete  BEST..TREQJOBPLAN 
where ( SITE_CF = @site_cf  or SITE_CF = 'ALL')  
and launch_d = null 
and REQCOD_CT in ("A","L","V","Y","Z")  
and DBCLO_D <= @p_CRE_D
    
print 'Delete all requests ("D","T","F","C") with launchD null BEST..TREQJOB ',@site_cf 
delete  BEST..TREQJOB where  SITE_CF = @site_cf and launch_d = null and REQCOD_CT in ("D","T","F","C") 

-- [013]
delete  BEST..TREQJOB where  SITE_CF = @site_cf and DBCLO_D >= @p_CRE_D and REQCOD_CT not in ('P')

--[006]
--[008] delete M and R from criteria
delete  BEST..TREQJOB where SITE_CF = @site_cf and launch_d = null and REQCOD_CT in ("A","L","V","Y","Z")

select @IS_NEW_MODE ="Y"
if  Exists (   select * from BEST.dbo.TREQJOBPLAN 
                where  launch_d = null
                and dbclo_d <= @max_dbclo
                and updusr_cf != "ESCJ"
                and SITE_CF = @site_cf -- @site_cf   
                and REQCOD_CT in ("D","T","F","C") 
            )
        select @IS_NEW_MODE ="N"

print '@IS_NEW_MODE="%1!"  ',@IS_NEW_MODE

-- Actualisation de la table TREQJOBPLAN
delete  BEST..TREQJOBPLAN where DBCLO_D > @p_CRE_D
insert into BEST..TREQJOBPLAN  
select  
	SSD_CF, BALSHEYEA_NF, BALSHTMTH_NF, CLODAT_D, REQCOD_CT, CRE_D, DBCLO_D, LAUNCH_D, CLOPER_LS, VRS_NF, UPDUSR_CF, START_D, END_D, SITE_CF
from BEST..TI17REQJOBPLAN
where REQCOD_CT in ("A","L","V","Y","Z","M","R")
and DBCLO_D > @p_CRE_D

 
if ( exists(  select 1 from #TREQJOBPLAN)   or exists ( select 1 from #TREQJOBPLAN1))  
BEGIN
   
    print 'delete  BEST..TREQJOBPLAN where SITE_CF = "%1!"   DBCLO_D in ( select dbclo_d from #TREQJOBPLAN ) ',@site_cf 
    delete  BEST..TREQJOBPLAN where SITE_CF = @site_cf   and DBCLO_D in ( select dbclo_d from #TREQJOBPLAN ) and REQCOD_CT  in ("D","T","F","C")
    --[006]
    delete  BEST..TREQJOBPLAN where SITE_CF = @site_cf   and DBCLO_D in ( select dbclo_d from #TREQJOBPLAN ) and REQCOD_CT  in ("A","L","V","Y","Z") 
    delete  BEST..TREQJOBPLAN where SITE_CF in ( @site_cf,"ALL")   and DBCLO_D =@p_CRE_D and REQCOD_CT  in ("M","R") 
    
    print 'delete from BEST..TREQJOB where SITE_CF = "%1!"    DBCLO_D in ( select dbclo_d from #TREQJOBPLAN ) ',@site_cf 
    delete from BEST..TREQJOB where SITE_CF = @site_cf   and DBCLO_D in ( select dbclo_d from #TREQJOBPLAN ) and REQCOD_CT != "B"  and CRE_D >= convert(varchar, getdate(),112)
         
    if @p_IS_CHECK  != 1 
    BEGIN    
        print 'nsert into BEST..TREQJOBPLAN'
        insert into BEST..TREQJOBPLAN
        select  
        SSD_CF, BALSHEYEA_NF, BALSHTMTH_NF, CLODAT_D, REQCOD_CT, CRE_D, DBCLO_D, LAUNCH_D, CLOPER_LS, VRS_NF, UPDUSR_CF, START_D, END_D, SITE_CF
        from #TREQJOBPLAN
        union  
        select 
        SSD_CF, BALSHEYEA_NF, BALSHTMTH_NF, CLODAT_D, REQCOD_CT, CRE_D, DBCLO_D, LAUNCH_D, CLOPER_LS, VRS_NF, UPDUSR_CF, START_D, END_D, SITE_CF
        from #TREQJOBPLAN1
    END
    
END 




if @p_IS_CHECK = 1
BEGIN
    print 'select * from #TREQJOBPLAN'
    select * from #TREQJOBPLAN
    
    print 'select * from #TREQJOBPLAN'
    select * from #TREQJOBPLAN1

    print 'select doublons'
    select * from BEST..TREQJOBPLAN where CRE_D in
    (
        select CRE_D from #TREQJOBPLAN  
    )
END


print 'select * from   BEST..TREQJOBPLAN where DBCLO_D="%1!" and SITE_CF = "%2!" ',@p_CRE_D,@site_cf 
--select * from  BEST..TREQJOBPLAN where DBCLO_D=@p_CRE_D and SITE_CF = @site_cf 

print 'select * from  BEST..TREQJOB where DBCLO_D="%1!" and SITE_CF = "%2!" ',@p_CRE_D,@site_cf 
--select * from  BEST..TREQJOB where DBCLO_D=@p_CRE_D and SITE_CF = @site_cf 

select "export @IS_NEW_MODE=" +@IS_NEW_MODE

return 0
go

GRANT EXECUTE ON dbo.PuREQJOBPLAN_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuREQJOBPLAN_03 TO GDBBATCH
go
