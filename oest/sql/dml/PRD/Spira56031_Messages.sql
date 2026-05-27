Use BREF
go


Delete from TMESSAGE where MESS_N = 30020 and MESSTHM_C = "ESTIMATION"
go

insert into TMESSAGE 
(BUTT_T,ICON_T,LANG_C,MESSTHM_C,MESS_L,MESS_N)
values 
(0,1,'E',"ESTIMATION", "The placement is disabled for estimates.",30020)
go
insert into TMESSAGE 
(BUTT_T,ICON_T,LANG_C,MESSTHM_C,MESS_L,MESS_N)
values 
(0,1,'F',"ESTIMATION", "Le placement est bloqué pour les estimations.",30020)
go
