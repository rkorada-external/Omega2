-- script d'update global pour 

if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFDMRG0')  
	insert into BEST..TI17CHN values ('ESFDMRG0',  '')

--
-- TABLE TI17FNC
--

if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_EXTENDED'  ) 
	insert into BEST..TI17FNC values ('I17L_EXTENDED','',  'ESFDMRG0',0)

if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_EXTENDED'  ) 
	insert into BEST..TI17FNC values ('I17P_EXTENDED', '', 'ESFDMRG0', 0)

--
--- TABLE TI17REQ
--
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17LQPOSX') 
	INSERT INTO  BEST..TI17REQ  VALUES ( 'I17LQPOSX', 'Quarterly POS IFRS 17 Local EXTENDED Closing', 'N', 'K' )

if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17PQPOSX') 
	INSERT INTO BEST..TI17REQ   VALUES ( 'I17PQPOSX', 'Quarterly POS IFRS 17 Local EXTENDED Closing', 'N', 'K' )

if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17LYPOSX') 
	INSERT INTO BEST..TI17REQ   VALUES ( 'I17LYPOSX', 'Annual POS IFRS 17 Parent EXTENDED Closing', 'N', 'H' )

if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17PYPOSX') 
	INSERT INTO BEST..TI17REQ VALUES ( 'I17PYPOSX', 'Annual POS IFRS 17 Parent EXTENDED Closing', 'N', 'H' )
go
