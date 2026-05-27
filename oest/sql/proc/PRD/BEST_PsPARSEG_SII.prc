use BEST
go
if object_id('dbo.PsPARSEG_SII') IS NOT null
begin
  drop PROC dbo.PsPARSEG_SII
  print '<<< DROPPED PROC dbo.PsPARSEG_SII >>>'
end
go
create procedure PsPARSEG_SII
  (
  @p_LAG_CF ULAG_CF='F'
 ,@p_SSD_CF USSD_CF=null
  )
as
/***************************************************
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : Florent
Date de creation         : 27/03/2012
Description du programme : :spot:23390 SOLVENCY II
Conditions d'execution :
Commentaires : pour la sélection des type de segment
_________________
MODIFICATIONS
  Auteur   Date       Description
*****************************************************/
select a.SEGTYP_CT,SEGTYP_LS=b.COLVAL_LS
 from TPARSEG a, BREF..TBANTECL b
  where SSD_CF=@p_SSD_CF
    and col_ls='SEGTYP_CT'
    and lag_cf=@p_LAG_CF
    and PERIM_LAUNCH=1
    and a.SEGTYP_CT=b.COLVAL_CT
go
if object_id('dbo.PsPARSEG_SII') IS NOT null
  print '<<< CREATED PROC dbo.PsPARSEG_SII >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsPARSEG_SII >>>'
go
GRANT execute on dbo.PsPARSEG_SII TO GOMEGA
go
