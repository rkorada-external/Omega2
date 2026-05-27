use BCTA
go

IF OBJECT_ID('dbo.PtCLMCOMMUT_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtCLMCOMMUT_01
    IF OBJECT_ID('dbo.PtCLMCOMMUT_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtCLMCOMMUT_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtCLMCOMMUT_01 >>>'
END
go

-- creation de la procedure

create procedure PtCLMCOMMUT_01
(
  @blcsht_d  char(8),
  @acy_nf    smallint,
  @p_DEBUG int = NULL -- (1 pour test debug)
)
as

/***************************************************

Programme: PtCLMCOMMUT_01


Fichier script associe : BCTA_PtCLMCOMMUT_01.prc

Base principale : BCTA

Version: 1

Auteur: JFVDE
Date de creation: 04/03/2005
Description du programme:

        Commutation des traités
        Contrepassation technique des sinistres emetteurs transferes.
        Reconduction du dernier SP et generation de SAP a zero.

Parametres:
Conditions d'execution:
Commentaires:

Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif 001       |             |
van de velde    | 06/03/2007  | pise en compte des tables btrt & bfac TRFCROSSREF pour la sélection des contrats commutés
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------

    13/03/2008  J. Ribot   SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
    28/11/2008  G. Buisson Spot 16534 : Ajout d'un Order By sur le Declare Cursor
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
 van de velde   | 16/11/2009  | [18401] Mettre les noms de colonne dans les INSERT de BCTA..TCLMAMT
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
 van de velde   | 20/05/2010  | [19484] Pour la commutation de RELIANCE (prendre UWORF_CF = 95 )
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
 van de velde   | 11/03/2011  | [21641] Pour la commutation d' AXA (prendre UWORF_CF = 211 )
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------

******************************************************************************/
PRINT ' ******* BCTA_PtCLMCOMMUT_01.prc *****'
IF @p_DEBUG = 1
BEGIN
PRINT '@@@@@@@@@@@@                              @@@@@@@@@'
PRINT '@@@@@@@@@@@@  C O M M U T A T I O N       @@@@@@@@@'
PRINT '@@@@@@@@@@@@                              @@@@@@@@@'
PRINT ' '
END

if object_id('#TCONTR') is not null	drop table #TCONTR

if object_id('#TCLMAMT') is not null drop table #TCLMAMT

if object_id('#SAP_TCLMAMT') is not null drop table #SAP_TCLMAMT


declare @p_blcsht_d  datetime,
        @p_date_acy  datetime,
        @p_acy_nf    smallint,
        @p_top_comut bit,
        @cpt_edit int

-- si le top commutation = 1, le traitement est déjà passé; pas de traitement

select @p_top_comut= (select distinct top_comut from BTRAV..CNC_CNCD2000_COMMUTCTRUWY)
if @p_top_comut= 1
    begin
    print '***** le traitement pour la commutation est déjà passé *****'
    print '****** A vérifier ******************************************'
    goto FIN
    end
--

select  @p_blcsht_d = @blcsht_d
select  @p_acy_nf   = @acy_nf
select '@p_blcsht_d = ', @p_blcsht_d
select '@p_acy_nf   = ', @p_acy_nf


select @p_date_acy = convert (datetime, convert(char(8), ( (@p_acy_nf * 10000) +
                                        (datepart(mm, @p_blcsht_d) * 100) +
                                         01 ) ) )

select '@p_date_acy = ', @p_date_acy

create table #TCONTR
            (
            ctr_nf      char(9),
            uwy_nf      smallint
            )

CREATE TABLE #TCLMAMT
            (
    		CLM_NF       UCLM_NF              NOT NULL,
    		POS_NT       UPOS_NT              NOT NULL,
    		POSTYP_CT    UCLMPOSTYP_CT        NOT NULL,
    		AMTTYP_NT    UCLMAMTTYP_NT        NOT NULL,
   		    SSD_CF       USSD_CF              NOT NULL,
    		REB_NF       UREB_NF                  NULL,
    		AMTLOS_M     UAMT_M                   NULL,
    		AMTEXP_M     UAMT_M                   NULL,
    		AMTINT_M     UAMT_M                   NULL,
    		AMTREC_M     UAMT_M                   NULL,
    		AMTRPC_M     UAMT_M                   NULL,
    		AMTTOT_M     UAMT_M                   NULL,
    		AMTSYSGEN_B  bit                  DEFAULT  0,
    		POSACC_D     datetime                 NULL,
    		SCOSTRMTH_NF UPERTYP_CF               NULL,
    		SCOENDMTH_NF UPERTYP_CF               NULL,
    		ACY_NF       UACCYER_NF               NULL
            )
CREATE TABLE #SAP_TCLMAMT
            (
    		CLM_NF       UCLM_NF              NOT NULL,
    		POS_NT       UPOS_NT              NOT NULL,
    		POSTYP_CT    UCLMPOSTYP_CT        NOT NULL,
    		AMTTYP_NT    UCLMAMTTYP_NT        NOT NULL,
   		    SSD_CF       USSD_CF              NOT NULL,
    	--	REB_NF       UREB_NF                  NULL,
    		AMTLOS_M     UAMT_M                   NULL,
    		AMTEXP_M     UAMT_M                   NULL,
    		AMTINT_M     UAMT_M                   NULL,
    		AMTREC_M     UAMT_M                   NULL,
    		AMTRPC_M     UAMT_M                   NULL,
    		AMTTOT_M     UAMT_M                   NULL
            )

-- --------------------------------------------------------
PRINT ' '
PRINT '-- Chargement des contrats en table temporaire'
PRINT '-- Récupération du périmetre d''intervention'
-- --------------------------------------------------------
/*** modif 001
INSERT into #TCONTR
select distinct ctr_nf, uwy_nf
from   BTRAV..CNC_CNCD2000_COMMUTCTRUWY
**/

PRINT ' '
PRINT 'TRAITES - récupération contrat/exercice commutés'
PRINT 'FACULTATIVES - récupération contrat/exercice commutés'
INSERT into #TCONTR
select distinct tcontr.ctr_nf, tcontr.uwy_nf
FROM btrt..TRFCROSSREF crossref,
     btrt..TCONTR tcontr
WHERE   tcontr.ctr_nf     = crossref.ctr_nf
AND     crossref.uworg_cf = 211    -- origine portefeuille commutation AXA
AND     tcontr.ssd_cf     = crossref.ssd_cf

UNION

select distinct tcontr.ctr_nf, tcontr.uwy_nf
FROM bfac..TRFCROSSREF crossref,
     bfac..TCONTR tcontr
WHERE   tcontr.ctr_nf     = crossref.ctr_nf
AND     crossref.uworg_cf = 211    -- origine portefeuille commutation AXA
AND     tcontr.ssd_cf     = crossref.ssd_cf

select @cpt_edit = @@rowcount

    IF @p_DEBUG = 1
        BEGIN
            PRINT 'nombre de contrats/EX sélectionnés = %1!.',@cpt_edit
            PRINT ' '
        END

IF @p_DEBUG = 1
        BEGIN
            PRINT 'gestion des sinistres de type précaution'
            PRINT ' '
        END

-- -----------------------------------------------------------------------------------------------------------------------
PRINT 'Passage à CLOS des sinistres de type ''précaution'' (clmtyp_cf = 1) appartenant au périmétre des contrats commutés'
-- -----------------------------------------------------------------------------------------------------------------------
UPDATE BCTA..TCLAIM
SET CLMSTS_CF = '2' --clos
FROM BCTA..TCLAIM tclaim,
     #TCONTR #tcontr
WHERE tclaim.ctr_nf    = #tcontr.ctr_nf
and   tclaim.uwy_nf    = #tcontr.uwy_nf
and   tclaim.clmsts_cf = '1'  -- =1 si ouvert ; =2 si clos ; =3 si sans suite
and   tclaim.clmtyp_cf = '1'  -- =1 si précaution; =2 si pris en charge

-- ----------------------------------------------------
PRINT 'Recherche dernière position par sinistre devise'
PRINT ''
-- ----------------------------------------------------
    IF @p_DEBUG = 1
        BEGIN
            PRINT 'declare curs_pos_dev'
            PRINT ' '
        END

declare curs_pos_dev cursor for
select a.clm_nf, a.ssd_cf, c.cur_cf, c.curlstpos_nt
from BCTA..TCLAIM a, #TCONTR b, BCTA..TCLMCUR c
where a.ctr_nf = b.ctr_nf
and   a.uwy_nf = b.uwy_nf
and   a.clm_nf = c.clm_nf
and   a.ssd_cf = c.ssd_cf
and   a.clmsts_cf != '2'	-- 2 = clos
order by a.clm_nf,c.cur_cf, a.ssd_cf

for read only

declare
	@clm_nf 	uclm_nf,
	@ssd_cf	 	ussd_cf,
	@cur_cf		ucur_cf,
	@curlstpos_nt	upos_nt,
	@derpos_nt	upos_nt,
	@derpos_d	datetime,
	@derac		UACCYER_NF,
	@erreur		int

-- Ouverture curseur

    IF @p_DEBUG = 1
        BEGIN
            PRINT 'Ouverture curseur'
        END
open curs_pos_dev

BEGIN TRAN

PRINT '1ère lecture curseur'

fetch	curs_pos_dev
    into @clm_nf,
         @ssd_cf,
         @cur_cf,
         @curlstpos_nt

while @@sqlstatus = 0
begin
    IF @p_DEBUG = 1
        BEGIN
            PRINT 'valeurs retour curseur'
            PRINT '@clm_nf       = %1!.',@clm_nf
            PRINT '@ssd_cf       = %1!.',@ssd_cf
            PRINT '@cur_cf       = %1!.',@cur_cf
            PRINT '@curlstpos_nt = %1!.',@curlstpos_nt
        END

-- Recherche de la dernière position et creation nouvelle position quelle que soit la devise

	select @derpos_nt = (select lstpos_nt + 1
			             from  BCTA..TCLAIM
			             where clm_nf = @clm_nf
			             and   ssd_cf = @ssd_cf)

-- Mettre à jour le numéro de la dernière position par devise dans TCLMCUR

	update BCTA..TCLMCUR
	set curlstpos_nt = @derpos_nt
	from  BCTA..TCLMCUR
	where clm_nf = @clm_nf
	and   ssd_cf = @ssd_cf
	and   cur_cf = @cur_cf

	select @erreur = @@error

	if @erreur != 0
		begin
			select 'Erreur update TCLMCUR sur sinistre, filiale, devise : ',
				 @clm_nf,@ssd_cf,@cur_cf, ' Erreur : ', @erreur
			ROLLBACK TRAN
			break
		end

-- Mettre à jour le numéro de la dernière position dans TCLAIM

    IF @p_DEBUG = 1
        BEGIN
            PRINT 'MAJ du n° de la dernière position et passage du status à CLOS dans TCLAIM'
            PRINT ' '
        END
	update BCTA..TCLAIM
	set lstpos_nt = @derpos_nt,        --dernière position
        clmsts_cf = '2',               -- passage à l'état CLOS
        lstupdusr_cf= 'DBC',
        lstupd_d = getdate(),
        clmclo_d = getdate()

	from  BCTA..TCLAIM
	where clm_nf = @clm_nf
	and   ssd_cf = @ssd_cf

	select @erreur = @@error

	if @erreur != 0
		begin
			select 'Erreur update TCLAIM sur sinistre, filiale : ',
				 @clm_nf,@ssd_cf, ' Erreur : ', @erreur
			ROLLBACK TRAN
			break
		end

-- Recherche de la derniere ac dans tclmpos pour le sinistre

	select @derac = (select max(acy_nf)
                 	 from   BCTA..TCLMPOS
                 	 where  clm_nf = @clm_nf
                 	 and    ssd_cf = @ssd_cf)

-- Recherche de la derniere date position dans tclmpos pour le sinistre
-- mais on prend le max entre cette valeur et le 31/12/1997

	select @derpos_d = (select max(pos_d)
                 	 from   BCTA..TCLMPOS
                 	 where  clm_nf = @clm_nf
                 	 and    ssd_cf = @ssd_cf)

	if @derpos_d < @p_date_acy
   		begin
       		select @derpos_d = @p_date_acy
       	end

    IF @p_DEBUG = 1
        BEGIN
            PRINT 'dernière date de position : %1!.', @derpos_d
            PRINT 'dernière AC de position   : %1!.', @derac
            PRINT ' '
        END

-- Création des nouvelles positions dans TCLMPOS

    IF @p_DEBUG = 1
        BEGIN
            PRINT 'Création des nouvelles positions dans TCLMPOS'
        END
 INSERT BCTA..TCLMPOS (
 		CLM_NF,
 	    	SSD_CF,
 		POS_NT,
 		POS_D,
 		CUR_CF,
 		POSACC_D,
 		SCOSTRMTH_NF,
 		SCOENDMTH_NF,
 		ACY_NF,
 		CREUSR_CF)
select
		@CLM_NF,
		@SSD_CF,
        	@derpos_nt,
    		@derpos_d,
    		@CUR_CF,
    		getdate(),	--@p_blcsht_d,
    		datepart(mm, @p_blcsht_d),
    		datepart(mm, @p_blcsht_d),
    		@p_acy_nf,
    		'DBC'		--CREUSR_CF

select @erreur = @@error

if @erreur != 0
		begin
			select 'Erreur INSERT TCLMPOS sur sinistre, filiale, position, devise : ',
				 @clm_nf,@ssd_cf,@derpos_nt,@cur_cf, ' Erreur : ', @erreur
			ROLLBACK TRAN
			break
		end

-- Suppresion du montant trouvé par la lecture précédente

	delete #TCLMAMT

--  Recherche du dernier montant de sp
    IF @p_DEBUG = 1
        BEGIN
            PRINT 'Recherche du dernier montant de sp'
        END
	INSERT #TCLMAMT
	select
    		a.CLM_NF,
    		a.POS_NT,
    		a.POSTYP_CT,
    		a.AMTTYP_NT,
    		a.SSD_CF,
    		1,         		--a.REB_NF,
    		a.AMTLOS_M,
    		a.AMTEXP_M,
    		a.AMTINT_M,
    		a.AMTREC_M,
    		a.AMTRPC_M,
    		a.AMTTOT_M,
    		a.AMTSYSGEN_B,
    		a.POSACC_D,
    		a.SCOSTRMTH_NF,
    		a.SCOENDMTH_NF,
    		a.ACY_NF
	from  BCTA..TCLMAMT a
	where a.ssd_cf    = @ssd_cf
	and   a.clm_nf    = @clm_nf
	and   a.pos_nt    = @curlstpos_nt
	and   a.postyp_ct = 'SI'   -- sinistre individuel
	and   a.amttyp_nt = 1      -- montant SP

select @erreur = @@error

if @erreur != 0
		begin
			select 'Erreur INSERT #TCLMAMT sur sinistre, filiale, position : ',
				 @clm_nf,@ssd_cf,@curlstpos_nt, ' Erreur : ', @erreur
			ROLLBACK TRAN
			break
		end

-- recherche des mvts de SAP pour les cumulés
    IF @p_DEBUG = 1
        BEGIN
            PRINT 'recherche des mvts de SAP pour les cumulés'
            PRINT ' '
        END
    INSERT #SAP_TCLMAMT
    select
    		a.CLM_NF,
    		a.POS_NT,
    		a.POSTYP_CT,
    		AMTTYP_NT=9,
    		a.SSD_CF,
    		--a.REB_NF,
    		AMTLOS_M=sum(isnull(a.AMTLOS_M,0)),
    		AMTEXP_M=sum(isnull(a.AMTEXP_M,0)),
    		AMTINT_M=sum(isnull(a.AMTINT_M,0)),
    		AMTREC_M=sum(isnull(a.AMTREC_M,0)),
    		AMTRPC_M=sum(isnull(a.AMTRPC_M,0)),
    		AMTTOT_M=sum(isnull(a.AMTTOT_M,0))

    from  BCTA..TCLMAMT a
	where a.ssd_cf    = @ssd_cf
	and   a.clm_nf    = @clm_nf
	and   a.pos_nt    = @curlstpos_nt
	and   a.postyp_ct = 'SI'       -- sinistre individuel
	and   a.amttyp_nt in (2,3,4)   -- montants de SAP
    group by a.CLM_NF,a.POS_NT,a.POSTYP_CT,a.SSD_CF --,a.REB_NF
    order by a.CLM_NF,a.POS_NT,a.POSTYP_CT,a.SSD_CF --,a.REB_NF

-- basculement du montant cumulé des SAP dans le dernier montant de SP
    IF @p_DEBUG = 1
        BEGIN
            PRINT 'basculement du montant cumulé des SAP dans le dernier montant de SP'
            PRINT ' '
        END
    UPDATE #TCLMAMT
    SET a.AMTLOS_M=isnull(a.AMTLOS_M,0) + b.AMTLOS_M,
    	a.AMTEXP_M=isnull(a.AMTEXP_M,0) + b.AMTEXP_M,
    	a.AMTINT_M=isnull(a.AMTINT_M,0) + b.AMTINT_M,
    	a.AMTREC_M=isnull(a.AMTREC_M,0) + b.AMTREC_M,
    	a.AMTRPC_M=isnull(a.AMTRPC_M,0) + b.AMTRPC_M,
    	a.AMTTOT_M=isnull(a.AMTTOT_M,0) + b.AMTTOT_M
    from  #TCLMAMT a, #SAP_TCLMAMT b
	where a.ssd_cf    = b.ssd_cf
	and   a.clm_nf    = b.clm_nf
    and   a.pos_nt    = b.pos_nt

--  Reconduire le dernier montant de SP

    IF @p_DEBUG = 1
        BEGIN
            PRINT 'Reconduction du dernier montant de SP'
            PRINT ' '
        END
INSERT BCTA..TCLMAMT
(CLM_NF,POS_NT,POSTYP_CT,AMTTYP_NT,SSD_CF,REB_NF,AMTLOS_M,AMTEXP_M,AMTINT_M,AMTREC_M,AMTRPC_M,AMTTOT_M,AMTSYSGEN_B,POSACC_D,SCOSTRMTH_NF,SCOENDMTH_NF,ACY_NF)    --[18401]
select
   	    CLM_NF,
        @DERPOS_NT,               --POS_NT,
    	POSTYP_CT,
    	AMTTYP_NT,
    	SSD_CF,
    	REB_NF,
    	AMTLOS_M,
    	AMTEXP_M,
    	AMTINT_M,
   	    AMTREC_M,
    	AMTRPC_M,
    	AMTTOT_M,
    	0,                         --AMTSYSGEN_B,
    	getdate(),                 --POSACC_D,
    	datepart(mm, @p_blcsht_d), --SCOSTRMTH_NF,
    	datepart(mm, @p_blcsht_d), --SCOENDMTH_NF,
    	@p_acy_nf                  --ACY_NF

from  #TCLMAMT
where ssd_cf    = @ssd_cf
  and clm_nf    = @clm_nf

select @erreur = @@error

if @erreur != 0
		begin
			select 'Erreur INSERT TCLMAMT dernier mt sp sur sinistre, filiale : ',
				 @clm_nf,@ssd_cf,' Erreur : ', @erreur
			ROLLBACK TRAN
			break
		end

--  Créer une position de sap cédante (type = 2) à zéro

    IF @p_DEBUG = 1
       BEGIN
        PRINT 'Création de la position de sap cédante (type = 2) à zéro'
        PRINT ' '
       END
INSERT BCTA..TCLMAMT
(CLM_NF,POS_NT,POSTYP_CT,AMTTYP_NT,SSD_CF,REB_NF,AMTLOS_M,AMTEXP_M,AMTINT_M,AMTREC_M,AMTRPC_M,AMTTOT_M,AMTSYSGEN_B,POSACC_D,SCOSTRMTH_NF,SCOENDMTH_NF,ACY_NF)   --[18401]
select
      CLM_NF,
    	@DERPOS_NT,                --POS_NT,
    	POSTYP_CT,
    	2,                         --AMTTYP_NT,
    	SSD_CF,
    	REB_NF,
    	0,                         --AMTLOS_M,
    	0,                         --AMTEXP_M,
    	0,                         --AMTINT_M,
   	    0,                         --AMTREC_M,
    	0,                         --AMTRPC_M,
    	0,                         --AMTTOT_M,
    	0,                         --AMTSYSGEN_B,
    	getdate(),                 --POSACC_D,
    	datepart(mm, @p_blcsht_d), --SCOSTRMTH_NF,
    	datepart(mm, @p_blcsht_d), --SCOENDMTH_NF,
    	@p_acy_nf                  --ACY_NF

from  #TCLMAMT
where ssd_cf = @ssd_cf
 and clm_nf = @clm_nf

select @erreur = @@error

if @erreur != 0
		begin
			select 'Erreur INSERT TCLMAMT position sap à zéro sur sinistre, filiale : ',
				 @clm_nf,@ssd_cf,' Erreur : ', @erreur
			ROLLBACK TRAN
			break
		end

-- Creer une position de sap substitution (type = 3) à zero si elle existe
    IF @p_DEBUG = 1
        BEGIN
            PRINT 'Création de la position de sap substitution (type = 3) à zero si elle existe'
        END
    INSERT BCTA..TCLMAMT
    (CLM_NF,POS_NT,POSTYP_CT,AMTTYP_NT,SSD_CF,REB_NF,AMTLOS_M,AMTEXP_M,AMTINT_M,AMTREC_M,AMTRPC_M,AMTTOT_M,AMTSYSGEN_B,POSACC_D,SCOSTRMTH_NF,SCOENDMTH_NF,ACY_NF)  --[18401]
    select
        a.CLM_NF,
    	@DERPOS_NT,                 --POS_NT,
    	a.POSTYP_CT,
    	3,                          --AMTTYP_NT,
    	a.SSD_CF,
    	a.REB_NF,
    	0,                          --AMTLOS_M,
    	0,                          --AMTEXP_M,
    	0,                          --AMTINT_M,
   	    0,                          --AMTREC_M,
    	0,                          --AMTRPC_M,
    	0,                          --AMTTOT_M,
    	0,                          --AMTSYSGEN_B,
    	getdate(),                  --POSACC_D,
    	datepart(mm, @p_blcsht_d),  --SCOSTRMTH_NF,
    	datepart(mm, @p_blcsht_d),  --SCOENDMTH_NF,
    	@p_acy_nf                   --ACY_NF

    from  #TCLMAMT a
    where a.ssd_cf = @ssd_cf
    and a.clm_nf = @clm_nf
    and exists (select * from bcta..tclmamt b
                               where a.clm_nf = b.clm_nf
                                 and a.ssd_cf = b.ssd_cf
                                 and b.amttyp_nt = 3
                                 and b.pos_nt = @curlstpos_nt) -- ajout vde le 10/03/05

    select @erreur = @@error

if @erreur != 0
		begin
			select 'Erreur INSERT TCLMAMT position sap sub. à zéro sur sinistre, filiale : ',
				 @clm_nf,@ssd_cf,' Erreur : ', @erreur
			ROLLBACK TRAN
			break
		end

-- Creer une position de SAP compémentaire (type = 4) à zéro si elle existe
    IF @p_DEBUG = 1
        BEGIN
            PRINT 'Création de la position de SAP compémentaire (type = 4) à zéro si elle existe'
        END

    INSERT BCTA..TCLMAMT
    (CLM_NF,POS_NT,POSTYP_CT,AMTTYP_NT,SSD_CF,REB_NF,AMTLOS_M,AMTEXP_M,AMTINT_M,AMTREC_M,AMTRPC_M,AMTTOT_M,AMTSYSGEN_B,POSACC_D,SCOSTRMTH_NF,SCOENDMTH_NF,ACY_NF)
    select
      a.CLM_NF,
    	@DERPOS_NT,                --POS_NT,
    	a.POSTYP_CT,
    	4,                         --AMTTYP_NT,
    	a.SSD_CF,
    	a.REB_NF,
    	0,                         --AMTLOS_M,
    	0,                         --AMTEXP_M,
    	0,                         --AMTINT_M,
   	    0,                         --AMTREC_M,
    	0,                         --AMTRPC_M,
    	0,                         --AMTTOT_M,
    	0,                         --AMTSYSGEN_B,
    	getdate(),                 --POSACC_D,
    	datepart(mm, @p_blcsht_d), --SCOSTRMTH_NF,
    	datepart(mm, @p_blcsht_d), --SCOENDMTH_NF,
    	@p_acy_nf                  --ACY_NF

    from  #TCLMAMT a
    where a.ssd_cf = @ssd_cf
        and a.clm_nf = @clm_nf
        and exists (select * from bcta..tclmamt b
                               where a.clm_nf = b.clm_nf
                                 and a.ssd_cf = b.ssd_cf
                                 and b.amttyp_nt = 4
                                 and b.pos_nt = @curlstpos_nt) -- ajout vde le 10/03/05

    select @erreur = @@error

    if @erreur != 0
		begin
			select 'Erreur INSERT TCLMAMT position acr à zéro sur sinistre, filiale : ',
				 @clm_nf,@ssd_cf,' Erreur : ', @erreur
			ROLLBACK TRAN
			break
		end

-- Lecture suivante curseur
    IF @p_DEBUG = 1
        BEGIN
            PRINT 'Lecture suivante'
        END
fetch	curs_pos_dev into @clm_nf, @ssd_cf, @cur_cf, @curlstpos_nt

end

COMMIT TRAN

-- Fermeture du curseur
    IF @p_DEBUG = 1
        BEGIN
            PRINT 'Fermeture du curseur'
        END
close curs_pos_dev
deallocate cursor curs_pos_dev

-- Mise a jour indicateur sur CNC_CNCD2000_COMMUTCTRUWY

    IF @p_DEBUG = 1
        BEGIN
            PRINT 'Mise a jour indicateur sur CNC_CNCD2000_COMMUTCTRUWY'
            PRINT ' '
        END
update BTRAV..CNC_CNCD2000_COMMUTCTRUWY
set    TOP_COMUT = 1

FIN:
return
go
GRANT EXECUTE ON dbo.PtCLMCOMMUT_01 TO GOMEGA
go
IF OBJECT_ID('dbo.PtCLMCOMMUT_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtCLMCOMMUT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtCLMCOMMUT_01 >>>'
go
EXEC sp_procxmode 'dbo.PtCLMCOMMUT_01','unchained'

--DROP TABLE BTRAV..CNC_CNCD2000_COMMUTCTRUWY
go
