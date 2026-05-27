USE BEST
go
IF OBJECT_ID('dbo.PuRETCATCVR_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuRETCATCVR_01_O2
    IF OBJECT_ID('dbo.PuRETCATCVR_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuRETCATCVR_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuRETCATCVR_01_O2 >>>'
END
go
create procedure dbo.PuRETCATCVR_01_O2
(
@p_SSD_CF  USSD_CF,
@p_usr_cf  UUSR_CF,
@p_balsh_d Datetime,
@p_erreur  varchar(64)= null output
)
as
/*****************************************************************
Domain            : Estimate
Base              : BEST
Author            : S.Gupta
Creation date     : 04/03/2015
Description       : Update BEST..TRETCATCVR from data of BTRAV..EST_ESID0861_TRETCATCVR,
					after check functional errors(Evo card EST56c)
_________________
MODIFICATIONS
1 S.Gupta       04/03/2015 création
2 Gaurav Pujari 23/11/2015 added for defect 41414
3 Sumit Gupta   08/02/2016 added for defect 44369
4 Florent       23/05/2017 :spira:59006 EST56c - Les demandes d'ES CAT COVER chargées par fichier ne se comptabilisent pas dans l'Inventaire
5 Riyadh : Spira 76814
*******************************************************************/
declare
  @erreur    int,
  @tran_imbr bit,
  @lignes    int,
  @insert_error int

select @erreur = 0, @tran_imbr = 1

if @@trancount = 0
begin
  select @tran_imbr = 0
  begin TRAN
end

--Clean TCTRANO Table for current SSD_CF
delete from BEST..TCTRANO where SSD_CF=@p_SSD_CF AND SEG_NF=@p_usr_cf AND VRS_NF=0 AND SEGTYP_CT= 'C'
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--Pre-Retrieve checks
--1. Check there is no duplicate rows in the input file (use BTRAV..EST_ESID0861_TRETCATCVR)
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET ERRORCOD_CT = 21014
    FROM BTRAV..EST_ESID0861_TRETCATCVR input1, BTRAV..EST_ESID0861_TRETCATCVR input2
    WHERE input1.RETCTR_NF    = input2.RETCTR_NF
    AND input1.RETSEC_NF    = input2.RETSEC_NF
    AND input1.RTY_NF       = input2.RTY_NF
    AND input1.BALSH_D      = input2.BALSH_D
    AND input1.ACMTRS_NT = input2.ACMTRS_NT
    AND input1.NUMLINE_NT  <> input2.NUMLINE_NT
    AND input1.rcl_nf = input2.rcl_nf -- modif 2
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--2. Check that the closing period in the file (use BTRAV..EST_ESID0861_TRETCATCVR) is the same as the input
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET ERRORCOD_CT = 21016
    FROM BTRAV..EST_ESID0861_TRETCATCVR input1
    WHERE input1.BALSH_D <> @p_balsh_d
    AND ERRORCOD_CT IS NULL
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--3. Check that the Ledger correspond in the input file (use BTRAV..EST_ESID0861_TRETCATCVR)
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET ERRORCOD_CT = 21017
    FROM BTRAV..EST_ESID0861_TRETCATCVR input1
    WHERE input1.SSD_CF <> @p_ssd_cf
    AND ERRORCOD_CT IS NULL
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--4. Check that the Cat Cover domain in the input file (use BTRAV..EST_ESID0861_TRETCATCVR)
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET ERRORCOD_CT = 21013
    FROM BTRAV..EST_ESID0861_TRETCATCVR input1
    WHERE input1.ACMTRS_NT NOT IN (110, 111, 112, 113)
    AND ERRORCOD_CT IS NULL
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--Retrieve Ids
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET input1.RCATCVR_NT = cat.RCATCVR_NT
    FROM BEST..TRETCATCVR cat,BTRAV..EST_ESID0861_TRETCATCVR input1
    WHERE cat.RETCTR_NF    = input1.RETCTR_NF
    AND cat.RETSEC_NF    = input1.RETSEC_NF
    AND cat.RTY_NF       = input1.RTY_NF
    AND cat.BALSH_D      = input1.BALSH_D
    AND cat.CATCVRDMN_CT = input1.ACMTRS_NT
    AND cat.RCL_NF = input1.RCL_NF  -- modif 2
    AND cat.MANUAL_B     = 0
    AND ERRORCOD_CT IS NULL
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--Post-Retrieve checks
--1. Check that all the data from input exists in the DB (by column RCATCVR_NT) --MOD05
/*
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET ERRORCOD_CT = 21011
    FROM BTRAV..EST_ESID0861_TRETCATCVR input1
    WHERE input1.RCATCVR_NT IS NULL
    AND ERRORCOD_CT IS NULL
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end*/

update  BTRAV..EST_ESID0861_TRETCATCVR 
set ERRORCOD_CT = 21000
FROM BTRAV..EST_ESID0861_TRETCATCVR input
where  input.RTY_NF not  in (Select distinct c.rty_nf
from BRET..TRETCTR C, BRET..TPLACEMT P
where C.RETCTR_NF = P.RETCTR_NF
and  C.RETCTR_NF = input.RETCTR_NF
AND C.RTY_NF = P.RTY_NF
AND C.RTY_NF = input.RTY_NF
AND P.HIS_B = 0
AND P.ACCPLC_B = 1
AND (P.PLCSTS_CT =16 or P.PLCSTS_CT = 19)
        AND  c.ssd_cf =@p_SSD_CF)    
   
 select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="21000 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end      
--2. Check that the where we want to upload are not duplicated in the DB
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET ERRORCOD_CT = 21012
    FROM BEST..TRETCATCVR cat, BTRAV..EST_ESID0861_TRETCATCVR input1
    WHERE cat.RETCTR_NF  = input1.RETCTR_NF
    AND cat.RETSEC_NF    = input1.RETSEC_NF
    AND cat.RTY_NF       = input1.RTY_NF
    AND cat.BALSH_D      = input1.BALSH_D
    AND cat.CATCVRDMN_CT = input1.ACMTRS_NT
    AND cat.MANUAL_B     = 0
    AND cat.RCATCVR_NT   <> input1.RCATCVR_NT
    AND cat.RCL_NF = input1.RCL_NF  -- modif 2
    AND ERRORCOD_CT IS NULL
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--3. Check that the Claim is the claim in the input file is sync with the Claim in the DB
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET ERRORCOD_CT = 21015
    FROM BEST..TRETCATCVR cat,BTRAV..EST_ESID0861_TRETCATCVR input1
    WHERE cat.RCATCVR_NT   = input1.RCATCVR_NT
    AND cat.RCL_NF       <> input1.RCL_NF
    AND ERRORCOD_CT IS NULL
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--4. Check that SSD in the DB fits with SSD of the upload
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET ERRORCOD_CT = 21018
    FROM BEST..TRETCATCVR cat,BTRAV..EST_ESID0861_TRETCATCVR input1
    WHERE cat.RETCTR_NF    = input1.RETCTR_NF
    AND cat.RETSEC_NF    = input1.RETSEC_NF
    AND cat.RTY_NF       = input1.RTY_NF
    AND cat.BALSH_D      = input1.BALSH_D
    AND cat.CATCVRDMN_CT = input1.ACMTRS_NT
    AND cat.MANUAL_B     = 0
    AND cat.SSD_CF       <> input1.SSD_CF
    AND ERRORCOD_CT IS NULL
    AND cat.RCL_NF = input1.RCL_NF --Mod 3
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--5. check that currency of upload file does not fit with currency in the DB
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET ERRORCOD_CT = 21019
    FROM BEST..TRETCATCVR cat,BTRAV..EST_ESID0861_TRETCATCVR input1
    WHERE cat.RETCTR_NF    = input1.RETCTR_NF
    AND cat.RETSEC_NF    = input1.RETSEC_NF
    AND cat.RTY_NF       = input1.RTY_NF
    AND cat.BALSH_D      = input1.BALSH_D
    AND cat.CATCVRDMN_CT = input1.ACMTRS_NT
    AND cat.MANUAL_B     = 0
    AND cat.AECUR_CF     <> input1.CUR_CF
    AND ERRORCOD_CT IS NULL
    AND cat.RCL_NF = input1.RCL_NF --Mod 3
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--6. check if the retro contract is not terminated (TERCTR_B=1)
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET ERRORCOD_CT = 21021
         FROM BRET..TRETCTR ret,BTRAV..EST_ESID0861_TRETCATCVR input1
         WHERE ret.RETCTR_NF  = input1.RETCTR_NF
           AND ret.RTY_NF     = input1.RTY_NF
           AND ret.TERCTR_B   = 1
           AND ERRORCOD_CT IS NULL
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--7. check if the retro claim is not closed (CLMSTS_CF=2) or not taken up (CLMSTS_CF=3)
UPDATE BTRAV..EST_ESID0861_TRETCATCVR
    SET ERRORCOD_CT = 21022
         FROM BCTA..TRETCLM clm,BTRAV..EST_ESID0861_TRETCATCVR input1
         WHERE clm.RETCTR_NF    = input1.RETCTR_NF
           AND clm.RTY_NF       = input1.RTY_NF
          AND clm.RCL_NF       = input1.RCL_NF
           AND clm.CLMSTS_CF    in ('2', '3')
           AND ERRORCOD_CT IS NULL
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--Insert into BEST..TCTRANO in case of error in file, otherwise update BEST..TRETCATCVR
IF EXISTS(SELECT 1 FROM BTRAV..EST_ESID0861_TRETCATCVR WHERE ERRORCOD_CT <> Null)
BEGIN
   INSERT INTO TCTRANO
   SELECT
     RETCTR_NF as CTR_NF,
     0 as END_NT,
     RETSEC_NF as SEC_NF,
     0 as VRS_NF,
     @p_SSD_CF as SSD_CF,
     'C' as SEGTYP_CT,
     @p_usr_cf as SEG_NF,
     ERRORCOD_CT as ANO_CT,
     NUMLINE_NT,
     RTY_NF as UWY_NF,
     NULL
    FROM BTRAV..EST_ESID0861_TRETCATCVR cat
    WHERE cat.ERRORCOD_CT IS NOT NULL
END
ELSE --MODIF 005
    Begin
    
    UPDATE BEST..TRETCATCVR
    SET ULTAMT_M = input1.ULTAMT_M,
    TRNAMT_M = (input1.ULTAMT_M - cat.RETCEDAMT_M)
    FROM BEST..TRETCATCVR cat,BTRAV..EST_ESID0861_TRETCATCVR input1
    WHERE cat.RCATCVR_NT = input1.RCATCVR_NT
    and input1.RCATCVR_NT !=null
    
       
   declare @maxRCATCVR_NT int
   select @maxRCATCVR_NT = (select max(RCATCVR_NT) from BEST..TRETCATCVR)
   
select (NUMLINE_NT + @maxRCATCVR_NT) as RCATCVR_NT       ,
   SSD_CF               ,
   ESB_CF               ,
   RETCTR_NF            ,
   RTY_NF               ,
   RETSEC_NF            ,
   CUR_CF            ,
   BALSH_D              ,
   CASE When ACMTRS_NT = 24200000  Then 110
           When ACMTRS_NT = 24420000 Then  111
            Else ACMTRS_NT END    as  CATCVRDMN_CT         ,
   RCL_NF               ,
   NULL               ,
   0          ,
   ULTAMT_M             ,
   NULL             ,
   NULL               ,
   NULL               ,
   0            ,
   1             ,
   getdate()                ,
   @p_usr_cf             ,
   getdate()             ,
   @p_usr_cf          ,
   getdate()           ,
   @p_usr_cf   
   from BTRAV..EST_ESID0861_TRETCATCVR 
   WHERE RCATCVR_NT =Null

    IF EXISTS(SELECT 1 FROM BTRAV..EST_ESID0861_TRETCATCVR WHERE RCATCVR_NT =Null)
    begin
        INSERT INTO BEST..TRETCATCVR (   RCATCVR_NT ,   SSD_CF  ,   ESB_CF,   RETCTR_NF,   RTY_NF,   RETSEC_NF,   AECUR_CF,
   BALSH_D,   CATCVRDMN_CT,   RCL_NF,   PLC_NT,   RETCEDAMT_M,   ULTAMT_M,   TRNAMT_M,   TRN_NT,   CMT_NT,   BOOKING_B,   MANUAL_B,
   CRE_D,   CREUSR_CF,   LSTUPD_D,   LSTUPDUSR_CF,   LSTULTUPD_D,   LSTULTUPDUSR_CF      )
    select (NUMLINE_NT + @maxRCATCVR_NT) as RCATCVR_NT       ,
   SSD_CF               ,
   ESB_CF               ,
   RETCTR_NF            ,
   RTY_NF               ,
   RETSEC_NF            ,
   CUR_CF            ,
   BALSH_D              ,
   CASE When ACMTRS_NT = 24200000  Then 110
           When ACMTRS_NT = 24420000 Then  111
            Else ACMTRS_NT END    as  CATCVRDMN_CT         ,
   RCL_NF               ,
   NULL               ,
   0          ,
   ULTAMT_M             ,
   ULTAMT_M             ,
   NULL               ,
   NULL               ,
   0            ,
   1             ,
   getdate()                ,
   @p_usr_cf             ,
   getdate()             ,
   @p_usr_cf          ,
   getdate()           ,
   @p_usr_cf   
   from BTRAV..EST_ESID0861_TRETCATCVR 
   WHERE RCATCVR_NT =Null
    end
    

    END


select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--Clean up BTRAV..EST_ESID0861_TRETCATCVR
delete from BTRAV..EST_ESID0861_TRETCATCVR
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20113 APPLICATIF;EST_ESID0861_TRETCATCVR" + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
IF OBJECT_ID('dbo.PuRETCATCVR_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuRETCATCVR_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuRETCATCVR_01_O2 >>>'
go
GRANT EXECUTE ON dbo.PuRETCATCVR_01_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuRETCATCVR_01_O2 TO GDBBATCH
go
