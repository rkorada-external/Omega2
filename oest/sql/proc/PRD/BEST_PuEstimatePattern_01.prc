use BEST
go


/*
 * DROP PROC dbo.PuEstimatePattern_01 */
IF OBJECT_ID('dbo.PuEstimatePattern_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PuEstimatePattern_01
    PRINT '<<< DROPPED PROC dbo.PuEstimatePattern_01 >>>'
END
go

/*
 * creation de la procedure */
create procedure PuEstimatePattern_01(
  @p_clodat_d   datetime,
  @p_cre_d      datetime,
  @p_typeinv_cf char(3),
		@p_norme_cf varchar(4),
		@p_creusr_cf   varchar(4)
)

as
/***************************************************
Programme:                  PuEstimatePattern_01
Domaine :                   Estimation
Base principale :           BEST
Version:                    1
Auteur:                     Arnaud RUFFAULT
Date de creation:           07/10/2021
Description du programme:   
Renewall of the estimate patterns
_________________
MODIFICATIONS
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
				and ((@p_norme_cf in ('I4I', 'EBS') and NORME_CF in (null, 'SII', 'IFRSI', 'GIM', 'ALLNO', 'EV')) or @p_norme_cf = NORME_CF )
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

-- La prochaine date de cloture est le dernier jour prochain trimestre
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
					and ((@p_norme_cf in ('I4I', 'EBS') and NORME_CF in (null, 'SII', 'IFRSI', 'GIM', 'ALLNO', 'EV')) or @p_norme_cf = NORME_CF )
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
							and ((@p_norme_cf in ('I4I', 'EBS') and a.NORME_CF in (null, 'SII', 'IFRSI', 'GIM', 'ALLNO', 'EV')) or @p_norme_cf = a.NORME_CF )
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
					and ((@p_norme_cf in ('I4I', 'EBS') and a.NORME_CF in (null, 'SII', 'IFRSI', 'GIM', 'ALLNO', 'EV')) or @p_norme_cf = a.NORME_CF )
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
						and ((@p_norme_cf in ('I4I', 'EBS') and a.NORME_CF in (null, 'SII', 'IFRSI', 'GIM', 'ALLNO', 'EV')) or @p_norme_cf = a.NORME_CF )
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

  -- Creer des patterns POS sur le meme trimestre a partir des patterns INV du trimestre
  -- Ecrase ceux qui existaient deja
  delete BEST..TPATSEGSII
   where CLODAT_D = @p_clodat_d
     and PER_CF   = 'POS'
					and ((@p_norme_cf in ('I4I', 'EBS') and NORME_CF in (null, 'SII', 'IFRSI', 'GIM', 'ALLNO', 'EV')) or @p_norme_cf = NORME_CF )
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATSEGSII CLODAT_D %1! PER_CF POS lignes %2!',@p_clodat_d,@lignes

  insert into BEST..TPATSEGSII
  select CLODAT_D,PER_CF='POS',SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID,ORIPATCAT_CT,ORIPATTYP_CT,ORIPATTERN_ID,CREUSR_CF=@p_creusr_cf,@p_cre_d CRE_D,RATEINDEX_CT,ESB_CF
   from BEST..TPATSEGSII
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
						and ((@p_norme_cf in ('I4I', 'EBS') and NORME_CF in (null, 'SII', 'IFRSI', 'GIM', 'ALLNO', 'EV')) or @p_norme_cf = NORME_CF )
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TPATSEGSII lignes %1!',@lignes

end

------------------------------------------
-- Cloture de type POS (Post Omega Social)
------------------------------------------
if @p_typeinv_cf='POS'
begin
  -- Creer des patterns POC sur le meme trimestre a partir des patterns POS du trimestre
  -- Ecrase ceux qui existaient deja
  delete BEST..TPATSEGSII
   where CLODAT_D = @p_clodat_d
     and PER_CF   = 'POC'
					and ((@p_norme_cf in ('I4I', 'EBS') and NORME_CF in (null, 'SII', 'IFRSI', 'GIM', 'ALLNO', 'EV')) or @p_norme_cf = NORME_CF )
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATSEGSII CLODAT_D %1! PER_CF POC lignes %2!',@p_clodat_d,@lignes


  insert into BEST..TPATSEGSII
  select CLODAT_D,PER_CF='POC',SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID,ORIPATCAT_CT,ORIPATTYP_CT,ORIPATTERN_ID,CREUSR_CF=@p_creusr_cf,@p_cre_d CRE_D,RATEINDEX_CT,ESB_CF
   from BEST..TPATSEGSII a
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
						and ((@p_norme_cf in ('I4I', 'EBS') and NORME_CF in (null, 'SII', 'IFRSI', 'GIM', 'ALLNO', 'EV')) or @p_norme_cf = NORME_CF )
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TPATSEGSII lignes %1!',@lignes


  -- Creer des patterns INV sur le trimestre suivant a partir des patterns POS du trimestre
  -- Ecrase ceux qui existaient deja
  -- EBS - Quarterly Pattern Modifications with respect to ICV and CUM
  delete BEST..TPATSEGSII
   where CLODAT_D = @p_NEW_CLODAT_D
     and PER_CF = 'INV'
					and ((@p_norme_cf in ('I4I', 'EBS') and NORME_CF in (null, 'SII', 'IFRSI', 'GIM', 'ALLNO', 'EV')) or @p_norme_cf = NORME_CF )
     and ( (PATCAT_CT in('CSF','ICR') and  month(@p_clodat_d) != 9) or PATCAT_CT not in('CSF','ICR'))
 
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TPATSEGSII CLODAT_D %1! PER_CF INV lignes %2!',@p_NEW_CLODAT_D,@lignes


  -- EBS - Quarterly Pattern Modifications with respect to ICV and CUM
  insert into BEST..TPATSEGSII
  select CLODAT_D=@p_NEW_CLODAT_D,PER_CF='INV',SSD_CF,SEG_NF,LOB_CF,CUR_CF,NORME_CF,SEGNAT_CT,PATCAT_CT,PATTYP_CT,PATTERN_ID,ORIPATCAT_CT,ORIPATTYP_CT,ORIPATTERN_ID,CREUSR_CF=@p_creusr_cf,@p_cre_d CRE_D,RATEINDEX_CT,ESB_CF
   from BEST..TPATSEGSII
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
						and ((@p_norme_cf in ('I4I', 'EBS') and NORME_CF in (null, 'SII', 'IFRSI', 'GIM', 'ALLNO', 'EV')) or @p_norme_cf = NORME_CF )
      and ( (PATCAT_CT in('CSF','ICR') and month(@p_clodat_d) != 9) or PATCAT_CT not in('CSF','ICR'))
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TPATSEGSII lignes %1!',@lignes

end



if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
EXEC sp_procxmode 'dbo.PuEstimatePattern_01', 'unchained'
go

IF OBJECT_ID('dbo.PuEstimatePattern_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PuEstimatePattern_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PuEstimatePattern_01 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PuEstimatePattern_01 */
GRANT EXECUTE ON dbo.PuEstimatePattern_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuEstimatePattern_01 TO GDBBATCH
go

