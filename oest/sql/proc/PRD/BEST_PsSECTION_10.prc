use BEST
go
IF OBJECT_ID('PsSECTION_10') IS NOT NULL
BEGIN
  DROP PROC PsSECTION_10
  PRINT '<<< DROPPED PROC PsSECTION_10 >>>'
END
go
create procedure PsSECTION_10
	(
	@p_option    char(1),
	@p_segtyp_ct char(1)
	)
with execute as caller as
/***************************************************
Programme: PsSECTION_10
Fichier script associé : ESSSEC10.PRC
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation: 
Description du programme: Descente de la table BEST..TCTRGRO en segmentation et en inventaire
Conditions d'execution: 
Commentaires:
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
2                      Removed dbo and added ‘with execute as caller as’
3 -=Dch=-   07/08/2013 :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
4 R. Cassis 31/12/2013 :spot:25427 -- Centralisation modification de la jointure TBATCHSSD car passe pas sur dev
5  Florent  04/06/2015 :spot:28694 Segmentation VIE, ici sélection uniquement des dommages !
6 M.NAJI 10/09/2018 add UWY_NF in TCTRGRO , spira 57605
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
   and exists(select 1 from BREF..TESB e where e.LIFE_CF=2 and e.SSD_CF=CTRGRO.SSD_CF)
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
   and exists(select 1 from BREF..TESB e where e.LIFE_CF=2 and e.SSD_CF=CTRGRO.SSD_CF)
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
IF OBJECT_ID('PsSECTION_10') IS NOT NULL
  PRINT '<<< CREATED PROC PsSECTION_10 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PsSECTION_10 >>>'
go
GRANT EXECUTE ON PsSECTION_10 TO GOMEGA
go
GRANT EXECUTE ON PsSECTION_10 TO GDBBATCH
go


