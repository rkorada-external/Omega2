USE BEST
go
IF OBJECT_ID('dbo.PtPATSEGSII_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtPATSEGSII_01
    IF OBJECT_ID('dbo.PtPATSEGSII_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtPATSEGSII_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtPATSEGSII_01 >>>'
END
go
create procedure dbo.PtPATSEGSII_01
  (
  @p_CRE_D        datetime
 ,@p_USR_CF       UUPDUSR_CF
 ,@p_CLODAT_D     datetime
 ,@p_PER_CF       char(5)
 ,@p_TYPE_FICHIER char(5)
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 10/10/2012
Description du programme: :spot:24041 SOLVENCY
Conditions d'execution: Par ESID0106.cmd
Commentaires:
_________________
MODIFICATIONS
1 20/03/2015 Florent :spot:27789 ajout restriction sur la période en cours pour la gestion de la DUPLI
2 29/04/2015 Florent :spot:26391 gestion ICV comme CUM
3 15/06/2015 Florent :spot:28941 gestion Inflated
4 30/05/2016 Florent :spot:30543 correction gestion des DSI
5 21/07/2016 Florent :spot:30976 Corections Solvency Ratio LoB
6 11/05/2016 Florent :spira:21416 Corections bis Solvency Ratio LoB
7 04/03/2019 Charles :spira:76356 Problème de chargement de pattern sur UAT
8 05/04/2024 JYP     :spira:108913 : bugfix cannot load because of archived data
*****************************************************/
declare
 @erreur int
,@lignes int
,@nb_archive  int

CREATE TABLE #PATSEGSII
  (
  CLODAT_D      datetime    NULL
 ,PER_CF        char(5)     NULL
 ,SSD_CF        USSD_CF     NULL
 ,SEG_NF        USEG_NF     NULL
 ,LOB_CF        char(2)     NULL
 ,CUR_CF        UCUR_CF     NULL
 ,NORME_CF      char(5)     NULL
 ,SEGNAT_CT     char(1)     DEFAULT '' NULL
 ,PATCAT_CT     char(5)     NOT NULL
 ,PATTYP_CT     char(5)     NOT NULL
 ,PATTERN_ID    varchar(21) NOT NULL
 ,ORIPATCAT_CT  char(5)     NULL
 ,ORIPATTYP_CT  char(5)     NULL
 ,ORIPATTERN_ID varchar(21) NULL
 ,CREUSR_CF     UUPDUSR_CF  NOT NULL
 ,CRE_D         datetime    NOT NULL
 ,RATEINDEX_CT   varchar(32) NULL
 ,ESB_CF   UESB_CF NULL
  )
if @@error!=0 return 999

CREATE INDEX IPATSEG_00_T
    ON #PATSEGSII(PATCAT_CT,PATTYP_CT,PATTERN_ID,CLODAT_D,PER_CF,SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,ORIPATCAT_CT,ORIPATTYP_CT,RATEINDEX_CT)
if @@error!=0 return 999

CREATE TABLE #PATSEGSII_DSI
  (
  CLODAT_D      datetime    NULL
 ,PER_CF        char(5)     NULL
 ,SSD_CF        USSD_CF     NULL
 ,SEG_NF        USEG_NF     NULL
 ,LOB_CF        char(2)     NULL
 ,CUR_CF        UCUR_CF     NULL
 ,NORME_CF      char(5)     NULL
 ,SEGNAT_CT     char(1)     DEFAULT '' NULL
 ,PATCAT_CT     char(5)     NOT NULL
 ,PATTYP_CT     char(5)     NOT NULL
 ,PATTERN_ID    varchar(21) NOT NULL
 ,ORIPATCAT_CT  char(5)     NULL
 ,ORIPATTYP_CT  char(5)     NULL
 ,ORIPATTERN_ID varchar(21) NULL
 ,CREUSR_CF     UUPDUSR_CF  NOT NULL
 ,CRE_D         datetime    NOT NULL
 ,RATEINDEX_CT   varchar(32) NULL
 ,ESB_CF   UESB_CF NULL
  )
if @@error!=0 return 999

CREATE INDEX IPATSEG_DSI_00
    ON #PATSEGSII_DSI(PATCAT_CT,PATTYP_CT,PATTERN_ID,CLODAT_D,PER_CF,SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,ORIPATCAT_CT,ORIPATTYP_CT)
if @@error!=0 return 999

CREATE TABLE #DELPATSEG
  (
  CLODAT_D      datetime    NULL
 ,PER_CF        char(5)     NULL
 ,SSD_CF        USSD_CF     NULL
 ,SEG_NF        USEG_NF     NULL
 ,LOB_CF        char(2)     NULL
 ,CUR_CF        UCUR_CF     NULL
 ,NORME_CF      char(5)     NULL
 ,SEGNAT_CT     char(1)     DEFAULT '' NULL
 ,PATCAT_CT     char(5)     NOT NULL
 ,PATTYP_CT     char(5)     NOT NULL
 ,PATTERN_ID    varchar(21) NOT NULL
 ,ORIPATCAT_CT  char(5)     NULL
 ,ORIPATTYP_CT  char(5)     NULL
 ,ORIPATTERN_ID varchar(21) NULL
 ,CREUSR_CF     UUPDUSR_CF  NOT NULL
 ,CRE_D         datetime    NOT NULL
 ,RATEINDEX_CT   varchar(32) NULL
 ,ESB_CF   UESB_CF NULL
  )
if @@error!=0 return 999

CREATE INDEX IDELPATSEG_00
    ON #DELPATSEG(PATCAT_CT,PATTYP_CT,PATTERN_ID,CLODAT_D,PER_CF,SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,ORIPATCAT_CT,ORIPATTYP_CT,RATEINDEX_CT)
if @@error!=0 return 999

CREATE TABLE #TLOBSII
(
  LOB_CF    char(2)   NOT NULL
 ,SEGNAT_CT char(1)   DEFAULT '' NOT NULL
 ,NORME_CF  char(5)   NOT NULL
 ,COEF_R    USHORAT_R NOT NULL
 ,CRE_D     datetime  DEFAULT getdate() NOT NULL
)
if @@error!=0 return 999

CREATE UNIQUE CLUSTERED INDEX ILOBSII_00
    ON #TLOBSII(LOB_CF,SEGNAT_CT,NORME_CF)
if @@error!=0 return 999

print 'Traitement pour Création %1! user %2! date de clôture %3! période %4! type de fichier %5!',@p_CRE_D,@p_USR_CF,@p_CLODAT_D,@p_PER_CF,@p_TYPE_FICHIER
begin tran

if @p_TYPE_FICHIER='BDT'
begin
  print 'before archivage BDT'

  update TPATSEGSII
   set CLODAT_D=null
      ,PER_CF=null
   from TPATSEGSII a, TPATTERNSII b
     where a.PATCAT_CT='BDT'
       and a.PATTYP_CT='RAT'
       and a.CRE_D!=@p_CRE_D
       and a.PATCAT_CT=b.PATCAT_CT
       and a.PATTYP_CT=b.PATTYP_CT
       and b.CRE_D=@p_CRE_D        -- nouveaux patterns BDT
       and a.SEG_NF=b.RATING_CF -- le RATING_CF de TPATERNSII est dans SEG_NF de TPATSEGSII pour avoir le taux qui a changé pour la norme/notation !
       and a.NORME_CF=b.NORME_CF
       and a.CLODAT_D in('19000101',@p_CLODAT_D)
       and a.PER_CF in('',@p_PER_CF)
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  print 'traces BDT vidées, lignes %1!',@lignes

  insert TPATSEGSII
  select @p_CLODAT_D,@p_PER_CF,SSD_CF,SEG_NF=RATING_CF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID
        ,ORIPATCAT_CT=null,ORIPATTYP_CT=null,ORIPATTERN_ID=null
        ,CREUSR_CF,CRE_D,RATEINDEX_CT,ESB_CF
   from TPATTERNSII
    where CRE_D=@p_CRE_D
      and PATCAT_CT='BDT'
      and PATTYP_CT='RAT'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  print 'nouvelles traces #PATSEGSII, lignes %1!',@lignes
end

if @p_TYPE_FICHIER!='BDT'
begin
  insert #PATSEGSII
  select CLODAT_D,PER_CF,SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID,ORIPATCAT_CT,ORIPATTYP_CT,ORIPATTERN_ID,CREUSR_CF,CRE_D,RATEINDEX_CT,ESB_CF
   from TPATSEGSII
    where CLODAT_D=@p_CRE_D
      and PER_CF='NEW'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  print 'nouvelles traces #PATSEGSII, lignes %1!',@lignes
end


if @p_TYPE_FICHIER='DSC'
begin
  insert #DELPATSEG
  select *
   from TPATSEGSII a
    where a.PER_CF='DUPLI'
      and a.PATCAT_CT='DSC'
      and a.CLODAT_D=@p_CRE_D
      and (select count(*) from TPATSEGSII b
                  where a.PATCAT_CT=b.PATCAT_CT
                    and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
                    and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                    and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
                    and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                    and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
                    and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
					and isnull(a.RATEINDEX_CT,'')=isnull(b.RATEINDEX_CT,'')
                    and a.PATCAT_CT=b.PATCAT_CT
                    and a.CLODAT_D=b.CLODAT_D
                 ) > 1
      and PATTERN_ID!=(select max(PATTERN_ID) from TPATSEGSII b
                  where a.PATCAT_CT=b.PATCAT_CT
                    and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
                    and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                    and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
                    and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                    and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
                    and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
					and isnull(a.RATEINDEX_CT,'')=isnull(b.RATEINDEX_CT,'')
                    and a.PATCAT_CT=b.PATCAT_CT
                    and a.CLODAT_D=b.CLODAT_D
                    )
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  if @lignes > 0
  begin
    print 'Anomalie de DSC en double !! lignes %1!',@lignes
    
    delete TPATSEGSII
     from TPATSEGSII a, #DELPATSEG b
      where a.PATCAT_CT=b.PATCAT_CT
        and a.PATTYP_CT=b.PATTYP_CT
        and a.PATTERN_ID=b.PATTERN_ID
        and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
        and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
        and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
        and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
        and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
        and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
		and isnull(a.RATEINDEX_CT,'')=isnull(b.RATEINDEX_CT,'')
    select @erreur=@@error,@lignes=@@rowcount
    if @erreur!=0 goto fin
    print 'suppression des des DSC en double !! lignes %1!',@lignes
    
    print 'Liste des des DSC en double '
    select * from #DELPATSEG
    if @@error!=0 goto fin
  end
end

if @p_TYPE_FICHIER in('CUM','ICV','DSC','INF')
begin
  -- pour la dupli, les patterns ID de #PATSEGSII correspondent à l'origine du pattern ID de TPATSEGSII, type CUM et DSC
  insert #PATSEGSII
  select distinct a.CLODAT_D,a.PER_CF,b.SSD_CF,b.SEG_NF,b.LOB_CF,b.CUR_CF,b.NORME_CF,b.SEGNAT_CT,b.PATCAT_CT,b.PATTYP_CT,b.PATTERN_ID,b.ORIPATCAT_CT,b.ORIPATTYP_CT
   ,b.ORIPATTERN_ID,b.CREUSR_CF,b.CRE_D,A.RATEINDEX_CT,A.ESB_CF
   from TPATSEGSII a, TPATSEGSII b
    where a.CLODAT_D=@p_CRE_D
      and a.PER_CF='DUPLI'
      and a.PATCAT_CT=@p_TYPE_FICHIER
      and a.PATTYP_CT not in('DSI','INFI')
      and a.PATTERN_ID=b.ORIPATTERN_ID
      and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
      and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
      and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
      and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
--on ne prend par les lignes qu'on vient de mettre et uniquement pour la clôture et période en cours
      and b.CLODAT_D in(null,'19000101',@p_CLODAT_D) 
      and b.PER_CF in(null,'',@p_PER_CF)
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  print 'Selection des traces en dupli #PATSEGSII CUM ou DSC, lignes %1!',@lignes
end

if @p_TYPE_FICHIER!='BDT'
begin
  delete TPATSEGSII where CLODAT_D=@p_CRE_D and PER_CF='DUPLI'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  print 'Suppression de TPATSEGSII des ligne DUPLI, lignes %1!',@lignes
end

if @p_TYPE_FICHIER in('CUM','ICV','DSC','INF')
begin

  print 'before delete old archived TPATSEGSII %1! %2! ', @p_TYPE_FICHIER, @p_PER_CF

  DELETE TPATSEGSII 
  FROM   TPATSEGSII AS a
  JOIN   #PATSEGSII AS b
  ON     isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
     and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
     and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
     and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
     and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
     and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
     and isnull(a.RATEINDEX_CT,'')=isnull(b.RATEINDEX_CT,'')     
	 and isnull(a.ESB_CF,0)=isnull(b.ESB_CF,0)
  WHERE  (isnull(a.CLODAT_D,'') = '' and isnull(a.PER_CF,'') = ''  )
  and    a.PATTERN_ID != b.PATTERN_ID 
  
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  print 'old archived data deleted %1! %2! records  ',@p_TYPE_FICHIER, @lignes

  		   
  print 'before update TPATSEGSII %1! %2! ', @p_TYPE_FICHIER, @p_PER_CF

  update TPATSEGSII
   set CLODAT_D=case when a.PATTERN_ID=b.PATTERN_ID then @p_CLODAT_D else null end
      ,PER_CF=case when a.PATTERN_ID=b.PATTERN_ID then @p_PER_CF else null end
      ,CRE_D=@p_CRE_D
      ,CREUSR_CF=@p_USR_CF
   from TPATSEGSII a, #PATSEGSII b
     where a.PATCAT_CT=b.PATCAT_CT
       and a.PATTYP_CT=b.PATTYP_CT
       and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
       and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
       and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
       and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
       and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
       and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
	   and isnull(a.RATEINDEX_CT,'')=isnull(b.RATEINDEX_CT,'')
	   and isnull(a.ESB_CF,0)=isnull(b.ESB_CF,0)
       and a.CLODAT_D in(@p_CRE_D,null,'19000101',@p_CLODAT_D)
       and a.PER_CF in(null,'',@p_PER_CF,'NEW')
       -- Il faut mettre à jour dans 3 cas
       -- si c'est une nouvelle courbe de taux pour le même PATTERN_ID : il faut renseigner la période car elle a la date de création et 'NEW'
       -- si c'est pour le même PATTERN_ID : il faut mettre à jour la date de création pour tracer que cette courbe de taux a été choisi pour cette période à nouveau
       -- si ce n'est plus dans la période (pas le même PATTERN_ID) et la période/date de clôture n'est pas nulle
       -- les autres cas concenrnent daes courbes de taux pas utilisées et marquées comme tel avec une période et date de clôture à null
       and 1=(case when a.PATTERN_ID=b.PATTERN_ID then 1
                   when a.PATTERN_ID!=b.PATTERN_ID and a.PER_CF!=null then 1
                   else 0 end)
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  print 'maj des TPATSEGSII pour les patterns à prendre en compte pour l''inventaire %1!/%2!, lignes %3!',@p_PER_CF,@p_CLODAT_D,@lignes
end


if @p_TYPE_FICHIER='DSI'
begin
  insert #PATSEGSII_DSI
  select CLODAT_D,PER_CF,SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID,ORIPATCAT_CT,ORIPATTYP_CT,ORIPATTERN_ID,CREUSR_CF,
  CRE_D, RATEINDEX_CT, ESB_CF
   from #PATSEGSII a
    where exists(select 1 from TPATSEGSII x 
                 where a.PATCAT_CT=x.PATCAT_CT
                   and a.PATTYP_CT=x.PATTYP_CT
                   and isnull(a.CUR_CF,'')=isnull(x.CUR_CF,'')
                   and isnull(a.NORME_CF,'')=isnull(x.NORME_CF,'')
                   and a.ORIPATCAT_CT=x.ORIPATCAT_CT
                   and a.ORIPATTYP_CT=x.ORIPATTYP_CT
                   and a.ORIPATTERN_ID=x.ORIPATTERN_ID
                   and x.PER_CF=@p_PER_CF
                   and x.CLODAT_D=@p_CLODAT_D)
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  print 'insert TPATSEGSII_DSI, nouvelles DSI, même clé (pour DSC) et même origine, lignes %1!',@lignes

  insert #PATSEGSII_DSI
  select CLODAT_D,PER_CF,SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID,ORIPATCAT_CT,ORIPATTYP_CT,ORIPATTERN_ID,CREUSR_CF,
  CRE_D,RATEINDEX_CT,ESB_CF
   from #PATSEGSII a
    where not exists(select 1 from #PATSEGSII_DSI x 
                 where a.PATCAT_CT=x.PATCAT_CT
                   and a.PATTYP_CT=x.PATTYP_CT
                   and isnull(a.LOB_CF,'')=isnull(x.LOB_CF,'')
                   and isnull(a.CUR_CF,'')=isnull(x.CUR_CF,'')
                   and isnull(a.NORME_CF,'')=isnull(x.NORME_CF,'')
                   and isnull(a.SEGNAT_CT,'')=isnull(x.SEGNAT_CT,'') )
       and PATTERN_ID=(select max(x.PATTERN_ID) from #PATSEGSII x
                 where a.PATCAT_CT=x.PATCAT_CT
                   and a.PATTYP_CT=x.PATTYP_CT
                   and isnull(a.LOB_CF,'')=isnull(x.LOB_CF,'')
                   and isnull(a.CUR_CF,'')=isnull(x.CUR_CF,'')
                   and isnull(a.NORME_CF,'')=isnull(x.NORME_CF,'')
                   and isnull(a.SEGNAT_CT,'')=isnull(x.SEGNAT_CT,''))
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  print 'insert TPATSEGSII_DSI, nouvelles DSI, même clé (pour DSI !) et origine (DSC) pas trouvée, on prend la DSC la plus récente, lignes %1!',@lignes

  print 'before update DSI TPATSEGSII %1! %2! ', @p_TYPE_FICHIER, @p_PER_CF

  update TPATSEGSII
   set CLODAT_D=case when a.PATTERN_ID=b.PATTERN_ID then @p_CLODAT_D else null end
      ,PER_CF=case when a.PATTERN_ID=b.PATTERN_ID then @p_PER_CF else null end
      ,CRE_D=@p_CRE_D
      ,CREUSR_CF=@p_USR_CF
     from TPATSEGSII a, #PATSEGSII_DSI b
     where a.PATCAT_CT=b.PATCAT_CT
       and a.PATTYP_CT=b.PATTYP_CT
       and a.PATTYP_CT='DSI'
       and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
       and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
       and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
       and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
       and a.CLODAT_D in(@p_CRE_D,@p_CLODAT_D)
       and a.PER_CF in(@p_PER_CF,'NEW')
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  print 'maj TPATSEGSII DSI, lignes %1!',@lignes

  -- code repris de PsFLOBSII_01, pour la liste de TLOBSII pour cette période
  insert #TLOBSII
  select LOB_CF,SEGNAT_CT,NORME_CF,COEF_R,CRE_D=max(CRE_D)
   from TLOBSII
    where VALEND_D >= @p_CLODAT_D
  group by LOB_CF,SEGNAT_CT,NORME_CF,COEF_R
  order by LOB_CF,SEGNAT_CT,NORME_CF,COEF_R

  insert #TLOBSII
  select LOB_CF,SEGNAT_CT,NORME_CF,COEF_R,CRE_D=max(CRE_D)
   from TLOBSII a
    where (a.VALEND_D is null or a.VALEND_D >= @p_CLODAT_D)
      and not exists(select 1 from #TLOBSII b where b.LOB_CF=a.LOB_CF and b.SEGNAT_CT=a.SEGNAT_CT and b.NORME_CF=a.NORME_CF)
      and a.CRE_D=(select max(c.CRE_D) from TLOBSII c where c.LOB_CF=a.LOB_CF and c.SEGNAT_CT=a.SEGNAT_CT and c.NORME_CF=a.NORME_CF
                   and (c.VALEND_D is null or c.VALEND_D<=@p_CLODAT_D) )
  group by LOB_CF,SEGNAT_CT,NORME_CF,COEF_R
  order by LOB_CF,SEGNAT_CT,NORME_CF,COEF_R

  print 'before update TPATSEGSII %1! %2! ', @p_TYPE_FICHIER, @p_PER_CF

  update TPATSEGSII
   set CLODAT_D=null
      ,PER_CF=null
      ,CRE_D=@p_CRE_D
      ,CREUSR_CF=@p_USR_CF
     from TPATSEGSII a
     where PATTYP_CT='DSI'
       and CLODAT_D=@p_CLODAT_D
       and PER_CF=@p_PER_CF
       and SEGNAT_CT!='' -- on teste uniquement les natures renseignées dans TLOBSII
-- les normes sont toujours données par le fichier importé, la nature est donnée par TLOBSII,
-- il faut donc vérifier si pour une LOB, la nature n'existe plus pour cette période
       and not exists(select 1 from #TLOBSII b where b.LOB_CF=a.LOB_CF and b.NORME_CF=a.NORME_CF and b.SEGNAT_CT=a.SEGNAT_CT)
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur!=0 goto fin
  print 'maj TPATSEGSII DSI à aucune période, car la nature n''existe plus dans TLOBSII pour la période en cours, lignes %1!',@lignes
end

commit tran
return 0

fin:
rollback tran
return 999
go
IF OBJECT_ID('dbo.PtPATSEGSII_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtPATSEGSII_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtPATSEGSII_01 >>>'
go
GRANT EXECUTE ON dbo.PtPATSEGSII_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtPATSEGSII_01 TO GDBBATCH
go

