USE BEST
go
IF OBJECT_ID('dbo.PsUNDSTA_10_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsUNDSTA_10_O2
    IF OBJECT_ID('dbo.PsUNDSTA_10_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsUNDSTA_10_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsUNDSTA_10_O2 >>>'
END
go
/*
 * creation de la procedure */
create procedure PsUNDSTA_10_O2 (
    @p_ctr_nf   UCTR_NF,
    @p_end_nt   UEND_NT,
    @p_sec_nf   USEC_NF,
    @p_uwy_nf   UUWY_NF,
    @p_uw_nt    UUW_NT,
    @p_lag_cf   ULAG_CF
)

as
/***************************************************
Programme:                  PsUNDSTA_10_O2
Fichier script associé :    ESSUND10.PRC
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     ME34 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
	- Si ctr_nf = "__T%" ou ctr_nf = "__Z% "
		- Select de BTRT..TSECTION
		- Select de BTRT..TSECTION (date effet de l'exercice le plus ancien)
		- Select de BTRT..TSECTION (date d'échéance dernier exercice)
			- Si secsts_ct = 19 du max(uwy_nf) dans #liste
				==> seccan_d du max(uwy_nf)
              	sinon
				==> scoexp_d de BTRT..TCONTR --> seccan_d

		- Select de BTRT..TFAMLIA (monnaie estimation)
		- Select de BTRT..TCONTR
		- Select de BTRT..TBOQPRG (libellé programme)
		- Select de BTRT..TBOQPRG (libellé bouquet)
		- Select du TIMESTAMP_GRAPPE de l'application TRAITE

	- Si ctr_nf = "__F%" ou ctr_nf = "__G%"
		- Select de BFAC..TSECTION
		- Select de BFAC..TSECTION (date effet de l'exercice le plus ancien)
		- Select de BFAC..TSECTION (date d'échéance dernier exercice)
			- Si secsts_ct = 19 du max(uwy_nf) dans #liste
				==> seccan_d du max(uwy_nf)
              	sinon
				==> scoexp_d de BFAC..TCONTR --> seccan_d

		- Select de BFAC..TFAMLIA
		- Select de BFAC..TCONTR  (bandeau fac)

	- Select BEST..TUNDSTA
	- Select BCLI..TCLIENT (libellé cédante)
	- Select BREF..TBANTECL (status du contrat)
	- Select BREF..TBANTECL (libellé type comptable)
	- Select BREF..TCTYSUPL (libellé territorialité ou marché)

	- Select final des variables

Parametres:
       @p_ctr_nf              UCTR_NF,      : Contrat
       @p_uwy_nf              UUWY_NF,      : Exercice
       @p_uw_nt               UUW_NT,	       : N° d'ordre
       @p_end_nt              UEND_NT,      : Avenant
       @p_sec_nf              USEC_NF,      : Section
       @p_lag_cf              ULAG_CF       : Langue
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur: L.DEBEVER
Date:	02/08/1997
Version:
Description: Dans le cas d'un TRAITE :
		 Si "secsts_ct" = 19
               ==> On affecte la date de résiliation "seccan_d" de l'exercice
                   le plus récent. -> ETAIT VALABLE ET LE RESTE
              Sinon
               ==> On recherche la date d'échéance "scoexp_d" de l'exercice le
                   plus récent dans BTRT..TCONTR, puis on l'affecte à "seccan_d".
					-> ON AFFECTE DESORMAIS "scoexp_d" - 1 jour A
					"seccan_d"
_________________
MODIFICATION 2
Auteur: A. PARIS
Date:	31/10/1997
Version:
Description: Recherche de la dernière période de compte recue : information comptable  (table TAPR)
_________________
MODIFICATION 3
Auteur:L.DEBEVER
Date:	26/11/1997
Version:
Description: Optimisation recherche de valeurs max dans tsection
_________________
MODIFICATION 4
Auteur:L.DEBEVER
Date:	06/02/1997
Version:
Description: si la valeur de egplessco_m est NULL, elle
	      reste à NULL, on ne la force pas à '0',
	      sinon ça fout la merde dans TRAITE à la création
	      d'un Ultime.
________________
MODIFICATION 5
Auteur: L.DEBEVER
Date: 09/02/1998
Version:
Description: Condition pour déterminer si un contrat est
	      un Traité :
	        IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z% or @p_ctr_nf like "__U%" or @p_ctr_nf like "__W%",
	      au lieu de :
		 IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%"
	      Il existe des traités de type "__U%" et "__W%"
________________
MODIFICATION 6
Auteur: L.DEBEVER
Date: 09/02/1998
Version:
Description: On reamène scogloegp_m de TFAMLIA
________________
MODIFICATION 7
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
_________________
MODIFICATION    [008]
Auteur:         D.GATIBELZA
Date:           27/05/2008
Version:        8.1
Description:    EDI15180
_________________
MODIFICATION    [009]
Auteur:         D.GATIBELZA
Date:           07/09/2009
Version:        9.1
Description:    ESTDOM17994 optimisation des temps de réponse fenetre révision des utltimes
_________________
MODIFICATION 010
Auteur: J.CHOCHON
Date: 10/07/2012
Version:
Description: The keyword "like" on ctr_nf is removed
_________________
MODIFICATION 011
Auteur: J.CHOCHON
Date: 14/01/2013
Version:
Description: removed the unnecessary SQL expressions (line 503) by "else"

_________________
MODIFICATION 012
Auteur: Swapnil S
Date: 12/06/2015
Version:
Description: spira#037451
*****************************************************/
declare @erreur             int,
        @max_secsts_ct      tinyint,
        @max_uwy_nf         UUWY_NF,
        @max_seccan_d       datetime,
        @RP                 UAMT_M,         /* compte comptet : resultat/prime              */
        @aliment_revise     UAMT_M,         /* scogloegp_m                                  */
        @ctrnat_ct          char(1),        /* nature de l'affaire: 'P'rop, 'N'on/prop,'F'ac*/
        @TIMESTAMP_GRAPPE   char(21)        /* utiliser pour la mise à jour sur TRAITE      */

/*---------------------------------
  Déclaration table BREF..TBANTECL
---------------------------------*/
declare @accadmtyp_lm       UL32,           /* libellé type comptable           */
        @ctrsts_ls          UL16            /* libellé status du traité ou fac  */

/*---------------------------------
  Déclaration table BREF..TCTYSUPL
---------------------------------*/
declare @ctysup_ls          UL16            /* libellé territorialité ou marché */

/*---------------------------------
  Déclaration table BCLI..TCLIENT
---------------------------------*/
declare @ced_ld             UCLISHONAM_LD   /* libellé cédante                  */

/*--------------------------------- --------
  Déclaration table TBOQPRG (TRAITE et FAC)
-------------------------------------------*/
declare @prg_ll             UL64,           /* libellé programme                */
        @boq_ll             UL64            /* libellé bouquet                  */

/*---------------------------------
  Déclaration table BEST..TUNDSTA
---------------------------------*/
declare @caccprm_m          UAMT_M,         /* compte complet : prime           */
        @caccclm_m          UAMT_M,         /* compte complet : sinistralité    */
        @caccloa_m          UAMT_M,         /* compte complet : charge          */
        @acy_nf             smallint,       /* période AAAA                     */
        @scoendmth_nf       tinyint,        /* période MM                       */
        @accprm_m           UAMT_M,         /* comptabilisée  : prime           */
        @accclm_m           UAMT_M,         /* comptabilisée  : sinistralité    */
        @caccupr_m          UAMT_M,
        @caccacr_m          UAMT_M,
        @accacr_m           UAMT_M

/*----------------------------------------
  Déclaration table TCONTR (TRAITE et FAC)
------------------------------------------*/
declare @prg_nf             UCTRGRP_NF,     /* code programme                   */
        @boq_nf             UCTRGRP_NF,     /* code bouquet                     */
        @ctrpcpnam_ll       UL64,           /* nom du traité ou affaire	        */
        @ced_nf             UCLI_NF,        /* code cédante                     */
        @ctrsts_ct          UCTRSTS_CT,     /* code status du traité ou fac     */
        @scoinc_d           datetime,       /* date d'effet du traité           */
        @ctrinc_d           datetime,       /* date d'effet de la facultative   */
        @accesb_cf          UESB_CF

/*-------------------------------------------
  Déclaration table TFAMLIA (TRAITE ET FAC)
-------------------------------------------*/
declare	@egpcur_cf          UCUR_CF,        /* monnaie estimation              	        */
        @addegp_m           UAMT_M,         /* montant aliment SCOR additionnel avenant */
        @scogloegp_m        UAMT_M,         /* montant aliment SCOR global              */
        @scoorgegp_m        UAMT_M,         /* montant part SCOR origine                */
        @pmlrat_r           USHORAT_R,		/* taux de SMP                              */
        @ridsha_r           USHA_R,         /* part réassurée                           */
        @scoegpcal_b        bit,            /* aliment part SCOR calculé (saisi)?       */
        @egplessco_m        UAMT_M,         /* montant dernière révision SCOR de l'aliment  */
        @cutsha_r           USHA_R,         /* part SCOr courante                       */
        @liaridsha_b        bit,			/* engagement sur part réassurée ?          */
        @reiexi_b           bit,			/* existence reconstitutions ?              */
        @reiunl_b           bit,			/* reconstitutions illimitées ?             */
        @reifre_b           bit,			/* reconstitutions gratuites (payantes) ?   */
        @reinbr_n           tinyint,		/* nombres de reconstitutions               */
        @laycap_m           UAMT_M,         /* montant portée                           */
        @liacur_cf          UCUR_CF         /* Monnaie engagement                       */

/*----------------------------------------------
  Déclaration table TSECTION (TRAITE ET FAC)
----------------------------------------------*/
declare	@subnat_cf          UCTRSUBNAT_CF,  /* sous nature                              */
        @nat_cf             UCTRNAT_CF,     /* nature                                   */
        @lob_cf             ULOB_CF,        /* Lob                                      */
        @top_cf             UTOP_CF,        /* Top                                      */
        @sob_cf             USOB_CF,        /* Sob                                      */
        @gar_cf             UGAR_CF,        /* garantie                                 */
        @pcprsktry_cf       UCTY_CF,        /* territoire principal de risque (territorialité ou marché)    */
        @usrcrtval_lm       UL32,           /* valeur critère utilisateur               */
        @ssd_cf             USSD_CF,        /* filiale                                  */
        @secsts_ct          UCTRSTS_CT,     /* etat de la section                       */
        @accadmtyp_ct       UACCADMTYP_CT,  /* type comptable	                        */
        @secaccsts_ct       UACCSTS_CT,     /* etat comptable de la section             */
        @estend_b           bit,            /* top estimations terminées                */
        @secinc_d           datetime,       /* date effet premier exercice              */
        @seccan_d           datetime,       /* date echeance dernier exercice           */
        @frsuwy_nf          UUWY_NF         /* 1er exercice de souscription de ce contrat                   */

/*---------------------------------
  Déclaration table BCTA..TAPR
---------------------------------*/
declare @maxacy_nf          smallint,       /* période AAAA ( dernière année de compte recu )               */
        @maxscoendmth_nf    tinyint         /* période MM   ( dernièr mois de compte recu )                 */


/* Initialisation de la variable TIMESTAMP_GRAPPE ------*/
select @TIMESTAMP_GRAPPE = NULL

/*****************************************************************************************
  TRAITE
*******************************************************************************************/
/* Modification 5 :                                          */
/*IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%" */
--IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%" or @p_ctr_nf like "__U%" or @p_ctr_nf like "__W%"
If exists (select 1 from BTRT..TCONTR where ctr_nf = @p_ctr_nf)													-- 010 add
begin
    /*------------------------
     Select  BTRT..TSECTION
    --------------------------*/
    select @subnat_cf    = subnat_cf,
           @nat_cf       = nat_cf,
           @lob_cf       = lob_cf,
           @top_cf       = top_cf,
           @sob_cf       = sob_cf,
           @gar_cf       = gar_cf,
           @pcprsktry_cf = pcprsktry_cf,
           @usrcrtval_lm = usrcrtval_lm,
           @ssd_cf       = ssd_cf,
           @secsts_ct    = secsts_ct,
           @secaccsts_ct = secaccsts_ct,
           @accadmtyp_ct = accadmtyp_ct,
           @secinc_d     = secinc_d,
           @seccan_d     = seccan_d,
           @frsuwy_nf    = frsuwy_nf,
           @estend_b     = estend_b
    from BTRT..TSECTION
    where ctr_nf = @p_ctr_nf
      and end_nt = @p_end_nt
      and sec_nf = @p_sec_nf
      and uwy_nf = @p_uwy_nf
      and uw_nt  = @p_uw_nt
      and secsts_ct in (14,16,17,18,19) /* (accepté, définitif, renouvelé, expiré, résilié) */

    select @erreur = @@error
	if @erreur != 0
	begin
	    raiserror 20001 "APPLICATIF;BTRT..TSECTION"
	    goto fin
	end

	-- modification 012 start
	if @ssd_cf is null 
	begin
		select @ssd_Cf = ssd_cf 
		from BTRT..TSECTION
		where 	ctr_nf = @p_ctr_nf
				and end_nt = @p_end_nt
				and sec_nf = @p_sec_nf
				and uwy_nf = @p_uwy_nf
				and uw_nt  = @p_uw_nt
	end
	-- modification 012 end
	
	/*-----------------------------------------------------------------
  	Date effet premier exercice :
  	Recherche de la date d'effet de l'exercice le plus ancien de ce
      contrat/section tous exercice confondus.
      select dans BTRT..TSECTION
 	-------------------------------------------------------------------*/
    select @secinc_d   = secinc_d
    from BTRT..TSECTION
    where ctr_nf = @p_ctr_nf
   	   and end_nt = @p_end_nt
   	   and sec_nf = @p_sec_nf
   	   and uw_nt  = @p_uw_nt
   	   and secsts_ct in (14,16,17,18,19) /* (accepté, définitif, renouvelé, expiré, résilié) */
       and uwy_nf = @frsuwy_nf

    select @erreur = @@error
    if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;BTRT..TSECTION"
        goto fin
    end

	/*-------------------------------------------------------------------------
	  Date d'échéance dernier exercice :
	  Test l'état de l'exercice le plus récent "Max(uwy_nf)" dans BTRT..TSECTION :
               Si "secsts_ct" = 19
               ==> On affecte la date de résiliation "seccan_d" de l'exercice
                   le plus récent.

               Sinon
               ==> On recherche la date d'échéance "scoexp_d" de l'exercice le
                   plus récent dans BTRT..TCONTR, puis on l'affecte à "seccan_d".
			Modif 1 : on affecte scoexp_d - 1 j à seccand_d
	--------------------------------------------------------------------------*/
	/* MODIFICATION 3: Ex requête : non optimisée
		 select 	@max_uwy_nf    = max(uwy_nf),
			@max_secsts_ct = secsts_ct,
			@max_seccan_d  = seccan_d
          from BTRT..TSECTION
	   where ctr_nf = @p_ctr_nf
           and end_nt = @p_end_nt
           and sec_nf = @p_sec_nf
           and uw_nt  = @p_uw_nt
           and secsts_ct in (14,16,17,18,19) /* (accepté, définitif, renouvelé, expiré, résilié) */
	*/

	/* Requête optimisée   */
    select @max_uwy_nf    = uwy_nf,
           @max_secsts_ct = secsts_ct,
           @max_seccan_d  = seccan_d
    from BTRT..TSECTION a
    where a.ctr_nf = @p_ctr_nf
      and a.end_nt = @p_end_nt
      and a.sec_nf = @p_sec_nf
      and a.uw_nt  = @p_uw_nt
      and a.secsts_ct in (14,16,17,18,19)
      and uwy_nf = ( select max(uwy_nf)
                     from BTRT..TSECTION b
                     where a.ctr_nf = b.ctr_nf
                       and a.end_nt = b.end_nt
                       and a.sec_nf = b.sec_nf
                       and a.uw_nt  = b.uw_nt
                       and a.secsts_ct in (14,16,17,18,19)) /* (accepté, définitif, renouvelé, expiré, résilié) */

    if @max_secsts_ct = 19
    begin
	    select @seccan_d = @max_seccan_d
    end
    else
    begin
        /*	select @seccan_d = scoexp_d  */
        /* MODIFICATION 1 */
		select @seccan_d = dateadd(dd, -1, scoexp_d)
        from BTRT..TCONTR
        where ctr_nf = @p_ctr_nf
          and end_nt = @p_end_nt
          and uw_nt  = @p_uw_nt
          and uwy_nf = @max_uwy_nf

        select @erreur = @@error
        if @erreur != 0
        begin
            raiserror 20001 '20001 APPLICATIF;BTRT..TCONTR;'
            goto fin
        end
    end

    /*--------------------------
      select de BTRT..TFAMLIA
    ----------------------------*/
    select @egpcur_cf      = egpcur_cf,
           @aliment_revise = scogloegp_m,
           @scogloegp_m    = scogloegp_m,
           @scoorgegp_m    = scoorgegp_m,
           @pmlrat_r       = pmlrat_r,
           @ridsha_r       = ridsha_r,
           @scoegpcal_b    = scoegpcal_b,
           @egplessco_m    = egplessco_m,
           @cutsha_r       = cutsha_r,
           @liaridsha_b    = liaridsha_b,
           @reiexi_b       = reiexi_b,
           @reiunl_b       = reiunl_b,
           @reifre_b       = reifre_b,
           @reinbr_n       = reinbr_n,
           @laycap_m       = laycap_m,
           @liacur_cf	   = liacur_cf
    from BTRT..TFAMLIA
    where ctr_nf = @p_ctr_nf
      and end_nt = @p_end_nt
      and sec_nf = @p_sec_nf
      and uwy_nf = @p_uwy_nf
      and uw_nt  = @p_uw_nt

    select @erreur = @@error
    if @erreur != 0
    begin
        raiserror 20001 '20001 APPLICATIF;BTRT..TFAMLIA;'
        goto fin
    end

	/*---------------------------------
	  select de BTRT..TCONTR
      bandeau (TRAITE)
	 ---------------------------------*/
    select @prg_nf       = prg_nf,
           @boq_nf       = boq_nf,
           @ctrpcpnam_ll = ctrpcpnam_ll,
           @ced_nf       = ced_nf,
           @ctrsts_ct    = ctrsts_ct,
           @scoinc_d     = scoinc_d,
           @accesb_cf    = accesb_cf
    from BTRT..TCONTR
    where ctr_nf = @p_ctr_nf
      and end_nt = @p_end_nt
      and uw_nt  = @p_uw_nt
      and uwy_nf = @p_uwy_nf

    select @erreur = @@error
    if @erreur != 0
    begin
        raiserror 20001 '20001 APPLICATIF;BTRT..TCONTR;'
        goto fin
    end

	/*---------------------------------
 	 Recherche du libellé du programme
	-----------------------------------*/
    select @prg_ll = grpnam_ll
	from BTRT..TBOQPRG
	where grp_nf = @prg_nf

    select @erreur = @@error
	if @erreur != 0
	begin
	    raiserror 20001 "APPLICATIF;BTRT..TBOQPRG "
	    goto fin
	end

	/*-------------------------------
	  Recherche du libellé du bouquet
	---------------------------------*/
    select @boq_ll = grpnam_ll
	from BTRT..TBOQPRG
	where grp_nf = @boq_nf

    select @erreur = @@error
    if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;BTRT..TBOQPRG "
        goto fin
    end


    /*---------------------
     Nature de l'affaire
	---------------------*/
    if @nat_cf <  "30"
    begin
        select @ctrnat_ct = "P"
    end     /* traité proportionnel     */
    if @nat_cf >= "30"
    begin
        select @ctrnat_ct  = "N"
    end     /* traité non proportionnel */


    /*----------------------------------
     Recherche du TIMESTAMP GRAPPE
     de l'application TRAITE dans BTEC
    -----------------------------------*/
    execute BTEC..PsLOCKTAB_01 @p_ctr_nf, 'TRAITES',  @TIMESTAMP_GRAPPE OUTPUT

end
/*****************************************************************************************
  FACULTATIVE
*******************************************************************************************/
--if @p_ctr_nf like "__F%" or @p_ctr_nf like "__G%"
--else if exists (select 1 from BFAC..TCONTR where ctr_nf = @p_ctr_nf)										--01 add
else
 begin
    /*------------------------
     Select  BFAC..TSECTION
    --------------------------*/
    select @subnat_cf = subnat_cf,
           @nat_cf = nat_cf,
           @lob_cf = lob_cf,
           @top_cf = top_cf,
           @sob_cf = sob_cf,
           @gar_cf = gar_cf,
           @pcprsktry_cf = pcprsktry_cf,
           @usrcrtval_lm = usrcrtval_lm,
           @ssd_cf = ssd_cf,
           @secsts_ct = secsts_ct,
           @secaccsts_ct = secaccsts_ct,
           @accadmtyp_ct = accadmtyp_ct,
           @secinc_d = secinc_d,
           @seccan_d = seccan_d,
           @frsuwy_nf = frsuwy_nf
    from BFAC..TSECTION
    where ctr_nf = @p_ctr_nf
      and end_nt = @p_end_nt
      and sec_nf = @p_sec_nf
      and uwy_nf = @p_uwy_nf
      and uw_nt  = @p_uw_nt
      and secsts_ct in (16,17,18,19) /* (définitif, renouvelé, expiré, résilié) */

    select @erreur = @@error
	if @erreur != 0
	begin
	    raiserror 20001 "APPLICATIF;BFAC..TSECTION"
	    goto fin
	end

	-- modification 012 start
	if @ssd_cf is null 
	begin
		select @ssd_Cf = ssd_cf 
		from BFAC..TSECTION
		where 	ctr_nf = @p_ctr_nf
				and end_nt = @p_end_nt
				and sec_nf = @p_sec_nf
				and uwy_nf = @p_uwy_nf
				and uw_nt  = @p_uw_nt
	end
	-- modification 012 end
	
	/*-----------------------------------------------------------------
  	Date effet premier exercice :
  	Recherche de la date d'effet de l'exercice le plus ancien de ce
      contrat:section tous exercices confondus en testant l'état de la section.
      select dans BFAC..TCONTR
 	-------------------------------------------------------------------*/
    select @secinc_d   = min(a.ctrinc_d)
    from BFAC..TCONTR a, BFAC..TSECTION b
    where a.ctr_nf = @p_ctr_nf
      and a.end_nt = @p_end_nt
      and b.sec_nf = @p_sec_nf
      and a.ctr_nf = b.ctr_nf
      and a.end_nt = b.end_nt
      and a.uw_nt = b.uw_nt
      and a.uwy_nf = b.uwy_nf
      and secsts_ct in (16,17,18,19) /* (définitif, renouvelé, expiré, résilié) */

    select @erreur = @@error
    if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;BFAC..TSECTION"
        goto fin
    end

    /*-------------------------------------------------------------------------
      Date d'échéance dernier exercice :
      	Recherche de la date d'échéance de l'exercice le plus récent de ce
          contrat/section tous exercices confondus en testant l'état de la section.
          select dans BFAC..TCONTR
    --------------------------------------------------------------------------*/
    select @seccan_d = max(a.ctrexp_d)
    from BFAC..TCONTR a, BFAC..TSECTION b
    where a.ctr_nf = @p_ctr_nf
      and a.end_nt = @p_end_nt
      and b.sec_nf = @p_sec_nf
      and a.ctr_nf = b.ctr_nf
      and a.end_nt = b.end_nt
      and a.uw_nt = b.uw_nt
      and a.uwy_nf = b.uwy_nf
      and secsts_ct in (16,17,18,19) /* (définitif, renouvelé, expiré, résilié) */

    select @erreur = @@error
    if @erreur != 0
    begin
        raiserror 20001 '20001 APPLICATIF;BFAC..TCONTR;'
        goto fin
    end


    /*--------------------------
      select de BFAC..TFAMLIA
    ----------------------------*/
    select @egpcur_cf      = egpcur_cf,
           @aliment_revise = scogloegp_m
    from BFAC..TFAMLIA
    where ctr_nf = @p_ctr_nf
      and end_nt = @p_end_nt
      and sec_nf = @p_sec_nf
      and uwy_nf = @p_uwy_nf
      and uw_nt  = @p_uw_nt

    select @erreur = @@error
    if @erreur != 0
    begin
        raiserror 20001 '20001 APPLICATIF;BFAC..TFAMLIA;'
        goto fin
    end

    /*---------------------------------
      select de BFAC..TCONTR
           bandeau (FACULTATIVE)
     ---------------------------------*/
    select @prg_nf         = prg_nf,
           @boq_nf         = boq_nf,
           @ctrpcpnam_ll   = ctrpcpnam_ll,
           @ced_nf         = ced_nf,
           @ctrsts_ct      = ctrsts_ct,
           @ctrinc_d       = ctrinc_d,
           @accesb_cf    = accesb_cf
    from BFAC..TCONTR
    where ctr_nf = @p_ctr_nf
      and end_nt = @p_end_nt
      and uw_nt  = @p_uw_nt
      and uwy_nf = @p_uwy_nf

    select @erreur = @@error
    if @erreur != 0
    begin
        raiserror 20001 '20001 APPLICATIF;BFAC..TCONTR;'
        goto fin
    end

    /*---------------------
     Nature de l'affaire
    ---------------------*/
    select @ctrnat_ct = "F"     /* facultative	*/

end


/*--------------------------------------
Select : BEST..TUNDSTA --> variables
--------------------------------------*/
select @caccprm_m    = caccprm_m,
       @caccclm_m    = caccclm_m,
       @caccloa_m    = caccloa_m,
       @accprm_m     = accprm_m,
       @accclm_m     = accclm_m,
       @caccupr_m    = caccupr_m,
       @caccacr_m    = caccacr_m,
       @caccupr_m    = caccupr_m,
       @accacr_m    = accacr_m,
       @acy_nf       = acy_nf,
       @scoendmth_nf = scoendmth_nf
from TUNDSTA
where ctr_nf = @p_ctr_nf
  and end_nt = @p_end_nt
  and sec_nf = @p_sec_nf
  and uwy_nf = @p_uwy_nf
  and uw_nt  = @p_uw_nt

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20001 "APPLICATIF;BEST..TUNDSTA "
    goto fin
end


/*-------------------------------
  Recherche du libellé cédante
  BCLI..TCLIENT
---------------------------------*/
select @ced_ld = clishonam_ld
from BCLI..TCLIENT
where cli_nf = @ced_nf

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20001 "APPLICATIF;BCLI..TCLIENT "
    goto fin
end

/*-------------------------------
  Recherche du status du contrat
  BREF..TBANTECL
---------------------------------*/
select @ctrsts_ls = colval_ls
from BREF..TBANTECL
where col_ls    = "CTRSTS_CT"
  and lag_cf    = @p_lag_cf
  and colval_ct = convert(char(5),@ctrsts_ct)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20001 "APPLICATIF;BREF..TBANTECL "
    goto fin
end

/*------------------------------------
  Recherche du libellé type comptable
  BREF..TBANTECL
-------------------------------------*/
select @accadmtyp_lm = colval_lm
from BREF..TBANTECL
where col_ls    = "ACCADMTYP_CT"
  and lag_cf    = @p_lag_cf
  and colval_ct = convert(char(5),@accadmtyp_ct)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20001 "APPLICATIF;BREF..TBANTECL "
    goto fin
end

/*-------------------------------
  Recherche du libellé territorialité ou marché du contrat
  BREF..TCTYSUPL
---------------------------------*/
select @ctysup_ls = ctysup_ls
from BREF..TCTYSUPL
where ctysup_cf = @pcprsktry_cf
 and lag_cf     = @p_lag_cf

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20001 "APPLICATIF;BREF..TCTYSUPL "
    goto fin
end

/*-------------------------------
  Recherche du la dernière période de copte reçu
  BCTA..TAPR
---------------------------------*/
select distinct	@maxacy_nf = acy_nf,
                @maxscoendmth_nf= scoendmth_nf
from bcta..tapr
where ctr_nf = @p_ctr_nf
  and  ety_d <> ''
group by ctr_nf
having 100 * acy_nf + scoendmth_nf = max(100 * acy_nf + scoendmth_nf)
--[009]order by ctr_nf


/*-----------------
 Select final
-----------------*/
select @p_ctr_nf                    ctr_nf,
       @p_end_nt                    end_nt,
       @p_sec_nf                    sec_nf,
       @p_uwy_nf                    uwy_nf,
       @p_uw_nt	                    uw_nt,
       @accadmtyp_ct                accadmtyp_ct,
       @accadmtyp_lm                accadmtyp_lm,
       @egpcur_cf                   egpcur_cf,
       @secinc_d                    secinc_d,
       @seccan_d                    seccan_d,
       isnull(@caccprm_m,0)		    caccprm_m,
       isnull(@caccclm_m ,0)        caccclm_m,
       isnull(@caccloa_m,0)         caccloa_m,
       isnull(@caccupr_m,0)         caccupr_m,
       isnull(@caccacr_m,0)         caccacr_m,
       isnull(@accacr_m,0)          accacr_m,
       isnull(@RP,0)                RP,
       @acy_nf                      acy_nf,
       @scoendmth_nf                scoendmth_nf,
       isnull(@accprm_m,0)          accprm_m,
       isnull(@accclm_m,0)          accclm_m,

       @subnat_cf                   subnat_cf,
       @nat_cf                      nat_cf,
       @lob_cf                      lob_cf,
       @top_cf                      top_cf,
       @sob_cf                      sob_cf,
       @gar_cf                      gar_cf,
       @pcprsktry_cf                pcprsktry_cf,
       @ctysup_ls                   ctysup_ls,
       @usrcrtval_lm                usrcrtval_lm,
       @ssd_cf                      ssd_cf,
       @secsts_ct                   secsts_ct,
       @secaccsts_ct                secaccsts_ct,
       @accesb_cf                   accesb_cf,
       @prg_nf                      prg_nf,
       @prg_ll                      prg_ll,
       @boq_nf                      boq_nf,
       @boq_ll                      boq_ll,
       @ctrpcpnam_ll                ctrpcpnam_ll,
       @ced_nf                      ced_nf,
       @ced_ld                      ced_ld,
       @ctrsts_ct                   ctrsts_ct,
       @ctrsts_ls                   ctrsts_ls,
       @scoinc_d                    scoinc_d,
       @ctrinc_d                    ctrinc_d,
       @frsuwy_nf                   frsuwy_nf,

       @ctrnat_ct                   ctrnat_ct,
       IsNull(@aliment_revise,0)    aliment_revise,
       IsNull(@scoorgegp_m,0)       scoorgegp_m,
       @scogloegp_m                 scogloegp_m,  /* Modif 6 */
       IsNull(@pmlrat_r,0)          pmlrat_r,
       IsNull(@ridsha_r,0)          ridsha_r,
       @scoegpcal_b                 scoegpcal_b,
       @egplessco_m                 egplessco_m,  /* Modif 4 */
       /*IsNull(@egplessco_m,0)	    egplessco_m,     Modif 4 */
       IsNull(@cutsha_r,0)          cutsha_r,
       @liaridsha_b                 liaridsha_b,
       @reiexi_b                    reiexi_b,
       @reiunl_b                    reiunl_b,
       @reifre_b                    reifre_b,
       @reinbr_n                    reinbr_n,
       IsNull(@laycap_m,0)          laycap_m,
       @liacur_cf                   liacur_cf,
       @estend_b                    estend_b,
       @maxacy_nf                   maxacy_nf,
       @maxscoendmth_nf             maxscoendmth_nf,
       @TIMESTAMP_GRAPPE            timestamp_grappe


fin:
return @erreur
go
EXEC sp_procxmode 'dbo.PsUNDSTA_10_O2', 'unchained'
go
IF OBJECT_ID('dbo.PsUNDSTA_10_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsUNDSTA_10_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsUNDSTA_10_O2 >>>'
go
GRANT EXECUTE ON dbo.PsUNDSTA_10_O2 TO GOMEGA
go
