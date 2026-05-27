use BEST
go
if object_id('dbo.PuREQJOBPLANBLCSHTD_01') is not null
begin
  drop PROC dbo.PuREQJOBPLANBLCSHTD_01
  print '<<< DROPPED PROC dbo.PuREQJOBPLANBLCSHTD_01 >>>'
end
go
create procedure PuREQJOBPLANBLCSHTD_01
as
/***************************************************
Programme :                 PuREQJOBPLANBLCSHTD_01
Fichier script associé :    BEST_PuREQJOBPLANBLCSHTD_01.prc
Domaine :                   Estimation
Base principale :           BEST
Version :                   1
Auteur :                    D.GATIBELZA
Date de creation :          26/10/2010
Description du programme :  Mise à jour des dates dans TBLCSHTD
_________________
MODIFICATIONS
1 JF VAN DE VELDE 16/07/2012 :spot:23390 Solvency II
[002] 09/02/2018 R. cassis :Spira:67171  Lors du controle de la date compta reglement, la date dbclo est prise en compte au lieu du clodat et on de décale plus cette date,
                                         nous la controlons lorsque nous la planifions. Ajout de la condition du site dans les requetes.
*****************************************************/

--[002]
declare @erreur         int,
        @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

select @erreur=0

select
  a.BLCSHTYEA_NF
 ,a.BLCSHTMTH_NF
 ,c.CLOSING_B
 ,DATE_CPT_TEC=convert(char(10),c.ACCOUNT_D,111)
 ,LIB_CPT_RGL=convert(char(10),b.CLODAT_D,111)   --PHP00
 ,DATE_CPT_RGL=convert(char(10),b.DBCLO_D,111)    --PHP00
 ,DATE_END_PER=convert(char(10),max(a.END_D),111)
 ,DATE_CPT_RGL_NEW=convert(char(10),
                      case when (c.CLOSING_B=1 or max(a.SSD_CF) in(8,9)) and b.CLODAT_D<>c.ACCOUNT_D then c.ACCOUNT_D
                           else b.DBCLO_D
/* [002]                        when convert(char(10),max(a.END_D),111)>convert(char(10),b.DBCLO_D,111) then --PHP00
                             case
                               when datepart(dw,b.DBCLO_D)=1 then dateadd (dd,1,max(a.END_D)) -- un dimanche,on décale d'1 jour
                               when datepart(dw,b.DBCLO_D)=6 then dateadd (dd,3,max(a.END_D)) -- un vendredi,on décale de 3 jours
                               when datepart(dw,b.DBCLO_D)=7 then dateadd (dd,2,max(a.END_D)) -- un samedi, on decale de 2 jours
                               else max(a.END_D)
                             end
                        else
                             case
                               when datepart(dw,b.DBCLO_D)=1 then dateadd(dd,1,b.CLODAT_D) -- un dimanche,on décale d'1 jour
                               when datepart(dw,b.DBCLO_D)=6 then dateadd(dd,3,b.CLODAT_D) -- un vendredi,on décale de 3 jours
                               when datepart(dw,b.DBCLO_D)=7 then dateadd(dd,2,b.CLODAT_D) -- un samedi, on decale de 2 jours
                               else b.DBCLO_D                                               -- on garde clodat_initial --PHP00
                             end*/
                   end,111)
into #ctrlBLC_REQJOB
from bcta..tblcshtd a, best..treqjobplan b, bref..tcalend c --PHP00
where a.DMN_CF=3
  and b.REQCOD_CT='V'
  and a.BLCSHTYEA_NF=b.BALSHEYEA_NF
  and a.BLCSHTMTH_NF=b.BALSHTMTH_NF
  and a.BLCSHTYEA_NF=c.BLCSHTYEA_NF
  and a.BLCSHTMTH_NF=c.BLCSHTMTH_NF
  and b.LAUNCH_D is null
  and b.SITE_CF = @site_cf  -- [002]
group by a.BLCSHTYEA_NF,a.BLCSHTMTH_NF,c.ACCOUNT_D,c.CLOSING_B,b.CLODAT_D,b.DBCLO_D --PHP00
order by a.BLCSHTYEA_NF,a.BLCSHTMTH_NF,c.ACCOUNT_D,c.CLOSING_B,b.CLODAT_D,b.DBCLO_D
select @erreur = @@error
if @erreur != 0
begin
    select "Erreur :1: dans insert #ctrlBLC_REQJOB"
    goto fin
end

select * from #ctrlBLC_REQJOB

/* ----------------------------------------------------------------------------------------
 * Mise à jour des dates de comptabilisation des reglements
 * ---------------------------------------------------------------------------------------- */
select a.*
from best..treqjobplan b,#ctrlBLC_REQJOB a --PHP00
where b.REQCOD_CT='V'
  and a.BLCSHTYEA_NF=b.BALSHEYEA_NF
  and a.BLCSHTMTH_NF=b.BALSHTMTH_NF
  and b.LAUNCH_D is null
  and a.DATE_CPT_RGL<>DATE_CPT_RGL_NEW
  and b.SITE_CF = @site_cf  -- [002]

update best..treqjobplan
   set DBCLO_D=DATE_CPT_RGL_NEW --PHP00
from best..treqjobplan b,#ctrlBLC_REQJOB a
where b.REQCOD_CT='V'
  and a.BLCSHTYEA_NF=b.BALSHEYEA_NF
  and a.BLCSHTMTH_NF=b.BALSHTMTH_NF
  and b.LAUNCH_D is null
  and a.DATE_CPT_RGL<>DATE_CPT_RGL_NEW
  and b.SITE_CF = @site_cf  -- [002]
select @erreur = @@error
if @erreur != 0
begin
  select "Erreur :2: dans MAJ TREQJOB"
  goto fin
end

/* ----------------------------------------------------------------------------------------
 * Mise à jour des dates bilan éventuellement si elles dépassent date compta reglement
 * ---------------------------------------------------------------------------------------- */
 /*
select a.DATE_CPT_RGL_NEW,c.END_D,c.*
from best..treqjobplan b, bcta..tblcshtd c, #ctrlBLC_REQJOB a
where b.REQCOD_CT='V'
  and c.DMN_CF=3
  and b.LAUNCH_D is null
  and a.BLCSHTYEA_NF=b.BALSHEYEA_NF
  and a.BLCSHTMTH_NF=b.BALSHTMTH_NF
  and a.BLCSHTYEA_NF=c.BLCSHTYEA_NF
  and a.BLCSHTMTH_NF=c.BLCSHTMTH_NF
  and convert(char(10),c.END_D,111)>a.DATE_CPT_RGL_NEW
*/
-- Préselectionne les enregistrements à mettre à jour dans pour le END_D
select c.SSD_CF,c.ESB_CF,a.DATE_CPT_RGL_NEW,a.BLCSHTYEA_NF,a.BLCSHTMTH_NF
into #majEND_TBLCSHTD
from best..treqjobplan b, bcta..tblcshtd c, #ctrlBLC_REQJOB a
where b.REQCOD_CT='V'
  and c.DMN_CF=3
  and b.LAUNCH_D is null
  and a.BLCSHTYEA_NF=b.BALSHEYEA_NF
  and a.BLCSHTMTH_NF=b.BALSHTMTH_NF
  and a.BLCSHTYEA_NF=c.BLCSHTYEA_NF
  and a.BLCSHTMTH_NF=c.BLCSHTMTH_NF
  and convert(char(10),c.END_D,111)>a.DATE_CPT_RGL_NEW
  and b.SITE_CF = @site_cf  -- [002]

select * from #majEND_TBLCSHTD

select @erreur = @@error
if @erreur != 0
begin
  select "Erreur :3: dans insert #majEND_TBLCSHTD"
  goto fin
end

-- Préselectionne les enregistrements à mettre à jour dans pour le STR_D
select
  c.SSD_CF,c.ESB_CF,DATE_STR_NEW=dateadd(DD,1,a.DATE_CPT_RGL_NEW)
 ,DATE_CPT_RGL_NEW=a.DATE_CPT_RGL_NEW
 ,BLCSHTYEA_NF=datepart(YY,dateadd(MM,1,convert(datetime,convert(varchar,a.BLCSHTYEA_NF)+"/"+convert(varchar,a.BLCSHTMTH_NF)+"/01")))
 ,BLCSHTMTH_NF=datepart(MM,dateadd(MM,1,convert(datetime,convert(varchar,a.BLCSHTYEA_NF)+"/"+convert(varchar,a.BLCSHTMTH_NF)+"/01")))
into #majSTR_TBLCSHTD
 from best..treqjobplan b, bcta..tblcshtd c, #ctrlBLC_REQJOB a
  where b.REQCOD_CT='V'
    and c.DMN_CF=3
    and b.LAUNCH_D is null
    and a.BLCSHTYEA_NF=b.BALSHEYEA_NF
    and a.BLCSHTMTH_NF=b.BALSHTMTH_NF
    and a.BLCSHTYEA_NF=c.BLCSHTYEA_NF
    and a.BLCSHTMTH_NF=c.BLCSHTMTH_NF
    and convert(char(10),c.END_D,111)>a.DATE_CPT_RGL_NEW
    and b.SITE_CF = @site_cf  -- [002]
select @erreur = @@error
if @erreur != 0
begin
  select "Erreur :4: dans insert #majSTR_TBLCSHTD"
  goto fin
end

-- Mise à jour END_D
update bcta..tblcshtd
   set END_D=DATE_CPT_RGL_NEW
from bcta..tblcshtd a, #majEND_TBLCSHTD b
where a.DMN_CF=3
  and b.SSD_CF=a.SSD_CF
  and b.ESB_CF=a.ESB_CF
  and b.BLCSHTYEA_NF=a.BLCSHTYEA_NF
  and b.BLCSHTMTH_NF=a.BLCSHTMTH_NF
  and convert(char(10),a.END_D,111)>b.DATE_CPT_RGL_NEW
select @erreur = @@error
if @erreur != 0
begin
  select "Erreur :5: dans MAJ tblcshtd END_D"
  goto fin
end

-- Mise à jour STR_D à END_D + 1 jour
update bcta..tblcshtd
   set STR_D = DATE_STR_NEW
from bcta..tblcshtd a, #majSTR_TBLCSHTD b
where a.DMN_CF=3
  and b.SSD_CF=a.SSD_CF
  and b.ESB_CF=a.ESB_CF
  and b.BLCSHTYEA_NF=a.BLCSHTYEA_NF
  and b.BLCSHTMTH_NF=a.BLCSHTMTH_NF
  and convert(char(10),a.END_D,111)>b.DATE_CPT_RGL_NEW
select @erreur = @@error
if @erreur != 0
begin
  select "Erreur :6: dans MAJ tblcshtd STR_D"
  goto fin
end

------------------------------------------------------------
--  Fin de la transaction
------------------------------------------------------------
--commit tran
return 0

fin:
--rollback tran
return 1
go
if object_id('dbo.PuREQJOBPLANBLCSHTD_01') is not null
  print '<<< CREATED PROC dbo.PuREQJOBPLANBLCSHTD_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PuREQJOBPLANBLCSHTD_01 >>>'
go
grant execute on dbo.PuREQJOBPLANBLCSHTD_01 TO GOMEGA
go
