use BEST
go
if object_id('PsLIFMOD2_02') is not null
begin
    drop PROC PsLIFMOD2_02
    print '<<< DROPPED PROC PsLIFMOD2_02 >>>'
end
go
create procedure PsLIFMOD2_02
  (
  @p_CTR_NF       UCTR_NF
 ,@p_SEC_NF       USEC_NF
 ,@p_BALSHEY_NF   smallint
 ,@p_BALSHTMTH_NF tinyint
 ,@p_CRE_D        datetime=null
 ,@p_RETRO_B      bit=0
  )
as
/***************************************************
Programme               : PsLIFMOD2_02
Fichier script associé  : BEST_PsLIFMOD2_02
Domaine                 : Estimations
Base principale         : BEST
Version                 : V05.1
Auteur                  : G. BUISSON
Date de creation        : 16/06/2005
Description du programme: Spot 11213 : Aggrégation des montants par traité lors d'un dépassement de seuil
Conditions d'execution  :
Commentaires            : sans la section de @p_SEC_NF, conversion en devise filiale puis en devise du dernier exe de la section
_________________
MODIFICATIONS
1  G. BUISSON  26/09/2005 V05.1 Le calcul de la différence  (après - avant) ne se fait plus dans la DW mais dans la proc.
                           Dans la DW les champs ne sont plus des champs calculés.
2  G. BUISSON  29/06/2006 V06.1 Les postes CNA ne sont plus différenciés par filiale
3  G. BUISSON  16/11/2007 V07.2 :Spot:14286 Ajout du poste 1011 (Primes liées à la sinistralité) qui doit être géré comme le 1010
4  Florent     05/06/2008 :spot:14205 debug recherche des derniers montants pour calcul positions
5  Florent     22/12/2008 :spot:16651 ajout de l'exe pour la séléction du dernier mois bilan !!
6  Florent     27/11/2009 :spot:17244 ajout de la VOBA et de poste cumul manquant dans la retro, libellé du poste 1450 pour le résultat financier comme sur la grille estimation
               28/01/2010 :spot:17244 groupe 3 devient le 4 et le 3 (RT + CNA) devient le 4
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/
declare
  @STAT_REP_D datetime
 ,@SEUIL_M    UAMT_M
 ,@CURCTR_CF  UCUR_CF
 ,@SSD_CF     USSD_CF
 ,@ESB_CF     UESB_CF
 ,@EXC_R_SEC  ULNGDEC

create Table #LISTE
  (
  ACMTRS_NT  smallint
 ,ESTMNT_M1  UAMT_M null
 ,ESTMNT_M2  UAMT_M null
 ,ESTMNT_M3  UAMT_M null
 ,ESTMNT_M4  UAMT_M null
 ,ESTMNT_M5  UAMT_M null
 ,ESTMNT_M6  UAMT_M null
 ,ESTMNT_M7  UAMT_M null
 ,AESTMNT_M1 UAMT_M null
 ,AESTMNT_M2 UAMT_M null
 ,AESTMNT_M3 UAMT_M null
 ,AESTMNT_M4 UAMT_M null
 ,AESTMNT_M5 UAMT_M null
 ,AESTMNT_M6 UAMT_M null
 ,AESTMNT_M7 UAMT_M null
 ,ACMTRS_LL  varchar(64) NOT null
  )

declare @site_cf        varchar(10),
        @erreur         int
select top 1 @SSD_CF=SSD_Cf FROM BTRT..TCONTR WHERE ctr_nf=@p_CTR_NF
Execute @erreur = BEST..PsSITE_01 @SSD_CF,'2',@site_cf output

-- Il faut récupérer la filiale, l'établissement et la monnaie
-- d'Origine pour la section déjà affichée
if @p_RETRO_B=1
begin
  select @SSD_CF   =SSD_CF,
         @ESB_CF   =ESB_CF,
         @CURCTR_CF=RETPCPCUR_CF
  from   BRET..TRETCTR
  where  RETCTR_NF=@p_ctr_nf
  and    RTY_NF   =(select max(RTY_NF)
                      from   BRET..TRETCTR c
                      where  c.RETCTR_NF  =@p_ctr_nf
                      and    RETCTRSTS_CT in (3, 19))
end
else
begin
  select @SSD_CF=SSD_CF,
         @ESB_CF=ACCESB_CF
  from   BTRT..TCONTR
  where  CTR_NF=@p_ctr_nf
  and    UWY_NF=(select max(UWY_NF)
                   from   BTRT..TCONTR c
                   where  c.CTR_NF  =@p_ctr_nf
                   and    CTRSTS_CT in (14, 16, 17, 19))

  select @CURCTR_CF=PCPCUR_CF
  from   BTRT..TSECTION
  where  CTR_NF=@p_CTR_NF
  and    SEC_NF=@p_SEC_NF
  and    UWY_NF=(select max(UWY_NF)
                   from   BTRT..TSECTION c
                   where  c.CTR_NF  =@p_ctr_nf
                   and    SEC_NF    =@p_SEC_NF
                   and    SECSTS_CT in (14, 16, 17, 19))
end

-- taux de conversion de la devise filiale vers la devise de la section dernier exe
select @EXC_R_SEC=b.EXC_R
 from BREF..TCURQUOT b
  where b.CUR_CF=@CURCTR_CF
    and b.SSD_CF=@SSD_CF
    and b.EXC_D=(select max(x.EXC_D) from BREF..TCURQUOT x where x.EXC_D<=isnull(@p_CRE_D,@STAT_REP_D) and x.CUR_CF=b.CUR_CF and x.SSD_CF=b.SSD_CF)

insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 1, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=1010 and SSD_CF=@SSD_CF
insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 2, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=1400 and SSD_CF=@SSD_CF
insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 3, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2450 else 1450 end) and SSD_CF=@SSD_CF
insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 4, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2460 else 1460 end) and SSD_CF=@SSD_CF -- modif 6

select @STAT_REP_D=max(CRE_D)
from   BEST..TREQJOB
where  SSD_CF      =@SSD_CF
and    REQCOD_CT   ='L'
and    BALSHEYEA_NF=1900
and    BALSHTMTH_NF=1
and    CLODAT_D    ='19000101'
and    SITE_CF     =@site_cf

-- en cours de la devise filiale
select @SEUIL_M=AMT_M from TLIFTHR where SSD_CF=@SSD_CF and ESB_CF=@ESB_CF

-- Liste à partir de TLIFEST
create Table #GROUPE(GP Tinyint, ACMTRS_NT Smallint)

--Primes
if @p_RETRO_B=1
begin
  insert #GROUPE values(1,2010)
  insert #GROUPE values(1,2011)
end
else
begin
  insert #GROUPE values(1,1010)
  insert #GROUPE values(1,1011)
end

--Résultat technique
if @p_RETRO_B=1
begin
  insert #GROUPE values(2,2010)
  insert #GROUPE values(2,2011)
  insert #GROUPE values(2,2021)
  insert #GROUPE values(2,2022)
  insert #GROUPE values(2,2063)
  insert #GROUPE values(2,2064)
  insert #GROUPE values(2,2073)
  insert #GROUPE values(2,2074)
  insert #GROUPE values(2,2083) -- modif 6
  insert #GROUPE values(2,2084) -- modif 6
  insert #GROUPE values(2,2100)
  insert #GROUPE values(2,2110) -- modif 6
  insert #GROUPE values(2,2140)
  insert #GROUPE values(2,2145) -- modif 6
  insert #GROUPE values(2,2150)
  insert #GROUPE values(2,2160)
  insert #GROUPE values(2,2200)
  insert #GROUPE values(2,2210)
  insert #GROUPE values(2,2220)
  insert #GROUPE values(2,2231)
  insert #GROUPE values(2,2232)
  insert #GROUPE values(2,2243)
  insert #GROUPE values(2,2244)
  insert #GROUPE values(2,2263) -- modif 6
  insert #GROUPE values(2,2264) -- modif 6
end
else
begin
  insert #GROUPE values(2,1010)
  insert #GROUPE values(2,1011)
  insert #GROUPE values(2,1021)
  insert #GROUPE values(2,1022)
  insert #GROUPE values(2,1063)
  insert #GROUPE values(2,1064)
  insert #GROUPE values(2,1073)
  insert #GROUPE values(2,1074)
  insert #GROUPE values(2,1083)
  insert #GROUPE values(2,1084)
  insert #GROUPE values(2,1100)
  insert #GROUPE values(2,1110)
  insert #GROUPE values(2,1140)
  insert #GROUPE values(2,1150)
  insert #GROUPE values(2,1160)
  insert #GROUPE values(2,1200)
  insert #GROUPE values(2,1210)
  insert #GROUPE values(2,1220)
  insert #GROUPE values(2,1231)
  insert #GROUPE values(2,1232)
  insert #GROUPE values(2,1243)
  insert #GROUPE values(2,1244)
  insert #GROUPE values(2,1263)
  insert #GROUPE values(2,1264)
end

--Résultat Tech. + Financier
insert #GROUPE select 3, ACMTRS_NT from #GROUPE where GP=2
if @p_RETRO_B=1
begin
  insert #GROUPE values(3,2340)
  insert #GROUPE values(3,2350)
end
else
begin
  insert #GROUPE values(3,1340)
  insert #GROUPE values(3,1350)
end

--Résultat Tech. + Financier + CNA + VOBA
insert #GROUPE select 4, ACMTRS_NT from #GROUPE where GP=3
-- CNA et VOBA
-- Les postes ne sont plus différenciés par filiale
if @p_RETRO_B=1
begin
  insert #GROUPE values(4,2163)
  insert #GROUPE values(4,2164)
  insert #GROUPE values(4,2183)
  insert #GROUPE values(4,2184)
  insert #GROUPE values(4,2193)
  insert #GROUPE values(4,2194)
end
else
begin
  insert #GROUPE values(4,1163)
  insert #GROUPE values(4,1164)
  insert #GROUPE values(4,1183)
  insert #GROUPE values(4,1184)
  insert #GROUPE values(4,1193)
  insert #GROUPE values(4,1194)
end

-- Situation avant, conversion en devise filiale puis en devise section dernier exercice
select
  ACMTRS_NT=x.GP
 ,ESTMNT_M1=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 4 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,ESTMNT_M2=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 3 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,ESTMNT_M3=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 2 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,ESTMNT_M4=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 1 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,ESTMNT_M5=round(sum(case when a.ACY_NF=@p_BALSHEY_NF     then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,ESTMNT_M6=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 1 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,ESTMNT_M7=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 2 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
into #TLIFEST_AV
 from TLIFEST a, #GROUPE x, BREF..TCURQUOT d
  where a.ACMTRS_NT=x.ACMTRS_NT
    and a.CTR_NF=@p_CTR_NF
    and a.SEC_NF!=@p_SEC_NF
    and a.ACY_NF between @p_BALSHEY_NF - 4 and @p_BALSHEY_NF + 2
    and a.PRS_CF=500
    and d.CUR_CF=a.CUR_CF
    and d.SSD_CF=@SSD_CF
    and d.EXC_D=(select max(c.EXC_D) from BREF..TCURQUOT c where c.EXC_D<=isnull(@p_CRE_D,@STAT_REP_D) and c.CUR_CF=d.CUR_CF and c.SSD_CF=d.SSD_CF)
    and a.CRE_D<=@STAT_REP_D
    and a.BALSHEY_NF=@p_BALSHEY_NF
    and a.BALSHTMTH_NF<=@p_BALSHTMTH_NF
    -- modif 4
    and a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF) from TLIFEST m
                         where m.ACY_NF=a.ACY_NF
                           and m.CTR_NF=a.CTR_NF
                           and m.UWY_NF=a.UWY_NF  -- modif 5
                           and m.SEC_NF=a.SEC_NF
                           and m.BALSHEY_NF=a.BALSHEY_NF
                           and m.BALSHTMTH_NF<=@p_BALSHTMTH_NF
                           and m.PRS_CF=a.PRS_CF
                           and m.ACMTRS_NT=a.ACMTRS_NT
                           and m.CRE_D<=@STAT_REP_D)
    and a.CRE_D=(select max(b.CRE_D) from TLIFEST b
                  where b.CTR_NF=a.CTR_NF
                    and b.UWY_NF=a.UWY_NF
                    and b.SEC_NF=a.SEC_NF
                    and b.ACY_NF=a.ACY_NF
                    and b.BALSHEY_NF=a.BALSHEY_NF
                    and b.BALSHTMTH_NF=a.BALSHTMTH_NF
                    and b.PRS_CF=a.PRS_CF
                    and b.ACMTRS_NT=a.ACMTRS_NT
                    and b.CRE_D<=@STAT_REP_D)
group by x.GP
order by 1

-- Situation après, conversion en devise filiale
select
  ACMTRS_NT=x.GP
 ,AESTMNT_M1=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 4 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,AESTMNT_M2=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 3 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,AESTMNT_M3=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 2 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,AESTMNT_M4=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 1 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,AESTMNT_M5=round(sum(case when a.ACY_NF=@p_BALSHEY_NF     then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,AESTMNT_M6=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 1 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
 ,AESTMNT_M7=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 2 then (a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) end),3)
into #TLIFEST_AP
 from TLIFEST a, #GROUPE x, BREF..TCURQUOT d
  where a.ACMTRS_NT=x.ACMTRS_NT
    and a.CTR_NF=@p_CTR_NF
    and a.SEC_NF!=@p_SEC_NF
    and a.ACY_NF between @p_BALSHEY_NF - 4 and @p_BALSHEY_NF + 2
    and a.PRS_CF=500
    and a.CUR_CF=d.CUR_CF
    and d.SSD_CF=@SSD_CF
    and d.EXC_D=(select max(c.EXC_D) from BREF..TCURQUOT c where c.EXC_D<=isnull(@p_CRE_D,@STAT_REP_D) and c.CUR_CF=d.CUR_CF and c.SSD_CF=d.SSD_CF)
    and a.BALSHEY_NF=@p_BALSHEY_NF
    and a.BALSHTMTH_NF<=@p_BALSHTMTH_NF
    -- modif 4
    and a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF) from TLIFEST m
                         where m.ACY_NF=a.ACY_NF
                           and m.CTR_NF=a.CTR_NF
                           and m.UWY_NF=a.UWY_NF  -- modif 5
                           and m.SEC_NF=a.SEC_NF
                           and m.BALSHEY_NF=a.BALSHEY_NF
                           and m.BALSHTMTH_NF<=@p_BALSHTMTH_NF
                           and m.PRS_CF=a.PRS_CF
                           and m.ACMTRS_NT=a.ACMTRS_NT)
    and a.CRE_D=(select max(b.CRE_D) from TLIFEST b
                  where b.CTR_NF=a.CTR_NF
                    and b.UWY_NF=a.UWY_NF
                    and b.SEC_NF=a.SEC_NF
                    and b.ACY_NF=a.ACY_NF
                    and b.BALSHEY_NF=a.BALSHEY_NF
                    and b.BALSHTMTH_NF=a.BALSHTMTH_NF
                    and b.PRS_CF=a.PRS_CF
                    and b.ACMTRS_NT=a.ACMTRS_NT)
group by x.GP
order by 1

-- conversion en devise de la section du dernier exe
update #LISTE
 set ESTMNT_M1=round(b.ESTMNT_M1 / 1000,3)
    ,ESTMNT_M2=round(b.ESTMNT_M2 / 1000,3)
    ,ESTMNT_M3=round(b.ESTMNT_M3 / 1000,3)
    ,ESTMNT_M4=round(b.ESTMNT_M4 / 1000,3)
    ,ESTMNT_M5=round(b.ESTMNT_M5 / 1000,3)
    ,ESTMNT_M6=round(b.ESTMNT_M6 / 1000,3)
    ,ESTMNT_M7=round(b.ESTMNT_M7 / 1000,3)
 from #LISTE a, #TLIFEST_AV b
  where a.ACMTRS_NT=b.ACMTRS_NT

update #LISTE
 set AESTMNT_M1=round(b.AESTMNT_M1 / 1000,3)
    ,AESTMNT_M2=round(b.AESTMNT_M2 / 1000,3)
    ,AESTMNT_M3=round(b.AESTMNT_M3 / 1000,3)
    ,AESTMNT_M4=round(b.AESTMNT_M4 / 1000,3)
    ,AESTMNT_M5=round(b.AESTMNT_M5 / 1000,3)
    ,AESTMNT_M6=round(b.AESTMNT_M6 / 1000,3)
    ,AESTMNT_M7=round(b.AESTMNT_M7 / 1000,3)
 from #LISTE a, #TLIFEST_AP b
  where a.ACMTRS_NT=b.ACMTRS_NT

select @SEUIL_M=isnull(round(@SEUIL_M / @EXC_R_SEC / 1000,3),0)

select
  ACMTRS_NT
 ,ESTMNT_M1
 ,ESTMNT_M2
 ,ESTMNT_M3
 ,ESTMNT_M4
 ,ESTMNT_M5
 ,ESTMNT_M6
 ,ESTMNT_M7
 ,0, 0, 0, 0, 0, 0, 0
 ,AN1=@p_BALSHEY_NF - 4
 ,AN2=@p_BALSHEY_NF - 3
 ,AN3=@p_BALSHEY_NF - 2
 ,AN4=@p_BALSHEY_NF - 1
 ,AN5=@p_BALSHEY_NF
 ,AN6=@p_BALSHEY_NF + 1
 ,AN7=@p_BALSHEY_NF + 2
 ,AESTMNT_M1
 ,AESTMNT_M2
 ,AESTMNT_M3
 ,AESTMNT_M4
 ,AESTMNT_M5
 ,AESTMNT_M6
 ,AESTMNT_M7
 ,SEUIL_M=@SEUIL_M
 ,ACMTRS_LL
 ,DIFF_M1=isnull(AESTMNT_M1,0) - isnull(ESTMNT_M1,0)
 ,DIFF_M2=isnull(AESTMNT_M2,0) - isnull(ESTMNT_M2,0)
 ,DIFF_M3=isnull(AESTMNT_M3,0) - isnull(ESTMNT_M3,0)
 ,DIFF_M4=isnull(AESTMNT_M4,0) - isnull(ESTMNT_M4,0)
 ,DIFF_M5=isnull(AESTMNT_M5,0) - isnull(ESTMNT_M5,0)
 ,DIFF_M6=isnull(AESTMNT_M6,0) - isnull(ESTMNT_M6,0)
 ,DIFF_M7=isnull(AESTMNT_M7,0) - isnull(ESTMNT_M7,0)
from #LISTE

fin:
if object_id('#LISTE')      is not null drop Table #LISTE
if object_id('#TLIFEST_AV') is not null drop Table #TLIFEST_AV
if object_id('#TLIFEST_AP') is not null drop Table #TLIFEST_AP
if object_id('#GROUPE')     is not null drop Table #GROUPE
return 0
go
if object_id('dbo.PsLIFMOD2_02') is not null
  print '<<< CREATED procedure dbo.PsLIFMOD2_02 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsLIFMOD2_02 >>>'
go
GRANT EXECUTE on dbo.PsLIFMOD2_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFMOD2_02 TO GDBBATCH
go
