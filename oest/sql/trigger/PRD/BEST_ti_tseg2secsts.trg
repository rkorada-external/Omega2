USE BEST
go
IF OBJECT_ID('dbo.ti_tseg2secsts') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.ti_tseg2secsts
    IF OBJECT_ID('dbo.ti_tseg2secsts') IS NOT NULL
        PRINT '<<< FAILED DROPPING TRIGGER dbo.ti_tseg2secsts >>>'
    ELSE
        PRINT '<<< DROPPED TRIGGER dbo.ti_tseg2secsts >>>'
END
go
create trigger ti_tseg2secsts on tseg2secsts for insert as
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
        SET     LSTUPD_D = getdate()
				,LSTUPDUSR_CF = i.CREUSR_CF
        from  	TSEGMENTATION a ,inserted i
        where 	a.SGT_NT =i.SGT_NT
        and    	a.SGTVER_NT =i.SGTVER_NT
        
        select @errno=@@error
        if @errno!= 0
        begin
            select @errmsg='INTEGRITE;"T";"ti_tseg2secsts: update TSEGMENTATION'
            goto erreur
        end
        
End

return



erreur:
rollback trigger with raiserror @errno @errmsg
go
IF OBJECT_ID('dbo.ti_tseg2secsts') IS NOT NULL
    PRINT '<<< CREATED TRIGGER dbo.ti_tseg2secsts >>>'
ELSE
    PRINT '<<< FAILED CREATING TRIGGER dbo.ti_tseg2secsts >>>'
go