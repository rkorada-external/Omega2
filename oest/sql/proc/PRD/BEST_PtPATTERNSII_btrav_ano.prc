use BEST
go
if object_id('PtPATTERNSII_btrav_ano') is not null
begin
  drop procedure PtPATTERNSII_btrav_ano
  if object_id('PtPATTERNSII_btrav_ano') is not null
    print '<<< FAILED DROPPING procedure PtPATTERNSII_btrav_ano >>>'
  else
    print '<<< DROPPED procedure PtPATTERNSII_btrav_ano >>>'
end
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
 ,@p_clodat_d	  datetime		--MOD012
 ,@p_per_cf		  varchar(5)	--MOD012
 ,@p_norme_cf	  varchar(5)	--MOD014
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
5 19/02/2015 Florent :spot:27789  correction pour la sélection de la version de la segmentation
6 28/04/2015 Florent :spot:26391 gestion ICV comme CUM et on reçoit ICV avec le code CUM alors maj en ICV si ICACC ou ICRET
7 11/06/2015 Florent :spot:28941 gestion INF
8 09/05/2016 Florent :spot:30543 on passe à 65 années
9 09/01/2020 KBagwe  :#82575:REQ22.1 - ULAE
10 22/07/2020 KBagwe  :#62221:EBS - Quarterly Pattern
11 02/11/2020 KBagwe	: Spira: 89097- REQ 53.3 - Impact on discount pattern load
12 28/07/2021 KBhimasen	: Spira: 85174- Closing calendar- Impact on patterns load
13 10/08/2021 KBhimasen : Spira: 97223- Illiquidity segment- Impact on pattern load
14 28/09/2021 CSocie : Spira: 98640 - Discount - Illiquidity segment management
15 14/10/2022 KBhimasen : Spira:105375 - I17S discount pattern load
16 18/08/2023 KBhimasen : Spira:108951 - P&C Load closing parameters during extended period
17 06/11/2023 FCI: Spira#110770 - Error when loading Parent/Local discount curves
18 29/01/2024 FCI: Spira#110445 - Interface DIP - manual upload should not overwrite DIP data
*****************************************************/
declare
  @erreur      int
 ,@lignes      int
 ,@lignes_load int
 ,@VRS_NF      numeric(10,0)
 ,@s_SSD_CF    varchar(30)
 ,@s_CRE_D     varchar(30)
 ,@s_lignes    varchar(30)
 --,@clodat_d    datetime
 --,@per_cf      char(3)
 ,@s_clodat_d  char(8)
 ,@s_BALSHEY_NF  int
 ,@s_REQCOD_CT varchar(12)
 ,@s_ExtendedPeriod varchar(4)

select @lignes=0 --lignes en erreur

-- demande uniquement la sélection des anomalies d'un précédent traitement
if @p_visu_ano=1 goto visu_ano

-- 1 pour exec par le batch
--exec @erreur=BREF..PsCALEND_EBS @p_CRE_D,1,@clodat_d output, @per_cf output
--if @erreur!=0 or @@error!=0 return 999

--MOD10 start
select @s_BALSHEY_NF= year(@p_clodat_d)
if (month(@p_clodat_d) >= 01 and month(@p_clodat_d) <= 09) 
begin
	select @s_BALSHEY_NF= @s_BALSHEY_NF-1
end
--MOD10 end

-- recherche de la version NON COMPTABILISÉE dans la période inventaire sinon comptabilisé pour la filiale
select @VRS_NF=a.VRS_NF
 from TVERPAR a
  where a.SEGTYP_CT='A'
 and SSD_CF=@p_SSD_CF
 and exists(SELECT 1 from TVERSION b where b.SEGTYP_CT='A' and ((@p_per_cf='INV' and b.VRSSTS_CT<>'AN') or (b.VRSSTS_CT='CO')) and b.VRSLOC_B=0 and a.SSD_CF=b.SSD_CF and a.VRS_NF=b.VRS_NF)
having PAR_D=max(PAR_D)
if @@error!=0 return 999

-- on delete les anomalies du traitement précédent
delete TCTRANO where SEG_NF=@p_CREUSR_CF and SSD_CF=@p_ssd_cf and SEGTYP_CT='S'

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

if @p_type_fichier!='DSC' 
begin
-- formatage des champs caractères en majuscules
update BTRAV..EST_ESID0821_TPATTERNSII
 set SEG_NF=upper(SEG_NF)
    ,LOB_CF=case when LOB_CF not in (null,'*') then right('0'+LOB_CF,2) else LOB_CF end-- pour s'assurer que la LOB a toujours 2 chiffres -- modif 1
    ,CUR_CF=upper(CUR_CF)
    ,NORME_CF=upper(NORME_CF)
    ,PATTYP_CT=upper(PATTYP_CT)
    ,PATCAT_CT=upper(PATCAT_CT)
  where CRE_D=@p_CRE_D
    and CREUSR_CF=@p_CREUSR_CF
    and PATCAT_CT=@p_type_fichier
select @erreur=@@error
if @erreur!=0 return 999
end

if @p_type_fichier='DSC' 
begin
-- formatage des champs caractères en majuscules
update BTRAV..EST_ESID0821_TPATTERNSII
 set SEG_NF=upper(SEG_NF)
    ,CUR_CF=upper(CUR_CF)
    ,NORME_CF=upper(NORME_CF)
    ,PATTYP_CT=upper(PATTYP_CT)
    ,PATCAT_CT=upper(PATCAT_CT)
  where CRE_D=@p_CRE_D
    and CREUSR_CF=@p_CREUSR_CF
    and PATCAT_CT=@p_type_fichier
select @erreur=@@error
if @erreur!=0 return 999
end

--------------------- gestion de l'ICV qui est en CUM au départ -------------------------------------------------------
if @p_type_fichier='CUM' and exists(select 1 from BTRAV..EST_ESID0821_TPATTERNSII where PATTYP_CT in('ICACC','ICRET') and CRE_D=@p_CRE_D and CREUSR_CF=@p_CREUSR_CF and PATCAT_CT=@p_type_fichier)
begin
  update BTRAV..EST_ESID0821_TPATTERNSII
   set PATCAT_CT='ICV'
    where CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and PATCAT_CT=@p_type_fichier
  select @erreur=@@error
  if @erreur!=0 return 999
  select @p_type_fichier='ICV'
end

--------------------- gestion du INF qui est en DSC au départ -------------------------------------------------------
if @p_type_fichier='DSC' and exists(select 1 from BTRAV..EST_ESID0821_TPATTERNSII where PATTYP_CT='INF' and CRE_D=@p_CRE_D and CREUSR_CF=@p_CREUSR_CF and PATCAT_CT=@p_type_fichier)
begin
  update BTRAV..EST_ESID0821_TPATTERNSII
   set PATCAT_CT='INF'
    where CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and PATCAT_CT=@p_type_fichier
  select @erreur=@@error
  if @erreur!=0 return 999
  select @p_type_fichier='INF'
end

-- Si la table n'a pas les nouveaux taux remplis, on y mets les bonnes valeurs
if exists (select 1 from BTRAV..EST_ESID0821_TPATTERNSII where CRE_D=@p_CRE_D and CREUSR_CF=@p_CREUSR_CF
           and 1=case when AN41=null and AN42=null and AN43=null and AN44=null and AN45=null and AN46=null and AN47=null
           and AN48=null and AN49=null and AN50=null and AN51=null and AN52=null and AN53=null and AN54=null
           and AN55=null and AN56=null and AN57=null and AN58=null and AN59=null and AN60=null and AN61=null
           and AN62=null and AN63=null and AN64=null and AN65=null then 1 else 0 end)
begin
  if @p_type_fichier in('ICV','CUM')
  begin
    update BTRAV..EST_ESID0821_TPATTERNSII
     set AN41=1, AN42=1, AN43=1, AN44=1, AN45=1, AN46=1, AN47=1, AN48=1, AN49=1, AN50=1, AN51=1, AN52=1
        ,AN53=1, AN54=1, AN55=1, AN56=1, AN57=1, AN58=1, AN59=1, AN60=1, AN61=1, AN62=1, AN63=1, AN64=1, AN65=1
     where CRE_D=@p_CRE_D and CREUSR_CF=@p_CREUSR_CF
    if @erreur!=0 return 999
  end
  if @p_type_fichier not in('ICV','CUM')
  begin
    update BTRAV..EST_ESID0821_TPATTERNSII
     set AN41=0, AN42=0, AN43=0, AN44=0, AN45=0, AN46=0, AN47=0, AN48=0, AN49=0, AN50=0, AN51=0, AN52=0
        ,AN53=0, AN54=0, AN55=0, AN56=0, AN57=0, AN58=0, AN59=0, AN60=0, AN61=0, AN62=0, AN63=0, AN64=0, AN65=0
     where CRE_D=@p_CRE_D and CREUSR_CF=@p_CREUSR_CF
    if @erreur!=0 return 999
  end
end


insert into TCTRANO
select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,87,LIGNE_N,0,0
 from BTRAV..EST_ESID0821_TPATTERNSII a
  where CRE_D=@p_CRE_D
    and CREUSR_CF=@p_CREUSR_CF
    AND AN65!=1.0                      --dernière année du taux doit être à 1
    and PATCAT_CT=@p_type_fichier
    and @p_type_fichier in('ICV','CUM')
select @erreur=@@error, @lignes=@lignes+@@rowcount
if @erreur!=0 return 999

if @p_type_fichier in('CUM','ICV')
begin
  insert into TCTRANO
  select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,88,LIGNE_N,0,0
   from BTRAV..EST_ESID0821_TPATTERNSII a
    where ((LOB_CF!=null and SEG_NF!=null) or (LOB_CF=null and SEG_NF=null))
      and CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and PATCAT_CT=@p_type_fichier
      and PATCAT_CT in('CUM','ICV')
  select @erreur=@@error, @lignes=@lignes+@@rowcount
  if @erreur!=0 return 999
end


insert into TCTRANO
select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,82,LIGNE_N,0,0
 from BTRAV..EST_ESID0821_TPATTERNSII a
  where SSD_CF!=null
    and LOB_CF!=null
    and not ((@p_type_fichier in('CUM','ICV') and LOB_CF='*') or @p_type_fichier = 'DSC') -- modif 1 & 14
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
    and not ((@p_type_fichier in('CUM','ICV') and LOB_CF='*') or @p_type_fichier = 'DSC') -- modif 1 & 14
    and CRE_D=@p_CRE_D
    and CREUSR_CF=@p_CREUSR_CF
    and PATCAT_CT=@p_type_fichier
    and not exists(select 1 from BREF..TLOB b where a.LOB_CF=b.LOB_CF)
select @erreur=@@error, @lignes=@lignes+@@rowcount
if @erreur!=0 return 999


--MOD09
if @p_type_fichier in('INF')
begin
	insert into TCTRANO
	select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,84,LIGNE_N,0,0
	 from BTRAV..EST_ESID0821_TPATTERNSII a
	  where CRE_D=@p_CRE_D
	    and CREUSR_CF=@p_CREUSR_CF
	    AND NORME_CF!="ALLNO"                      
	    and PATCAT_CT=@p_type_fichier

	select @erreur=@@error, @lignes=@lignes+@@rowcount
	if @erreur!=0 return 999
end
else
begin
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

end
--MOD09

insert into TCTRANO
select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,83,LIGNE_N,0,0
 from BTRAV..EST_ESID0821_TPATTERNSII a
  where CRE_D=@p_CRE_D
    and CREUSR_CF=@p_CREUSR_CF
    and PATCAT_CT=@p_type_fichier
    and not exists(select 1 from BREF..TBANTEC b where b.COL_LS='PATTYP_CT' and b.COLVAL_CT=a.PATTYP_CT)
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
    and not (@p_type_fichier in('CUM','ICV') and SEG_NF='*') -- modif 1
    and PATCAT_CT=@p_type_fichier
    and not exists(select 1 from TSEGMENT b where b.SEG_NF=a.SEG_NF and b.VRS_NF=@VRS_NF)
select @erreur=@@error, @lignes=@lignes+@@rowcount
if @erreur!=0 return 999

-- vérification si le type de courbe de taux DSC a une courbe de taux Illiquidity correspondante
if @p_type_fichier='DSC'
begin
	insert into TCTRANO
	select convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0,@p_SSD_CF,'S',@p_CREUSR_CF,89,LIGNE_N,0,0
	from BTRAV..EST_ESID0821_TPATTERNSII a
    where CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and PATCAT_CT=@p_type_fichier
--MOD013[START]
     -- and PATCAT_CT='DSC'
	  and PATTYP_CT!='DSC'
     -- and exists(select 1 from BTRAV..EST_ESID0821_TPATTERNSII b where a.CREUSR_CF=b.CREUSR_CF and a.PATCAT_CT=b.PATCAT_CT
     --                 and b.PATTYP_CT=case when a.PATTYP_CT='DSC' then 'ILL' else 'DSC' end
      --                and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'') and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,''))
	select @erreur=@@error, @lignes=@lignes+@@rowcount
	if @erreur!=0 return 999
		
	insert into TCTRANO 
	 select distinct convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0, @p_SSD_CF, 'S', @p_CREUSR_CF,  21014, LIGNE_N, 0,0
		from BTRAV..EST_ESID0821_TPATTERNSII a
		WHERE CREUSR_CF = @p_CREUSR_CF
		  and CRE_D=@p_CRE_D
		  and NORME_CF in ('I17G','I17P','I17L','I17S')			--MOD015
		group by SSD_CF, SEG_NF, LOB_CF, ESB_CF, NORME_CF, PATTYP_CT, CUR_CF ,CREUSR_CF	
		having count(*) > 1
	
	select @erreur=@@error, @lignes=@lignes+@@rowcount
	if @erreur!=0 return 999

	insert into TCTRANO 
	 select distinct convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0, @p_SSD_CF, 'S', @p_CREUSR_CF,  21014, LIGNE_N, 0,0
		from BTRAV..EST_ESID0821_TPATTERNSII a
		WHERE CREUSR_CF = @p_CREUSR_CF
		  and CRE_D=@p_CRE_D
		  and NORME_CF in ('SII',' IFRSI',' GIM',' EV')
		group by  NORME_CF, PATTYP_CT, CUR_CF ,CREUSR_CF	
		having count(*) > 1
		
	select @erreur=@@error, @lignes=@lignes+@@rowcount
	if @erreur!=0 return 999
--MOD013[END]
--MOD016[START]
	if (@p_norme_cf='I17P' or @p_norme_cf='I17L')
	begin
		--MOD017[START]
		select top 1 @s_REQCOD_CT =  REQCOD_CT FROM BEST..TI17REQJOBPLAN Where DBCLO_D <= @p_CRE_D and NORME_CF = @p_norme_cf and SITE_CF = 
		(SELECT SITE_CF = CASE
			WHEN BATCHUSER_CF = 'UBAM'  THEN 'USA1'
			WHEN BATCHUSER_CF = 'UBEU'  THEN 'FRA1'
			WHEN BATCHUSER_CF = 'UBAS'  THEN 'SGP1' END 
			FROM BREF..TBATCHSSD WHERE SSD_CF = @p_SSD_CF)
		order by DBCLO_D desc

		select @s_ExtendedPeriod = RIGHT(@s_REQCOD_CT,4)

		--print 'Extended period calculated = %1!, REQCOD_CT = %2!, CRE_D = %3!, norme_cf = %4!, SSD_CF = %5!',@s_ExtendedPeriod,@s_REQCOD_CT,@p_CRE_D,@p_norme_cf,@p_SSD_CF

		if (@s_ExtendedPeriod = 'POSX')
--MOD017[END]
		begin
			insert into TCTRANO 
			 select distinct convert(char(8),@p_CRE_D,112),datepart(hour,@p_CRE_D),datepart(minute,@p_CRE_D),0, @p_SSD_CF, 'S', @p_CREUSR_CF,  810, LIGNE_N, 0,0
				from BTRAV..EST_ESID0821_TPATTERNSII a, BEST..TI17CLOPER b
				WHERE a.CREUSR_CF = @p_CREUSR_CF
				  and a.CRE_D=@p_CRE_D
				  and a.NORME_CF in ('I17P','I17L')
				  and a.SSD_CF = @p_SSD_CF
				  and a.SSD_CF = b.SSD_CF
				  and a.ESB_CF = b.ESB_CF
				  and (b.PARM5 IS NULL or b.PARM5 = '0')
				
			select @erreur=@@error, @lignes=@lignes+@@rowcount
			if @erreur!=0 return 999
		end
	end
--MOD016[END]
--MOD018[START]
	insert into TCTRANO
	select distinct convert(char(8),@p_CRE_D,112),datepart(hour,getDate()),datepart(minute,getDate()),0, @p_SSD_CF, 'S', @p_CREUSR_CF,  811, LIGNE_N, 0,0
    FROM BEST..TPATTERNSII A , BTRAV..EST_ESID0821_TPATTERNSII B
	WHERE
	isnull(A.SSD_CF, 0 ) = isnull(B.SSD_CF, 0 ) AND
	isnull(A.ESB_CF, 0 ) = isnull(B.ESB_CF, 0) AND			
	isnull(A.CUR_CF, '' ) = isnull(B.CUR_CF, '') AND
	isnull(A.NORME_CF, '' ) = isnull(B.NORME_CF, '') AND
	A.PATTYP_CT = B.PATTYP_CT AND A.PATCAT_CT = B.PATCAT_CT AND
	isnull(A.RATEINDEX_CT, '') = isnull(B.LOB_CF, '') AND
	A.CREUSR_CF = 'DIP0' AND B.CREUSR_CF != 'DIP0' AND
	B.CRE_D=@p_CRE_D 		and B.CREUSR_CF=@p_CREUSR_CF		and B.PATCAT_CT=@p_type_fichier AND
	EXISTS 
	( SELECT 1 FROM BEST..TPATSEGSII C 
	  WHERE isnull(A.RATEINDEX_CT, '' )= isnull(C.RATEINDEX_CT, '' ) AND A.PATTERN_ID = C.ORIPATTERN_ID AND A.PATCAT_CT = C.PATCAT_CT  AND A.PATTYP_CT =C.ORIPATTYP_CT
			AND isnull(A.SSD_CF, 0 ) = isnull(C.SSD_CF, 0 ) AND isnull(A.ESB_CF, 0 ) = isnull(C.ESB_CF, 0)
			AND isnull(A.CUR_CF, '' ) = isnull(C.CUR_CF, '') AND isnull(A.NORME_CF, '' ) = isnull(C.NORME_CF, '')				
			AND C.CLODAT_D = @p_clodat_d AND C.PER_CF = @p_per_cf
			AND C.CREUSR_CF = 'DIP0'
	)
	select @erreur=@@error, @lignes=@lignes+@@rowcount
	if @erreur!=0 return 999
--MOD018[END]
end --DSC

visu_ano:
if @p_batch=0
 --gestion spécifique pour l'erreur du nombres de lignes attendues
  select PATCAT_CT
    ,PATCAT_LS=(select COLVAL_LS from BREF..TBANTECL y where t.PATCAT_CT=y.COLVAL_CT and COL_LS='PATCAT_CT' and LAG_CF=@p_LAG_CF)
    ,LIGNE=a.NUMLINE_NT,COLONNE=b.COLVAL_LS
    ,ANOMALIE=(CASE WHEN a.ANO_CT=89 THEN 'unauthorized value for column “type de taux”: '+PATTYP_CT  ELSE b.COLVAL_LM END)+
						  case when a.ANO_CT=80 then ': '+convert(varchar(5),a.UWY_NF)+'/'+convert(varchar(5),a.ACY_NF)
                               when a.ANO_CT in(81,82) then ': '+ t.LOB_CF
                               when a.ANO_CT=83 then ': '+ t.PATTYP_CT
                               when a.ANO_CT=84 then ': '+ t.NORME_CF
                               when a.ANO_CT=85 then ': '+ t.CUR_CF
                               when a.ANO_CT=86 then ': '''+ t.SEG_NF +''' version '+convert(char(10),VRS_NF)
                               when a.ANO_CT=87 then ': '+ convert(char(10),t.AN40)
                               when a.ANO_CT=88 then ': LOB '''+ isnull(LOB_CF,'') + ''' Segment ''' + isnull(t.SEG_NF,'') + ''''
                              -- when a.ANO_CT=89 then ': '+isnull(CUR_CF,'')+'/'+isnull(NORME_CF,'')+'/'+PATTYP_CT
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
                 Case when T1.ANO_CT = 90 then ': '+ CONVERT(VARCHAR ,T1.SSD_CF)
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
  --MOD013[START]
  UNION
	SELECT PATCAT_CT = NULL,
	PATCAT_LS = NULL,
	LIGNE = p.NUMLINE_NT,
	COLONNE = '',
	ANOMALIE = q.MESS_L,
	CRE_D=case when @p_CRE_D=null then dateadd(minute,sec_nf,dateadd(hour,end_nt,convert(datetime,CTR_NF))) else @p_CRE_D end
	 from TCTRANO p, BREF..TMESSAGE q, BTRAV..EST_ESID0821_TPATTERNSII r
   where p.SSD_CF=@p_SSD_CF
     and p.SEGTYP_CT='S'
     and p.SEG_NF=@p_CREUSR_CF
     and q.LANG_C=@p_LAG_CF
     and p.ANO_CT in (21014,810,811)				--MOD016 MOD018
	 and q.MESS_N=P.ANO_CT
     and q.MESSTHM_C='ESTIMATION'
     and p.SEG_NF=r.CREUSR_CF
     and p.NUMLINE_NT=r.LIGNE_N
	 and r.CREUSR_CF=@p_CREUSR_CF
  --MOD013[END]  
if @p_batch=1
begin
  -- retour avec anomalies pour le batch
  if @lignes > 0
  begin
    raiserror 35000 'Anomalies user %1!, date %2!',@p_CREUSR_CF,@p_CRE_D
    return 1
  end
  -- sélection du fichier pour le ESID0101
  if @p_type_fichier='DSC'			--MOD11
  BEGIN
  select SSD_CF,rtrim(PATCAT_CT),rtrim(PATTYP_CT),SEG_NF,UWY_NF=null,CUR_CF,LOB_CF,RATING_CF=null,NORME_CF,SEGNAT_CT=null
        ,@s_BALSHEY_NF			--MOD10
        ,PATTERN_ID=null,CRE_D=convert(char(8),CRE_D,112)+' '+ convert(char(8),CRE_D,8)+ substring(convert(char(27),CRE_D,109),21,4)
        ,CREUSR_CF,TOTAUX=null
        ,AN1,AN2,AN3,AN4,AN5,AN6,AN7,AN8,AN9,AN10,AN11,AN12,AN13,AN14,AN15,AN16,AN17,AN18,AN19,AN20
        ,AN21,AN22,AN23,AN24,AN25,AN26,AN27,AN28,AN29,AN30,AN31,AN32,AN33,AN34,AN35,AN36,AN37,AN38,AN39,AN40
        ,AN41,AN42,AN43,AN44,AN45,AN46,AN47,AN48,AN49,AN50,AN51,AN52,AN53,AN54,AN55,AN56,AN57,AN58,AN59,AN60
        ,AN61,AN62,AN63,AN64,AN65,ESB_CF
   from BTRAV..EST_ESID0821_TPATTERNSII
    where CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and PATCAT_CT=@p_type_fichier
  order by SSD_CF,PATCAT_CT,PATTYP_CT,SEG_NF,CUR_CF,LOB_CF,NORME_CF
  if @@error!=0 return 1
  
  END
  ELSE
  BEGIN
    select SSD_CF,rtrim(PATCAT_CT),rtrim(PATTYP_CT),SEG_NF,UWY_NF=null,CUR_CF,LOB_CF,RATING_CF=null,NORME_CF,SEGNAT_CT=null
        ,@s_BALSHEY_NF			--MOD10
        ,PATTERN_ID=null,CRE_D=convert(char(8),CRE_D,112)+' '+ convert(char(8),CRE_D,8)+ substring(convert(char(27),CRE_D,109),21,4)
        ,CREUSR_CF,TOTAUX=null
        ,AN1,AN2,AN3,AN4,AN5,AN6,AN7,AN8,AN9,AN10,AN11,AN12,AN13,AN14,AN15,AN16,AN17,AN18,AN19,AN20
        ,AN21,AN22,AN23,AN24,AN25,AN26,AN27,AN28,AN29,AN30,AN31,AN32,AN33,AN34,AN35,AN36,AN37,AN38,AN39,AN40
        ,AN41,AN42,AN43,AN44,AN45,AN46,AN47,AN48,AN49,AN50,AN51,AN52,AN53,AN54,AN55,AN56,AN57,AN58,AN59,AN60
        ,AN61,AN62,AN63,AN64,AN65
   from BTRAV..EST_ESID0821_TPATTERNSII
    where CRE_D=@p_CRE_D
      and CREUSR_CF=@p_CREUSR_CF
      and PATCAT_CT=@p_type_fichier
  order by SSD_CF,PATCAT_CT,PATTYP_CT,SEG_NF,CUR_CF,LOB_CF,NORME_CF
  if @@error!=0 return 1
  
  END
end

-- on lance l'asynchrone si on vient du TP pour faire le fichier pour la chaîne des courbes de taux
if @lignes=0 and @p_batch=0 and @p_visu_ano=0 and @p_CREUSR_CF != 'DIP0'	--MOD013
begin
  select
   @s_SSD_CF=convert(varchar(30),@p_SSD_CF)
   -- pour gérer les espaces, format SSAAMMJJ HH:MM:SS:mmm
   --[003] suppression des quotes (') qui entouraient la chaine de caracteres
  ,@s_CRE_D=convert(char(8),@p_CRE_D,112)+' '+ convert(char(12),@p_CRE_D,20)
  ,@s_clodat_d=convert(char(8),@p_clodat_d,112)
  ,@s_lignes=convert(varchar(30),@p_lignes)

  exec @erreur=BTEC..PiJOBQUEUE_02 'best11a',@p_CREUSR_CF,null
  -- paramètres du job
   ,@p_LAG_CF,@s_SSD_CF,@s_CRE_D,@s_lignes,@p_type_fichier,@p_per_cf,@s_clodat_d,@p_norme_cf,'','','','','','','','','',''		
  return @erreur
end

return 0
go
if object_id('PtPATTERNSII_btrav_ano') is not null
  print '<<< CREATED procedure PtPATTERNSII_btrav_ano >>>'
else
  print '<<< FAILED CREATING procedure PtPATTERNSII_btrav_ano >>>'
go
grant execute on PtPATTERNSII_btrav_ano TO GOMEGA
go
grant execute on PtPATTERNSII_btrav_ano TO GDBBATCH
go
