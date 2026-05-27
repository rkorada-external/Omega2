USE BRET
go
if object_id('PuRET_TRREPLINK_TRETIFRS_01') is not null
begin
  drop procedure PuRET_TRREPLINK_TRETIFRS_01
  if object_id('PuRET_TRREPLINK_TRETIFRS_01') is not null
      print '<<< FAILED DROPPING procedure PuRET_TRREPLINK_TRETIFRS_01 >>>'
  else
      print '<<< DROPPED procedure PuRET_TRREPLINK_TRETIFRS_01 >>>'
end
go
create procedure PuRET_TRREPLINK_TRETIFRS_01
  (
  @cre_d datetime
  )
with execute as caller as
/*****
Programme: PuRET_TRREPLINK_TRETIFRS_01


Domaine : (Estimation)
Base principale : BTRT
Version: 1
Auteur: S.Behague
Date de creation:07/05/2024
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
UPDATE BRET..TRETIFRS
SET
GRPIFRSSEG_CT   =   FROMGRPIFRSSEG_CT,
GRPIFRSSEG_LL   =   FROMGRPIFRSSEG_LL,
GRPIFRSSEG1_CT  =   FROMGRPIFRSSEG1_CT,
GRPIFRSSEG1_LL  =   FROMGRPIFRSSEG1_LL,
GRPINIPRO_CF    =   FROMGRPINIPRO_CF,
GRPIFRSTRA_CT   =   FROMGRPIFRSTRA_CT,
GRPINISTS_CT    =   FROMGRPINISTS_CT,
GRPFSTCLO_D     =   FROMGRPFSTCLO_D,
GRPRATEINDEX_CT =   FROMGRPRATEINDEX_CT,
GRPANCO_NF      =   FROMGRPANCO_NF,     
RETRECOD_D      =   FROMRETRECOD_D,
LSTUPD_D        =   getdate()
FROM   BTRAV..SCOPE_TRREPLINK link, BRET..TRETIFRS retifrs
WHERE  link.TORETCTR_NF = retifrs.RETCTR_NF AND link.TORTY_NF = retifrs.RTY_NF
AND    link.ISTREATED_B = 0
AND    link.ISVALIDI17G_B = 1


if @erreur != 0
  begin
  	select  "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
   goto fin
  end
  

-- 2EME ETAPE : UPDATE 17P
UPDATE BRET..TRETIFRS
SET
PARIFRSSEG_CT   =   FROMPARIFRSSEG_CT,
PARIFRSSEG_LL   =   FROMPARIFRSSEG_LL,
PARIFRSSEG1_CT  =   FROMPARIFRSSEG1_CT,
PARIFRSSEG1_LL  =   FROMPARIFRSSEG1_LL,
PARINIPRO_CF    =   FROMPARINIPRO_CF,
PARIFRSTRA_CT   =   FROMPARIFRSTRA_CT,
PARINISTS_CT    =   FROMPARINISTS_CT,
PARFSTCLO_D     =   FROMPARFSTCLO_D,
PARRATEINDEX_CT =   FROMPARRATEINDEX_CT,
PARANCO_NF      =   FROMPARANCO_NF,
RETRECOD_D      =   FROMRETRECOD_D,
LSTUPD_D        =   getdate()
FROM   BTRAV..SCOPE_TRREPLINK link, BRET..TRETIFRS retifrs
WHERE  link.TORETCTR_NF = retifrs.RETCTR_NF AND link.TORTY_NF = retifrs.RTY_NF
AND    link.ISTREATED_B = 0
AND    link.ISVALIDI17P_B = 1


if @erreur != 0
  begin
  	select  "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
   goto fin
  end
  

-- 3EME ETAPE : UPDATE 17L
UPDATE BRET..TRETIFRS
SET
LOCIFRSSEG_CT   =   FROMLOCIFRSSEG_CT,
LOCIFRSSEG_LL   =   FROMLOCIFRSSEG_LL,
LOCIFRSSEG1_CT  =   FROMLOCIFRSSEG1_CT,
LOCIFRSSEG1_LL  =   FROMLOCIFRSSEG1_LL,
LOCINIPRO_CF    =   FROMLOCINIPRO_CF,
LOCIFRSTRA_CT   =   FROMLOCIFRSTRA_CT,
LOCINISTS_CT    =   FROMLOCINISTS_CT,
LCLFSTCLO_D     =   FROMLCLFSTCLO_D,
LCLRATEINDEX_CT =   FROMLCLRATEINDEX_CT,
LOCANCO_NF      =   FROMLOCANCO_NF,
RETRECOD_D      =   FROMRETRECOD_D,
LSTUPD_D        =   getdate()
FROM   BTRAV..SCOPE_TRREPLINK link, BRET..TRETIFRS retifrs
WHERE  link.TORETCTR_NF = retifrs.RETCTR_NF AND link.TORTY_NF = retifrs.RTY_NF
AND    link.ISTREATED_B = 0
AND    link.ISVALIDI17L_B = 1


-- 4EME ETAPE : UPDATE ISTREATED = 1 
UPDATE BTRAV..SCOPE_TRREPLINK
SET    ISTREATED_B = 1,
       ISUPDATEFAILED_B = 0,
       LSTUPD_D = getdate()
FROM   BTRAV..SCOPE_TRREPLINK link
WHERE  link.ISTREATED_B = 0
AND    ( link.ISVALIDI17G_B = 1 OR link.ISVALIDI17P_B = 1 OR link.ISVALIDI17L_B = 1 )


if @erreur != 0
  begin
  	select  "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
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

UPDATE BTRAV..SCOPE_TRREPLINK
SET    ISUPDATEFAILED_B = 1
FROM   BTRAV..SCOPE_TRREPLINK link
WHERE  link.ISTREATED_B = 0
AND    ( link.ISVALIDI17G_B = 1 OR link.ISVALIDI17P_B = 1 OR link.ISVALIDI17L_B = 1 )
end

PRINT '-- FIN de la procedure bret..PuTRT_TREPLINK_TSECIFRS_01'

return @erreur

go
EXEC sp_procxmode 'PuRET_TRREPLINK_TRETIFRS_01', 'unchained'
go
IF OBJECT_ID('PuRET_TRREPLINK_TRETIFRS_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PuRET_TRREPLINK_TRETIFRS_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PuRET_TRREPLINK_TRETIFRS_01 >>>'
go
GRANT EXECUTE ON PuRET_TRREPLINK_TRETIFRS_01 TO GOMEGA
go
GRANT EXECUTE ON PuRET_TRREPLINK_TRETIFRS_01 TO GDBBATCH
go
