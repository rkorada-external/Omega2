
-- SPIRA 104778 IFRS17 simulation - Build new closing for I17S norme

if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SMINV' ) INSERT INTO BEST..TI17REQ  VALUES ( 'I17SMINV' , 'Monthly INV IFRS 17 Simulation', 'N', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SMINVB') INSERT INTO BEST..TI17REQ  VALUES ( 'I17SMINVB', 'Monthly INV IFRS 17 Simulation booking', 'N', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SQINV' ) INSERT INTO BEST..TI17REQ  VALUES ( 'I17SQINV' , 'Quarterly INV IFRS 17 Simulation', 'N', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SQINVB') INSERT INTO BEST..TI17REQ  VALUES ( 'I17SQINVB', 'Quarterly INV IFRS 17 Simulation booking', 'Y', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SQPOC' ) INSERT INTO BEST..TI17REQ  VALUES ( 'I17SQPOC' , 'Quarterly POC IFRS 17 Simulation', 'N', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SQPOCB') INSERT INTO BEST..TI17REQ  VALUES ( 'I17SQPOCB', 'Quarterly POC IFRS 17 Simulation booking', 'N', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SQPOS' ) INSERT INTO BEST..TI17REQ  VALUES ( 'I17SQPOS' , 'Quarterly POS IFRS 17 Simulation', 'N', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SQPOSB') INSERT INTO BEST..TI17REQ  VALUES ( 'I17SQPOSB', 'Quarterly POS IFRS 17 Simulation booking', 'Y', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SQPOSP') INSERT INTO BEST..TI17REQ  VALUES ( 'I17SQPOSP', 'SAP IFRS 17 Simulation', 'Y', 'S' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SYINV' ) INSERT INTO BEST..TI17REQ  VALUES ( 'I17SYINV' , 'Annual INV IFRS 17 Simulation', 'N', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SYINVB') INSERT INTO BEST..TI17REQ  VALUES ( 'I17SYINVB', 'Annual INV IFRS 17 Simulation booking', 'Y', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SYPOC' ) INSERT INTO BEST..TI17REQ  VALUES ( 'I17SYPOC' , 'Annual POC IFRS 17 Simulation', 'N', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SYPOCB') INSERT INTO BEST..TI17REQ  VALUES ( 'I17SYPOCB', 'Annual POC IFRS 17 Simulation booking', 'N', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SYPOS' ) INSERT INTO BEST..TI17REQ  VALUES ( 'I17SYPOS' , 'Annual POS IFRS 17 Simulation', 'N', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SYPOSB') INSERT INTO BEST..TI17REQ  VALUES ( 'I17SYPOSB', 'Annual POS IFRS 17 Simulation booking', 'Y', 'G' )
if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT='I17SYPOSP') INSERT INTO BEST..TI17REQ  VALUES ( 'I17SYPOSP', 'SAP IFRS 17 Simulation', 'Y', 'S' )

go
