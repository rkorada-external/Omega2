use BSAR
go
if object_id('dbo.PsTSEGPOR_SEG') is not null
begin
  drop PROC dbo.PsTSEGPOR_SEG
  print '<<< DROPPED PROC dbo.PsTSEGPOR_SEG >>>'
end
go
create procedure dbo.PsTSEGPOR_SEG
  (
  @P_SSD_CF    USSD_CF
 ,@P_SEGTYP_CT USEGTYP_CT
 ,@P_TYPEINV_CF char(4)
  )
as
/***************************************************
Domaine : Estimations
Base principale : BEST
Auteur: Florent
Date de creation: 17/10/2014
Description du programme: :spot:27466 Extraction du p�rim�tre au format de BSAR..TSEGPOR (table plus utilis�e)
Conditions d'execution: par les batch asynchrones de la segmentation
Commentaires:
_________________
MODIFICATIONS
1 Florent 30/10/2014 :spot:27722 on prend la derni�re c�dante du contrat valide pour le test de la r�tro interne
2 Florent 01/06/2015 :spot:28694 Segmentation VIE
3 Florent 24/05/2017 :spira:58025 Cr�ation de la proc en BEST avec nouveau nom
[004] Roger 18/08/2017 :spira:63448 Les requetes se font sur BMIS au lieu du TP (comme ancienne proc)
5 M.NAJI add  25/10/2018 Ajout de l'exercice  :spira5605 ,REQ.P.03.2
6 DaD     06/03/2023  : 109076 : feat<109076> DaD - Flagged contracts- Closing version in anomaly
7 DaD     26/09/2023  : 109347 : EBS/I17 - Fac status Accepted only POS
8 DaD     26/04/2024  : 111368 : replace the NOT IN by IN with theses statuses and reduced to 12 and 14 for fac, 12 for trt
9 M.NAJI  05/08/2024  : Spira 112013 PRD- Issue with ULR load

*****************************************************/
print '@P_SEGTYP_CT %1!, @P_SSD_CF %2!, @P_TYPEINV_CF %3!',@P_SEGTYP_CT,@P_SSD_CF,@P_TYPEINV_CF

declare
    @V_SSD_CF          varchar(2),
    @SQL_REF_SELECT    varchar(254),
    @SQL_SELECT_1      varchar(254),
    @SQL_SELECT_2      varchar(254),
    @SQL_SELECT_3      varchar(254),
    @SQL_SELECT_4      varchar(254),
    @SQL_SELECT_5      varchar(3000),
    @SQL_JOIN_1        varchar(254),
    @SQL_JOIN_2        varchar(254),
    @SQL_JOIN_3        varchar(254)

declare @STS_LIST table (Id TINYINT)

insert into @STS_LIST values (16)
insert into @STS_LIST values (18)
insert into @STS_LIST values (19)
IF(@P_TYPEINV_CF = 'POS')
BEGIN
    insert into @STS_LIST values (14)
END

select @V_SSD_CF=convert(varchar,@P_SSD_CF)

if exists (select 1 from BREF..TESB where LIFE_CF = 2 and SSD_CF = @P_SSD_CF)
    select @SQL_REF_SELECT = "Y" --- "case when c.CTRTYP_CT=2 then 'F' when c.CTRTYP_CT=1 and s.NAT_CF < '30' then 'P' else 'N' end"
else
    select @SQL_REF_SELECT = "N" --- "case when s.NAT_CF < '30' then 'P' else 'N' end"


CREATE TABLE #TSEGPOR_SEG
(
   CTR_NF      UCTR_NF NOT NULL,
   END_NT      UEND_NT NOT NULL,
   SEC_NF      USEC_NF NOT NULL,
   SEGTYP_CT   USEGTYP_CT DEFAULT '' NOT NULL,
   SSD_CF      USSD_CF NOT NULL,
   CTRNAT_CF   char(1) NULL,
   CTRRET_B    tinyint DEFAULT 0 NOT NULL,
   UWY_NF      smallint NULL
)

----------------PREPARE TSEGPOR DATA (in tmp table #tt)----------------
SELECT DISTINCT
    c.CTR_NF
    ,c.END_NT
    ,s.SEC_NF
    ,c.SSD_CF
    ,c.UWY_NF
    ,SEGTYP_CT = @P_SEGTYP_CT
    ,CTRRET_B = isnull ( (SELECT CASE WHEN i.CLISSD_CF = NULL THEN 0 ELSE 1 END
                            FROM BCLI..TCLIENT i
                            WHERE i.CLI_NF = (SELECT max (y.CED_NF)
                                                FROM BMIS..TCONTR y
                                                WHERE y.CTR_NF = c.CTR_NF
                                                AND y.UWY_NF = (SELECT max (z.UWY_NF)
                                                                    FROM BMIS..TCONTR z
                                                                    WHERE c.CTR_NF = z.CTR_NF
                                                                    AND z.CTRTYP_CT = 1
                                                                    AND z.CTRSTS_CT IN (14, 16, 17, 19, 23)
                                                                )
                                                )
                            ),
            0)
    ,c.CTRTYP_CT
    ,s.LOB_CF
    ,c.CTRSTS_CT 
    ,s.SECSTS_CT 
    ,s.SECACCSTS_CT 
    ,c.ESTCRB_CT
	,CTRNAT_CF = case when @SQL_REF_SELECT = 'Y' then 
							case when c.CTRTYP_CT=2 then 'F' when c.CTRTYP_CT=1 and s.NAT_CF < '30' then 'P' else 'N' end
					  else
							case when s.NAT_CF < '30' then 'P' else 'N' end
					   end
    ,CTR_NF_fs=fs.CTR_NF    --6
    ,CTR_NF_ts=ts.CTR_NF    --6
INTO #tt
FROM BMIS..TSECTION s
JOIN BMIS..TCONTR c ON c.SSD_CF = @P_SSD_CF
    AND c.CTR_NF = s.CTR_NF
    AND c.UWY_NF = s.UWY_NF
    AND c.UW_NT = s.UW_NT
    AND c.END_NT = s.END_NT
    AND c.SSD_CF = s.SSD_CF
    AND s.SSD_CF = @P_SSD_CF
LEFT OUTER JOIN BFAC..TSECIFRS fs ON fs.FRCIFRSBTCH_NT = 1                                     --6
    AND fs.UWY_NF = s.UWY_NF
    AND fs.UW_NT = s.UW_NT
    AND fs.CTR_NF = s.CTR_NF
    AND fs.end_nt = s.end_nt
    AND fs.sec_nf = s.sec_nf
LEFT OUTER JOIN BTRT..TSECIFRS ts ON ts.FRCIFRSBTCH_NT = 1                                     --6
    AND ts.UWY_NF = s.UWY_NF
    AND ts.UW_NT = s.UW_NT
    AND ts.CTR_NF = s.CTR_NF
    AND ts.end_nt = s.end_nt
    AND ts.sec_nf = s.sec_nf
             
--insert in tmp table #TSEGPOR_SEG to avoid line duplication
IF EXISTS (SELECT 1 FROM BREF..TESB WHERE LIFE_CF = 2 AND SSD_CF = @P_SSD_CF)
BEGIN
----------------PREPARE TSEGPOR DATA (in tmp table #TSEGPOR_SEG) P&C----------------
	INSERT #TSEGPOR_SEG (CTR_NF, END_NT, SEC_NF, SEGTYP_CT, SSD_CF, CTRNAT_CF , CTRRET_B, UWY_NF)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, SEGTYP_CT, SSD_CF, CTRNAT_CF , CTRRET_B, UWY_NF
    FROM #tt
    WHERE  ( 
        ( CTRTYP_CT = 1
            AND LOB_CF NOT IN ('30', '31')
            AND SECSTS_CT IN (14, 16, 17, 19, 23)
            AND CTRSTS_CT IN (14, 16, 17, 19, 23)
        )
        OR ( CTRTYP_CT = 2
                AND SECSTS_CT IN (select Id from @STS_LIST)
                AND CTRSTS_CT IN (select Id from @STS_LIST)
            )
        OR ( SECSTS_CT IN (12, 14)
                AND CTRSTS_CT IN (12, 14)
                AND CTR_NF_fs != NULL
            ) --[006] Includes forced FAC onerous contract
        OR ( SECSTS_CT IN (12)
                AND CTRSTS_CT IN (12)
                AND CTR_NF_ts != NULL
            ) --[006] Includes forced TRT onerous contract
    )
    AND SECACCSTS_CT != 9
END
ELSE
BEGIN
----------------PREPARE TSEGPOR DATA (in tmp table #TSEGPOR_SEG) FOR LIFE----------------
    INSERT #TSEGPOR_SEG (CTR_NF, END_NT, SEC_NF, SEGTYP_CT, SSD_CF, CTRNAT_CF , CTRRET_B, UWY_NF)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, SEGTYP_CT, SSD_CF, CTRNAT_CF , CTRRET_B, UWY_NF
    FROM #tt
    WHERE LOB_CF IN ('30', '31')
    AND SECSTS_CT IN (14, 16, 17, 19, 23)
    AND CTRSTS_CT IN (14, 16, 17, 19, 23)
    AND SECACCSTS_CT != 9
    AND ESTCRB_CT = 'E'
END

----------------FINAL TSEGPOR OUTPUT----------------
CREATE UNIQUE CLUSTERED INDEX iSEGPOR_SEG ON #TSEGPOR_SEG (CTR_NF, END_NT, SEC_NF, UWY_NF)
SELECT * FROM #TSEGPOR_SEG ORDER BY CTR_NF, END_NT, SEC_NF, UWY_NF

go
EXEC sp_procxmode 'dbo.PsTSEGPOR_SEG', 'unchained'
go
if object_id('dbo.PsTSEGPOR_SEG') is not null
  print '<<< CREATED PROC dbo.PsTSEGPOR_SEG >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsTSEGPOR_SEG >>>'
go
grant execute on dbo.PsTSEGPOR_SEG TO GOMEGA, GDBBATCH
go

