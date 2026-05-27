use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsLIFEST_03
*/

IF OBJECT_ID('dbo.PsLIFEST_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsLIFEST_03
   PRINT '<<< DROPPED PROC dbo.PsLIFEST_03 >>>'
END
go

/*
 * creation de la procedure
*/
create procedure PsLIFEST_03 (
                @p_end_nt       UEND_NT,
                @p_sec_nf       USEC_NF,
                @p_uw_nt        UUW_NT,
                @p_uwy_nf       UUWY_NF,
                @p_ssd_cf       USSD_CF,
                @p_visu_mois	tinyint,
                @p_visu_an  	smallint,
                @p_poste1       smallint,
                @p_poste2       smallint,
                @p_ctr_nf       UCTR_NF)
as

/***************************************************

Programme: PsLIFEST_03

Fichier script associé : ESSLIF03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: L.DEBEVER (ME01) avec Infotool version 2.0

Date de creation: 11 Avril 1997

Description du programme:

 	ESTIMATIONS VIE Acceptation et Rétro :
	Sélection dans TLIFEST des estimations d'un contrat de type comptable 1 ou 4
	(année de compte = exercice), ceci pour un exercice donné.

Parametres:

       @p_end_nt        UEND_NT,
       @p_sec_nf        USEC_NF,
       @p_uw_nt         UUW_NT,
       @p_uwy_nf        UUWY_NF,
       @p_ssd_cf  		USSD_CF,
	   @p_visu_mois		tinyint,
	   @p_visu_an  		smallint,
	   @p_poste1        smallint,
	   @p_poste2        smallint,
 	   @p_ctr_nf        UCTR_NF


Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER

Date: 28/03/2000

Version:

Description: de TACMTRSH, on ne ramène que PRS_CF = 500

_________________
MODIFICATION 2

Auteur: G.BUISSON

Date:   09/07/2003

Version:

Description: Modification des criteres de selection sur TLIFEST.
             du max (CRE_D) on prend maintenant le max de annee bilan + mois
             bilan + annee de CRE_D + mois de CRE_D + jour de CRE_D +
             heure de CRE_D

*****************************************************/

declare @erreur int,
	    @acy_nf_1 smallint,  	/* années de compte : bilan - 4 -> bilan + 2 */
	    @acy_nf_2 smallint,
	    @acy_nf_3 smallint,
	    @acy_nf_4 smallint,
	    @acy_nf_5 smallint,
	    @acy_nf_6 smallint,
	    @acy_nf_7 smallint,
	    @cre_d    UUPD_D,
       @lob_cf   tinyint

/*--------------------------------------------------*/
/* Création tables temporaire                       */
/*--------------------------------------------------*/

/* Liste des montants cumulés par années de compte, */
/* code traitement (prs_cf) et poste cumul          */
/* (acmtrc_nt); libellés code + poste; position     */

Create table #liste (
            CRE_D        UUPD_D,
            PRS_CF       smallint,
            ACMTRS_NT    smallint,
            POSITION     smallint NULL,
            ACMTRS_LL    UL64 NULL,
            ESTMNT_M1    UAMT_M NULL,
            ESTMNT_M2    UAMT_M NULL,
            ESTMNT_M3    UAMT_M NULL,
            ESTMNT_M4    UAMT_M NULL,
            ESTMNT_M5    UAMT_M NULL,
            ESTMNT_M6    UAMT_M NULL,
            ESTMNT_M7    UAMT_M NULL,
            COMACC_B1        bit,
            COMACC_B2        bit,
            COMACC_B3        bit,
            COMACC_B4        bit,
            COMACC_B5        bit,
            COMACC_B6        bit,
            COMACC_B7        bit,
            AUTUPD_B1        bit,
            AUTUPD_B2        bit,
            AUTUPD_B3        bit,
            AUTUPD_B4        bit,
            AUTUPD_B5        bit,
            AUTUPD_B6        bit,
            AUTUPD_B7        bit,
            CMT_NT1      UCMT_NT,
            CMT_NT2      UCMT_NT,
            CMT_NT3      UCMT_NT,
            CMT_NT4      UCMT_NT,
            CMT_NT5      UCMT_NT,
            CMT_NT6      UCMT_NT,
            CMT_NT7      UCMT_NT)

/* Lifest réduit                                    */

Create table #TLIFEST (
            UWY_NF       UUWY_NF,
            ACMTRS_NT    smallint,
            PRS_CF       smallint,
            ACY_NF       smallint,
            ESTMNT_M     UAMT_M,
            CRE_D        datetime,
            BALSHEY_NF   smallint,
            BALSHTMTH_NF tinyint)

/* Montants estimés                                 */

Create table #montants_w (
            UWY_NF       UUWY_NF,
            ACMTRS_NT    smallint,
            PRS_CF       smallint,
            ACY_NF       smallint,
            ESTMNT_M     UAMT_M )

/* montants cumulés par années de compte,           */
/* code traitement (prs_cf) et poste cumul          */
/* (acmtrc_nt)                                      */
/*Create table #montants
(	 ACMTRS_NT    smallint,
       PRS_CF       smallint,
	 ACY_NF       smallint,
       ESTMNT_M     UAMT_M )*/

/* Lifdri réduit                                      */

Create table #TLIFDRI (
            ACY_NF       smallint,
            AUTUPD_B     bit,
            COMACC_B     bit,
            CMT_NT       UCMT_NT,
            CRE_D        datetime,
            BALSHEY_NF   smallint,
            BALSHTMTH_NF tinyint)

/* Arrêté statistique                                 */

Create table #stat (
            ACY_NF       smallint,
            AUTUPD_B     bit,
            COMACC_B     bit,
            CMT_NT       UCMT_NT)

/* Rechercher la LOB de la section */
select @lob_cf = 0

SELECT   distinct @lob_cf = convert(tinyint,LOB_CF)
  FROM   BTRT..TSECTION
 WHERE   CTR_NF   = @p_ctr_nf
   AND   SEC_Nf   = @p_sec_nf
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;BTRT_TSECTION"
        return @erreur
        goto fin
    end

If @lob_cf = null OR @lob_cf = 0
begin
   SELECT   distinct @lob_cf = convert(tinyint,LOB_CF)
     FROM   BFAC..TSECTION
    WHERE   CTR_NF   = @p_ctr_nf
      AND   SEC_Nf   = @p_sec_nf
   select @erreur = @@error
   if @erreur != 0
       begin
           raiserror 20001 "APPLICATIF;BFAC_TSECTION"
           return @erreur
           goto fin
       end
END

If @lob_cf = null OR @lob_cf = 0
begin
   SELECT   distinct @lob_cf = convert(tinyint,LOB_CF)
     FROM   BRET..TRETSEC
    WHERE   RETCTR_NF   = @p_ctr_nf
      AND   RETSEC_Nf   = @p_sec_nf
   select @erreur = @@error
   if @erreur != 0
       begin
           raiserror 20001 "APPLICATIF;BRET_TRETSEC"
           return @erreur
           goto fin
       end
END

/*--------------------------------------------------*/
/* Maj codes + libellé dans #liste                  */
/* Modif 1 :On ne ramène que PRS_CF = 500           */
/*--------------------------------------------------*/

Insert into #liste
select  '', H.PRS_CF, H.ACMTRS_NT, R.POSITION_NT, H.ACMTRS_LL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0
from    BREF..TACMTRSH H, TACCPAR R
where   H.PRS_CF    *= R.PRS_CF
and     H.ACMTRS_NT *= R.ACMTRS_NT
and     H.ACMTRS_NT >= @p_poste1
and     H.ACMTRS_NT  < @p_poste2
and     H.SSD_CF     =  @p_ssd_cf
and     H.PRS_CF     = 500
order by R.POSITION_NT

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

/* Filtrer les postes par lob */
delete   #liste
from     BEST..TACCPAR a, #liste b
WHERE    a.acmtrs_nt = b.acmtrs_nt
and      a.LOB_CF != @LOB_CF
and      a.LOB_CF != 0
and      a.LOb_CF != NULL

/* Mettre à jour les libelles si il n'existe pas dans tacmtrsh pour la filiale */
/* On prend le libellé de PARIS (2)                                            */

UPDATE   #liste
SET      acmtrs_ll = b.acmtrs_gl
FROM     #liste         a,
         BREF..TACMTRS b
WHERE    a.acmtrs_nt = b.acmtrs_nt
AND      a.acmtrs_ll = ''


/*--------------------------------------------------*/
/* Calcul années de compte : bilan - 4 -> bilan + 2 */
/*--------------------------------------------------*/

Select @acy_nf_1 = @p_visu_an - 4
Select @acy_nf_2 = @p_visu_an - 3
Select @acy_nf_3 = @p_visu_an - 2
Select @acy_nf_4 = @p_visu_an - 1
Select @acy_nf_5 = @p_visu_an
Select @acy_nf_6 = @p_visu_an + 1
Select @acy_nf_7 = @p_visu_an + 2

/*--------------------------------------------------*/
/* Maj exc souscription, montants dans #montants_w  */
/*--------------------------------------------------*/

/* 1ère partie   */

Insert into #TLIFEST
Select uwy_nf,
       acmtrs_nt,
       prs_cf,
       acy_nf,
       estmnt_m,
       cre_d,
       balshey_nf,
       balshtmth_nf
from   TLIFEST
where  ctr_nf        = @p_ctr_nf
and    end_nt        = @p_end_nt
and    sec_nf        = @p_sec_nf
and    uw_nt         = @p_uw_nt
and    acy_nf       <= @acy_nf_7
and    acy_nf       >= @acy_nf_1
and    balshey_nf    = @p_visu_an
and    balshtmth_nf <= @p_visu_mois

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLIFEST"
        return @erreur
        goto fin
    end

/* 2ème partie   */

Insert into #montants_w
Select A.uwy_nf,
	   A.acmtrs_nt,
	   A.prs_cf,
	   A.acy_nf,
	   A.estmnt_m
from  #TLIFEST A
where convert(char(4), A.balshey_nf) +
      right(convert(char(3),100 + A.balshtmth_nf), 2) +
      convert(char(4),datepart(yy, A.cre_d)) +
      right(convert(char(3),100 + datepart(mm, A.cre_d)), 2) +
      right(convert(char(3),100 + datepart(dd, A.cre_d)), 2) +
      convert(char(9), A.cre_d, 8)                             = (select max(convert(char(4), B.balshey_nf) +
                                                                  right(convert(char(3),100 + B.balshtmth_nf), 2) +
                                                                  convert(char(4),datepart(yy, B.cre_d)) +
                                                                  right(convert(char(3),100 + datepart(mm, B.cre_d)), 2) +
                                                                  right(convert(char(3),100 + datepart(dd, B.cre_d)), 2) +
                                                                  convert(char(9), B.cre_d, 8))
                                                                  from  #TLIFEST B
     					                                          where B.prs_cf    = A.prs_cf
					                                              and   B.acmtrs_nt = A.acmtrs_nt
					                                              and   B.acy_nf    = A.acy_nf)

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#montants_w"
        return @erreur
        goto fin
    end



update #liste
set    ESTMNT_M1 = M.ESTMNT_M
from   #liste L, #montants_w M
where  L.PRS_CF    = M.PRS_CF
and    L.ACMTRS_NT = M.ACMTRS_NT
and    M.ACY_NF    = @acy_nf_1

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    ESTMNT_M2 = M.ESTMNT_M
from   #liste L, #montants_w M
where  L.PRS_CF    = M.PRS_CF
and    L.ACMTRS_NT = M.ACMTRS_NT
and    M.ACY_NF    = @acy_nf_2

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    ESTMNT_M3 = M.ESTMNT_M
from   #liste L, #montants_w M
where  L.PRS_CF    = M.PRS_CF
and    L.ACMTRS_NT = M.ACMTRS_NT
and    M.ACY_NF    = @acy_nf_3

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    ESTMNT_M4 = M.ESTMNT_M
from   #liste L, #montants_w M
where  L.PRS_CF    = M.PRS_CF
and    L.ACMTRS_NT = M.ACMTRS_NT
and    M.ACY_NF    = @acy_nf_4

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    ESTMNT_M5 = M.ESTMNT_M
from   #liste L, #montants_w M
where  L.PRS_CF    = M.PRS_CF
and    L.ACMTRS_NT = M.ACMTRS_NT
and    M.ACY_NF    = @acy_nf_5

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    ESTMNT_M6 = M.ESTMNT_M
from   #liste L, #montants_w M
where  L.PRS_CF    = M.PRS_CF
and    L.ACMTRS_NT = M.ACMTRS_NT
and    M.ACY_NF    = @acy_nf_6

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    ESTMNT_M7 = M.ESTMNT_M
from   #liste L, #montants_w M
where  L.PRS_CF    = M.PRS_CF
and    L.ACMTRS_NT = M.ACMTRS_NT
and    M.ACY_NF    = @acy_nf_7

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

/*--------------------------------------------------*/
/* Maj arrêté stat dans #stat, puis dans #liste     */
/*--------------------------------------------------*/

/* 1ère partie   */

Insert into #TLIFDRI
Select acy_nf,
       autupd_b,
       comacc_b,
       cmt_nt,
       cre_d,
       balshey_nf,
       balshtmth_nf
from   TLIFDRI
where  ctr_nf        = @p_ctr_nf
and    end_nt        = @p_end_nt
and    sec_nf        = @p_sec_nf
and    uw_nt         = @p_uw_nt
and    acy_nf       <= @acy_nf_7
and    acy_nf       >= @acy_nf_1
and    balshey_nf    = @p_visu_an
and    balshtmth_nf <= @p_visu_mois

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLIFDRI"
        return @erreur
        goto fin
    end

/* 2ème partie   */

Insert into #stat
Select  A.acy_nf,
        A.autupd_b,
        A.comacc_b,
        A.cmt_nt
from  #TLIFDRI A
where convert(char(4), A.balshey_nf) +
      right(convert(char(3),100 + A.balshtmth_nf), 2) +
      convert(char(4),datepart(yy, A.cre_d)) +
      right(convert(char(3),100 + datepart(mm, A.cre_d)), 2) +
      right(convert(char(3),100 + datepart(dd, A.cre_d)), 2) +
      convert(char(9), A.cre_d, 8) =                         (select max(convert(char(4), B.balshey_nf) +
                                                                     right(convert(char(3),100 + B.balshtmth_nf), 2) +
                                                                     convert(char(4),datepart(yy, B.cre_d)) +
                                                                     right(convert(char(3),100 + datepart(mm, B.cre_d)), 2) +
                                                                     right(convert(char(3),100 + datepart(dd, B.cre_d)), 2) +
                                                                     convert(char(9), B.cre_d, 8))
                                                              from   #TLIFDRI B
     					                                      where  B.acy_nf = A.acy_nf)

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#stat"
        return @erreur
        goto fin
    end

update #liste
set    COMACC_B1 = S.COMACC_B,
	   AUTUPD_B1 = S.AUTUPD_B,
	   CMT_NT1 = S.CMT_NT
from   #liste L, #stat S
where  S.ACY_NF = @acy_nf_1

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    COMACC_B2 = S.COMACC_B,
	   AUTUPD_B2 = S.AUTUPD_B,
	   CMT_NT2 = S.CMT_NT
from   #liste L, #stat S
where  S.ACY_NF = @acy_nf_2

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    COMACC_B3 = S.COMACC_B,
	   AUTUPD_B3 = S.AUTUPD_B,
	   CMT_NT3 = S.CMT_NT
from   #liste L, #stat S
where  S.ACY_NF = @acy_nf_3

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    COMACC_B4 = S.COMACC_B,
	   AUTUPD_B4 = S.AUTUPD_B,
	   CMT_NT4 = S.CMT_NT
from   #liste L, #stat S
where  S.ACY_NF = @acy_nf_4

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    COMACC_B5 = S.COMACC_B,
	   AUTUPD_B5 = S.AUTUPD_B,
	   CMT_NT5 = S.CMT_NT
from   #liste L, #stat S
where  S.ACY_NF = @acy_nf_5

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    COMACC_B6 = S.COMACC_B,
	   AUTUPD_B6 = S.AUTUPD_B,
	   CMT_NT6 = S.CMT_NT
from   #liste L, #stat S
where  S.ACY_NF = @acy_nf_6

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

update #liste
set    COMACC_B7 = S.COMACC_B,
       AUTUPD_B7 = S.AUTUPD_B,
	   CMT_NT7 = S.CMT_NT
from   #liste L, #stat S
where  S.ACY_NF = @acy_nf_7

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20004 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

/*--------------------------------------------------*/
/* Select final                                     */
/*--------------------------------------------------*/

select  @CRE_D  CRE_D,
        PRS_CF,
        ACMTRS_NT,
        POSITION,
        ACMTRS_LL,
        ESTMNT_M1,
        ESTMNT_M2,
        ESTMNT_M3,
        ESTMNT_M4,
        ESTMNT_M5,
        ESTMNT_M6,
        ESTMNT_M7,
        COMACC_B1,
        COMACC_B2,
        COMACC_B3,
        COMACC_B4,
        COMACC_B5,
        COMACC_B6,
        COMACC_B7,
        AUTUPD_B1,
        AUTUPD_B2,
        AUTUPD_B3,
        AUTUPD_B4,
        AUTUPD_B5,
        AUTUPD_B6,
        AUTUPD_B7,
        CMT_NT1,
        CMT_NT2,
        CMT_NT3,
        CMT_NT4,
        CMT_NT5,
        CMT_NT6,
        CMT_NT7,
        @acy_nf_1 AN1,
        @acy_nf_2 AN2,
        @acy_nf_3 AN3,
        @acy_nf_4 AN4,
        @acy_nf_5 AN5,
        @acy_nf_6 AN6,
        @acy_nf_7 AN7,
        @p_uwy_nf UWY
from #liste
order by POSITION

/*--------------------------------------------------*/
/* Destruction des tables temporaires               */
/*--------------------------------------------------*/

fin:
drop table #liste
drop table #montants_w
drop table #TLIFDRI
drop table #TLIFEST
drop table #stat
/*drop table #montants*/



return 0
go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSLIF03', 'PsLIFEST_03', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsLIFEST_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsLIFEST_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsLIFEST_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsLIFEST_03
 */
GRANT EXECUTE ON dbo.PsLIFEST_03 TO GOMEGA
go

