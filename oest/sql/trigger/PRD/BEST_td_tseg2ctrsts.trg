USE BEST
go
IF OBJECT_ID('dbo.td_tseg2ctrsts') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.td_tseg2ctrsts
    IF OBJECT_ID('dbo.td_tseg2ctrsts') IS NOT NULL
        PRINT '<<< FAILED DROPPING TRIGGER dbo.td_tseg2ctrsts >>>'
    ELSE
        PRINT '<<< DROPPED TRIGGER dbo.td_tseg2ctrsts >>>'
END
go
create trigger td_tseg2ctrsts on tseg2ctrsts for delete as
Begin
/***************************************************
Base :                     BEST
Auteur:                    Tarun Singh
Date de creation:          24/07/2014
Description du programme:  to update Segmentation
________________
*****************************************************/
declare
   @errno      int,
   @errmsg     varchar(255)

if @@rowcount = 0 return


        Update 	TSEGMENTATION
        SET     a.LSTUPD_D = getdate()
				,a.LSTUPDUSR_CF = user
        from  	TSEGMENTATION a ,deleted d
        where 	a.SGT_NT =d.SGT_NT
        and    	a.SGTVER_NT =d.SGTVER_NT
        
        select @errno=@@error
        if @errno!= 0
        begin
            select @errmsg='INTEGRITE;"T";"td_tseg2ctrsts: update TSEGMENTATION'
            goto erreur
        end
        
End

return



erreur:
rollback trigger with raiserror @errno @errmsg
go
IF OBJECT_ID('dbo.td_tseg2ctrsts') IS NOT NULL
    PRINT '<<< CREATED TRIGGER dbo.td_tseg2ctrsts >>>'
ELSE
    PRINT '<<< FAILED CREATING TRIGGER dbo.td_tseg2ctrsts >>>'
go