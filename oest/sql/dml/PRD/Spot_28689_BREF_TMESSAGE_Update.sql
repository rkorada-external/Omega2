delete from BREF..TMESSAGE
where MESSTHM_C = 'ESTIMATION'
and MESS_N in
(
      5030
    , 5031
)
go

--
-- TABLE INSERT STATEMENTS
--
INSERT INTO BREF..TMESSAGE ( LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T ) VALUES ( 'E', 'ESTIMATION  ', 5030, 'Acceptance contract does not exist.', 1, 0 )
INSERT INTO BREF..TMESSAGE ( LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T ) VALUES ( 'F', 'ESTIMATION  ', 5030, 'Contrat d''acceptation n''existant.', 1, 0 )
INSERT INTO BREF..TMESSAGE ( LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T ) VALUES ( 'E', 'ESTIMATION  ', 5031, 'Retro contract does not exist.', 1, 0 )
INSERT INTO BREF..TMESSAGE ( LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T ) VALUES ( 'F', 'ESTIMATION  ', 5031, 'Contrat retro n''existant.', 1, 0 )
go
