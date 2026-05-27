use BEST
go

delete BEST..TLIFDRI
where CTR_NF in (select distinct ts.CTR_NF from BTRT..TSECTION ts, BEST..TLIFDRI tl where ts.CTR_NF=tl.CTR_NF and ts.SEC_NF=tl.SEC_NF and ts.LOB_CF not in ('30','31')) 

go