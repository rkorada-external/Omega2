USE BEST
go
IF OBJECT_ID('dbo.PsIfrs17Cond_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PsIfrs17Cond_01
  IF OBJECT_ID('dbo.PsIfrs17Cond_01') IS NOT NULL
  PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsIfrs17Cond_01 >>>'
  ELSE
  PRINT '<<< DROPPED PROCEDURE dbo.PsIfrs17Cond_01 >>>'
END
go
/*
 * creation de la procedure */ 
create procedure PsIfrs17Cond_01 (
  @p_CRE_D  char(8)
)
/*
 BEST..PsIfrs17Cond_01 
  @p_CRE_D  ='20210725'

*/
with execute as caller as
/***************************************************
Programme: PsIfrs17Cond_01
Fichier script associé : BEST_PsIfrs17Cond_01.prc
Domaine : (ES)Estimation
Base principale: BEST
Version: 1
Auteur: M. NAJI refonte de PsPlan_02 pour IFR17

Date de creation: 29/06/2018
Description du programme: generation des fichiers PLAN
 Sélection d'enregistrement dans TREQJOB
 Select des règle dans 
Parametres:
 @p_CRE_D UUPD_D
Conditions d'execution:
Commentaires:
[001] 21/01/2019 JYP  :Spira:74540 bugfix variable ComptaSocialEBSDone
[002] 28/02/2019 JYP  :Spira:74540 report de code : bugfix variable ComptaSocialEBSDone
[003] 29/03/2019 JYP  :Spira:075589 report de code : bugfix variable ComptaSocialEBSDone + Revue Roger
[004] 14/04/2020 M.NAJI :Spira 86064 suppression de la table BEST..TIfrs17ContextRequest
[005] 01/06/2020 M.NAJI :Spira 86220 add param_ComptaSocialLastDay:le dernier jour du postomegasocial, dernier jour inventaire postomega social positionné
[006] 08/12/2020 M.NAJI :Spira 87596 suppression des conditions non utilisées
[007] 29/03/2022 M.NAJI :Spira 96729 suppression de la condition ESPD3850
*/

-- Recherche des dates dans BREF..TCALEND
-----------------------------------------------------------------------------------------
declare @variante  tinyint,
  @erreur int,
  @p_BLCSHTYEA_NF smallint,
  @p_BLCSHTMTH_NF tinyint ,
  @p_SPCEND_D char(8) ,
  @p_ACCOUNT_D  char(8) ,
  @p_CLODAT_D char(8) ,
  @p_PERTYP_CT  char(1) ,
  @p_CLOTYP_CT  char(1) ,
  @p_CLOEXIST_CT bit ,
  @p_CONSOMTH smallint,  ---@P_BOOKING_D  char(8) ,
  @p_CONSOYEA int,  --- MOD018
  --#@p_CLODATMAX_D  Char(8),
  @p_DBCLO_D  Char(8),
 --[031] @nbinventaireOld  int,
  @Is31_12  char(1),
  @IsCOMPTA  char(1),
  @IsCLOSING char(1),  -- MOD19
  @IsSNEM char(1),
  --[031] @IsLife char(1),
  @nb_SNEM  int,
  @nb_Life  int,
  @nb_NoLife int,
  @nb_NoEBS  int,  -- [036]
  @CLODAT0  char(8),
  @IsTrim char(1),  -- JR 13/04/2005
  @IsEpo char(1),  -- JR 01/07/2005 traitement ecritures post omega demandé
  @IsEpo31_12 char(1),
  @IsEpoComptaRequestF  char(1),  -- [063]
  @ComptaSocialIFRSDone int, -- [036] Compta Sociale IFRS effectuée 0/1 = Non/Oui
  @ComptaSocialEBSDone  int, -- [036] Compta Sociale EBS effectuée 0/1 = Non/Oui
  @ComptaSocialLastDay  char(1), -- dernier jour inventaire postomega social positionné à N par défaut PP [046]
  --@IsReqcodEqualT int,  -- MDJ 08/02/2006 - MOD018 -- REQCOD_CT = T - 0/1 = Non/Oui
  @TypePOST char(6)
  
declare @site_cf  varchar(10)
declare @suser_Name varchar(20)
select @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output


--@variante
--@IsCOMPTA
--@Is31_12
--@nb_NoEBS
--@p_CLOTYP_CT
--@Istrim
--@IsSNEM
--@TypePOST
--@IsEpo
--@IsEpo31_12
--@IsEpoComptaRequestF
--@IsEpo31_12
--@ComptaSocialIFRSDone
--@ComptaSocialLastDay
--@ComptaSocialEBSDone
 

Select
	 @p_BLCSHTYEA_NF = A.blcshtyea_nf
	,@p_BLCSHTMTH_NF = A.blcshtmth_nf
	,@p_SPCEND_D = convert(char(8),A.specend_d,112)
	,@p_ACCOUNT_D =convert(char(8),A.account_d,112)  
--,@p_closing_b = A.closing_b
from BREF..TCALEND A
where ((A.blcshtyea_nf * 100) + A.blcshtmth_nf)=(select min((B.blcshtyea_nf * 100) + B.blcshtmth_nf)
											from BREF..TCALEND B where convert(Char(10),B.account_d,112) >= convert(Char(10),@p_CRE_D,112)) -- [003]

select @p_CLODAT_D = convert(char(6),@p_BLCSHTYEA_NF*100 + @p_BLCSHTMTH_NF) + '01'
select @p_CLODAT_D = convert(char(8),dateadd(dd,-1,dateadd(mm,1,@p_CLODAT_D)),112)

select @p_PERTYP_CT = "H"
select @p_DBCLO_D  = convert(char(8),@p_CRE_D,112)

if @p_DBCLO_D > @p_SPCEND_D
begin
	select @p_PERTYP_CT = "S"
	select @p_DBCLO_D = @p_SPCEND_D
end


Select @p_CONSOYEA = Max(BALSHEYEA_NF)      
FROM BEST..TREQJOB
WHERE REQCOD_CT   = 'B'
    and LAUNCH_D <= @p_CRE_D
    and SSD_CF    = 99
    and SITE_CF   = @site_cf

Select @p_CONSOMTH = Max(BALSHTMTH_NF)
FROM BEST..TREQJOB
WHERE REQCOD_CT      = 'B'
    and LAUNCH_D     <= @p_CRE_D
    and SSD_CF       = 99
    and BALSHEYEA_NF = @p_CONSOYEA
    and SITE_CF      = @site_cf
	

  
--#select
--#	@p_CLODATMAX_D = convert(char(8),max(CLODAT_D),112)
--#from BEST..TREQJOBPLAN
--#where CLODAT_D >= @p_CLODAT_D
--#and  BALSHTMTH_NF = @p_BLCSHTMTH_NF
--#and  LAUNCH_D is null
--#and  reqcod_ct in ('I','J','L','D','E','T','Y') -- [005] [102]
--#and  SITE_CF = @site_cf
--#--------------------------------------------------------------------
--#print '==> @p_CLODATMAX_D 1 = %1!', @p_CLODATMAX_D 
--#-------------------------------------------------------------------- 
--#
--#-- [006]
--#if @p_CLODATMAX_D = null
--#Begin
--#  select
--#  @p_CLODATMAX_D = convert(char(8),max(CLODAT_D),112)
--# from BEST..TREQJOB
--#  where CLODAT_D >= @p_CLODAT_D and LAUNCH_D is null and reqcod_ct in ('I','J','L', 'T','Y') -- Ajout Demande Type T [102]
--# and SITE_CF = @site_cf
--#END 
--#--------------------------------------------------------------------
--#print '==> @p_CLODATMAX_D 2 = %1!', @p_CLODATMAX_D
--#	--------------------------------------------------------------------

-- Variante 7: inventaire vie uniquement --------------------------------------------
/**********************************************************************************************
  LIBELLE INVENTAIRE :
  remplacer la premier jour du mois par le dernier jour du même mois pour
  obtenir le vrai libéllé d'inventaire principal
***********************************************************************************************/
select @CLODAT0 = convert(char(6),@p_BLCSHTYEA_NF*100 + @p_BLCSHTMTH_NF) + '01'
select @CLODAT0 = convert(char(8),dateadd(dd,-1,dateadd(mm,1,@CLODAT0)),112)

select @erreur = @@error
if @erreur != 0
begin
  raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification*/
  return @erreur
end

-- Nb Demandes type EBS planifiees
select @nb_NoEBS = count(*)
from BEST..TREQJOBPLAN r
WHERE r.LAUNCH_D = NULL
 and isnull(vrs_nf,0)=1
 and SITE_CF = @site_cf
 AND ((convert(char(8),r.CLODAT_D,112) >= @CLODAT0 and
  convert(char(8),r.DBCLO_D,112) <= @p_CRE_D and
  reqcod_ct in ('E','D'))
  or
  (BALSHEYEA_NF = @p_CONSOYEA and
  BALSHTMTH_NF = @p_CONSOMTH and
  convert(char(8),r.DBCLO_D,112) <= @p_CRE_D and
  reqcod_ct in ('T','F'))
 )

-- Demande de traitement post omega
select @IsEpo = "N"
If Exists ( SELECT 1 FROM BEST..TREQJOB
  WHERE REQCOD_CT in ('T')
 and SITE_CF = @site_cf
 and LAUNCH_D = Null )
Begin
  Select @IsEpo = "Y"
End

-- Demande de traitement plan Vie
select @nb_NoLife = count(*)
from BEST..TREQJOB r
WHERE r.LAUNCH_D = NULL
 AND convert(char(8),r.CLODAT_D,112) >= @CLODAT0
 and convert(char(8),r.DBCLO_D,112) <= @p_CRE_D
 and r.reqcod_ct in ('I','J')
 and SITE_CF = @site_cf

-- Demande de traitement plan Vie
select @nb_Life = count(*)
from BEST..TREQJOB r
WHERE r.LAUNCH_D = NULL
 and convert(char(8),r.CLODAT_D,112) >= @CLODAT0
 and r.reqcod_ct in ('L', 'A')
 and SITE_CF = @site_cf

-- Compta sociale IFRS passee
Select @ComptaSocialIFRSDone = 0
If Exists ( SELECT 1 FROM BEST..TREQJOB
  WHERE REQCOD_CT = 'F'
 and LAUNCH_D != Null
 and SITE_CF = @site_cf
 and isnull(VRS_Nf,0) = 0
 and BALSHEYEA_NF = @p_CONSOYEA
 and BALSHTMTH_NF = @p_CONSOMTH )
Begin
  Select @ComptaSocialIFRSDone = 1
End

-- Demande de Comptabilisation PostOmega/Conso
select @IsEpoComptaRequestF = "N"
select @IsEpoComptaRequestF = "Y"
from BEST..TREQJOB
where LAUNCH_D = NULL
 and REQCOD_CT = 'F'
 and DBCLO_D <= @p_CRE_D -- [063]
 and SITE_CF = @site_cf

-- Compta sociale EBS passee
Select @ComptaSocialEBSDone = 0 -- Non par défaut
If Exists ( SELECT 1 FROM BEST..TREQJOB
  WHERE REQCOD_CT = 'F'
 and LAUNCH_D != Null
 and isnull(VRS_Nf,0) = 1
 and SITE_CF = @site_cf
 and BALSHEYEA_NF = @p_CONSOYEA
 and BALSHTMTH_NF = @p_CONSOMTH )
  AND Exists ( SELECT 1 FROM BEST..TREQJOB, bref..tcalend 
  WHERE REQCOD_CT = 'F'
 and LAUNCH_D != Null
 and isnull(VRS_Nf,0) = 1
 and SITE_CF = @site_cf
 and BALSHEYEA_NF = @p_CONSOYEA
 and BALSHTMTH_NF = @p_CONSOMTH
 and BALSHEYEA_NF = BLCSHTYEA_NF
 and BALSHTMTH_NF = BLCSHTMTH_NF
 and @p_CRE_D > isnull(EBSPSTOMGEND_D,getdate()) )			  
Begin
  Select @ComptaSocialEBSDone = 1
End

declare @Demande char(1) , @Closing_B bit

-- indication que le mois bilan actuel est trimestriel (3,6,9,12)
select @Closing_B = 0
select @Closing_B = 1	
FROM BREF..TCALEND	
WHERE @p_ACCOUNT_D  = @p_CRE_D	
 AND @p_BLCSHTYEA_NF = BLCSHTYEA_NF	
 AND @p_BLCSHTMTH_NF = BLCSHTMTH_NF	
 AND CLOSING_B  = 1	

--#-- Demande Compta technique IFRS4
--#If Exists ( SELECT 1 FROM BEST..TREQJOBPLAN	
--# WHERE REQCOD_CT = 'C'	
--#  and LAUNCH_D is Null	
--#  and SITE_CF = @site_cf	
--#  and isnull(VRS_Nf,0) = 0	
--#  and BALSHEYEA_NF = @p_BLCSHTYEA_NF	
--#  and BALSHTMTH_NF = @p_BLCSHTMTH_NF
--#  and DBCLO_D = @p_CRE_D )	
--#  select @Demande = 'C'	
--#
--#-- Demande IFRS4
--#If Exists ( SELECT 1 FROM BEST..TREQJOBPLAN	
--# WHERE REQCOD_CT = 'D'	
--#  and LAUNCH_D is Null	
--#  and SITE_CF = @site_cf	
--#  and isnull(VRS_Nf,0) = 0	
--#  and BALSHEYEA_NF = @p_BLCSHTYEA_NF	
--#  and BALSHTMTH_NF = @p_BLCSHTMTH_NF
--#  and DBCLO_D <= @p_CRE_D )	
--#  select @Demande = 'D'	
--#
--#-- Demande post-omega
--#If Exists ( SELECT 1 FROM BEST..TREQJOBPLAN	
--# WHERE REQCOD_CT = 'T'	
--#  and LAUNCH_D is Null	
--#  and SITE_CF = @site_cf	
--#  and isnull(VRS_Nf,0) = 1	
--#  and BALSHEYEA_NF = @p_CONSOYEA	
--#  and BALSHTMTH_NF = @p_CONSOMTH
--#  and DBCLO_D <= @p_CRE_D )	
--#  select @Demande = 'T'	
--#
--#-- Demande Compta POS ou POC
--#If Exists ( SELECT 1 FROM BEST..TREQJOBPLAN	
--# WHERE REQCOD_CT = 'F'	
--#  and LAUNCH_D is Null	
--#  and SITE_CF = @site_cf	
--#  and isnull(VRS_Nf,0) = 1	
--#  and BALSHEYEA_NF = @p_CONSOYEA	
--#  and BALSHTMTH_NF = @p_CONSOMTH
--#  and DBCLO_D <= @p_CRE_D )	
--#  select @Demande = 'F'	
--#
--#-- Demande ES locales
--#Select @IsESLOC = 'N'
--#If Exists ( SELECT 1 FROM BEST..TREQJOBPLAN a, BREF..TCALEND
--#  WHERE REQCOD_CT = 'Y'
--# and LAUNCH_D = Null
--# and isnull(VRS_Nf,0) = 0
--# and SITE_CF = @site_cf
--# and @variante != 6 -- [075]
--# and datepart(yy,CLODAT_D) = @p_CONSOYEA -- [072] and BALSHEYEA_NF = @p_CONSOYEA 
--# and datepart(mm,CLODAT_D) = @p_CONSOMTH
--# and BALSHEYEA_NF = BLCSHTYEA_NF
--# and datepart(mm,CLODAT_D) = BLCSHTMTH_NF
--# and DBCLO_D <= @p_CRE_D
--# and DBCLO_D <= (select min(SPECEND_D) from BREF..TCALEND c 
--# where CLOSING_B = 1
--# and  ACCOUNT_D > a.DBCLO_D
--# and  ACCOUNT_D > (select max(DBCLO_D) from BEST..TREQJOB r
--#   where r.REQCOD_CT = 'B'
--#   and  a.DBCLO_D > r.DBCLO_D
--#   and  r.SITE_CF = @site_cf)
--# )
--# )
--#Begin
--#  Select @IsESLOC = 'Y'
--#  select @Demande = 'Y'	
--#End

-- [005] le dernier jour du postomegasocial, dernier jour inventaire postomega social positionné
Select @ComptaSocialLastDay = 'N' 
If Exists ( SELECT 1 FROM BEST..TREQJOB, bref..tcalend 
  WHERE REQCOD_CT = 'T'
 and LAUNCH_D = Null
 and SITE_CF = @site_cf
 and BALSHEYEA_NF = @p_CONSOYEA
 and BALSHTMTH_NF = @p_CONSOMTH
 and BALSHEYEA_NF = BLCSHTYEA_NF
 and BALSHTMTH_NF = BLCSHTMTH_NF
 and ( DBCLO_D = isnull(EBSPSTOMGEND_D,getdate()) or DBCLO_D = isnull(PSTOMGEND_D,getdate()) ) )
Begin
  Select @ComptaSocialLastDay = 'Y' -- dernier jour inventaire postomega social [046]
End


-- Type d'inventaire demande
--#declare @Request_id varchar(100)

--#select @Request_id= 
--#  case 
--#  when @nb_NoLife = 0 and @nb_Life > 0 then "PlanVie"	
--#  when @IsEpo='Y' and @ComptaSocialIFRSDone = 0 and @IsEpoComptaRequestF = 'N' then "POSI"	
--#  when @IsEpo='Y' and @ComptaSocialIFRSDone = 0 and @IsEpoComptaRequestF = 'Y' then "BookingPOSI"	
--#  when @IsEpo='Y' and @ComptaSocialIFRSDone = 0 and @IsEpoComptaRequestF = 'Y' and @IsEpo31_12 = 'Y' then "BookingPOSIAnnuel"
--#  when @IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @ComptaSocialEBSDone = 0 and @IsEpoComptaRequestF = 'N' and @nb_NoEBS > 0 then "POSE"
--#  when @IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @ComptaSocialEBSDone = 0 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS > 0 then "BookingPOSE"
--#  when @IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @ComptaSocialEBSDone = 0 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS > 0 and @IsEpo31_12 = 'Y' then "BookingPOSEAnnuel"
--#  when @IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @IsEpoComptaRequestF = 'N' and @nb_NoEBS = 0 then "POCI"
--#  when @IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS = 0 then "BookingPOCI"	
--#  when @IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS = 0 and @IsEpo31_12 = 'Y' then "BookingPOCIAnnuel"
--#  when @IsEpo='Y' and @ComptaSocialEBSDone = 1 and @IsEpoComptaRequestF = 'N' and @nb_NoEBS > 0 then "POCE"	
--#  when @IsEpo='Y' and @ComptaSocialEBSDone = 1 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS > 0 then "BookingPOCE"	
--#  when @IsEpo='Y' and @ComptaSocialEBSDone = 1 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS > 0 and @IsEpo31_12 = 'Y' then "BookingPOCEAnnuel"	
--#  when @nb_NoLife = 0 and @nb_Life > 0 And @Is31_12='Y' then "PlanVie_3112"
--#  --when	@Demande = 'D' or @Demande = 'X' then "IFRS_EBS"	--JYP not used
--#  when @Demande = 'C' and @Closing_B = 0 then "BookingTech"
--#  when @Demande = 'C' and @Closing_B = 1 then "BookingTechTrim"		
--#  when @Demande = 'C' and @Closing_B = 1 And @Is31_12='Y' then "BookingTechAnnuel"
--#  when @Demande = 'D' then "IFRS"
--#  when @Demande = 'D' And @p_CLOTYP_CT='P' then "IFRS_TRIM"	
--#  when @Demande = 'D' and (dateadd(dd, -15,@End_D) < @p_CRE_D and @p_CRE_D < dateadd(dd,1,@p_SPCENDT_D)) then "IFRS_Moins15End"	
--#  when @Demande = 'D' And @Is31_12='Y' then "IFRS_3112"	
--#  when @Demande = 'Y' then "Local"	
--#  else "noClosing"
--#  end 

-- Identification du contexte
--declare @Context_id varchar(100)

--select @Context_id = contextId from BEST..TIfrs17ContextRequest where requestId = @Request_id

--select * from BEST..TIfrs17ContextRequest where requestId = @Request_id

-- Type global d'Inventaire
--#declare @TYPEINV varchar(10), @NORME varchar(10)

--#select @TYPEINV = "INV" where @Request_id in ("IFRS","IFRS_TRIM","BookingTech","BookingTechTrim","noClosing")
--#select @TYPEINV = "POS" where @Request_id in ("POSI","BookingPOSI",	"BookingPOSIAnnuel","POSE","BookingPOSE","BookingPOSEAnnuel")
--#select @TYPEINV = "POC" where @Request_id in ("POCI","BookingPOCI","BookingPOCIAnnuel","POCE","BookingPOCE","BookingPOCEAnnuel")

-- Norme EBS ou IFRS
--#select @NORME = "EBS" where @Request_id in ("POSE","BookingPOSE","BookingPOSEAnnuel","BookingPOCE","BookingPOCEAnnuel","IFRS_EBS","POCE")
--#select @NORME = "IFRS" where @Request_id in ("IFRS","POSI","BookingPOSI",	"BookingPOSIAnnuel","POCI","BookingPOCI","BookingPOCIAnnuel","IFRS_3112","IFRS_EBS","BookingTechAnnuel","IFRS_Trim","IFRS_Moins15End","IFRS","BookingTech","BookingTechTrim")


--------------------------------------------------------------------
--#print '==> @suser_Name = %1!',@suser_Name
--#print '==> @site_cf = %1!',@site_cf
--#print '==> @Demande = %1!', @Demande
--#print '==> @Closing_B = %1!', @Closing_B
print '==> @nb_NoLife = %1!', @nb_NoLife
print '==> @nb_Life = %1!', @nb_Life
print '==> @IsEpo = %1!', @IsEpo
--#print '==> @IsESLOC= %1!', @IsESLOC
print '==> @ComptaSocialIFRSDone = %1!', @ComptaSocialIFRSDone
print '==> @ComptaSocialEBSDone = %1!', @ComptaSocialEBSDone
print '==> @IsEpoComptaRequestF = %1!', @IsEpoComptaRequestF
print '==> @nb_NoEBS = %1!', @nb_NoEBS
--#print '==> @Request_id = %1!', @Request_id
--print '==> @Context_id = %1!', @Context_id
--#print '==> @TYPEINV = %1!', @TYPEINV
--#print '==> @NORME = %1!', @NORME
--------------------------------------------------------------------


-- SELECT * FROM BEST..TIfrs17Chain 
-- SELECT * from BEST..TIfrs17Plan




select "export param_suser_Name=" + @suser_Name 

UNION
select "export param_site_cf=" + @site_cf 

UNION 
-- Current period

SELECT  top 1
  'export CUR_CLODAT=' + min( convert(varchar, a.BLCSHTYEA_NF) + substring(convert(varchar, a.BLCSHTMTH_NF+100),2,2) )
from BREF..TCALEND a
where a.ACCOUNT_D >= @p_CRE_D
 and a.CLOSING_B = 1
UNION 

-- Previous period

SELECT  top 1
  'export PREV_CLODAT=' + max( convert(varchar, a.BLCSHTYEA_NF) + substring(convert(varchar, a.BLCSHTMTH_NF+100),2,2) )
from BREF..TCALEND a
where a.ACCOUNT_D < @p_CRE_D
 and a.CLOSING_B = 1
UNION
select "export param_Demande=" + @Demande 
UNION
select "export param_Closing_B=" + convert(varchar,@Closing_B)
UNION
select "export param_nb_NoLife=" + convert(varchar,@nb_NoLife)
UNION
select "export param_nb_Life=" + convert(varchar,@nb_Life)
UNION
select "export param_IsEpo=" + @IsEpo
UNION
select "export param_ComptaSocialIFRSDone=" + convert(varchar,@ComptaSocialIFRSDone) 
UNION
select "export param_ComptaSocialEBSDone=" + convert(varchar,@ComptaSocialEBSDone )
UNION
select "export param_IsEpoComptaRequestF=" + @IsEpoComptaRequestF 
UNION
select "export param_nb_NoEBS=" + convert(varchar,@nb_NoEBS) 
--#UNION
--#select "export param_Request_id=" + @Request_id
UNION
--select "export param_Context_id=" + @Context_id
--UNION
--#select "export TYPEINV=" + @TYPEINV
--#UNION
--#select "export NORME=" + @NORME
--#UNION
select "export param_ComptaSocialLastDay=" + @ComptaSocialLastDay --[005] 



----------------------------------------------------------------------------------


-- AJOUT Jr 02/06/2006  spot 12860 indication si comptabilisation trimestrielle  MOD19
select @IsCLOSING = 'N'
select @IsCLOSING = 'Y'
FROM BREF..TCALEND
WHERE @p_ACCOUNT_D  = @p_CRE_D
 AND @p_BLCSHTYEA_NF = BLCSHTYEA_NF
 AND @p_BLCSHTMTH_NF = BLCSHTMTH_NF
 AND CLOSING_B  = 1

 
 
 declare @COMPTA_MENS   BIT
 
 select @COMPTA_MENS = 0

 select @COMPTA_MENS = 1
from BREF..TCALEND
where @p_CRE_D = ACCOUNT_D
  and CLOSING_B = 0

 Select @p_CLOEXIST_CT = 0
 if exists (  Select Distinct SSD_CF  From BTRAV..TESTSSD ) 
	if @COMPTA_MENS != 1 Select @p_CLOEXIST_CT = 1

-- Aucun inventaire n'est demandé ---------------------------------------
if @p_CLOEXIST_CT = 0
  --- La date de lancement est différente de la date de comptabilisation ------------------
  if @p_ACCOUNT_D != @p_CRE_D
	if @p_PERTYP_CT = 'H'  ------- Hors service --------------------------------------
		select @variante = 1
	else
	begin
	  if @p_ACCOUNT_D > @p_CRE_D
		select @variante = 2
	end
  else
	-- AJOUT Jr 02/06/2006  spot 12860  MOD19
	if @IsCLOSING = 'Y' -- jour comptabilisation mois inventaire
		select @variante = 2
	else
		-- Fin AJOUT Jr 02/06/2006  spot 12860  MOD19
		select @variante = 5
else
	------- Hors service -------------------------------------------
	if @p_PERTYP_CT = 'H'
		select @variante = 3
	else
		--- La date de lancement et inférieur à la date de comptabilisation ---------------
		if @p_ACCOUNT_D > @p_CRE_D
			select @variante = 4
		else
			select @variante = 6


if @variante = 5
	begin
	 If Exists ( SELECT 1 FROM BEST..TREQJOBPLAN
				 WHERE REQCOD_CT = 'C'
				  and LAUNCH_D != Null
				  and SITE_CF = @site_cf
				  and isnull(VRS_Nf,0) = 0
				  and BALSHEYEA_NF = @p_BLCSHTYEA_NF
				  and BALSHTMTH_NF = @p_BLCSHTMTH_NF 
				)
		Select @variante = 1 -- La Comptabilisation technique a déjà été faite dans la journée, on l'annule pour ne pas la refaire le soir
	End 
 
IF @nb_NoLife = 0 and @nb_Life > 0
	BEGIN
	  select @variante = 7
	END

--------------------------------------------------------------------
print '==> @variante = %1!', @variante




-- top à 'Y' la variable Is31_12 si la pariode de l'inventaire est égal à 12 -------------------
if datepart(mm,@p_CLODAT_D) = 12
  select @Is31_12 = "Y"

-- top à 'Y' la variable @IsCOMPTA si c'est un jour de comptabilisation et CLOSING_B = 1 on est à J --------------------------------------------------
select @IsCOMPTA = 'Y'
FROM BREF..TCALEND
WHERE @p_ACCOUNT_D  = @p_CRE_D
 AND @p_BLCSHTYEA_NF = BLCSHTYEA_NF
 AND @p_BLCSHTMTH_NF = BLCSHTMTH_NF
 AND CLOSING_B  = 1
 
 
 -- top à 'Y' @IsSNEM si l'inventaire est SNEM --------------------------------------------
select @IsSNEM = "N"
select @nb_SNEM = count(*)
from BTRAV..TESTSSD s, BEST..TREQJOB r
where s.SSD_CF = r.SSD_CF
 AND convert( char(8),r.CLODAT_D,112) = @p_CLODAT_D
 and r.LAUNCH_D = NULL
 and r.REQCOD_CT = 'J'
 and SITE_CF = @site_cf

IF @nb_SNEM > 0
BEGIN
  select @IsSNEM = 'Y'
END

if datepart(mm,@p_CLODAT_D) in (03, 06, 09, 12)
    select @Istrim = "Y"

select @TypePOST=""
if ( @IsEpo = "Y")
begin
  if (@nb_NoEBS = 0 )
    if (@ComptaSocialIFRSDone = 1 )
      select @TypePOST = "CONSO "
    else
      select @TypePOST = "SOCIAL"
  else
    if (@ComptaSocialEBSDone = 1 )
      select @TypePOST = "CONSO "
    else
      select @TypePOST = "SOCIAL"
end

if @p_CONSOMTH = 12 -- MOD011 - Conditionné uniquement
    select @IsEpo31_12 = "Y"
    
    


Select  @p_CLOTYP_CT = 'A'
If Exists ( 
    select 1
    from    BEST..TREQJOB r
    where  convert(char(8),r.CLODAT_D,112) =    @p_CLODAT_D
    and      r.LAUNCH_D = NULL
    and      r.reqcod_ct in ('I','J','L', 'T','Y')                                      
    and    SITE_CF = @site_cf
)      
    select @p_CLOTYP_CT = 'P'


print '#--> @p_CLODAT_D = %1!', @p_CLODAT_D
print '#--> @variante 	= %1!', @variante
print '#--> @Istrim 	= %1!', @Istrim
print '#--> @IsCOMPTA 	= %1!', @IsCOMPTA
print '#--> @Is31_12 	= %1!', @Is31_12
print '#--> @nb_NoEBS 	= %1!', @nb_NoEBS
print '#--> @p_CLOTYP_CT = %1!', @p_CLOTYP_CT
print '#--> @IsSNEM 	= %1!', @IsSNEM
print '#--> @TypePOST 	= %1!', @TypePOST
print '#--> @p_SPCEND_D = %1!', @p_SPCEND_D
print '#--> @IsEpo 		= %1!', @IsEpo
print '#--> @IsEpoComptaRequestF = %1!', @IsEpoComptaRequestF
print '#--> @ComptaSocialIFRSDone= %1!', @ComptaSocialIFRSDone
print '#--> @ComptaSocialEBSDone = %1!', @ComptaSocialEBSDone
print '#--> @p_CLOEXIST_CT = %1!', @p_CLOEXIST_CT
print '#--> @COMPTA_MENS = %1!', @COMPTA_MENS
print '#--> @IsCLOSING = %1!', @IsCLOSING
print '#--> @p_ACCOUNT_D = %1!', @p_ACCOUNT_D
print '#--> @p_PERTYP_CT = %1!', @p_PERTYP_CT

 

--- Top des conditions COND -----------------------------------------------------
-- grep EST_.*_COND[0-9] *.cmd | grep -v ':#if' | grep -v ':echo' | grep -v ':ECHO_LOG' | grep -v ':#' |  cut -d'{' -f2,3,4 --output-delimiter='~' | sed s'/\}/~/g' | awk -F'~' '{print $1"\n"$2"\n"$3"\n"$4"\n"$5"\n"$6"\n"$7"\n"$8"\n"$9"\n"$10}' | grep 'EST_' | sort -u


      select case when  @variante = 4														then 'export EST_ESID0560_COND1="Y"' else 'export EST_ESID0560_COND1="N"' end 
UNION select case when  @variante = 4                                                  		then 'export EST_ESID1520_COND1="Y"' else 'export EST_ESID1520_COND1="N"' end 
UNION select case when  @variante = 4                                                  		then 'export EST_ESID1550_COND1="Y"' else 'export EST_ESID1550_COND1="N"' end 
UNION select case when  @variante = 4                                                  		then 'export EST_ESID1800_COND1="Y"' else 'export EST_ESID1800_COND1="N"' end 
UNION select case when  @variante = 4                                                  		then 'export EST_ESID3800_COND2="Y"' else 'export EST_ESID3800_COND2="N"' end 
UNION select case when  @variante = 4                                                  		then 'export EST_ESID3900_COND2="Y"' else 'export EST_ESID3900_COND2="N"' end 
UNION select case when  @variante = 5                                                  		then 'export EST_ESID3800_COND3="Y"' else 'export EST_ESID3800_COND3="N"' end 
UNION select case when  @variante = 6 and @IsCOMPTA = "Y" and  @Is31_12 = "Y"          		then 'export EST_STAD7500_COND1="Y"' else 'export EST_STAD7500_COND1="N"' end 
--UNION select case when  @variante = 3 and @p_CLOTYP_CT = "P" and @Istrim = "Y"         		then 'export EST_ESID2500_COND1="Y"' else 'export EST_ESID2500_COND1="N"' end 
--UNION select case when  @variante = 3 and @p_CLOTYP_CT = "P" and @Istrim = "Y"         		then 'export EST_ESID8000_COND2="Y"' else 'export EST_ESID8000_COND2="N"' end 
--- @Istrim est toujour égal à Y dans le PLAN1 utilisé par ESID2500, ESID8000 et STAD1500
UNION select case when  @variante = 3 and @p_CLOTYP_CT = "P"          						then 'export EST_ESID2500_COND1="Y"' else 'export EST_ESID2500_COND1="N"' end 
UNION select case when  @variante = 3 and @p_CLOTYP_CT = "P"          						then 'export EST_ESID8000_COND2="Y"' else 'export EST_ESID8000_COND2="N"' end 
UNION select case when  @variante = 3 and (@Is31_12 = "Y" or @nb_NoEBS > 0)            		then 'export EST_ESID8000_COND1="Y"' else 'export EST_ESID8000_COND1="N"' end 
UNION select case when  @variante = 4 or @IsSNEM = "Y"                                 		then 'export EST_ESID2060_COND1="Y"' else 'export EST_ESID2060_COND1="N"' end 
UNION select case when  @variante = 4 or @IsSNEM = "Y"                                 		then 'export EST_ESID2560_COND1="Y"' else 'export EST_ESID2560_COND1="N"' end 
UNION select case when  @variante in(4,6)                                              		then 'export EST_ESID0060_COND1="Y"' else 'export EST_ESID0060_COND1="N"' end 
UNION select case when  @variante in(4,6)                                              		then 'export EST_ESID0080_COND1="Y"' else 'export EST_ESID0080_COND1="N"' end 
UNION select case when  @variante in(3,4) and @Is31_12 = "Y"                           		then 'export EST_ESID2800_COND1="Y"' else 'export EST_ESID2800_COND1="N"' end 
UNION select case when  @variante in(3,4) and @Is31_12= "Y"                            		then 'export EST_ESID3800_COND1="Y"' else 'export EST_ESID3800_COND1="N"' end 
UNION select case when  @TypePOST = "SOCIAL"                                           		then 'export EST_ESPD3700_COND1="Y"' else 'export EST_ESPD3700_COND1="N"' end 
--UNION select case when  @TypePOST = "SOCIAL" and @nb_NoEBS = 0                         		then 'export EST_ESPD3850_COND1="Y"' else 'export EST_ESPD3850_COND1="N"' end 
UNION select case when  @IsCOMPTA = "Y"                                                		then 'export EST_ESID7000_COND1="Y"' else 'export EST_ESID7000_COND1="N"' end 
UNION select case when  @IsCOMPTA = "Y"                                                		then 'export EST_ESID7050_COND1="Y"' else 'export EST_ESID7050_COND1="N"' end 
UNION select case when  @Is31_12 = "Y"                                                 		then 'export EST_ESID8060_COND1="Y"' else 'export EST_ESID8060_COND1="N"' end 
UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESID2000_COND1="Y"' else 'export EST_ESID2000_COND1="N"' end 
UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESID2010_COND1="Y"' else 'export EST_ESID2010_COND1="N"' end 
UNION select case when  @Is31_12 = "Y" or @nb_NoEBS > 0                                		then 'export EST_ESID2500_COND2="Y"' else 'export EST_ESID2500_COND2="N"' end 
UNION select case when  @IsEpo = "Y"  and @IsEpo31_12 = "Y" and @IsEpoComptaRequestF =	"Y" then 'export EST_ESLD8830_COND1="Y"' else 'export EST_ESLD8830_COND1="N"' end 
UNION select case when  @IsEpo31_12 = "Y"  and @IsEpoComptaRequestF = "Y"              		then 'export EST_ESPD8830_COND1="Y"' else 'export EST_ESPD8830_COND1="N"' end 
UNION select case when  @ComptaSocialLastDay = "N"                                     		then 'export EST_ESPD2550_COND3="Y"' else 'export EST_ESPD2550_COND3="N"' end 
UNION select case when  @Is31_12="Y"                                                   		then 'export EST_ESID7000_COND2="Y"' else 'export EST_ESID7000_COND2="N"' end 
UNION select case when  @variante in(6)     		                                  		then 'export EST_ESID7000_COND3="Y"' else 'export EST_ESID7000_COND3="N"' end 
UNION select case when  @Is31_12="Y"                                                   		then 'export EST_ESID7050_COND2="Y"' else 'export EST_ESID7050_COND2="N"' end 
UNION select case when  @variante in(5,6)           	                            		then 'export EST_ESID0060_COND3="Y"' else 'export EST_ESID0060_COND3="N"' end 
UNION select case when  @variante in(5,6)               	                        		then 'export EST_ESID0080_COND3="Y"' else 'export EST_ESID0080_COND3="N"' end  

UNION select case when  @variante = 6 					                      				then 'export EST_STAD1500_COND1="Y"' else 'export EST_STAD1500_COND1="N"' end 
UNION select case when  @variante = 6 and @Is31_12 = 'Y'                      				then 'export EST_STAD1500_COND2="Y"' else 'export EST_STAD1500_COND2="N"' end 
UNION select case when  @variante in(3,4, 6,7) 					                     		then 'export EST_STAD1500_COND3="Y"' else 'export EST_STAD1500_COND3="N"' end 
UNION select  'export EST_VARIANTE=' +  convert(varchar,@variante) 


--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESPD8830_COND2="Y"' else 'export EST_ESPD8830_COND2="N"' end 
--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESPD2500_COND2="Y"' else 'export EST_ESPD2500_COND2="N"' end 
--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESPD2550_COND2="Y"' else 'export EST_ESPD2550_COND2="N"' end 
--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESPD2900_COND2="Y"' else 'export EST_ESPD2900_COND2="N"' end 
--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESPD3800_COND2="Y"' else 'export EST_ESPD3800_COND2="N"' end 
--UNION select case when  @TypePOST = "SOCIAL"                                           		then 'export EST_ESPD2000_COND1="Y"' else 'export EST_ESPD2000_COND1="N"' end 
--UNION select case when  @TypePOST = "SOCIAL"                                           		then 'export EST_ESPD3800_COND1="Y"' else 'export EST_ESPD3800_COND1="N"' end 
--UNION select case when  @IsEpo = "Y" and @IsEpoComptaRequestF = "Y" and @nb_NoEBS = 0  		then 'export EST_ESPD3860_COND1="Y"' else 'export EST_ESPD3860_COND1="N"' end 
--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESID0060_COND4="Y"' else 'export EST_ESID0060_COND4="N"' end  
--UNION select case when  @ComptaSocialIFRSDone = 1                                      		then 'export EST_ESPD3800_COND3="Y"' else 'export EST_ESPD3800_COND3="N"' end  
--UNION select case when  @IsEpoComptaRequestF = "Y"                                     		then 'export EST_ESPD3800_COND4="Y"' else 'export EST_ESPD3800_COND4="N"' end 
--UNION select case when  @ComptaSocialEBSDone = 1                                       		then 'export EST_ESPD3800_COND5="Y"' else 'export EST_ESPD3800_COND5="N"' end  
--UNION select case when  @IsEpo31_12 = "Y"                                              		then 'export EST_ESPD2000_COND3="Y"' else 'export EST_ESPD2000_COND3="N"' end 
--UNION select case when  @variante in(3,4)                      								then 'export EST_STAD1550_COND1="Y"' else 'export EST_STAD1550_COND1="N"' end 
--UNION select case when   @nb_NoEBS > 0                        								then 'export EST_ESPD3900_COND2="Y"' else 'export EST_ESPD3900_COND2="N"' end 
--UNION select case when  @variante = 3 and @nb_NoEBS > 0                                		then 'export EST_ESID3800_COND4="Y"' else 'export EST_ESID3800_COND4="N"' end 
--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESPD0060_COND2="Y"' else 'export EST_ESPD0060_COND2="N"' end 
--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESPD1800_COND2="Y"' else 'export EST_ESPD1800_COND2="N"' end 
--UNION select case when  @TypePOST = "SOCIAL"                                           		then 'export EST_ESPD0060_COND1="Y"' else 'export EST_ESPD0060_COND1="N"' end 
--UNION select case when  @TypePOST = "SOCIAL"                                           		then 'export EST_ESPD1800_COND1="Y"' else 'export EST_ESPD1800_COND1="N"' end 
--UNION select case when  @TypePOST = "SOCIAL"                                           		then 'export EST_ESPD2500_COND1="Y"' else 'export EST_ESPD2500_COND1="N"' end 
--UNION select case when  @TypePOST = "SOCIAL"                                           		then 'export EST_ESPD2550_COND1="Y"' else 'export EST_ESPD2550_COND1="N"' end 
--UNION select case when  @TypePOST = "CONSO"                                           		then 'export EST_DWPD0010_COND1="Y"' else 'export EST_DWPD0010_COND1="N"' end 
--UNION select case when  @TypePOST = "CONSO"                                           		then 'export EST_ESPD3850_COND2="Y"' else 'export EST_ESPD3850_COND2="N"' end 
--UNION select case when  @TypePOST = "CONSO"                                           		then 'export EST_ESPD8100_COND2="Y"' else 'export EST_ESPD8100_COND2="N"' end 
--UNION select case when  @TypePOST = "SOCIAL"                                           		then 'export EST_ESPD8600_COND1="Y"' else 'export EST_ESPD8600_COND1="N"' end 
--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESID3600_COND1="Y"' else 'export EST_ESID3600_COND1="N"' end 
--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESPD8100_COND1="Y"' else 'export EST_ESPD8100_COND1="N"' end 
--UNION select case when  @nb_NoEBS > 0 and @ComptaSocialIFRSDone = 1                    		then 'export EST_ESPD0060_COND3="Y"' else 'export EST_ESPD0060_COND3="N"' end 


--UNION select case when  @variante = 4                                                  		then 'export EST_ESID2050_COND1="Y"' else 'export EST_ESID2050_COND1="N"' end 
--UNION select case when  @variante = 4                                                  		then 'export EST_ESID2550_COND1="Y"' else 'export EST_ESID2550_COND1="N"' end 
--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESPD2000_COND2="Y"' else 'export EST_ESPD2000_COND2="N"' end 
--UNION select case when  @TypePOST = "SOCIAL"                                           		then 'export EST_ESPD3900_COND1="Y"' else 'export EST_ESPD3900_COND1="N"' end 
--UNION select case when  @nb_NoEBS > 0                                                  		then 'export EST_ESPD3900_COND2="Y"' else 'export EST_ESPD3900_COND2="N"' end 





----------------------------------------------------------------------------------

if @erreur != 0
begin
  raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
  return @erreur
end

return 0
go
EXEC sp_procxmode 'dbo.PsIfrs17Cond_01', 'unchained'
go
IF OBJECT_ID('dbo.PsIfrs17Cond_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PsIfrs17Cond_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PsIfrs17Cond_01 >>>'
go
GRANT EXECUTE ON dbo.PsIfrs17Cond_01 TO GDBBATCH
go


-- chaines qui utilisent le PLAN1 
-- DWED0010
-- DWUJ0070
-- DWUJ0170
-- DWUJ1480
-- DWUJ9070
-- DWUJ9170
-- ESFD2000
-- ESFD2010
-- ESFD2040
-- ESID0560
-- ESID1020
-- ESID1520
-- ESID1530
-- ESID1550
-- ESID1800
-- ESID2000
-- ESID2010
-- ESID2020
-- ESID2040
-- ESID2050
-- ESID2060
-- ESID2080
-- ESID2090
-- ESID2100
-- ESID2140
-- ESID2500
-- ESID2530
-- ESID2550
-- ESID2560
-- ESID2590
-- ESID2600
-- ESID2660
-- ESID2800
-- ESID2900
-- ESID3600
-- ESID3700
-- ESID3800
-- ESID3810
-- ESID3850
-- ESID3860
-- ESID3900
-- ESID4000
-- ESID4010
-- ESID8000
-- ESID8040
-- ESID8050
-- ESID8530
-- ESID8600
-- ESID8700
-- ESID8800
-- ESID8900
-- ESOD2000
-- ESRD0000
-- ESRD0010
-- ESRD2530
-- STAD1200
-- STAD1220
-- STAD1280
-- STAD1500
-- STAD1530
-- STAD1540
-- STAD1550
