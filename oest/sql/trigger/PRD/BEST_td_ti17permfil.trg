USE BEST
go
CREATE OR REPLACE trigger td_ti17permfil on TI17PERMFIL for delete as
/***************************************************
Base :                     BEST
Auteur:                    David Da Silva Teixeira
Date de creation:          03/09/2021
Description du programme:  historisation des delete de la table TI17PERMFIL dans TI17PERMFIL_H
________________
MODIFICATIONS
*****************************************************/
begin
    declare @numrows        int
    declare @errno          int
    declare @errmsg         varchar(255)
    declare @ACTION_D       UUPD_D
    declare @ACTIONTYP_CT   char(1)
    declare @CREUSR_CF      UL16

    if @@rowcount=0 return

    select @ACTION_D = getdate()
    select @ACTIONTYP_CT = "D"
    select @CREUSR_CF = suser_name()

    update BTRAV..TI17PERMFIL_T
    set ACTIONTYP_CT = "D"
    where ACTIONTYP_CT = "T"

    insert into BEST..TI17PERMFIL_H (IDF_CT, PERMFIL_CT, PATHPATTRN_LL, IO, PERM_LL, ACTION_D, ACTIONTYP_CT, CRE_D, CREUSR_CF)
    select d.IDF_CT, d.PERMFIL_CT, d.PATHPATTRN_LL, d.IO, d.PERM_LL, @ACTION_D, @ACTIONTYP_CT, t.CRE_D, @CREUSR_CF 
    from BTRAV..TI17PERMFIL_T t, deleted d
    where t.IDF_CT = d.IDF_CT and t.PERMFIL_CT = d.PERMFIL_CT 
    
    update BTRAV..TI17PERMFIL_T
    set ACTIONTYP_CT    = "T", 
        ACTION_D        = @ACTION_D, 
        CREUSR_CF       = @CREUSR_CF
    from BTRAV..TI17PERMFIL_T t, deleted d 
    where t.IDF_CT = d.IDF_CT and t.PERMFIL_CT = d.PERMFIL_CT

    select @errno=@@error
    if @errno!= 0
    begin
        select @errmsg='APPLICATIF;TI17PERMFIL_H;delete'
        print @errmsg
        goto erreur
    end 

    return
end

erreur:
    rollback trigger with raiserror @errno @errmsg
go
IF OBJECT_ID('dbo.td_ti17permfil') IS NOT NULL
    PRINT '<<< CREATED TRIGGER dbo.td_ti17permfil >>>'
ELSE
    PRINT '<<< FAILED CREATING TRIGGER dbo.td_ti17permfil >>>'
go
