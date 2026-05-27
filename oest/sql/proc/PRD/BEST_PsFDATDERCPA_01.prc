USE BEST
go
IF OBJECT_ID('dbo.PsFDATDERCPA_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsFDATDERCPA_01
    IF OBJECT_ID('dbo.PsFDATDERCPA_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsFDATDERCPA_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsFDATDERCPA_01 >>>'
END
go
create procedure dbo.PsFDATDERCPA_01
AS

/***************************************************
Programme:              PsFDATDERCPA_01
Fichier script associé: PsFDATDERCPA_01.PRC
Domaine:                (ES) Estimation
Base principale:        BEST
Version:                :spira:42212: TRAITE DECALES
Auteur:                 MZM
Date de creation:       09/04/2020

Description du programme:
			Extraction de la date de derniere Comptabilité connue

Parametres: 
Conditions d'execution:

*****************************************************/

    DECLARE @p_ssd_cf    USSD_CF
    DECLARE @erreur INT
    DECLARE @curr_usr UUPDUSR_CF
    SELECT @curr_usr = USER_NAME ()
    
    SELECT
        BATCHUSER_CF,
        SSD_CF
    INTO #ssds
    FROM BREF..TBATCHSSD
    WHERE BATCHUSER_CF = @curr_usr 

--declare @p_ced_Year int
--select  @p_ced_Year=2019

		select CTR_NF, 
		DatDerCpa = convert(varchar, dateadd(day, -1, dateadd(month, 1 , convert(varchar, MAX(CEDENDYEA_NF*10000 + CEDENDMTH_NF*100 + 1))  ) ) ,112)
		from BCTA..TAPR ta, #ssds sd
		where 1 = 1 
		--AND CTR_NF = 'TR0039719'
		AND sd.SSD_CF = ta.SSD_CF
		AND (   acctyp_cf <> 4                                            
		     OR (acctyp_cf = 4 AND due_d < dateadd (yy, 2, getdate() )))  
		       --AND (CEDSTRYEA_NF =@p_ced_Year)
		       AND ETY_D NOT IN (NULL,'')
		group by CTR_NF
		order by CTR_NF

select @erreur = @@error
if @erreur != 0
begin
    return @erreur
end

return 0
go
EXEC sp_procxmode 'dbo.PsFDATDERCPA_01', 'unchained'
go
IF OBJECT_ID('dbo.PsFDATDERCPA_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsFDATDERCPA_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsFDATDERCPA_01 >>>'
go
GRANT EXECUTE ON dbo.PsFDATDERCPA_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsFDATDERCPA_01 TO GDBBATCH
go


