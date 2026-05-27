-- spira 29791
select ctr_nf, ssd_cf,esb_cf, acy_nf, scoendmth_nf, year(blcsht_d) balsheyacc_nf into #cplacc12 from bcta..tcplacc where scoendmth_nf = 12
go

select distinct a.*, b.balsheyacc_nf into #lifdricc  from best..tlifdri a, #cplacc12 b where a.ctr_nf = b.ctr_nf
                                                                 and     a.acy_nf = b.acy_nf
                                                                 and     a.ACY_NF < 2012
                                                                 and     a.COMACC_B = 0
                                                                 and     a.cre_d= (select max(cre_d) from best..tlifdri c where a.ctr_nf = c.ctr_nf and a.acy_nf = c.acy_nf and a.sec_nf = c.sec_nf )
                                                                 and     a.balshey_nf= (select max(balshey_nf) from best..tlifdri c where a.ctr_nf = c.ctr_nf and a.acy_nf = c.acy_nf and a.sec_nf = c.sec_nf )
go


insert into best..tlifdri 
select ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt, getdate() cre_d, balsheyacc_nf, 12, acy_nf, ssd_cf, autupd_b, 1, cmt_nt, creusr_cf, getdate(), lstupdusr_cf,respropag_b, segupd_b from #lifdricc
go

drop table #cplacc12
go

drop table #lifdricc
go
