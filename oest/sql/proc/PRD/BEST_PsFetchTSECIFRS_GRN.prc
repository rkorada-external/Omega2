use BEST
go
if object_id('dbo.PsFetchTSECIFRS_GRN') is not null
begin
  drop PROC dbo.PsFetchTSECIFRS_GRN
  print '<<< DROPPED PROC dbo.PsFetchTSECIFRS_GRN >>>'
end
go

create procedure dbo.PsFetchTSECIFRS_GRN
(
  @p_user_site varchar(5)
)
with execute as caller as 


/**************************************************************************************************
Programme                : PsFetchTSECIFRS_GRN
Fichier script associé   : BEST_PsFetchTSECIFRS_GRN.prc
Domaine                  : (ES) Estimation
Base principale          : BEST
Version                  : 1
Auteur                   : JYP - PERSEE 
Date de creation         : 21/01/2022
Description du programme : Extraction from TSECIFRS table for Granularity process
                      
_____________________________________________________
[001] 24/01/2022 JYP  :SPIRA 101782 : création
[002] 08/06/2022 JYP  :SPIRA 104771 : IFRS17 Product defaulting
************************************************************************************************/

---- TREATY ----
SELECT  t.ctr_nf , t.end_nt, t.sec_nf  , t.uwy_nf, t.uw_nt , 
		t.GRPIFRSSEG_CT,
		t.GRPINIPRO_CF ,
		t.GRPIFRSTRA_CT,
		t.PARIFRSSEG_CT, 
		t.PARINIPRO_CF , 
		t.PARIFRSTRA_CT, 
		t.LOCIFRSSEG_CT, 
		t.LOCINIPRO_CF , 
		t.LOCIFRSTRA_CT, 
		GRPINISTS_CT ,
		PARINISTS_CT ,
		LOCINISTS_CT,
		@p_user_site,
		'A' ,
		f.LIFE_CF,e.PARM1,e.PARM2
FROM btrt..TSECIFRS t , BREF..TBATCHSSD b, btrt..TCONTR d , BEST..TI17CLOPER e, BREF..TESB f
WHERE b.BATCHUSER_CF = @p_user_site
AND b.SSD_CF =  d.SSD_CF 
AND t.CTR_NF = d.CTR_NF AND t.UWY_NF = d.UWY_NF  AND t.UW_NT  = d.UW_NT  AND t.END_NT = d.END_NT
AND d.SSD_CF *= e.SSD_CF AND d.ACCESB_CF *= e.ESB_CF
AND d.SSD_CF *= f.SSD_CF AND d.ACCESB_CF *= f.ESB_CF
UNION
---- FAC ----
SELECT  t.ctr_nf , t.end_nt, t.sec_nf  , t.uwy_nf, t.uw_nt , 
		t.GRPIFRSSEG_CT,
		t.GRPINIPRO_CF ,
		t.GRPIFRSTRA_CT,
		t.PARIFRSSEG_CT, 
		t.PARINIPRO_CF , 
		t.PARIFRSTRA_CT, 
		t.LOCIFRSSEG_CT, 
		t.LOCINIPRO_CF , 
		t.LOCIFRSTRA_CT, 
		GRPINISTS_CT ,
		PARINISTS_CT ,
		LOCINISTS_CT,
		@p_user_site,
		'F' ,
		f.LIFE_CF,e.PARM1,e.PARM2
FROM bfac..TSECIFRS t, BREF..TBATCHSSD b, bfac..TCONTR d , BEST..TI17CLOPER e, BREF..TESB f
WHERE b.BATCHUSER_CF = @p_user_site
AND b.SSD_CF =  d.SSD_CF 
AND t.CTR_NF = d.CTR_NF AND t.UWY_NF = d.UWY_NF  AND t.UW_NT  = d.UW_NT  AND t.END_NT = d.END_NT
AND d.SSD_CF *= e.SSD_CF AND d.ACCESB_CF *= e.ESB_CF
AND d.SSD_CF *= f.SSD_CF AND d.ACCESB_CF *= f.ESB_CF

GO

if object_id('dbo.PsFetchTSECIFRS_GRN') is not null
  print '<<< CREATED PROC dbo.PsFetchTSECIFRS_GRN >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFetchTSECIFRS_GRN >>>'
go
grant execute on dbo.PsFetchTSECIFRS_GRN TO GOMEGA
go
grant execute on dbo.PsFetchTSECIFRS_GRN TO GDBBATCH
go



	 