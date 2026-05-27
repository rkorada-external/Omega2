USE BSAR
go

IF OBJECT_ID('dbo.PsTSEGSTAT_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTSEGSTAT_01
    IF OBJECT_ID('dbo.PsTSEGSTAT_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTSEGSTAT_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTSEGSTAT_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsTSEGSTAT_01  (
                                                                @p_ssd_cf  USSD_CF   ,
                                                                @p_segment  USEG_NF,
                                                                @p_egpcur_cf   UCUR_CF
                                                        )

as

/***************************************************
Programme: PsTSEGSTAT_01
Fichier script associé : BEST_PsTSEGSTAT_01.PRC
Domaine : Estimations
Base principale : BSAR
Version: 1
Auteur: ME57
Date de creation: 29/07/2004
Description du programme:
   Selection d'enregistrement dans TTSEGSTAT: Permet de calculer le "LR" dans PB w_reponse_es0208.
Parametres:
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur: SPAGNOLI Marc
Date:    03/09/2004
Version:
Description: Ajout d'un controle sur l'existence de la tsegstat_
_________________
MODIFICATION 2
Auteur: SPAGNOLI Marc
Date:    07/09/2004
Version:
Description: modification de la recherche des données dans tsegstat_
_________________
MODIFICATION 3
Auteur: SPAGNOLI Marc
Date:    06/10/2004
Version:
Description: Ajout de la table #mont1 + multiplication du taux par 100
_________________
MODIFICATION 4
Auteur: SPAGNOLI Marc
Date:    11/10/2004
Version:
Description:Modification de la recherche de la tsegstat_
_________________
MODIFICATION 5
Auteur: SPAGNOLI Marc
Date:    14/10/2004
Version:
Description: Modification de la selection des segments : correction bug.

_________________
MODIFICATION 6

    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs

_________________
MODIFICATION 7 (MOD07)
Auteur: Dominique OURMIAH
Date:    16/07/2008
Version:
Description: SPOT 15808 Augmentation de la taille (600 --> 1000) de la variable de type varchar qui reçoit la requete de calcul de la prime acquise

*****************************************************/

declare @erreur int , @vrs_nf numeric , @vrs_lm   UL32
declare @BALSHTDAT_CF	char (6)
declare @montant_pa   decimal(9,3)
declare @montant_st    decimal(9,3)

--Calcul de la date bilan
declare @p_date   	datetime
declare @p_typper     char(1)
declare @p_blcshtyea_nf  smallint
declare @p_blcshtmth_nf  tinyint
declare @p_specend_d     datetime
declare @p_account_d     datetime
declare @p_closing_b     bit
declare @date_conv datetime

DECLARE  @c_clause   varchar(1000) -- MOD07

declare @tableseg char(12)

select @p_date = GetDate()
select @p_typper = "E"

CREATE TABLE #mont ( mont_pa UAMT_M,
                                        mont_st  UAMT_M,
                                        clmamt_m UAMT_M,
                                         taux       USHORAT_R ,
                                        uwy_nf UUWY_NF ,
                                        cur_cf   ucur_cf  ,
                                        ibnr_avant  UAMT_M,
                                        ibnr_apres  UAMT_M,
                                        taux_apres USHORAT_R  null ,
                                         clm_apres uamt_m null)




CREATE TABLE #mont_avant ( mont_pa UAMT_M null,
                                        mont_st  UAMT_M null ,
                                        clmamt_m UAMT_M null,
                                         taux       USHORAT_R null,
                                        uwy_nf UUWY_NF null,
                                        cur_cf   ucur_cf null ,
                                        ibnr_avant  UAMT_M null ,
                                        ibnr_apres  UAMT_M null ,
                                        taux_apres USHORAT_R null ,
                                         clm_apres uamt_m null)

CREATE TABLE #mont1 (clmamt_m UAMT_M null,
                                         taux       USHORAT_R null ,
                                        uwy_nf UUWY_NF ,
                                        cur_cf   ucur_cf   )

CREATE TABLE #temp (seg_nf USEG_NF ,                 --0005
                                        mont_pa UAMT_M ,
                                        mont_st  UAMT_M ,
                                        clmamt_m UAMT_M null,
                                         taux       USHORAT_R ,
                                        uwy_nf UUWY_NF ,
                                        cur_cf   ucur_cf )


set arithabort numeric_truncation off
set arithabort off


exec BREF..Pscalend_02  @p_date ,@p_typper,@p_blcshtyea_nf output  ,@p_blcshtmth_nf output ,@p_specend_d , @p_account_d ,@p_closing_b




---Recherche de l'indice pour le calcul du 'LR'
select 	@BALSHTDAT_CF = convert (varchar, @p_blcshtyea_nf) +
			replicate ('0', 2 - datalength ( convert (varchar, @p_blcshtmth_nf))) +
			convert (varchar, @p_blcshtmth_nf)



select @tableseg = a.TABCIBLE_CF
from BSAR..TBOPAR a
where a.DMN_CF="EST"
and a.TAB_CF="TSEGSTAT"
and a.FIELD1_CF = (select max(b.FIELD1_CF)
                   from BSAR..TBOPAR b
                   where a.DMN_CF = b.DMN_CF
                   and a.TAB_CF = b.TAB_CF
                   and b.FIELD1_CF <= @BALSHTDAT_CF )
and a.FIELD2_CF =  (select max(c.FIELD2_CF)
                   from BSAR..TBOPAR c
                   where a.DMN_CF = c.DMN_CF
                   and a.TAB_CF = c.TAB_CF
                   and substring (c.FIELD2_CF, 1, 6) <= @BALSHTDAT_CF)
and (a.PAR_D=NULL or a.PAR_D='')
and a.ARCH_B=0

--0004
IF  @tableseg = NULL  or @tableseg = ""
Begin
        select @tableseg = a.TABCIBLE_CF
        from BSAR..TBOPAR a
        where a.DMN_CF="EST"
        and a.TAB_CF="TSEGSTAT"
        and a.FIELD1_CF = (select max(b.FIELD1_CF)
                           from BSAR..TBOPAR b
                           where a.DMN_CF = b.DMN_CF
                           and a.TAB_CF = b.TAB_CF
                           and b.FIELD1_CF <= @BALSHTDAT_CF )
        and a.FIELD2_CF =  (select max(c.FIELD2_CF)
                           from BSAR..TBOPAR c
                           where a.DMN_CF = c.DMN_CF
                           and a.TAB_CF = c.TAB_CF
                           and substring (c.FIELD2_CF, 1, 6) >= @BALSHTDAT_CF)
        and (a.PAR_D=NULL or a.PAR_D='')
        and a.ARCH_B=0
end

--MODIF 0001 on return la table #mont_avant pour ne pas avoir de pb de result set dans l'appli.
IF @tableseg = NULL     or       @tableseg = ""
Begin
        /* Adaptive Server has expanded all '*' elements in the following statement */ select #mont_avant.mont_pa, #mont_avant.mont_st, #mont_avant.clmamt_m, #mont_avant.taux, #mont_avant.uwy_nf, #mont_avant.cur_cf, #mont_avant.ibnr_avant, #mont_avant.ibnr_apres, #mont_avant.taux_apres, #mont_avant.clm_apres from #mont_avant
        RETURN
End



--1 Calcul du montant ibnr AVANT
--montant de Prime Aquise
select @c_clause =  " insert into #temp select  seg_nf, sum(caccprm_m + caccepp_m + caccrpp_m + caccpna_m + iaccprm_m + iaccepp_m + iaccrpp_m +" +
          " iaccpna_m + estprm_m + estepp_m + estrpp_m + estpna_m)  , " +
        " sum( caccsp_m + cacceps_m + caccrps_m + caccsap_m + caccacr_m +iaccsp_m + iacceps_m + iaccrps_m +  iaccsap_m +    " +
         " iaccacr_m +estsp_m + esteps_m + estrps_m + estsap_m + estblkosl_m + estblkpl_m + estacr_m)  , " +
          " 0, 0, uwy_nf , egpcur_cf  from BSAR.." + @tableseg +
"where ssd_cf =  " + convert(char(2),@p_ssd_cf) + "  and seg_nf =  " + "'" + @p_segment +"'"    + " and ctrret_b = 0 and (actclmamt_m <> 0 or actlosrat_r <> 0 )"  +
"  group by seg_nf, uwy_nf , egpcur_cf  "  +  "  order by seg_nf, uwy_nf , egpcur_cf  "

execute (@c_clause)

--On converti tout en devise @p_egpcur_cf  Pour le calcul de l'ibnr avant -> données prises dans TSEGSTAT_X
set arithabort numeric_truncation off
UPDATE  #temp
set   a. mont_pa      =  a.mont_pa    * b.exc_r ,
       a.mont_st        =  a.mont_st     * b.exc_r,
       a.cur_cf           =       @p_egpcur_cf
from   #temp a , BREF..TCURQUOT b
where  b.ssd_cf = @p_ssd_cf
and     a.cur_cf = b.cur_cf
and    b.exc_d  = ( select max(exc_d)
                    from  BREF..TCURQUOT c
                    where b.ssd_cf = c.ssd_cf
                    and c.cur_cf = @p_egpcur_cf   )

Insert into #mont
select  sum(mont_pa),
        sum(mont_st) ,
        0 ,
         0  ,
        uwy_nf ,
        cur_cf ,
        0, 0, 0, 0
FROM #temp
group by   seg_nf ,  uwy_nf ,cur_cf
order by   seg_nf ,  uwy_nf ,cur_cf

DELETE  #temp

/* select avec actucr_cf dans cur_cf montant Sinistre*/
select @c_clause =  " insert into #temp select distinct seg_nf, 0, 0, actclmamt_m, actlosrat_r, uwy_nf , actcur_cf  from BSAR.." + @tableseg +
"where ssd_cf =  " + convert(char(2),@p_ssd_cf) + "  and seg_nf =  " + "'" + @p_segment +"'"    + " and ctrret_b = 0 and (actclmamt_m <> 0 or actlosrat_r <> 0 )"
execute (@c_clause)

set arithabort numeric_truncation off
UPDATE  #temp
set   clmamt_m      =  clmamt_m    * b.exc_r ,
       a.cur_cf           =        @p_egpcur_cf
from   #temp a , BREF..TCURQUOT b
where  b.ssd_cf = @p_ssd_cf
and     a.cur_cf = b.cur_cf
--and    b.exc_d  =  @date_conv
and    b.exc_d  = ( select max(exc_d)
                    from  BREF..TCURQUOT c
                    where b.ssd_cf = c.ssd_cf
                    and c.cur_cf = @p_egpcur_cf )

update #mont
set    a.clmamt_m = b.clmamt_m ,
        a.taux = b.taux
from  #mont a, #temp b
where  a.uwy_nf  =  b.uwy_nf
and      a.cur_cf  =  b.cur_cf



--via tsegest
Insert  into #mont1
select b.clmamt_m,
         b.losrat_r,
         b.uwy_nf,
         b.cur_cf
FROM #mont a, tsegest b
WHERE a.uwy_nf = b.uwy_nf
--and   a.cur_cf = b.cur_cf
and   b.ssd_cf = @p_ssd_cf --ms
and   b.seg_nf = @p_segment -- AJOUT MS
and  b.ctrret_b = 0



/*--On converti tout en devise @p_egpcur_cf  Pour le calcul de l'ibnr avant -> données prises dans TSEGSTAT_X
UPDATE  #mont
set   a. mont_pa      =  a.mont_pa    * b.exc_r ,
       a.mont_st        =  a.mont_st     * b.exc_r,
       --a.clmamt_m    =  a.clmamt_m * b.exc_r ,                  --normalement ce montant est deja converti dans la base.
       a.cur_cf           =         @p_egpcur_cf
from   #mont a , BREF..TCURQUOT b
where  b.ssd_cf = @p_ssd_cf
and     a.cur_cf = b.cur_cf
--and    b.exc_d  =  @date_conv
and    b.exc_d  = ( select max(exc_d)
                    from  BREF..TCURQUOT c
                    where b.ssd_cf = c.ssd_cf
                    and c.cur_cf = @p_egpcur_cf   )        */

--On converti tout en devise @p_egpcur_cf   Pour le calcul de l'ibnr apres données prises dans TSEGEST
UPDATE  #mont1
set   a.clmamt_m      =  a.clmamt_m  * b.exc_r,
       a.cur_cf           =         @p_egpcur_cf
from   #mont1 a , BREF..TCURQUOT b
where  b.ssd_cf = @p_ssd_cf
and     a.cur_cf = b.cur_cf
and    b.exc_d  = ( select max(exc_d)
                    from  BREF..TCURQUOT c
                    where b.ssd_cf = c.ssd_cf
                   and c.cur_cf = @p_egpcur_cf   )

--On somme les colonnes sur les exercices pour alimenter la table des montant à l'ouverture de la data window
Insert into #mont_avant
select  sum( mont_pa), sum(  mont_st), sum(clmamt_m ) ,     taux   ,  uwy_nf  , cur_cf , 0, 0,0 ,0
from #mont
group by   clmamt_m, taux, uwy_nf  , cur_cf
order by   clmamt_m, taux, uwy_nf  , cur_cf


--UPDATE DES TAUX_APRES
UPDATE  #mont_avant
set    a.clm_apres = isnull(b.clmamt_m, 0) ,
        a.taux_apres = b.taux
FROM #mont_avant a, #mont1 b
where  a.cur_cf = b.cur_cf
and a.uwy_nf = b.uwy_nf


UPDATE  #mont_avant
set ibnr_avant =  ((taux*100) * mont_pa  *-1 ) - mont_st  --modification du calcul     multiplier le taux par 10
WHERE taux <> 0




UPDATE  #mont_avant
set ibnr_avant = clmamt_m - mont_st
--set ibnr_avant = clmamt_m + mont_st       --Attention !
WHERE taux =  0


--MISE A JOUR DES IBNR VIA TSEGEST    POUR LES IBNR APRES
UPDATE  #mont_avant
set ibnr_apres =  ((taux_apres*100) * mont_pa  * -1) -  mont_st
WHERE taux_apres <> 0



UPDATE  #mont_avant
set ibnr_apres = clm_apres - mont_st
WHERE taux =  0


--SELECT FINAL
/* Adaptive Server has expanded all '*' elements in the following statement */ select #mont_avant.mont_pa, #mont_avant.mont_st, #mont_avant.clmamt_m, #mont_avant.taux, #mont_avant.uwy_nf, #mont_avant.cur_cf, #mont_avant.ibnr_avant, #mont_avant.ibnr_apres, #mont_avant.taux_apres, #mont_avant.clm_apres from #mont_avant

drop table #mont
drop table #mont1
drop table  #mont_avant

return 0

go
EXEC sp_procxmode 'dbo.PsTSEGSTAT_01','unchained'
go
IF OBJECT_ID('dbo.PsTSEGSTAT_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTSEGSTAT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTSEGSTAT_01 >>>'
go
GRANT EXECUTE ON dbo.PsTSEGSTAT_01 TO GOMEGA
go
