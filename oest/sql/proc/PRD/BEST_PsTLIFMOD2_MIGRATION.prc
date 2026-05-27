USE BEST
go
IF OBJECT_ID('dbo.PsTLIFMOD2_MIGRATION') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTLIFMOD2_MIGRATION
    IF OBJECT_ID('dbo.PsTLIFMOD2_MIGRATION') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTLIFMOD2_MIGRATION >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTLIFMOD2_MIGRATION >>>'
END
go

/*
 * creation de la procedure PsTLIFMOD2_MIGRATION
*/

create procedure dbo.PsTLIFMOD2_MIGRATION
   (
     @p_balshtyea_nf	 smallint,
     @ssd_cf             smallint
   )
as
/***************************************************

Programme: PsTLIFMOD2_MIGRATION

Fichier script associé : BEST_PsTLIFMOD2_MIGRATION.prc

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: M.MECHRI

Date de creation: 13/09/2014

Description du programme:
Migration : Reprise des données TLIFMOD2
Parametres: @p_balshtyea_nf	 

Conditions d'execution:

Commentaires:
Reprise de la table TLIFMOD2
________________
MODIFICATION   : 
[001] BEN EZZINE R. : Création de la procéudre et adaptation du fonctionnement par filiale
*******************************************************************************************/
-- Déclaration des varaiables

DECLARE @creusr VARCHAR(5) 
SET @creusr='RP2B'

DECLARE @lstupdusr VARCHAR(5)
SET @lstupdusr='RP2B'


-- Recherche des derniers mouvemements de la grille TLIFEST pour l'année bilan end cours 
    
select * 
  into #lifest_last
  from best..tlifest a  
 where balshey_nf=@p_balshtyea_nf
   and ssd_cf = @ssd_cf
   and cre_d = (select max(cre_d) 
                  from best..tlifest b 
                 where a.ctr_nf=b.ctr_nf 
                   and a.sec_nf=b.sec_nf 
                   and a.uwy_nf=b.uwy_nf 
                   and a.balshey_nf=b.balshey_nf 
                   and a.acy_nf=b.acy_nf 
                   and a.acmtrs_nt=b.acmtrs_nt 
                   and a.gaap_nt=b.gaap_nt 
                   and a.dettrncod_cf = b.dettrncod_cf)

-- Création d'index sur la table temporaire

CREATE INDEX ILIFEST_00 ON #lifest_last (ACMTRS_NT,CTR_NF,SEC_NF,ACY_NF,BALSHEY_NF)

-- Recherche des derniers mouvements de la table des indicateurs TLIFDRI pour l'année bilan end cours
    
select * 
  into #lifdri_last
  from best..tlifdri a  
 where balshey_nf=@p_balshtyea_nf
   and ssd_cf = @ssd_cf
   and cre_d = (select max(cre_d) 
                  from best..tlifdri b 
                 where a.ctr_nf=b.ctr_nf 
                   and a.sec_nf=b.sec_nf 
                   and a.balshey_nf=b.balshey_nf 
                   and a.acy_nf=b.acy_nf )

-- Recherche des paramètres de la BEST TACCPAR
    
select PRS_CF,
       ACMTRS_NT,
       POSITION_NT,
       ADJCOD_CT,
       ADJSIG_B,
       RETCOD_CT,
       SPIMOD_CT,
       DETTRS_CF,
       CRE_D,
       CREUSR_CF,
       LSTUPD_D,
       LSTUPDUSR_CF,
       RESTEC_B	,
       RESDAC_B,
       RESFIN_B,
       SUMRISK_B,
       LOB_CF	   
  into #taccpar																	
  from best..TACCPAR

-- Mise à jour des paramètre pour les réserves

update #taccpar 
   set RESTEC_B = 1 , 
       RESDAC_B=1 , 
       RESFIN_B=1
 where acmtrs_nt in (1503,1523,1533,1603,1623,1633,1504,1524,1534,1604,1624,1634) 

----------------------------------------------------------------------------------------------------------------
-- Reprise des données dans la table TLIFMOD2

-- Mise à jour de la des informations de TLIFMOD2 à partir du paramétrage 

 select a.ctr_nf, 
        a.sec_nf,	
        getdate() CRE_D, 
        @p_balshtyea_nf BALSHEY_NF,
        a.BALSHTMTH_NF, 
        a.acy_nf, 
        c.COMACC_B,	
        case when a.acmtrs_nt in (1010, 1011, 2010, 2011)  then a.ESTMNT_M else 0 end  PRIPRMAMT_M,
        case when a.acmtrs_nt in (1010, 1011, 2010, 2011)  then a.ESTMNT_M else 0 end  AFTPRMAMT_M,
        case when (b.RESTEC_B = 1 OR a.acmtrs_nt in (1010, 1011, 2010, 2011)) then a.ESTMNT_M else 0 end  PRIRESTECAMT_M,
        case when (b.RESTEC_B = 1 OR a.acmtrs_nt in (1010, 1011, 2010, 2011)) then a.ESTMNT_M else 0 end  AFTRESTECAMT_M,
        case when (b.RESDAC_B = 1 OR a.acmtrs_nt in (1010, 1011, 2010, 2011)) then a.ESTMNT_M else 0 end  PRIRESDACAMT_M,
        case when (b.RESDAC_B = 1 OR a.acmtrs_nt in (1010, 1011, 2010, 2011)) then a.ESTMNT_M else 0 end  AFTRESDACAMT_M,
        case when (b.RESFIN_B = 1 OR a.acmtrs_nt in (1010, 1011, 2010, 2011)) then a.ESTMNT_M else 0 end  PRIRESFINAMT_M,
        case when (b.RESFIN_B = 1 OR a.acmtrs_nt in (1010, 1011, 2010, 2011)) then a.ESTMNT_M else 0 end  AFTRESFINAMT_M,
        a.CREUSR_CF,
        a.LSTUPD_D, 
        a.LSTUPDUSR_CF,
        a.GAAP_NT
   into #TLIFMOD2_tmp
   from #lifest_last a, #taccpar b , #lifdri_last c
  where a.acmtrs_nt=b.acmtrs_nt 
    and (a.ctr_nf = c.ctr_nf 
         and a.sec_nf = c.sec_nf 
         and a.acy_nf = c.acy_nf 
         and a.BALSHEY_NF = c.BALSHEY_NF)

-- Mettre à jour la table TLIFMOD2

insert into BEST..TLIFMOD2
          (CTR_NF,
          SEC_NF,
          CRE_D,
          BALSHEY_NF,
          BALSHTMTH_NF,
          ACY_NF,
          COMACC_B,
          PRIPRMAMT_M,
          AFTPRMAMT_M,
          PRIRESTECAMT_M,
          AFTRESTECAMT_M,
          PRIRESDACAMT_M,
          AFTRESDACAMT_M,
          PRIRESFINAMT_M,
          AFTRESFINAMT_M,
          CREUSR_CF,
          LSTUPD_D,
          LSTUPDUSR_CF,
          GAAP_NT)
   select a.ctr_nf, 
          a.sec_nf,	
          getdate() CRE_D, 
          @p_balshtyea_nf BALSHEY_NF,
          1 BALSHTMTH_NF,
          a.acy_nf, 
          a.COMACC_B,	
          sum (PRIPRMAMT_M),
          sum (AFTPRMAMT_M),
          sum (PRIRESTECAMT_M),
          sum (AFTRESTECAMT_M),
          sum (PRIRESDACAMT_M),
          sum (AFTRESDACAMT_M),
          sum (PRIRESFINAMT_M),
          sum (AFTRESFINAMT_M),
          @creusr CREUSR_CF,
          max (a.LSTUPD_D), 
          @lstupdusr LSTUPDUSR_CF,
          a.GAAP_NT
     from #TLIFMOD2_tmp a
    group by a.ctr_nf, a.sec_nf, a.acy_nf,gaap_nt, a.COMACC_B
    order by a.ctr_nf, a.sec_nf, a.acy_nf,gaap_nt, a.COMACC_B

return 0

go
EXEC sp_procxmode 'dbo.PsTLIFMOD2_MIGRATION', 'unchained'
go
IF OBJECT_ID('dbo.PsTLIFMOD2_MIGRATION') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTLIFMOD2_MIGRATION >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTLIFMOD2_MIGRATION >>>'
go
GRANT EXECUTE ON dbo.PsTLIFMOD2_MIGRATION TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTLIFMOD2_MIGRATION TO GDBBATCH
go