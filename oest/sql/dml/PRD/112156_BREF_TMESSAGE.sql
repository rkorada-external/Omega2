use BREF
go

delete from BREF..TMESSAGE where MESSTHM_C = "ESTIMATION" and MESS_N in(20051, 20052, 20053)

go

-- EN message
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("E", "ESTIMATION", 20051, "The file must contain 10 columns.", 1, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("E", "ESTIMATION", 20052, "In the line § the LCI Ratio is not a rate.", 1, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("E", "ESTIMATION", 20053, "In the line § the LCR Ratio is not a rate.", 1, 0)

go

-- FR message
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("F", "ESTIMATION", 20051, "Le fichier doit contenir 10 colonnes.", 1, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("F", "ESTIMATION", 20052, "Sur la ligne § le ratio de LCI n'est pas un taux.", 1, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("F", "ESTIMATION", 20053, "Sur la ligne § le ratio de LCR n'est pas un taux.", 1, 0)

go