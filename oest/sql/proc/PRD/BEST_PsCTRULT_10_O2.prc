USE BEST
go
IF OBJECT_ID('dbo.PsCTRULT_10_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsCTRULT_10_O2
    IF OBJECT_ID('dbo.PsCTRULT_10_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsCTRULT_10_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsCTRULT_10_O2 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PsCTRULT_10_O2
     (
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF,
       @facB                  int,
	   @p_uwy_nf			 UUWY_NF
     )
as

/***************************************************

Programme: PsCTRULT_10_O2

Fichier script associé : ESSCTR10.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:

	- Création tables temporaires

	- IF TREATY
		- Insert/Select : BTRT..TSECTION  --> #Liste
  		- Delete de BTRT..TCONTR --> #liste
		- Update de BTRT..TFAMLIA --> #liste

	- IF FACULTATIVE
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
       @facB                  int,           : Contract indicator
	   @p_uwy_nf			 UUWY_NF



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
    
_________________
MODIFICATION 4

Auteur: M.POINT

Date: 07/09/2012

Version:

Description: MODIFICATION 1 not used anymore --> Contract indicator given as parameter

_________________
MODIFICATION 4

Auteur: Gaurav P.

Date: 01/21/2016

Version:

Description: Done for defect 21422, add condition for SEC_NF is null

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

/*modif	4		 */
create table #sectiontmp(
sec_nf USEC_NF     NULL
)					 

IF @facB = 0
begin
	IF @p_sec_nf <> NULL
	begin
		INSERT INTO #sectiontmp
		SELECT DISTINCT SEC_NF FROM BTRT..TSECTION A 
			INNER JOIN BREF..TBANTECL B ON
			 CONVERT (TINYINT, B.COLVAL_CT) = A.SECSTS_CT AND
					  COL_LS = 'CTRSTS_CT' AND LAG_CF = 'E'
					WHERE CTR_NF = @p_ctr_nf AND SEC_NF = @p_sec_nf
	end
	ELSE IF @p_uwy_nf <> NULL
	begin
		INSERT INTO #sectiontmp
		SELECT SEC_NF FROM BTRT..TSECTION A 
			INNER JOIN BREF..TBANTECL B ON
			 CONVERT (TINYINT, B.COLVAL_CT) = A.SECSTS_CT AND
					  COL_LS = 'CTRSTS_CT' AND LAG_CF = 'E'
					WHERE CTR_NF = @p_ctr_nf AND UWY_NF = @p_uwy_nf
	end
	else
	begin
		INSERT INTO #sectiontmp
		SELECT DISTINCT SEC_NF FROM BTRT..TSECTION A 
			INNER JOIN BREF..TBANTECL B ON
			 CONVERT (TINYINT, B.COLVAL_CT) = A.SECSTS_CT AND
					  COL_LS = 'CTRSTS_CT' AND LAG_CF = 'E'
					WHERE CTR_NF = @p_ctr_nf

	end
end
ELSE IF @facB = 1
begin
	IF @p_sec_nf <> NULL
	begin
		INSERT INTO #sectiontmp
		SELECT DISTINCT SEC_NF FROM BFAC..TSECTION A 
			INNER JOIN BREF..TBANTECL B ON
			 CONVERT (TINYINT, B.COLVAL_CT) = A.SECSTS_CT AND
					  COL_LS = 'CTRSTS_CT' AND LAG_CF = 'E'
					WHERE CTR_NF = @p_ctr_nf AND SEC_NF = @p_sec_nf
	end
	ELSE IF @p_uwy_nf <> NULL
	begin
		INSERT INTO #sectiontmp
		SELECT SEC_NF FROM BFAC..TSECTION A 
			INNER JOIN BREF..TBANTECL B ON
			 CONVERT (TINYINT, B.COLVAL_CT) = A.SECSTS_CT AND
					  COL_LS = 'CTRSTS_CT' AND LAG_CF = 'E'
					WHERE CTR_NF = @p_ctr_nf AND UWY_NF = @p_uwy_nf
	end
	else
	begin
		INSERT INTO #sectiontmp
		SELECT DISTINCT SEC_NF FROM BFAC..TSECTION A 
			INNER JOIN BREF..TBANTECL B ON
			 CONVERT (TINYINT, B.COLVAL_CT) = A.SECSTS_CT AND
					  COL_LS = 'CTRSTS_CT' AND LAG_CF = 'E'
					WHERE CTR_NF = @p_ctr_nf

	end
end
/*modif	4		 */


/* Modification 1 :                                          */
/*IF @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%" */
/* Modif 4 : testing facB. If facB = 0 --> selecting Treaties */
IF @facB = 0
begin

	/*----------------------------------------------------
	 Insert/Select : BTRT..TSECTION  --> #Liste
	 -----------------------------------------------------*/
	 IF  @p_uwy_nf IS NOT NULL	--modif 4
	 BEGIN
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
		 and uwy_nf = @p_uwy_nf
         and secsts_ct in (14,16,17,18,19) /* (accepté, définitif, renouvelé, expiré, résilié) */
		 and sec_nf in (SELECT sec_nf FROM #sectiontmp)	--modif 4
	end	 
	ELSE		--modif 4
	begin
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
         and secsts_ct in (14,16,17,18,19) /* (accepté, définitif, renouvelé, expiré, résilié) */
		 and sec_nf in (SELECT sec_nf FROM #sectiontmp)	--modif 4
		 						   
	END
	
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
/* Modif 4 : testing facB. If facB = 1 --> selecting facultatives */
IF @facB = 1
begin
	/*----------------------------------------------------
	 Insert/Select : BFAC..TSECTION  --> #Liste
	-----------------------------------------------------*/
	IF  @p_uwy_nf IS NOT NULL		--modif 4
	 BEGIN
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
		 and uwy_nf = @p_uwy_nf
         and secsts_ct in (16,17,18,19) /* (définitif, renouvelé, expiré, résilié) */
		 and sec_nf in (SELECT sec_nf FROM #sectiontmp)	--modif 4
	end
	ELSE			--modif 4
	BEGIN
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
         and secsts_ct in (16,17,18,19) /* (définitif, renouvelé, expiré, résilié) */
		 and sec_nf in (SELECT sec_nf FROM #sectiontmp)	--modif 4
	END

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
IF  @p_uwy_nf IS NOT NULL		--modif 4
	 BEGIN
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
		   and sec_nf in (SELECT sec_nf FROM #sectiontmp)	--modif 4
		   and uwy_nf = @p_uwy_nf
		 group by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt
		 having cre_d = max(cre_d)
		 order by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt
 END
 ELSE			--modif 4
 BEGIN
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
			   and sec_nf in (SELECT sec_nf FROM #sectiontmp)	--modif 4
			 group by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt
			 having cre_d = max(cre_d)
			 order by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt
 END

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
IF  @p_uwy_nf IS NOT NULL			--modif 4
	 BEGIN
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
		   and sec_nf in (SELECT sec_nf FROM #sectiontmp)	--modif 4
		   and uwy_nf = @p_uwy_nf
		 group by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt
		 order by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt
	END
	ELSE 			--modif 4
	BEGIN
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
		   and sec_nf in (SELECT sec_nf FROM #sectiontmp)	--modif 4
		 group by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt
		 order by ctr_nf,end_nt, sec_nf, uwy_nf, uw_nt
	END

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
/* Adaptive Server has expanded all '*' elements in the following statement */ select #liste.ctr_nf, #liste.end_nt, #liste.sec_nf, #liste.uwy_nf, #liste.uw_nt, #liste.egpcur_cf, #liste.secaccsts_ct, #liste.caccprm_m, #liste.caccclm_m, #liste.caccloa_m, #liste.caccupr_m, #liste.caccacr_m, #liste.stat_RP, #liste.accprm_m, #liste.retamtprm_m, #liste.resprm_m, #liste.retamtclm_m, #liste.nat_cf, #liste.acy_nf, #liste.scoendmth_nf from #liste order by #liste.uwy_nf DESC, #liste.uw_nt DESC

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
EXEC sp_procxmode 'dbo.PsCTRULT_10_O2', 'unchained'
go
IF OBJECT_ID('dbo.PsCTRULT_10_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsCTRULT_10_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsCTRULT_10_O2 >>>'
go
GRANT EXECUTE ON dbo.PsCTRULT_10_O2 TO GOMEGA
go
