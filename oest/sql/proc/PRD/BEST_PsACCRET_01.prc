USE BEST
go
IF OBJECT_ID('dbo.PsACCRET_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsACCRET_01
    IF OBJECT_ID('dbo.PsACCRET_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsACCRET_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsACCRET_01 >>>'
END
go
create procedure dbo.PsACCRET_01
(
 @p_CLODAT_D datetime -- date de fin de mois en cours
,@p_ANO_B    bit=0
,@p_LOG_B 	 bit=0     -- pour les sorties de log
)
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 03/03/2015
Description du programme: :spot:29176 Comptabilité Rétro des PNA
Conditions d'execution: par ESID0065.cmd
Commentaires: au format GT
_________________
MODIFICATIONS
1 Florent    01/02/2016 :spot:29066 ajout colonnes GT 71 colonnes
2 -=Dch=-    13/05/2016 :spot:30465 EST57b Ajout de log pour les PNA RETRO
3 Riyadh    16/03/2017  : Spira 54986 : PAS DE PERIODE SCOR DEBUT ET FIN SUR LES ESTIMATIONS DE PNA RETRO NP RETRO

*****************************************************/
declare
 @erreur        int
,@lignes        int
,@TAUX_DEFAUT   decimal(9,8) 
,@SEUIL_PNA     UAMT_M
,@TRNCOD_PNA    UDETTRS_CF
,@DBLTRNCOD_PNA UDETTRS_CF
,@ICLODAT_D     datetime
,@NOTIF_LOG     int

select @ICLODAT_D=convert(char(4),year(@p_CLODAT_D))+
          case when month(@p_CLODAT_D) in(1,2,3) then '0331'
               when month(@p_CLODAT_D) in(4,5,6) then '0630'
               when month(@p_CLODAT_D) in(7,8,9) then '0930'
               when month(@p_CLODAT_D) in(10,11,12) then '1231'
          end

-- Initialisation des constantes
select @TAUX_DEFAUT=0.25, @TRNCOD_PNA='21410002',@SEUIL_PNA=1,@NOTIF_LOG=281
select @DBLTRNCOD_PNA=CTRSCOD_CF from bref..tdettrs where DETTRS_CF=@TRNCOD_PNA

create table #QUARTER (TRIMESTRE smallint)
insert #QUARTER values(1)
insert #QUARTER values(2)
insert #QUARTER values(3)
insert #QUARTER values(4)

SELECT distinct SSD_CF,ESB_CF,RETCTR_NF,RTY_NF,CTRINCUWY_D,CTREXP_D
 ,TAUX_1=sum(case when TRIMESTRE=1 then TAUX end)
 ,TAUX_2=sum(case when TRIMESTRE=2 then TAUX end)
 ,TAUX_3=sum(case when TRIMESTRE=3 then TAUX end)
 ,TAUX_4=sum(case when TRIMESTRE=4 then TAUX end)
into #RETSAISON
 from (
      ---------------------------------------------------------------------------------------------------------------------------------
      -- Recherche des taux à appliquer pour la saisonnalité des traités non proportionnels avant prise en compte de la durée du traité
      ---------------------------------------------------------------------------------------------------------------------------------
      SELECT distinct
        c.SSD_CF
       ,c.ESB_CF
       ,c.RETCTR_NF
       ,c.RTY_NF
       ,TAUX=round(convert(decimal,t.COLVAL_LS) / 100,8)   -- taux en 0 à 100
       ,TRIMESTRE=CONVERT(int, SUBSTRING(t.COLVAL_CT, CHARINDEX('Q', t.COLVAL_CT) + 1, 1))
       ,c.CTRINCUWY_D
       ,c.CTREXP_D
       FROM BRET..TRETSEC e, BRET..TRETCTR c, BREF..TBANTECL t
        WHERE c.RETCTRSTS_CT IN (3, 19)
          AND c.RETCTR_NF = e.RETCTR_NF
          AND c.RTY_NF = e.RTY_NF
          AND e.LOB_CF NOT IN ('30', '31')                                 -- Exclusion des traités Vie
          AND e.SECQUA4_CF between 220 and 239                             -- Qualifiant4 définissant la saisonnalité (US, Asie, Europe)
          AND c.RETCTRCAT_CF='02'                                        -- Traités non proportionnels
          AND t.COLVAL_CT LIKE CONVERT(varchar(5), e.SECQUA4_CF)+'Q[1-4]'  -- Lien avec la saisonnalité répertoriée dans TBANTECL sous la forme 'SECQUA4~Qi' ie qualifiant4~n° trimestre
          AND t.COL_LS = 'SAISRET_CT'
          AND t.LAG_CF = 'E'
          and e.RTY_NF >= year(@p_CLODAT_D) - 5
          -- Si la date d'échéance est postérieure à la date d'arrêté (0)
          and dbo.FtCompTrimestreRetro(c.CTRINCUWY_D,c.CTREXP_D,c.RTY_NF,'exp',@ICLODAT_D) = 0
          AND c.SSD_CF in(select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF=suser_name())
      union all
      -------------------------------------------------------------------------------------------------------------------------------------------------
      -- Constitution des taux (linéaires) à appliquer pour les traités pas concernés par la saisonnalité (avant prise en compte de la durée du traité)
      -------------------------------------------------------------------------------------------------------------------------------------------------
      SELECT distinct
        c.SSD_CF
       ,c.ESB_CF
       ,c.RETCTR_NF
       ,c.RTY_NF
       ,TAUX=@TAUX_DEFAUT
       ,x.TRIMESTRE
       ,c.CTRINCUWY_D
       ,c.CTREXP_D
       FROM BRET..TRETSEC e, BRET..TRETCTR c, #QUARTER x
        WHERE c.RETCTRSTS_CT IN (3, 19)
          AND c.RETCTR_NF = e.RETCTR_NF
          AND c.RTY_NF = e.RTY_NF
          AND c.RETCTRCAT_CF='02'                                     -- Traités non proportionnels
          AND e.LOB_CF NOT IN ('30', '31')                           -- Exclusion des traités Vie
          AND (e.SECQUA4_CF not between 220 and 239 OR e.SECQUA4_CF=NULL)-- Qualifiant4 excluant la saisonnalité (US, Asie, Europe)
          and e.RTY_NF >= year(@p_CLODAT_D) - 5
          -- Si la date d'échéance est postérieure à la date d'arrêté (0)
          and dbo.FtCompTrimestreRetro(c.CTRINCUWY_D,c.CTREXP_D,c.RTY_NF,'exp',@ICLODAT_D) = 0
          AND c.SSD_CF in(select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF=suser_name())
      ) a
GROUP BY SSD_CF,ESB_CF,RETCTR_NF,RTY_NF,CTRINCUWY_D,CTREXP_D
ORDER BY SSD_CF,ESB_CF,RETCTR_NF,RTY_NF,CTRINCUWY_D,CTREXP_D
select @erreur=@@error,@lignes=@@rowcount
if @erreur!=0 return
print 'table des Taux pour les 4 trimestre du contrat, lignes %1!',@lignes

------------------------------------------- recherche des anomalies sur la saisonnalité
select @lignes=count(*) from #RETSAISON a
 where (select count(*) from #RETSAISON b where a.RETCTR_NF=b.RETCTR_NF AND a.RTY_NF=b.RTY_NF) > 1
    or (TAUX_1+TAUX_2+TAUX_3+TAUX_4) != 1
if @p_ANO_B=1 and @lignes > 0
begin
  print 'Contrat avec plusieurs taux ou dont la somme est différente de 100! lignes %1!',@lignes
  select distinct
   DOBJECT_ID=convert(varchar,a.SSD_CF)+'-'+convert(varchar,a.ESB_CF)+'-'+a.RETCTR_NF+'-'+convert(char(4),a.RTY_NF)
  ,NOTIFTYP_NT=@NOTIF_LOG
  ,USR_CF=t.COLVAL_LS
  ,NOTIFCONTEXT_LL='ANO RATE,TAUX'
   from #RETSAISON a, BREF..TBANTECL t
    where ((select count(*) from #RETSAISON b where a.RETCTR_NF=b.RETCTR_NF AND a.RTY_NF=b.RTY_NF) > 1 or (TAUX_1+TAUX_2+TAUX_3+TAUX_4) != 1)
      and t.COL_LS='ALERTUSER_CT'
      and convert(smallint,left(t.COLVAL_CT,4))=a.SSD_CF*100+a.ESB_CF
      and t.LAG_CF='E'
  select @erreur=@@error
  if @erreur!=0 return
end

if @lignes > 0
begin
  print 'suppression des Contrat avec plusieurs taux ou dont la somme est différente de 100!'
  delete #RETSAISON
    from #RETSAISON a
     where (select count(*) from #RETSAISON b where a.RETCTR_NF=b.RETCTR_NF AND a.RTY_NF=b.RTY_NF) > 1 
        or (TAUX_1+TAUX_2+TAUX_3+TAUX_4) != 1 
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 return
  print 'suppression des Contrat avec plusieurs taux ou dont la somme est différente de 100!, lignes %1!',@lignes
end

----------------- anomalie mais pas demandée en sortie, donc en commentaire pour le moment
select @lignes=count(*) from #RETSAISON where RTY_NF!=year(isnull(CTRINCUWY_D,dateadd(day,1,dateadd(year,-1,CTREXP_D))))
       or isnull(CTRINCUWY_D,dateadd(day,1,dateadd(year,-1,CTREXP_D))) >= isnull(CTREXP_D, dateadd(day,-1,dateadd(year,1,CTRINCUWY_D)))
--if @p_ANO_B=1 and @lignes > 0
--begin
--  print 'sortie de contrat en anomalie sur les date d''effet et fin, lignes %1!',@lignes
--  select distinct
--   DOBJECT_ID=convert(varchar,a.SSD_CF)+'-'+convert(varchar,a.ESB_CF)+'-'+a.RETCTR_NF+'-'+convert(char(4),a.RTY_NF)
--  ,NOTIFTYP_NT=@NOTIF_LOG
--  ,USR_CF=t.COLVAL_LS
--  ,NOTIFCONTEXT_LL='ANO DATES - '+isnull(convert(char(10),CTRINCUWY_D,111),'null')+' - '+isnull(convert(char(10),CTREXP_D,111),'null')
--   from #RETSAISON a, BREF..TBANTECL t
--    where (RTY_NF!=year(isnull(CTRINCUWY_D,dateadd(day,1,dateadd(year,-1,CTREXP_D))))
--           or isnull(CTRINCUWY_D,dateadd(day,1,dateadd(year,-1,CTREXP_D))) >= isnull(CTREXP_D, dateadd(day,-1,dateadd(year,1,CTRINCUWY_D))))
--      and t.COL_LS='ALERTUSER_CT'
--      and convert(smallint,left(t.COLVAL_CT,4))=a.SSD_CF*100+a.ESB_CF
--      and t.LAG_CF='E'
--  select @erreur=@@error
--  if @erreur!=0 return
--end
if @lignes > 0
begin
  delete #RETSAISON
    where RTY_NF!=year(isnull(CTRINCUWY_D,dateadd(day,1,dateadd(year,-1,CTREXP_D))))
       or isnull(CTRINCUWY_D,dateadd(day,1,dateadd(year,-1,CTREXP_D))) >= isnull(CTREXP_D, dateadd(day,-1,dateadd(year,1,CTRINCUWY_D)))
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 return
  print 'sortie de contrat en anomalie sur les date d''effet et fin, lignes %1!',@lignes
end


if @p_ANO_B=1 and @p_LOG_B=0
begin
  print 'Fin de la recherche des anomalies'
  return
end

Select
  f.SSD_CF
 ,f.RETCTR_NF
 ,f.RTY_NF
 ,f.PRMDUECUR_CF
 ,c.CTRINCUWY_D
 ,c.CTREXP_D
 ,c.TAUX_1
 ,c.TAUX_2
 ,c.TAUX_3
 ,c.TAUX_4 
 ,TRIMESTRESCTR_N
 ,TRIMESTRESFIN_N
 ,TRIMESTRESCLO_N
 ,RETPRMULT_M=sum(f.PRMDUE_M)
 ,PRMRATIO_R=convert(decimal(12,8),null)
 ,PRMCLO_R=convert(decimal(12,8),null)
 ,PRMCLO_M=convert(decimal(15,3),null)
into #RETFAMPRM
 from BRET..TRFAMPRM f, (select RETCTR_NF,RTY_NF,CTRINCUWY_D,CTREXP_D,TAUX_1,TAUX_2,TAUX_3,TAUX_4
 ,TRIMESTRESCTR_N=dbo.FtCompTrimestreRetro(CTRINCUWY_D,CTREXP_D,RTY_NF,'ctr',null)
 ,TRIMESTRESFIN_N=dbo.FtCompTrimestreRetro(CTRINCUWY_D,CTREXP_D,RTY_NF,'fin',null)
 ,TRIMESTRESCLO_N=dbo.FtCompTrimestreRetro(CTRINCUWY_D,CTREXP_D,RTY_NF,'clo',@ICLODAT_D)
                          from #RETSAISON) c
  where f.RETCTR_NF = c.RETCTR_NF
    and f.RTY_NF = c.RTY_NF
group by f.SSD_CF,f.RETCTR_NF,f.RTY_NF,f.PRMDUECUR_CF,c.CTRINCUWY_D,c.CTREXP_D,TAUX_1,TAUX_2,TAUX_3,TAUX_4
        ,TRIMESTRESCTR_N,TRIMESTRESFIN_N,TRIMESTRESCLO_N
order by f.SSD_CF,f.RETCTR_NF,f.RTY_NF,f.PRMDUECUR_CF,c.CTRINCUWY_D,c.CTREXP_D,TAUX_1,TAUX_2,TAUX_3,TAUX_4
        ,TRIMESTRESCTR_N,TRIMESTRESFIN_N,TRIMESTRESCLO_N
select @erreur=@@error,@lignes=@@rowcount
if @erreur!=0 return
print 'Table des ultimes de BRET..TRFAMPRM, lignes %1!',@lignes

select 
   SSD_CF
  ,ESB_CF
  ,RETCTR_NF
  ,RTY_NF
  ,RETCUR_CF=CUR_CF
  ,RETAMT_M=sum(TRN_M) --la prime émise (PRMBooked)
into #RETACC
 from (
        select
          a.SSD_CF
         ,c.ESB_CF
         ,a.CUR_CF
         ,a.TRN_M
         ,a.RETCTR_NF
         ,a.RTY_NF
--         ,RETACY_NF=RETACCYER_NF
         from BRET..TACCTRAI a, #RETSAISON c
          where TRNCOD_CF like '2_10110_' --primes retro
            and a.RETCTR_NF=c.RETCTR_NF
            and a.RTY_NF=c.RTY_NF
            and a.SSD_CF=c.SSD_CF
            and a.ACC_D <= @ICLODAT_D
        union all
        select
          a.SSD_CF
         ,c.ESB_CF
         ,a.CUR_CF
         ,a.TRN_M
         ,a.RETCTR_NF
         ,a.RTY_NF
--         ,RETACY_NF=year(@ICLODAT_D)
         from BRET..TOUTTRAI a, #RETSAISON c
          where TRNCOD_CF like '2_10110_' --primes retro
            and a.RETCTR_NF=c.RETCTR_NF
            and a.RTY_NF=c.RTY_NF
            and a.SSD_CF=c.SSD_CF
            and a.LSTUPD_D <= @ICLODAT_D
       ) a
group by SSD_CF,ESB_CF,RETCTR_NF,RTY_NF,CUR_CF--,RETACY_NF
order by SSD_CF,ESB_CF,RETCTR_NF,RTY_NF,CUR_CF--,RETACY_NF
select @erreur=@@error,@lignes=@@rowcount
if @erreur!=0 return
print 'table des mouvement comptable de prime rétro comme transaction code 2_10110_, lignes %1!',@lignes

print 'Ajustement du taux par trimestre dont le total sera different de 100 pourcent pour les contrat de plus ou moins de 1 an'
print ' pour obtenir in fine un total de 100 pourcent pour les taux du contrat'
print 'et ainsi calculer correctement sur les trimetres échu via la clodat le bon taux à multiplier avec l''ultime de BRET..TRFAMPRM'
print''

update #RETFAMPRM
 set PRMRATIO_R=round(case when TRIMESTRESCTR_N < 4 then 1 / (TAUX_1 + case when TRIMESTRESCLO_N >=2 then TAUX_2 else 0 end + case when TRIMESTRESCLO_N >=3 then TAUX_3 else 0 end )
                           when TRIMESTRESCTR_N = 4 then 1
                     -- les 4 premiers Taux devant faire 1 sinon erreur on mets 1 à la place de l'addition des 4 taux 
                           when TRIMESTRESCTR_N > 4 then 1 /( 1 + (@TAUX_DEFAUT * (TRIMESTRESCTR_N - 4)) ) end,8)
select @erreur=@@error,@lignes=@@rowcount
if @erreur!=0 return
print 'maj du taux de taux de lissage des taux sur la durée du contrat, 1 an ou moins fait un taux de 100 pourcent'
print 'table des Taux pour les 4 trimestre du contrat, lignes %1!',@lignes

update #RETFAMPRM
  set PRMCLO_R=round(PRMRATIO_R * TAUX_1 
                       + case when TRIMESTRESCLO_N >=2 then PRMRATIO_R * TAUX_2 else 0 end 
                       + case when TRIMESTRESCLO_N >=3 then PRMRATIO_R * TAUX_3 else 0 end 
                       + case when TRIMESTRESCLO_N >=4 then PRMRATIO_R * TAUX_4 else 0 end 
                       + case when TRIMESTRESCLO_N >=5 then PRMRATIO_R * @TAUX_DEFAUT * (TRIMESTRESCLO_N - 4) else 0 end,8)
select @erreur=@@error,@lignes=@@rowcount
if @erreur!=0 return
print 'maj du taux de prime ultime gagnée à la clodat, RatePrmEarned, lignes %1!',@lignes

update #RETFAMPRM
 set PRMCLO_M=round(PRMCLO_R * RETPRMULT_M,3)
select @erreur=@@error,@lignes=@@rowcount
if @erreur!=0 return
print 'maj du montant de prime ultime gagnée à la clodat, la prime acquise (RatePrmEarned * Aliment), lignes %1!',@lignes


/*
12 Subsidiary 									SSD_CF
2_10110_Subledger 								ESB_CF
30465Contracti 									RETCTR_NF
4Section 										RETSEC_NF
5Underwriting year 								RTY_NF
6Currency 										RETCUR_CF
71Contract inception datetime 					CTRINCUWY_D
8Contract expiry datetime 						CTREXP_D
9Closing datetime 								CLODAT_D
100Ratio 1st QUARTER 							TAUX_1
11Ratio 2nd QUARTER 							TAUX_2
12Ratio 3rd QUARTER 							TAUX_3
13Ratio 4th QUARTER 							TAUX_4
14Number of trimester until contract expiration TRIMESTRESFIN_N
15Number of quarter until closing datetime 		TRIMESTRESCLO_N
16Ratio 										PRMRATIO_R
17Ratio sum between inception dt and closing dt PRMCLO_R
18Ultimate premium 								RETPRMULT_M
19Earned premium 								RETPRMULT_MPRMCLO_M
2015Booked premiumRETPRMULT_M(c) 				RETAMT_M
21410002PNA 									PNA_M

*/

if @p_LOG_B=1
begin 
	print " sortie des logs PNA RETRO"
select 
   c.SSD_CF
  ,c.ESB_CF
  ,a.RETCTR_NF
  ,RETSEC_NF=1
  ,a.RTY_NF
  ,c.RETCUR_CF
  ,a.CTRINCUWY_D  
  ,a.CTREXP_D
  ,CLODAT=convert(char(8),@p_CLODAT_D,103)
  ,a.TAUX_1
  ,a.TAUX_2
  ,a.TAUX_3
  ,a.TAUX_4 
  ,a.TRIMESTRESFIN_N
  ,a.TRIMESTRESCLO_N
  ,a.PRMRATIO_R
  ,a.PRMCLO_R 
  ,a.RETPRMULT_M
  ,a.PRMCLO_M 
  ,c.RETAMT_M
  ,PNA_M= a.PRMCLO_M - c.RETAMT_M
 from #RETFAMPRM a, #RETACC c
   where a.RETCTR_NF = c.RETCTR_NF
     and a.RTY_NF = c.RTY_NF
     and a.PRMDUECUR_CF = c.RETCUR_CF
     and c.RETAMT_M > a.PRMCLO_M
     and abs(a.PRMCLO_M - c.RETAMT_M) > @SEUIL_PNA
order by RETCTR_NF,RTY_NF,RETCUR_CF
return 
end 

print 'résultat final'
select 
   c.SSD_CF
  ,c.ESB_CF
  ,BALSHEY_NF=year(@p_CLODAT_D)
  ,BALSHRMTH_NF=month(@p_CLODAT_D)
  ,BALSHRDAY_NF=day(@p_CLODAT_D)
  ,TRNCOD_CF=@TRNCOD_PNA
  ,DBLTRNCOD_CF=@DBLTRNCOD_PNA
  ,CTR_NF=null
  ,END_NT=null
  ,SEC_NF=null
  ,UWY_NF=null
  ,UW_NT=null
  ,OCCYEA_NF=year(@p_CLODAT_D)                  --Modif 3
  ,ACY_NF=year(@p_CLODAT_D)                       --Modif 3
  ,SCOSTRMTH_NF=month(@p_CLODAT_D)         --Modif 3
  ,SCOENDMTH_NF=month(@p_CLODAT_D)         --Modif 3
  ,CLM_NF=null
  ,c.RETCUR_CF
  ,AMT_M=(a.PRMCLO_M - c.RETAMT_M) * -1 -- on mets aussi ici les PNA retro ??  
  ,CED_NF=null
  ,BRK_NF=null
  ,PAY_NF=null
  ,KEY_NF=null
  ,a.RETCTR_NF
  ,RETEND_NT=0
  ,RETSEC_NF=1
  ,a.RTY_NF
  ,RETUW_NT=1
  ,RETOCCYEA_NF=year(@p_CLODAT_D)            --Modif 3
  ,RETACY_NF=year(@p_CLODAT_D)                 --Modif 3    -- comment on gère l'année de compte ??? exercice ??
  ,RETSCOSTRMTH_NF=month(@p_CLODAT_D)   --Modif 3
  ,RETSCOENDMTH_NF=month(@p_CLODAT_D)   --Modif 3
  ,RCL_NF=null
  ,c.RETCUR_CF
  ,RETAMT_M=(a.PRMCLO_M - c.RETAMT_M) * -1
  ,PLC_NT=null
  ,RTO_NF=null
  ,INT_NF=null
  ,RETPAY_NF=null
  ,RETKEY_CF=null
  ,RETINTAMT_M=null
  ,BUKRS_CF=null
  ,RCOMP_CF=null
  ,LDGRP_CF=null
  ,HKONT_CF=null
  ,DBLHKONT_CF=null
  ,GJAHR_NF=null
  ,MONAT_NF=null
  ,VBUND_CF=null
  ,ZZCED_NF=null
  ,SEGMENT_CF=null
  ,BEWAR_CF=null
  ,ZZGAAPDIF_CF=null
  ,BLART_CF=null
  ,ZZRECONKEY_CF=null
  ,TRN_NT=null
  ,ORICOD_LS=null
  ,RETROAUTO_B=null
  ,SPEENTNAT_CT	=null
  ,EVT_NF=null
  ,REVT_NF=null
  ,RETARDRETINT_B=null
  ,NEWCOLS1_NF=null
  ,NEWCOLS2_NF=null
  ,NEWCOLS3_NF=null
  ,NEWCOLS4_NF=null
  ,NEWCOLS5_NF=null
  ,NEWCOLS6_NF=null
  ,NEWCOLS7_NF=null
  ,NEWCOLS8_NF=null
  ,NEWCOLS9_NF=null
 from #RETFAMPRM a, #RETACC c
   where a.RETCTR_NF = c.RETCTR_NF
     and a.RTY_NF = c.RTY_NF
     and a.PRMDUECUR_CF = c.RETCUR_CF
     and c.RETAMT_M > a.PRMCLO_M
     and abs(a.PRMCLO_M - c.RETAMT_M) > @SEUIL_PNA
order by RETCTR_NF,RTY_NF,RETCUR_CF
go
EXEC sp_procxmode 'dbo.PsACCRET_01', 'unchained'
go
IF OBJECT_ID('dbo.PsACCRET_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsACCRET_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsACCRET_01 >>>'
go
GRANT EXECUTE ON dbo.PsACCRET_01 TO GCONSULT
go
GRANT EXECUTE ON dbo.PsACCRET_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsACCRET_01 TO GDBBATCH
go
