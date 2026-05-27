USE BEST
go
IF OBJECT_ID('dbo.PuSOLVENCY_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuSOLVENCY_02
    IF OBJECT_ID('dbo.PuSOLVENCY_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuSOLVENCY_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuSOLVENCY_02 >>>'
END
go
create procedure dbo.PuSOLVENCY_02 (
  @p_clodat_d   datetime,
  @p_cre_d      datetime,
  @p_typeinv_cf char(3)
  )
as
/***************************************************
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     P.PEZOUT
Description du programme: :spot:24516
    - Mise a jour de la date de comptabilisation et du type d'inventaire des tables patterns solvency
Parametres:     - @p_cre_d : la date de traitement
                - @p_clodat_d : libellé d'inventaire
                - @p_typeinv_cf : type inventaire
_________________
MODIFICATIONS
1 Florent  24/07/2013 :spot:25399 génération trimestre suivant
2 12/12/2013 Cyrille Despret :spot:26209 Correction génération trimestre suivant, gestion des mois à 30 et 31 jours
3 27/03/2014 Roger Cassis    :spot:25427 Omage 1B - Suppression données avant reinsertion
4 02/12/2014 Cyrille Despret :spot:xxxxx Copie des patterns du POS sur INV lors d'une cloture de type POS; ecrasement des patterns du trimestre suivant dans tous les cas
5 30/04/2015 Florent         :spot:27903 on ne renouvelle pas les CUM et ICV d'une autre année bilan, donc quand l'année change entre la nouvelle clôture et l'ancienne
6 22/06/2015 Florent :spot:28941 gestion ULAE
7 04/05/2016 Florent :spot:30535 suppression des patterns pas utilisées par un inventaire
8 04/05/2017 Florent :spira:21416 correction pour la suppression des patterns DSC
9 10/09/2019 Abhishek:spira:62221 EBS - Quarterly Pattern Modifications with respect to ICV and CUM
10 09/10/2020 KBagwe:spira:89093 REQ 53.3 - Impact on EST data model
*****************************************************/
declare
 @erreur int
,@tran_imbr  bit
,@annee smallint
,@lignes int


select @erreur=0, @tran_imbr=1

select a.CLODAT_D, a.PER_CF, a.SSD_CF, a.SEG_NF, a.LOB_CF, a.CUR_CF, a.NORME_CF, a.SEGNAT_CT, a.PATCAT_CT, a.PATTYP_CT, a.PATTERN_ID, a.ORIPATCAT_CT, a.ORIPATTYP_CT, a.ORIPATTERN_ID, a.CREUSR_CF, a.CRE_D, a.RATEINDEX_CT, a.ESB_CF                                                                                                                                                                                                          
into #PATSEGSII
 from TPATSEGSII a
  where CLODAT_D=null
    and PER_CF=null
    and not exists(select 1 from TPATSEGSII b
     where a.PATCAT_CT=b.PATCAT_CT
       and a.PATTYP_CT=b.PATTYP_CT
       and a.PATTERN_ID=b.PATTERN_ID
       and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
       and isnull(a.ESB_CF,0)=isnull(b.ESB_CF,0)
       and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
       and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
       and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
       and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
       and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
       and b.CLODAT_D!=null
       and b.PER_CF!=null)
select @erreur=@@error,@lignes=@@rowcount
if @erreur != 0 goto fin
print 'select BEST..TPATSEGSII des patterns pas utilisées dans un inventaire lignes %1!',@lignes

-- [002] La prochaine date de cloture est le dernier jour prochain trimestre
-- pour gérer les mois à 30 et 31 jours, la formule est :
-- prendre le 1er jour du mois de la date cloture actuelle,
-- ajouter 4 mois (on est alors le 1er jour du mois de cloture + 4 mois)
-- et retirer 1 jour (on est alors le dernier jour du mois de cloture + 3 mois)
DECLARE @p_NEW_CLODAT_D DATETIME
SELECT @p_NEW_CLODAT_D =
               DATEADD(DAY, -1
                         ,DATEADD(MONTH, 4,
                            CONVERT(DATE,
                               SUBSTRING(CONVERT(CHAR, @p_CLODAT_D, 102), 1, 8) + '01'
                               , 102
                            )
                          )
                    )


if @@trancount=0
begin
  select @tran_imbr=0
  begin tran
end

if month(@p_clodat_d)=3 and day(@p_clodat_d)=31 and @p_typeinv_cf='INV'
begin
  select @annee=year(@p_clodat_d)
  print 'Suppression des traces de patterns cumulatives et incrémentales pas activées dont l''année bilan n''est pas %1!',@annee
  delete TPATSEGSII
   from TPATSEGSII a
   where PER_CF=null
     and CLODAT_D=null
     and PATCAT_CT in('ICR','CSF')
     and exists(select 1 from TPATTERNSII b where a.SSD_CF=b.SSD_CF
                                              and b.PATCAT_CT=a.PATCAT_CT
                                              and b.PATTYP_CT=a.PATTYP_CT
                                              and a.PATTERN_ID=b.PATTERN_ID
                                              and isnull(a.ESB_CF,0)=isnull(b.ESB_CF,0)
                                              and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                                              and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
                                              and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
                                              and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                                              and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
                                              and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                                              and b.BALSHEY_NF!=@annee)
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATSEGSII ICR CSF CLODAT_D null PER_CF null lignes %1!',@lignes
end

if (select count(1) from #PATSEGSII) > 0
begin
  delete TPATTERNSII
   from TPATTERNSII a, #PATSEGSII b
     where b.PATCAT_CT=case when a.PATCAT_CT='CUM' then 'CSF' when a.PATCAT_CT='ICV' then 'ICR' else a.PATCAT_CT end
       and b.PATTYP_CT=case when a.PATTYP_CT='INF' then 'INFI' else a.PATTYP_CT end
       and a.PATTERN_ID=b.PATTERN_ID
       and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
       and isnull(a.ESB_CF,0)=isnull(b.ESB_CF,0)
       and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
       and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
       and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
       and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
       and ((a.PATCAT_CT='BDT' and isnull(b.SEG_NF,'')=isnull(a.RATING_CF,'')) or (a.PATCAT_CT!='BDT' and isnull(b.SEG_NF,'')=isnull(a.SEG_NF,'')))
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATTERNSII des patterns pas utilisées dans un inventaire %1!',@lignes

 delete TPATTERNSII
  from BEST..TPATTERNSII a, #PATSEGSII t
   where a.PATCAT_CT='DSC'
     and a.PATTYP_CT=t.ORIPATTYP_CT
     and a.PATTERN_ID=t.ORIPATTERN_ID
     and isnull(a.SSD_CF,0)=isnull(t.SSD_CF,0)
     and isnull(a.ESB_CF,0)=isnull(t.ESB_CF,0)
     and isnull(a.SEG_NF,'')=isnull(t.SEG_NF,'')
     and isnull(a.LOB_CF,'')=isnull(t.LOB_CF,'')
     and isnull(a.CUR_CF,'')=isnull(t.CUR_CF,'')
     and isnull(a.NORME_CF,'')=isnull(t.NORME_CF,'')
     and isnull(a.SEGNAT_CT,'')=isnull(t.SEGNAT_CT,'')
     and not exists(select 1 from BEST..TPATSEGSII b
                     where b.PATCAT_CT=a.PATCAT_CT
                       and b.PATTYP_CT='DSI'
                       and a.PATTERN_ID=b.ORIPATTERN_ID
                       and b.ORIPATTYP_CT=a.PATTYP_CT
                       and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
                       and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
                       and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                       and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
                       and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                       and isnull(a.ESB_CF,0)=isnull(b.ESB_CF,0)
                       and b.CLODAT_D!=null
                       and b.PER_CF!=null
                       )
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATTERNSII des patterns DSC/DSC|ILL pas utilisées dans un inventaire %1!',@lignes

  delete TPATSEGSII
   from TPATSEGSII a, #PATSEGSII b
    where a.PATCAT_CT=b.PATCAT_CT
      and a.PATTYP_CT=b.PATTYP_CT
      and a.PATTERN_ID=b.PATTERN_ID
      and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
      and isnull(a.ESB_CF,0)=isnull(b.ESB_CF,0)
      and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
      and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
      and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
      and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
      and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATSEGSII des patterns pas utilisées dans un inventaire lignes %1!',@lignes
end

------------------------------------------
-- Cloture de type INV
------------------------------------------
if @p_typeinv_cf='INV'
begin
  -- Creer des patterns INV sur le trimestre suivant a partir des patterns INV du trimestre
  -- Ecrase ceux qui existaient deja
  --[003]
  --[009] spira:62221 EBS - Quarterly Pattern Modifications with respect to ICV and CUM

  delete BEST..TPATSEGSII
   where CLODAT_D = @p_NEW_CLODAT_D
     and PER_CF   = @p_typeinv_cf
     and ( (PATCAT_CT in('CSF','ICR') and month(@p_clodat_d) != 9) or PATCAT_CT not in('CSF','ICR'))
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATSEGSII CLODAT_D %1! PER_CF %2! lignes %3!',@p_NEW_CLODAT_D,@p_typeinv_cf,@lignes

  delete BEST..TULAERAT
   where CLOSING_D = @p_NEW_CLODAT_D
     and PER_CF    = @p_typeinv_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TULAERAT CLOSING_D %1! PER_CF %2! lignes %3!',@p_NEW_CLODAT_D,@p_typeinv_cf,@lignes

  --[002] nouvelle date de cloture calculée pour gérer les mois de 30 et 31 jours (31 décembre)
  --[009] spira:62221 EBS - Quarterly Pattern Modifications with respect to ICV and CUM
  insert into BEST..TPATSEGSII
  select CLODAT_D=@p_NEW_CLODAT_D,PER_CF,SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID,ORIPATCAT_CT,ORIPATTYP_CT,ORIPATTERN_ID,CREUSR_CF='BOOK',@p_cre_d CRE_D,RATEINDEX_CT,ESB_CF
   from BEST..TPATSEGSII
    where CLODAT_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
      and ( (PATCAT_CT in('CSF','ICR') and month(@p_clodat_d) != 9) or PATCAT_CT not in('CSF','ICR'))
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TPATSEGSII lignes %1!',@lignes

  insert into BEST..TULAERAT
  select SSD_CF,ESB_CF,PER_CF,CLOSING_D=@p_NEW_CLODAT_D,RATIO_NF,CREUSR_CF='BOOK',CRE_D=@p_cre_d
   from BEST..TULAERAT
    where CLOSING_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TULAERAT lignes %1!',@lignes

  -- Creer des patterns POS sur le meme trimestre a partir des patterns INV du trimestre
  -- Ecrase ceux qui existaient deja
  -- modif 1
  delete BEST..TPATSEGSII
   where CLODAT_D = @p_clodat_d
     and PER_CF   = 'POS'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATSEGSII CLODAT_D %1! PER_CF POS lignes %2!',@p_clodat_d,@lignes

  delete BEST..TULAERAT
   where CLOSING_D = @p_clodat_d
     and PER_CF    = 'POS'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TULAERAT CLOSING_D %1! PER_CF POS lignes %2!',@p_clodat_d,@lignes

  insert into BEST..TPATSEGSII
  select CLODAT_D,PER_CF='POS',SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID,ORIPATCAT_CT,ORIPATTYP_CT,ORIPATTERN_ID,CREUSR_CF='BOOK',@p_cre_d CRE_D,RATEINDEX_CT,ESB_CF
   from BEST..TPATSEGSII
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TPATSEGSII lignes %1!',@lignes

  insert into BEST..TULAERAT
  select SSD_CF,ESB_CF,PER_CF='POS',CLOSING_D,RATIO_NF,CREUSR_CF='BOOK',CRE_D=@p_cre_d
   from BEST..TULAERAT
    where CLOSING_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TULAERAT lignes %1!',@lignes
end

------------------------------------------
-- Cloture de type POS (Post Omega Social)
------------------------------------------
if @p_typeinv_cf='POS'
begin
  -- Creer des patterns POC sur le meme trimestre a partir des patterns POS du trimestre
  -- Ecrase ceux qui existaient deja
  -- modif 1
  delete BEST..TPATSEGSII
   where CLODAT_D = @p_clodat_d
     and PER_CF   = 'POC'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATSEGSII CLODAT_D %1! PER_CF POC lignes %2!',@p_clodat_d,@lignes

  delete BEST..TULAERAT
   where CLOSING_D = @p_clodat_d
     and PER_CF    = 'POC'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TULAERAT CLOSING_D %1! PER_CF POC lignes %2!',@p_clodat_d,@lignes

  insert into BEST..TPATSEGSII
  select CLODAT_D,PER_CF='POC',SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID,ORIPATCAT_CT,ORIPATTYP_CT,ORIPATTERN_ID,CREUSR_CF='BOOK',@p_cre_d CRE_D,RATEINDEX_CT,ESB_CF
   from BEST..TPATSEGSII a
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TPATSEGSII lignes %1!',@lignes

  insert into BEST..TULAERAT
  select SSD_CF,ESB_CF,PER_CF='POC',CLOSING_D,RATIO_NF,CREUSR_CF='BOOK',CRE_D=@p_cre_d
   from BEST..TULAERAT
    where CLOSING_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TULAERAT lignes %1!',@lignes

  -- [004]
  -- Creer des patterns POS sur le trimestre suivant a partir des patterns POS du trimestre
  -- Ecrase ceux qui existaient deja
  --[009] spira:62221 EBS - Quarterly Pattern Modifications with respect to ICV and CUM
 
  delete BEST..TPATSEGSII
   where CLODAT_D = @p_NEW_CLODAT_D
     and PER_CF   = 'POS'
     and ( (PATCAT_CT in('CSF','ICR') and month(@p_clodat_d) != 9) or PATCAT_CT not in('CSF','ICR'))
  
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATSEGSII CLODAT_D %1! PER_CF POS lignes %2!',@p_NEW_CLODAT_D,@lignes

  delete BEST..TULAERAT
   where CLOSING_D = @p_NEW_CLODAT_D
     and PER_CF    = 'POS'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TULAERAT CLOSING_D %1! PER_CF POS lignes %2!',@p_NEW_CLODAT_D,@lignes

  --[009] spira:62221 EBS - Quarterly Pattern Modifications with respect to ICV and CUM
  insert into BEST..TPATSEGSII
  select CLODAT_D=@p_NEW_CLODAT_D,PER_CF,SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID,ORIPATCAT_CT,ORIPATTYP_CT,ORIPATTERN_ID,CREUSR_CF='BOOK',@p_cre_d CRE_D,RATEINDEX_CT,ESB_CF
   from BEST..TPATSEGSII
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
      and ( (PATCAT_CT in('CSF','ICR') and month(@p_clodat_d) != 9) or PATCAT_CT not in('CSF','ICR'))
 select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TPATSEGSII lignes %1!',@lignes

  insert into BEST..TULAERAT
  select SSD_CF,ESB_CF,PER_CF,CLOSING_D=@p_NEW_CLODAT_D,RATIO_NF,CREUSR_CF='BOOK',CRE_D=@p_cre_d
   from BEST..TULAERAT
    where CLOSING_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TULAERAT lignes %1!',@lignes

  -- [004]
  -- Creer des patterns INV sur le trimestre suivant a partir des patterns POS du trimestre
  -- Ecrase ceux qui existaient deja
  --[009] spira:62221 EBS - Quarterly Pattern Modifications with respect to ICV and CUM
  delete BEST..TPATSEGSII
   where CLODAT_D = @p_NEW_CLODAT_D
     and PER_CF = 'INV'
     and ( (PATCAT_CT in('CSF','ICR') and  month(@p_clodat_d) != 9) or PATCAT_CT not in('CSF','ICR'))
 
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATSEGSII CLODAT_D %1! PER_CF INV lignes %2!',@p_NEW_CLODAT_D,@lignes

  delete BEST..TULAERAT
   where CLOSING_D = @p_NEW_CLODAT_D
     and PER_CF    = 'INV'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TULAERAT CLOSING_D %1! PER_CF INV lignes %2!',@p_NEW_CLODAT_D,@lignes

  --[009] spira:62221 EBS - Quarterly Pattern Modifications with respect to ICV and CUM
  insert into BEST..TPATSEGSII
  select CLODAT_D=@p_NEW_CLODAT_D,PER_CF='INV',SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID,ORIPATCAT_CT,ORIPATTYP_CT,ORIPATTERN_ID,CREUSR_CF='BOOK',@p_cre_d CRE_D,RATEINDEX_CT,ESB_CF
   from BEST..TPATSEGSII
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
      and ( (PATCAT_CT in('CSF','ICR') and month(@p_clodat_d) != 9) or PATCAT_CT not in('CSF','ICR'))
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TPATSEGSII lignes %1!',@lignes

  insert into BEST..TULAERAT
  select SSD_CF,ESB_CF,PER_CF='INV',CLOSING_D=@p_NEW_CLODAT_D,RATIO_NF,CREUSR_CF='BOOK',CRE_D=@p_cre_d
   from BEST..TULAERAT
    where CLOSING_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TULAERAT lignes %1!',@lignes
end



if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
EXEC sp_procxmode 'dbo.PuSOLVENCY_02', 'unchained'
go
IF OBJECT_ID('dbo.PuSOLVENCY_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuSOLVENCY_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuSOLVENCY_02 >>>'
go
GRANT EXECUTE ON dbo.PuSOLVENCY_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuSOLVENCY_02 TO GDBBATCH
go
