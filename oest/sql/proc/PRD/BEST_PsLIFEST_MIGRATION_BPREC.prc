USE BEST
go
IF OBJECT_ID('dbo.PsLIFEST_MIGRATION_BPREC') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFEST_MIGRATION_BPREC
    IF OBJECT_ID('dbo.PsLIFEST_MIGRATION_BPREC') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFEST_MIGRATION_BPREC >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFEST_MIGRATION_BPREC >>>'
END
go
/*
 * creation de la procedure
*/

create procedure dbo.PsLIFEST_MIGRATION_BPREC
   (
     @p_balshtyea_nf	 smallint,
     @ssd_cf       smallint
   )
as
/***************************************************

Programme: PsLIFEST_MIGRATION_BPREC

Fichier script associé : PsLIFEST_MIGRATION_BPREC.prc

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: R. BEN EZZINE

Date de creation: 29/04/2014

Description du programme:
Migration : Reprise des données TLIFEST sur les bilan précédents (< 2014)

Parametres: @p_balshtyea_nf	 
            @ssd_cf

Conditions d'execution:

Commentaires:

________________
MODIFICATION   : 
*****************************************************/

-- Création des tables temporaires
If Object_id('#lifest') Is Not Null
	Drop Table #lifest


create TABLE #lifest
  (
      CTR_NF       UCTR_NF    NOT null
     ,END_NT       smallint   NOT null
     ,SEC_NF       USEC_NF    NOT null
     ,UWY_NF       UUWY_NF    NOT null
     ,UW_NT        smallint   NOT null
     ,CRE_D        datetime   null
     ,BALSHEY_NF   Smallint   NOT null
     ,BALSHTMTH_NF Smallint   NOT null
     ,ACY_NF       Smallint   NOT null
     ,PRS_CF       Smallint   NOT null
     ,ACMTRS_NT    Smallint   null
     ,DETTRNCOD_CF       CHAR(5)    null
     ,DETTRS_CF    CHAR(5)    null
     ,SSD_CF       Smallint   NOT null
     ,CUR_CF       UCUR_CF    DEFAULT '' NOT null
     ,ESTMNT_M     UAMT_M     NOT null
     ,INDSUP_B     Int        null
     ,LOB_CF       char(2) null --ULOB_CF    null
     ,ORICOD_LS    VARCHAR(30)    null
     ,CREUSR_CF    UUPDUSR_CF DEFAULT user NOT null
     ,LSTUPD_D     datetime   null
     ,LSTUPDUSR_CF UUPDUSR_CF DEFAULT user NOT null
     ,NUMLINE_NT   Numeric(10,0) IDENTITY
     ,GAAP_NT   Smallint   DEFAULT 0 NOT null 
     ,DIFF_M UAMT_M     null 
  )

-- Création des tables temporaires
If Object_id('#lifest1') Is Not Null
	Drop Table #lifest1
	
create TABLE #lifest_1
  (
      CTR_NF       UCTR_NF    NOT null
     ,END_NT       smallint   NOT null
     ,SEC_NF       USEC_NF    NOT null
     ,UWY_NF       UUWY_NF    NOT null
     ,UW_NT        smallint   NOT null
     ,CRE_D        datetime   null
     ,BALSHEY_NF   Smallint   NOT null
     ,BALSHTMTH_NF Smallint   NOT null
     ,ACY_NF       Smallint   NOT null
     ,PRS_CF       Smallint   NOT null
     ,ACMTRS_NT    Smallint   null
     ,DETTRNCOD_CF       CHAR(5)    null
     ,DETTRS_CF    CHAR(5)    null
     ,SSD_CF       Smallint   NOT null
     ,CUR_CF       UCUR_CF    DEFAULT '' NOT null
     ,ESTMNT_M     UAMT_M     NOT null
     ,INDSUP_B     Int        null
     ,LOB_CF       char(2) null --ULOB_CF    null
     ,ORICOD_LS    VARCHAR(30)    null
     ,CREUSR_CF    UUPDUSR_CF DEFAULT user NOT null
     ,LSTUPD_D     datetime   null
     ,LSTUPDUSR_CF UUPDUSR_CF DEFAULT user NOT null
     ,NUMLINE_NT   Numeric(10,0) IDENTITY
     ,GAAP_NT   Smallint   DEFAULT 0 NOT null 
     ,DIFF_M UAMT_M     null 
  )

-- Création des tables temporaires
If Object_id('#lifest_final') Is Not Null
	Drop Table #lifest_final
	
  create TABLE #lifest_final
  (
      CTR_NF       UCTR_NF    NOT null
     ,END_NT       smallint   NOT null
     ,SEC_NF       USEC_NF    NOT null
     ,UWY_NF       UUWY_NF    NOT null
     ,UW_NT        smallint   NOT null
     ,CRE_D        datetime   null
     ,BALSHEY_NF   Smallint   NOT null
     ,BALSHTMTH_NF Smallint   NOT null
     ,ACY_NF       Smallint   NOT null
     ,PRS_CF       Smallint   NOT null
     ,ACMTRS_NT    Smallint   null
     ,DETTRNCOD_CF       CHAR(5)    null
     ,DETTRS_CF    CHAR(5)    null
     ,SSD_CF       Smallint   NOT null
     ,CUR_CF       UCUR_CF    DEFAULT '' NOT null
     ,ESTMNT_M     UAMT_M     NOT null
     ,INDSUP_B     Int        null
     ,LOB_CF       char(2) null --ULOB_CF    null
     ,ORICOD_LS    VARCHAR(30)    null
     ,CREUSR_CF    UUPDUSR_CF DEFAULT user NOT null
     ,LSTUPD_D     datetime   null
     ,LSTUPDUSR_CF UUPDUSR_CF DEFAULT user NOT null
     ,NUMLINE_NT   Numeric(10,0) IDENTITY
     ,GAAP_NT   Smallint   DEFAULT 0 NOT null 
     ,DIFF_M UAMT_M     null 
     ,NAT_CF   UCTRNAT_CF not null
     ,ESB_CF  UESB_CF not null
  )

-- Création des tables temporaires
If Object_id('#TACCPAR_USER') Is Not Null
	Drop Table #TACCPAR_USER  
  
CREATE TABLE #TACCPAR_USER
(
    ACMTRS_NT     smallint   NOT NULL,
    DETTRNCOD_CF  char(5)    NOT NULL,
    SUMRISK_B     bit        DEFAULT 0         NOT NULL
)

INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1010,'10000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1011,'10120')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1140,'12000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1150,'12400')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1100,'14000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1110,'14300')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1160,'15000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1220,'20000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1200,'20020')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1210,'20080')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1022,'30000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1021,'30100')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1232,'32000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1231,'32100')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1063,'40000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1064,'40100')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1093,'40040')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1094,'40140')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1503,'41000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1533,'41010')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1633,'41010')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1504,'41100')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1603,'41000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1604,'41100')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1534,'41110')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1634,'41110')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1243,'42000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1263,'42000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1244,'42100')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1264,'42100')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1523,'43000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1623,'43000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1524,'43100')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1624,'43100')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1163,'43200')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1183,'43300')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1184,'43400')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1164,'43500')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1193,'43800')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1194,'43900')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1303,'81200')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1304,'81300')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1323,'81400')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1324,'81500')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1340,'82100')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1350,'90320')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1360,'90330')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1900,'50000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1901,'50400')

INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1073,'40010')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1074,'40110')

INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1083,'49000')
INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(1084,'49100')

INSERT INTO #TACCPAR_USER
select ACMTRS_NT+1000,DETTRNCOD_CF,0 from #TACCPAR_USER

update #TACCPAR_USER set DETTRNCOD_CF = '12110' where ACMTRS_NT = 2150 

INSERT INTO #TACCPAR_USER (ACMTRS_NT,DETTRNCOD_CF) VALUES(2145,'12400')

UPDATE #TACCPAR_USER
set SUMRISK_B =1
where ACMTRS_NT in (1010,1011,1021,1022,1073,1083,1100,1110,1140,1150,1160,2010,2011,2021,
                         2022,2073,2083,2100,2110,2140,2150,2160)	

--select * from #TACCPAR_USER
-----------------------------------------------------------------------------------------------------------

insert into #lifest
select a.CTR_NF,
       a.END_NT,
       a.SEC_NF,
       a.UWY_NF,
       a.UW_NT,
       a.CRE_D,
       a.BALSHEY_NF,
       a.BALSHTMTH_NF,
       a.ACY_NF, 
       a.PRS_CF,
       a.ACMTRS_NT,
       b.DETTRNCOD_CF,
       ' ',
       a.SSD_CF,
       a.CUR_CF, 
       a.ESTMNT_M,
       a.INDSUP_B,
       " " lob_cf,
       a.ORICOD_LS,
       a.CREUSR_CF,
       a.LSTUPD_D,
       a.LSTUPDUSR_CF,
       1 GAAP_NT,
       0 DIFF_M         
  from BEST..TLIFEST a,
         #TACCPAR_USER b
 where a.BALSHEY_NF = @p_balshtyea_nf
   and a.acmtrs_nt=b.acmtrs_nt
   and a.SSD_CF = @ssd_cf 
   /*and a.cre_d = (select max(cre_d) from BEST..TLIFEST c 
                                                where a.BALSHEY_NF = c.BALSHEY_NF
                                                   and a.ctr_nf=c.ctr_nf
                                                   and a.sec_nf=c.sec_nf
                                                   and a.uwy_nf=c.uwy_nf
                                                   and a.acy_nf=c.acy_nf
                                                   and a.acmtrs_nt=c.acmtrs_nt)*/
                                                   
     
create index I_LIFEST2 on #lifest(BALSHEY_NF,GAAP_NT) 
create index I_LIFEST3 on #lifest(ACMTRS_NT,GAAP_NT) 



-- Eliminer les enregistrements où il n'y a pas de numéro de contrat
delete from #lifest where ctr_nf ='         '
 


----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-- Créer le deuxième gaap à partir du gaap 1

insert into #lifest
   select a.CTR_NF,
               a.END_NT,
               a.SEC_NF,
               a.UWY_NF,
               a.UW_NT,
               a.CRE_D,
               a.BALSHEY_NF,
               a.BALSHTMTH_NF,
               a.ACY_NF, 
               a.PRS_CF,
               ACMTRS_NT,
               DETTRNCOD_CF,
               ' ' ,
               a.SSD_CF,
               a.CUR_CF, 
               ESTMNT_M,
               a.INDSUP_B,
               a.lob_cf,
               a.ORICOD_LS,
               'D004'  CREUSR_CF,
               getdate() LSTUPD_D,
               'D004'  LSTUPDUSR_CF,
               2 GAAP_NT, 
               DIFF_M
   from #lifest a 
  where GAAP_NT =1 
  insert into #lifest
   select a.CTR_NF,
               a.END_NT,
               a.SEC_NF,
               a.UWY_NF,
               a.UW_NT,
               a.CRE_D,
               a.BALSHEY_NF,
               a.BALSHTMTH_NF,
               a.ACY_NF, 
               a.PRS_CF,
               ACMTRS_NT,
               DETTRNCOD_CF,
               ' ' ,
               a.SSD_CF,
               a.CUR_CF, 
               a.ESTMNT_M ,
               a.INDSUP_B,
               a.lob_cf,
               a.ORICOD_LS,
               'D004'  CREUSR_CF,
               getdate() LSTUPD_D,
               'D004'  LSTUPDUSR_CF,
               3 GAAP_NT, 
               DIFF_M 
   from #lifest a where GAAP_NT =2

   
   insert into #lifest
   select a.CTR_NF,
               a.END_NT,
               a.SEC_NF,
               a.UWY_NF,
               a.UW_NT,
               a.CRE_D,
               a.BALSHEY_NF,
               a.BALSHTMTH_NF,
               a.ACY_NF, 
               a.PRS_CF,
               ACMTRS_NT,
               DETTRNCOD_CF,
               ' ' ,
               a.SSD_CF,
               a.CUR_CF, 
               a.ESTMNT_M,
               a.INDSUP_B,
               a.lob_cf,
               a.ORICOD_LS,
               'D004'  CREUSR_CF,
               getdate() LSTUPD_D,
               'D004'  LSTUPDUSR_CF,
               4 GAAP_NT, 
               DIFF_M
   from #lifest a where GAAP_NT =3

   
   insert into #lifest
   select a.CTR_NF,
               a.END_NT,
               a.SEC_NF,
               a.UWY_NF,
               a.UW_NT,
               a.CRE_D,
               a.BALSHEY_NF,
               a.BALSHTMTH_NF,
               a.ACY_NF, 
               a.PRS_CF,
               ACMTRS_NT,
               DETTRNCOD_CF,
               ' ' ,
               a.SSD_CF,
               a.CUR_CF, 
               a.ESTMNT_M,
               a.INDSUP_B,
               a.lob_cf,
               a.ORICOD_LS,
               'D004'  CREUSR_CF,
               getdate() LSTUPD_D,
               'D004'  LSTUPDUSR_CF,
               5 GAAP_NT, 
               DIFF_M 
   from #lifest a where GAAP_NT =1
    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- gaap > 1 et gaap <> 4

update #lifest
   set ACMTRS_NT = 1063 ,
        DETTRNCOD_CF ='40000',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt in (1073,1083)
   and GAAP_NT !=4
   and GAAP_NT >1
   
   update #lifest
   set ACMTRS_NT = 1064 ,
        DETTRNCOD_CF ='40100',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt in (1074,1084)
   and GAAP_NT !=4
   and GAAP_NT >1
   ---------------------------------------------
   update #lifest
   set ACMTRS_NT = 2063 ,
        DETTRNCOD_CF ='40000',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt in (2073,2083)
   and GAAP_NT !=4
   and GAAP_NT >1
   
    update #lifest
   set ACMTRS_NT = 2064 ,
        DETTRNCOD_CF ='40100',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt in (2074,2084)
   and GAAP_NT !=4
   and GAAP_NT >1

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- gaap > 1 

update #lifest
   set ACMTRS_NT = 1503 ,
        DETTRNCOD_CF ='41000',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 1603
   and GAAP_NT >1
   
   update #lifest
   set ACMTRS_NT = 1504 ,
        DETTRNCOD_CF ='41100',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 1604
   and GAAP_NT >1
  ---------------------
   update #lifest
   set ACMTRS_NT = 2503 ,
        DETTRNCOD_CF ='41000',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 2603
   and GAAP_NT >1
   
    update #lifest
   set ACMTRS_NT = 2504 ,
        DETTRNCOD_CF ='41100',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 2604
   and GAAP_NT >1
   
   -----------------------------------------------------
  update #lifest
   set ACMTRS_NT = 1533 ,
        DETTRNCOD_CF ='41010',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 1633
   and GAAP_NT >1
   
   update #lifest
   set ACMTRS_NT = 1534 ,
        DETTRNCOD_CF ='41110',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 1634
   and GAAP_NT >1
   
   -----------------------------
   
   update #lifest
   set ACMTRS_NT = 2533 ,
        DETTRNCOD_CF ='41010',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 2633
   and GAAP_NT >1
   
    update #lifest
   set ACMTRS_NT = 2534 ,
        DETTRNCOD_CF ='41110',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 2634
   and GAAP_NT >1
  
  ----------------------------------------------------------- 
    update #lifest
   set ACMTRS_NT = 1243 ,
        DETTRNCOD_CF ='42000',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 1263
   and GAAP_NT >1
   and SSD_CF not in (14,25,26)
   
   update #lifest
   set ACMTRS_NT = 1244 ,
        DETTRNCOD_CF ='42100',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 1264
   and GAAP_NT >1
   and SSD_CF not in (14,25,26)
   ---------------------------------
   
      update #lifest
   set ACMTRS_NT = 2243 ,
        DETTRNCOD_CF ='42000',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 2263
   and GAAP_NT >1
   and SSD_CF not in (14,25,26)
   
    update #lifest
   set ACMTRS_NT = 2244 ,
        DETTRNCOD_CF ='42100',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 2264
   and GAAP_NT >1
   and SSD_CF not in (14,25,26)
  
  ---------------------------------------------------------------------
    update #lifest
   set ACMTRS_NT = 1523 ,
        DETTRNCOD_CF ='43000',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 1623
   and GAAP_NT >1
   
    update #lifest
   set ACMTRS_NT = 1524 ,
        DETTRNCOD_CF ='43100',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 1624
   and GAAP_NT >1
   
   ------------------------------
   
      update #lifest
   set ACMTRS_NT = 2523 ,
        DETTRNCOD_CF ='43000',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 2623
   and GAAP_NT >1
   
   update #lifest
   set ACMTRS_NT = 2524 ,
        DETTRNCOD_CF ='43100',
        ORICOD_LS = ORICOD_LS
where acmtrs_nt = 2624
   and GAAP_NT >1

---------------------------------------------------------------------------------------------------------------

    --delete from #lifest
    update #lifest 
    set ESTMNT_M = 0,
        ORICOD_LS = 'SUPP G1'
    where acmtrs_nt in (1163, 1164, 2163, 2164,1183, 1184, 2183, 2184, 1193, 1194, 2193, 2194)
   and GAAP_NT = 1
   
   -- US
   --delete from #lifest
   update #lifest 
    set ESTMNT_M = 0,
        ORICOD_LS = 'SUPP G1 US'
    where acmtrs_nt in (1063, 1064, 2063, 2064)
   and GAAP_NT = 1
   and SSD_CF in (14,25,26)
   
    --delete from #lifest
    update #lifest 
    set ESTMNT_M = 0,
        ORICOD_LS = 'SUPP G1 US'
    where acmtrs_nt in (1243, 1244, 2243, 2244, 1263, 1264, 2263, 2264)
   and GAAP_NT = 1
   and SSD_CF in (14,25,26)
   
----------------------------

   --delete from #lifest
   update #lifest 
    set ESTMNT_M = 0,
        ORICOD_LS = 'SUPP G2et5 US'
   where acmtrs_nt in (1183, 1184, 2183, 2184)
   and GAAP_NT in (2,5)
   and SSD_CF not in (14,25,26)
   
   -- US
   update #lifest
   set DETTRNCOD_CF ='43800'
   where acmtrs_nt in (1183,2183)
   and GAAP_NT in (2,5)
   and SSD_CF in (14,25,26)
   
    update #lifest
   set DETTRNCOD_CF ='43900'
   where acmtrs_nt in (1184, 2184)
   and GAAP_NT in (2,5)
   and SSD_CF in (14,25,26)

------------------------------

 --delete from #lifest
 update #lifest 
    set ESTMNT_M = 0,
        ORICOD_LS = 'SUPP G3et4'
   where acmtrs_nt in (1163, 1164, 2163, 2164)
   and GAAP_NT in (3,4)
   
   --delete from #lifest
   update #lifest 
   set ESTMNT_M = 0,
        ORICOD_LS = 'SUPP G3et4'
   where acmtrs_nt in (1193, 1194, 2193, 2194)
   and GAAP_NT in (3,4)
   
---------- Fin du GAPP  ---------------------------------

-- regrouper les acmtrs et dettrncod 
--truncate table #lifest_1
 insert into #lifest_1
  select a.CTR_NF,
               a.END_NT,
               a.SEC_NF,
               a.UWY_NF,
               a.UW_NT,
               max(a.CRE_D) CRE_D,
               a.BALSHEY_NF,
               a.BALSHTMTH_NF,
               a.ACY_NF, 
               a.PRS_CF,
               ACMTRS_NT,
               DETTRNCOD_CF,
               ' ' ,
               a.SSD_CF,
               a.CUR_CF, 
               sum(a.ESTMNT_M) ESTMNT_M,
               min(a.INDSUP_B) INDSUP_B,
               ' ' lob_cf,
               max(ORICOD_LS) ORICOD_LS,
               'D004'  CREUSR_CF,
               getdate() LSTUPD_D,
               'D004'  LSTUPDUSR_CF,
               GAAP_NT, 
               sum(DIFF_M)
 from #lifest  a
 where a.ORICOD_LS not like 'SUPP%'
group by CTR_NF,
             END_NT,
             SEC_NF,
             UWY_NF,
             UW_NT,
             BALSHEY_NF,
             BALSHTMTH_NF,
             ACY_NF,
             PRS_CF, 
             ACMTRS_NT, 
             DETTRNCOD_CF, 
             a.SSD_CF,
             a.CUR_CF,
             GAAP_NT
 
 --  select count(1) from #lifest_1
 create UNIQUE index I_LIFEST_01 on #lifest_1(CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF,PRS_CF, ACMTRS_NT, DETTRNCOD_CF, GAAP_NT)
 

drop table #lifest

----------------------------------------------------------------------------------------------------------------------------------------------------------------


update #lifest_1
set lob_cf = a.lob_cf
from btrt..tsection a, #lifest_1 b
 where a.ctr_nf=b.ctr_nf
    and a.sec_nf=b.sec_nf
    and a.uwy_nf=b.uwy_nf
    and a.lob_cf in ('30','31')  

   
update #lifest_1
set lob_cf = a.lob_cf
from btrt..tsection a, #lifest_1 b
 where a.ctr_nf=b.ctr_nf
    and a.sec_nf=b.sec_nf
    and b.lob_cf =' '
    and a.uwy_nf = (select max(uwy_nf) from btrt..tsection c where a.ctr_nf=c.ctr_nf
                            and a.sec_nf=c.sec_nf)
    and a.lob_cf in ('30','31')  
    
    
update #lifest_1
set lob_cf = a.lob_cf    
     from bret..tretsec a, #lifest_1 b
 where a.retctr_nf = b.ctr_nf
   and a.retsec_nf = b.sec_nf
   and a.rty_nf    = b.uwy_nf
   and a.lob_cf in ('30','31')
   
   update #lifest_1
set lob_cf = a.lob_cf    
     from bret..tretsec a, #lifest_1 b
 where a.retctr_nf = b.ctr_nf
   and a.retsec_nf = b.sec_nf
   and b.lob_cf = ' ' 
   and a.rty_nf  = (select max(rty_nf) from bret..tretsec c where a.retctr_nf=c.retctr_nf
                            and a.retsec_nf=c.retsec_nf)
   and a.lob_cf in ('30','31')
   
---- Lifest finale avec NAT_CF et ESB_CF ---------------------------------------------------------------------------------

insert into #lifest_final  
  select a.CTR_NF,
           a.END_NT,
           a.SEC_NF,
           a.UWY_NF,
           a.UW_NT,
           a.CRE_D,
           a.BALSHEY_NF,
           a.BALSHTMTH_NF,
           a.ACY_NF, 
           a.PRS_CF,
           a.ACMTRS_NT,
           a.DETTRNCOD_CF,
           a.lob_cf,
           a.SSD_CF,
           a.CUR_CF, 
           a. ESTMNT_M,
           a.INDSUP_B,
           a.lob_cf,
           a.ORICOD_LS,
           a.CREUSR_CF,
           a.LSTUPD_D,
           a.LSTUPDUSR_CF,
           a.GAAP_NT, 
           a.DIFF_M,
           '00',
           0
    from #lifest_1 a 
    

update #lifest_final
     set NAT_CF = a.NAT_cf
   from btrt..tsection a, #lifest_final b
 where a.ctr_nf=b.ctr_nf
    and a.sec_nf=b.sec_nf
    and a.uwy_nf=b.uwy_nf
    and a.lob_cf in ('30','31') 

    
update #lifest_final
     set NAT_CF = a.NAT_cf
   from btrt..tsection a, #lifest_final b
 where a.ctr_nf=b.ctr_nf
    and a.sec_nf=b.sec_nf
    and a.uwy_nf=(select max(uwy_nf) from btrt..tsection c where a.ctr_nf=c.ctr_nf
                            and a.sec_nf=c.sec_nf)
    and b.NAT_CF ='00'
    and a.lob_cf in ('30','31') 

    
update #lifest_final
     set NAT_CF = a.NAT_cf 
   from bret..tretsec a, #lifest_final b
  where a.retctr_nf = b.ctr_nf
    and a.retsec_nf = b.sec_nf
    and a.rty_nf    = b.uwy_nf
    and a.lob_cf in ('30','31')
    
    update #lifest_final
     set NAT_CF = a.NAT_cf 
   from bret..tretsec a, #lifest_final b
  where a.retctr_nf = b.ctr_nf
    and a.retsec_nf = b.sec_nf
    and a.rty_nf    = (select max(rty_nf) from bret..tretsec c where a.retctr_nf=c.retctr_nf
                            and a.retsec_nf=c.retsec_nf)
    and b.NAT_CF ='00'
    and a.lob_cf in ('30','31')   
    
   



    update #lifest_final   
      set ESB_CF = a.ACCESB_cf
    from btrt..tcontr a, #lifest_final b
  where b.ctr_nf   = a.ctr_nf
     and b.uwy_nf = a.uwy_nf 
     and b.SSD_CF = a.SSD_CF
     
   
   update #lifest_final   
      set ESB_CF = a.ACCESB_cf 
    from btrt..tcontr a, #lifest_final b 
   where b.ctr_nf   = a.ctr_nf    
     and a.uwy_nf = (select max(uwy_nf) from btrt..tcontr c 
                                     where a.ctr_nf=c.ctr_nf
                                       and a.SSD_CF=c.SSD_CF)
     and b.SSD_CF = a.SSD_CF
     and b.ESB_CF = 0
    
    
 update #lifest_final   
    set ESB_CF = a.ESB_cf
          
   from bret..tretctr a, #lifest_final b
  where b.ctr_nf   = a.retctr_nf
    and b.uwy_nf = a.rty_nf 
    and b.SSD_CF = a.SSD_CF
     
  
   update #lifest_final   
      set ESB_CF = a.ESB_cf
         
     from bret..tretctr a, #lifest_final b 
    where b.ctr_nf  = a.retctr_nf     
      and a.rty_nf = (select max(rty_nf) from bret..tretctr c 
                                     where a.retctr_nf=c.retctr_nf
                                       and a.SSD_CF=c.SSD_CF) 
      and b.SSD_CF = a.SSD_CF
      and b.ESB_CF = 0


      
     
 -- Filiale Canadienne
/*     select * from #lifest_final 
      where SSD_CF = 04
        and ESB_CF in (03,04,06,07)
        and ACMTRS_NT = 2084     
        and GAAP_NT = 4
 */    
      
  update #lifest_final
       set ACMTRS_NT = 1063 ,
        DETTRNCOD_CF ='40000',
        ORICOD_LS = ORICOD_LS
     where SSD_CF = 04
        and ESB_CF in (03,04,06,07)
        and ACMTRS_NT = 1073     
        and GAAP_NT = 4
        
        
        update #lifest_final
       set ACMTRS_NT = 1064 ,
        DETTRNCOD_CF ='40100',
        ORICOD_LS = ORICOD_LS
     where SSD_CF = 04
        and ESB_CF in (03,04,06,07)
        and ACMTRS_NT = 1074     
        and GAAP_NT = 4
        
        
         update #lifest_final
       set ACMTRS_NT = 2063 ,
        DETTRNCOD_CF ='40000',
        ORICOD_LS = ORICOD_LS
     where SSD_CF = 04
        and ESB_CF in (03,04,06,07)
        and ACMTRS_NT = 2073     
        and GAAP_NT = 4
        
        
        update #lifest_final
       set ACMTRS_NT = 2064 ,
        DETTRNCOD_CF ='40100',
        ORICOD_LS = ORICOD_LS
     where SSD_CF = 04
        and ESB_CF in (03,04,06,07)
        and ACMTRS_NT = 2074     
        and GAAP_NT = 4
        
    update #lifest_final
        set ESTMNT_M = 0,
            ORICOD_LS = 'SUPP 49000'
        where SSD_CF = 04
        and ESB_CF in (03,04,06,07)
        and ACMTRS_NT in (1083,1084,2083,2084)
        and GAAP_NT = 4
        
     update #lifest_final
        set ESTMNT_M = 0,
            ORICOD_LS = 'SUPP 49000'
        where SSD_CF = 04
        and ESB_CF not in (03,04,06,07)
        and ACMTRS_NT in (1083,1084,2083,2084,1073,1074,2073,2074)
        and GAAP_NT = 4
        
    update #lifest_final
        set ESTMNT_M = 0,
            ORICOD_LS = 'SUPP 49000'
        where SSD_CF != 04
        and ACMTRS_NT in (1083,1084,2083,2084,1073,1074,2073,2074)
        and GAAP_NT = 4
        
-- NPT Premium -----------------------------------------------------------
  
update #lifest_final
     set DETTRNCOD_CF = '10110'
 where convert(smallint, NAT_CF) >= 30
    and ACMTRS_NT =1010
 
------------------------------------------------------------------------------------
  
  truncate table #lifest_1
  
  insert into #lifest_1
  select a.CTR_NF,
               a.END_NT,
               a.SEC_NF,
               a.UWY_NF,
               a.UW_NT,
               max(a.CRE_D) CRE_D,
               a.BALSHEY_NF,
               a.BALSHTMTH_NF,
               a.ACY_NF, 
               a.PRS_CF,
               ACMTRS_NT,
               DETTRNCOD_CF,
               ' ' ,
               a.SSD_CF,
               a.CUR_CF, 
               sum(a.ESTMNT_M) ESTMNT_M,
               min(a.INDSUP_B) INDSUP_B,
               ' ' lob_cf,
               ORICOD_LS,
               'D004'  CREUSR_CF,
               getdate() LSTUPD_D,
               'D004'  LSTUPDUSR_CF,
               GAAP_NT, 
               sum(DIFF_M)
 from #lifest_final  a
group by CTR_NF,
             END_NT,
             SEC_NF,
             UWY_NF,
             UW_NT,
             BALSHEY_NF,
             BALSHTMTH_NF,
             ACY_NF,
             PRS_CF, 
             ACMTRS_NT, 
             DETTRNCOD_CF, 
             a.SSD_CF,
             a.CUR_CF,   
             ORICOD_LS,
             GAAP_NT
  
  
  
  -------------------------------------------------------------------------------------------------------------------------------------
  drop table #lifest_final
  
    --delete from #lifest_1
    update #lifest_1
   set ESTMNT_M = 0,
        ORICOD_LS = 'SUPP G1 LOB30'
    where ACMTRS_NT in (1503,1523,1533, 1504,1524,1534, 2503,2523,2533,2504,2524,2534)
       and lob_cf ='30'
       and gaap_nt =1
    
    --delete from #lifest_1
    update #lifest_1
   set ESTMNT_M = 0,
        ORICOD_LS = 'SUPP G1 LOB31'
    where ACMTRS_NT in (1063,1064, 2063, 2064)
       and lob_cf ='31'
       --and gaap_nt =1
   
     update #lifest_1
   set ESTMNT_M = 0,
        ORICOD_LS = 'SUPP G1 '
    where ACMTRS_NT in (1073,1074,2073,2074,
                        1083,1084,2083,2084,
                        1603,1604,2603,2604,
                        1633,1634,2633,2634,
                        1263,1264,2263,2264,
                        1623,1624,2623,2624)
      and gaap_nt = 1
      
      update #lifest_1
         set ESTMNT_M = 0
        where ACMTRS_NT in (1063,1064,2063,2064,
                            1093,1094,2093,2094,
                            1503,1504,2503,2504,
                            1533,1534,2533,2534,
                            1243,1244,2243,2244,
                            1523,1524,2523,2524,
                            1163,1164,2163,2164,
                            1183,1184,2183,2184,
                            1193,1194,2193,2194)
         and gaap_nt = 5
----------------------------------------------------------------------------------------------
--TRUNCATE TABLE BTRAV..TLIFEST_MIG

insert into BEST..TLIFEST_H
select  
     CTR_NF	,
     END_NT	,
     SEC_NF	,
     UWY_NF	,
     UW_NT	,
     CRE_D	,
     BALSHEY_NF	,
     BALSHTMTH_NF	,
     ACY_NF	,
     GAAP_NT	,
     DETTRNCOD_CF	,
     13 ACM_NF	,
     PRS_CF	,
     ACMTRS_NT	,
     SSD_CF	,
     CUR_CF	,
     ESTMNT_M	,
     INDSUP_B	,
     ORICOD_LS	,
     CREUSR_CF	,
     LSTUPD_D	,
     LSTUPDUSR_CF	,
     null ORICTR_NF	,
     null ORISEC_NF	,
     null ORIUWY_NF	,
     DIFF_M	,
     0 PROPAGATION_B	,
     0 CALCULATED_B	,
     0 BATCH_B	
from #lifest_1
where ORICOD_LS not like 'SUPP%'

return 0
go
EXEC sp_procxmode 'dbo.PsLIFEST_MIGRATION_BPREC', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFEST_MIGRATION_BPREC') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFEST_MIGRATION_BPREC >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFEST_MIGRATION_BPREC >>>'
go
GRANT EXECUTE ON dbo.PsLIFEST_MIGRATION_BPREC TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFEST_MIGRATION_BPREC TO GDBBATCH
go
