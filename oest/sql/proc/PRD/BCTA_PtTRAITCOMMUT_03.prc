USE BCTA
go

IF OBJECT_ID('dbo.PtTRAITCOMMUT_03') IS NOT NULL
BEGIN
   DROP PROCEDURE dbo.PtTRAITCOMMUT_03
   IF OBJECT_ID('dbo.PtTRAITCOMMUT_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtTRAITCOMMUT_03 >>>'
   ELSE
        PRINT '<<< DROPPED PROC dbo.PtTRAITCOMMUT_03 >>>'
END
go

-- création de la procédure

create procedure PtTRAITCOMMUT_03
(
  @uworg_cf  smallint           --[004] vdv le 19/07/07
)
as

/***************************************************
Programme              : PtTRAITCOMMUT_03
Fichier script associé : BCTA_PtTRAITCOMMUT_03.PRC
Base principale        : BCTA

Version: 1

Auteur: JF VDV
Date de creation:  03/10/2006
Description du programme:

cette proc fait appel au traitement TP des procédures PuDCTR_01 & PuDCTR_02
    Modification de l'état et du type comptable d'un contrat
    contrôle des éléments financiers non lettrés


Parametres :
Conditions d'execution:
Commentaires:
Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif 001       |             |
 van de velde   | 06/03/2007  | prise en compte des tables btrt & bfac TRFCROSSREF pour la sélection des contrats  commutés.
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif 002       |             |
 van de velde   | 13/03/2007  | prise en compte du n°d'ordre et de l'avenant pour la constitution du curseur
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif 003       |             |
 van de velde   | 23/04/2007  | Afin d'éviter les listes de synthèse, utilisation de l'option "trigger off"
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif [004]     |             |
van de velde    | 19/07/2007  | prise en compte du paramètre UWORG_CF
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif [005]     |             |
G. BUISSON      | 28/11/2008  | Spot 16534 : Ajout d'un Order By sur le Declare Cursor
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
**********************/

--select @debug = 'D'

set flushmessage on

-- Déclaration du curseur
-- Sélection de tous les contrats/exercices des bases oméga TRAITES & FACULTATIVES
-- pour lesquels les contrats sont commutés.

DECLARE
@err          varchar(64),
@err_b        int,
@win          varchar(60),
@dw           varchar(60),
@numligne     smallint,
@erreurligne  int,
@tst          varchar(21),
@ret          varchar(64),
@lstupdusr_cf uupdusr_cf,
@lstupd_d     uupd_d,
@ctr_nf       uctr_nf,
@uwy_nf       int,
@esb_cf       int,
@ssd_cf       int,
@code_ret     INT,
@cmt_nt_1     ucmt_nt,
@uw_nt        uuw_nt,
@end_nt       uend_nt

CREATE TABLE #majctr
(
tctr_nf     UCTR_NF   	NOT NULL ,
tuwy_nf     UUWY_NF   	NOT NULL ,
tuw_nt      UUW_NT    	NOT NULL ,
tend_nt     UEND_NT   	NOT NULL ,
tsec_nf     USEC_NF   	NOT NULL ,
tcur_cf     UCUR_CF   	NOT NULL ,
toccyea_nf  int		      NOT NULL ,
ttrncod_cf  udettrs_cf	NOT NULL ,
tmax        int       	NOT NULL ,
tsum	      uamt_m	    DEFAULT 0 NOT NULL
)

CREATE TABLE #ctrlcum
(
tctr_nf    UCTR_NF    NOT NULL ,
tuwy_nf    UUWY_NF    NOT NULL ,
tuw_nt     UUW_NT     NOT NULL ,
tend_nt    UEND_NT    NOT NULL ,
tsec_nf    USEC_NF    NOT NULL ,
tcur_cf    UCUR_CF    NOT NULL ,
toccyea_nf int        NOT NULL ,
ttrncod_cf UDETTRS_CF NOT NULL ,
toricuramt_m UAMT_M   NOT NULL
)

create table #erreur
(
win       varchar(60) NULL,
dw        varchar(60) NULL,
numligne  smallint,
erreur    varchar(64) NULL,
tst       varchar(21) NULL,
ret       varchar(64) NULL,
updusr    uupdusr_cf  NULL,
upddate   uupd_d      NULL,
proctype  char(1)
)

create table #ctr
(
ctr_nf  uctr_nf,
uwy_nf  int,
uw_nt   uuw_nt,        -- modif 002
end_nt  uend_nt        -- modif 002
)

create table #cr
(
ctr_nf  uctr_nf,
uwy_nf  int,
uw_nt   uuw_nt,        -- modif 002
end_nt  uend_nt        -- modif 002
)

set arithabort numeric_truncation off

-- Alimentation de la table temporaire #ctr pour lecture du curseur
-- sélection des contrat/exercice/n° d'ordre commutés

-- *******************************  modif 001
-- INSERT into #ctR
-- SELECT ctr_nf, uwy_nf
-- FROM btrav..CNC_CNCD2000_COMMUTCTRUWY


PRINT ' '
PRINT 'TRAITES - récupération contrat/exercice commutés'
insert into #Ctr
select distinct tcontr.ctr_nf, tcontr.uwy_nf, tcontr.uw_nt, tcontr.end_nt     -- modif 002
FROM btrt..TRFCROSSREF crossref,
     btrt..TCONTR tcontr
WHERE   tcontr.ctr_nf     = crossref.ctr_nf
-- AND     crossref.uworg_cf = 65    -- origine portefeuille commutation St PAUL Travellers
AND     crossref.uworg_cf = @uworg_cf    -- origine du portefeuille en commutation   [004] vdv le 19/07/07
AND     tcontr.ssd_cf     = crossref.ssd_cf


PRINT ' '
PRINT 'FACULTATIVES - récupération contrat/exercice commutés'
insert into #Ctr
select distinct tcontr.ctr_nf, tcontr.uwy_nf, tcontr.uw_nt, tcontr.end_nt      -- modif 002
FROM bfac..TRFCROSSREF crossref,
     bfac..TCONTR tcontr
WHERE   tcontr.ctr_nf     = crossref.ctr_nf
-- AND     crossref.uworg_cf = 65    -- origine portefeuille commutation St PAUL Travellers
AND     crossref.uworg_cf = @uworg_cf    -- origine du portefeuille en commutation   [004] vdv le 19/07/07
AND     tcontr.ssd_cf     = crossref.ssd_cf

DECLARE curs_ctr CURSOR FOR
SELECT DISTINCT ctr.ctr_nf, ctr.uwy_nf, tcontr.ssd_cf, tcontr.accesb_cf,
                ctr.uw_nt,        -- modif 002
                ctr.end_nt        -- modif 002
FROM	  #cTr ctr, btrt..TCONTR tcontr
WHERE  tcontr.ctr_nf = ctr.ctr_nf
and	  tcontr.uwy_nf = ctr.uwy_nf
UNION
SELECT DISTINCT ctr.ctr_nf, ctr.uwy_nf, tcontr.ssd_cf, tcontr.accesb_cf,
                ctr.uw_nt,        -- modif 002
                ctr.end_nt        -- modif 002
FROM	  #Ctr ctr, bfac..TCONTR tcontr
WHERE  tcontr.ctr_nf = ctr.ctr_nf
and	  tcontr.uwy_nf = ctr.uwy_nf
Order By ctr.ctr_nf, ctr.uwy_nf, tcontr.ssd_cf, tcontr.accesb_cf,ctr.uw_nt,ctr.end_nt

SET triggers off                        -- modif 003
If @@error != 0 SELECT syb_quit()

OPEN curs_ctr
PRINT '** Lecture initiale **'

FETCH  curs_ctr
INTO	 @ctr_nf, @uwy_nf, @ssd_cf , @esb_cf, @uw_nt, @end_nt

WHILE (@@sqlstatus = 0)
BEGIN
	delete #erreur
	delete #majctr
	delete #ctrlcum
--  select '@ctr_nf = ', @ctr_nf ,'  @uwy_nf = ',@uwy_nf, '@uw_nt =', @uw_nt,'@end_nt = ',@end_nt

	begin tran
	execute 	@code_ret = BCTA..PuDCTR_01
				    @p_ctr_nf = @ctr_nf,
				    @p_sec_nf = 1,
				    @p_uwy_nf = @uwy_nf,
				    @p_uw_nt  = @uw_nt,   --1,    -- modif 002
				    @p_end_nt = @end_nt,  --0,    -- modif 002
				    @p_ssd_cf = @ssd_cf,
				    @p_esb_cf = @esb_cf,

				    @p_all_sec = 1,
				    @p_all_exe = 0,
				    @p_ctraccsts_ct = 9,   -- terminé
				    @p_ctraccsts2_ct = 1,  -- racheté/commuté
				    @p_accadmtyp_ct = NULL,
            @p_mono_sec_exe = 0,

            @p_v_secsts_ct	= 12, --Int,		-- 001 : ajout GF CPT11722 29/09/2005
	          @p_v_ctrsts_ct	= 12, --iNt,		-- 001 : ajout GF CPT11722
	          @p_v_grp_cf			= 0, --inT,	  -- 001 : ajout GF CPT11722

				    @p_erreur = @err output ,
				    @debug = 'N'

if @code_ret = 1
	begin
	 	rollback tran
	 	insert into #cr select @ctr_nf, @uwy_nf, @uw_nt, @end_nt
	 	select '**ERREUR**','@ctr_nf = ', @ctr_nf ,'@uwy_nf = ',@uwy_nf, '@uw_nt =', @uw_nt,'@end_nt = ',@end_nt

	end
	else
	begin
	--rollback tran
	commit tran
	--select '***commit tran ***'
	end
    --select '#majctr', * from #majctr
    --select '#ctrlcum',* from #ctrlcum
    --PRINT '*** lecture suivante ***'
	FETCH  curs_ctr
	INTO	 @ctr_nf, @uwy_nf, @ssd_cf, @esb_cf, @uw_nt, @end_nt
END

--DROP TABLE #erreur
--DROP TABLE #majctr
--DROP TABLE #ctrlcum

SET triggers on                        -- modif 003
If @@error != 0 SELECT syb_quit()

print ''
print ''
print 'compte-rendu des erreurs :'
print '--------------------------'

select * from #cr order by ctr_nf , uwy_nf

select 'Nombre de contrats FACs + TRAITES en entrée : ' , count(distinct ctr_nf)
from  #ctr

select 'Nombre de contrats TRAITES mis en terminés : ' , count(distinct tcontr.ctr_nf)
from #ctr ctr,
	   btrt..TCONTR tcontr
where tcontr.ctr_nf        = ctr.ctr_nf
and   tcontr.uwy_nf        = ctr.uwy_nf
and   tcontr.ctraccsts_ct  = 9
and   tcontr.ctraccsts2_ct = 1

select 	'Nombre de contrats FACs mis en terminés : ' , count(distinct tcontr.ctr_nf)
from  #ctr ctr,
      bfac..TCONTR tcontr
where tcontr.ctr_nf        = ctr.ctr_nf
and   tcontr.uwy_nf        = ctr.uwy_nf
and   tcontr.ctraccsts_ct  = 9
and   tcontr.ctraccsts2_ct = 1

fin:
go

----------------------------------------------
-- fin de la procédure
---------------------------------------------

-- Granting/Revoking Permissions on dbo.PtTRAITCOMMUT_03
GRANT EXECUTE ON dbo.PtTRAITCOMMUT_03 TO GOMEGA
go

IF OBJECT_ID('dbo.PtTRAITCOMMUT_03') IS NOT NULL
   PRINT '<<< CREATED PROCEDURE dbo.PtTRAITCOMMUT_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtTRAITCOMMUT_03 >>>'
go

EXEC sp_procxmode 'dbo.PtTRAITCOMMUT_03','unchained'
