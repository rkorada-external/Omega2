USE BEST
go
set nocount on
declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Debut  '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go
declare
  @erreur      int
 ,@p_CRE_D        UUPD_D
 ,@clodat_d    datetime
 ,@per_cf      char(3)
 ,@annee_clo   smallint

select @p_CRE_D = getdate()
exec @erreur=BREF..PsCALEND_EBS @p_CRE_D,1,@clodat_d output, @per_cf output

select @annee_clo=year(@clodat_d)

print 'Suppression des traces de patterns cumulatives et incrémentales dont l''année bilan n''est pas %1!',@annee_clo

delete TPATSEGSII
 from TPATSEGSII a
 where PATCAT_CT in('ICR','CSF')
   and exists(select 1 from TPATTERNSII b where a.SSD_CF=b.SSD_CF
                                            and b.PATCAT_CT=a.PATCAT_CT
                                            and b.PATTYP_CT=a.PATTYP_CT
                                            and a.PATTERN_ID=b.PATTERN_ID
                                            and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                                            and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'') 
                                            and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
                                            and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                                            and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
                                            and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                                            and ((a.CLODAT_D=null and b.BALSHEY_NF!=@annee_clo) or b.BALSHEY_NF!=year(a.CLODAT_D)) )
go
print 'suppression des traces de patterns qui viennent de plantage'
go
select distinct cre_d=clodat_d
into #delpat
 from  BEST..TPATSEGSII where PER_CF in('NEW','DUPLI')
go
delete BEST..TPATTERNSII from BEST..TPATTERNSII where cre_d in (select cre_d from #delpat)
go
delete BEST..TPATSEGSII where PER_CF in('NEW','DUPLI')
go
print 'suppression des traces de patterns qui sont dans aucune période d''inventaire'
go
delete TPATSEGSII where clodat_d=null
go
print 'suppression des traces de patterns qui ne pointe sur aucune patterns'
go
delete TPATSEGSII
 from TPATSEGSII a
  where not exists(select 1 from TPATTERNSII b
     where a.PATCAT_CT=b.PATCAT_CT
       and a.PATTYP_CT=b.PATTYP_CT
       and a.PATTERN_ID=b.PATTERN_ID
       and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
       and ((a.PATCAT_CT='BDT' and isnull(a.SEG_NF,'')=isnull(b.RATING_CF,'')) or (a.PATCAT_CT!='BDT' and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')))
       and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
       and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
       and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
       and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'') )
go
print 'suppression des patterns qui n''ont pas de traces, corrige les bug de dédoublements'
go
print 'Pour les cumulatives et incrémentales'
go
delete TPATTERNSII
 from TPATTERNSII a
   where PATCAT_CT in('CUM','ICV','CSF','ICR')
     and not exists(select 1 from TPATSEGSII b
                     where b.PATCAT_CT=case when a.PATCAT_CT='CUM' then 'CSF' when a.PATCAT_CT='ICV' then 'ICR' else a.PATCAT_CT end
                       and b.PATTYP_CT=a.PATTYP_CT
                       and a.PATTERN_ID=b.PATTERN_ID
                       and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
                       and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
                       and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
                       and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                       and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
                       and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                       )
go
print 'Pour les bad debt'
go
delete TPATTERNSII
 from TPATTERNSII a
   where PATCAT_CT='BDT'
     and not exists(select 1 from TPATSEGSII b
                     where b.PATCAT_CT=a.PATCAT_CT
                       and b.PATTYP_CT=a.PATTYP_CT
                       and a.PATTERN_ID=b.PATTERN_ID
                       and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
                       and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
                       and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
                       and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                       and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
                       and isnull(a.RATING_CF,'')=isnull(b.SEG_NF,'')
                       )
go
print 'Pour les discount illiquidity'
go
delete TPATTERNSII
 from BEST..TPATTERNSII a
   where PATCAT_CT='DSC'
     and not exists(select 1 from BEST..TPATSEGSII b
                     where b.PATCAT_CT=a.PATCAT_CT
                       and b.PATTYP_CT='DSI'
                       and ((a.PATTERN_ID=b.PATTERN_ID and a.PATTYP_CT='DSI') or (a.PATTERN_ID=b.ORIPATTERN_ID and b.ORIPATTYP_CT=a.PATTYP_CT))
                       and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
                       and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
                       and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                       and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
                       and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                       )
go
print 'Pour les inflations'
go
delete TPATTERNSII
 from TPATTERNSII a
   where PATCAT_CT='INF'
     and not exists(select 1 from TPATSEGSII b
                     where b.PATCAT_CT=a.PATCAT_CT
                       and b.PATTYP_CT='INFI'
                       and a.PATTERN_ID=b.ORIPATTERN_ID
                       and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
                       and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
                       and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                       and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
                       and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                       )
go
declare
  @erreur      int
 ,@p_CRE_D     UUPD_D
 ,@clodat_d    datetime
 ,@per_cf      char(3)

select @p_CRE_D = getdate()
exec @erreur=BREF..PsCALEND_EBS @p_CRE_D,1,@clodat_d output, @per_cf output

print 'Suppression des doublons =>Correction sur la période %1!/%2!',@clodat_d,@per_cf

update TPATSEGSII
 set CLODAT_D=null
    ,PER_CF=null
    ,CRE_D=getdate()
    ,CREUSR_CF=suser_name()
 from best..TPATSEGSII a
  where (select count(*) from best..TPATSEGSII b
                where a.PATCAT_CT=b.PATCAT_CT
                  and a.PATTYP_CT=b.PATTYP_CT
                  and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
                  and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                  and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
                  and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                  and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
                  and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
                  and isnull(a.ORIPATCAT_CT,'')=isnull(b.ORIPATCAT_CT,'')
                  and isnull(a.ORIPATTYP_CT,'')=isnull(b.ORIPATTYP_CT,'')
                  and a.CLODAT_D=b.CLODAT_D
                  and a.PER_CF=b.PER_CF
               ) > 1
    and PATTERN_ID!=(select max(PATTERN_ID) from best..TPATSEGSII b
                where a.PATCAT_CT=b.PATCAT_CT
                  and a.PATTYP_CT=b.PATTYP_CT
                  and isnull(a.SSD_CF,0)=isnull(b.SSD_CF,0)
                  and isnull(a.SEG_NF,'')=isnull(b.SEG_NF,'')
                  and isnull(a.LOB_CF,'')=isnull(b.LOB_CF,'')
                  and isnull(a.CUR_CF,'')=isnull(b.CUR_CF,'')
                  and isnull(a.NORME_CF,'')=isnull(b.NORME_CF,'')
                  and isnull(a.SEGNAT_CT,'')=isnull(b.SEGNAT_CT,'')
                  and isnull(a.ORIPATCAT_CT,'')=isnull(b.ORIPATCAT_CT,'')
                  and isnull(a.ORIPATTYP_CT,'')=isnull(b.ORIPATTYP_CT,'')
                  and a.CLODAT_D=b.CLODAT_D
                  and a.PER_CF=b.PER_CF)
    and clodat_d=@clodat_d
    and PER_CF=@per_cf
go
set nocount on                                                                                                                      
declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go
