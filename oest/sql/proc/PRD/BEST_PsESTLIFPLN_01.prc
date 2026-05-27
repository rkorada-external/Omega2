USE BEST
go
IF OBJECT_ID('dbo.PsESTLIFPLN_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsESTLIFPLN_01
    IF OBJECT_ID('dbo.PsESTLIFPLN_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsESTLIFPLN_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsESTLIFPLN_01 >>>'
END
go
/*
 * creation de la procedure */
create procedure dbo.PsESTLIFPLN_01
 
as
/***************************************************
Programme:                  PsESTLIFPLN_01
Fichier script associé :    BEST_PsESTLIFPLN_01.prc
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     J. Ribot
Date de creation:           05/05/2004
Description du programme:   
    - sélection des écritures d'ajustement du plan
Parametres:
    - annee de la periode du plan

_________________
MODIFICATION    [001]
Auteur:         D.GATIBELZA
Date:           17/03/2010
Version:        10.1
Description:    SRVIE16960 Adaptation de TLIFSTAREP  création d'une version du plan vie à la demande + ES plan à intégrer

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 21/05/2014 M. MECHRI   :spot:26803  - Modifications pour omega2 -1b correction plan vie
*****************************************************/
declare @clodat_year        int,
        @clodat_month       int,
        @clodat_day         int,
        @erreur             int,
        @tran_imbr          bit,
        @balshtyea_nf       smallint

select @erreur      = 0
select @tran_imbr   = 1

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

/* ------------------------------------------------------------
   Début de la transaction
 -------------------------------------------------------------- */ 
if @@trancount = 0
begin
    select @tran_imbr = 0
    BEGIN TRAN
end

--[001] /* ---------------------------------------------
--[001]    Sélection des écritures de service
--[001] --------------------------------------------- */
--[001] --select @clodat_d = a.CLODAT_D,
--[001] select @clodat_year  = convert (int, DatePart (yy, a.CLODAT_D)),
--[001]        @clodat_month = convert (int, DatePart (MM, a.CLODAT_D)),
--[001]        @clodat_day   = convert (int, DatePart (DD, a.CLODAT_D)),
--[001]        @balshtyea_nf = a.balsheyea_nf
--[001]     from BEST..TREQJOB a
--[001]        where a.SSD_CF = 99
--[001]          and a.balshtmth_nf = 1
--[001]          and a.reqcod_ct = 'A'
--[001]          and a.cre_d = (select max(b.cre_d)
--[001]    				              from BEST..TREQJOB b
--[001]                         where b.SSD_CF = 99
--[001]                         and b.balshtmth_nf = 1
--[001]                         and b.reqcod_ct = 'A'
--[001]                        )
--[001] 
--[001] 
--[001] 
--[001] /* -----------------------------------
--[001]    Descente de la table en fichiers
--[001] ----------------------------------- */
--[001] 
--[001] select SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF,
--[001] 	END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF	, 0,	CUR_CF, AMT_M,
--[001]   CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RETRTY_NF, RETUW_NT,
--[001]   RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, 0, 	RETCUR_CF, RETAMT_M, PLC_NT, RTO_NF,
--[001]   INT_NF, RETPAY_NF, RETKEY_CF, 0, ACCTYP_NF
--[001]   from	BEST..TLIFPLN
--[001]    where PLAN_NF = @balshtyea_nf
--[001]       and BALSHEY_NF    = @clodat_year
--[001]       and BALSHRMTH_NF  = @clodat_month
--[001]       and BALSHRDAY_NF  = @clodat_day 


/*
--[101]
--[001] S'il n'y a jamais eu de demande pour la filiale, on prend tout TLIFPLN depuis la dernière comptabilisation pour la filiale 
--select a.SSD_CF, a.ESB_CF, a.BALSHEY_NF, a.BALSHRMTH_NF, a.BALSHRDAY_NF, a.TRNCOD_CF, a.DBLTRNCOD_CF, a.CTR_NF,
--       a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.OCCYEA_NF, a.ACY_NF, a.SCOSTRMTH_NF, a.SCOENDMTH_NF, 0,
--       a.CUR_CF, a.AMT_M,  a.CED_NF, a.BRK_NF, a.GEMPRMPAY_NF, a.GANPAYORD_NT, a.RETCTR_NF, a.RETEND_NT,
--       a.RETSEC_NF, a.RETRTY_NF, a.RETUW_NT, a.RETOCCYEA_NF, a.RETACY_NF, a.RETSCOSTRMTH_NF, a.RETSCOENDMTH_NF,
--       0, a.RETCUR_CF, a.RETAMT_M, a.PLC_NT, a.RTO_NF, a.INT_NF, a.RETPAY_NF, a.RETKEY_CF, 0, a.ACCTYP_NF
--from BEST..TLIFPLN a
--where not exists ( select 1
                   from BEST..TREQJOB c
                   where c.REQCOD_CT = 'A'
                     and c.SSD_CF    = a.SSD_CF
                     and c.LAUNCH_D is not null 
                   --  and SITE_CF = @site_cf
--                )
--  and a.CRE_D > ( select max(LAUNCH_D)
--                   from BEST..TREQJOB c
--                   where c.REQCOD_CT = 'B' 
--                   and SITE_CF = @site_cf
--                )
-- SELECT @erreur = @@error
--if @erreur != 0
--begin
--    select "Erreur dans le premier select"
--    goto fin
--end
*/
--[001] Sinon, On prends les Ecritures service faites après la dernière demande de fichier plan pour la filiale.
select a.SSD_CF, a.ESB_CF, a.BALSHEY_NF, a.BALSHRMTH_NF, a.BALSHRDAY_NF, a.TRNCOD_CF, a.DBLTRNCOD_CF, a.CTR_NF,
       a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.OCCYEA_NF, a.ACY_NF, a.SCOSTRMTH_NF, a.SCOENDMTH_NF, 0,
       a.CUR_CF, a.AMT_M, a.CED_NF, a.BRK_NF, a.GEMPRMPAY_NF, a.GANPAYORD_NT, a.RETCTR_NF, a.RETEND_NT,
       a.RETSEC_NF, a.RETRTY_NF, a.RETUW_NT, a.RETOCCYEA_NF, a.RETACY_NF, a.RETSCOSTRMTH_NF, a.RETSCOENDMTH_NF,
       0, a.RETCUR_CF, a.RETAMT_M, a.PLC_NT, a.RTO_NF, a.INT_NF, a.RETPAY_NF, a.RETKEY_CF, 0, a.ACCTYP_NF
from BEST..TLIFPLN a, BEST..TREQJOB b
where a.SSD_CF = b.SSD_CF
  and convert(char(8), a.CRE_D, 112)  > convert(char(8), b.LAUNCH_D, 112)
  and b.REQCOD_CT = 'A'
  and b.SITE_CF = @site_cf
  and a.cre_D > ( select max(c.LAUNCH_D) --[101]
                     from BEST..TREQJOB c
                     where c.REQCOD_CT = b.REQCOD_CT
                       and c.SSD_CF    = b.SSD_CF )

  and b.LAUNCH_D is not null

SELECT @erreur = @@error
if @erreur != 0
begin
    select "Erreur dans le deuxieme select"
    goto fin
end


/* ------------------------------------------------------------
   Fin de la transaction
 -------------------------------------------------------------- */
if @tran_imbr = 0
    COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
    ROLLBACK TRAN

return 1
go
EXEC sp_procxmode 'dbo.PsESTLIFPLN_01', 'unchained'
go
IF OBJECT_ID('dbo.PsESTLIFPLN_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsESTLIFPLN_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsESTLIFPLN_01 >>>'
go
GRANT EXECUTE ON dbo.PsESTLIFPLN_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsESTLIFPLN_01 TO GDBBATCH
go
