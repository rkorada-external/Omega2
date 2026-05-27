USE BEST
Go

/*
  DROP PROC dbo.PiLIFEST_05 */
IF OBJECT_ID('dbo.PiLIFEST_05') IS NOT NULL
BEGIN
    DROP PROC dbo.PiLIFEST_05
    PRINT '<<< DROPPED PROC dbo.PuLIFEST_01 >>>'
END
go

/*
 * creation de la procedure */
create procedure PiLIFEST_05(
    @p_balshey	int
)

as
/***************************************************
Programme:              PiLIFEST_05
Fichier script associé: BEST_PiLIFEST_05.PRC
Domaine :               (ES) Estimation
Base principale :       BEST
Version:                1
Auteur:                 
Description du programme: Insertion d'enregistrements dans TLIFEST 
_________________
MODIFICATION    [001]
Auteur:         TRIPERT
Date:           04/03/2011
Version:        10.2
Description:    Mauvaise libéation des postes 1064,1094,2064,2094
_________________
MODIFICATION    [002]
Auteur: P. COPPIN
Date: 15/10/2013
Description: :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2
*****************************************************/

Declare @erreur         Int
Declare @code_erreur    Int


---------------------------------------------
-- GESTION DES LIBERATIONS
---------------------------------------------
-- Les postes de constitution

-- ACCEPT
SELECT a.CTR_NF,
       a.end_nt,
       a.SEC_NF,
       UWY_NF= case when b.accadmtyp_ct in (1,3)
                    then a.UWY_NF + 1
                    else a.UWY_NF
               end,
       a.UW_NT,
       a.cre_d,
       a.balshey_nf,
       a.balshtmth_nf,
       a.ACY_NF+1 ACY_NF,
       a.prs_cf,
       a.ACMTRS_NT+1 ACMTRS_NT,
       a.ssd_cf,
       a.cur_cf,
       a.ESTMNT_M*-1 ESTMNT_M,
       a.indsup_b,
       a.oricod_ls,
       a.creusr_cf,
       dateadd(ss, 3661, convert(datetime, convert(char(8), getdate(), 112))) lstupd_d,
       a.lstupdusr_cf
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
union
--RETRO
SELECT a.CTR_NF,
       a.end_nt,
       a.SEC_NF,
       UWY_NF= case when b.retacctyp_ct in (1,3)
                    then a.UWY_NF + 1
                    else a.UWY_NF
               end,
       a.UW_NT,
       a.cre_d,
       a.balshey_nf,
       a.balshtmth_nf,
       a.ACY_NF+1 ACY_NF,
       a.prs_cf,
       a.ACMTRS_NT+1 ACMTRS_NT,
       a.ssd_cf,
       a.cur_cf,
       a.ESTMNT_M*-1 ESTMNT_M,
       a.indsup_b,
       a.oricod_ls,
       a.creusr_cf,
       dateadd(ss, 3661, convert(datetime, convert(char(8), getdate(), 112))) lstupd_d,
       a.lstupdusr_cf
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
	
-- Gestion des doublons
select a.CTR_NF,
       a.end_nt,
       a.SEC_NF,
       a.UWY_NF,
       a.UW_NT,
       a.cre_d,
       a.balshey_nf,
       a.balshtmth_nf,
       a.ACY_NF,
       a.prs_cf,
       a.ACMTRS_NT,
       a.ssd_cf,
       a.cur_cf,
       a.ESTMNT_M,
       a.indsup_b,
       a.oricod_ls,
       a.creusr_cf,
       a.lstupd_d,
       a.lstupdusr_cf
into #lib1 from #lib a
where a.cre_d = ( select max(b.cre_d) 
                  from #lib b
                  where	a.ctr_nf = b.ctr_nf
                    and a.sec_nf = b.sec_nf
                    and a.uwy_nf = b.uwy_nf
                    and a.acy_nf = b.acy_nf
                    and a.acmtrs_nt = b.acmtrs_nt
                    and a.balshey_nf = b.balshey_nf )

-- Lignes maanquantes dans TLIFEST
select * into #lifest from #lib1 a
where not exists (select 1 from best..tlifest b
                  where	a.ctr_nf = b.ctr_nf
                    and a.sec_nf = b.sec_nf
                    and a.uwy_nf = b.uwy_nf
                    and a.acy_nf = b.acy_nf
                    and a.acmtrs_nt = b.acmtrs_nt
                    and a.balshey_nf = b.balshey_nf )                    
	
-- INSERTION DANS TLIFEST
insert into best..tlifest
select * from #lifest

Select @erreur = @@error
If @erreur != 0
Begin
    Raiserror 20001 '20001 APPLICATIF;58;'
    select @code_erreur = 1
    GOTO plantage
End

COMMIT

return 0

plantage:
-------------------

Select Getdate(),"roolback"

ROLLBACK

return 1

go

/*
 * fin de la procedure  */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/
IF OBJECT_ID('dbo.PiLIFEST_05') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PiLIFEST_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PiLIFEST_05 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PuLIFEST_01 */
GRANT EXECUTE ON dbo.PiLIFEST_05 TO GOMEGA
go

GRANT EXECUTE ON dbo.PiLIFEST_05 TO GCONSULT
go
GRANT EXECUTE ON dbo.PiLIFEST_05 TO GDBBATCH
go
