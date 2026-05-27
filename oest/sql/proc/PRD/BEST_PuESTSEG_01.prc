use BEST
go
if object_id('dbo.PuESTSEG_01') is not null
begin
  drop PROC dbo.PuESTSEG_01
  print '<<< DROPPED PROC dbo.PuESTSEG_01 >>>'
end
go
create procedure PuESTSEG_01
  (
  @ssd_cf    integer
,@segtyp_ct char(1) --type de segment (A ou V ou E ou S)
,@P_VRS_NF  numeric(10,0)
,@caller_flag char(1)='U'  -- by default , file from user
  )
as
/********************************************************************************
Domaine : (ES) Estimation
Base principale : BEST
Description : on met les deux derniers caracteres du champ SEG_NF = numero de filiale.
              Dans les 3 progs C du ESED0401 on a verifie que la longueur ne dépassait pas 8 caracteres.
              Pour toutes les filiales sauf New-York.
Conditions d'execution : Valeurs de retour 0:  OK -1: Echec
Commentaires :
_________________
MODIFICATIONS
1 Yves B  21/06/1999 Création
2 Florent 14/02/2012 :spot:23390 SOLVENCY II
3 Florent 15/11/2012 :spot:24041 le libellé du segment S doit être le même que le libellé du segment A s'il existe
4 Florent 01/06/2015 :spot:28694 Segmentation VIE
5 Florent 11/05/2017 :spira:58025 ajout de la version de la segmentation
6 Charles 17/08/2018 :BJTD-CLO-905316 EXT-IFRS17-903277 - REQ 03.05 ajout du segment type 
7 KBagwe  09/01/2019 :Closing Version Information not available [IN:074327]
8 JYP     18/06/2024 :spira 111723 : do not update TSEGEST when closing job
********************************************************************************/
declare
  @ssdlib_cf char(2)
,@segtyp_SII USEGTYP_CT -- modif 2


--modif 6
create table #tmapping (segtyp_ct char(1), segvalues char(1))


insert into #tmapping values ('A', 'A')
insert into #tmapping values ('A', 'V')
insert into #tmapping values ('T', 'T')
insert into #tmapping values ('T', 'W')
insert into #tmapping values ('U', 'U')
insert into #tmapping values ('U', 'X') 
insert into #tmapping values ('E', 'E')
insert into #tmapping values ('S', 'S')



begin TRANSACTION

if @segtyp_ct='S'
begin
  select @segtyp_SII='A'
  -- on insert dans BTRAV..EST_ESED0401_TSEGEST le segment A pour gérer la maj du libellé du segment sur un seul segtype: A
  -- avec le segment A comme référence si déjà existant
  -- On vide la table du SEGTYP_CT='A' ou si SEGTYP_CT='V' si présent dans la table de travail pour reprendre les données validées dans BEST..TSEGEST
  -- modif 6
  delete BTRAV..EST_ESED0401_TSEGEST where SSD_CF=@ssd_cf and (SEGTYP_CT='A' or SEGTYP_CT='V') 
  if @@error!=0 goto ERREUR

  insert BTRAV..EST_ESED0401_TSEGEST
  select
    a.SSD_CF
   ,a.SEGTYP_CT
   ,a.SEG_NF
   ,a.UWY_NF
   ,b.SEG_LL
   ,a.CUR_CF
   ,b.SEGNAT_CT
   ,b.CTRRET_B 
   ,a.PRMAMT_M 
   ,a.CLMAMT_M 
   ,a.LOSRAT_R 
   ,a.AMORAT_CT
   ,a.ACY_NF
   from BEST..TSEGEST a, BEST..TSEGMENT b
    where a.SSD_CF=@ssd_cf
      and (a.SEGTYP_CT='A' or a.SEGTYP_CT='V')  
      and a.VRS_NF=@P_VRS_NF
      and a.SSD_CF=b.SSD_CF
      and a.SEGTYP_CT=b.SEGTYP_CT
      and a.VRS_NF=b.VRS_NF
      and a.SEG_NF=b.SEG_NF
  if @@error!=0 goto ERREUR
end
else
begin
  if (@segtyp_ct='A' or @segtyp_ct='V')  
    select @segtyp_SII='S'
  else
    select @segtyp_SII=@segtyp_ct
end

-- on convertit ssd_cf en varchar, on met 0 devant si filiale < 10
select @ssdlib_cf = replicate ('0', 2 - datalength ( convert (varchar, @ssd_cf))) + convert (varchar, @ssd_cf)
-- on update dans BEST : TCTRGRO, TSEGEST et TLABOCY
-- on rajoute le numéro de filiale (02 ou 12) dans le champ SEG_NF
-- SEG_NF : char(10)
-- on a bien verifié que seg_nf avait au plus 8 caracteres (premiers step du ESED0401)
-- Cela ne se fait pas pour New-York (ssd_ cf = 10)

if @ssd_cf!=10
begin
  if @segtyp_ct!='S'
  begin
    update BEST..TCTRGRO
     set SEG_NF=rtrim(SEG_NF) + replicate (' ', 8-datalength(convert(varchar, SEG_NF))) + @ssdlib_cf
      from BEST..TCTRGRO
       where SSD_CF=@ssd_cf
         and SEGTYP_CT in (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct )
         and VRS_NF=@P_VRS_NF
    if @@error!=0 goto ERREUR

    update BEST..TLABOCY
    set SEG_NF=rtrim(SEG_NF) + replicate (' ', 8-datalength(convert(varchar, SEG_NF))) + @ssdlib_cf
     from BEST..TLABOCY
      where SSD_CF=@ssd_cf
        and SEGTYP_CT in (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct )
        and VRS_NF=@P_VRS_NF
    if @@error!=0 goto ERREUR
  end

 if @caller_flag = 'U' 
 begin 
  update BTRAV..EST_ESED0401_TSEGEST
   set SEG_NF=rtrim(SEG_NF) + replicate (' ', 8-datalength(convert(varchar, SEG_NF))) + @ssdlib_cf
    from BTRAV..EST_ESED0401_TSEGEST
     where SSD_CF=@ssd_cf
       and SEGTYP_CT in (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct )
  if @@error!=0 goto ERREUR
 end 
  -- modif 3 le libellé du segment S doit être le même que le libellé du segment A s'il existe
    
  if @segtyp_ct='S'
  begin
    update BTRAV..EST_ESED0401_TSEGEST
     set SEG_LL = a.SEG_LL
      from BTRAV..EST_ESED0401_TSEGEST s, BEST..TSEGMENT a
       where s.SSD_CF = @ssd_cf
         and s.SEGTYP_CT in (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct )
         and a.SSD_CF = @ssd_cf
         and a.VRS_NF=@P_VRS_NF
         and a.SSD_CF = s.SSD_CF
         and (a.SEGTYP_CT = 'A' or a.SEGTYP_CT='V')   			-- modif 6
         and a.SEG_NF=s.SEG_NF
         and s.SEG_LL!=a.SEG_LL
    if @@error!=0 goto ERREUR
  end
end
-- modif 6
delete BEST..TSEGMENT where SSD_CF=@SSD_CF and (SEGTYP_CT='A' or SEGTYP_CT='V') and VRS_NF=@P_VRS_NF       
if @@error!=0 goto ERREUR

-- on insert dans TSEGMENT les libelles des segments sans notion d'UWY
insert BEST..TSEGMENT(VRS_NF,SSD_CF,SEGTYP_CT,SEG_NF)
select distinct VRS_NF,SSD_CF,SEGTYP_CT,SEG_NF
from BEST..TCTRGRO
  where SSD_CF=@ssd_cf
    and SEGTYP_CT in (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct )
    and VRS_NF=@P_VRS_NF
if @@error!=0 goto ERREUR

  -- modif 6
insert BEST..TSEGMENT(VRS_NF,SSD_CF,SEGTYP_CT,SEG_NF)
select distinct VRS_NF=@P_VRS_NF,SSD_CF,'A',SEG_NF
from BTRAV..EST_ESED0401_TSEGEST a
  where SSD_CF=@ssd_cf
    and (a.SEGTYP_CT in  (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct) OR a.SEGTYP_CT= @segtyp_SII)  -- modif 1,7
    and not exists(select 1 from BEST..TSEGMENT b where a.SSD_CF=b.SSD_CF and (b.SEGTYP_CT='A' or b.SEGTYP_CT='V') and a.SEG_NF=b.SEG_NF and b.VRS_NF=@P_VRS_NF) -- modif 1   -- modif 6
if @@error!=0 goto ERREUR
  -- modif 6
-- modif 2 - on s'assure de toujours sélectionner les type de segment A, V et S qui correspondent à un type A ou V dans BEST..TSEGMENT
update BEST..TSEGMENT
set SEG_LL=e.SEG_LL,
     CUR_CF=e.CUR_CF,
     SEGNAT_CT=e.SEGNAT_CT,
     CTRRET_B=e.CTRRET_B
  from BEST..TSEGMENT s, BTRAV..EST_ESED0401_TSEGEST e
   where e.SSD_CF=@ssd_cf
     and (e.SEGTYP_CT in  (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct) OR e.SEGTYP_CT= @segtyp_SII)  -- 7
     and (s.SEGTYP_CT='A' or s.SEGTYP_CT='V')    
     and s.VRS_NF=@P_VRS_NF
     and e.SEG_NF=s.SEG_NF
     and e.SSD_CF=s.SSD_CF
     and e.UWY_NF*10000+e.ACY_NF=(select max(UWY_NF*10000+ACY_NF) from BTRAV..EST_ESED0401_TSEGEST x where x.SEG_NF=e.SEG_NF and x.SSD_CF=e.SSD_CF 
     and (x.SEGTYP_CT in  (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct) OR x.SEGTYP_CT= @segtyp_SII)  )-- modif 7
if @@error!=0 goto ERREUR

 if @caller_flag = 'U'
 begin 
  insert BEST..TSEGEST
  select
    @P_VRS_NF
   ,SSD_CF
   ,SEGTYP_CT
   ,SEG_NF
   ,UWY_NF
   ,CRE_D=getdate()
   ,CUR_CF
   ,PRMAMT_M 
   ,CLMAMT_M 
   ,LOSRAT_R 
   ,AMORAT_CT
   ,ACY_NF
   from BTRAV..EST_ESED0401_TSEGEST
    where SSD_CF=@ssd_cf
      and SEGTYP_CT in (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct )
  if @@error!=0 goto ERREUR

 end 

commit TRANSACTION
return 0

ERREUR:
rollback TRANSACTION
return -1
go
if object_id('dbo.PuESTSEG_01') is not null
  print '<<< CREATED PROC dbo.PuESTSEG_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PuESTSEG_01 >>>'
go
grant execute on dbo.PuESTSEG_01 TO GOMEGA, GDBBATCH
go
