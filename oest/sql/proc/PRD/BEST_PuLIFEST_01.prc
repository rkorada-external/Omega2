USE BEST
Go

/*
  DROP PROC PuLIFEST_01 */
IF OBJECT_ID('PuLIFEST_01') IS NOT NULL
BEGIN
    DROP PROC PuLIFEST_01
    PRINT '<<< DROPPED PROC PuLIFEST_01 >>>'
END
go

/*
 * creation de la procedure */
create procedure PuLIFEST_01(
    @p_balshey	int
)

with execute as caller as
/***************************************************
Programme:              PuLIFEST_01
Fichier script associé: ESULIF01.PRC
Domaine :               (ES) Estimation
Base principale :       BEST
Version:                1
Auteur:                 ME27 avec Infotool version 2.0 (AUTO)
Description du programme: 
                        Modification d'enregistrements dans TLIFEST 
_________________
MODIFICATION    [001]
Auteur:         D.GATIBELZA ( TRIPERT )
Date:           14/02/2011
Version:        10.2
Description:    ESTVIE21422 Mauvais calcul du poste 1063 pour les lob non vie,
                après arrété stat  le 1063 n'est pas recalculé en batch à partir du 1503/1523/1533
                
_________________
MODIFICATION    [002]
Auteur:         TRIPERT
Date:           04/03/2011
Version:        10.2
Description:    INSERTION DES LIGNES LIB MANQUANBTES DANS TLIFEST
_________________
MODIFICATION    [003]
Auteur:         TRIPERT
Date:           09/03/2011
Version:        10.2
Description:    AJOUT ACY DANS LES REQUETES
_________________
Modification - Removed dbo and added ‘with execute as caller as’
_________________
MODIFICATION    [005]
Auteur: P. COPPIN
Date: 16/10/2013
Description: :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2
*****************************************************/

-- ACCEPT

-- Les postes 1063
SELECT a.CTR_NF, a.SEC_NF, a.BALSHEY_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.ACY_NF, a.ESTMNT_M
INTO #1063
FROM BEST..TLIFEST a, BTRT..TSECTION b, BREF..TBATCHSSD T
WHERE a.ctr_nf = b.ctr_nf
  and a.sec_nf = b.sec_nf
  and a.uwy_nf = b.uwy_nf
  and a.uw_nt  = b.uw_nt
  and a.end_nt = b.end_nt
  and a.acmtrs_nt = 1063

  and a.SSD_CF = T.SSD_CF
  and T.BATCHUSER_CF = suser_name()

  and a.cre_d = ( select max(b.cre_d) 
                  from best..tlifest b
                  where	a.ctr_nf = b.ctr_nf
                    and a.sec_nf = b.sec_nf
                    and a.uwy_nf = b.uwy_nf
                    and a.acy_nf = b.acy_nf
                    and a.acmtrs_nt = b.acmtrs_nt
                    and a.balshey_nf = b.balshey_nf )
  and b.lob_cf = '31'
  and a.BALSHEY_NF = @p_balshey


-- Les postes 1503,1523,1533
SELECT a.CTR_NF, a.SEC_NF, a.BALSHEY_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.ACY_NF, sum(a.ESTMNT_M) ESTMNT_M
INTO #15X3
FROM BEST..TLIFEST a, BTRT..TSECTION b, BREF..TBATCHSSD T
WHERE a.ctr_nf = b.ctr_nf
  and a.sec_nf = b.sec_nf
  and a.uwy_nf = b.uwy_nf
  and a.uw_nt  = b.uw_nt
  and a.end_nt = b.end_nt

  and a.SSD_CF = T.SSD_CF
  and T.BATCHUSER_CF = suser_name()

  and a.cre_d = ( select max(b.cre_d)
                  from best..tlifest b
                  where a.ctr_nf = b.ctr_nf
                    and a.sec_nf = b.sec_nf
                    and a.uwy_nf = b.uwy_nf
                    and a.acy_nf = b.acy_nf
                    and a.acmtrs_nt = b.acmtrs_nt
                    and a.balshey_nf = b.balshey_nf )
  and a.acmtrs_nt in (1503,1523,1533)
  and b.lob_cf = '31'
  and a.BALSHEY_NF = @p_balshey
group by a.CTR_NF, a.SEC_NF, a.BALSHEY_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.ACY_NF


/* PhP détruire les lignes du #1063 ou #1063.estmnt_m = #15x3.estmnt_m */
delete #1063
from #1063 a, #15x3 b
WHERE a.ctr_nf = b.ctr_nf
  and a.sec_nf = b.sec_nf
  and a.uwy_nf = b.uwy_nf
  and a.acy_nf = b.acy_nf  
  and a.uw_nt  = b.uw_nt
  and a.end_nt = b.end_nt
  and a.BALSHEY_NF = @p_balshey
  and a.estmnt_m = b.estmnt_m


-- MISE à JOUR 1063 pour les 15x3 avec des montants différents
update #1063
   set estmnt_m = b.estmnt_m
from #1063 a, #15x3 b
WHERE a.ctr_nf = b.ctr_nf
  and a.sec_nf = b.sec_nf
  and a.uwy_nf = b.uwy_nf
  and a.acy_nf = b.acy_nf
  and a.uw_nt  = b.uw_nt
  and a.end_nt = b.end_nt
  and a.BALSHEY_NF = @p_balshey



-- RETRO

-- Les postes 2063
SELECT a.CTR_NF, a.SEC_NF, a.BALSHEY_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.ACY_NF, a.ESTMNT_M
INTO #2063
FROM BEST..TLIFEST	a, BRET..TRETSEC b, BREF..TBATCHSSD T
WHERE a.ctr_nf = b.retctr_nf
  and a.sec_nf = b.retsec_nf
  and a.uwy_nf = b.rty_nf
  and a.acmtrs_nt = 2063

  and a.SSD_CF = T.SSD_CF
  and T.BATCHUSER_CF = suser_name()

  and a.cre_d = ( select max(b.cre_d)
                  from best..tlifest b, BREF..TBATCHSSD T2
                  where	a.ctr_nf = b.ctr_nf
                    and a.sec_nf = b.sec_nf
                    and a.uwy_nf = b.uwy_nf
                    and a.acy_nf = b.acy_nf
                    and a.acmtrs_nt = b.acmtrs_nt
                    and a.balshey_nf = b.balshey_nf 
                    
                    and b.SSD_CF = T2.SSD_CF
                    and T2.BATCHUSER_CF = suser_name() )
  and b.lob_cf = '31'
  and a.BALSHEY_NF = @p_balshey


-- Les postes 2503,2523,2533
SELECT a.CTR_NF, a.SEC_NF, a.BALSHEY_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.ACY_NF, sum(a.ESTMNT_M) ESTMNT_M
INTO #25X3
FROM BEST..TLIFEST a, BRET..TRETSEC b, BREF..TBATCHSSD T
WHERE a.ctr_nf = b.retctr_nf
  and a.sec_nf = b.retsec_nf
  and a.uwy_nf = b.rty_nf

  and a.SSD_CF = T.SSD_CF
  and T.BATCHUSER_CF = suser_name()

  and a.cre_d = ( select max(b.cre_d)
                  from best..tlifest b, BREF..TBATCHSSD T2
                  where a.ctr_nf = b.ctr_nf
                    and a.sec_nf = b.sec_nf
                    and a.uwy_nf = b.uwy_nf
                    and a.acy_nf = b.acy_nf
                    and a.acmtrs_nt = b.acmtrs_nt
                    and a.balshey_nf = b.balshey_nf 
                    
                    and b.SSD_CF = T2.SSD_CF
                    and T2.BATCHUSER_CF = suser_name() )
                    
  and a.acmtrs_nt in (2503,2523,2533)
  and b.lob_cf = '31'
  and a.BALSHEY_NF = @p_balshey
group by a.CTR_NF, a.SEC_NF, a.BALSHEY_NF, a.UWY_NF, a.UW_NT, a.END_NT, a.ACY_NF


/* PhP détruire les lignes du #1063 ou #1063.estmnt_m = #15x3.estmnt_m */
delete #2063
from #2063 a, #25x3 b
WHERE a.ctr_nf = b.ctr_nf
  and a.sec_nf = b.sec_nf
  and a.uwy_nf = b.uwy_nf
  and a.acy_nf = b.acy_nf    
  and a.uw_nt  = b.uw_nt
  and a.end_nt = b.end_nt
  and a.BALSHEY_NF = @p_balshey
  and a.estmnt_m = b.estmnt_m


-- MISE à JOUR 2063 pour les 25x3 avec des montants différents
update #2063
   set estmnt_m = b.estmnt_m
from #2063 a, #25x3 b
WHERE a.ctr_nf = b.ctr_nf
  and a.sec_nf = b.sec_nf
  and a.uwy_nf = b.uwy_nf
  and a.acy_nf = b.acy_nf  
  and a.uw_nt  = b.uw_nt
  and a.end_nt = b.end_nt
  and a.BALSHEY_NF = @p_balshey


---------------------------------------------
-- GESTION DES LIBERATIONS
---------------------------------------------
-- Les postes de constitution
SELECT a.CTR_NF,
       a.SEC_NF,
       a.BALSHEY_NF,
       UWY_NF= case when b.accadmtyp_ct in (1,3)
                    then a.UWY_NF + 1
                    else a.UWY_NF
               end,
       a.UW_NT,
       a.END_NT,
       a.ACY_NF+1 ACY_NF,
       a.ACMTRS_NT+1 ACMTRS_NT,
       a.ESTMNT_M*-1 ESTMNT_M
INTO #lib
FROM BEST..TLIFEST a, BTRT..TSECTION b, BREF..TBATCHSSD T
WHERE a.ctr_nf = b.ctr_nf
  and a.sec_nf = b.sec_nf
  and a.uwy_nf = b.uwy_nf
  and a.uw_nt  = b.uw_nt
  and a.end_nt = b.end_nt
  and a.acmtrs_nt in ( 1063, 1093 )

  and a.SSD_CF = T.SSD_CF
  and T.BATCHUSER_CF = suser_name()

  and a.cre_d = ( select max(b.cre_d) 
                  from best..tlifest b
                  where	a.ctr_nf = b.ctr_nf
                    and a.sec_nf = b.sec_nf
                    and a.uwy_nf = b.uwy_nf
                    and a.acy_nf = b.acy_nf
                    and a.acmtrs_nt = b.acmtrs_nt
                    and a.balshey_nf = b.balshey_nf )
  and a.BALSHEY_NF = @p_balshey
	and a.ACY_NF < @p_balshey + 2
UNION
SELECT a.CTR_NF,
       a.SEC_NF,
       a.BALSHEY_NF,
       UWY_NF= case when b.retacctyp_ct in (1,3)
                    then a.UWY_NF + 1
                    else a.UWY_NF
               end,
       a.UW_NT,
       a.END_NT,
       a.ACY_NF+1 ACY_NF,
       a.ACMTRS_NT+1 ACMTRS_NT,
       a.ESTMNT_M*-1 ESTMNT_M
FROM BEST..TLIFEST a, BRET..TRETCTR b, BREF..TBATCHSSD T
WHERE a.ctr_nf = b.retctr_nf
  and a.uwy_nf = b.rty_nf
  and a.acmtrs_nt in ( 2063, 2093 )
  
  and a.SSD_CF = T.SSD_CF
  and T.BATCHUSER_CF = suser_name()
  
  and a.cre_d = ( select max(b.cre_d) 
                  from best..tlifest b, BREF..TBATCHSSD T2
                  where	a.ctr_nf = b.ctr_nf
                    and a.sec_nf = b.sec_nf
                    and a.uwy_nf = b.uwy_nf
                    and a.acy_nf = b.acy_nf
                    and a.acmtrs_nt = b.acmtrs_nt
                    and a.balshey_nf = b.balshey_nf 
                    
                    and b.SSD_CF = T2.SSD_CF
                    and T2.BATCHUSER_CF = suser_name() )
                    
  and a.BALSHEY_NF = @p_balshey
	and a.ACY_NF < @p_balshey + 2



---------------------------------------------
-- MISE A JOUR TLIFEST
---------------------------------------------
--1063
update best..tlifest
   set estmnt_m = b.estmnt_m,
       lstupd_d = dateadd(ss, 3661, convert(datetime, convert(char(8), getdate(), 112)))
from BEST..TLIFEST a, #1063 b
WHERE a.ctr_nf = b.ctr_nf
  and a.sec_nf = b.sec_nf
  and a.uwy_nf = b.uwy_nf
  and a.acy_nf = b.acy_nf
  and a.uw_nt  = b.uw_nt
  and a.end_nt = b.end_nt
  and a.BALSHEY_NF = @p_balshey
  and a.acmtrs_nt = 1063
  and a.cre_d = ( select max(c.cre_d)
                  from best..tlifest c
                  where a.ctr_nf = c.ctr_nf
                    and a.sec_nf = c.sec_nf
                    and a.uwy_nf = c.uwy_nf 
                    and a.acy_nf = c.acy_nf 
                    and a.acmtrs_nt = c.acmtrs_nt
                    and a.balshey_nf = c.balshey_nf )


--2063
update best..tlifest
   set estmnt_m = b.estmnt_m,
       lstupd_d = dateadd(ss, 3661, convert(datetime, convert(char(8), getdate(), 112)))
from BEST..TLIFEST a, #2063 b
WHERE a.ctr_nf = b.ctr_nf
  and a.sec_nf = b.sec_nf
  and a.uwy_nf = b.uwy_nf
  and a.acy_nf = b.acy_nf
  and a.uw_nt  = b.uw_nt
  and a.end_nt = b.end_nt
  and a.BALSHEY_NF = @p_balshey
  and a.acmtrs_nt = 2063
  and a.cre_d = ( select max(c.cre_d)
                  from best..tlifest c
                  where a.ctr_nf = c.ctr_nf
                    and a.sec_nf = c.sec_nf
                    and a.uwy_nf = c.uwy_nf
                    and a.acy_nf = c.acy_nf
                    and a.acmtrs_nt = c.acmtrs_nt
                    and a.balshey_nf = c.balshey_nf )

-- Liberation
update best..tlifest
   set estmnt_m = b.estmnt_m,
       lstupd_d = dateadd(ss, 3661, convert(datetime, convert(char(8), getdate(), 112)))
from BEST..TLIFEST a, #lib b
WHERE a.ctr_nf = b.ctr_nf
  and a.sec_nf = b.sec_nf
  and a.uwy_nf = b.uwy_nf
  and a.acy_nf = b.acy_nf
  and a.uw_nt  = b.uw_nt
  and a.end_nt = b.end_nt
  and a.BALSHEY_NF = @p_balshey
  and a.acmtrs_nt = b.acmtrs_nt
  and a.estmnt_m <> b.estmnt_m
  and a.cre_d = ( select max(c.cre_d)
                  from best..tlifest c
                  where a.ctr_nf = c.ctr_nf
                    and a.sec_nf = c.sec_nf
                    and a.uwy_nf = c.uwy_nf
                    and a.acy_nf = c.acy_nf
                    and a.acmtrs_nt = c.acmtrs_nt
                    and a.balshey_nf = c.balshey_nf )


/* Mise a jour de TSECTION dans la base Traites */
update BTRT..TSECTION
   set ESTCTR_NF = tmp.ESTCTR_NF
from BTRT..TSECTION sec, BTRAV..TESTSECTION tmp
where sec.CTR_NF = tmp.CTR_NF
  and sec.END_NT = tmp.END_NT
  and sec.SEC_NF = tmp.SEC_NF
  and sec.UWY_NF = tmp.UWY_NF
  and sec.UW_NT  = tmp.UW_NT
  and tmp.ESTCTR_NF is not null


update BTRT..TSECTION
   set SEG_NF = tmp.SEG_NF
from BTRT..TSECTION sec, BTRAV..TESTSECTION tmp
where sec.CTR_NF = tmp.CTR_NF
  and sec.END_NT = tmp.END_NT
  and sec.SEC_NF = tmp.SEC_NF
  and sec.UWY_NF = tmp.UWY_NF
  and sec.UW_NT  = tmp.UW_NT
  and tmp.SEG_NF is not null


-- 002
-- INSERTION DES LIGNES MANQUANTES
exec pilifest_05 @p_balshey

go

IF OBJECT_ID('PuLIFEST_01') IS NOT NULL
    PRINT '<<< CREATED PROC PuLIFEST_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PuLIFEST_01 >>>'
go

/*
 * Granting/Revoking Permissions on PuLIFEST_01 */
GRANT EXECUTE ON PuLIFEST_01 TO GOMEGA
go

GRANT EXECUTE ON PuLIFEST_01 TO GCONSULT
go
GRANT EXECUTE ON PuLIFEST_01 TO GDBBATCH
go


