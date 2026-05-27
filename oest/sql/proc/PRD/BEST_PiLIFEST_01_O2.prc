USE BEST
go
IF OBJECT_ID('dbo.PiLIFEST_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiLIFEST_01_O2
    IF OBJECT_ID('dbo.PiLIFEST_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiLIFEST_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiLIFEST_01_O2 >>>'
END
go
create procedure dbo.PiLIFEST_01_O2
  (
  @p_acmtrs_nt    smallint,
  @p_acy_nf       smallint,
  @p_balshey_nf   smallint,
  @p_balshtmth_nf tinyint,
  @p_ctr_nf       UCTR_NF,
  @p_end_nt       UEND_NT,
  @p_gaap_nt	  tinyint, -- GAAP_NT  - MODIF 16
  @p_dettrncod_cf UL16, -- 5 Digit transaction code - MODIF 16
  @p_propagation_b tinyint, -- Propagation indicator - MODIF 16
  --@p_batch_b	  tinyint, -- Batch indicator - MODIF 16
  @p_calculated_b tinyint, -- Calculation indicator - MODIF 16
  @p_prs_cf       smallint,
  @p_sec_nf       USEC_NF,
  @p_uw_nt        UUW_NT,
  @p_uwy_nf       UUWY_NF,
  @p_creusr_cf    UUPDUSR_CF,
  @p_cur_cf       UCUR_CF,
  @p_estmnt_m     UAMT_M,
  @p_diff_m       UAMT_M,
  @p_ssd_cf       USSD_CF,
  @p_oricod_ls    UL16,
  @p_lstupd_d     UUPD_D      = null output,
  @p_lstupdusr_cf UUPDUSR_CF  = null output,
  @p_erreur       varchar(64) = null output
  )
as
/***************************************************
Domaine                     : (ES) Estimation
Base principale             : BEST
Auteur                      : ME01 avec Infotool version 2.0 (L.DEBEVER)
Date de creation            :
Description du programme    : Insertion d'enregistrement dans TLIFEST
Conditions d'execution      :
Commentaires                :
_________________
MODIFICATIONS
1  L.DEBEVER 13/06/1997 Ajout du code filiale SSD_CF
2  M GEORGET            si on se trouve dans accepation alors autupd_b = 1 sinon si r?tro alors autupd_b = 0
3  G BUISSON            si on se trouve dans accepation alors autupd_b = 1 Les liberations de depots ne se font plus en EX + 1 / AC + 1
                         mais en EX / AC + 1 quel que soit le type comptable
4  G BUISSON 05/01/2004 La filiale est generee a partir des 2 premiers caracteres du contrat (probleme du a la filialisation vie)
5  G BUISSON 24/05/2004 G?n?ration automatique des lib?rations de CNA en Ex + 1 / Ac + 1 sur les contrats de type 3
6  G BUISSON 04/09/2006 :spot:12720 Le code MAJ AUTO des trait?s acceptation d?pend de la r?tro interne (0 si r?tro interne, 1 sinon)
7  D OURMIAH 22/12/2008 :spot:16652 Plantage lors de saisie sur le poste 1073
8  Florent   27/11/2009 :spot:16973 si demande de lib?ration ajoute 1 ? poste cumul !
9  T.RIPERT  30/09/2010 :spot 18235 on ajoute une second si on a modifi? soit le poste 1900 - SAR ou 1901 RATIO 
10 T.RIPERT	 23/11/2010 :spot 18235 origine = CALC pour le champ calcul? SR
11 T.RIPERT	 11/02/2011 :spot ????? Lib?ration du poste 1093/2093
12 Florent   08/09/2011 :spot:22315 gestion de la lib?ration en EXE+1,Le type 1 a d?j? eu sa lib?ration cr??e par l'application, pour les autres il faut la g?n?rer
                        et il faut incr?menter l'exercice des type 1 s'ils font partie des postes concern?s ? l'insertion re?ue de l'application
13 Florent   24/01/2012 :spot:20562 interdit la cr?ation de ligne si avant le bilan en cours
14 Florent   23/04/2012 :spot:23688 l'exercice=ann?e de compte pour les type 1 et si pas lib?ration en exe+1 alors exe=ann?e de compte -1!
15 Sosinha   18/10/2013 : changes done for the contract number pattern change
16 A Deshpande 26/02/2014 : Added new columns GAAP_NT gaap_nt,DETTRNCOD_CF 5 digit transaction code,PROPAGATION_B propagation indicator,BATCH_B batch indicator,CALCULATED_B calculation indicator 
17 A Deshpande 28/04/2014: Added RESPROPAG_B with default value of '1' for EST 22 evo card & SEGUPD_B = 0 for EST 39 evo card
18 Sumit Gupta 24/09/2014: Fixed for SPIRA # 031162 
19 A Deshpande 28/04/2014: Changes for spira #031392(added defect value 0 for RESPROPAG_B)
20 A Deshpande 09/03/2015 - Estimates grid : cancellation UWY different to UWY ( accounting type = 4)
*****************************************************/
declare
  @erreur      int
 ,@tran_imbr   bit
 ,@uwy         UUWY_NF
 ,@acy         smallint
 ,@estmnt      UAMT_M
 ,@acmtrs_nt   smallint
 ,@ssd_cf      USSD_CF
 ,@majauto     bit -- MAJ AUTO
 ,@date_jour   datetime
 ,@lst_resil   smallint     -- modif 14
 ,@lst_accadmtyp_ct smallint
 ,@exe_accadmtyp_ct smallint
 ,@libe_exe_p1 smallint -- modif 12
-- modif 13
 ,@BLCSHTYEA_NF smallint -- Balance sheet year
 ,@BLCSHTMTH_NF tinyint -- Balance sheet month
 ,@SPECEND_D    datetime -- Special Ending Date
 ,@ACCOUNT_D    datetime -- Accounting Date
 ,@CLOSING_B    bit
 ,@release_dettrncod_cf UL16 
 ,@max_uwy_nf UUWY_NF 
--modif 15 start
select @date_jour=getdate(), @erreur=0, @tran_imbr=1 ,@ssd_cf=@p_ssd_cf --, @ssd_cf=convert(int,substring(@p_ctr_nf,1,2))
--modif 15 end
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin tran
end
		-- PsCalend_02 records selection in TCALEND search for the exceptional period or accounting (service) over given date	
execute @erreur=BREF..PsCALEND_02 @date_jour,'E',@BLCSHTYEA_NF output,@BLCSHTMTH_NF output,@SPECEND_D output,@ACCOUNT_D output,@CLOSING_B output
if @erreur!=0
begin
  select @p_erreur = "20001 APPLICATIF;BREF..PsCALEND_02 " + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @p_balshey_nf*100 + @p_balshtmth_nf < @BLCSHTYEA_NF*100 + @BLCSHTMTH_NF
begin
  select @p_erreur='30002 ESTIMATION;erreur p?riode bilan/wrong balance sheet period;',@erreur=30002
  goto fin
end

-- Modif 9
IF @p_acmtrs_nt > 10000
  select @date_jour=dateadd(second,1,getdate()), @p_acmtrs_nt=@p_acmtrs_nt / 10
-- Fin modif 9

if @p_acmtrs_nt between 1000 and 1999
begin
-- ACCEPTATION
select
  @lst_accadmtyp_ct = ACCADMTYP_CT
 ,@lst_resil=datepart(year,SECCAN_D)
 from BTRT..TSECTION
  where CTR_NF = @p_CTR_NF
    and END_NT = @p_END_NT
    and SEC_NF = @p_SEC_NF
    and UW_NT  = @p_UW_NT
    and UWY_NF = (select max(UWY_NF) from BTRT..TSECTION where CTR_NF=@p_CTR_NF and END_NT=@p_END_NT and SEC_NF=@p_SEC_NF and UW_NT=@p_UW_NT and SECSTS_CT in(14,16,17,19))
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur = "20011 APPLICATIF;btrt..tsection " + convert(varchar(10),@erreur) + ";"
    goto fin
  end

  select @exe_accadmtyp_ct=accadmtyp_ct
   from BTRT..TSECTION
    where ctr_nf=@p_ctr_nf
      and sec_nf=@p_sec_nf
      and uwy_nf=@p_uwy_nf
      and end_nt=@p_end_nt
      and uw_nt=@p_uw_nt
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur = "20011 APPLICATIF;btrt..tsection " + convert(varchar(10),@erreur) + ";"
    goto fin
  end
  if @exe_accadmtyp_ct=null
  begin
    select @exe_accadmtyp_ct=accadmtyp_ct
     from BTRT..TSECTION
      where ctr_nf=@p_ctr_nf
        and sec_nf=@p_sec_nf
        and uwy_nf=(select max(UWY_NF) from BTRT..TSECTION where
                     ctr_nf=@p_ctr_nf and sec_nf=@p_sec_nf and end_nt=@p_end_nt and uw_nt=@p_uw_nt and SECSTS_CT in (14,16,17,19))
        and end_nt=@p_end_nt
        and uw_nt=@p_uw_nt
    select @erreur=@@error
    if @erreur!=0
    begin
      select @p_erreur = "20011 APPLICATIF;btrt..tsection " + convert(varchar(10),@erreur) + ";" -- Changed the error message
      goto fin
    end
  end
end
else
begin
-- RETRO
  select @lst_accadmtyp_ct=RETACCTYP_CT
        ,@lst_resil=datepart(year,CAN_DT)
   from BRET..TRETCTR
    where RETCTR_NF=@p_ctr_nf
      and RTY_NF=(select max(RTY_NF) from BRET..TRETCTR where RETCTR_NF=@p_CTR_NF and RETCTRSTS_CT in(3,19))
  if @erreur!=0
  begin
    select @p_erreur = "20011 APPLICATIF;bret..tretctr " + convert(varchar(10),@erreur) + ";"
    goto fin
  end

  select @exe_accadmtyp_ct=RETACCTYP_CT
   from BRET..TRETCTR
    where RETCTR_NF=@p_ctr_nf
      and RTY_NF=@p_uwy_nf
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur = "20011 APPLICATIF;bret..tretctr " + convert(varchar(10),@erreur) + ";"
    goto fin
  end
  if @exe_accadmtyp_ct=null
  begin
    select @exe_accadmtyp_ct=retacctyp_ct
     from BRET..TRETCTR
      where retctr_nf=@p_ctr_nf
        and rty_nf=(select max(RTY_NF) from BRET..TRETCTR where RETCTR_NF=@p_CTR_NF and RETCTRSTS_CT in(3,19))
    select @erreur=@@error
    if @erreur!=0
    begin
      select @p_erreur = "20011 APPLICATIF;bret..tretctr " + convert(varchar(10),@erreur) + ";"
      goto fin
    end
  end
end

-- modif 14
if @lst_accadmtyp_ct in(1,4)
begin
  if @p_acmtrs_nt%10=4
    -- l'exercice=ann?e de compte pour les type 1 et si pas lib?ration en exe+1 alors exe=ann?e de compte -1!
   select @uwy=@p_acy_nf - (1 - dbo.FtLiberationExeP1(1,@p_acmtrs_nt -1))
  else
    select @uwy=@p_acy_nf
end
else
   select @uwy=@p_uwy_nf
--MODIF 20 START
if @p_acmtrs_nt between 1000 and 1999
begin
       -- For assume case select lowest underwriting year
         if @lst_accadmtyp_ct=4 or @lst_accadmtyp_ct=5
		 select @max_uwy_nf = min(UWY_NF) from BTRT..TSECTION where
                        ctr_nf=@p_ctr_nf and sec_nf=@p_sec_nf and end_nt=@p_end_nt and uw_nt=@p_uw_nt and SECSTS_CT=19		
end
   else
       -- For Retrocession case select lowest underwriting year
        if @lst_accadmtyp_ct=4 or @lst_accadmtyp_ct=5				
		 select @max_uwy_nf = min (RTY_NF) from BRET..TRETCTR where RETCTR_NF=@p_CTR_NF and RETCTRSTS_CT=19							

--if @lst_accadmtyp_ct=4 and @uwy > @lst_resil
--  select @uwy=@lst_resil
if @lst_accadmtyp_ct=4 and @uwy > @max_uwy_nf
select  @uwy =@max_uwy_nf 
--MODIF 20 END

insert TLIFEST
  (
  ACMTRS_NT,
  ACY_NF,
  BALSHEY_NF,
  BALSHTMTH_NF,
  CRE_D,
  CTR_NF,
  END_NT,
  GAAP_NT, --Modif15
  DETTRNCOD_CF,  --Modif15
  PROPAGATION_B,  --Modif15
  --BATCH_B,  --Modif15
  CALCULATED_B,  --Modif15
  PRS_CF,
  SEC_NF,
  UW_NT,
  UWY_NF,
  CREUSR_CF,
  CUR_CF,
  ESTMNT_M,
  DIFF_M,
  INDSUP_B,
  LSTUPD_D,
  LSTUPDUSR_CF,
  ORICOD_LS,
  SSD_CF)
values
  (
  @p_acmtrs_nt,
  @p_acy_nf,
  @p_balshey_nf,
  @p_balshtmth_nf,
  @date_jour,
  @p_ctr_nf,
  @p_end_nt,
  @p_gaap_nt,
  @p_dettrncod_cf,
  @p_propagation_b,
  --@p_batch_b,
  @p_calculated_b,
  @p_prs_cf,
  @p_sec_nf,
  @p_uw_nt,
  @uwy,
  @p_creusr_cf,
  @p_cur_cf,
  @p_estmnt_m,
  @p_diff_m,
  0,
  getdate(),
  suser_name(),
	@p_oricod_ls,
  @ssd_cf
  )
select @erreur=@@error
if @erreur != 0
begin
  if @erreur = 2601
    select @p_erreur = "20002 APPLICATIF;2601;TLIFEST "
  else
    select @p_erreur = "20001 APPLICATIF;TLIFEST " + convert(varchar(10),@erreur) + ";"
  goto fin
end

select @libe_exe_p1 = dbo.FtLiberationExeP1(@exe_accadmtyp_ct,@p_acmtrs_nt)

--MODIF - 17 Release release dettrncod_Cf will be considered when accounting type = 3
select @release_dettrncod_cf = dettrncod2_cf from BREF..TSUBTRSASSO where dettrncod1_cf = @p_dettrncod_cf and assotyp_ct = '1'	

-- Le type 1 et 4 ont d?j? eu leur lib?ration cr??e par l'application, pour les autres il faut la g?n?rer

if @lst_accadmtyp_ct not in(1,4) and @libe_exe_p1 > 0 AND (@p_acy_nf <= @p_balshey_nf + 3) AND  @release_dettrncod_cf IS NOT NULL
begin
  select @uwy=@p_uwy_nf + @libe_exe_p1, @acy=@p_acy_nf + 1, @estmnt=@p_estmnt_m * (-1), @acmtrs_nt=@p_acmtrs_nt + 1
 insert TLIFEST
    (
    ACMTRS_NT,
    ACY_NF,
    BALSHEY_NF,
    BALSHTMTH_NF,
    CRE_D,
    CTR_NF,
    END_NT,
	GAAP_NT, --Modif15
    DETTRNCOD_CF,  --Modif15
  PROPAGATION_B,  --Modif15
  --BATCH_B,  --Modif15
  CALCULATED_B,  --Modif15
    PRS_CF,
    SEC_NF,
    UW_NT,
    UWY_NF,
    CREUSR_CF,
    CUR_CF,
    ESTMNT_M,
	DIFF_M,
    INDSUP_B,
    LSTUPD_D,
    LSTUPDUSR_CF,
    ORICOD_LS,
    SSD_CF)
  values
    (
    @acmtrs_nt,
    @acy,
    @p_balshey_nf,
    @p_balshtmth_nf,
    getdate(),
    @p_ctr_nf,
    @p_end_nt,
	@p_gaap_nt,
	@release_dettrncod_cf,
  @p_propagation_b,
  --@p_batch_b,
  @p_calculated_b,
    @p_prs_cf,
    @p_sec_nf,
    @p_uw_nt,
    @uwy,
    @p_creusr_cf,
    @p_cur_cf,
    @estmnt,
	@p_diff_m,
    0,
    getdate(),
    suser_name(),
    'TP',
    @ssd_cf
    )
	
  select @erreur=@@error
  if @erreur!=0
  begin
    if @erreur = 2601
      select @p_erreur = "20002 APPLICATIF;2601;TLIFEST"
    else
      select @p_erreur = "20001 APPLICATIF;TLIFEST " + convert(varchar(10),@erreur) + ";"
    goto fin
  end
end

select @p_lstupdusr_cf=LSTUPDUSR_CF, @p_lstupd_d=LSTUPD_D
 from TLIFEST
  where ACMTRS_NT=@p_acmtrs_nt
    and ACY_NF=@acy
    and BALSHEY_NF=@p_balshey_nf
    and BALSHTMTH_NF=@p_balshtmth_nf
    and CTR_NF=@p_ctr_nf
    and END_NT=@p_end_nt
    and PRS_CF=@p_prs_cf
    and SEC_NF=@p_sec_nf
    and UW_NT=@p_uw_nt
    and UWY_NF=@uwy
select @erreur=@@error
if @erreur!=0
  select @p_erreur = "20011 APPLICATIF;TLIFEST " + convert(varchar(10),@erreur) + ";"

-- S'il n'existe pas de TLIFDRI pour le TLIFEST cr??, cr?ation
-- Remarque : dans tous les cas, exercice de souscription = ann?e de compte
-- on positionne l'indicateur de r?tro interne pour l'acceptation en fonction de la c?dante du contrat
-- Recherche du dernier exercice valide de la section
if (select CLISSD_CF from BTRT..TCONTR, BCLI..TCLIENT
     where CTR_NF=@p_ctr_nf
       and UWY_NF=(select max(UWY_NF) from BTRT..TSECTION where CTR_NF=@p_CTR_NF and END_NT =@p_END_NT and UW_NT=@p_UW_NT and SEC_NF=@p_SEC_NF and SECSTS_CT in(14,16,17,19))
       and CLI_NF=CED_NF)!=null
 select @majauto=0 -- MAJ AUTO = NON
else
 select @majauto=1 -- MAJ AUTO = OUI

if not exists(select 1 from TLIFDRI where CTR_NF=@p_ctr_nf and END_NT=@p_end_nt and SEC_NF=@p_sec_nf and UW_NT=@p_uw_nt and BALSHEY_NF=@p_balshey_nf
               and BALSHTMTH_NF<=@p_balshtmth_nf and ACY_NF=@p_acy_nf)
begin
  insert TLIFDRI
    (
    CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
    UW_NT,
    CRE_D,
    BALSHEY_NF,
    BALSHTMTH_NF,
    ACY_NF,
    SSD_CF,
    AUTUPD_B,
    COMACC_B,
    CMT_NT,
    CREUSR_CF,
    LSTUPD_D,
    LSTUPDUSR_CF,
	RESPROPAG_B)
  values
    (
    @p_ctr_nf,
    @p_end_nt,
    @p_sec_nf,
    @p_acy_nf,
    @p_uw_nt,
    getdate(),
    @p_balshey_nf,
    @p_balshtmth_nf,
    @p_acy_nf,
    @ssd_cf,
    case when @p_acmtrs_nt < 2000 then @majauto else 0 end, --si acceptation
    0,
    0,
    @p_creusr_cf,
    getdate(),
    suser_name(),
	0
    )
  select @erreur=@@error
  if @erreur != 0
  begin
    if @erreur = 2601
      select @p_erreur = "20002 APPLICATIF;2601;TLIFDRI"
    else
      select @p_erreur = "20001 APPLICATIF;TLIFDRI " + convert(varchar(10),@erreur) + ";"
    goto fin
  end
end

if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
EXEC sp_procxmode 'dbo.PiLIFEST_01_O2', 'unchained'
go
IF OBJECT_ID('dbo.PiLIFEST_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiLIFEST_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiLIFEST_01_O2 >>>'
go
GRANT EXECUTE ON dbo.PiLIFEST_01_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiLIFEST_01_O2 TO GDBBATCH
go
