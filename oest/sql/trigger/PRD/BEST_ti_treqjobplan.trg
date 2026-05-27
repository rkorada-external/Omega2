use BEST
go

IF OBJECT_ID('dbo.ti_treqjobplan') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.ti_treqjobplan
    PRINT '<<< DROPPED TRIGGER dbo.ti_treqjobplan >>>'
END
go
create trigger ti_treqjobplan on treqjobplan for insert as
/***************************************************
Base :                     BEST
Auteur:                    Tony
Date de creation:          23/08/2010
Description du programme:  insertion les demandes V
________________
MODIFICATIONS
Auteur       Date       Version Description
sbasak     08/11/2013  column added for 1B site management
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
   insert into best..treqjob
   (
			 SSD_CF,
             BALSHEYEA_NF,
             BALSHTMTH_NF,
             CLODAT_D,
             REQCOD_CT,
             CRE_D,
             DBCLO_D,
             LAUNCH_D,
             CLOPER_LS,
             VRS_NF,
             UPDUSR_CF,
             START_D,
             END_D,
             SITE_CF,
             ID_NF
   )
   select    SSD_CF,
             BALSHEYEA_NF,
             BALSHTMTH_NF,
             CLODAT_D,
             REQCOD_CT,
             CRE_D,
             DBCLO_D,
             LAUNCH_D,
             CLOPER_LS,
             VRS_NF,
             UPDUSR_CF,
             START_D,
             END_D,
             SITE_CF,
             ID_NF
     from    inserted i

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

IF OBJECT_ID('dbo.ti_treqjobplan') IS NOT NULL
    PRINT '<<< CREATED TRIGGER dbo.ti_treqjobplan >>>'
ELSE
    PRINT '<<< FAILED CREATING TRIGGER dbo.ti_treqjobplan >>>'
go
