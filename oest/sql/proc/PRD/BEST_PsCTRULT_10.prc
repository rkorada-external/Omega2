USE BEST
Go

/*
 * DROP PROC dbo.PsCTRULT_10
 */

IF OBJECT_ID('dbo.PsCTRULT_10') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCTRULT_10
    PRINT '<<< DROPPED PROC dbo.PsCTRULT_10 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsCTRULT_10
     (
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF
     )
as

/***************************************************

Programme: PsCTRULT_10

Fichier script associé : ESSCTR10.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:

	- Création tables temporaires

	- Si ctr_nf = "__T%" ou ctr_nf = "__Z% "
		- Insert/Select : BTRT..TSECTION  --> #Liste
  		- Delete de BTRT..TCONTR --> #liste
		- Update de BTRT..TFAMLIA --> #liste

	- Si ctr_nf = "__F%" ou ctr_nf = "__G%"
		- Insert/Select : BFAC..TSECTION  --> #Liste
		- Delete de BFAC..TCONTR --> #liste
		- Update de BFAC..TFAMLIA --> #liste

	- Insert/select : BEST..TCTRULT --> #ctrult
	- Update de #ctrult --> #liste

	- Insert/select : BEST..TUNDSTA --> #undsta
	- Update de #undsta --> #liste

	- Select final
	- Suppression des tables temporaires


Parametres:
       @p_ctr_nf              UCTR_NF,      : Contrat
       @p_end_nt              UEND_NT,      : Avenant
       @p_sec_nf              USEC_NF,      : Section



Conditions d'execution:


Commentaires:


_________________
MODIFICATION 1

Auteur: L.DEBEVER

Date: 26/01/1998

Version:

Description: Condition pour déterminer si un contrat est
	      un Traité :
	        IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z% or @p_ctr_nf like "__U%" or @p_ctr_nf like "__W%",
	      au lieu de :
		 IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%"
	      Il existe des traités de type "__U%" et "__W%"

_________________
MODIFICATION 2

Auteur: L.DEBEVER

Date: 04/11/1998

Version:

Description: Lors de la maj de #liste à partir de #undsta,
		 rajout de la jointure sur uw_nt (manquante)

_________________
MODIFICATION 3
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs

*****************************************************/

declare @erreur     int

/* -----------------------------
Création tables temporaires
----------------------------- */

create table #liste (
				ctr_nf             UCTR_NF        NULL,
				end_nt             UEND_NT        NULL,
				sec_nf             USEC_NF        NULL,
				uwy_nf             UUWY_NF        NULL,
				uw_nt              UUW_NT         NULL,
				egpcur_cf          UCUR_CF        NULL,
				secaccsts_ct       UACCSTS_CT     NULL,
				caccprm_m          UAMT_M         NULL,
				caccclm_m          UAMT_M         NULL,
				caccloa_m          UAMT_M         NULL,
				caccupr_m          UAMT_M	      NULL,
   				caccacr_m          UAMT_M	      NULL,
				stat_RP            UAMT_M         NULL,
				accprm_m           UAMT_M         NULL,
				retamtprm_m        UAMT_M         NULL,
				resprm_m           UAMT_M         NULL,
				retamtclm_m        UAMT_M         NULL,
				nat_cf             UCTRNAT_CF     NULL,
				acy_nf      		smallint    	   NULL,
    				scoendmth_nf 	tinyint        NULL
             	  )


create table #ctrult (
				ctr_nf     		UCTR_NF     NULL,
				end_nt             UEND_NT     NULL,
				sec_nf             USEC_NF     NULL,
				uwy_nf             UUWY_NF     NULL,
				uw_nt              UUW_NT      NULL,
				retamtprm_m        UAMT_M      NULL,
				resprm_m      	UAMT_M      NULL,
				retamtclm_m        UAMT_M      NULL
                     )

create table #undsta (
				ctr_nf             UCTR_NF     NULL,
				end_nt             UEND_NT     NULL,
				sec_nf             USEC_NF     NULL,
				uwy_nf          	UUWY_NF     NULL,
				uw_nt              UUW_NT      NULL,
				caccprm_m          UAMT_M      NULL,
				caccclm_m          UAMT_M      NULL,
				caccloa_m          UAMT_M      NULL,
				accprm_m           UAMT_M      NULL,
				caccupr_m          UAMT_M	   NULL,
   				caccacr_m          UAMT_M	   NULL,
				acy_nf      		smallint    NULL,
    				scoendmth_nf 	tinyint     NULL
                     )


/* Modification 1 :                                          */
/*IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%" */
IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%" or @p_ctr_nf like "__U%" or @p_ctr_nf like "__W%"
begin

	/*----------------------------------------------------
	 Insert/Select : BTRT..TSECTION  --> #Liste
	 -----------------------------------------------------*/
	  insert into #liste
	  select 	ctr_nf,
	        	end_nt,
	    		sec_nf,
			uwy_nf,
			uw_nt,
			NULL,
			secaccsts_ct,
			0,
			0,
			0,
        		0,
			0,
			0,
			0,
			0,
			0,
			0,
			nat_cf,
			NULL,
			NULL
	  from BTRT..TSECTION
	 where ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt
         and sec_nf = @p_sec_nf
         and secsts_ct in (14,16,17,18,19) /* (accepté, définitif, renouvelé, expiré, résilié) */

	select @erreur = @@error
	if @erreur != 0 begin raiserror 20001 "APPLICATIF;BTRT..TSECTION -> #liste" goto fin end

	/*----------------------------------
	  Delete de BTRT..TCONTR --> #liste
	  suppression des contrats/exercices
        qui sont invalide "ctrlck_b=1"
	 -----------------------------------*/
	  Delete #liste
          from #liste a, BTRT..TCONTR b
         where a.ctr_nf = b.ctr_nf
           and a.end_nt = b.end_nt
           and a.uwy_nf = b.uwy_nf
           and a.uw_nt  = b.uw_nt
	     and b.ctrlck_b = 1

	  select @erreur = @@error
	  if @erreur != 0 begin raiserror 20003 '20003 APPLICATIF;BTRT..TCONTR -> #liste;' goto fin end


	 /*----------------------------------
	  Update de BTRT..TFAMLIA --> #liste
	  recherche de la monnaie
	 -----------------------------------*/
	  update #liste
	     set a.egpcur_cf = b.egpcur_cf
          from #liste a, BTRT..TFAMLIA b
         where a.ctr_nf = b.ctr_nf
           and a.end_nt = b.end_nt
           and a.sec_nf = b.sec_nf
           and a.uwy_nf = b.uwy_nf
           and a.uw_nt  = b.uw_nt

	  select @erreur = @@error
	  if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;BTRT..TFAMLIA -> #liste;' goto fin end

end

IF @p_ctr_nf like "__F%" or @p_ctr_nf like "__G%"
begin
	/*----------------------------------------------------
	 Insert/Select : BFAC..TSECTION  --> #Liste
	-----------------------------------------------------*/
	  insert into #liste
	  select 	ctr_nf,
			end_nt,
			sec_nf,
			uwy_nf,
			uw_nt,
			NULL,
			secaccsts_ct,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			nat_cf,
			NULL,
			NULL
	  from BFAC..TSECTION
       where ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt
         and sec_nf = @p_sec_nf
         and secsts_ct in (16,17,18,19) /* (définitif, renouvelé, expiré, résilié) */

   	select @erreur = @@error
   	if @erreur != 0 begin raiserror 20001 "APPLICATIF;BFAC..TSECTION -> #liste" goto fin end


	/*----------------------------------
	  Delete de BFAC..TCONTR --> #liste
	  suppression des contrats/exercices
        qui sont invalide "ctrlck_b<>1"
	 -----------------------------------*/
	  Delete #liste
          from #liste a, BFAC..TCONTR b
         where a.ctr_nf = b.ctr_nf
           and a.end_nt = b.end_nt
           and a.uwy_nf = b.uwy_nf
           and a.uw_nt  = b.uw_nt
	     and b.ctrlck_b <> 1

	  select @erreur = @@error
	  if @erreur != 0 begin raiserror 20003 '20003 APPLICATIF;BFAC..TCONTR -> #liste;' goto fin end


	 /*---------------------------------
	  Update de BFAC..TFAMLIA --> #liste
	  recherche de la monnaie
	 ----------------------------------*/
	  update #liste
     	     set a.egpcur_cf = b.egpcur_cf
          from #liste a, BFAC..TFAMLIA b
         where a.ctr_nf = b.ctr_nf
           and a.end_nt = b.end_nt
           and a.sec_nf = b.sec_nf
           and a.uwy_nf = b.uwy_nf
           and a.uw_nt  = b.uw_nt

 	  select @erreur = @@error
	  if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;BFAC..TFAMLIA -> #liste;' goto fin end

end

/*------------------------------------------
Insert/select : BEST..TCTRULT --> #ctrult
recherche des montants ultimes souscription
------------------------------------------*/
insert into #ctrult
select ctr_nf,
  end_nt,
       sec_nf,
       uwy_nf,
       uw_nt,
       isnull(retamtprm_m,0),
       isnull(resprm_m ,0),
       isnull(retamtclm_m,0)
  from TCTRULT
 where ctr_nf = @p_ctr_nf
   and end_nt = @p_end_nt
   and sec_nf = @p_sec_nf
 group by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt
 having cre_d = max(cre_d)
 order by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt

select @erreur = @@error
if @erreur != 0 begin raiserror 20001 "APPLICATIF;BEST..TCTRULT -> #ctrult" goto fin end


/*---------------------------
 Update de #ctrult --> #liste
----------------------------*/
update #liste
   set a.retamtprm_m   = b.retamtprm_m,
	 a.resprm_m      = b.resprm_m,
	 a.retamtclm_m   = b.retamtclm_m
  from #liste a, #ctrult b
 where a.ctr_nf = b.ctr_nf
   and a.end_nt = b.end_nt
   and a.sec_nf = b.sec_nf
   and a.uwy_nf = b.uwy_nf

select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;#ctrult->#liste;' goto fin end


/*--------------------------------------
Insert/select : BEST..TUNDSTA --> #undsta
--------------------------------------*/
insert into #undsta
select ctr_nf,
       end_nt,
       sec_nf,
       uwy_nf,
       uw_nt,
       isnull(caccprm_m,0),
       isnull(caccclm_m ,0),
       isnull(caccloa_m,0),
       isnull(accprm_m,0),
	isnull(caccupr_m,0),
       isnull(caccacr_m ,0),
	 acy_nf,
    	 scoendmth_nf
  from TUNDSTA
 where ctr_nf = @p_ctr_nf
   and end_nt = @p_end_nt
   and sec_nf = @p_sec_nf
 group by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt
 order by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt

select @erreur = @@error
if @erreur != 0 begin raiserror 20001 "APPLICATIF;BEST..TUNDSTA -> #undsta " goto fin end



/*---------------------------
 Update de #undsta --> #liste
----------------------------*/
/* Modif 2 : rajout jointure sur 'uw_nt' */
update #liste
   set a.caccprm_m = b.caccprm_m,
       a.caccclm_m  = b.caccclm_m ,
       a.caccloa_m = b.caccloa_m,
       a.accprm_m = b.accprm_m,
	 a.caccupr_m = b.caccupr_m,
	 a.caccacr_m = b.caccacr_m,
	 a.acy_nf = b.acy_nf,
	 a.scoendmth_nf = b.scoendmth_nf
  from #liste a, #undsta b
 where a.ctr_nf = b.ctr_nf
   and a.end_nt = b.end_nt
   and a.sec_nf = b.sec_nf
   and a.uwy_nf = b.uwy_nf
   and a.uw_nt = b.uw_nt

select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;#undsta ->#liste;' goto fin end


/*-----------------
 Select final
-----------------*/
select * from #liste

select @erreur = @@error
if @erreur != 0 begin raiserror 20005 '20005 APPLICATIF;#liste;' goto fin end

/* --------------------------------
Suppression des tables temporaires
----------------------------------*/
fin:
drop table #liste
drop table #ctrult
drop table #undsta


return @erreur
go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSCTR10', 'PsCTRULT_10', 'BEST', 'ME34'
go
IF OBJECT_ID('dbo.PsCTRULT_10') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCTRULT_10 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCTRULT_10 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCTRULT_10
 */
GRANT EXECUTE ON dbo.PsCTRULT_10 TO GOMEGA
go

