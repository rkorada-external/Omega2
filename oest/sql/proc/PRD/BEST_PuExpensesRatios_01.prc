USE BEST
go
IF OBJECT_ID('dbo.PuExpensesRatios_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuExpensesRatios_01
    IF OBJECT_ID('dbo.PuExpensesRatios_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuExpensesRatios_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuExpensesRatios_01 >>>'
END
go
create procedure dbo.PuExpensesRatios_01 (
  @p_clodat_d   datetime,
  @p_cre_d      datetime,
  @p_typeinv_cf char(3),
  @p_norme_cf   char(4),
		@p_creusr_cf   varchar(4)
  )
as
/***************************************************
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     Arnaud RUFFAULT
Description du programme: 
    - Mise a jour des Expenses Ratios
_________________
MODIFICATIONS
*****************************************************/
declare
 @erreur int
,@tran_imbr  bit
,@annee smallint
,@lignes int


select @erreur=0, @tran_imbr=1

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

------------------------------------------
-- Cloture de type INV
------------------------------------------
if @p_typeinv_cf='INV'
begin

  -- Creer des patterns POS sur le meme trimestre a partir des patterns INV du trimestre
  -- Ecrase ceux qui existaient deja
  delete BEST..TEXPRAT
   where CLODAT_D = @p_clodat_d
     and PER_CF   = 'POS'
	 and NORME_CF = @p_norme_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TEXPRAT CLODAT_D %1! PER_CF POS lignes %2! NORME_CF %3!',@p_clodat_d,@lignes,@p_norme_cf



  insert into BEST..TEXPRAT (SSD_CF, ESB_CF, SEG_NF, NORME_CF, CTRNAT_CT, ACQRAT_R, MAINTRAT_R, CLODAT_D, PER_CF, CREUSR_CF, CRE_D, LSTUPDUSR_CF, LSTUPD_D, MAINTRATINI_R, UWY_NF)
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,ACQRAT_R,MAINTRAT_R,CLODAT_D=@p_clodat_d,PER_CF='POS',CREUSR_CF=@p_creusr_cf,CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D, MAINTRATINI_R, UWY_NF
   from BEST..TEXPRAT
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
	  and NORME_CF = @p_norme_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TEXPRAT lignes %1!',@lignes


end

------------------------------------------
-- Cloture de type POS (Post Omega Social)
------------------------------------------
if @p_typeinv_cf='POS'
begin
  -- Creer des patterns POC sur le meme trimestre a partir des patterns POS du trimestre
  -- Ecrase ceux qui existaient deja
  delete BEST..TEXPRAT
   where CLODAT_D = @p_clodat_d
     and PER_CF   = 'POC'
	 and NORME_CF = @p_norme_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TEXPRAT CLODAT_D %1! PER_CF POC lignes %2! NORME_CF %3!',@p_clodat_d,@lignes,@p_norme_cf



  insert into BEST..TEXPRAT (SSD_CF, ESB_CF, SEG_NF, NORME_CF, CTRNAT_CT, ACQRAT_R, MAINTRAT_R, CLODAT_D, PER_CF, CREUSR_CF, CRE_D, LSTUPDUSR_CF, LSTUPD_D, MAINTRATINI_R, UWY_NF)
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,ACQRAT_R,MAINTRAT_R,CLODAT_D=@p_clodat_d,PER_CF='POC',CREUSR_CF=@p_creusr_cf,CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D, MAINTRATINI_R, UWY_NF
   from BEST..TEXPRAT a
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
	  and NORME_CF = @p_norme_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TEXPRAT lignes %1!',@lignes

  -- Creer des patterns INV sur le trimestre suivant a partir des patterns POS du trimestre
  -- Ecrase ceux qui existaient deja
  delete BEST..TEXPRAT
   where CLODAT_D = @p_NEW_CLODAT_D
     and PER_CF = 'INV'
	 and NORME_CF = @p_norme_cf
 
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TEXPRAT CLODAT_D %1! PER_CF INV lignes %2! NORME_CF %3!',@p_NEW_CLODAT_D,@lignes,@p_norme_cf


  insert into BEST..TEXPRAT (SSD_CF, ESB_CF, SEG_NF, NORME_CF, CTRNAT_CT, ACQRAT_R, MAINTRAT_R, CLODAT_D, PER_CF, CREUSR_CF, CRE_D, LSTUPDUSR_CF, LSTUPD_D, MAINTRATINI_R, UWY_NF)
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,ACQRAT_R,MAINTRAT_R,CLODAT_D=@p_NEW_CLODAT_D,PER_CF='INV',CREUSR_CF=@p_creusr_cf,CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D, MAINTRATINI_R, UWY_NF
   from BEST..TEXPRAT
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
	  and NORME_CF = @p_norme_cf
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TEXPRAT lignes %1!',@lignes


end

if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
EXEC sp_procxmode 'dbo.PuExpensesRatios_01', 'unchained'
go
IF OBJECT_ID('dbo.PuExpensesRatios_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuExpensesRatios_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuExpensesRatios_01 >>>'
go
GRANT EXECUTE ON dbo.PuExpensesRatios_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuExpensesRatios_01 TO GDBBATCH
go
