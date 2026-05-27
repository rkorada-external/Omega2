use BEST
go


/* * DROP PROC dbo.PsREQJOB_02
*/
IF OBJECT_ID('dbo.PsREQJOB_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsREQJOB_02
   PRINT '<<< DROPPED PROC dbo.PsREQJOB_02 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsREQJOB_02
     (
      @p_cre_d      char(8),
      @p_CLODAT 		char(8)  OUTPUT,
      @p_SPCEND     char(10) OUTPUT,
      @p_annee      smallint OUTPUT,
      @p_mois       tinyint output
     )
as

/***************************************************
Programme: PsREQJOB_02
Fichier script associé : ESSREQ02.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME65 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
      Sélection d'enregistrement dans TREQJOB

Parametres:
      @p_cre_d  UUPD_D,
    	@p_CLODAT char(8)  OUTPUT,
    	@p_SPCEND char(8) OUTPUT,
    	@p_annee  smallint OUTPUT,
    	@p_mois   tinyint
    
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
_________________
MODIFICATION    [002]
Auteur:         D.GATIBELZA
Date:           27/05/2008
Version:        8.1
Description:    EDI15180
Modifications:

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare @erreur int
declare @CLODAT0 char(8)

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

/* Recherche de l'année et de la période du libellé d'inventaire principal.
   On affecte provisoirement 1 aujour pour avoir un format date
*/
select @CLODAT0=min( convert(char(6),BLCSHTYEA_NF*100 +  BLCSHTMTH_NF) + '01'  )
 from  bcta..TBLCSHTD b, BREF..TBATCHSSD c
where b.str_d<= @p_cre_d and @p_cre_d <= b.spcend_d and b.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_Name()

select @erreur = @@error
if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end


/* Recherche de la date de fin de période exeptionnelle */
select
	@p_SPCEND = convert( char(8),min(SPCEND_D),112)
from  bcta..TBLCSHTD b, BREF..TBATCHSSD c
where b.str_d<= @p_cre_d and @p_cre_d <= b.spcend_d and b.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_Name()
and 	@CLODAT0=convert(char(6),BLCSHTYEA_NF*100 +  BLCSHTMTH_NF) + '01'

select @erreur = @@error
if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end

/* remplacer la premier jour du mois par le dernier jour du même mois pour
   obtenir le vrai libéllé d'inventaire principatl
*/
select @p_CLODAT = convert(char(8),dateadd(dd,-1,dateadd(mm,1,@CLODAT0)),112)


select @erreur = @@error
if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end


/* deconcaténation du libéllé d'inventaire principal en année et période */
select @p_annee = convert(smallint,substring(@p_CLODAT,1,4)),
	 @p_mois  = convert(tinyint,substring(@p_CLODAT,5,2) )

select @erreur = @@error
if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end


/* insertion dans la table de travail BTRAV..TESTSSD les filiales qui ont
   damandé des inventaires
*/
delete BTRAV..TESTSSD

insert into BTRAV..TESTSSD(SSD_CF)
select distinct ssd_cf
from BEST..TREQJOB
where CLODAT_D >= @p_CLODAT and LAUNCH_D is null and reqcod_ct = 'I'
and SITE_CF= @site_cf
group by SSD_CF
order by SSD_CF


select @erreur = @@error
if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end

UPDATE BTRAV..TESTSSD
SET    VRS_NF=(SELECT VRS_NF
               FROM   BEST..TVERPAR VERPAR
               HAVING VERPAR.SSD_CF=ESTSSD.SSD_CF and SEGTYP_CT='A' and PAR_D=MAX(PAR_D))
FROM BTRAV..TESTSSD ESTSSD

select @erreur = @@error
if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end


/* sélection des inventaires et fililale de TREQJOB */
select
	SSD_CF   ,
--   	BALSHEYEA_NF ,
--	BALSHTMTH_NF ,
	convert(char(8),CLODAT_D,112) CLODAT_D,
--	REQCOD_CT,
	convert(char(8),CRE_D,112)	CRE_D,
   	convert(char(8),DBCLO_D,112) DBCLO_D
--   	convert(char(8),LAUNCH_D,112) LAUNCH_D
--   	CLOPER_LS,
--   	VRS_NF,
--   	UPDUSR_CF,
--   	JOBRES_CT
from TREQJOB
where CLODAT_D >= @p_CLODAT and LAUNCH_D is null and reqcod_ct = 'I'
and SITE_CF = @site_cf
order by CLODAT_D , ssd_cf

select @erreur = @@error

if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end

return 0
go

/*
 * fin de la procedure
 */

IF OBJECT_ID('dbo.PsREQJOB_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsREQJOB_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsREQJOB_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsREQJOB_02
 */
GRANT EXECUTE ON dbo.PsREQJOB_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsREQJOB_02 TO GDBBATCH
go

