use BEST
go

IF OBJECT_ID('dbo.tu_treqjobplan') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.tu_treqjobplan
    PRINT '<<< DROPPED TRIGGER dbo.tu_treqjobplan >>>'
END
go
create trigger tu_treqjobplan on treqjobplan for update as
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

select @reqcod_ct = inserted.reqcod_ct from inserted

If @reqcod_ct = 'V'
Begin
   -- Insertion treqjob
   update   best..treqjob
   set      a.CLOPER_LS   =  i.CLOPER_LS,
            a.CLODAT_D    =  i.CLODAT_D,
            a.DBCLO_D     =  i.DBCLO_D
   from     best..treqjob a, inserted i
    where   a.SSD_CF       = i.SSD_CF
      and   a.BALSHEYEA_NF = i.BALSHEYEA_NF
      and   a.BALSHTMTH_NF = i.BALSHTMTH_NF
      and   a.CLODAT_D     = i.CLODAT_D
      and   a.REQCOD_CT    = i.REQCOD_CT
      and   a.CRE_D        = i.CRE_D
      and   a.SITE_CF      = i.SITE_CF
   select @errno=@@error
   if @errno!= 0
   begin
     select @errmsg='INTEGRITE;"T";"ti_treqjobplan: insert TREQJOB'
     goto erreur
   end
End

return

--Gestion d'erreurs
erreur:
rollback trigger with raiserror @errno @errmsg
go

IF OBJECT_ID('dbo.tu_treqjobplan') IS NOT NULL
    PRINT '<<< CREATED TRIGGER dbo.tu_treqjobplan >>>'
ELSE
    PRINT '<<< FAILED CREATING TRIGGER dbo.tu_treqjobplan >>>'
go
