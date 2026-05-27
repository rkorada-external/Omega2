USE BEST
go
IF OBJECT_ID('dbo.PsIfrs17Perm_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsIfrs17Perm_01
    IF OBJECT_ID('dbo.PsIfrs17Perm_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsIfrs17Perm_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsIfrs17Perm_01 >>>'
END
go
/*
 * creation de la procedure */
create procedure PsIfrs17Perm_01  (
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
    @p_IsPlan       varchar(64) ,          --[029]
    @p_ContextId    varchar(32) ,
    @p_version       smallint        
)
/*
 BEST..PsIfrs17Perm_01  
    @p_CRE_D   ='20180630',
    @p_CLONUM   =    2,
    @p_BLCSHTYEA_NF =2018,
    @p_BLCSHTMTH_NF =12 ,
    @p_SPCEND_D     ='20180630' ,
    @p_ACCOUNT_D    ='20180630' ,
    @p_CLODAT_D     ='20180630' ,
    @p_PERTYP_CT =   'P' ,
    @p_CLOTYP_CT   = 'P' ,
    @p_CLOEXIST_CT  =0 ,
    @p_CONSOMTH     =12,    
    @p_CONSOYEA    = 2018,  
    @p_SSDACC_LL   = "_1_2_",
    @p_IsPlan     =  "YES"   ,   
    @p_ContextId     =  "POSE" ,
    @p_version = 1
*/
with execute as caller as
/***************************************************
Programme: PsIfrs17Perm_01
Fichier script associé : BEST_PsIfrs17Plan_02.prc
Domaine : (ES)Estimation
Base principale: BEST
Version: 1
Auteur: M. NAJI 
Date de creation: 29/06/2018
Description du programme: generation des fichiers PERM
      Sélection d'enregistrement dans TREQJOB
Parametres:
      @p_CRE_D      UUPD_D
Conditions d'execution:
Commentaires:
****************************************************/
declare @variante           tinyint,
        @erreur             int,
        @Is31_12            char(1),
        @IsP31_12           char(1),
        @Title              varchar(90),
        @IsCOMPTA           char(1),
        @IsCLOSING          char(1),
        @IsSNEM             char(1),
        @nb_SNEM            int,
        @nb_Life            int,
        @nb_NoLife          int,
        @nb_NoEBS           int,  
        @CLODAT0            char(8),
        @Is30_06            char(1),
        @IsTrim             char(1),
        @IsEpo              char(1),
        @IsESLOC            char(1),
        @IsEpo31_12         char(1),
        @IsEpoComptaRequestF   char(1), 
        @ComptaSocialIFRSDone  int,    
        @ComptaSocialEBSDone   int,    
        @ComptaSocialLastDay   char(1),
        @IsPlan             int,                 
        @TypePOST      char(6),
        @TotalPOST      varchar(16),  
        @End_D            char(8),        
        @p_SPCENDT_D      char(8),   
        @p_BLCSHTMTHT_NF  int       
        
declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output


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


select @IsEpo =  'Y' , @nb_NoEBS = 1 
declare @Request_id  varchar(30) 

if (@IsEpo =  'Y' and @nb_NoEBS > 0    ) -- ===> EBS
    select @Request_id= "PostOmegaEBS"

select @IsEpo =  'Y' , @nb_NoEBS = 1 



SELECT  "export "  +  p.fileVariable + "=" + PATTERN
FROM  BEST..TIfrs17Perm p  
Where version = @p_version
and 	p.ContextId = @p_ContextId
and  p.chain ='*'

union all

SELECT 'if [ "${NCHAIN}" = "' + chain + '" ] ; then  ' + 'export '  +  p.fileVariable + '=' + PATTERN  + '  ;fi;'
FROM  BEST..TIfrs17Perm p  
Where version = @p_version
and 	p.ContextId = @p_ContextId
and  p.chain !='*'

if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end


return 0
go
EXEC sp_procxmode 'dbo.PsIfrs17Perm_01', 'unchained'
go
IF OBJECT_ID('dbo.PsIfrs17Perm_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsIfrs17Perm_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsIfrs17Perm_01 >>>'
go
GRANT EXECUTE ON dbo.PsIfrs17Perm_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsIfrs17Perm_01 TO GDBBATCH
go
