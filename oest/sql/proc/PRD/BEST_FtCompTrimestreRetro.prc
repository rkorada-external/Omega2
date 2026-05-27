use BEST
go
if object_id('FtCompTrimestreRetro') is not null
begin
  drop function FtCompTrimestreRetro
  if object_id('FtCompTrimestreRetro') is not null
    print '<<< FAILED DROPPING function FtCompTrimestreRetro >>>'
  else
    print '<<< DROPPED function FtCompTrimestreRetro >>>'
end
go
create function FtCompTrimestreRetro
(
 @p_DEBUT_D    datetime
,@p_FIN_D      datetime
,@p_EXERCICE_N smallint
,@p_type       char(3) -- clo pour calcul de trimestre jusqu'à la cloture
                       -- ctr pour la durée du contrat
                       -- fin pour jusqu'à la fin de l'année de l'exercice
                       -- exp renvoi 1 si la date d'échéance(gestion du calcul si nulle) est supérieure à la date de clôture
,@p_CLODAT_D   datetime
)
returns smallint
as
/***************************************************
Base : BRET
Auteur: Florent
Date de creation: 23/09/2015
Description du programme: EST45 :spot:29176 Review Retro automatic rules
                          calculer le nombre de trimestre entre les 2 dates
Commentaire : gestion aussi des cas particulier !
________________
MODIFICATIONS
   Auteur      Date       Description
*****************************************************/
declare
 @DEBUT_D  datetime
,@FIN_D    datetime
,@MOISJOUR char(4)
,@retour   smallint

set @retour=0

-- on utilise l'exercice pour calculer les date bornées
if @p_DEBUT_D=null and @p_FIN_D=null
  select @DEBUT_D=convert(char(4),@p_EXERCICE_N)+'0101', @FIN_D=convert(char(4),@p_EXERCICE_N)+'1231'
else
begin
    if @p_DEBUT_D=null
      select @DEBUT_D=dateadd(day,1,dateadd(year,-1,@p_FIN_D))
    else
      select @DEBUT_D=@p_DEBUT_D
    
    if @p_FIN_D=null
      select @FIN_D=dateadd(day,-1,dateadd(year,1,@p_DEBUT_D))
    else
      select @FIN_D=@p_FIN_D
end

-- si anomalie année date d'effet est différente de l'exercice, si le contrat commence avant d'avoir fini
--  on gère comme le cas des dates début et fin nulles !
if @p_EXERCICE_N!=year(@DEBUT_D) or @DEBUT_D >= @FIN_D
  select @DEBUT_D=convert(char(4),@p_EXERCICE_N)+'0101', @FIN_D=convert(char(4),@p_EXERCICE_N)+'1231'

if @p_type='exp'
begin
  -- Si la date d'arrêté est strictement postérieure à la date d'échéance, renvoi 1
  set @retour=case when @p_CLODAT_D > @FIN_D then 1 else 0 end
end
else
begin
  -- gestion date de fin suivant les type de calculs demandés
  select @FIN_D=case when @p_type='fin' then case when convert(char(4),@p_EXERCICE_N)+'1231' > @FIN_D then @FIN_D else convert(char(4),@p_EXERCICE_N)+'1231' end
                     when @p_type='clo' then case when @p_CLODAT_D > @FIN_D then @FIN_D else @p_CLODAT_D end
                     else @FIN_D -- type ctr déjà initialisé
                end
                 
  -- il faut initialiser les mois des dates pour les mettre dans le 1er mois du trimestre au 1er jour
  --  car on considère on doit calculer des trimestres plein, un trimestre commencé est dû
  select 
   @DEBUT_D=convert(char(4),year(@DEBUT_D))+
            case when month(@DEBUT_D) in(1,2,3) then '0101'
                 when month(@DEBUT_D) in(4,5,6) then '0401'
                 when month(@DEBUT_D) in(7,8,9) then '0701'
                 when month(@DEBUT_D) in(10,11,12) then '1001'
            end
  -- on se positionne en fin de trimestre + 1 jour, car si le contrat commence et termine dans le même trimestre on aurait Zéro!
  ,@FIN_D=convert(char(4),year(@FIN_D) + case when month(@FIN_D) in(10,11,12) then 1 else 0 end)+
          case when month(@FIN_D) in(1,2,3) then '0401'
               when month(@FIN_D) in(4,5,6) then '0701'
               when month(@FIN_D) in(7,8,9) then '1001'
               when month(@FIN_D) in(10,11,12) then '0101'
          end
  
  set @retour=datediff(quarter,@DEBUT_D,@FIN_D)
end
return @retour
go
if object_id('FtCompTrimestreRetro') is not null
  print '<<< CREATED function FtCompTrimestreRetro >>>'
else
  print '<<< FAILED CREATING function FtCompTrimestreRetro >>>'
go
GRANT EXECUTE ON dbo.FtCompTrimestreRetro TO GOMEGA,GDBBATCH,GCONSULT
go
