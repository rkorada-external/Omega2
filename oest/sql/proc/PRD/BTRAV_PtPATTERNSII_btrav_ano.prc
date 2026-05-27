USE BEST
go
IF OBJECT_ID('dbo.PtPATTERNSII_btrav_ano') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtPATTERNSII_btrav_ano
    IF OBJECT_ID('dbo.PtPATTERNSII_btrav_ano') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtPATTERNSII_btrav_ano >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtPATTERNSII_btrav_ano >>>'
END
go
create procedure PtPATTERNSII_btrav_ano
  (
  @p_LAG_CF       ULAG_CF='F'
 ,@p_SSD_CF       USSD_CF
 ,@p_CRE_D        UUPD_D
 ,@p_CREUSR_CF    UUPDUSR_CF
 ,@p_lignes       int=0
 ,@p_visu_ano     bit=0
 ,@p_type_fichier char(3) -- DSC Illiquidity/Discount ou CUM cumulative ou ICV incurred
 ,@p_batch        bit=0  -- demande de fabrication du fichier pour le ESID0821.cmd
  )
with execute as caller as
/***************************************************
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : Florent
Date de creation         : 16/04/2012
Description du programme : :spot:23390 SOLVENCY II
Conditions d'execution :
Commentaires : cette proc est exécutée par le TP pour 2 objectifs:
                1 - Vérification du fichier monté en table et si erreur sélection des anomalies alors exec avec @p_visu_ano=0 et @p_batch=0
                      et si ok exécution de l'asinchrone pour faire le fichier pour le ESID0821.cmd
                2 - Visualisation des dernières anomalies pour le user et filiale : @p_visu_ano=1 et @p_batch=0
               Et pour le batch revérification si anomalies et si ok sélection des lignes pour le fichier du ESID0821.cmd
_________________
MODIFICATIONS
1 Florent 17/08/2012 :spot:24041 Solvency II, vérif sur les devises de références dans TBANALL, controle LOB et Segment *
2 KBagwe 11/06/2013 Modification for obsolete table BREF..TLOBH -> BREF..TLOBL
                    Removed dbo and added 'with execute as caller as'
3 20/03/2014 Cyrille Despret :spot:25427 - Suppression de quotes (') qui entourent la chaine de caractères @s_CRE_D. Le Daemon met les chaines entre "" depuis la 1B. 
4 17/09/2014 CHARRIER Alexis: Defect: - Added a union statement for case p_batch = 0 to retrieve SII06B Solvency Life Cash flows anomalies
*****************************************************/
declare
  @erreur      int
 ,@lignes      int
 ,@lignes_load int
 ,@VRS_NF      numeric(10,0)
 ,@s_SSD_CF    varchar(30)
 ,@s_CRE_D     varchar(30)
 ,@s_lignes    varchar(30)
 ,@clodat_d    datetime
 ,@per_cf      char(3)
 ,@s_clodat_d  char(8)

select @lignes=0 --lignes en erreur

-- demande uniquement la sélection des anomalies d'un précédent traitement
if @p_visu_ano=1 goto visu_ano

-- recherche de la version NON COMPTABILISÉE pour la filiale
select @VRS_NF=a.VRS_NF
 from TVERPAR a
  where a.SEGTYP_CT='A'
 and SSD_CF=@p_SSD_CF
 and exists(SELECT 1 from TVERSION b where b.SEGTYP_CT='A' and b.VRSSTS_CT<>'AN' and b.VRSLOC_B=0 and a.SSD_CF=b.SSD_CF and a.VRS_NF=b.VRS_NF)
having PAR_D=max(PAR_D)
if @@error!=0 return 999

-- on delete les anomalies du traitement précédent
delete TCTRANO where SEG_NF=@p_CREUSR_CF and SSD_CF=@p_ssd_cf and SEGTYP_CT='S'

-- 1 pour exec par le batch
exec @erreur=BREF..PsCALEND_EBS @p_CRE_D,1,@clodat_d output, @per_cf output
if @erreur!=0 or @@error!=0 return 999

-- on vérifie les lignes
select @lignes_load=(select count(*) from BTRAV..EST_ESID0821_TPATTERNSII where CRE_D=@p_CRE_D  and CREUSR_CF=@p_CREUSR_CF)
if @p_lignes!=@lignes_load
begin
  insert into TCTRANO
   --CTR_NF,END_NT,SEC_NF,VRS_NF,SSD_CF,SEGTYP_CT,SEG_NF,ANO_CT,NUMLINE_NT,UWY_NF,ACY_NF
  select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,80,0,@p_lignes,@lignes_load
  select @erreur=@@error, @lignes=@@rowcount
  if @erreur!=0 return 999
end

-- formatage des champs caractères en majuscules
update BTRAV..EST_ESID0821_TPATTERNSII
 set SEG_NF=upper(SEG_NF)
    ,LOB_CF=case when LOB_CF not in (null,'*') then right('0'+LOB_CF,2) else LOB_CF end-- pour s'assurer que la LOB a toujours 2 chiffres -- modif 1
    ,CUR_CF=upper(CUR_CF)
    ,NORME_CF=upper(NORME_CF)
    ,PATTYP_CT=upper(PATTYP_CT)
  where CRE_D=@p_CRE_D
    and CREUSR_CF=@p_CREUSR_CF
    and PATCAT_CT=@p_type_fichier
select @erreur=@@error
if @erreur!=0 return 999

insert into TCTRANO
select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,87,LIGNE_N,0,0
 from BTRAV..EST_ESID0821_TPATTERNSII a
  where CRE_D=@p_CRE_D
    and CREUSR_CF=@p_CREUSR_CF
    AND AN40!=1.0
    and PATCAT_CT=@p_type_fichier
    and @p_type_fichier in('ICV','CUM')
select @erreur=@@error, @lignes=@lignes+@@rowcount
if @erreur!=0 return 999

if @p_type_fichier!='ICV'
begin

  if @p_type_fichier='CUM'
  begin
    insert into TCTRANO
    select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,88,LIGNE_N,0,0
     from BTRAV..EST_ESID0821_TPATTERNSII a
      where ((LOB_CF!=null and SEG_NF!=null) or (LOB_CF=null and SEG_NF=null))
        and CRE_D=@p_CRE_D
        and CREUSR_CF=@p_CREUSR_CF
        and PATCAT_CT=@p_type_fichier
        and PATCAT_CT='CUM'
    select @erreur=@@error, @lignes=@lignes+@@rowcount
    if @erreur!=0 return 999
  end

  insert into TCTRANO
  select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,82,LIGNE_N,0,0
   from BTRAV..EST_ESID0821_TPATTERNSII a
    where SSD_CF!=null
      and LOB_CF!=null
      and not (@p_type_fichier='CUM' and LOB_CF='*') -- modif 1
      and CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and PATCAT_CT=@p_type_fichier
      and not exists(select 1 from BREF..TLOBL b where a.LOB_CF=b.LOB_CF and b.LAG_CF = @p_LAG_CF)
  select @erreur=@@error, @lignes=@lignes+@@rowcount
  if @erreur!=0 return 999

  insert into TCTRANO
  select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,81,LIGNE_N,0,0
   from BTRAV..EST_ESID0821_TPATTERNSII a
    where SSD_CF=null
      and LOB_CF!=null
      and not (@p_type_fichier='CUM' and LOB_CF='*') -- modif 1
      and CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and PATCAT_CT=@p_type_fichier
      and not exists(select 1 from BREF..TLOB b where a.LOB_CF=b.LOB_CF)
  select @erreur=@@error, @lignes=@lignes+@@rowcount
  if @erreur!=0 return 999

  insert into TCTRANO
  select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,84,LIGNE_N,0,0
   from BTRAV..EST_ESID0821_TPATTERNSII a
    where CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and NORME_CF!=null
      and PATCAT_CT=@p_type_fichier
      and not exists(select 1 from BREF..TBANAL b where b.COL_LS='NORME_CF' and b.COLVAL_CT=a.NORME_CF)
  select @erreur=@@error, @lignes=@lignes+@@rowcount
  if @erreur!=0 return 999

  insert into TCTRANO
  select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,83,LIGNE_N,0,0
   from BTRAV..EST_ESID0821_TPATTERNSII a
    where CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and PATCAT_CT=@p_type_fichier
      and not exists(select 1 from BREF..TBANTEC b where b.COL_LS='PATTYP_CT' and b.COLVAL_CT!='ICV' and b.COLVAL_CT=a.PATTYP_CT)
  select @erreur=@@error, @lignes=@lignes+@@rowcount
  if @erreur!=0 return 999

  insert into TCTRANO
  select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,85,LIGNE_N,0,0
   from BTRAV..EST_ESID0821_TPATTERNSII a
    where CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and CUR_CF!=null
      and PATCAT_CT=@p_type_fichier
      and not exists(select 1 from BREF..TBANAL b where b.COL_LS='GRPCUR_CF' and b.COLVAL_CT=a.CUR_CF) -- modif 1
  select @erreur=@@error, @lignes=@lignes+@@rowcount
  if @erreur!=0 return 999

  insert into TCTRANO
  select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),isnull(@VRS_NF,-1),@p_SSD_CF,'S',@p_CREUSR_CF,86,LIGNE_N,0,0
   from BTRAV..EST_ESID0821_TPATTERNSII a
    where CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and SEG_NF!=null
      and not (@p_type_fichier='CUM' and SEG_NF='*') -- modif 1
      and PATCAT_CT=@p_type_fichier
      and not exists(select 1 from TSEGMENT b where b.SEG_NF=a.SEG_NF and b.VRS_NF=@VRS_NF)
  select @erreur=@@error, @lignes=@lignes+@@rowcount
  if @erreur!=0 return 999

  if @p_type_fichier='DSC'
  begin
    insert into TCTRANO
    select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,89,LIGNE_N,0,0
     from BTRAV..EST_ESID0821_TPATTERNSII a
      where CRE_D=@p_CRE_D
        and CREUSR_CF=@p_CREUSR_CF
        and PATCAT_CT=@p_type_fichier
        and PATCAT_CT='DSC'
        and not exists(select 1 from BTRAV..EST_ESID0821_TPATTERNSII b where a.CREUSR_CF=b.CREUSR_CF and a.PATCAT_CT=b.PATCAT_CT
                        and b.PATTYP_CT=case when a.PATTYP_CT='DSC' then 'ILL' else 'DSC' end
                        and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'') and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,''))
    select @erreur=@@error, @lignes=@lignes+@@rowcount
    if @erreur!=0 return 999
  end

end

visu_ano:
if @p_batch=0
 --gestion spécifique pour l'erreur du nombres de lignes attendues
  select PATCAT_CT
    ,PATCAT_LS=(select COLVAL_LS from BREF..TBANTECL y where t.PATCAT_CT=y.COLVAL_CT and COL_LS='PATCAT_CT' and LAG_CF=@p_LAG_CF)
    ,LIGNE=a.NUMLINE_NT,COLONNE=b.COLVAL_LS
    ,ANOMALIE=b.COLVAL_LM+case when a.ANO_CT=80 then ': '+convert(varchar(5),a.UWY_NF)+'/'+convert(varchar(5),a.ACY_NF)
                               when a.ANO_CT in(81,82) then ': '+ t.LOB_CF
                               when a.ANO_CT=83 then ': '+ t.PATTYP_CT
                               when a.ANO_CT=84 then ': '+ t.NORME_CF
                               when a.ANO_CT=85 then ': '+ t.CUR_CF
                               when a.ANO_CT=86 then ': '''+ t.SEG_NF +''' version '+convert(char(10),VRS_NF)
                               when a.ANO_CT=87 then ': '+ convert(char(10),t.AN40)
                               when a.ANO_CT=88 then ': LOB '''+ isnull(LOB_CF,'') + ''' Segment ''' + isnull(t.SEG_NF,'') + ''''
                               when a.ANO_CT=89 then ': '+isnull(CUR_CF,'')+'/'+isnull(NORME_CF,'')+'/'+PATTYP_CT
                               else '' end
        ,CRE_D=case when @p_CRE_D=null then dateadd(minute,sec_nf,dateadd(hour,end_nt,convert(datetime,CTR_NF))) else @p_CRE_D end
   from TCTRANO a, BREF..TBANTECL b, BTRAV..EST_ESID0821_TPATTERNSII t
   where a.SSD_CF=@p_SSD_CF
     and a.SEGTYP_CT='S'
     and a.SEG_NF=@p_CREUSR_CF
     and b.LAG_CF=@p_LAG_CF
     and a.ANO_CT=convert(int,b.COLVAL_CT)
     and b.COL_LS='ANO_CT'
     and a.SEG_NF=t.CREUSR_CF
     and a.NUMLINE_NT=t.LIGNE_N
     --[004] 
	 and t.CRE_D like case when (@p_CRE_D=null and ISNUMERIC(CTR_NF)=1) then dateadd(minute,sec_nf,dateadd(hour,end_nt,convert(datetime,CTR_NF))) else @p_CRE_D end
     and t.CREUSR_CF=@p_CREUSR_CF
	-- [004] SII06b : Select Solvency II Life cash flows anomalies 
	UNION
		SELECT  PATCAT_CT = NULL,
				PATCAT_LS = NULL,
				LIGNE = T1.NUMLINE_NT,
				COLVAL_LS = CASE WHEN T2.COLVAL_LS = NULL THEN CONVERT (VARCHAR, T1.ANO_CT)  ELSE T2.COLVAL_LS END,
				ANOMALIE = (CASE WHEN T2.COLVAL_LM = NULL THEN CONVERT (VARCHAR, T1.ANO_CT)  ELSE T2.COLVAL_LM END) + 
                        Case	when T1.ANO_CT = 90 then ': '+ CONVERT(VARCHAR ,T1.SSD_CF)
								when T1.ANO_CT = 2 then ': ' + T3.CTR_NF + '/ ' + convert(varchar(5),T3.SEC_NF) + '/ ' + convert(varchar(5),T3.UWY_NF)
								when T1.ANO_CT = 91 then ': ' + T3.CTR_NF + '/ ' + convert(varchar(5),T3.SEC_NF) + '/ ' + convert(varchar(5),T3.UWY_NF)
								when T1.ANO_CT = 47 then ': ' + T3.CTR_NF + '/ ' + convert(varchar(5),T3.SEC_NF) + '/ ' + convert(varchar(5),T3.UWY_NF)
								when T1.ANO_CT = 85 then ': ' + isnull(T3.CUR_CF,'')
								when T1.ANO_CT = 92 then ': ' + convert(varchar(5),T3.ACMTRS_NT)
								else '' end,
				CRE_D = NULL
		FROM BEST..TCTRANO T1 LEFT OUTER JOIN BREF..TBANTECL T2 ON T1.ANO_CT = convert(int,T2.COLVAL_CT) AND T2.COL_LS = 'ANO_CT' AND T2.LAG_CF = @p_LAG_CF,
				BTRAV..EST_ESID0841_SIICASHFLOWS T3
		WHERE T1.SSD_CF = @p_SSD_CF
			AND T1.SEG_NF = @p_CREUSR_CF
			AND T1.SEGTYP_CT = 'S'
			AND T1.SEG_NF = T3.CREUSR_CF
			AND T1.NUMLINE_NT = T3.LINE_N
			AND T3.CREUSR_CF = @p_CREUSR_CF
            AND T1.CTR_NF = T3.CTR_NF
            AND T1.SEC_NF = T3.SEC_NF

	-- [004] end modification
if @p_batch=1
begin
  -- retour avec anomalies pour le batch
  if @lignes > 0
  begin
    raiserror 35000 'Anomalies user %1!, date %2!',@p_CREUSR_CF,@p_CRE_D
    return 1
  end
  -- sélection du fichier pour le ESID0101
  select SSD_CF,rtrim(PATCAT_CT),rtrim(PATTYP_CT),SEG_NF,UWY_NF=null,CUR_CF,LOB_CF,RATING_CF=null,NORME_CF,SEGNAT_CT=null
        ,BALSHEY_NF=year(@clodat_d)
        ,PATTERN_ID=null,CRE_D=convert(char(8),CRE_D,112)+' '+ convert(char(8),CRE_D,8)+ substring(convert(char(27),CRE_D,109),21,4)
        ,CREUSR_CF,TOTAUX=null
        ,AN1,AN2,AN3,AN4,AN5,AN6,AN7,AN8,AN9,AN10,AN11,AN12,AN13,AN14,AN15,AN16,AN17,AN18,AN19,AN20
        ,AN21,AN22,AN23,AN24,AN25,AN26,AN27,AN28,AN29,AN30,AN31,AN32,AN33,AN34,AN35,AN36,AN37,AN38,AN39,AN40
   from BTRAV..EST_ESID0821_TPATTERNSII
    where CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and PATCAT_CT=@p_type_fichier
  order by SSD_CF,PATCAT_CT,PATTYP_CT,SEG_NF,CUR_CF,LOB_CF,NORME_CF
  if @@error!=0 return 1
end

-- on lance l'asynchrone si on vient du TP pour faire le fichier pour la chaîne des courbes de taux
if @lignes=0 and @p_batch=0 and @p_visu_ano=0
begin
  select
   @s_SSD_CF=convert(varchar(30),@p_SSD_CF)
   -- pour gérer les espaces, format SSAAMMJJ HH:MM:SS:mmm
   --[003] suppression des quotes (') qui entouraient la chaine de caracteres
  ,@s_CRE_D=convert(char(8),@p_CRE_D,112)+' '+ convert(char(12),@p_CRE_D,20)
  ,@s_clodat_d=convert(char(8),@clodat_d,112)
  ,@s_lignes=convert(varchar(30),@p_lignes)

  exec @erreur=BTEC..PiJOBQUEUE_02 'best11a',@p_CREUSR_CF,null
  -- paramètres du job
   ,@p_LAG_CF,@s_SSD_CF,@s_CRE_D,@s_lignes,@p_type_fichier,@per_cf,@s_clodat_d,'','','','','','','','','','',''
  return @erreur
end

return 0
go
EXEC sp_procxmode 'dbo.PtPATTERNSII_btrav_ano', 'unchained'
go
IF OBJECT_ID('dbo.PtPATTERNSII_btrav_ano') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtPATTERNSII_btrav_ano >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtPATTERNSII_btrav_ano >>>'
go
GRANT EXECUTE ON dbo.PtPATTERNSII_btrav_ano TO GOMEGA
go
GRANT EXECUTE ON dbo.PtPATTERNSII_btrav_ano TO GDBBATCH
go
