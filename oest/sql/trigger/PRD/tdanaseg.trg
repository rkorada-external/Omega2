use best
go

DROP TRIGGER dbo.td_tanaseg
go

IF OBJECT_ID('dbo.td_tanaseg') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.td_tanaseg
    PRINT '<<< DROPPED TRIGGER dbo.td_tanaseg >>>'
END
go

/*  Trigger "td_tanaseg"; permet de controler que le segment à supprimer n'est pas référencé */
/*  dans la table de paramètrage des segments TSEGPAR                                        */
/*  Si c'est le cas un message indique à l'utilisateur qu'il lui faut d'abord supprimer      */
/*  le segment dans la table de paramétrage des segments TSEGPAR                             */

create trigger td_tanaseg on TANASEG for delete as
begin
    declare
       @numrows  int,
       @errno    int,
       @errmsg   varchar(255),
       @seg_nf   char(10)

    select  @numrows = @@rowcount
    if @numrows = 0
       return



  select @seg_nf = seg_nf from deleted

  if exists( select 1 from tsegpar where seg_nf = @seg_nf)
   begin
       select @errno  = 30001,
       @errmsg = 'ESTIMATION;"";""'
       goto error
   end
  return 


/*  Gestion d'erreurs  */


error:
    raiserror @errno @errmsg
    rollback  trigger
end
go
IF OBJECT_ID('dbo.td_tanaseg') IS NOT NULL
    PRINT '<<< CREATED TRIGGER dbo.td_tanaseg >>>'
ELSE
    PRINT '<<< FAILED CREATING TRIGGER dbo.td_tanaseg >>>'
go

