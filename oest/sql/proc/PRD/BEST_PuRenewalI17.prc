USE BEST
go
IF OBJECT_ID('dbo.PuRenewalI17') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuRenewalI17
    IF OBJECT_ID('dbo.PuRenewalI17') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuRenewalI17 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuRenewalI17 >>>'
END
go
create procedure dbo.PuRenewalI17 (
  @p_clodat_d   datetime,
  @p_cre_d      datetime,
  @p_typeinv_cf char(3),
  @p_norme_cf   char(4)
  )
as
/***************************************************
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     C.SOCIE
Description du programme: 
    - Mise a jour de la date de comptabilisation et du type d'inventaire des tables patterns solvency
Parametres:     - @p_cre_d : la date de traitement
                - @p_clodat_d : libellé d'inventaire
                - @p_typeinv_cf : type inventaire
_________________
MODIFICATIONS
[01] Charles SOCIE spira 70380 add norme_cf
[02] 01/04/2021 filter update by region and and filter on LOB_CF
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


if object_id('#TABLE_SSD_TO_UPDATE') is not null drop Table #TABLE_SSD_TO_UPDATE --2

select distinct SSD_CF --2
into #TABLE_SSD_TO_UPDATE --2
from BREF..TBATCHSSD --2
where BATCHUSER_CF = suser_name() --2

------------------------------------------
-- Cloture de type INV
------------------------------------------
if @p_typeinv_cf='INV'
begin
  -- Creer des patterns INV sur le trimestre suivant a partir des patterns INV du trimestre
  -- Ecrase ceux qui existaient deja
  delete BEST..TEXPRAT
   where CLODAT_D = @p_NEW_CLODAT_D
     and PER_CF   = @p_typeinv_cf
	 and NORME_CF = @p_norme_cf
		and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TEXPRAT CLODAT_D %1! PER_CF %2! lignes %3! NORME_CF %4!',@p_NEW_CLODAT_D,@p_typeinv_cf,@lignes,@p_norme_cf

  delete BEST..TRARAT
   where CLODAT_D  = @p_NEW_CLODAT_D
     and PER_CF    = @p_typeinv_cf
	 and NORME_CF = @p_norme_cf
		and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TRARAT CLODAT_D  %1! PER_CF %2! lignes %3! NORME_CF %4!',@p_NEW_CLODAT_D,@p_typeinv_cf,@lignes,@p_norme_cf

 insert into BEST..TEXPRAT
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,ACQRAT_R,MAINTRAT_R,CLODAT_D=@p_NEW_CLODAT_D,PER_CF,CREUSR_CF='BOOK',CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D
   from BEST..TEXPRAT
    where CLODAT_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
	  and NORME_CF = @p_norme_cf
			and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TEXPRAT lignes %1!',@lignes

 insert into BEST..TRARAT
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,DOMAIN_CF,PRMRAT_R,RSRVRAT_R,CLODAT_D=@p_NEW_CLODAT_D,PER_CF,CREUSR_CF='BOOK',CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D 
   from BEST..TRARAT
       where CLODAT_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
	  and NORME_CF = @p_norme_cf
			and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TRARAT lignes %1!',@lignes

  -- Creer des patterns POS sur le meme trimestre a partir des patterns INV du trimestre
  -- Ecrase ceux qui existaient deja
  delete BEST..TEXPRAT
   where CLODAT_D = @p_clodat_d
     and PER_CF   = 'POS'
	 and NORME_CF = @p_norme_cf
		and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TEXPRAT CLODAT_D %1! PER_CF POS lignes %2! NORME_CF %3!',@p_clodat_d,@lignes,@p_norme_cf

  delete BEST..TRARAT
   where CLODAT_D = @p_clodat_d
     and PER_CF    = 'POS'
	 and NORME_CF = @p_norme_cf
		and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TRARAT CLODAT_D %1! PER_CF POS lignes %2! NORME_CF %3!',@p_clodat_d,@lignes,@p_norme_cf

  insert into BEST..TEXPRAT
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,ACQRAT_R,MAINTRAT_R,CLODAT_D=@p_clodat_d,PER_CF='POS',CREUSR_CF='BOOK',CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D
   from BEST..TEXPRAT
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
	  and NORME_CF = @p_norme_cf
			and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TEXPRAT lignes %1!',@lignes

  insert into BEST..TRARAT
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,DOMAIN_CF,PRMRAT_R,RSRVRAT_R,CLODAT_D=@p_clodat_d,PER_CF='POS',CREUSR_CF='BOOK',CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D 
   from BEST..TRARAT
    where CLODAT_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
	  and NORME_CF = @p_norme_cf
			and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TRARAT lignes %1!',@lignes
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
		and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TEXPRAT CLODAT_D %1! PER_CF POC lignes %2! NORME_CF %3!',@p_clodat_d,@lignes,@p_norme_cf

  delete BEST..TRARAT
   where CLODAT_D = @p_clodat_d
     and PER_CF    = 'POC'
	 and NORME_CF = @p_norme_cf
		and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TRARAT CLODAT_D %1! PER_CF POC lignes %2! NORME_CF %3!',@p_clodat_d,@lignes,@p_norme_cf

  insert into BEST..TEXPRAT
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,ACQRAT_R,MAINTRAT_R,CLODAT_D=@p_clodat_d,PER_CF='POC',CREUSR_CF='BOOK',CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D
   from BEST..TEXPRAT a
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
	  and NORME_CF = @p_norme_cf
			and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TEXPRAT lignes %1!',@lignes

  insert into BEST..TRARAT
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,DOMAIN_CF,PRMRAT_R,RSRVRAT_R,CLODAT_D=@p_clodat_d,PER_CF='POC',CREUSR_CF='BOOK',CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D 
   from BEST..TRARAT
    where CLODAT_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
	  and NORME_CF = @p_norme_cf
			and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TRARAT lignes %1!',@lignes

  -- Creer des patterns POS sur le trimestre suivant a partir des patterns POS du trimestre
  -- Ecrase ceux qui existaient deja
  delete BEST..TEXPRAT
   where CLODAT_D = @p_NEW_CLODAT_D
     and PER_CF   = 'POS'
	 and NORME_CF = @p_norme_cf
		and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TEXPRAT CLODAT_D %1! PER_CF POS lignes %2! NORME_CF %3!',@p_NEW_CLODAT_D,@lignes,@p_norme_cf

  delete BEST..TRARAT
   where CLODAT_D = @p_NEW_CLODAT_D
     and PER_CF    = 'POS'
	 and NORME_CF = @p_norme_cf
		and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TRARAT CLODAT_D %1! PER_CF POS lignes %2! NORME_CF %3!',@p_NEW_CLODAT_D,@lignes,@p_norme_cf

  insert into BEST..TEXPRAT
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,ACQRAT_R,MAINTRAT_R,CLODAT_D=@p_NEW_CLODAT_D,PER_CF,CREUSR_CF='BOOK',CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D
   from BEST..TEXPRAT
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
	  and NORME_CF = @p_norme_cf
			and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
 select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TEXPRAT lignes %1!',@lignes

  insert into BEST..TRARAT
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,DOMAIN_CF,PRMRAT_R,RSRVRAT_R,CLODAT_D=@p_NEW_CLODAT_D,PER_CF,CREUSR_CF='BOOK',CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D 
   from BEST..TRARAT
    where CLODAT_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
	  and NORME_CF = @p_norme_cf
			and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TRARAT lignes %1!',@lignes


  -- Creer des patterns INV sur le trimestre suivant a partir des patterns POS du trimestre
  -- Ecrase ceux qui existaient deja
  delete BEST..TEXPRAT
   where CLODAT_D = @p_NEW_CLODAT_D
     and PER_CF = 'INV'
	 and NORME_CF = @p_norme_cf
		and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
 
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TEXPRAT CLODAT_D %1! PER_CF INV lignes %2! NORME_CF %3!',@p_NEW_CLODAT_D,@lignes,@p_norme_cf

  delete BEST..TRARAT
   where CLODAT_D = @p_NEW_CLODAT_D
     and PER_CF    = 'INV'
	 and NORME_CF = @p_norme_cf
		and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'delete BEST..TRARAT CLODAT_D %1! PER_CF INV lignes %2! NORME_CF %3!',@p_NEW_CLODAT_D,@lignes,@p_norme_cf

  insert into BEST..TEXPRAT
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,ACQRAT_R,MAINTRAT_R,CLODAT_D=@p_NEW_CLODAT_D,PER_CF='INV',CREUSR_CF='BOOK',CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D
   from BEST..TEXPRAT
    where CLODAT_D = @p_clodat_d
      and PER_CF   = @p_typeinv_cf
	  and NORME_CF = @p_norme_cf
			and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TEXPRAT lignes %1!',@lignes

  insert into BEST..TRARAT
  select SSD_CF,ESB_CF,SEG_NF,NORME_CF,CTRNAT_CT,DOMAIN_CF,PRMRAT_R,RSRVRAT_R,CLODAT_D=@p_NEW_CLODAT_D,PER_CF='INV',CREUSR_CF='BOOK',CRE_D=@p_cre_d,LSTUPDUSR_CF,LSTUPD_D 
   from BEST..TRARAT
    where CLODAT_D=@p_clodat_d
      and PER_CF=@p_typeinv_cf
	  and NORME_CF = @p_norme_cf
			and SSD_CF IN ( select * from #TABLE_SSD_TO_UPDATE) --2
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 goto fin
  print 'insert into BEST..TRARAT lignes %1!',@lignes
end

if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
EXEC sp_procxmode 'dbo.PuRenewalI17', 'unchained'
go
IF OBJECT_ID('dbo.PuRenewalI17') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuRenewalI17 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuRenewalI17 >>>'
go
GRANT EXECUTE ON dbo.PuRenewalI17 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuRenewalI17 TO GDBBATCH
go
