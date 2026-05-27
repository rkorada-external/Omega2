delete from BREF..TMESSAGE
where MESSTHM_C = 'ESTIMATION'
and MESS_N in
(
      811
)
go

--
-- TABLE INSERT STATEMENTS
-- SPIRA#110445
INSERT INTO BREF..TMESSAGE ( LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T ) VALUES ( 'E', 'ESTIMATION  ', 811, 'Last update done by DIP can not be overwritten.', 1, 0 )
INSERT INTO BREF..TMESSAGE ( LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T ) VALUES ( 'F', 'ESTIMATION  ', 811, 'La dernière mise à jour a été effectuée par DIP et ne peut pas être remplacée par un chargement manuel.', 1, 0 )
go