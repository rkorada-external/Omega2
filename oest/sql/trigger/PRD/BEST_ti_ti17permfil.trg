USE BEST
go
CREATE OR REPLACE trigger ti_ti17permfil on TI17PERMFIL for insert as
/***************************************************
Base :                     BEST
Auteur:                    David Da Silva Teixeira
Date de creation:          03/09/2021
Description du programme:  historisation des insert de la table TI17PERMFIL dans TI17PERMFIL_H
________________
MODIFICATIONS
*****************************************************/
begin
    declare @numrows        int
    declare @errno          int
    declare @errmsg         varchar(255)
    declare @IDF_CT         varchar(30)
    declare @PERMFIL_CT     varchar(50)
    declare @PATHPATTRN_LL  varchar(512)
    declare @IO             char(1)
    declare @PERM_LL        varchar(64)
    declare @CRE_D          UUPD_D

    if @@rowcount=0 return

    select
        @IDF_CT         = IDF_CT, 
        @PERMFIL_CT     = PERMFIL_CT, 
        @PATHPATTRN_LL  = PATHPATTRN_LL, 
        @IO             = IO, 
        @PERM_LL        = PERM_LL
    from inserted

    if exists (select * from BTRAV..TI17PERMFIL_T where ( IDF_CT = @IDF_CT and PERMFIL_CT = @PERMFIL_CT ))
    begin
        select @CRE_D = CRE_D from BEST..TI17PERMFIL_H where ( IDF_CT = @IDF_CT and PERMFIL_CT = @PERMFIL_CT )

        if exists (select * from BTRAV..TI17PERMFIL_T where ( IDF_CT = @IDF_CT and PERMFIL_CT = @PERMFIL_CT and ACTIONTYP_CT = "T"))
        begin
            update BTRAV..TI17PERMFIL_T
            set PATHPATTRN_LL = @PATHPATTRN_LL, IO = @IO, PERM_LL = @PERM_LL, ACTIONTYP_CT = "U"
            where IDF_CT        = @IDF_CT 
            and PERMFIL_CT      = @PERMFIL_CT
            and ACTIONTYP_CT    = "T"
            and ( PATHPATTRN_LL     != @PATHPATTRN_LL
            or IO                   != @IO
            or PERM_LL              != @PERM_LL )
        end
        else
        begin
            insert into BEST..TI17PERMFIL_H (IDF_CT, PERMFIL_CT, PATHPATTRN_LL, IO, PERM_LL, ACTION_D, ACTIONTYP_CT, CRE_D, CREUSR_CF)
            values (@IDF_CT, @PERMFIL_CT, @PATHPATTRN_LL, @IO, @PERM_LL, getdate(), "I", @CRE_D, suser_name())

            update BTRAV..TI17PERMFIL_T
            set PATHPATTRN_LL = @PATHPATTRN_LL, IO = @IO, PERM_LL = @PERM_LL, ACTIONTYP_CT = "I"
            where IDF_CT        = @IDF_CT 
            and PERMFIL_CT      = @PERMFIL_CT
        end
    end
    else
    begin
        declare @I_CRE_D      UUPD_D
        declare @I_ACTION_D   UUPD_D
        declare @I_CREUSR_CF  UL16

        select @I_CRE_D = getdate()
        select @I_ACTION_D = getdate()
        select @I_CREUSR_CF = suser_name()

        insert into BEST..TI17PERMFIL_H (IDF_CT, PERMFIL_CT, PATHPATTRN_LL, IO, PERM_LL, ACTION_D, ACTIONTYP_CT, CRE_D, CREUSR_CF)
        values (@IDF_CT, @PERMFIL_CT, @PATHPATTRN_LL, @IO, @PERM_LL, @I_ACTION_D, "I", @I_CRE_D, @I_CREUSR_CF)

        insert into BTRAV..TI17PERMFIL_T (IDF_CT, PERMFIL_CT, PATHPATTRN_LL, IO, PERM_LL, ACTION_D, ACTIONTYP_CT, CRE_D, CREUSR_CF)
        values (@IDF_CT, @PERMFIL_CT, @PATHPATTRN_LL, @IO, @PERM_LL, @I_ACTION_D, "I", @I_CRE_D, @I_CREUSR_CF)
    end

    declare @TMP_IDF_CT         varchar(30)
    declare @TMP_PERMFIL_CT     varchar(50)
    declare @TMP_PATHPATTRN_LL  varchar(512)
    declare @TMP_IO             char(1)
    declare @TMP_PERM_LL        varchar(64)
    declare @TMP_ACTION_D       UUPD_D
    declare @TMP_ACTIONTYP_CT   char(1)
    declare @TMP_CRE_D          UUPD_D
    declare @TMP_CREUSR_CF      UL16

    select
        @TMP_IDF_CT         = IDF_CT, 
        @TMP_PERMFIL_CT     = PERMFIL_CT, 
        @TMP_PATHPATTRN_LL  = PATHPATTRN_LL, 
        @TMP_IO             = IO, 
        @TMP_PERM_LL        = PERM_LL, 
        @TMP_ACTION_D       = ACTION_D, 
        @TMP_ACTIONTYP_CT   = ACTIONTYP_CT, 
        @TMP_CRE_D          = CRE_D, 
        @TMP_CREUSR_CF      = CREUSR_CF 
    from BTRAV..TI17PERMFIL_T where ( IDF_CT = @IDF_CT and PERMFIL_CT = @PERMFIL_CT )

    if @TMP_ACTIONTYP_CT = "U"
    begin
        update BEST..TI17PERMFIL_H
        set PATHPATTRN_LL = @TMP_PATHPATTRN_LL, 
            IO = @TMP_IO, 
            PERM_LL = @TMP_PERM_LL, 
            ACTIONTYP_CT = @TMP_ACTIONTYP_CT
        from BEST..TI17PERMFIL_H
        where IDF_CT      = @TMP_IDF_CT 
        and PERMFIL_CT    = @TMP_PERMFIL_CT 
        and ACTION_D      = @TMP_ACTION_D 
        and CRE_D         = @TMP_CRE_D 
        and CREUSR_CF     = @TMP_CREUSR_CF 
        and ACTIONTYP_CT  = "D"
    end

    if @TMP_ACTIONTYP_CT = "T"
    begin
        delete from BEST..TI17PERMFIL_H
        where IDF_CT      = @TMP_IDF_CT 
        and PERMFIL_CT    = @TMP_PERMFIL_CT 
        and ACTION_D      = @TMP_ACTION_D 
        and CRE_D         = @TMP_CRE_D 
        and CREUSR_CF     = @TMP_CREUSR_CF 
        and ACTIONTYP_CT  = "D"
    end
    

    select @errno=@@error
    if @errno!= 0
    begin
        select @errmsg='APPLICATIF;TI17PERMFIL_H;insert'
        goto erreur
    end 

    return
end

erreur:
    rollback trigger with raiserror @errno @errmsg
go
IF OBJECT_ID('dbo.ti_ti17permfil') IS NOT NULL
    PRINT '<<< CREATED TRIGGER dbo.ti_ti17permfil >>>'
ELSE
    PRINT '<<< FAILED CREATING TRIGGER dbo.ti_ti17permfil >>>'
go
