use BEST
go
if object_id('PsFVSEGEST_01') is not null
begin
  drop PROC PsFVSEGEST_01
  print '<<< DROPPED PROC PsFVSEGEST_01 >>>'
end
go
create procedure PsFVSEGEST_01
  (
  @p_option    char(1)
 ,@p_segtyp_ct char(1)
  )
with execute as caller as
/***************************************************
Domaine:                  Estimations
Base principale:          BEST
Auteur:                   Florent
Date de creation:         04/06/2015
Description du programme: Descente de la table TSEGEST pour la g.tion et l'inventaire
                          :spot:28694 Segmentation VIE, ici sélection uniquement de la VIE
Conditions d'execution:
Commentaires:            création à partir de PsSECTION_10 pour la VIE
_________________
MODIFICATIONS
*****************************************************/
declare  @erreur int ,@segtyp_ct_sii char(1) 

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr

if @p_segtyp_ct in('S','T','U')
  select @segtyp_ct_sii='A'
else
  select @segtyp_ct_sii=@p_segtyp_ct

-- Cas multifiliale (inventaire)
-- La liste des filiales est dans la table BTRAV..TESTSSD
if @p_option = 'I'
begin
  if @p_segtyp_ct in('T','U')
    select distinct e.SSD_CF, e.SEG_NF, UWY_NF, e.CUR_CF, SEGNAT_CT, CLMAMT_M, LOSRAT_R, AMORAT_CT, ACY_NF
     from best..TSEGEST e, best..TSEGMENT g
      where e.SEGTYP_CT=@p_segtyp_ct
        and e.VRS_NF=(select max(VRS_NF) from best..TSEGEST s where s.SSD_CF=e.SSD_CF and s.SEGTYP_CT =@p_segtyp_ct)
        and e.VRS_NF=g.VRS_NF
        and e.SSD_CF=g.SSD_CF
        and e.SEG_NF=g.SEG_NF
        and g.SEGTYP_CT=@segtyp_ct_sii
        and not exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=e.SSD_CF)
        and e.SSD_CF in ( select SSD_CF from #ssds )
  else
    select e.SSD_CF, e.SEG_NF, UWY_NF, e.CUR_CF, SEGNAT_CT, CLMAMT_M, LOSRAT_R, AMORAT_CT, ACY_NF
     from TSEGEST e, TSEGMENT g, BTRAV..TESTSSD s
      where e.SEGTYP_CT=@p_segtyp_ct
        and e.SSD_CF=s.SSD_CF
        and e.VRS_NF=s.VRS_NF
        and e.VRS_NF=g.VRS_NF
        and e.SSD_CF=g.SSD_CF
        and e.SEG_NF=g.SEG_NF
        and g.SEGTYP_CT=@segtyp_ct_sii -- modif 1 ajout
        and not exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=e.SSD_CF)
end

-- Cas multifiliale (segmentation)
-- La liste des filiales est dans la table BTRAV..TESTSSDTMP
else if @p_option = 'S'
begin
  if @p_segtyp_ct in('T','U')
    select distinct e.SSD_CF, e.SEG_NF, UWY_NF, e.CUR_CF, SEGNAT_CT, CLMAMT_M, LOSRAT_R, AMORAT_CT, ACY_NF
     from best..TSEGEST e, best..TSEGMENT g
      where e.SEGTYP_CT=@p_segtyp_ct
        and e.VRS_NF=(select max(VRS_NF) from best..TSEGEST x where x.SSD_CF=e.SSD_CF and x.SEGTYP_CT=@p_segtyp_ct)
        and e.VRS_NF=g.VRS_NF
        and e.SSD_CF=g.SSD_CF
        and e.SEG_NF=g.SEG_NF
        and g.SEGTYP_CT=@segtyp_ct_sii
        and e.SSD_CF in ( select SSD_CF from #ssds )
        and not exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=e.SSD_CF)
  else
    select e.SSD_CF, e.SEG_NF, UWY_NF, e.CUR_CF, SEGNAT_CT, CLMAMT_M, LOSRAT_R, AMORAT_CT, ACY_NF
     from TSEGEST e, TSEGMENT g, BTRAV..TESTSSDTMP s
      where e.SEGTYP_CT=@p_segtyp_ct
        and e.SSD_CF=s.SSD_CF
        and e.VRS_NF=s.VRS_NF
        and s.SEGTYP_CT=@segtyp_ct_sii
        and e.VRS_NF=g.VRS_NF
        and e.SSD_CF=g.SSD_CF
        and e.SEG_NF=g.SEG_NF
        and g.SEGTYP_CT=@segtyp_ct_sii -- modif 1 ajout
        and not exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=e.SSD_CF)
end
select @erreur = @@error
if @erreur != 0
   return @erreur

return 0
go
if object_id('PsFVSEGEST_01') is not null
  print '<<< CREATED PROC PsFVSEGEST_01 >>>'
else
  print '<<< FAILED CREATING PROC PsFVSEGEST_01 >>>'
go
grant execute on PsFVSEGEST_01 TO GOMEGA
go
GRANT EXECUTE ON PsFVSEGEST_01 TO GDBBATCH
go
