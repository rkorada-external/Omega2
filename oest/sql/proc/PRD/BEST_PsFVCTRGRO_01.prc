USE BEST
go
IF OBJECT_ID('dbo.PsFVCTRGRO_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsFVCTRGRO_01
    IF OBJECT_ID('dbo.PsFVCTRGRO_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsFVCTRGRO_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsFVCTRGRO_01 >>>'
END
go
create procedure PsFVCTRGRO_01
	(
	@p_option    char(1),
	@p_segtyp_ct char(1)
	)
with execute as caller as
/***************************************************
Domaine : Estimations
Base principale : BEST
Auteur: Florent
Date de creation: 04/06/2015
Description du programme: Descente de la table BEST..TCTRGRO en segmentation et en inventaire
                          :spot:28694 Segmentation VIE, ici sélection uniquement de la VIE!  
Conditions d'execution:
Commentaires: création à partir dePsSECTION_13 pour la VIE
_________________
MODIFICATION 1
Auteur: M.HA-THUC
Date: 15/09/1998
Description: la jointure avec BTRAV..TESTSSD est remplacée par une jointure
	avec BTRAV..TESTSSDVRS. 
	On descend maintenant la table BEST..TCTRGRO quelque soit la filiale et 
	le type de segment. 
	De plus, le paramètre @p_option ne prend plus la valeur 'I' 
	( pour inventaire ) mais 'Q' ( pour quotidien ).
	Avant cette modif, la table BEST..TCTRGRO était descendue à chaque 
	inventaire et pour segtyp_ct = 'A'; maintenant, elle est descendue 
	quotidiennement et le filtre sur segtyp_ct = 'A' a été déplacé
	dans la chaîne ESID0560.
	Un tri sur la clé CTR_NF, END_NT, SEC_NF a été rajouté.
_________________
 10/09/2018 M.NAJI ajout de la colonne UWY_NF spira 57605
 
 test:
 select * from BEST..TCTRGRO
    BEST..PsFVCTRGRO_01 'S' , 'A'
    select * from BTRAV..TESTSSDVRS
     select * from BTRAV..TESTSSDTMP
     select * from BREF..TESB e where e.LIFE_CF=2 and e.SSD_CF in ( 22,20)
*****************************************************/
declare @erreur int

select @erreur = 0
-- Cas multifiliale ( quotidien )
-- La liste des filiales est dans la table BTRAV..TESTSSDVRS

if @p_option = 'Q'
BEGIN
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
   and not exists(select 1 from BREF..TESB e where e.LIFE_CF=2 and e.SSD_CF=CTRGRO.SSD_CF)
   and 	 CTRGRO.SEGTYP_CT = ESTSSD.SEGTYP_CT
   and 	 CTRGRO.VRS_NF = ESTSSD.VRS_NF
   and   CTRGRO.SSD_CF = ESTSSD.SSD_CF
   order by CTRGRO.CTR_NF, CTRGRO.END_NT, CTRGRO.SEC_NF,UWY_NF
END

-- Cas multifiliale (segmentation)
-- La liste des filiales est dans la table BTRAV..TESTSSDTMP
ELSE if @p_option = 'S'
BEGIN
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
   from   BEST..TCTRGRO CTRGRO, BTRAV..TESTSSDTMP ESTSSD
   where  CTRGRO.SEGTYP_CT=@p_segtyp_ct
   and not exists(select 1 from BREF..TESB e where e.LIFE_CF=2 and e.SSD_CF=CTRGRO.SSD_CF)
   and    CTRGRO.SSD_CF=ESTSSD.SSD_CF
   and    CTRGRO.VRS_NF=ESTSSD.VRS_NF
   and    CTRGRO.SEGTYP_CT=ESTSSD.SEGTYP_CT
   and    CTRGRO.SSD_CF = ESTSSD.SSD_CF 
   order by CTRGRO.CTR_NF, CTRGRO.END_NT, CTRGRO.SEC_NF,UWY_NF
END

select @erreur = @@error
if @erreur != 0
begin
  return @erreur
end
return 0
go
EXEC sp_procxmode 'dbo.PsFVCTRGRO_01', 'unchained'
go
IF OBJECT_ID('dbo.PsFVCTRGRO_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsFVCTRGRO_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsFVCTRGRO_01 >>>'
go
GRANT EXECUTE ON dbo.PsFVCTRGRO_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsFVCTRGRO_01 TO GDBBATCH
go

