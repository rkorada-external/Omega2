USE BEST
go
IF OBJECT_ID('dbo.PuUlaeRatio_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuUlaeRatio_01
    IF OBJECT_ID('dbo.PuUlaeRatio_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuUlaeRatio_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuUlaeRatio_01 >>>'
END
go
create procedure dbo.PuUlaeRatio_01 (
  @p_clodat_d   datetime,
  @p_cre_d      datetime,
  @p_typeinv_cf char(3),
		@p_creusr_cf   varchar(4)
  )
as
/***************************************************
Programme:                  PuUlaeRatio_01
Domaine :                   Estimation
Base principale :           BEST
Version:                    1
Auteur:                     Arnaud RUFFAULT
Date de creation:           07/10/2021
Description du programme:   
Renewall of ULAE ratios
_________________
MODIFICATIONS
20/03/2024 - DAD - spira:110913 - new column CTRNAT_CT, UWY_NF, LOBN2_NF added
*****************************************************/
declare
 @erreur int
,@tran_imbr  bit
,@annee smallint
,@lignes int


select @erreur=0, @tran_imbr=1


-- La prochaine date de cloture est le dernier jour prochain trimestre
-- pour g�rer les mois � 30 et 31 jours, la formule est :
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

------------------------------------------
-- Cloture de type INV
------------------------------------------
if @p_typeinv_cf='INV'
begin

  -- Creer des patterns POS sur le meme trimestre a partir des patterns INV du trimestre
  -- Ecrase ceux qui existaient deja

  delete BEST..TULAERAT
   where CLOSING_D = @p_clodat_d
     and PER_CF    = 'POS'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TULAERAT CLOSING_D %1! PER_CF POS lignes %2!',@p_clodat_d,@lignes


  insert into BEST..TULAERAT (SSD_CF, ESB_CF, PER_CF, CLOSING_D, RATIO_NF, CREUSR_CF, CRE_D, CTRNAT_CT, UWY_NF, LOBN2_NF)
  select SSD_CF,ESB_CF,PER_CF='POS',CLOSING_D,RATIO_NF,CREUSR_CF=@p_creusr_cf,CRE_D=@p_cre_d, CTRNAT_CT, UWY_NF, LOBN2_NF
   from BEST..TULAERAT
    where CLOSING_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TULAERAT lignes %1!',@lignes
end

------------------------------------------
-- Cloture de type POS (Post Omega Social)
------------------------------------------
if @p_typeinv_cf='POS'
begin
  -- Creer des patterns POC sur le meme trimestre a partir des patterns POS du trimestre
  -- Ecrase ceux qui existaient deja

  delete BEST..TULAERAT
   where CLOSING_D = @p_clodat_d
     and PER_CF    = 'POC'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TULAERAT CLOSING_D %1! PER_CF POC lignes %2!',@p_clodat_d,@lignes


  insert into BEST..TULAERAT (SSD_CF, ESB_CF, PER_CF, CLOSING_D, RATIO_NF, CREUSR_CF, CRE_D, CTRNAT_CT, UWY_NF, LOBN2_NF)
  select SSD_CF,ESB_CF,PER_CF='POC',CLOSING_D,RATIO_NF,CREUSR_CF=@p_creusr_cf,CRE_D=@p_cre_d, CTRNAT_CT, UWY_NF, LOBN2_NF
   from BEST..TULAERAT
    where CLOSING_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TULAERAT lignes %1!',@lignes


  -- Creer des patterns INV sur le trimestre suivant a partir des patterns POS du trimestre
  -- Ecrase ceux qui existaient deja

  delete BEST..TULAERAT
   where CLOSING_D = @p_NEW_CLODAT_D
     and PER_CF    = 'INV'
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TULAERAT CLOSING_D %1! PER_CF INV lignes %2!',@p_NEW_CLODAT_D,@lignes


  insert into BEST..TULAERAT (SSD_CF, ESB_CF, PER_CF, CLOSING_D, RATIO_NF, CREUSR_CF, CRE_D, CTRNAT_CT, UWY_NF, LOBN2_NF)
  select SSD_CF,ESB_CF,PER_CF='INV',CLOSING_D=@p_NEW_CLODAT_D,RATIO_NF,CREUSR_CF=@p_creusr_cf,CRE_D=@p_cre_d, CTRNAT_CT, UWY_NF, LOBN2_NF
   from BEST..TULAERAT
    where CLOSING_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TULAERAT lignes %1!',@lignes
end



if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
EXEC sp_procxmode 'dbo.PuUlaeRatio_01', 'unchained'
go
IF OBJECT_ID('dbo.PuUlaeRatio_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuUlaeRatio_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuUlaeRatio_01 >>>'
go
GRANT EXECUTE ON dbo.PuUlaeRatio_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuUlaeRatio_01 TO GDBBATCH
go
