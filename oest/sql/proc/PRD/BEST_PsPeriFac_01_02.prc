/** Alter Procedure Script **/
use BEST
go

drop procedure dbo.PsPeriFac_01_02
go

create procedure PsPeriFac_01_02
--(
-- @p_segtyp_ct char(1) --type de segmentation ( 'A' ou 'E' )
--)
as
/****************************************************************************************************************************
** Domaine                  : Estimations
** Base principale          : BEST
** Version                  : 1.0
** Auteur                   : B.LAGHA version 1.0 (AUTO)
** Date de creation         : 21/03/2019
** Description du programme : Descente du périmètre acceptation fac au niveau CASEX sans filtre sur la date d'effet.
** Conditions d'execution   :
** Commentaires             :
** __________________________
** Modification : [001] - Spira 64222 - ajout de nouveaux champs dans le pericase et modifier les calcule EST41.
** Author       : B.LAGHA
** Date de modif: 21/03/2019
** Description  : ajout de nouveaux champs dans le pericase.
*****************************************************************************************************************************/
declare @erreur int
select @erreur = 0

--------------------------------
-- Périmètre pour les traités --
--------------------------------
SELECT SECTION.SSD_CF,
--       @p_segtyp_ct,
       SECTION.CTR_NF,
       SECTION.END_NT,
       SECTION.SEC_NF,
       SECTION.UWY_NF,
       SECTION.UW_NT,
       FAMFUNW.CLMFUNVARINT_B,
       FAMFUNW.CLMFUNESTINT_R,
       FAMFUNW.URRFUNVARINT_B,
       FAMFUNW.URRFUNESTINT_R,
       FAMFUNW.ANNFUNVARINT_B,
       FAMFUNW.ANNFUNCAS_R,
       FAMFUNW.ANNFUNESTINT_R,
       FAMFUNW.LIFRESVARINT_B,
       FAMFUNW.LIFRESCAS_R,
       FAMFUNW.LIFRESINT_R,
       FAMFUNW.LIFRESESTINT_R,
       FAMFUNW.ANNFUN_R,
       FAMFUNW.LIFRES_R,
       CHAMP_LIBRE_03=null, -- champs libre
       CHAMP_LIBRE_04=null, -- champs libre
       CHAMP_LIBRE_05=null,
       CHAMP_LIBRE_06=null,
       CHAMP_LIBRE_07=null,
       CHAMP_LIBRE_08=null,
       CHAMP_LIBRE_09=null,
       CHAMP_LIBRE_10=null,
       CHAMP_LIBRE_11=null,
       CHAMP_LIBRE_12=null,
       CHAMP_LIBRE_13=null,
       CHAMP_LIBRE_14=null,
       CHAMP_LIBRE_15=null,
       CHAMP_LIBRE_16=null,
       CHAMP_LIBRE_17=null,
       CHAMP_LIBRE_18=null,
       CHAMP_LIBRE_19=null,
       CHAMP_LIBRE_20=null,
       CHAMP_LIBRE_21=null,
       CHAMP_LIBRE_22=null,
       CHAMP_LIBRE_23=null,
       CHAMP_LIBRE_24=null,
       CHAMP_LIBRE_25=null,
       CHAMP_LIBRE_26=null,
       CHAMP_LIBRE_27=null,
       CHAMP_LIBRE_28=null,
       CHAMP_LIBRE_29=null,
       CHAMP_LIBRE_30=null,
       CHAMP_LIBRE_31=null,
       CHAMP_LIBRE_32=null,
       CHAMP_LIBRE_33=null,
       CHAMP_LIBRE_34=null,
       CHAMP_LIBRE_35=null,
       CHAMP_LIBRE_36=null,
       CHAMP_LIBRE_37=null,
       CHAMP_LIBRE_38=null,
       CHAMP_LIBRE_39=null,
       CHAMP_LIBRE_40=null,
       CHAMP_LIBRE_41=null,
       CHAMP_LIBRE_42=null,
       CHAMP_LIBRE_43=null,
       CHAMP_LIBRE_44=null,
       CHAMP_LIBRE_45=null,
       CHAMP_LIBRE_46=null,
       CHAMP_LIBRE_47=null,
       CHAMP_LIBRE_48=null,
       CHAMP_LIBRE_49=null,
       CHAMP_LIBRE_50=null,
       CHAMP_LIBRE_51=null,
       CHAMP_LIBRE_52=null,
       CHAMP_LIBRE_53=null
       
  FROM BFAC..TSECTION  SECTION
      ,BFAC..TFAMFUNW  FAMFUNW
      ,BREF..TBATCHSSD T

WHERE T.BATCHUSER_CF = suser_name()
  and SECTION.SECSTS_CT IN(16,18,19)
  and SECTION.SSD_CF = T.SSD_CF
  and SECTION.CTR_NF*= FAMFUNW.CTR_NF
  and SECTION.END_NT*= FAMFUNW.END_NT
  and SECTION.SEC_NF*= FAMFUNW.SEC_NF
  and SECTION.UWY_NF*= FAMFUNW.UWY_NF
  and SECTION.UW_NT *= FAMFUNW.UW_NT
  
select @erreur = @@error
if @erreur != 0
begin
    return @erreur
end

return 0
go

GRANT EXECUTE ON dbo.PsPeriFac_01_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPeriFac_01_02 TO GDBBATCH
go

