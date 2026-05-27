use BEST
go
IF OBJECT_ID('PsSECTIONI17_10') IS NOT NULL
BEGIN
  DROP PROC PsSECTIONI17_10
  PRINT '<<< DROPPED PROC PsSECTIONI17_10 >>>'
END
go
create procedure PsSECTIONI17_10  

with execute as caller as
/***************************************************
Programme: PsSECTIONI17_10
Domaine : Estimations
Base principale : BEST
Version: 1
Date de creation: 07/06/2021
Description du programme: 
Créé à partir de la procédure PsSECTION_10 utilisé dans IFRS4
Descente de la table BEST..TCTRGRO en segmentation et en inventaire
Conditions d'execution: 
Commentaires:
_________________
*****************************************************/
declare @erreur int

select @erreur = 0

-- La liste des filiales est dans la table BTRAV..TESTSSDVRS


select CTRGRO.CTR_NF,
       CTRGRO.END_NT,
       CTRGRO.SEC_NF,
       CTRGRO.VRS_NF,
       CTRGRO.SSD_CF,
       CTRGRO.SEGTYP_CT,
       CTRGRO.SEG_NF,
       CTRGRO.DIV_NT,
       CTRGRO.CED_NF,
       CTRGRO.UWGRP_CF,
       CTRGRO.LOB_CF,
       CTRGRO.SOB_CF,
       CTRGRO.TOP_CF,
       CTRGRO.NAT_CF,
       CTRGRO.SUBNAT_CF,
       CTRGRO.PCPRSKTRY_CF,
       CONVERT(char(8), CTRGRO.SECINC_D, 112),
       CONVERT(char(8), CTRGRO.SECCAN_D, 112), CTRGRO.CTRRET_B,
       CONVERT(char(8), CTRGRO.CRE_D, 112),
       CTRGRO.UWY_NF
from   BEST..TCTRGRO CTRGRO, BTRAV..TESTSSDVRS ESTSSD
where  CTRGRO.SSD_CF = ESTSSD.SSD_CF
and exists(select 1 from BREF..TESB e where e.LIFE_CF=2 and e.SSD_CF=CTRGRO.SSD_CF)
and 	 CTRGRO.SEGTYP_CT = ESTSSD.SEGTYP_CT
and 	 CTRGRO.VRS_NF = ESTSSD.VRS_NF
and   CTRGRO.SSD_CF = ESTSSD.SSD_CF
order by CTRGRO.CTR_NF, CTRGRO.END_NT, CTRGRO.SEC_NF,UWY_NF

select @erreur = @@error
if @erreur != 0
begin
  return @erreur
end
return 0
go
IF OBJECT_ID('PsSECTIONI17_10') IS NOT NULL
  PRINT '<<< CREATED PROC PsSECTIONI17_10 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PsSECTIONI17_10 >>>'
go
GRANT EXECUTE ON PsSECTIONI17_10 TO GOMEGA
go
GRANT EXECUTE ON PsSECTIONI17_10 TO GDBBATCH
go


