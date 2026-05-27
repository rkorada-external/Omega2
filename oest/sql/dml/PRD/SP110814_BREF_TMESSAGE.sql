use BREF
go

delete from BREF..TMESSAGE where MESSTHM_C = "ESTIMATION" and MESS_N in (30138, 30139)

go

-- EN message
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("E", "ESTIMATION", 30138, "The file must contain 9 columns", 0, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("E", "ESTIMATION", 30139, "In the line §, the Maintenance Ratio INI is not a rate", 0, 0)
go

-- FR message
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("F", "ESTIMATION", 30138, "Le fichier doit contenir 9 colonnes", 0, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("F", "ESTIMATION", 30139, "Sur la ligne §, le ratio de maintenance INI n'est pas un taux", 0, 0)
go
