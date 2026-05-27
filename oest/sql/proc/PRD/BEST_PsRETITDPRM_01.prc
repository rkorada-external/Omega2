USE BEST
go
IF OBJECT_ID('dbo.PsRETITDPRM_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsRETITDPRM_01
    IF OBJECT_ID('dbo.PsRETITDPRM_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsRETITDPRM_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsRETITDPRM_01 >>>'
END
go
create procedure dbo.PsRETITDPRM_01
(
 @p_ICLODAT_D   datetime,
 @p_ssd_cf    USSD_CF
)
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BRET
Auteur: mzm
Date de creation: 30/01/2019
Description du programme: :Génération du fichier des ITD PREMIUM
Conditions d'execution: par ESID2571.cmd
				spira:70671:Future premium for retro NP contracts ; 
				spira:70782:Future claim for retro NP contracts 
				spira:70671:UPR ACTUAL MIS A JOUR
Commentaires:
_________________
MODIFICATIONS
[01] MZM 20/06/2019 : Ajout du placement et du RTO extrait à partir du fichier de placement construit; 
									  pour rappel, la table bret..tracctrn ne contient pas les placements valorisés.
									  La notion de SECTION n'est situé qu'au niveau contrat, ce qui justifie le fait
									  de ne pas inclure la section dans la cle de jointure.
[02] MZM 05/05/2020 : spira 81349 : Ajout du Retent à 0 au lieu de null, pour plus de lisibilité dans les logs
[03] MZM 28/05/2020 : spira 81349 : Ajout de la colonne  st.plcsta_nt qui Permet la distinction unque ITD Actual 								  
   
*****************************************************/

declare @erreur int

-------------------------
-- ITD PRMIUM RETRO NP
-------------------------

if @p_ssd_cf = 0
begin
       
select distinct
			ta.SSD_CF as GT_SSD_CF  				
			,st.ESB_CF as GT_ESB_CF -- ta.ESB_CF as GT_ESB_CF         
			, convert(char(4), BLCSHT_D , 112) as GT_BALSHEY_NF     
			, convert(char(2), BLCSHT_D , 110) as GT_BALSHRMTH_NF   
			, convert(char(2), BLCSHT_D , 106) as GT_BALSHRDAY_NF   
			, ta.TRNCOD_CF as GT_TRNCOD_CF      
			, null as GT_DBLTRNCOD_CF   
			, null as GT_CTR_NF         
			, null as GT_END_NT         
			, null as GT_SEC_NF         
			, null as GT_UWY_NF         
			, null as GT_UW_NT          
			, null as GT_OCCYEA_NF      
			, null as GT_ACY_NF         
			, null as GT_SCOSTRMTH_NF   
			, null as GT_SCOENDMTH_NF   
			, null as GT_CLM_NF         
			, null as GT_CUR_CF         
			, null as GT_AMT_M          
			, null as GT_CED_NF         
			, null as GT_BRK_NF  --ta.BRK_NF as GT_BRK_NF         
			, null as GT_PAY_NF         
			, null as GT_KEY_NF         
			, ta.RETCTR_NF as GT_RETCTR_NF    
			, 0 as GT_RETEND_NT   -- 02 null as GT_RETEND_NT   
			, ta.RETSEC_NF      
			, ta.RTY_NF         
			, null as GT_RETUW_NT       
			, null as GT_RETOCCYEA_NF   
			, ta.RETACCYER_NF as GT_RETACY_NF 
			, ta.SCOSTRMTH_NF as GT_RETSCOSTRMTH_NF
			, ta.SCOENDMTH_NF as GT_RETSCOENDMTH_NF
			, null as GT_RCL_NF         
			, st.ACCCUR_CF  as GT_RETCUR_CF       
			, (-1)*st.CNVAMT_M  as GT_RETAMT_M       
			, ta.PLC_NT as GT_PLC_NT       
			, st.RTO_NF as GT_RTO_NF        
			, st.INT_NF as GT_INT_NF         
			, null as GT_RETPAY_NF      
			, null as GT_RETKEY_CF      
			, null as GT_RETINTAMT_M    
			, null as GT_ESTCUR_CF      
			, null as GT_ESTAMT_M       
			, null as GT_NAT_CF         
			, tt.ACMTRS_NT as GT_ACMTRS_NT     
			, null as GT_ESTCTR_NF      
			, null as GT_ESTSEC_NF      
			, ta.LOB_CF as GT_LOB_CF       
			, null as GT_SCOEGP_M       
			, null as GT_ESTCRB_CT      
			, null as GT_LIFTRTTYP_CF   
			, null as GT_ACCADMTYP_CT   
			, null as GT_SECSTS_CT      
			, null as GT_PRD_NF         
			, null as GT_SEG_NF         
			, null as GT_COMACC_        
			, null as GT_ADJCOD_CT      
			, null as GT_ORICOD_CF      
			, null                        --tk.DETTRS_CF as GT_DETTRS_CF     
			, null as GT_ACCRET_B       
			, null as GT_ESTUWY_NF      
			, null as GT_LSTENDMTH_NF   
			, null as GT_PROPER_N       
			, null as GT_RTOCTY_CF
			,st.plcsta_nt        -- [03] Permet de distinguer toutes les lignes de ITD Actual unicité
      from bref..TTRSLNK tt,
     bret..tplcatrn ta,
     bret..trtosta  st,
     bret..tretctr   re
where tt.DETTRS_CF = ta.TRNCOD_CF
and st.PLC_NT	          = ta.PLC_NT	     
and st.RTY_NF	          = ta.RTY_NF	     
and st.SCOSTRMTH_NF     = ta.SCOSTRMTH_NF
and st.SCOENDMTH_NF	    = ta.SCOENDMTH_NF
and st.RETACCYER_NF	    = ta.RETACCYER_NF
and st.TRNCOD_CF	      = ta.TRNCOD_CF	 
and st.LOB_CF           = ta.LOB_CF      
and st.RETSEC_NF	      = ta.RETSEC_NF	 
and st.SSD_CF	          = ta.SSD_CF	     
and st.RETACCSEN_NT     = ta.RETACCSEN_NT
and re.RETCTR_NF        = ta.RETCTR_NF
and re.RTY_NF	          = ta.RTY_NF 
and re.SSD_CF	          = ta.SSD_CF	
and re.retctrcat_cf        = '02'
and   tt.ACMTRS_NT = 1010 
and   tt.PRS_CF = 751
and  	substring(ta.trncod_cf,1,2) in ('2A', '2E', '21', '24')
and   ta.LOB_CF<>'30' and ta.LOB_CF<>'31'
and   st.BLCSHT_D <=  @p_ICLODAT_D
order by ta.RETCTR_NF, ta.RETSEC_NF,  ta.RTY_NF,  ta.PLC_NT, st.RTO_NF   desc
end

   select @erreur = @@error
   if @erreur != 0
   begin
      return @erreur
   end
return 0
go
EXEC sp_procxmode 'dbo.PsRETITDPRM_01', 'unchained'
go
IF OBJECT_ID('dbo.PsRETITDPRM_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsRETITDPRM_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsRETITDPRM_01 >>>'
go
GRANT EXECUTE ON dbo.PsRETITDPRM_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsRETITDPRM_01 TO GDBBATCH
go
