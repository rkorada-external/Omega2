use BREF
go

delete from BREF..TMESSAGE where MESSTHM_C = "ESTIMATION" and MESS_N in(20057)
go

-- EN message
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("E", "ESTIMATION", 20057, "The last file is still being processed. Please contact the support if the processing time exceed 30 minutes.", 1, 0)
go

-- FR message
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("F", "ESTIMATION", 20057, "Le dernier fichier est toujours en cours de traitement. Veuillez contactez le support si le délai de traitement depasse 30 minutes.", 1, 0)
go