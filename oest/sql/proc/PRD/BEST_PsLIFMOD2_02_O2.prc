USE BEST
go
IF OBJECT_ID('dbo.PsLIFMOD2_02_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFMOD2_02_O2
    IF OBJECT_ID('dbo.PsLIFMOD2_02_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFMOD2_02_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFMOD2_02_O2 >>>'
END
go
create procedure dbo.PsLIFMOD2_02_O2
  (
  @p_CTR_NF       UCTR_NF
 ,@p_SEC_NF       USEC_NF
 ,@p_BALSHEY_NF   smallint
 ,@p_BALSHTMTH_NF tinyint
 ,@p_CRE_D        datetime=null
 ,@p_RETRO_B      bit=0
 ,@p_LAG_CF		  ULAG_CF
  )
as

/****************************************************
Programme               : PsLIFMOD2_02_O2
Fichier script associé  : BEST_PsLIFMOD2_02_O2
Domaine                 : Estimations
Base principale         : BEST
Version                 : V05.1
Auteur                  : G. BUISSON
Date de creation        : 16/06/2005
Description du programme: Spot 11213 : Aggrégation des montants par traité lors d'un dépassement de seuil
Conditions d'execution  :
Commentaires            : sans la section de @p_SEC_NF, conversion en devise filiale puis en devise du dernier exe de la section
_________________
MODIFICATIONS
1  G. BUISSON  26/09/2005 V05.1 Le calcul de la différence  (après - avant) ne se fait plus dans la DW mais dans la proc.
                           Dans la DW les champs ne sont plus des champs calculés.
2  G. BUISSON  29/06/2006 V06.1 Les postes CNA ne sont plus différenciés par filiale
3  G. BUISSON  16/11/2007 V07.2 :Spot:14286 Ajout du poste 1011 (Primes liées à la sinistralité) qui doit être géré comme le 1010
4  Florent     05/06/2008 :spot:14205 debug recherche des derniers montants pour calcul positions
5  Florent     22/12/2008 :spot:16651 ajout de l'exe pour la séléction du dernier mois bilan !!
6  Florent     27/11/2009 :spot:17244 ajout de la VOBA et de poste cumul manquant dans la retro, libellé du poste 1450 pour le résultat financier comme sur la grille estimation
               28/01/2010 :spot:17244 groupe 3 devient le 4 et le 3 (RT + CNA) devient le 4
			   			 	_________________
MODIFICATION 7

Auteur: J.CHOCHON

Date: 10/07/2012

Version:

Description: The table TACMTRSH is now obsolet
			 TACMTRSH --> TACMTRSL
			 TACMTRSH.ACMTRS_LL --> TACMTRSL.ACMTRS_GL
			 
_________________
MODIFICATIONS
M  Auteur          Date       Description
8 C.Cros   24/05/2013 :OMEGA2 - spira17670:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2

MODIFICATIONS
M  Auteur          Date       Description
9  KBagwe   20/08/2014 :OMEGA2 - spira029137:Movement file / Treaty accumulation : amounts null.
10 PColle   19/11/2014 : OMEGA2 - Treaty accumulation optimisation
*****************************************************/
declare
  @STAT_REP_D datetime
 ,@SEUIL_M    UAMT_M
 ,@CURCTR_CF  UCUR_CF
 ,@SSD_CF     USSD_CF
 ,@ESB_CF     UESB_CF
 ,@EXC_R_SEC  ULNGDEC
 ,@current_balshtyear Datetime
 ,@TYPPER  Char(1)
 ,@BLCSHTYEA_NF Smallint
 ,@erreur     integer

DECLARE 
    @StartTime datetime,
    @Time datetime
SELECT @StartTime=GETDATE() 

create Table #LISTE
  (
  ACMTRS_NT  smallint
 ,GAAP_NT 	 tinyint
 ,ESTMNT_M1  UAMT_M null
 ,ESTMNT_M2  UAMT_M null
 ,ESTMNT_M3  UAMT_M null
 ,ESTMNT_M4  UAMT_M null
 ,ESTMNT_M5  UAMT_M null
 ,ESTMNT_M6  UAMT_M null
 ,ESTMNT_M7  UAMT_M null
 ,ESTMNT_M8  UAMT_M null
 ,ESTMNT_M9  UAMT_M null
 ,AESTMNT_M1 UAMT_M null
 ,AESTMNT_M2 UAMT_M null
 ,AESTMNT_M3 UAMT_M null
 ,AESTMNT_M4 UAMT_M null
 ,AESTMNT_M5 UAMT_M null
 ,AESTMNT_M6 UAMT_M null
 ,AESTMNT_M7 UAMT_M null
 ,AESTMNT_M8 UAMT_M null
 ,AESTMNT_M9 UAMT_M null
 ,ACMTRS_GL  varchar(64) NOT null
  )

Create table #TLIFEST (
                DETTRNCOD_CF 	char(5),
				ACMTRS_NT		smallint,
				UWY_NF			UUWY_NF,
				ACY_NF			smallint,
				CTR_NF			UCTR_NF, 
				END_NT			UEND_NT, 
				SEC_NF			USEC_NF,  
				UW_NT			UUW_NT, 
				CRE_D			datetime, 
				BALSHEY_NF		smallint, 
				BALSHTMTH_NF	tinyint,  
				PRS_CF			smallint NULL,  
				SSD_CF			USSD_CF, 
				CUR_CF			UCUR_CF, 
				ESTMNT_M		UAMT_M NULL, 
				INDSUP_B		bit, 
				ORICOD_LS		varchar(16), 
				CREUSR_CF		UUSR_CF, 
				LSTUPD_D		datetime, 
				LSTUPDUSR_CF	UUSR_CF,  
				GAAP_NT			smallint,
				DIFF_M			UAMT_M NULL,
				PROPAGATION_B bit)


/* We are using BREF..PsCALEND_02 to get the current Balance sheet year (@BLCSHTYEA_NF) */
select @current_balshtyear = getdate(), @TYPPER = 'C'
execute @erreur = BREF..PsCALEND_02 @current_balshtyear, @TYPPER, @BLCSHTYEA_NF output

if @erreur != 0
    begin
        Raiserror 20005 "APPLICATIF;TACCSUP/TCALEND"
        return @erreur
    end


/* When input balance sheet year is current balance sheet year, we retrieve from TLIFEST */

IF @BLCSHTYEA_NF =  @p_BALSHEY_NF  --mod 10
begin	
Insert into #TLIFEST
Select 			t.DETTRNCOD_CF,
				t.ACMTRS_NT,
				t.UWY_NF,
				t.ACY_NF,
				t.CTR_NF, 
				t.END_NT, 
				t.SEC_NF,  
				t.UW_NT, 
				t.CRE_D, 
				t.BALSHEY_NF, 
				t.BALSHTMTH_NF,  
				t.PRS_CF,  
				t.SSD_CF, 
				t.CUR_CF, 
				t.ESTMNT_M, 
				t.INDSUP_B, 
				t.ORICOD_LS, 
				t.CREUSR_CF, 
				t.LSTUPD_D, 
				t.LSTUPDUSR_CF,  
				t.GAAP_NT,
				t.DIFF_M,
				t.PROPAGATION_B
		from   TLIFEST t
		where  
		    t.CTR_NF = @p_CTR_NF
		and    t.acy_nf 	   <= @BLCSHTYEA_NF + 4
		and    t.acy_nf 	   >= @BLCSHTYEA_NF - 4
		and    t.balshey_nf    = @BLCSHTYEA_NF
		and    t.balshtmth_nf  <= @p_BALSHTMTH_NF

end 
	ELSE
	/* Else, we retrieve from TLIFEST_H */
		begin
		Insert into #TLIFEST
		
		Select 	t.DETTRNCOD_CF,
				t.ACMTRS_NT,
				t.UWY_NF,
				t.ACY_NF,
				t.CTR_NF, 
				t.END_NT, 
				t.SEC_NF,  
				t.UW_NT, 
				t.CRE_D, 
				t.BALSHEY_NF, 
				t.BALSHTMTH_NF,  
				t.PRS_CF,  
				t.SSD_CF, 
				t.CUR_CF, 
				t.ESTMNT_M, 
				t.INDSUP_B, 
				t.ORICOD_LS, 
				t.CREUSR_CF, 
				t.LSTUPD_D, 
				t.LSTUPDUSR_CF,  
				t.GAAP_NT,
				t.DIFF_M,
				t.PROPAGATION_B
		from   TLIFEST_H t 
		where  
		    t.CTR_NF = @p_CTR_NF
		and    t.acy_nf 	   <= @BLCSHTYEA_NF + 4
		and    t.acy_nf 	   >= @BLCSHTYEA_NF - 4
		and    t.balshey_nf    = @BLCSHTYEA_NF
		and    t.balshtmth_nf  <= @p_BALSHTMTH_NF
END		


-- Il faut récupérer la filiale, l'établissement et la monnaie
-- d'Origine pour la section déjà affichée
if @p_RETRO_B=1
begin
  select @SSD_CF   =SSD_CF,
         @ESB_CF   =ESB_CF,
         @CURCTR_CF=RETPCPCUR_CF
  from   BRET..TRETCTR
  where  RETCTR_NF=@p_ctr_nf
  and    RTY_NF   =(select max(RTY_NF)
                      from   BRET..TRETCTR c
                      where  c.RETCTR_NF  =@p_ctr_nf
                      and    RETCTRSTS_CT in (3, 19))
end
else
begin
  select @SSD_CF=SSD_CF,
         @ESB_CF=ACCESB_CF
  from   BTRT..TCONTR
  where  CTR_NF=@p_ctr_nf
  and    UWY_NF=(select max(UWY_NF)
                   from   BTRT..TCONTR c
                   where  c.CTR_NF  =@p_ctr_nf
                   and    CTRSTS_CT in (14, 16, 17, 19))

  select @CURCTR_CF=PCPCUR_CF
  from   BTRT..TSECTION
  where  CTR_NF=@p_CTR_NF
  and    SEC_NF=@p_SEC_NF
  and    UWY_NF=(select max(UWY_NF)
                   from   BTRT..TSECTION c
                   where  c.CTR_NF  =@p_ctr_nf
                   and    SEC_NF    =@p_SEC_NF
                   and    SECSTS_CT in (14, 16, 17, 19))
end


select @STAT_REP_D=max(CRE_D)
from   TREQJOB
where  SSD_CF      =@SSD_CF
and    REQCOD_CT   ='L'
and    BALSHEYEA_NF=1900
and    BALSHTMTH_NF=1
and    CLODAT_D    ='19000101'

-- taux de conversion de la devise filiale vers la devise de la section dernier exe
select @EXC_R_SEC=b.EXC_R
 from BREF..TCURQUOT b
  where b.CUR_CF=@CURCTR_CF
    and b.SSD_CF=@SSD_CF
    and b.EXC_D=(select max(x.EXC_D) from BREF..TCURQUOT x where x.EXC_D<=isnull(@p_CRE_D,@STAT_REP_D) and x.CUR_CF=b.CUR_CF and x.SSD_CF=b.SSD_CF)

/* insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 1, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=1010 and SSD_CF=@SSD_CF
insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 2, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=1400 and SSD_CF=@SSD_CF
insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 3, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2450 else 1450 end) and SSD_CF=@SSD_CF
insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 4, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2460 else 1460 end) and SSD_CF=@SSD_CF -- modif 6
*/

insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 1, 1,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=1010 and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 2, 1,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=1400 and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 3, 1,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2450 else 1450 end) and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 4, 1,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2460 else 1460 end) and LAG_CF = @P_LAG_CF


insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 1, 2,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=1010 and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 2, 2,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=1400 and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 3, 2,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2450 else 1450 end) and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 4, 2,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2460 else 1460 end) and LAG_CF = @P_LAG_CF

insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 1, 3,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=1010 and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 2, 3,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=1400 and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 3, 3,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2450 else 1450 end) and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 4, 3,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2460 else 1460 end) and LAG_CF = @P_LAG_CF

insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 1, 4,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=1010 and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 2, 4,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=1400 and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 3, 4,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2450 else 1450 end) and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 4, 4,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2460 else 1460 end) and LAG_CF = @P_LAG_CF

insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 1, 5,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=1010 and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 2, 5,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=1400 and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 3, 5,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2450 else 1450 end) and LAG_CF = @P_LAG_CF
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL) select 4, 5,ACMTRS_GL from BREF..TACMTRSL where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2460 else 1460 end) and LAG_CF = @P_LAG_CF


-- en cours de la devise filiale
select @SEUIL_M=AMT_M from TLIFTHR where SSD_CF=@SSD_CF and ESB_CF=@ESB_CF

-- Liste à partir de TLIFEST
create Table #GROUPE(GP Tinyint, DETTRNCOD_CF char(5))

--Primes
      Insert into #GROUPE
	   Select
            1,
            DETTRNCOD_CF
      FROM BREF..TSUBTRSBASE tb
      WHERE tb.ACMTRS_NT = 1010
	  AND tb.PRS_CF = 569 	

--Résultat technique
    Insert into #GROUPE
      Select
            2,
            DETTRNCOD_CF
      FROM BREF..TSUBTRSBASE tb
      WHERE tb.ACMTRS_NT = 1400
	  AND tb.PRS_CF = 569

--Résultat Tech. + Financier
	Insert into #GROUPE
      Select
            3,
            DETTRNCOD_CF
      FROM BREF..TSUBTRSBASE tb
      WHERE tb.ACMTRS_NT =(case when @p_RETRO_B=1 then 2450 else 1450 end) -- Pem will confirming with PP for RETROB so it can be 1450
	  AND tb.PRS_CF = 569	
	  
	--Résultat Tech. + Financier + CNA + VOBA
      Insert into #GROUPE
      Select
            4,
            DETTRNCOD_CF
      FROM BREF..TSUBTRSBASE tb
      WHERE tb.ACMTRS_NT = (case when @p_RETRO_B=1 then 2460 else 1460 end) 
	  AND tb.PRS_CF = 569
  

--modif 10 
--SELECT @Time=GETDATE() 
--SELECT "2",DATEDIFF(ms,@StartTime,@Time) 

--modif 10 
CREATE CLUSTERED INDEX TLIFEST_00
    ON #TLIFEST(SEC_NF,UWY_NF,ACY_NF,GAAP_NT,DETTRNCOD_CF,BALSHTMTH_NF,CRE_D)

-- Situation avant, conversion en devise filiale puis en devise section dernier exercice
select
  ACMTRS_NT=x.GP
 ,a.gaap_nt							--mod9
 ,ESTMNT_M1=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 4 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,ESTMNT_M2=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 3 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,ESTMNT_M3=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 2 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,ESTMNT_M4=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 1 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,ESTMNT_M5=round(sum(case when a.ACY_NF=@p_BALSHEY_NF     then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,ESTMNT_M6=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 1 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,ESTMNT_M7=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 2 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,ESTMNT_M8=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 3 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,ESTMNT_M9=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 4 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 
into #TLIFEST_AV
 from #TLIFEST a, #GROUPE x, BREF..TCURQUOT d
  where a.DETTRNCOD_CF=x.DETTRNCOD_CF
    and a.CTR_NF=@p_CTR_NF
    and a.SEC_NF!=@p_SEC_NF
    and a.ACY_NF between @p_BALSHEY_NF - 4 and @p_BALSHEY_NF + 4
    and d.CUR_CF=a.CUR_CF
    and d.SSD_CF=@SSD_CF
    and d.EXC_D=(select max(c.EXC_D) from BREF..TCURQUOT c where c.EXC_D<=isnull(@p_CRE_D,@STAT_REP_D) and c.CUR_CF=d.CUR_CF and c.SSD_CF=d.SSD_CF)
    and a.CRE_D<=@STAT_REP_D
    and a.BALSHEY_NF=@p_BALSHEY_NF
    and a.BALSHTMTH_NF<=@p_BALSHTMTH_NF
    -- modif 4
    and a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF) from #TLIFEST m --modif 10 optimize keys order
                         where m.SEC_NF=a.SEC_NF 
                           and m.UWY_NF=a.UWY_NF
                           and m.ACY_NF=a.ACY_NF
                           and m.GAAP_NT = a.GAAP_NT
                           and m.DETTRNCOD_CF = a.DETTRNCOD_CF -- modif 5
                           and m.BALSHTMTH_NF<=@p_BALSHTMTH_NF--mod9
                           and m.CRE_D<=@STAT_REP_D)
    and a.CRE_D=(select max(b.CRE_D) from #TLIFEST b --modif 10 optimize keys order
                  where b.SEC_NF=a.SEC_NF
                    and b.UWY_NF=a.UWY_NF
                    and b.ACY_NF=a.ACY_NF
                    and b.GAAP_NT = a.GAAP_NT	--mod9
                    and b.DETTRNCOD_CF = a.DETTRNCOD_CF
                    and b.BALSHTMTH_NF=a.BALSHTMTH_NF
                    and b.CRE_D<=@STAT_REP_D)
group by x.GP, a.gaap_nt							--mod9
order by 1

--modif 10 
--SELECT @Time=GETDATE() 
--SELECT "3",DATEDIFF(ms,@StartTime,@Time) 

-- Situation après, conversion en devise filiale
select
  ACMTRS_NT=x.GP
 ,a.gaap_nt											--mod9
 ,AESTMNT_M1=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 4 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,AESTMNT_M2=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 3 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,AESTMNT_M3=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 2 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,AESTMNT_M4=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 1 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,AESTMNT_M5=round(sum(case when a.ACY_NF=@p_BALSHEY_NF     then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,AESTMNT_M6=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 1 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,AESTMNT_M7=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 2 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,AESTMNT_M8=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 3 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 ,AESTMNT_M9=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 4 then CAST((a.ESTMNT_M * d.EXC_R / @EXC_R_SEC) AS NUMERIC(18,  3)) end),3)
 
into #TLIFEST_AP
 from #TLIFEST a, #GROUPE x, BREF..TCURQUOT d
  where a.DETTRNCOD_CF=x.DETTRNCOD_CF
    and a.CTR_NF=@p_CTR_NF
    and a.SEC_NF!=@p_SEC_NF
    and a.ACY_NF between @p_BALSHEY_NF - 4 and @p_BALSHEY_NF + 4
    and a.CUR_CF=d.CUR_CF
    and d.SSD_CF=@SSD_CF
    and d.EXC_D=(select max(c.EXC_D) from BREF..TCURQUOT c where c.EXC_D<=isnull(@p_CRE_D,@STAT_REP_D) and c.CUR_CF=d.CUR_CF and c.SSD_CF=d.SSD_CF)
    and a.BALSHEY_NF=@p_BALSHEY_NF
    and a.BALSHTMTH_NF<=@p_BALSHTMTH_NF
    -- modif 4
    and a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF) from #TLIFEST m --modif 10 optimize keys order
                         where m.SEC_NF=a.SEC_NF 
                           and m.UWY_NF=a.UWY_NF
                           and m.ACY_NF=a.ACY_NF
                           and m.GAAP_NT = a.GAAP_NT
                           and m.DETTRNCOD_CF = a.DETTRNCOD_CF -- modif 5
                           and m.BALSHTMTH_NF<=@p_BALSHTMTH_NF)--mod9
    and a.CRE_D=(select max(b.CRE_D) from #TLIFEST b --modif 10 optimize keys order
                  where b.SEC_NF=a.SEC_NF
                    and b.UWY_NF=a.UWY_NF
                    and b.ACY_NF=a.ACY_NF
                    and b.GAAP_NT = a.GAAP_NT	--mod9
                    and b.DETTRNCOD_CF = a.DETTRNCOD_CF
                    and b.BALSHTMTH_NF=a.BALSHTMTH_NF)
group by x.GP, a.gaap_nt												--mod9
order by 1
-- modif 10
--SELECT @Time=GETDATE() 
--SELECT "4",DATEDIFF(ms,@StartTime,@Time) 

-- conversion en devise de la section du dernier exe
update #LISTE
/** OMEGA2 - spira17670:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2 **/
 set ESTMNT_M1=round(b.ESTMNT_M1,3)
    ,ESTMNT_M2=round(b.ESTMNT_M2,3)
    ,ESTMNT_M3=round(b.ESTMNT_M3,3)
    ,ESTMNT_M4=round(b.ESTMNT_M4,3)
    ,ESTMNT_M5=round(b.ESTMNT_M5,3)
    ,ESTMNT_M6=round(b.ESTMNT_M6,3)
    ,ESTMNT_M7=round(b.ESTMNT_M7,3)
	,ESTMNT_M8=round(b.ESTMNT_M8,3)
	,ESTMNT_M9=round(b.ESTMNT_M9,3)
	
 from #LISTE a, #TLIFEST_AV b
  where a.ACMTRS_NT=b.ACMTRS_NT
  and a.gaap_nt = b.gaap_nt												--mod9

update #LISTE
/** OMEGA2 - spira17670:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2 **/
 set AESTMNT_M1=round(b.AESTMNT_M1,3)
    ,AESTMNT_M2=round(b.AESTMNT_M2,3)
    ,AESTMNT_M3=round(b.AESTMNT_M3,3)
    ,AESTMNT_M4=round(b.AESTMNT_M4,3)
    ,AESTMNT_M5=round(b.AESTMNT_M5,3)
    ,AESTMNT_M6=round(b.AESTMNT_M6,3)
    ,AESTMNT_M7=round(b.AESTMNT_M7,3)
	,AESTMNT_M8=round(b.AESTMNT_M8,3)
	,AESTMNT_M9=round(b.AESTMNT_M9,3)
 from #LISTE a, #TLIFEST_AP b
  where a.ACMTRS_NT=b.ACMTRS_NT
   and a.gaap_nt = b.gaap_nt											--mod9

select @SEUIL_M=isnull(round(@SEUIL_M / @EXC_R_SEC,3),0)

select
  ACMTRS_NT
 ,GAAP_NT
 ,SEC_NF = @p_SEC_NF 
 ,ESTMNT_M1
 ,ESTMNT_M2
 ,ESTMNT_M3
 ,ESTMNT_M4
 ,ESTMNT_M5
 ,ESTMNT_M6
 ,ESTMNT_M7
 ,ESTMNT_M8
 ,ESTMNT_M9
 ,0, 0, 0, 0, 0, 0, 0,0,0
 ,AN1=@p_BALSHEY_NF - 4
 ,AN2=@p_BALSHEY_NF - 3
 ,AN3=@p_BALSHEY_NF - 2
 ,AN4=@p_BALSHEY_NF - 1
 ,AN5=@p_BALSHEY_NF
 ,AN6=@p_BALSHEY_NF + 1
 ,AN7=@p_BALSHEY_NF + 2
 ,AN8=@p_BALSHEY_NF + 3
 ,AN9=@p_BALSHEY_NF + 4
 ,AESTMNT_M1
 ,AESTMNT_M2
 ,AESTMNT_M3
 ,AESTMNT_M4
 ,AESTMNT_M5
 ,AESTMNT_M6
 ,AESTMNT_M7
 ,AESTMNT_M8
 ,AESTMNT_M9
 ,SEUIL_M=@SEUIL_M
 ,ACMTRS_GL
 ,DIFF_M1=isnull(AESTMNT_M1,0) - isnull(ESTMNT_M1,0)
 ,DIFF_M2=isnull(AESTMNT_M2,0) - isnull(ESTMNT_M2,0)
 ,DIFF_M3=isnull(AESTMNT_M3,0) - isnull(ESTMNT_M3,0)
 ,DIFF_M4=isnull(AESTMNT_M4,0) - isnull(ESTMNT_M4,0)
 ,DIFF_M5=isnull(AESTMNT_M5,0) - isnull(ESTMNT_M5,0)
 ,DIFF_M6=isnull(AESTMNT_M6,0) - isnull(ESTMNT_M6,0)
 ,DIFF_M7=isnull(AESTMNT_M7,0) - isnull(ESTMNT_M7,0)
 ,DIFF_M8=isnull(AESTMNT_M8,0) - isnull(ESTMNT_M8,0)
 ,DIFF_M9=isnull(AESTMNT_M9,0) - isnull(ESTMNT_M9,0)
 
from #LISTE l
group by  l.GAAP_NT,l.ACMTRS_NT 
order by l.GAAP_NT,l.ACMTRS_NT 

--modif 10 
--SELECT @Time=GETDATE() 
--SELECT "5",DATEDIFF(ms,@StartTime,@Time) 

fin:
if object_id('#LISTE')      is not null drop Table #LISTE
if object_id('#TLIFEST')    is not null drop Table #TLIFEST
if object_id('#TLIFEST_AV') is not null drop Table #TLIFEST_AV
if object_id('#TLIFEST_AP') is not null drop Table #TLIFEST_AP
if object_id('#GROUPE')     is not null drop Table #GROUPE
return 0
go
EXEC sp_procxmode 'dbo.PsLIFMOD2_02_O2', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFMOD2_02_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFMOD2_02_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFMOD2_02_O2 >>>'
go
GRANT EXECUTE ON dbo.PsLIFMOD2_02_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFMOD2_02_O2 TO GDBBATCH
go
