use BEST
go
if object_id('dbo.PsFPATTERNSII_01') is not null
begin
  drop PROC dbo.PsFPATTERNSII_01
  print '<<< DROPPED PROC dbo.PsFPATTERNSII_01 >>>'
end
go
create procedure PsFPATTERNSII_01
  (
  @p_TYPE_FICHIER varchar(7) -- DSC / CUM / INF /ICV / BDT / DSI / DSI_DSC
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur:
Date de creation: 05/06/2012
Description du programme: :spot:23390 Génération du fichier FPATTERNSII (SOLVENCY)
Conditions d'execution: asynchrone ESID0106
Commentaires:
_________________
MODIFICATIONS
1 10/10/2012 Florent :spot:24041 Sélection de tous les type de PATCAT_CT
2 07/08/2013 -=Dch=- :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
3 08/10/2014 Florent :spot:27789 pas de centralisation pour cette proc, on supprime la modif 2
4 04/05/2016 Florent :spot:30535 pour les patterns DSC, CUM, INF, ICV on ne sort plus de lignes pour le dédoublonneur
5 09/05/2016 Florent :spot:30543 on passe à 65 années et gestion du cas de sélection des DSC
                                 le dédoublement des PATTERNS est suspendu pour les DSC,CUM,INF,ICV
6 18/05/2017 Florent :spira:21416 corrections pour DSI lors de maj ratio LOB SII
7 07/12/2020 KBagwe  :spira:89731 PROD- Issue when loading Bad debt ratio 
*****************************************************/
declare
 @SQL_REF    varchar(2000)
,@maintenant datetime
,@clodat_d   datetime
,@per_cf     char(3)
,@BALSHEY_NF char(4)
,@erreur     int
,@PER_DSI_D  datetime

select @maintenant=getdate()
-- récupérer la date bilan en cours de l'EBS pour les types CUM et ICV et sélectionner dans cette année bilan car ces patterns ne sont valide que pour l'année bilan en cours
-- 1 pour exec par le batch
exec @erreur=BREF..PsCALEND_EBS @maintenant,1,@clodat_d output, @per_cf output
if @erreur!=0 or @@error!=0 return 999

select @BALSHEY_NF=convert(char(4),year(@clodat_d))

-- avec un changement de TLOBSII il faut recalculer les DSI de la période courante uniquement
if @p_TYPE_FICHIER in('DSI_DSC','DSI')
begin
  -- le fichier de discount est caractérisé par une SEULE date de création, c'est le moment de l'importation du fichier DSC
  select @PER_DSI_D=max(PATTERN_CRE_D) from (select PATTERN_CRE_D=(select CRE_D from TPATTERNSII b
                  where a.ORIPATCAT_CT = b.PATCAT_CT
                    and a.ORIPATTERN_ID = b.PATTERN_ID
                    and a.ORIPATTYP_CT  = b.PATTYP_CT
                    and ISNULL(a.SSD_CF,0) = ISNULL(b.SSD_CF, 0)
					and ISNULL(a.ESB_CF,0) = ISNULL(b.ESB_CF, 0)
                    and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                    and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'') )
   from TPATSEGSII a
    where PATCAT_CT='DSC'
      and CLODAT_D=@clodat_d
      and PER_CF=@per_cf) a
end


if @p_TYPE_FICHIER NOT IN('BDT')
begin
-- implémentation d'une sélection spécifique pour le DSC car le calcul se fait sur les DSC et ILL ensemble inséparable et par date d'importation du DSC: CRE_D
select @SQL_REF="
select distinct SSD_CF,rtrim(PATCAT_CT),rtrim(PATTYP_CT),SEG_NF,UWY_NF,CUR_CF,LOB_CF,RATING_CF,NORME_CF,rtrim(SEGNAT_CT)
        ,BALSHEY_NF,PATTERN_ID
        ,CRE_D=convert(char(8),CRE_D,112)+' '+ convert(char(8),CRE_D,8)+ substring(convert(char(27),CRE_D,109),21,4)
        ,CREUSR_CF
        ,TOTAUX
        ,AN1,AN2,AN3,AN4,AN5,AN6,AN7,AN8,AN9,AN10,AN11,AN12,AN13,AN14,AN15,AN16,AN17,AN18,AN19,AN20
        ,AN21,AN22,AN23,AN24,AN25,AN26,AN27,AN28,AN29,AN30,AN31,AN32,AN33,AN34,AN35,AN36,AN37,AN38,AN39,AN40
        ,AN41,AN42,AN43,AN44,AN45,AN46,AN47,AN48,AN49,AN50,AN51,AN52,AN53,AN54,AN55,AN56,AN57,AN58,AN59,AN60
        ,AN61,AN62,AN63,AN64,AN65
 from TPATTERNSII a
  where PATCAT_CT='"+case when @p_TYPE_FICHIER in('DSI','DSI_DSC') then "DSC" else @p_TYPE_FICHIER end+"'
      "+case when @p_TYPE_FICHIER in('DSI_DSC','DSI') then "and CRE_D='"+convert(varchar,@PER_DSI_D,109)+"'" else "" end+"
      "+case when @p_TYPE_FICHIER in('DSI','INF') then "and PATTYP_CT='"+@p_TYPE_FICHIER+"'"
             when @p_TYPE_FICHIER in('CUM','ICV') then "and BALSHEY_NF="+@BALSHEY_NF
             when @p_TYPE_FICHIER in('DSC','DSI_DSC') then "and PATTYP_CT in('DSC','ILL') and exists(select 1 from TPATTERNSII b
              where a.PATCAT_CT=b.PATCAT_CT and a.CUR_CF=b.CUR_CF and a.NORME_CF=b.NORME_CF and a.CRE_D=b.CRE_D 
              and ISNULL(a.SSD_CF,0) = ISNULL(b.SSD_CF, 0) and ISNULL(a.ESB_CF,0) = ISNULL(b.ESB_CF, 0)
                and b.PATTYP_CT=case when a.PATTYP_CT='DSC' then 'ILL' else 'DSC' end)"
             else "" end+"
    and @p_TYPE_FICHIER not in('DSC','CUM','INF','ICV', 'BDT')
order by SSD_CF,PATCAT_CT,PATTYP_CT,SEG_NF,CUR_CF,LOB_CF,NORME_CF"

END
ELSE				--MOD07
BEGIN
select @SQL_REF="select distinct a.SSD_CF,rtrim(a.PATCAT_CT),rtrim(a.PATTYP_CT),a.SEG_NF,a.UWY_NF,a.CUR_CF,a.LOB_CF,a.RATING_CF,a.NORME_CF,rtrim(a.SEGNAT_CT)
        ,a.BALSHEY_NF,a.PATTERN_ID
        ,CRE_D=convert(char(8),a.CRE_D,112)+' '+ convert(char(8),a.CRE_D,8)+ substring(convert(char(27),a.CRE_D,109),21,4)
        ,a.CREUSR_CF
        ,a.TOTAUX
        ,AN1,AN2,AN3,AN4,AN5,AN6,AN7,AN8,AN9,AN10,AN11,AN12,AN13,AN14,AN15,AN16,AN17,AN18,AN19,AN20
        ,AN21,AN22,AN23,AN24,AN25,AN26,AN27,AN28,AN29,AN30,AN31,AN32,AN33,AN34,AN35,AN36,AN37,AN38,AN39,AN40
        ,AN41,AN42,AN43,AN44,AN45,AN46,AN47,AN48,AN49,AN50,AN51,AN52,AN53,AN54,AN55,AN56,AN57,AN58,AN59,AN60
        ,AN61,AN62,AN63,AN64,AN65 
from TPATTERNSII a , TPATSEGSII b
  where a.PATCAT_CT='BDT'
and a.PATCAT_CT = b.PATCAT_CT
and a.PATTERN_ID = b.PATTERN_ID
and b.SEG_NF = a.RATING_CF 
and ISNULL(a.NORME_CF,'') = ISNULL(b.NORME_CF,'') 
and b.PER_CF = @per_cf 
and b.CLODAT_D=@clodat_d
and ISNULL(a.SSD_CF,0) = ISNULL(b.SSD_CF, 0)
and ISNULL(a.ESB_CF,0) = ISNULL(b.ESB_CF, 0)
order by a.SSD_CF,A.ESB_CF,a.PATCAT_CT,a.PATTYP_CT,a.SEG_NF,a.CUR_CF,a.LOB_CF,a.NORME_CF"


END


exec (@SQL_REF)
if @@error!=0 select @SQL_REF
go
if object_id('dbo.PsFPATTERNSII_01') is not null
  print '<<< CREATED PROC dbo.PsFPATTERNSII_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFPATTERNSII_01 >>>'
go
grant execute on dbo.PsFPATTERNSII_01 TO GOMEGA
go
grant execute on dbo.PsFPATTERNSII_01 TO GDBBATCH
go
