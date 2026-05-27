use BEST
go
if object_id('dbo.PfES_PATSEGSII_01') is not null
begin
  drop PROC dbo.PfES_PATSEGSII_01
  print '<<< DROPPED PROC dbo.PfES_PATSEGSII_01 >>>'
end
go
create procedure PfES_PATSEGSII_01
  @p_nb_lignes              int,
  @p_etape         char(1)
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 11/07/2012
Description du programme: :spot:23390 (SOLVENCY)
Conditions d'execution: fenêtre de recherche w_recherche_es_sii_patseg
Commentaires:
_________________
MODIFICATIONS
*****************************************************/
if @p_etape = 'O'
begin
  SET cursor rows @p_nb_lignes FOR BigList_Curs_ES_PATSEGSII_01
  OPEN BigList_Curs_ES_PATSEGSII_01
  select @p_etape  = 'F'
end

if @p_etape = 'F'
begin
  fetch Biglist_curs_ES_PATSEGSII_01
  if @@sqlstatus=2
  begin
    CLOSE BigList_Curs_ES_PATSEGSII_01
    DEALLOCATE cursor BigList_Curs_ES_PATSEGSII_01
    raiserror 25000 'fin de liste'
    return -1
  end
end

if @p_etape = 'C'
begin
  CLOSE BigList_Curs_ES_PATSEGSII_01
  DEALLOCATE cursor BigList_Curs_ES_PATSEGSII_01
end

return
go
if object_id('dbo.PfES_PATSEGSII_01') is not null
  print '<<< CREATED PROC dbo.PfES_PATSEGSII_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PfES_PATSEGSII_01 >>>'
go
grant execute on dbo.PfES_PATSEGSII_01 TO GOMEGA
go
