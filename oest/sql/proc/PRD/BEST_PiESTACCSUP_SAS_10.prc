USE BEST
go
IF OBJECT_ID('PiESTACCSUP_SAS_10') IS NOT NULL
BEGIN
  DROP PROC PiESTACCSUP_SAS_10
  PRINT '<<< DROPPED PROC PiESTACCSUP_SAS_10 >>>'
END
go
create procedure PiESTACCSUP_SAS_10(
  @p_balshtyea_nf int,
  @p_balshtmth_nf tinyint,
  @p_clodatmax_d  datetime,
  @p_ssd_cf int,
  @p_esb_cf UESB_CF,
  @p_cre_d  datetime,
  @p_NORME      varchar(4),
  @p_usr_cf char(4),
  @trnmax_nt int = 0,
  @p_File   varchar(10) = 'N',
  @isPostingSas_d datetime = NULL )
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M.NAJI
Date de creation: 21/11/2024
Description du programme: 	
	- nettoyage ou inversion des montants dans BEST..TACCSUP
	- lancement de PiACCSUP_04
	- commit si pas d'annos sinon rollback
Conditions d'execution: 
Commentaires: remplace PiACCSUP_04 de ESIJ8000
_________________
Auteur          | Date        | Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
-- 18-03-2025 MOD[001] - S.Behague - 111789 - Control/Limit SAS data volume in Omega
-- 25-06-2025 MOD[002] - S.Behague US:5884:Control/Limit SAS AE data volume in Omega- Review AE remove conditions
-- 08-10-2025 MOD[003] - S.Behague US:6233:Spira 111627 - L&H-SAS AE load error management
*****************************************************/
declare @erreur       int,
        @result04     int,
        @tran_imbr    bit,
        @datej        datetime
        --@maxtrn_nt    int 

select @tran_imbr = 1 
select @erreur=0
select @datej=getdate()

print 'PiESTACCSUP_SAS_10 ==> @isPostingSas_d = %1! ',  @isPostingSas_d

--- Traitement si l'appel est d'origine SAS, Fichier SAS en entrée

IF @p_File = "CSMENGI"
BEGIN
  -- 1ere ETAPE : Sélection des AE SAS à effacer
  -----------------------------------------------
  select a.TRN_NT, 0 AS SENDED_B  
  into  #TO_DELETE   FROM  BEST..TACCSUP a
  where 
        ( VALPERY_NF > @p_balshtyea_nf or
        ( VALPERY_NF = @p_balshtyea_nf and VALPERMTH_NF >= @p_balshtmth_nf ) )
        and speentnat_ct in (9, 10, 11) 
        AND SPEENTTYP_CF in (8, 9)
                AND ( 
                    ( substring(TRNCOD_CF,8,1) IN ('I', 'J') AND @p_NORME = 'I17G' ) OR
                    ( substring(TRNCOD_CF,8,1) IN ('K', 'L') AND @p_NORME = 'I17P' ) OR
                    ( substring(TRNCOD_CF,8,1) IN ('M', 'N') AND @p_NORME = 'I17L' )
                )
        and TRN_NT <= @trnmax_nt
        and ssd_cf = @p_ssd_cf
        and esb_cf = @p_esb_cf
        and exists(select 1 from BREF..TBATCHSSD c where a.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())

  select @erreur = @@error
  if @erreur != 0  goto fin

  UPDATE #TO_DELETE SET SENDED_B = 1
  FROM   #TO_DELETE d, BEST..TACCSUPSAP s
  WHERE  d.TRN_NT = s.TRN_NT
  AND    s.SENDED_B  = 1

  UPDATE #TO_DELETE SET SENDED_B = 1
  FROM   #TO_DELETE d, BEST..TACCSUPSAP s
  WHERE  d.TRN_NT = s.TRN_NT
  AND    s.ISCANCELATION_B  = 1
  
  select @erreur = @@error
  if @erreur != 0  goto fin

  DELETE FROM #TO_DELETE
  WHERE SENDED_B = 1

  select @erreur = @@error
  if @erreur != 0  goto fin


  -- 2eme ETAPE : Sélection des AE SAS à annuler
  -----------------------------------------------
  
  SELECT TOP 1 *, TRN_NT ORIGTRN_NT INTO #TO_INSERT FROM BEST..TACCSUP
  DELETE FROM #TO_INSERT
  
  INSERT INTO #TO_INSERT
  select  1 TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
    BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, a.CTR_NF,
    END_NT, a.SEC_NF, a.UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF, 
    CUR_CF, sum(AMT_M) AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, a.RETCTR_NF, RETEND_NT, a.RETSEC_NF,
    a.RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, 
    RETCUR_CF, sum(RETAMT_M) RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, max(a.CRE_D) CRE_D,
    CREUSR_CF, max(a.LSTUPD_D) LSTUPD_D, a.LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF, a.TRN_NT   --[008]
  from  BEST..TACCSUP a, BEST..TACCSUPSAP  b
  where 
        a.TRN_NT = b .TRN_NT
        and b.SENDED_B = 1
        and b.CRE_D < @p_cre_d
        and ( VALPERY_NF > @p_balshtyea_nf or
        ( VALPERY_NF = @p_balshtyea_nf and VALPERMTH_NF >= @p_balshtmth_nf ) )
        and speentnat_ct in (9, 10, 11) 
        AND SPEENTTYP_CF in (8, 9)
                AND ( 
                    ( substring(TRNCOD_CF,8,1) IN ('I', 'J') AND @p_NORME = 'I17G' ) OR
                    ( substring(TRNCOD_CF,8,1) IN ('K', 'L') AND @p_NORME = 'I17P' ) OR
                    ( substring(TRNCOD_CF,8,1) IN ('M', 'N') AND @p_NORME = 'I17L' )
                )
        and ssd_cf = @p_ssd_cf
        and esb_cf = @p_esb_cf
        and exists(select 1 from BREF..TBATCHSSD c where a.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())
  group by ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
    BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, a.CTR_NF,
    END_NT, a.SEC_NF, a.UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF, 
    CUR_CF, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, a.RETCTR_NF, RETEND_NT, a.RETSEC_NF,
    a.RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, 
    RETCUR_CF, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL,  CREUSR_CF, a.LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF, a.TRN_NT

  select @erreur = @@error
  if @erreur != 0  goto fin


  -- Effacement de #TO_INSERT des TRN_NT origine pour lesquelles les annulations ont déjà déjà envoyées
  delete #TO_INSERT from #TO_INSERT ins, best..taccsupsap sap
  where  ins.origtrn_nt = sap.origtrn_nt
  and    sap.ISCANCELATION_B = 1

  -- Effacement de #TO_INSERT des TRN_NT annulations pour qu'elles ne soient pas réannulées
  delete #TO_INSERT from #TO_INSERT ins, best..taccsupsap sap
  where  ins.origtrn_nt = sap.trn_nt
  and    sap.ISCANCELATION_B = 1
  
  select @erreur = @@error
  if @erreur != 0  goto fin


  delete from #TO_INSERT
  where (RETCTR_NF != "" AND RETCTR_NF != "NULL" AND RETAMT_M = 0) OR (CTR_NF != "" AND AMT_M = 0)


  select @erreur = @@error
  if @erreur != 0  goto fin


END -- END Traitement fichiers SAS

  
execute @result04=BEST..PiACCSUP_SAS_04 @p_ssd_cf, @p_esb_cf, @p_usr_cf,'batch', @datej, @isPostingSas_d

select @erreur = @@error

if @erreur != 0  goto fin

IF  ( 	select count(*) from BEST..TCTRANO  
		where SSD_CF=@p_ssd_cf and 
			SEGTYP_CT = 'A' and 
			SEG_NF = @p_usr_cf and 
			NUMLINE_NT != 0 and 
			ANO_CT != 1 ) = 0 and @p_File = "CSMENGI" and @result04 = 0

BEGIN 
   if @@trancount = 0
     begin
     select @tran_imbr = 0
     BEGIN TRAN
   end
  
   -- 1 - Effacement des AE SAS non bookées de TACCSUP   
   DELETE BEST..TACCSUP FROM BEST..TACCSUP t,  #TO_DELETE bt
   where t.TRN_NT = bt.TRN_NT

   select @erreur = @@error
   if @erreur != 0  goto fin

   -- 1 - Effacement des AE SAS non bookées de TACCSUPSAP
   DELETE BEST..TACCSUPSAP FROM BEST..TACCSUPSAP t,  #TO_DELETE bt
   where t.TRN_NT = bt.TRN_NT

   select @erreur = @@error
   if @erreur != 0  goto fin


   -- Create Cursor
   declare insert_taccsup  cursor  for
   select trn_nt from #TO_INSERT

   declare @trn_nt int, @maxtrn_nt int, @curtrn_nt int

   select @maxtrn_nt =  max(trn_nt) from best..taccsup
   select @curtrn_nt = 1

   -- Open Cursor
   open insert_taccsup

   -- Fetch Cursor
   fetch insert_taccsup into @trn_nt

   While (@@sqlstatus = 0)
   BEGIN
       update #TO_INSERT set trn_nt = @curtrn_nt + @maxtrn_nt where current of insert_taccsup
       select @curtrn_nt = @curtrn_nt + 1
       fetch insert_taccsup into @trn_nt
   END

   -- Close and Desalocate Cursor
   CLOSE insert_taccsup
   deallocate cursor insert_taccsup

   -- Insertion of reverse amount 
   insert into best..taccsup 
   select TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
   BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
   END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF, 
   CUR_CF, AMT_M*-1, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
   RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, 
   RETCUR_CF, RETAMT_M*-1, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, getdate(),
   CREUSR_CF, getdate(), LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
   from #TO_INSERT
        
   select @erreur = @@error
   if @erreur != 0  goto fin 

   insert into best..taccsupsap
   select TRN_NT, ORIGTRN_NT, '', '', '', CTR_NF, SEC_NF, UWY_NF, RETCTR_NF, RETSEC_NF, RETRTY_NF, NULL, getdate(), getdate(), suser_name(), 1,0
   from #TO_INSERT
   
   select @erreur = @@error
   if @erreur != 0  goto fin 
END


if @tran_imbr = 0
        COMMIT TRAN
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN

return 1
go


EXEC sp_procxmode 'dbo.PiESTACCSUP_SAS_10', 'unchained'
go
IF OBJECT_ID('dbo.PiESTACCSUP_SAS_10') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiESTACCSUP_SAS_10 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiESTACCSUP_SAS_10 >>>'
go
GRANT EXECUTE ON dbo.PiESTACCSUP_SAS_10 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiESTACCSUP_SAS_10 TO GDBBATCH
go
