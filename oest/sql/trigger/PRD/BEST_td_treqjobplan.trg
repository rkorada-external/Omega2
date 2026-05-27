use BEST
go

IF OBJECT_ID('dbo.td_treqjobplan') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.td_treqjobplan
    PRINT '<<< DROPPED TRIGGER dbo.td_treqjobplan >>>'
END
go
create trigger td_treqjobplan on treqjobplan for delete as
/***************************************************
Base :                     BEST
Auteur:                    Tony
Date de creation:          23/08/2010
Description du programme:  delete les demandes V
________________
MODIFICATIONS
Auteur       Date       Version Description
*****************************************************/
declare
   @errno      int,
   @errmsg     varchar(255),
   @reqcod_ct  char(1)

if @@rowcount = 0 return

select @reqcod_ct = deleted.reqcod_ct from deleted

If @reqcod_ct = 'V'
Begin
   -- Suppression treqjob
   delete   BEST..TREQJOB
     from   BEST..TREQJOB A, deleted d
    where   A.SSD_CF       = d.SSD_CF
      and   A.BALSHEYEA_NF = d.BALSHEYEA_NF
      and   A.BALSHTMTH_NF = d.BALSHTMTH_NF
      and   A.CLODAT_D     = d.CLODAT_D
      and   A.REQCOD_CT    = d.REQCOD_CT
      and   A.CRE_D        = d.CRE_D
      and   A.SITE_CF      = d.SITE_CF
   select @errno=@@error
   if @errno!= 0
   begin
     select @errmsg='INTEGRITE;"T";"td_treqjobplan: delete TREQJOB'
     goto erreur
   end
End

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
