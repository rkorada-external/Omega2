use BTRT
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsFAMCNA_03
*/

IF OBJECT_ID('dbo.PsFAMCNA_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsFAMCNA_03
   PRINT '<<< DROPPED PROC dbo.PsFAMCNA_03 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsFAMCNA_03 (

                    @p_UWY_NF       UUWY_NF,
                    @p_UW_NT        UUW_NT,
                    @p_END_NT       UEND_NT,
                    @p_SEC_NF       USEC_NF,
                    @p_CTR_NF       UCTR_NF,
                    @p_LANGUE       char(1)

     )
as

/***************************************************

Programme: PsFAMCNA_03

Fichier script associé : BTRT_PsFAMCNA_03.prc

Domaine : (ES) Estimation

Base principale : BTRT

Version: 1

Auteur: GIBU

Date de creation: 02 Avril 2003

Description du programme:

    Selection des taux de CNA Conso et CNA Sociale en fonction de
    age (acy) par traite / exercice / section.
    On selectionne toujours 7 ages pour le traite/exercice meme
    si tous existent pas dans la table

Parametres:

                    @p_UWY_NF       UUWY_NF,
                    @p_UW_NT        UUW_NT,
                    @p_END_NT       UEND_NT,
                    @p_SEC_NF       USEC_NF,
                    @p_CTR_NF       UCTR_NF



Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur: G.BUISSON

Date: 16/05/2003

Version:

Description: si exercice passe en parametre est > dernier exercice
             valide sur TCONTR il faut recuperer les valeurs de TFAMCNA
             sur le dernier exercice valide de TCONTR

*****************************************************/

declare @UWY_NF         UUWY_NF,
        @UWY_UTIL       UUWY_NF,
        @cnatyp_ct      char(1),
        @cnatyp_ll      ul16,
        @lag_cf         char(1),
        @ssd_cf         char(2)

/************************************************/
/*	                                        */
/* 1- Creation de la table temporaire           */
/*	                                        */
/************************************************/

CREATE TABLE #TFAMCNA (
    CTR_NF       UCTR_NF      NOT NULL,
    UWY_NF       smallint     NOT NULL,
    UW_NT        tinyint      DEFAULT 1 NOT NULL,
    END_NT       tinyint      DEFAULT 0 NOT NULL,
    SEC_NF       tinyint      NOT NULL,
    ACY_NF       smallint     NOT NULL,
    CNACONSO_R   decimal(9,8) NULL,
    CNASOCI_R    decimal(9,8) NULL)

/**************************************************/
/*	                                          */
/* 2- Recherche du cnatyp_ct et du libelle sur    */
/*    exercice demande. Si cet exercice est >     */
/*    dernier exercice valide on prendra celui ci */
/*	                                          */
/**************************************************/

Select @UWY_NF = max(UWY_NF)
from   BTRT..TCONTR
where  CTR_NF    = @p_CTR_NF
and    END_NT    = @p_END_NT
and    UW_NT     = @p_UW_NT
and   (CTRSTS_CT = 14 or
       CTRSTS_CT = 16 or
       CTRSTS_CT = 17 or
       CTRSTS_CT = 19)

IF @p_uwy_nf > @UWY_NF
    begin
        Select @UWY_UTIL = @UWY_NF
    end
ELSE
    begin
        Select @UWY_UTIL = @p_uwy_nf
    end

select @lag_cf = @p_LANGUE

Select @cnatyp_ct = a.cnatyp_ct,
	   @cnatyp_ll = b.colval_ls
from   BTRT..TCONTR a, BREF..TBANTECL b
where  a.CTR_NF = @p_CTR_NF
and    a.END_NT = @p_END_NT
and    a.UW_NT  = @p_UW_NT
and    a.UWY_NF = @UWY_UTIL
and    a.cnatyp_ct = b.colval_ct
and    b.col_ls    = 'CNATYP_CT'
and    b.lag_cf    = @lag_cf

/************************************************/
/* Temporairement on initialise cnatyp_ct en    */
/* fonction de la filiale                       */
/************************************************/
/*
select @ssd_cf = substring(@p_CTR_NF,1,2)
if @ssd_cf = '14'
    begin
        select @cnatyp_ct = '3'
        select @cnatyp_ll = 'Manuel 2'
    end
else
    begin
        select @cnatyp_ct = NULL
        select @cnatyp_ll = NULL
    end
*/

/************************************************/
/*	                                        */
/* 3- initialisation de la table temporaire     */
/*	                                        */
/************************************************/

insert into #TFAMCNA values
   (@p_ctr_nf, @p_uwy_nf, @p_uw_nt, @p_end_nt, @p_sec_nf, 0, NULL, NULL)
insert into #TFAMCNA values
   (@p_ctr_nf, @p_uwy_nf, @p_uw_nt, @p_end_nt, @p_sec_nf, 1, NULL, NULL)
insert into #TFAMCNA values
   (@p_ctr_nf, @p_uwy_nf, @p_uw_nt, @p_end_nt, @p_sec_nf, 2, NULL, NULL)
insert into #TFAMCNA values
   (@p_ctr_nf, @p_uwy_nf, @p_uw_nt, @p_end_nt, @p_sec_nf, 3, NULL, NULL)
insert into #TFAMCNA values
   (@p_ctr_nf, @p_uwy_nf, @p_uw_nt, @p_end_nt, @p_sec_nf, 4, NULL, NULL)
insert into #TFAMCNA values
   (@p_ctr_nf, @p_uwy_nf, @p_uw_nt, @p_end_nt, @p_sec_nf, 5, NULL, NULL)
insert into #TFAMCNA values
   (@p_ctr_nf, @p_uwy_nf, @p_uw_nt, @p_end_nt, @p_sec_nf, 6, NULL, NULL)


/************************************************/
/*	                                        */
/* 4- Chargement de la table temporaire         */
/*	                                        */
/************************************************/

Update #TFAMCNA
set    a.CNACONSO_R = b.CNACONSO_R,
       a.CNASOCI_R  = b.CNASOCI_R
from   #TFAMCNA a, BTRT..TFAMCNA b
where  a.CTR_NF = b.CTR_NF
and    b.UWY_NF = @UWY_UTIL
and    a.UW_NT  = b.UW_NT
and    a.END_NT = b.END_NT
and    a.SEC_NF = b.SEC_NF
and    a.ACY_NF = b.ACY_NF

/************************************************/
/*	                                        */
/* 5- Select final                              */
/*	                                        */
/************************************************/

select CTR_NF       CTR_NF,
       UWY_NF       UWY_NF,
       UW_NT        UW_NT,
       END_NT       END_NT,
       SEC_NF       SEC_NF,
       ACY_NF       ACY_NF,
       CNACONSO_R   CNACONSO_R,
       CNASOCI_R    CNASOCI_R,
       @cnatyp_ct   cnatyp_ct,
       @cnatyp_ll   cnatyp_ll
from   #TFAMCNA
order by CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, ACY_NF

return 0
go

/*
 * fin de la procedure
 */

IF OBJECT_ID('dbo.PsFAMCNA_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsFAMCNA_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsFAMCNA_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsFAMCNA_03
 */
GRANT EXECUTE ON dbo.PsFAMCNA_03 TO GOMEGA
go

