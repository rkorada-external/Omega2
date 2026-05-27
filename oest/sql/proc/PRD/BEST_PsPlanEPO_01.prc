USE BEST
go
IF OBJECT_ID('dbo.PsPlanEPO_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsPlanEPO_01
    IF OBJECT_ID('dbo.PsPlanEPO_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsPlanEPO_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsPlanEPO_01 >>>'
END
go
/*
 * creation de la procedure */
create procedure PsPlanEPO_01  (
    @p_CRE_D        char(8),
    @p_CLONUM       tinyint,
    @p_BLCSHTYEA_NF smallint,
    @p_BLCSHTMTH_NF tinyint ,
    @p_SPCEND_D     char(8) ,
    @p_ACCOUNT_D    char(8) ,
    @p_CLODAT_D     char(8) ,
    @p_PERTYP_CT    char(1) ,
    @p_CLOTYP_CT    char(1) ,
    @p_CLOEXIST_CT  bit ,
    @p_CONSOMTH     smallint,           ---@P_BOOKING_D    char(8) ,
    @p_CONSOYEA     int,                --- MOD018
    @p_SSDACC_LL    varchar(64),
    @p_IsPlan       varchar(64)         --[029]
)
/*
 BEST..PsPlanEPO_01  
    @p_CRE_D   ='20180823',
    @p_CLONUM   =    0,
    @p_BLCSHTYEA_NF =2018,
    @p_BLCSHTMTH_NF =6 ,
    @p_SPCEND_D     ='20180813' ,
    @p_ACCOUNT_D    ='20180611' ,
    @p_CLODAT_D     ='20180831' ,
    @p_PERTYP_CT =   'P' ,
    @p_CLOTYP_CT   = 'P' ,
    @p_CLOEXIST_CT  =0 ,
    @p_CONSOMTH     =6,           ---@P_BOOKING_D    char(8) ,
    @p_CONSOYEA    = 2018,                --- MOD018
    @p_SSDACC_LL   = "_1_2_3_4_5_6_7_12_15_16_17_18_19_23_",
    @p_IsPlan     =  "YES"         --[029]

*/
with execute as caller as
/***************************************************
Programme: PsPlanEPO_01
Fichier script associé : BEST_PsPlanEPO_01.prc
Domaine : (ES)Estimation
Base principale: BEST
Version: 1
Auteur: M. NAJI refonte de PsPlan_02 pour IFR17

Date de creation: 29/06/2018
Description du programme: generation des fichiers PLAN
      Sélection d'enregistrement dans TREQJOB
      Select des règle dans 
Parametres:
      @p_CRE_D      UUPD_D
Conditions d'execution:
Commentaires:
[001] 21/01/2019 JYP    :Spira:74540 bugfix variable ComptaSocialEBSDone
[002] 28/02/2019 JYP    :Spira:74540 report de code : bugfix variable ComptaSocialEBSDone
[003] 29/03/2019 JYP    :Spira:075589 report de code : bugfix variable ComptaSocialEBSDone

*/

-- Recherche des dates dans BREF..TCALEND
-----------------------------------------------------------------------------------------
declare @variante           tinyint,
        @erreur             int,
        --[031] @nbinventaireOld    int,
        @Is31_12            char(1),
        @IsP31_12           char(1),
        @Title              varchar(90),
        @IsCOMPTA           char(1),
        @IsCLOSING          char(1),            -- MOD19
        @IsSNEM             char(1),
        --[031] @IsLife     char(1),
        @nb_SNEM            int,
        @nb_Life            int,
        @nb_NoLife          int,
        @nb_NoEBS           int,                -- [036]
        @CLODAT0            char(8),
        @Is30_06            char(1),
        @IsTrim             char(1),            -- JR 13/04/2005
        @IsEpo              char(1),            -- JR 01/07/2005 traitement ecritures post omega demandé
        @IsESLOC            char(1),            -- [068]
        @IsEpo31_12         char(1),
        @IsEpoComptaRequestF   char(1),    -- [063]
        @ComptaSocialIFRSDone  int,     -- [036] Compta Sociale IFRS effectuée 0/1 = Non/Oui
        @ComptaSocialEBSDone   int,     -- [036] Compta Sociale EBS effectuée 0/1 = Non/Oui
        @ComptaSocialLastDay   char(1), -- dernier jour inventaire postomega social positionné à N par défaut PP [046]
        --@IsReqcodEqualT     int,        -- MDJ 08/02/2006 - MOD018 -- REQCOD_CT = T  - 0/1 = Non/Oui
        @IsPlan             int,                 --[029]
        -- PHP0907
      --@IsPOsocialEBS      char(1),    --[036]
      --  @IsPOconsoEBS       char(1)     --[036]
        @TypePOST      char(6),
        @TotalPOST      varchar(16),       -- [068]
        @End_D            char(8),                --[065] ESID8040 tourne selon une planification
        @p_SPCENDT_D      char(8),                --[069]
        @p_BLCSHTMTHT_NF  int                 --[069]
        
declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output



-- Variante 7: inventaire vie uniquement --------------------------------------------
/**********************************************************************************************
    LIBELLE INVENTAIRE :
    remplacer la premier jour du mois par le dernier jour du même mois pour
    obtenir le vrai libéllé d'inventaire principal
***********************************************************************************************/
select @CLODAT0 = convert(char(6),@p_BLCSHTYEA_NF*100 +  @p_BLCSHTMTH_NF) + '01'
select @CLODAT0 = convert(char(8),dateadd(dd,-1,dateadd(mm,1,@CLODAT0)),112)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification*/
    return @erreur
end

select @nb_NoEBS = count(*)
from BEST..TREQJOBPLAN r
WHERE r.LAUNCH_D = NULL
  and isnull(vrs_nf,0)=1
  and SITE_CF = @site_cf
  AND ((convert(char(8),r.CLODAT_D,112) >= @CLODAT0 and
        convert(char(8),r.DBCLO_D,112) <= @p_CRE_D  and
        reqcod_ct in ('E','D'))
       or
       (BALSHEYEA_NF = @p_CONSOYEA and
        BALSHTMTH_NF = @p_CONSOMTH and
        convert(char(8),r.DBCLO_D,112) <= @p_CRE_D and
        reqcod_ct in ('T','F'))
      )

-- top à 'Y' @IsEpo si demande traitement ecritures post omega  ------------MOD10 jr 01/07/2005
select @IsEpo = "N"         -- Non Par Défaut
If Exists ( SELECT 1 FROM BEST..TREQJOB
            WHERE REQCOD_CT in ('T')
              and SITE_CF = @site_cf
              and LAUNCH_D = Null )
Begin
    Select @IsEpo = "Y"     -- Demande Post-omega T active
End



select @nb_NoLife = count(*)
from BEST..TREQJOB r
WHERE r.LAUNCH_D = NULL
  AND convert(char(8),r.CLODAT_D,112) >= @CLODAT0
  and convert(char(8),r.DBCLO_D,112) <= @p_CRE_D
  and r.reqcod_ct in ('I','J')
  and SITE_CF = @site_cf



select @nb_Life = count(*)
from BEST..TREQJOB r
WHERE r.LAUNCH_D = NULL
  and convert(char(8),r.CLODAT_D,112) >= @CLODAT0
  and r.reqcod_ct in ('L', 'A')
  and SITE_CF = @site_cf


Select @ComptaSocialIFRSDone = 0         -- Non par défaut
If Exists ( SELECT 1 FROM BEST..TREQJOB
            WHERE REQCOD_CT = 'F'
              and LAUNCH_D != Null
              and SITE_CF = @site_cf
              and isnull(VRS_Nf,0) = 0
              and BALSHEYEA_NF = @p_CONSOYEA
              and BALSHTMTH_NF = @p_CONSOMTH )
Begin
    Select @ComptaSocialIFRSDone = 1     -- La Comptabilisation Sociale IFRS est Passée pour la Période
End


-- Di Demande de Comptabilisation PostOmega/Conso
select @IsEpoComptaRequestF = "N"
select @IsEpoComptaRequestF = "Y"
from BEST..TREQJOB
where LAUNCH_D = NULL
  and REQCOD_CT = 'F'
  and DBCLO_D <= @p_CRE_D  -- [063]
  and SITE_CF = @site_cf

-- [001]
Select @ComptaSocialEBSDone = 0         -- Non par défaut
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
    Select @ComptaSocialEBSDone = 1     -- La Comptabilisation Sociale EBS est Passée pour la Période
End



declare @Demande char(1) , @Closing_B bit

select @Closing_B = 1	
FROM BREF..TCALEND	
WHERE @p_ACCOUNT_D    = @p_CRE_D	
  AND @p_BLCSHTYEA_NF = BLCSHTYEA_NF	
  AND @p_BLCSHTMTH_NF = BLCSHTMTH_NF	
  AND CLOSING_B       = 1	



If Exists ( SELECT 1 FROM BEST..TREQJOBPLAN	
              WHERE REQCOD_CT = 'C'	
                and LAUNCH_D is Null	
                and SITE_CF = @site_cf	
                and isnull(VRS_Nf,0) = 0	
                and BALSHEYEA_NF = @p_BLCSHTYEA_NF	
                and BALSHTMTH_NF = @p_BLCSHTMTH_NF )	
    select @Demande = 'C'	
	
If Exists ( SELECT 1 FROM BEST..TREQJOBPLAN	
              WHERE REQCOD_CT = 'D'	
                and LAUNCH_D is Null	
                and SITE_CF = @site_cf	
                and isnull(VRS_Nf,0) = 0	
                and BALSHEYEA_NF = @p_BLCSHTYEA_NF	
                and BALSHTMTH_NF = @p_BLCSHTMTH_NF )	
    select @Demande = 'D'	

/*SELECT * FROM BEST..TREQJOBPLAN	 
              WHERE REQCOD_CT = 'D'	
                and LAUNCH_D is Null	
                and SITE_CF = "SGP1"
                and isnull(VRS_Nf,0) = 0	
                and BALSHEYEA_NF = 2018
                and BALSHTMTH_NF =6
 */               
declare @Request_id varchar(100)


select @Request_id=  
    case 
        when @nb_NoLife = 0  and @nb_Life > 0 then  "PlanVie"	
        when @IsEpo='Y' and @ComptaSocialIFRSDone = 0 and @IsEpoComptaRequestF = 'N' then  "POSI"	
        when @IsEpo='Y' and @ComptaSocialIFRSDone = 0 and @IsEpoComptaRequestF = 'Y'then  "BookingPOSI"	
        when @IsEpo='Y' and @ComptaSocialIFRSDone = 0 and @IsEpoComptaRequestF = 'Y' and @IsEpo31_12 = 'Y' then "BookingPOSIAnnuel"
        when @IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @ComptaSocialEBSDone =  0 and @IsEpoComptaRequestF = 'N' and @nb_NoEBS > 0 then "POSE"
        when @IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @ComptaSocialEBSDone =  0 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS > 0 then "BookingPOSE"
        when	@IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @ComptaSocialEBSDone = 0 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS > 0 and @IsEpo31_12 = 'Y' then "BookingPOSEAnnuel"
        when @IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @IsEpoComptaRequestF = 'N' and @nb_NoEBS = 0 then  "POCI"
        when @IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS = 0 then  "BookingPOCI"	
        when	@IsEpo='Y' and @ComptaSocialIFRSDone = 1 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS = 0 and @IsEpo31_12 = 'Y' then "BookingPOCIAnnuel"
        when @IsEpo='Y' and @ComptaSocialEBSDone  = 1 and @IsEpoComptaRequestF = 'N' and @nb_NoEBS > 0 then  "POCE"	
        when @IsEpo='Y' and @ComptaSocialEBSDone  = 1 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS > 0 then  "BookingPOCE"	
        when	@IsEpo='Y' and @ComptaSocialEBSDone = 1 and @IsEpoComptaRequestF = 'Y' and @nb_NoEBS > 0 and @IsEpo31_12 = 'Y' then "BookingPOCEAnnuel"	
        when @IsESLOC = 'Y'  then  "Local"	
        when	@nb_NoLife = 0  and @nb_Life > 0 And @Is31_12='Y' then "PlanVie_3112"
        when	@Demande = 'D' And @Is31_12='Y'  then "IFRS_3112"	
        --when	@Demande = 'D' or @Demande = 'X' then "IFRS_EBS"	--JYP not used
        when	@Demande = 'C' and @Closing_B = 1 And @Is31_12='Y' then "BookingTechAnnuel"
        when	@Demande = 'D' And @p_CLOTYP_CT='P' then "IFRS_TRIM"	
        when	@Demande = 'D' and (dateadd(dd, -15,@End_D) < @p_CRE_D and @p_CRE_D < dateadd(dd,1,@p_SPCENDT_D)) then "IFRS_Moins15End"	
        when @Demande = 'D' then  "IFRS"
        when @Demande = 'C' and @Closing_B = 0 then "BookingTech"
        when @Demande = 'C' and @Closing_B = 1 then "BookingTechTrim"		
        else "noClosing"
    end 

--declare @Context_id varchar(100)
--select @Context_id = contextId from BEST..TIfrs17ContextRequest where requestId = @Request_id

--select * from BEST..TIfrs17ContextRequest where requestId = @Request_id


declare @TYPEINV varchar(10)  , @NORME varchar(10)
select @TYPEINV = "INV" where @Request_id in ("IFRS","IFRS_TRIM","BookingTech","BookingTechTrim","noClosing")
select @TYPEINV = "POS" where @Request_id in ("POSI","BookingPOSI",	"BookingPOSIAnnuel","POSE","BookingPOSE","BookingPOSEAnnuel")
select @TYPEINV = "POC" where @Request_id in ("POCI","BookingPOCI","BookingPOCIAnnuel","POCE","BookingPOCE","BookingPOCEAnnuel")

select @NORME = "EBS" where @Request_id in ("POSE","BookingPOSE","BookingPOSEAnnuel","BookingPOCE","BookingPOCEAnnuel","IFRS_EBS","POCE")
select @NORME = "IFRS" where @Request_id in ("IFRS","POSI","BookingPOSI",	"BookingPOSIAnnuel","POCI","BookingPOCI","BookingPOCIAnnuel","IFRS_3112","IFRS_EBS","BookingTechAnnuel","IFRS_Trim","IFRS_Moins15End","IFRS","BookingTech","BookingTechTrim")

      

--------------------------------------------------------------------
print '==> @suser_Name = %1!',@suser_Name
print '==> @site_cf = %1!',@site_cf
print '==> @Demande = %1!', @Demande
print '==> @Closing_B = %1!', @Closing_B
print '==> @nb_NoLife = %1!', @nb_NoLife
print '==> @nb_Life = %1!', @nb_Life
print '==> @IsEpo = %1!', @IsEpo
print '==> @ComptaSocialIFRSDone = %1!', @ComptaSocialIFRSDone
print '==> @ComptaSocialEBSDone = %1!', @ComptaSocialEBSDone
print '==> @IsEpoComptaRequestF = %1!', @IsEpoComptaRequestF
print '==> @nb_NoEBS = %1!', @nb_NoEBS
print '==> @Request_id = %1!', @Request_id
--print '==> @Context_id = %1!', @Context_id
print '==> @TYPEINV = %1!', @TYPEINV
print '==> @NORME = %1!', @NORME
--------------------------------------------------------------------


-- SELECT  * FROM BEST..TIfrs17Chain 
-- SELECT  *  from BEST..TIfrs17Plan

--SELECT 
--    case 
--        when  p.requestId = 'IFRS'  then 'export EST_' + c.chain + '_GONOGO="Y"'
--        when  p.requestId = 'IFRS_TRIM'  then 'export EST_' + c.chain + '_GONOGO="Y"'
--        when  p.requestId = 'POSI'  then 'export EST_' + c.chain + '_GONOGO="Y"'
--        when  p.requestId = 'POSE'  then 'export EST_' + c.chain + '_GONOGO="Y"'
--        when  p.requestId = 'BookingPOSI'  then 'export EST_' + c.chain + '_GONOGO="Y"'
--        when  p.requestId = 'BookingPOSIAnnuel'  then 'export EST_' + c.chain + '_GONOGO="Y"'
--        when  p.requestId = 'POCE'  then 'export EST_' + c.chain + '_GONOGO="Y"'
--        when  p.requestId = 'BookingPOSE'  then 'export EST_' + c.chain + '_GONOGO="Y"'
--        when  p.requestId = 'BookingPOCEAnnuel'  then 'export EST_' + c.chain + '_GONOGO="Y"'
--        else 'export EST_' + c.chain + '_GONOGO="N"'
--    end 
--FROM BEST..TIfrs17Chain c 
--JOIN BEST..TIfrs17Plan p on p.chain = c.chain  
--and	p.planId = "PLAN" + convert(varchar,@p_CLONUM) 
--and p.requestId = @Request_id


SELECT
    case
        when REQCOD_CT = 'IFRS'  then 'export EST_' + chain_ct + '_GONOGO="Y"'
       when  REQCOD_CT = 'IFRS_TRIM'  then 'export EST_' + chain_ct + '_GONOGO="Y"'
        when  REQCOD_CT = 'POSI'  then 'export EST_' + chain_ct + '_GONOGO="Y"'
        when  REQCOD_CT = 'POSE'  then 'export EST_' + chain_ct + '_GONOGO="Y"'
        when REQCOD_CT = 'BookingPOSI'  then 'export EST_' + chain_ct + '_GONOGO="Y"'
       when  REQCOD_CT = 'BookingPOSIAnnuel'  then 'export EST_' + chain_ct + '_GONOGO="Y"'
        when  REQCOD_CT = 'POCE'  then 'export EST_' + chain_ct + '_GONOGO="Y"'
        when  REQCOD_CT = 'BookingPOSE'  then 'export EST_' + chain_ct + '_GONOGO="Y"'
        when  REQCOD_CT = 'BookingPOCEAnnuel'  then 'export EST_' + chain_ct + '_GONOGO="Y"'
        else 'export EST_' + chain_ct + '_GONOGO="N"'
    end
/*FROM BEST..TIfrs17Chain c
JOIN BEST..TIfrs17Plan p on p.chain = c.chain_ct
and     p.planId = "PLAN" + convert(varchar,@p_CLONUM)
and p.requestId = @Request_id
*/
from BEST..TI17REQCHN r
where reqcod_ct = @Request_id


UNION
select  "export  param_suser_Name=" + @suser_Name 

UNION
select  "export  param_site_cf=" + @site_cf 

UNION 
-- Current period

SELECT   top 1
    'export CUR_CLODAT=' + min( convert(varchar, a.BLCSHTYEA_NF) + substring(convert(varchar, a.BLCSHTMTH_NF+100),2,2) )
from BREF..TCALEND a
where a.ACCOUNT_D >= @p_CRE_D
  and a.CLOSING_B = 1
UNION 

-- Previous  period

SELECT   top 1
    'export PREV_CLODAT=' + max( convert(varchar, a.BLCSHTYEA_NF) + substring(convert(varchar, a.BLCSHTMTH_NF+100),2,2) )
from BREF..TCALEND a
where a.ACCOUNT_D < @p_CRE_D
  and a.CLOSING_B = 1
UNION
select  "export  param_Demande=" + @Demande 
UNION
select  "export  param_Closing_B=" + convert(varchar,@Closing_B)
UNION
select  "export  param_nb_NoLife=" + convert(varchar,@nb_NoLife)
UNION
select  "export  param_nb_Life=" + convert(varchar,@nb_Life)
UNION
select  "export  param_IsEpo=" + @IsEpo
UNION
select  "export  param_ComptaSocialIFRSDone=" + convert(varchar,@ComptaSocialIFRSDone)  
UNION
select  "export  param_ComptaSocialEBSDone=" + convert(varchar,@ComptaSocialEBSDone )
UNION
select  "export  param_IsEpoComptaRequestF=" +  @IsEpoComptaRequestF 
UNION
select  "export  param_nb_NoEBS=" + convert(varchar,@nb_NoEBS)
UNION
select  "export  param_Request_id=" + @Request_id
UNION
--select  "export  param_Context_id=" + @Context_id
--UNION
select  "export  TYPEINV=" + @TYPEINV
UNION
select  "export  NORME=" + @NORME



if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end

return 0
go
EXEC sp_procxmode 'dbo.PsPlanEPO_01', 'unchained'
go
IF OBJECT_ID('dbo.PsPlanEPO_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsPlanEPO_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsPlanEPO_01 >>>'
go
GRANT EXECUTE ON dbo.PsPlanEPO_01 TO GDBBATCH
go
