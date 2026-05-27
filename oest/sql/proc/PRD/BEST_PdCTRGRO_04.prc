use BEST
go
if object_id('dbo.PdCTRGRO_04') is not null
begin
  drop PROC dbo.PdCTRGRO_04
  print '<<< DROPPED PROC dbo.PdCTRGRO_04 >>>'
end
go
create procedure PdCTRGRO_04
  (
  @p_ssd_cf    USSD_CF
 ,@p_vrs_nf    numeric(10,0)
 ,@p_segtyp_ct char(1)
  )
as
/***************************************************
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: Suppression partielle d'une version pour rechargement
Conditions d'execution:
Commentaires:
_________________
1  Florent   14/02/2012 :spot:23390 SOLVENCY II
*****************************************************/
declare
  @erreur           int
 ,@segtyp_SII USEGTYP_CT     -- modif 1

-- on n'aura pas de type S ici, mais pour faire TSEGEST il faut prendre les type S quand on traite le type A
if @p_segtyp_ct='A'
  select @segtyp_SII='S'
else
  select @segtyp_SII=@p_segtyp_ct

select @erreur=0
-- Suppression partielle version

delete BEST..TSEGANO
where  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
select @erreur = @@error
if @erreur != 0 goto fin

delete BEST..TSEGEST
where  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT in(@segtyp_SII,@p_segtyp_ct)
select @erreur = @@error
if @erreur != 0 goto fin

delete BEST..TLABOCY
where  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
select @erreur = @@error
if @erreur != 0 goto fin

fin:
if @erreur != 0 return @erreur

return 0
go
if object_id('dbo.PdCTRGRO_04') is not null
  print '<<< CREATED PROC dbo.PdCTRGRO_04 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PdCTRGRO_04 >>>'
go
grant execute on dbo.PdCTRGRO_04 TO GOMEGA
go
