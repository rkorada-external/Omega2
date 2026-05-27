USE BREF
go

DELETE FROM BREF..TMESSAGE where MESS_N in (20058,20059,20060,20061,20062,20063,20064,20065,20066,20067,20057)
go

INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('E', 'ESTIMATION', 20058, 'The ledger does not match the geographical site of the server', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('E', 'ESTIMATION', 20059, 'The Ledger is not available for that I17 closing type', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('E', 'ESTIMATION', 20060, 'The currency must be the EGPI currency', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('E', 'ESTIMATION', 20061, 'The currency must be the main currency', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('E', 'ESTIMATION', 20062, 'The Underlying Assumed of the Proportional Retro Contract is missing', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('E', 'ESTIMATION', 20063, 'The Underlying Assumed of the Retro Contract is missing for the internal Assumed row', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('E', 'ESTIMATION', 20064, 'The Ledger must match the Assumed Contract', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('E', 'ESTIMATION', 20065, 'The Ledger must match the Retro Contract', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('E', 'ESTIMATION', 20066, 'New row added to the file', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('E', 'ESTIMATION', 20067, 'The Segment is required', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('E', 'ESTIMATION', 20057, 'The last file is still being processed. Please contact the support if the processing time exceed 30 minutes.', 1, 0)

INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('F', 'ESTIMATION', 20058, 'L''Etablissement n''appartient pas au site geographique du serveur', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('F', 'ESTIMATION', 20059, 'L''Etablissement n''est pas eligible pour ce type de closing I17', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('F', 'ESTIMATION', 20060, 'La devise doit etre celle de l''engagement', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('F', 'ESTIMATION', 20061, 'La devise doit etre la devise principale', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('F', 'ESTIMATION', 20062, 'Le Contrat d''Acceptation lie au Contrat Retro Proportionnel est manquant', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('F', 'ESTIMATION', 20063, 'Le Contrat d''Acceptation lie au Contrat Retro est manquant pour la ligne d''Acceptation interne', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('F', 'ESTIMATION', 20064, 'L''Etablissement doit correspondre au Contrat d''Acceptation', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('F', 'ESTIMATION', 20065, 'L''Etablissement doit correspondre au Contrat Retro', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('F', 'ESTIMATION', 20066, 'Nouvel enregistrement ajoute au fichier', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('F', 'ESTIMATION', 20067, 'Le Segment doit etre fourni', 1, 0)
INSERT INTO BREF..TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) VALUES ('F', 'ESTIMATION', 20057, 'Le dernier fichier est toujours en cours de traitement. Veuillez contactez le support si le delai de traitement depasse 30 minutes.', 1, 0)
go