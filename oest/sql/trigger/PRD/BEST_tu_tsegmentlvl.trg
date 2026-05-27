USE BEST
go
IF OBJECT_ID('dbo.tu_tsegmentlvl') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.tu_tsegmentlvl
    IF OBJECT_ID('dbo.tu_tsegmentlvl') IS NOT NULL
        PRINT '<<< FAILED DROPPING TRIGGER dbo.tu_tsegmentlvl >>>'
    ELSE
        PRINT '<<< DROPPED TRIGGER dbo.tu_tsegmentlvl >>>'
END
go
create trigger tu_tsegmentlvl on tsegmentlvl for update as
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
				,LSTUPDUSR_CF = i.LSTUPDUSR_CF
        from  	TSEGMENTATION a ,inserted i
        where 	a.SGT_NT =i.SGT_NT
        and    	a.SGTVER_NT =i.SGTVER_NT
        
        select @errno=@@error
        if @errno!= 0
        begin
            select @errmsg='INTEGRITE;"T";"tu_tsegmentlvl: update TSEGMENTATION'
            goto erreur
        end
        
End

return



erreur:
rollback trigger with raiserror @errno @errmsg
go
IF OBJECT_ID('dbo.tu_tsegmentlvl') IS NOT NULL
    PRINT '<<< CREATED TRIGGER dbo.tu_tsegmentlvl >>>'
ELSE
    PRINT '<<< FAILED CREATING TRIGGER dbo.tu_tsegmentlvl >>>'
go