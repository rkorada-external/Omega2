USE BREF
go
IF OBJECT_ID('dbo.PsCALEND_EBS') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsCALEND_EBS
    IF OBJECT_ID('dbo.PsCALEND_EBS') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsCALEND_EBS >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsCALEND_EBS >>>'
END
go
create procedure dbo.PsCALEND_EBS
  (
  @p_date     datetime
 ,@p_batch    bit=0
 ,@p_clodat_d datetime=null output
 ,@p_per_cf   char(3)=null output
 ,@p_ret      UL64=null output
  )
as
set nocount on
/***************************************************
Domaine : Estimation
Base principale : BREF
Auteur: Florent
Date de creation: 12/07/2012
Description du programme: :spot:23390 sélection dans TCALEND pour obtenir le segment type autorisé en importation
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1 Florent     30/11/2012  :spot:24041  Solvency II ode batch pour avoir la période et la date de clôture en cours
2 C DESPRET   08/12/2014  :spot:28352  La periode CONSO EBS va jusqu'a la periode exceptionnelle du trimestre suivant
*****************************************************/
declare
 @erreur                int
,@blcshtyea_nf          smallint
,@blcshtmth_nf          tinyint
,@account_d             datetime
,@Nextaccount_d         datetime
--[002] Fin periode excepetionnelle
,@Nextspecend_d         datetime
,@closing_b             bit
,@END_D                 datetime
,@STR_D                 datetime
,@EBS_PSTOM_CONSO_END_D datetime
,@EBSPSTOMGEND_D        datetime
,@site                  varchar(9)

-- Remarque : dans la clause 'where', les datetime sont transformés
-- en char(10) pour éliminer les heures (à midi, on repart à zéro
-- confusion midi / minuit
-- derniere date de compta
select @account_d=max(ACCOUNT_D) from BREF..TCALEND B where convert(Char(10),@p_date,112)>=convert(Char(10),dateadd(MM,+0,ACCOUNT_D),112) and closing_b=1
select @Nextaccount_d=min(ACCOUNT_D) from BREF..TCALEND B where convert(Char(10),@account_d,112)<convert(Char(10),dateadd(MM,+0,ACCOUNT_D),112) and closing_b=1

-- [002] Fin periode exceptionnelle
SELECT @Nextspecend_d = SPECEND_D FROM BREF..TCALEND B WHERE ACCOUNT_D = @Nextaccount_d

select
  @END_D = end_d
 ,@blcshtyea_nf = blcshtyea_nf
 ,@blcshtmth_nf = blcshtmth_nf
 ,@EBSPSTOMGEND_D = EBSPSTOMGEND_D
--[002] Fin periode conso = periode exceptionnelle du prochain trimestre
-- ,@EBS_PSTOM_CONSO_END_D=dateadd(DD,-21,@Nextaccount_d)
 ,@EBS_PSTOM_CONSO_END_D= @Nextspecend_d
 ,@closing_b = closing_b
from BREF..TCALEND A
where convert(Char(10),@account_d,112)=convert(Char(10),ACCOUNT_D,112) and closing_b=1

-- le test est le même mais envoi différent, donc si modif changer dans les 2 tests
if @p_batch=0
begin
  -- attention il y a une tabulation entre le libellé et le code en 1 lettre à la fin
  -- case when @p_date< @account_d then 'Solvency normale '+char(9)+'S'
  select @p_ret = case when @account_d <= @p_date and @p_date <= @EBSPSTOMGEND_D then 'Solvency Post Omega Social'+char(9)+'T'
              when @p_date <= @EBS_PSTOM_CONSO_END_D then 'Solvency Post Omega Conso'+char(9)+'U'
              else '' end
end
else
begin
print 'Date en entrée %1!, comptabilisation %2!, EBS POST OMEG %3!, EBS POST OMEGA CONSO %4!',@p_date,@account_d,@EBSPSTOMGEND_D,@EBS_PSTOM_CONSO_END_D

  select @p_per_cf=case when @account_d <= @p_date and @p_date <= @EBSPSTOMGEND_D then 'POS'
                    when @p_date <= @EBS_PSTOM_CONSO_END_D then 'POC'
                    else 'INV' end
  if @p_per_cf!='INV' -- on prend la date de clôture précédente
    select @p_clodat_d=dateadd(day,-1,dateadd(month,1,convert(char(8),BLCSHTYEA_NF*10000+BLCSHTMTH_NF*100+1)))
      from BREF..TCALEND a
       where a.blcshtyea_nf * 100 + a.blcshtmth_nf=(select max(b.blcshtyea_nf * 100 + b.blcshtmth_nf) from BREF..TCALEND b
                                                     where closing_b=1 and b.blcshtyea_nf * 100 + b.blcshtmth_nf < @blcshtyea_nf * 100 + @blcshtmth_nf)

if @p_per_cf!='INV' -- on prend la date de clôture précédente
  select @p_clodat_d=dateadd(day,-1,dateadd(month,1,convert(char(8),BLCSHTYEA_NF*10000+BLCSHTMTH_NF*100+1))) from BREF..TCALEND B where ACCOUNT_D=@account_d
else
  select @p_clodat_d=dateadd(day,-1,dateadd(month,1,convert(char(8),BLCSHTYEA_NF*10000+BLCSHTMTH_NF*100+1))) from BREF..TCALEND B where ACCOUNT_D=@Nextaccount_d
end
return 0
go
EXEC sp_procxmode 'dbo.PsCALEND_EBS', 'unchained'
go
IF OBJECT_ID('dbo.PsCALEND_EBS') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsCALEND_EBS >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsCALEND_EBS >>>'
go
GRANT EXECUTE ON dbo.PsCALEND_EBS TO GOMEGA
go
GRANT EXECUTE ON dbo.PsCALEND_EBS TO GDBBATCH
go
