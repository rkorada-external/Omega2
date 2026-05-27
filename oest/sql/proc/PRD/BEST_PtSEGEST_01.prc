use BEST
go
if object_id('PtSEGEST_01') is not null
begin
  drop PROC PtSEGEST_01
  print '<<< DROPPED PROC PtSEGEST_01 >>>'
end
go
create procedure PtSEGEST_01
  (
  @p_ssd_cf    USSD_CF
 ,@segtyp_ct USEGTYP_CT
 ,@P_VRS_NF    numeric(10,0)
  )
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 05/10/2012
Description du programme: :spot:24041 solvency, intégration des segments type U et T
Conditions d'execution: appel par le ESED0401.cmd
Commentaires:
_________________
MODIFICATIONS
Modification - Removed dbo and added ‘with execute as caller as’ 
2 Florent 01/06/2015 :spot:28694 Segmentation VIE
3 Florent 11/05/2017 :spira:58025 ajout de la version de la segmentation
4 Charles 17/08/2018 :BJTD-CLO-905316 EXT-IFRS17-903277 - REQ 03.05 ajout du segment type 
*****************************************************/
create table #tmapping (segtyp_ct char(1), segvalues char(1))


insert into #tmapping values ('A', 'A')
insert into #tmapping values ('A', 'V')
insert into #tmapping values ('T', 'T')
insert into #tmapping values ('T', 'W')
insert into #tmapping values ('U', 'U')
insert into #tmapping values ('U', 'X') 
insert into #tmapping values ('E', 'E')
insert into #tmapping values ('S', 'S')

declare
  @VRS_NF  numeric(10,0)
 ,@CRE_D   datetime

select @CRE_D=getdate()

-- recherche de la dernière version COMPTABILISÉE pour la filiale
select @VRS_NF=VRS_NF
 from TVERPAR a
  where SEGTYP_CT='A'
    and SSD_CF=@p_SSD_CF
    and VRS_NF=@P_VRS_NF
    and exists(select 1 from best..TVERSION b where b.SEGTYP_CT='A' and b.VRSSTS_CT='CO' and b.VRSLOC_B=0 and a.SSD_CF=b.SSD_CF and a.VRS_NF=b.VRS_NF)
group by SSD_CF
having PAR_D=max(PAR_D)
order by SSD_CF

if @VRS_NF=null
begin
  raiserror 20010 "Valid Version %1!, subsidiary %2! not found",@P_VRS_NF,@p_ssd_cf
  return 999
end
-- maj de seg_nf pour ajouter la filiale si autre que 10
-- on supprime les segments en importation qui n'existe pas
update BTRAV..EST_ESED0401_TSEGEST
 set SEG_NF=upper(rtrim(SEG_NF))+replicate (' ',8-datalength(convert(varchar,SEG_NF)))+right(convert(char(3),SSD_CF+100),2)
  where SSD_CF=@p_ssd_cf
    and SEGTYP_CT in (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct )
    and SSD_CF!=10
if @@error!=0 return 999

-- maj du taux
update BTRAV..EST_ESED0401_TSEGEST
 set LOSRAT_R=round(LOSRAT_R / 100,8)
  where SSD_CF=@p_ssd_cf
    and SEGTYP_CT in (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct )
    and AMORAT_CT='R'
if @@error!=0 return 999

delete TSEGEST where SSD_CF=@p_ssd_cf and SEGTYP_CT in (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct ) and VRS_NF=@VRS_NF
if @@error!=0 return 999

insert TSEGEST
select
  @vrs_nf
 ,SSD_CF
 ,SEGTYP_CT
 ,SEG_NF
 ,UWY_NF
 ,@CRE_D
 ,CUR_CF
 ,PRMAMT_M
 ,CLMAMT_M
 ,LOSRAT_R
 ,AMORAT_CT
 ,ACY_NF
 from BTRAV..EST_ESED0401_TSEGEST
  where SSD_CF=@p_ssd_cf
    and SEGTYP_CT in (select segvalues from #tmapping c where c.segtyp_ct = @segtyp_ct )
if @@error!=0 return 999
go
if object_id('PtSEGEST_01') is not null
  print '<<< CREATED PROC PtSEGEST_01 >>>'
else
  print '<<< FAILED CREATING PROC PtSEGEST_01 >>>'
go
grant execute on PtSEGEST_01 TO GOMEGA, GDBBATCH
go