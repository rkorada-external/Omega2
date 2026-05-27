use BEST
go
if object_id('PsSECTION_13') is not null
begin
  drop PROC PsSECTION_13
  print '<<< DROPPED PROC PsSECTION_13 >>>'
end
go
create procedure PsSECTION_13
  (
  @p_option    char(1)
 ,@p_segtyp_ct char(1)
 ,@p_segtyp_ct2 char(1) = null
  )
with execute as caller as
/***************************************************
Domaine:                 Estimations
Base principale:         BEST
Version:                 1
Auteur:                  ME31 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: Descente de la table TSEGEST pour la g.tion et l'inventaire
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1 Roger Cassis 25/05/2012 :spot:23802 - Modifications pour Solvency - Ajout test sur segtyp = S
2 Roger Cassis 29/10/2012 :spot:24041 - Modifications Solvency - pas de jointure filiale pour T et U
3                         Removed dbo and added ‘with execute as caller as’
4 -=Dch=-      12/08/2013 :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
5  Florent     04/06/2015 :spot:28694 Segmentation VIE, ici sélection uniquement des dommages !
06 JYP         05/10/2018 : IFRS17 req 10.6 : extract new loss ratio, SEGTYP_CT2 V/W/X 
07 JYP         25/02/2019 : IFRS17 req 10.6 : new rule : use segtyp A in TSEGMENT table
08 R.CASSIS    29/06/2021 :spira:97314 SEGTYP used are now the ones from parm values. value 'S' not used now.
--  For INV IFRS4        ->  Loss Ratio type = A (selected into shell sort)
--  For EBS INV          ->  Loss Ratio type = A and V
--  For EBS POS+IFRS17   ->  Loss Ratio type = W and T
--  For EBS POC+IFRS17   ->  Loss Ratio type = X and U   
[09] R.CASSIS    01/09/2021 :spira:97398 Ajout p_segtyp_ct = 'V' dans condition sur TSEGEST
*****************************************************/
declare  @erreur int ,@segtyp_ct_sii char(1)  , @segtyp_ct_sii2 char(1)

declare @curr_usr UUPDUSR_CF 
select @curr_usr = suser_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr


if @p_segtyp_ct in('S','T','U')
  select @segtyp_ct_sii='A'
else
  select @segtyp_ct_sii=@p_segtyp_ct
  
--if @p_segtyp_ct2 in('W','X')
if @p_segtyp_ct2 in('V','W','X')  --[09]
  select @segtyp_ct_sii2='A'
else
  select @segtyp_ct_sii2=@p_segtyp_ct2


-- Cas multifiliale (inventaire)
-- La liste des filiales est dans la table BTRAV..TESTSSD
--if @p_option = 'I'
--begin
  if @p_segtyp_ct in('T','U')
     ---------------------------------------------- new IFRS17 context / double LR with SEGTYP_CT field
     begin
     select distinct e.SSD_CF, e.SEG_NF, UWY_NF, e.CUR_CF, SEGNAT_CT, CLMAMT_M, LOSRAT_R, AMORAT_CT, e.SEGTYP_CT
     from best..TSEGEST e, best..TSEGMENT g
      where e.SEGTYP_CT=@p_segtyp_ct
        and e.VRS_NF=(select max(VRS_NF) from best..TSEGEST s where s.SSD_CF=e.SSD_CF and s.SEGTYP_CT =@p_segtyp_ct)
        and e.VRS_NF=g.VRS_NF
        and e.SSD_CF=g.SSD_CF
        and e.SEG_NF=g.SEG_NF
        and g.SEGTYP_CT=@segtyp_ct_sii
        and exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=e.SSD_CF)
        and e.SSD_CF in ( select SSD_CF from #ssds )
	   UNION
	   select distinct e.SSD_CF, e.SEG_NF, UWY_NF, e.CUR_CF, SEGNAT_CT, CLMAMT_M, LOSRAT_R, AMORAT_CT, e.SEGTYP_CT
      from best..TSEGEST e, best..TSEGMENT g
      where e.SEGTYP_CT=@p_segtyp_ct2
        and e.VRS_NF=(select max(VRS_NF) from best..TSEGEST s where s.SSD_CF=e.SSD_CF and s.SEGTYP_CT =@p_segtyp_ct2)
        and e.VRS_NF=g.VRS_NF
        and e.SSD_CF=g.SSD_CF
        and e.SEG_NF=g.SEG_NF
        and g.SEGTYP_CT=@segtyp_ct_sii2
        and exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=e.SSD_CF)
        and e.SSD_CF in ( select SSD_CF from #ssds )
	end

  	
  else  --- segment type A and V
    begin
     ---------------------------------------------- new IFRS17 / double LR with SEGTYP_CT field   
     select e.SSD_CF, e.SEG_NF, UWY_NF, e.CUR_CF, SEGNAT_CT, CLMAMT_M, LOSRAT_R, AMORAT_CT,  e.SEGTYP_CT
     from TSEGEST e, TSEGMENT g, BTRAV..TESTSSD s
      where e.SEGTYP_CT=@p_segtyp_ct
        and e.SSD_CF=s.SSD_CF
        and e.VRS_NF=s.VRS_NF
        and e.VRS_NF=g.VRS_NF
        and e.SSD_CF=g.SSD_CF
        and e.SEG_NF=g.SEG_NF
        and g.SEGTYP_CT=@segtyp_ct_sii  
        and e.SSD_CF in ( select SSD_CF from #ssds )
        and exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=e.SSD_CF)
     UNION
     select e.SSD_CF, e.SEG_NF, UWY_NF, e.CUR_CF, SEGNAT_CT, CLMAMT_M, LOSRAT_R, AMORAT_CT,  e.SEGTYP_CT
     from TSEGEST e, TSEGMENT g, BTRAV..TESTSSD s
      where e.SEGTYP_CT=@p_segtyp_ct2 
        and e.SSD_CF=s.SSD_CF
        and e.VRS_NF=s.VRS_NF
        and e.VRS_NF=g.VRS_NF
        and e.SSD_CF=g.SSD_CF
        and e.SEG_NF=g.SEG_NF
        and g.SEGTYP_CT=@segtyp_ct_sii2    
        and e.SSD_CF in ( select SSD_CF from #ssds )
        and exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=e.SSD_CF)
    end		
--end
--
---- Cas multifiliale (segmentation)
---- La liste des filiales est dans la table BTRAV..TESTSSDTMP
--else if @p_option = 'S'
--begin
--  if @p_segtyp_ct in('T','U')
--    select distinct e.SSD_CF, e.SEG_NF, UWY_NF, e.CUR_CF, SEGNAT_CT, CLMAMT_M, LOSRAT_R, AMORAT_CT 
--     from best..TSEGEST e, best..TSEGMENT g
--      where e.SEGTYP_CT=@p_segtyp_ct
--        and e.VRS_NF=(select max(VRS_NF) from best..TSEGEST x where x.SSD_CF=e.SSD_CF and x.SEGTYP_CT=@p_segtyp_ct)
--        and e.VRS_NF=g.VRS_NF
--        and e.SSD_CF=g.SSD_CF
--        and e.SEG_NF=g.SEG_NF
--        and g.SEGTYP_CT=@segtyp_ct_sii
--        and e.SSD_CF in ( select SSD_CF from #ssds )
--        and exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=e.SSD_CF)
--  else
--    select e.SSD_CF, e.SEG_NF, UWY_NF, e.CUR_CF, SEGNAT_CT, CLMAMT_M, LOSRAT_R, AMORAT_CT 
--     from TSEGEST e, TSEGMENT g, BTRAV..TESTSSDTMP s
--      where e.SEGTYP_CT=@p_segtyp_ct
--        and e.SSD_CF=s.SSD_CF
--        and e.VRS_NF=s.VRS_NF
--        and s.SEGTYP_CT=@segtyp_ct_sii
--        and e.VRS_NF=g.VRS_NF
--        and e.SSD_CF=g.SSD_CF
--        and e.SEG_NF=g.SEG_NF
--        and g.SEGTYP_CT=@segtyp_ct_sii -- modif 1 ajout
--        and e.SSD_CF in ( select SSD_CF from #ssds )
--        and exists(select 1 from BREF..TESB x where x.LIFE_CF=2 and x.SSD_CF=e.SSD_CF)
--end
select @erreur = @@error
if @erreur != 0
   return @erreur

return 0
go
if object_id('PsSECTION_13') is not null
  print '<<< CREATED PROC PsSECTION_13 >>>'
else
  print '<<< FAILED CREATING PROC PsSECTION_13 >>>'
go
grant execute on PsSECTION_13 TO GOMEGA
go
GRANT EXECUTE ON PsSECTION_13 TO GDBBATCH
go
