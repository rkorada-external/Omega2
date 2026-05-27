use BEST
go
if object_id('dbo.PsLIFMOD2_01') is not null
begin
  drop procedure dbo.PsLIFMOD2_01
  if object_id('dbo.PsLIFMOD2_01') is not null
    print '<<< FAILED DROPPING procedure dbo.PsLIFMOD2_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PsLIFMOD2_01 >>>'
end
go
create procedure PsLIFMOD2_01
  (
  @p_CTR_NF       UCTR_NF
 ,@p_SEC_NF       USEC_NF
 ,@p_BALSHEY_NF   smallint
 ,@p_BALSHTMTH_NF tinyint
 ,@p_CRE_D        datetime=null
 ,@p_RETRO_B      bit=0
  )
as
/***************************************************
Domaine                   : Estimation
Base principale           : BEST
Auteur                    : Florent
Date de création          : 12/10/2004
Description du programme  : Estimations Vie, suivi du dépassement du seuil
Conditions d'éxécution    : par la dw d_seuil_lifmod2
Commentaires              : Requête croisée : Pour avoir les 7 acy_nf de ligne en colonne, utilisation du Case avec un group by
_________________
MODIFICATIONS
M  Auteur      Date       Description
1  Florent     15/11/2004 :spot:10260, on ne prend plus dans le regroupement 4 les postes de dépôts 2303,2304,2323,2324,1303,1304,1323,1324
2  GIBU        23/09/2005 Les montants en différence ne sont plus calculés dans la DW mais dans la proc.
3  GIBU        28/06/2006 Les postes CNA ne sont plus différenciés par filiale
4  GIBU        16/11/2007 :spot:14286 Ajout du poste 1011 (Primes liées à la sinistralité) qui doit être géré comme le 1010
5  Florent     05/06/2008 :spot:14205 debug recherche des derniers montants pour calcul positions
6  Florent     22/12/2008 :spot:16651 ajout de l'exe pour la séléction du dernier mois bilan !!
7  Florent     27/11/2009 :spot:17244 ajout de la VOBA et de poste cumul manquant dans la retro, libellé du poste 1450 pour le résultat financier comme sur la grille estimation
               25/01/2010 :spot:17244 groupe 3 devient le 4 et le 3 (RT + CNA) devient le 4
8  Tony        15/10/2010 Remettre la modif 6
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/
declare
  @erreur     integer
 ,@lignes     integer
 ,@STAT_REP_D datetime
 ,@SEUIL_M    UAMT_M
 ,@SSD_CF     USSD_CF
 ,@ESB_CF     UESB_CF
 ,@CURLIF_CF  UCUR_CF
 ,@CURCTR_CF  UCUR_CF

create Table #LISTE
  (
  ACMTRS_NT  smallint
 ,ESTMNT_M1  UAMT_M null
 ,ESTMNT_M2  UAMT_M null
 ,ESTMNT_M3  UAMT_M null
 ,ESTMNT_M4  UAMT_M null
 ,ESTMNT_M5  UAMT_M null
 ,ESTMNT_M6  UAMT_M null
 ,ESTMNT_M7  UAMT_M null
 ,COMACC_B1  bit default 0
 ,COMACC_B2  bit default 0
 ,COMACC_B3  bit default 0
 ,COMACC_B4  bit default 0
 ,COMACC_B5  bit default 0
 ,COMACC_B6  bit default 0
 ,COMACC_B7  bit default 0
 ,AESTMNT_M1 UAMT_M null
 ,AESTMNT_M2 UAMT_M null
 ,AESTMNT_M3 UAMT_M null
 ,AESTMNT_M4 UAMT_M null
 ,AESTMNT_M5 UAMT_M null
 ,AESTMNT_M6 UAMT_M null
 ,AESTMNT_M7 UAMT_M null
 ,ACMTRS_LL  varchar(64) NOT null
 )

declare @site_cf        varchar(10)
select top 1 @SSD_CF=SSD_Cf FROM BTRT..TCONTR WHERE ctr_nf=@p_CTR_NF
Execute @erreur = BEST..PsSITE_01 @SSD_CF,'2',@site_cf output

if @p_RETRO_B=1
   begin
     select @SSD_CF=SSD_CF, @ESB_CF=ESB_CF, @CURCTR_CF=RETPCPCUR_CF
       from BRET..TRETCTR
        where RETCTR_NF=@p_ctr_nf
          and RTY_NF=(select max(RTY_NF) from BRET..TRETCTR c where c.RETCTR_NF=@p_ctr_nf and RETCTRSTS_CT in(3,19))
   end
else
   begin
     select @SSD_CF=SSD_CF, @ESB_CF=ACCESB_CF
      from BTRT..TCONTR
       where CTR_NF=@p_ctr_nf
   --    and LSTUWY_B=1
         and UWY_NF=(select max(UWY_NF) from BTRT..TCONTR c where c.CTR_NF=@p_ctr_nf and CTRSTS_CT in(14,16,17,19))

     select @CURCTR_CF=PCPCUR_CF
      from BTRT..TSECTION
       where CTR_NF=@p_CTR_NF
         and SEC_NF=@p_SEC_NF
         and UWY_NF=(select max(UWY_NF) from BTRT..TSECTION c where c.CTR_NF=@p_ctr_nf and SEC_NF=@p_SEC_NF and SECSTS_CT in(14,16,17,19))
end

insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 1, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=1010 and SSD_CF=@SSD_CF
insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 2, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=1400 and SSD_CF=@SSD_CF
insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 3, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2450 else 1450 end) and SSD_CF=@SSD_CF -- modif 8
insert #LISTE(ACMTRS_NT,ACMTRS_LL) select 4, ACMTRS_LL from BREF..TACMTRSH where PRS_CF=500 and ACMTRS_NT=(case when @p_RETRO_B=1 then 2460 else 1460 end) and SSD_CF=@SSD_CF -- modif 7 et 8

select @STAT_REP_D=max(CRE_D)
 from BEST..TREQJOB
  where SSD_CF=@SSD_CF
    and REQCOD_CT='L'
    and BALSHEYEA_NF=1900
    and BALSHTMTH_NF=1
    and CLODAT_D='19000101'
    And SITE_CF = @site_cf

select @SEUIL_M=AMT_M from TLIFTHR where SSD_CF=@SSD_CF and ESB_CF=@ESB_CF -- en cours de la devise filiale

-- On regarde dans TLIFMOD2 si le mouvement existe sinon dans TLIFEST
if exists(select 1 from TLIFMOD2
           where CTR_NF=@p_CTR_NF and SEC_NF=@p_SEC_NF and BALSHEY_NF=@p_BALSHEY_NF and BALSHTMTH_NF=@p_BALSHTMTH_NF and CRE_D=@p_CRE_D)
   begin
     -- TLIFMOD2
     select @CURLIF_CF=CUR_CF from TLIFMOD
       where CTR_NF=@p_CTR_NF and SEC_NF=@p_SEC_NF and BALSHEY_NF=@p_BALSHEY_NF and BALSHTMTH_NF=@p_BALSHTMTH_NF and CRE_D=@p_CRE_D

     select
       b.ACMTRS_NT
      ,COMACC_B1 =max(case when a.ACY_NF=@p_BALSHEY_NF - 4 then a.COMACC_B else 0 end)
      ,COMACC_B2 =max(case when a.ACY_NF=@p_BALSHEY_NF - 3 then a.COMACC_B else 0 end)
      ,COMACC_B3 =max(case when a.ACY_NF=@p_BALSHEY_NF - 2 then a.COMACC_B else 0 end)
      ,COMACC_B4 =max(case when a.ACY_NF=@p_BALSHEY_NF - 1 then a.COMACC_B else 0 end)
      ,COMACC_B5 =max(case when a.ACY_NF=@p_BALSHEY_NF     then a.COMACC_B else 0 end)
      ,COMACC_B6 =max(case when a.ACY_NF=@p_BALSHEY_NF + 1 then a.COMACC_B else 0 end)
      ,COMACC_B7 =max(case when a.ACY_NF=@p_BALSHEY_NF + 2 then a.COMACC_B else 0 end)
      ,ESTMNT_M1 =sum(case when a.ACY_NF=@p_BALSHEY_NF - 4 then case when b.ACMTRS_NT=1 then PRIPRMAMT_M When b.ACMTRS_NT=2 then PRIRESTECAMT_M When b.ACMTRS_NT=4 then PRIRESDACAMT_M When b.ACMTRS_NT=3 then PRIRESFINAMT_M end end)
      ,ESTMNT_M2 =sum(case when a.ACY_NF=@p_BALSHEY_NF - 3 then case when b.ACMTRS_NT=1 then PRIPRMAMT_M When b.ACMTRS_NT=2 then PRIRESTECAMT_M When b.ACMTRS_NT=4 then PRIRESDACAMT_M When b.ACMTRS_NT=3 then PRIRESFINAMT_M end end)
      ,ESTMNT_M3 =sum(case when a.ACY_NF=@p_BALSHEY_NF - 2 then case when b.ACMTRS_NT=1 then PRIPRMAMT_M When b.ACMTRS_NT=2 then PRIRESTECAMT_M When b.ACMTRS_NT=4 then PRIRESDACAMT_M When b.ACMTRS_NT=3 then PRIRESFINAMT_M end end)
      ,ESTMNT_M4 =sum(case when a.ACY_NF=@p_BALSHEY_NF - 1 then case when b.ACMTRS_NT=1 then PRIPRMAMT_M When b.ACMTRS_NT=2 then PRIRESTECAMT_M When b.ACMTRS_NT=4 then PRIRESDACAMT_M When b.ACMTRS_NT=3 then PRIRESFINAMT_M end end)
      ,ESTMNT_M5 =sum(case when a.ACY_NF=@p_BALSHEY_NF     then case when b.ACMTRS_NT=1 then PRIPRMAMT_M When b.ACMTRS_NT=2 then PRIRESTECAMT_M When b.ACMTRS_NT=4 then PRIRESDACAMT_M When b.ACMTRS_NT=3 then PRIRESFINAMT_M end end)
      ,ESTMNT_M6 =sum(case when a.ACY_NF=@p_BALSHEY_NF + 1 then case when b.ACMTRS_NT=1 then PRIPRMAMT_M When b.ACMTRS_NT=2 then PRIRESTECAMT_M When b.ACMTRS_NT=4 then PRIRESDACAMT_M When b.ACMTRS_NT=3 then PRIRESFINAMT_M end end)
      ,ESTMNT_M7 =sum(case when a.ACY_NF=@p_BALSHEY_NF + 2 then case when b.ACMTRS_NT=1 then PRIPRMAMT_M When b.ACMTRS_NT=2 then PRIRESTECAMT_M When b.ACMTRS_NT=4 then PRIRESDACAMT_M When b.ACMTRS_NT=3 then PRIRESFINAMT_M end end)
      ,AESTMNT_M1=sum(case when a.ACY_NF=@p_BALSHEY_NF - 4 then case when b.ACMTRS_NT=1 then AFTPRMAMT_M When b.ACMTRS_NT=2 then AFTRESTECAMT_M When b.ACMTRS_NT=4 then AFTRESDACAMT_M When b.ACMTRS_NT=3 then AFTRESFINAMT_M end end)
      ,AESTMNT_M2=sum(case when a.ACY_NF=@p_BALSHEY_NF - 3 then case when b.ACMTRS_NT=1 then AFTPRMAMT_M When b.ACMTRS_NT=2 then AFTRESTECAMT_M When b.ACMTRS_NT=4 then AFTRESDACAMT_M When b.ACMTRS_NT=3 then AFTRESFINAMT_M end end)
      ,AESTMNT_M3=sum(case when a.ACY_NF=@p_BALSHEY_NF - 2 then case when b.ACMTRS_NT=1 then AFTPRMAMT_M When b.ACMTRS_NT=2 then AFTRESTECAMT_M When b.ACMTRS_NT=4 then AFTRESDACAMT_M When b.ACMTRS_NT=3 then AFTRESFINAMT_M end end)
      ,AESTMNT_M4=sum(case when a.ACY_NF=@p_BALSHEY_NF - 1 then case when b.ACMTRS_NT=1 then AFTPRMAMT_M When b.ACMTRS_NT=2 then AFTRESTECAMT_M When b.ACMTRS_NT=4 then AFTRESDACAMT_M When b.ACMTRS_NT=3 then AFTRESFINAMT_M end end)
      ,AESTMNT_M5=sum(case when a.ACY_NF=@p_BALSHEY_NF     then case when b.ACMTRS_NT=1 then AFTPRMAMT_M When b.ACMTRS_NT=2 then AFTRESTECAMT_M When b.ACMTRS_NT=4 then AFTRESDACAMT_M When b.ACMTRS_NT=3 then AFTRESFINAMT_M end end)
      ,AESTMNT_M6=sum(case when a.ACY_NF=@p_BALSHEY_NF + 1 then case when b.ACMTRS_NT=1 then AFTPRMAMT_M When b.ACMTRS_NT=2 then AFTRESTECAMT_M When b.ACMTRS_NT=4 then AFTRESDACAMT_M When b.ACMTRS_NT=3 then AFTRESFINAMT_M end end)
      ,AESTMNT_M7=sum(case when a.ACY_NF=@p_BALSHEY_NF + 2 then case when b.ACMTRS_NT=1 then AFTPRMAMT_M When b.ACMTRS_NT=2 then AFTRESTECAMT_M When b.ACMTRS_NT=4 then AFTRESDACAMT_M When b.ACMTRS_NT=3 then AFTRESFINAMT_M end end)
     into #TLIFMOD2
      from TLIFMOD2 a, #LISTE b
       where a.CTR_NF   =  @p_CTR_NF
         and a.SEC_NF   =  @p_SEC_NF
         and a.CRE_D    =  @p_CRE_D
         and a.BALSHEY_NF     =  @p_BALSHEY_NF
         and a.BALSHTMTH_NF   =  @p_BALSHTMTH_NF
     group by b.ACMTRS_NT
     order by b.ACMTRS_NT

     update #LISTE
      set COMACC_B1=b.COMACC_B1
         ,COMACC_B2=b.COMACC_B2
         ,COMACC_B3=b.COMACC_B3
         ,COMACC_B4=b.COMACC_B4
         ,COMACC_B5=b.COMACC_B5
         ,COMACC_B6=b.COMACC_B6
         ,COMACC_B7=b.COMACC_B7
         ,ESTMNT_M1=round(b.ESTMNT_M1 / 1000,3)
         ,ESTMNT_M2=round(b.ESTMNT_M2 / 1000,3)
         ,ESTMNT_M3=round(b.ESTMNT_M3 / 1000,3)
         ,ESTMNT_M4=round(b.ESTMNT_M4 / 1000,3)
         ,ESTMNT_M5=round(b.ESTMNT_M5 / 1000,3)
         ,ESTMNT_M6=round(b.ESTMNT_M6 / 1000,3)
         ,ESTMNT_M7=round(b.ESTMNT_M7 / 1000,3)
         ,AESTMNT_M1=round(b.AESTMNT_M1 / 1000,3)
         ,AESTMNT_M2=round(b.AESTMNT_M2 / 1000,3)
         ,AESTMNT_M3=round(b.AESTMNT_M3 / 1000,3)
         ,AESTMNT_M4=round(b.AESTMNT_M4 / 1000,3)
         ,AESTMNT_M5=round(b.AESTMNT_M5 / 1000,3)
         ,AESTMNT_M6=round(b.AESTMNT_M6 / 1000,3)
         ,AESTMNT_M7=round(b.AESTMNT_M7 / 1000,3)
       from #LISTE a, #TLIFMOD2 b
        where a.ACMTRS_NT=b.ACMTRS_NT

   end
else
   -- TLIFEST
   begin
      select
        x.ACMTRS_NT
       ,COMACC_B1=max(case when a.ACY_NF=@p_BALSHEY_NF - 4 then a.COMACC_B else 0 end)
       ,COMACC_B2=max(case when a.ACY_NF=@p_BALSHEY_NF - 3 then a.COMACC_B else 0 end)
       ,COMACC_B3=max(case when a.ACY_NF=@p_BALSHEY_NF - 2 then a.COMACC_B else 0 end)
       ,COMACC_B4=max(case when a.ACY_NF=@p_BALSHEY_NF - 1 then a.COMACC_B else 0 end)
       ,COMACC_B5=max(case when a.ACY_NF=@p_BALSHEY_NF     then a.COMACC_B else 0 end)
       ,COMACC_B6=max(case when a.ACY_NF=@p_BALSHEY_NF + 1 then a.COMACC_B else 0 end)
       ,COMACC_B7=max(case when a.ACY_NF=@p_BALSHEY_NF + 2 then a.COMACC_B else 0 end)
      into #TLIFDRI
       from TLIFDRI a, #LISTE x
        where a.CTR_NF=@p_CTR_NF
          and a.SEC_NF=@p_SEC_NF
          and a.ACY_NF between @p_BALSHEY_NF - 4 and @p_BALSHEY_NF + 2
          and a.BALSHEY_NF=@p_BALSHEY_NF
          and a.BALSHTMTH_NF <= @p_BALSHTMTH_NF
          -- modif 5
          and a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF) from TLIFDRI m
                               where m.ACY_NF=a.ACY_NF
                                 and m.CTR_NF=a.CTR_NF
                                 and m.SEC_NF=a.SEC_NF
                                 and m.BALSHEY_NF=a.BALSHEY_NF
                                 and m.BALSHTMTH_NF<=@p_BALSHTMTH_NF)
          and a.COMACC_B=1
          and a.CRE_D=(select max(b.CRE_D) from TLIFDRI b
                                             where b.CTR_NF=a.CTR_NF
                                               and b.SEC_NF=a.SEC_NF
                                               and b.ACY_NF=a.ACY_NF
                                               and b.BALSHEY_NF=a.BALSHEY_NF
                                               and b.BALSHTMTH_NF=a.BALSHTMTH_NF)
      group by x.ACMTRS_NT
      order by x.ACMTRS_NT

      update #LISTE
      set   COMACC_B1=b.COMACC_B1,
            COMACC_B2=b.COMACC_B2,
            COMACC_B3=b.COMACC_B3,
            COMACC_B4=b.COMACC_B4,
            COMACC_B5=b.COMACC_B5,
            COMACC_B6=b.COMACC_B6,
            COMACC_B7=b.COMACC_B7
      from  #LISTE a, #TLIFDRI b
      where a.ACMTRS_NT=b.ACMTRS_NT

      -- si pas de lignes en base alors liste à partir de TLIFEST
      create Table #GROUPE(GP Tinyint, ACMTRS_NT Smallint)

      --Primes
      if @p_RETRO_B=1
         begin
           insert #GROUPE values(1,2010)
           insert #GROUPE values(1,2011)
         end
      else
         begin
           insert #GROUPE values(1,1010)
           insert #GROUPE values(1,1011)
         end

      --Résultat technique
      if @p_RETRO_B=1
         begin
           INSERT INTO  #groupe
           SELECT       2, ACMTRS_NT
             FROM       BEST..TACCPAR
            WHERE       RESTEC_B = 1
            and         acmtrs_nt >= 2000
         end
      else
         begin
           INSERT INTO  #groupe
           SELECT       2, ACMTRS_NT
             FROM       BEST..TACCPAR
            WHERE       RESTEC_B = 1
            and         acmtrs_nt < 2000
         end

      --Résultat Tech. + Financier
--      insert #GROUPE select 3, ACMTRS_NT from #GROUPE where GP=2
      if @p_RETRO_B=1
         begin
           INSERT INTO  #groupe
           SELECT       3, ACMTRS_NT
             FROM       BEST..TACCPAR
            WHERE       RESFIN_B = 1
            and         acmtrs_nt >= 2000
         end
      else
         Begin
           INSERT INTO  #groupe
           SELECT       3, ACMTRS_NT
             FROM       BEST..TACCPAR
            WHERE       RESFIN_B = 1
            and         acmtrs_nt < 2000
         End

      --Résultat Tech. + Financier + CNA + VOBA
      --insert #GROUPE select 4, ACMTRS_NT from #GROUPE where GP=3

      -- CNA et VOBA
      -- Les postes ne sont plus différenciés par filiale
      if @p_RETRO_B=1
         Begin
           INSERT INTO  #groupe
           SELECT       4, ACMTRS_NT
             FROM       BEST..TACCPAR
            WHERE       RESDAC_B = 1
            and         acmtrs_nt >= 2000
         End
      else
         Begin
           INSERT INTO  #groupe
           SELECT       4, ACMTRS_NT
             FROM       BEST..TACCPAR
            WHERE       RESDAC_B = 1
            and         acmtrs_nt < 2000
         end

      select   @CURLIF_CF=max(a.CUR_CF)
        from   TLIFEST a, #GROUPE x
       where   a.ACMTRS_NT=x.ACMTRS_NT
         and   a.CTR_NF=@p_CTR_NF
         and   a.SEC_NF=@p_SEC_NF
         and   a.ACY_NF between @p_BALSHEY_NF - 4 and @p_BALSHEY_NF + 2
         and   a.PRS_CF=500
         and   a.CRE_D<=@STAT_REP_D
         and   a.BALSHEY_NF=@p_BALSHEY_NF
         and   a.BALSHTMTH_NF<=@p_BALSHTMTH_NF
    -- modif 5
         and   a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF)
                                 from TLIFEST m
                                where m.ACY_NF=a.ACY_NF
                                  and m.CTR_NF=a.CTR_NF
                                  and m.UWY_NF=a.UWY_NF  -- modif 6
                                  and m.SEC_NF=a.SEC_NF
                                  and m.BALSHEY_NF=a.BALSHEY_NF
                                  and m.BALSHTMTH_NF<=@p_BALSHTMTH_NF
                                  and m.PRS_CF=a.PRS_CF
                                  and m.ACMTRS_NT=a.ACMTRS_NT
                                  and m.CRE_D<=@STAT_REP_D)
         and a.CRE_D=( select max(b.CRE_D)
                      from TLIFEST b
                     where b.CTR_NF=a.CTR_NF
                       and b.UWY_NF=a.UWY_NF
                       and b.SEC_NF=a.SEC_NF
                       and b.ACY_NF=a.ACY_NF
                       and b.BALSHEY_NF=a.BALSHEY_NF
                       and b.BALSHTMTH_NF=a.BALSHTMTH_NF
                       and b.PRS_CF=a.PRS_CF
                       and b.ACMTRS_NT=a.ACMTRS_NT
                       and b.CRE_D<=@STAT_REP_D)

      select
        ACMTRS_NT=x.GP
       ,ESTMNT_M1=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 4 then a.ESTMNT_M end) / 1000,3)
       ,ESTMNT_M2=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 3 then a.ESTMNT_M end) / 1000,3)
       ,ESTMNT_M3=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 2 then a.ESTMNT_M end) / 1000,3)
       ,ESTMNT_M4=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 1 then a.ESTMNT_M end) / 1000,3)
       ,ESTMNT_M5=round(sum(case when a.ACY_NF=@p_BALSHEY_NF     then a.ESTMNT_M end) / 1000,3)
       ,ESTMNT_M6=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 1 then a.ESTMNT_M end) / 1000,3)
       ,ESTMNT_M7=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 2 then a.ESTMNT_M end) / 1000,3)
         into #TLIFEST_AV
         from TLIFEST a, #GROUPE x
        where a.ACMTRS_NT=x.ACMTRS_NT
          and a.CTR_NF=@p_CTR_NF
          and a.SEC_NF=@p_SEC_NF
          and a.ACY_NF between @p_BALSHEY_NF - 4 and @p_BALSHEY_NF + 2
          and a.PRS_CF=500
          and a.CRE_D<=@STAT_REP_D
          and a.BALSHEY_NF=@p_BALSHEY_NF
          and a.BALSHTMTH_NF<=@p_BALSHTMTH_NF
          -- modif 5
          and a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF) from TLIFEST m
                               where m.ACY_NF=a.ACY_NF
                                 and m.CTR_NF=a.CTR_NF
                                 and m.UWY_NF=a.UWY_NF  -- modif 6
                                 and m.SEC_NF=a.SEC_NF
                                 and m.BALSHEY_NF=a.BALSHEY_NF
                                 and m.BALSHTMTH_NF<=@p_BALSHTMTH_NF
                                 and m.PRS_CF=a.PRS_CF
                                 and m.ACMTRS_NT=a.ACMTRS_NT
                                 and m.CRE_D<=@STAT_REP_D)
          and a.CRE_D=(select max(b.CRE_D) from TLIFEST b
                        where b.CTR_NF=a.CTR_NF
                          and b.UWY_NF=a.UWY_NF
                          and b.SEC_NF=a.SEC_NF
                          and b.ACY_NF=a.ACY_NF
                          and b.BALSHEY_NF=a.BALSHEY_NF
                          and b.BALSHTMTH_NF=a.BALSHTMTH_NF
                          and b.PRS_CF=a.PRS_CF
                          and b.ACMTRS_NT=a.ACMTRS_NT
                          and b.CRE_D<=@STAT_REP_D)
      group by x.GP
      order by 1

      select
        ACMTRS_NT=x.gp
       ,AESTMNT_M1=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 4 then a.ESTMNT_M end) / 1000,3)
       ,AESTMNT_M2=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 3 then a.ESTMNT_M end) / 1000,3)
       ,AESTMNT_M3=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 2 then a.ESTMNT_M end) / 1000,3)
       ,AESTMNT_M4=round(sum(case when a.ACY_NF=@p_BALSHEY_NF - 1 then a.ESTMNT_M end) / 1000,3)
       ,AESTMNT_M5=round(sum(case when a.ACY_NF=@p_BALSHEY_NF     then a.ESTMNT_M end) / 1000,3)
       ,AESTMNT_M6=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 1 then a.ESTMNT_M end) / 1000,3)
       ,AESTMNT_M7=round(sum(case when a.ACY_NF=@p_BALSHEY_NF + 2 then a.ESTMNT_M end) / 1000,3)
         into #TLIFEST_AP
         from TLIFEST a, #GROUPE x
        where a.ACMTRS_NT=x.ACMTRS_NT
          and a.CTR_NF=@p_CTR_NF
          and a.SEC_NF=@p_SEC_NF
          and a.ACY_NF between @p_BALSHEY_NF - 4 and @p_BALSHEY_NF + 2
          and a.PRS_CF=500
          and a.BALSHEY_NF=@p_BALSHEY_NF
          and a.BALSHTMTH_NF<=@p_BALSHTMTH_NF
          -- modif 5
          and a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF) from TLIFEST m
                               where m.ACY_NF=a.ACY_NF
                                 and m.CTR_NF=a.CTR_NF
                                 and m.UWY_NF=a.UWY_NF  -- modif 6
                                 and m.SEC_NF=a.SEC_NF
                                 and m.BALSHEY_NF=a.BALSHEY_NF
                                 and m.BALSHTMTH_NF<=@p_BALSHTMTH_NF
                                 and m.PRS_CF=a.PRS_CF
                                 and m.ACMTRS_NT=a.ACMTRS_NT)
          and a.CRE_D=(select max(b.CRE_D) from TLIFEST b
                        where b.CTR_NF=a.CTR_NF
                          and b.UWY_NF=a.UWY_NF
                          and b.SEC_NF=a.SEC_NF
                          and b.ACY_NF=a.ACY_NF
                          and b.BALSHEY_NF=a.BALSHEY_NF
                          and b.BALSHTMTH_NF=a.BALSHTMTH_NF
                          and b.PRS_CF=a.PRS_CF
                          and b.ACMTRS_NT=a.ACMTRS_NT)
      group by x.GP
      order by 1

      update #LISTE
       set COMACC_B1=b.COMACC_B1
          ,COMACC_B2=b.COMACC_B2
          ,COMACC_B3=b.COMACC_B3
          ,COMACC_B4=b.COMACC_B4
          ,COMACC_B5=b.COMACC_B5
          ,COMACC_B6=b.COMACC_B6
          ,COMACC_B7=b.COMACC_B7
        from #LISTE a, #TLIFDRI b
         where a.ACMTRS_NT=b.ACMTRS_NT

      update #LISTE
       set ESTMNT_M1=b.ESTMNT_M1
          ,ESTMNT_M2=b.ESTMNT_M2
          ,ESTMNT_M3=b.ESTMNT_M3
          ,ESTMNT_M4=b.ESTMNT_M4
          ,ESTMNT_M5=b.ESTMNT_M5
          ,ESTMNT_M6=b.ESTMNT_M6
          ,ESTMNT_M7=b.ESTMNT_M7
       from #LISTE a, #TLIFEST_AV b
        where a.ACMTRS_NT=b.ACMTRS_NT

      update #LISTE
       set AESTMNT_M1=b.AESTMNT_M1
          ,AESTMNT_M2=b.AESTMNT_M2
          ,AESTMNT_M3=b.AESTMNT_M3
          ,AESTMNT_M4=b.AESTMNT_M4
          ,AESTMNT_M5=b.AESTMNT_M5
          ,AESTMNT_M6=b.AESTMNT_M6
          ,AESTMNT_M7=b.AESTMNT_M7
        from #LISTE a, #TLIFEST_AP b
         where a.ACMTRS_NT=b.ACMTRS_NT
   End
-- FIN IF

select   @SEUIL_M=round(@SEUIL_M / b.EXC_R / 1000,3)
  from   BREF..TCURQUOT b
 where   b.CUR_CF=isnull(@CURLIF_CF, @CURCTR_CF)
   and   b.SSD_CF=@SSD_CF
   and   b.EXC_D=( select  max(x.EXC_D)
                     from  BREF..TCURQUOT x
                    where  x.EXC_D<=isnull(@p_CRE_D,@STAT_REP_D)
                      and  x.CUR_CF=b.CUR_CF
                      and  x.SSD_CF=b.SSD_CF)

if @SEUIL_M=null select @SEUIL_M=0

select
  ACMTRS_NT
 ,ESTMNT_M1
 ,ESTMNT_M2
 ,ESTMNT_M3
 ,ESTMNT_M4
 ,ESTMNT_M5
 ,ESTMNT_M6
 ,ESTMNT_M7
 ,COMACC_B1
 ,COMACC_B2
 ,COMACC_B3
 ,COMACC_B4
 ,COMACC_B5
 ,COMACC_B6
 ,COMACC_B7
 ,AN1=@p_BALSHEY_NF - 4
 ,AN2=@p_BALSHEY_NF - 3
 ,AN3=@p_BALSHEY_NF - 2
 ,AN4=@p_BALSHEY_NF - 1
 ,AN5=@p_BALSHEY_NF
 ,AN6=@p_BALSHEY_NF + 1
 ,AN7=@p_BALSHEY_NF + 2
 ,AESTMNT_M1
 ,AESTMNT_M2
 ,AESTMNT_M3
 ,AESTMNT_M4
 ,AESTMNT_M5
 ,AESTMNT_M6
 ,AESTMNT_M7
 ,SEUIL_M=@SEUIL_M
 ,ACMTRS_LL
 ,DIFF_M1=isnull(AESTMNT_M1,0) - isnull(ESTMNT_M1,0)
 ,DIFF_M2=isnull(AESTMNT_M2,0) - isnull(ESTMNT_M2,0)
 ,DIFF_M3=isnull(AESTMNT_M3,0) - isnull(ESTMNT_M3,0)
 ,DIFF_M4=isnull(AESTMNT_M4,0) - isnull(ESTMNT_M4,0)
 ,DIFF_M5=isnull(AESTMNT_M5,0) - isnull(ESTMNT_M5,0)
 ,DIFF_M6=isnull(AESTMNT_M6,0) - isnull(ESTMNT_M6,0)
 ,DIFF_M7=isnull(AESTMNT_M7,0) - isnull(ESTMNT_M7,0)
 From #LISTE

if object_id('#LISTE')     is not null drop Table #LISTE
if object_id('#TLIFDRI')   is not null drop Table #TLIFDRI
if object_id('#TLIFMOD2')  is not null drop Table #TLIFMOD2
if object_id('#TLIFEST_AV')is not null drop Table #TLIFEST_AV
if object_id('#TLIFEST_AP')is not null drop Table #TLIFEST_AP
if object_id('#GROUPE')    is not null drop Table #GROUPE

return 0
go

if object_id('dbo.PsLIFMOD2_01') is not null
  print '<<< CREATED procedure dbo.PsLIFMOD2_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsLIFMOD2_01 >>>'
go

grant execute on dbo.PsLIFMOD2_01 To GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFMOD2_01 TO GDBBATCH
go
