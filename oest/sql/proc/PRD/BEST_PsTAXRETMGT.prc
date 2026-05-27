USE BEST
go

IF OBJECT_ID('dbo.PsTAXRETMGT') IS NOT NULL
BEGIN
  DROP PROC dbo.PsTAXRETMGT
  PRINT '<<< DROPPED PROC dbo.PsTAXRETMGT >>>'
END
go

create procedure PsTAXRETMGT
(
    --@p_NORM                 varchar(4),
		@PARM_ICLODAT_D 			  datetime
)

as

--with execute as caller as
/***************************************************
Programme: PsTAXRETMGT
Domaine : (ES) Estimation
Base principale : BRET
Version: Version:spira:87852: Retrocession automatized Tax Estimates management
Auteur: MZM
Date de creation: 04/10/2021
Description du programme: Extraction des Taxes pour l'automatisation en Retro
                         
Parametres: date de closing 
Conditions d'execution: 
Commentaires:
_________________
MODIFICATIONS

*****************************************************/


select distinct 
  TP.RETCTR_NF	
, TP.RTY_NF	
, TP.PLC_NT	
, TP.PLCVER_NT	
, TP.RETPRMTAXORD_NT	
, TP.SSD_CF	
, TP.ESB_CF	
, TP.RTO_NF	
, TP.RETPRMTAX_CT	       -- basic
, TP.PLCRETPRMTAX_R	
, convert(char(8), TP.PLCTAXSTRAPP_D, 112)	
, convert(char(8), TP.PLCTAXENDAPP_D, 112)
, TR.CTLGPRMTAX_CT	
, TR.PRMTAXBASIS_NT	
, TR.CTLGPRMTAX_R	
, TR.TAXTRNCOD_CF	
, TR.TAXESTMGT_B	
, TR.CTLGPRMTAXACT_B	
, convert(char(8), TR.CTLGTAXSTRAPP_D, 112)
, convert(char(8), TR.CTLGTAXENDAPP_D, 112)
  
from  BRET..TPLCTAXPRM TP,  
      BRET..TRTAXPRMCTLG TR,  
      BREF..TTRSLNK TT,
      BREF..TBATCHSSD BA
      
where TP.ssd_cf = TR.SSD_CF
and   TP.ESB_CF = TR.ESB_CF
and   TT.ACMTRS_NT = TR.PRMTAXBASIS_NT
and   TP.RETPRMTAX_CT = TR.CTLGPRMTAX_CT

and   TR.TAXESTMGT_B = 1
and   TR.CTLGPRMTAXACT_B = 1
and   TP.HIS_B = 0

and   TP.PLCTAXENDAPP_D >= @PARM_ICLODAT_D 
and   TP.PLCTAXSTRAPP_D <= @PARM_ICLODAT_D

and   TP.SSD_CF=BA.SSD_CF
AND   BA.BATCHUSER_CF = suser_name() 

go

EXEC sp_procxmode 'dbo.PsTAXRETMGT', 'unchained'
go

IF OBJECT_ID('dbo.PsTAXRETMGT') IS NOT NULL
  PRINT '<<< CREATED PROC dbo.PsTAXRETMGT >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC dbo.PsTAXRETMGT >>>'
go
GRANT EXECUTE ON dbo.PsTAXRETMGT TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTAXRETMGT TO GDBBATCH
go

