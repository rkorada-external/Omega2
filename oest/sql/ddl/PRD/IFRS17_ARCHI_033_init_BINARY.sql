USE BEST
go

---------------------------------------------------------------
-- IFRS17_ARCHI_03_init_EBS.sql
---------------------------------------------------------------

-- M.NAJI spira 69157 : Init  New freamwork
-- [000] 05/12/2018 R. Cassis :spira:65656 - EBS FORCED IBNR : Nommage fichier pour fichier EST_FCTREST pour EBS POCE POSE et autres modifs
-- [000] 08/01/2019 R. Cassis :spira:xxxxx - EBSSO remplace par DLDGTAASIISO
-- [001] 28/02/2019 MZM       :spira:70671 - Ajout fichiers ESPD2570
-- [001] 11/03/2019 M.NAJI    :spira:73132 - Migration new arch
-- [005] 10/04/2019 R. cassis :spira:65656 - Ajustement des noms de fichiers FCTREST pour la separation IFRS/EBS, ajout ESPD8000 et diverses corrections
-- [006] 19/04/2019 JYP : spira 75589 - bugfix POCE mapping SEGEST
-- [007] 24/04/2019 JYP : spira 71570 : bugfix file for IFRS req 11.2



delete BEST..TI17PERMFIL 
where IDF_CT in ('POSE','POCE')  
and PERMFIL_CT in ('EST_FBOPRSLNK_TXT','EST_FPRSMAP_TXT','EST_FTRSLNK_TXT')

go

insert into BEST..TI17PERMFIL  values ('POSE','EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT.dat',' ',' ')
insert into BEST..TI17PERMFIL  values ('POSE','EST_FPRSMAP_TXT','${DFILP}/${PCH}ESPT0000_FPRSMAP_TXT.dat',' ',' ')
insert into BEST..TI17PERMFIL  values ('POSE','EST_FTRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FTRSLNK_TXT.dat',' ',' ')


insert into BEST..TI17PERMFIL  values ('POCE','EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT.dat',' ',' ')
insert into BEST..TI17PERMFIL  values ('POCE','EST_FPRSMAP_TXT','${DFILP}/${PCH}ESPT0000_FPRSMAP_TXT.dat',' ',' ')
insert into BEST..TI17PERMFIL  values ('POCE','EST_FTRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FTRSLNK_TXT.dat',' ',' ')

go


