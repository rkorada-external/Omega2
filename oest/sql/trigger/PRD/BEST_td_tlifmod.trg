use BEST
go
IF OBJECT_ID('dbo.td_tlifmod') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.td_tlifmod
    PRINT '<<< DROPPED TRIGGER dbo.td_tlifmod >>>'
END
go
create trigger td_tlifmod on tlifmod for delete as
/***************************************************
Base :                     BEST
Auteur:                    Florent
Date de creation:          06/07/2004
Description du programme:  delete des commentaires et table TLIFPEN
________________
MODIFICATIONS
Auteur       Date       Version Description
*****************************************************/
declare
   @errno    int,
   @errmsg   varchar(255)

if @@rowcount = 0 return

-- Suppression commentaires
delete TESTCOM
 from TESTCOM C, deleted d
  where C.CMT_NT = d.CMT_NT
select @errno=@@error
if @errno!= 0
begin
  select @errmsg='INTEGRITE;"T";"td_tlifmod: delete TESTCOM'
  goto erreur
end

delete TLIFPEN
 from TLIFPEN a, deleted d
  where a.CTR_NF=d.CTR_NF
    and a.SEC_NF=d.SEC_NF
    and a.BALSHEY_NF=d.BALSHEY_NF
    and a.BALSHTMTH_NF=d.BALSHTMTH_NF
    and a.CRE_D=d.CRE_D
select @errno=@@error
if @errno!= 0
begin
  select @errmsg='INTEGRITE;"T";"td_tlifmod: delete TLIFPEN'
  goto erreur
end

return

--Gestion d'erreurs
erreur:
rollback trigger with raiserror @errno @errmsg
go
IF OBJECT_ID('dbo.td_tlifmod') IS NOT NULL
    PRINT '<<< CREATED TRIGGER dbo.td_tlifmod >>>'
ELSE
    PRINT '<<< FAILED CREATING TRIGGER dbo.td_tlifmod >>>'
go
