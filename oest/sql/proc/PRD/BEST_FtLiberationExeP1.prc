use BEST
go
if object_id('dbo.FtLiberationExeP1') is not null
begin
  drop function dbo.FtLiberationExeP1
  if object_id('dbo.FtLiberationExeP1') is not null
    print '<<< FAILED DROPPING function dbo.FtLiberationExeP1 >>>'
  else
    print '<<< DROPPED function dbo.FtLiberationExeP1 >>>'
end
go
create function dbo.FtLiberationExeP1
(
  @p_ACCADMTYP_CT UACCADMTYP_CT -- type comptable de la section/exercice
 ,@p_ACMTRS_NT    smallint
)
returns smallint
as
/***************************************************
Domaine: Estimation
Base principale: BEST
Auteur: Florent
Date de creation: 08/09/2011
Description du programme: :spot:22315 Détermine si libération du poste en paramètre doit être libéré en exercice+1
Conditions d'execution: le type comptable est nécessaire pour déterminer la libération
Commentaires:
_________________
MODIFICATIONS
[001]	3/09/2021	B. LAGHA	Spira:96618 - For "grouping code Ending Analytics", the beginig UWY is equals to ending UWY

******************************************************************************/
-- Si c'est une constitution le compte a 3 en unité (% : reste de la division par 10)
if @p_ACMTRS_NT%10 != 3 or @p_ACCADMTYP_CT=null or @p_ACMTRS_NT=null
  return null

--if @p_ACMTRS_NT in(1303,1323,2303,2323)
-- si les 3 derniers chiffre sont dans cette liste
if @p_ACMTRS_NT%1000 in (303,323)
  return 0

if @p_ACCADMTYP_CT=1
  return 1
		 --  Assum : @p_ACMTRS_NT not in(1243,1263,1903,1913,1923,1933,1943,1963)  -- [001]
		 --  Retro : @p_ACMTRS_NT not in(2243,2263,2903,2913,2923,2933,2943,2963)  -- [001]
if @p_ACCADMTYP_CT=3 and @p_ACMTRS_NT%1000 not in(243,263,903,913,923,933,943,963) -- [001]
  return 1

return 0
go
if object_id('dbo.FtLiberationExeP1') is not null
  print '<<< CREATED function dbo.FtLiberationExeP1 >>>'
else
  print '<<< FAILED CREATING function dbo.FtLiberationExeP1 >>>'
go
grant execute on dbo.FtLiberationExeP1 TO GOMEGA
go
grant execute on dbo.FtLiberationExeP1 TO GCONSULT
go
