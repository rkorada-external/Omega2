use BREF
go

delete from BREF..TMESSAGE where MESSTHM_C = "ESTIMATION" and MESS_N in(20047, 20048, 20049, 20050, 20051)

go

-- EN message
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("E", "ESTIMATION", 20047, "The file must contain 6 columns", 0, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("E", "ESTIMATION", 20048, "In the line §, the U/W year is not an integer", 0, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("E", "ESTIMATION", 20049, "In the line §, the LoB N2 is not an integer", 0, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("E", "ESTIMATION", 20050, "In the line §, the LoB N2 is not in the segmentation", 0, 0)
-- insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("E", "ESTIMATION", 20051, "The file must contained in contract nature column F, N or P", 0, 0) -- message 30106
go

-- FR message
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("F", "ESTIMATION", 20047, "Le fichier doit contenir 6 colonnes", 0, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("F", "ESTIMATION", 20048, "Sur la ligne §, l'exercice n'est pas un entier", 0, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("F", "ESTIMATION", 20049, "Sur la ligne §, la LoB N2 n'est pas un entier", 0, 0)
insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("F", "ESTIMATION", 20050, "Sur la ligne §, la LoB N2 n'est pas dans la segmentation", 0, 0)
--insert into BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) values ("F", "ESTIMATION", 20051, "La colonne Nature du contrat doit être égale à F, N ou P", 0, 0) -- message 30106
go
