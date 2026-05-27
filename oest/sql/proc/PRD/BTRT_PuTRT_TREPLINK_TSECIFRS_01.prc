USE BTRT
go
if object_id('PuTRT_TREPLINK_TSECIFRS_01') is not null
begin
  drop procedure PuTRT_TREPLINK_TSECIFRS_01
  if object_id('PuTRT_TREPLINK_TSECIFRS_01') is not null
      print '<<< FAILED DROPPING procedure PuTRT_TREPLINK_TSECIFRS_01 >>>'
  else
      print '<<< DROPPED procedure PuTRT_TREPLINK_TSECIFRS_01 >>>'
end
go
create procedure PuTRT_TREPLINK_TSECIFRS_01
  (
  @cre_d datetime
  )
with execute as caller as
/*****
Programme: PuTRT_TREPLINK_TSECIFRS_01


Domaine : (Estimation)
Base principale : BTRT
Version: 1
Auteur: S.Behague
Date de creation:06/05/2024
Description du programme:

      Proc appelee par le ESIJ0830

Parametres:
Conditions d'execution:
Commentaires:
Auteur          | Date        | Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
S.Behague   		| 06/05/2024  | Creation
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
-- 06-05-2024 MOD[001] - S.Behague - 110557 - L&H - Automate treaty update (NTAP)
-- 25-09_2024 MOD[002] - S.Behague - 112207 - NTAP - Source contract UWY management
******************************************************************************************************/
declare @erreur int,
        @tran_imbr	bit

select @erreur = 0
select @tran_imbr = 1
if @@trancount = 0
begin
   select @tran_imbr = 0
   BEGIN TRAN
end

-- 1ERE ETAPE : UPDATE 17G
UPDATE BTRT..TSECIFRS
SET 
GRPIFRSSEG_CT     = link.FROMGRPIFRSSEG_CT,
GRPIFRSSEG_LL     = link.FROMGRPIFRSSEG_LL,
GRPIFRSSEG1_CT    = link.FROMGRPIFRSSEG1_CT,
GRPIFRSSEG1_LL    = link.FROMGRPIFRSSEG1_LL,
GRPINIPRO_CF      = link.FROMGRPINIPRO_CF,
GRPIFRSTRA_CT     = link.FROMGRPIFRSTRA_CT,
GRPINISTS_CT      = link.FROMGRPINISTS_CT,
GRPFIRCLO_D       = link.FROMGRPFIRCLO_D,
GRPRATEINDEX_CT   = link.FROMGRPRATEINDEX_CT,
GRPANCO_NF        = link.FROMGRPANCO_NF,
RECOD_D           = link.FROMRECOD_D,
LSTUPD_D          = getdate()
FROM   BTRAV..SCOPE_TREPLINK link, BTRT..TSECIFRS secifrs
WHERE  link.TOCTR_NF = secifrs.CTR_NF AND link.TOSEC_NF = secifrs.SEC_NF AND link.TOUWY_NF = secifrs.UWY_NF AND link.TOUW_NT = secifrs.UW_NT AND link.TOEND_NT = secifrs.END_NT
AND    link.ISTREATED_B = 0
AND    link.ISVALIDI17G_B = 1

if @erreur != 0
  begin
  	select  "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
   goto fin
  end


-- 2EME ETAPE : UPDATE 17P
UPDATE BTRT..TSECIFRS
SET 
PARIFRSSEG_CT     = link.FROMPARIFRSSEG_CT,
PARIFRSSEG_LL     = link.FROMPARIFRSSEG_LL,
PARIFRSSEG1_CT    = link.FROMPARIFRSSEG1_CT,
PARIFRSSEG1_LL    = link.FROMPARIFRSSEG1_LL,
PARINIPRO_CF      = link.FROMPARINIPRO_CF,
PARIFRSTRA_CT     = link.FROMPARIFRSTRA_CT,
PARINISTS_CT      = link.FROMPARINISTS_CT,
PARFIRCLO_D       = link.FROMPARFIRCLO_D,
PARRATEINDEX_CT   = link.FROMPARRATEINDEX_CT,
PARANCO_NF        = link.FROMPARANCO_NF,
RECOD_D           = link.FROMRECOD_D,
LSTUPD_D          = getdate()
FROM   BTRAV..SCOPE_TREPLINK link, BTRT..TSECIFRS secifrs
WHERE  link.TOCTR_NF = secifrs.CTR_NF AND link.TOSEC_NF = secifrs.SEC_NF AND link.TOUWY_NF = secifrs.UWY_NF AND link.TOUW_NT = secifrs.UW_NT AND link.TOEND_NT = secifrs.END_NT
AND    link.ISTREATED_B = 0
AND    link.ISVALIDI17P_B = 1

if @erreur != 0
  begin
  	select "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
   goto fin
  end
  
-- 3EME ETAPE : UPDATE 17L
UPDATE BTRT..TSECIFRS
SET 
LOCIFRSSEG_CT     = link.FROMLOCIFRSSEG_CT,
LOCIFRSSEG_LL     = link.FROMLOCIFRSSEG_LL,
LOCIFRSSEG1_CT    = link.FROMLOCIFRSSEG1_CT,
LOCIFRSSEG1_LL    = link.FROMLOCIFRSSEG1_LL,
LOCINIPRO_CF      = link.FROMLOCINIPRO_CF,
LOCIFRSTRA_CT     = link.FROMLOCIFRSTRA_CT,
LOCINISTS_CT      = link.FROMLOCINISTS_CT,
LOCFIRCLO_D       = link.FROMLOCFIRCLO_D,
LOCRATEINDEX_CT   = link.FROMLOCRATEINDEX_CT,
LOCANCO_NF        = link.FROMLOCANCO_NF,
RECOD_D           = link.FROMRECOD_D,
LSTUPD_D          = getdate()
FROM   BTRAV..SCOPE_TREPLINK link, BTRT..TSECIFRS secifrs
WHERE  link.TOCTR_NF = secifrs.CTR_NF AND link.TOSEC_NF = secifrs.SEC_NF AND link.TOUWY_NF = secifrs.UWY_NF AND link.TOUW_NT = secifrs.UW_NT AND link.TOEND_NT = secifrs.END_NT
AND    link.ISTREATED_B = 0
AND    link.ISVALIDI17L_B = 1

if @erreur != 0
  begin
  	select "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
   goto fin
  end
  
-- 4EME ETAPE : UPDATE ISTREATED = 1 
UPDATE BTRAV..SCOPE_TREPLINK
SET    ISTREATED_B = 1,
       ISUPDATEFAILED_B = 0,
       LSTUPD_D = getdate()
FROM   BTRAV..SCOPE_TREPLINK link
WHERE   link.ISTREATED_B = 0
AND    ( link.ISVALIDI17G_B = 1 OR link.ISVALIDI17P_B = 1 OR link.ISVALIDI17L_B = 1 )

if @erreur != 0
  begin
  	select "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
   goto fin
  end
  


-- FIN NORMALE DE LA PROC

if @tran_imbr = 0
   COMMIT TRAN

PRINT '-- FIN de la procedure bret..PuTRT_TREPLINK_TSECIFRS_01'

return 0

fin:
if @tran_imbr = 0
begin
   ROLLBACK TRAN
   
UPDATE BTRAV..SCOPE_TREPLINK
SET    ISUPDATEFAILED_B = 1
FROM   BTRAV..SCOPE_TREPLINK link
WHERE  link.ISTREATED_B = 0
AND    ( link.ISVALIDI17G_B = 1 OR link.ISVALIDI17P_B = 1 OR link.ISVALIDI17L_B = 1 )
end

PRINT '-- FIN de la procedure bret..PuTRT_TREPLINK_TSECIFRS_01'

return @erreur

go

EXEC sp_procxmode 'PuTRT_TREPLINK_TSECIFRS_01', 'unchained'

go
IF OBJECT_ID('PuTRT_TREPLINK_TSECIFRS_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PuTRT_TREPLINK_TSECIFRS_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PuTRT_TREPLINK_TSECIFRS_01 >>>'
go
GRANT EXECUTE ON PuTRT_TREPLINK_TSECIFRS_01 TO GOMEGA
go
GRANT EXECUTE ON PuTRT_TREPLINK_TSECIFRS_01 TO GDBBATCH
go
