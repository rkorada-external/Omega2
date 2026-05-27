use BEST
go
if object_id('dbo.PsACCPAR_resul') is not null
begin
  drop PROC dbo.PsACCPAR_resul
  print '<<< DROPPED PROC dbo.PsACCPAR_resul >>>'
end
go
create procedure PsACCPAR_resul
(
 @p_SSD_CF       USSD_CF=0
,@p_ACCADMTYP_CT UACCADMTYP_CT=null -- type comptable de la section/exercice
)
as
/***************************************************
Programme:          PsACCPAR_resul
Domaine :           (ES) Estimation
Base principale :   BEST
Auteur:             Florent
Date de creation:   13/09/2011
Description du programme: :spot:22315 renvoyer la liste des postes et indique à quels poste de résultats ils participent
Commentaires: utilisé par w_feuille_es2200 et w_feuille_es2100
_________________
MODIFICATIONS
*****************************************************/
select
  ACMTRS_NT
 ,POSITION_NT
 ,ADJSIG_B
 ,RESTEC_B
 ,RESDAC_B
 ,RESFIN_B
 ,SUMRISK_B
 ,PRIME_B = case when ACMTRS_NT%1000 in(10,11) then 1 else 0 end
 ,PRIME_ACQUISE_B = case when ACMTRS_NT%1000 in(10,11,21,22,63,64,73,74,83,84,93,94) then 1 else 0 end
 ,CHARGE_B = case when ACMTRS_NT%1000 in(100,110,140,150,160,163,164) then 1
                  when ACMTRS_NT in(2183,2184,2193,2194,2145) then 1
                  when @p_SSD_CF=14 and ACMTRS_NT in(1183,1184) then 1
                  when @p_SSD_CF!=14 and ACMTRS_NT in(1193,1194) then 1
                  else 0 end
 ,SINISTRE_B = case when ACMTRS_NT%1000 in(200,210,220,231,232,243,244,263,264) then 1 else 0 end
 ,INTERET_B = case when ACMTRS_NT%1000 = 340 then 1 else 0 end
 ,DEPOT_B = case when ACMTRS_NT%1000 in(304,324) then 1 else 0 end
-- si @p_ACCADMTYP_CT est null ou pas un compte de constitution alors la fonction retournera null
 ,LIBERE_EXE_P1_N=dbo.FtLiberationExeP1(@p_ACCADMTYP_CT,ACMTRS_NT)
 from BEST..TACCPAR
go
if object_id('dbo.PsACCPAR_resul') is not null
  print '<<< CREATED PROC dbo.PsACCPAR_resul >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsACCPAR_resul >>>'
go
grant execute on dbo.PsACCPAR_resul TO GOMEGA
go
