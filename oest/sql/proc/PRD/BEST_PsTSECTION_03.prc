USE BEST
go

IF OBJECT_ID('dbo.PsTSECTION_03') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTSECTION_03
    IF OBJECT_ID('dbo.PsTSECTION_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTSECTION_03 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTSECTION_03 >>>'
END
go

CREATE PROCEDURE dbo.PsTSECTION_03 (
    @p_ctr_nf UCTR_NF,
    @p_uwy_nf UUWY_NF,
	@p_uw_nt  UUW_NT,
	@p_end_nt UEND_NT,
	@p_sec_nf USEC_NF,
	@p_ssd_cf USSD_CF
)


as
/***************************************************
Programme:          PsTSECTION_03
Domaine :           (ES) Estimation
Base principale :   BEST
Version:            9.1
Auteur:             D.GATIBELZA
Date de creation :  21/07/2009

Description du programme:   ESTVIE17265 Il faut ajouter un contrôle sur l'ACY quand saisie manuelle d'écriture service
                            -> on ne doit pas avoir ACY<UWY pour la vie
_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:
*****************************************************/
declare @error int,
        @lob char(3)


    /* Traité */
    select @lob = lob_cf
    from BTRT..TSECTION
    where ctr_nf = @p_ctr_nf
      and uwy_nf = @p_uwy_nf
      and uw_nt = @p_uw_nt
      and end_nt = @p_end_nt
      and ssd_cf = @p_ssd_cf
      and sec_nf = @p_sec_nf

    select @error = @@error
    if @error != 0
    begin
        raiserror 20003 "APPLICATIF;TCONTR"
        return 1
    end


    select @lob

return 0


EXEC sp_procxmode 'dbo.PsTSECTION_03','unchained'

go
EXEC sp_procxmode 'dbo.PsTSECTION_03','unchained'
go
IF OBJECT_ID('dbo.PsTSECTION_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTSECTION_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTSECTION_03 >>>'
go
GRANT EXECUTE ON dbo.PsTSECTION_03 TO GOMEGA
go

