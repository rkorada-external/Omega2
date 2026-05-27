Use BREF
go
update TMESSAGE 
SET MESS_L ="No valid exercise for this contract" where MESS_N = 103 and MESSTHM_C = "ESTIMATION  " and LANG_C = "E"
go
update TMESSAGE 
SET MESS_L ="No valid exercise for this contract" where MESS_N = 122 and MESSTHM_C = "ESTIMATION  " and LANG_C = "E"
go
update TMESSAGE 
SET MESS_L ="Pas d'exercice valide pour ce contrat " where MESS_N = 103 and MESSTHM_C = "ESTIMATION  " and LANG_C = "F"
go
update TMESSAGE 
SET MESS_L ="Pas d'exercice valide pour ce contrat " where MESS_N = 122 and MESSTHM_C = "ESTIMATION  " and LANG_C = "F"
go

Delete from TMESSAGE where MESS_N = 138 and MESSTHM_C = "ESTIMATION"


insert into TMESSAGE 
(BUTT_T,ICON_T,LANG_C,MESSTHM_C,MESS_L,MESS_N)
values 
(0,1,'E',"ESTIMATION", "No Valid section for this contract",138)
go
insert into TMESSAGE 
(BUTT_T,ICON_T,LANG_C,MESSTHM_C,MESS_L,MESS_N)
values 
(0,1,'F',"ESTIMATION", "Section invalide pour ce contrat",138)
go
