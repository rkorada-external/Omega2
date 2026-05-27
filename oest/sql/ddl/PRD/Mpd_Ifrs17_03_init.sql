-- M.NAJI spira 69157 : Init  New freamwork
-- [000] 05/12/2018 R. Cassis :spira:65656 - EBS FORCED IBNR : Nommage fichier pour fichier EST_FCTREST pour EBS POCE POSE et autres modifs
-- [000] 08/01/2019 R. Cassis :spira:xxxxx - EBSSO remplace par DLDGTAASIISO
-- [001] 28/02/2019 MZM       :spira:70671 - Ajout fichiers ESPD2570
-- [002] 14/03/2019 MZM       :spira:70671 - Ajout fichiers ESPD2570 et DANS la CHAINE NOUVELLE IFRS17
-- [003] 27/03/2019 MZM       :spira:70671 - Ajout fichiers ESPD2570 et DANS la CHAINE NOUVELLE IFRS17 DLDGTRSO et DLDGTRCO
-- [004] 04/04/2019 JYP       :spira:77426 - bugfix POCE DLDGTAA file
-- [005] 17/04/2019 R. Cassis :spira:65656 - Mise a jour des jobs planifies et diverses corrections
-- [006] 19/04/2019 JYP       :spira:75589: EBS POCE : correction mapping FSEGEST
-- [007] 24/04/2019 JYP       :spira:71570: bugfix filename for IFRS req 11.2

delete BEST..TIfrs17Perm
delete BEST..TIfrs17ContextRequest
delete BEST..TIfrs17Plan
delete BEST..TIfrs17Request
delete BEST..TIfrs17Context
delete BEST..TIfrs17Chain



-- init TIfrs17Chain table
--
INSERT INTO BEST..TIfrs17Chain ( chain, comment ) VALUES ( 'ESGETDT0', NULL )
INSERT INTO BEST..TIfrs17Chain ( chain, comment ) VALUES ( 'ESPD3610', 'Cach flow calculation jobs ESID3702A et ESID3703A' )
INSERT INTO BEST..TIfrs17Chain ( chain, comment ) VALUES ( 'ESPD3620', 'Discount calcultion job ESID3703B' )
INSERT INTO BEST..TIfrs17Chain ( chain, comment ) VALUES ( 'ESPD3630', 'UPR cancellation job ESID3601A' )
INSERT INTO BEST..TIfrs17Chain ( chain, comment ) VALUES ( 'ESPD3640', 'Risk Marging calculation job ESPD3602A' )
INSERT INTO BEST..TIfrs17Chain ( chain, comment ) VALUES ( 'ESID2210', 'IFRS Losses and IBNR calculation' )
INSERT INTO BEST..TIfrs17Chain ( chain, comment ) VALUES ( 'ESID2220', 'EBS Losses and IBNR calculation' )
INSERT INTO BEST..TIfrs17Chain ( chain, comment ) VALUES ( 'ESPD2570', 'FUTURE FOR RETRO NP CONTRACT' )
INSERT INTO BEST..TIfrs17Chain ( chain, comment ) VALUES ( '*', NULL )
go 

--
--  init TIfrs17Context table
--
INSERT INTO BEST..TIfrs17Context ( ContextId, comment )   VALUES ( 'Always', 'Always' )
INSERT INTO BEST..TIfrs17Context ( ContextId, comment )   VALUES ( 'IFRS', 'Inventaire IFRS' )
INSERT INTO BEST..TIfrs17Context ( ContextId, comment )   VALUES ( 'EBS', 'Inventaire EBS' )
INSERT INTO BEST..TIfrs17Context ( ContextId, comment )   VALUES ( 'POSI', 'Post-omega Social IFRS' )
INSERT INTO BEST..TIfrs17Context ( ContextId, comment )   VALUES ( 'POSE', 'Post-omega Social EBS' )
INSERT INTO BEST..TIfrs17Context ( ContextId, comment )   VALUES ( 'POCI', 'Post-omega Conso IFRS' )
INSERT INTO BEST..TIfrs17Context ( ContextId, comment )   VALUES ( 'POCE', 'Post-omega Conso EBS' )
INSERT INTO BEST..TIfrs17Context ( ContextId, comment )   VALUES ( 'LOCAL', 'Local' )
INSERT INTO BEST..TIfrs17Context ( ContextId, comment )   VALUES ( 'PlanVie', 'Plan Vie' )
INSERT INTO BEST..TIfrs17Context ( ContextId, comment )   VALUES ( 'BookingSettel', 'Bookin settelment' )
go
--
-- init TIfrs17Request table
--
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'Always', 'Aucun inventaire programmé' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'IFRS', 'Inventaire IFRS' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'IFRS_TRIM', 'Inventaire IFRS_TRIM' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'EBS', 'Inventaire EBS' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'BookingTech', 'Compta technique' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'BookingTechTrim', 'Compta technique trimestrielle' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'BookingPOSEAnnuel', 'Compta technique annuelle' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'PlanVie', 'Plan Vie - Photoplan' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'POSI', 'Post-omega Social IFRS' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'BookingPOSI', 'Comptabilisation post-omega Social IFRS' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'POSE', 'Post-omega Social EBS4' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'BookingPOSE', 'Comptabilisation Post-omega Social EBS4' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'POCI', 'Post-omega Conso IFRS' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'BookingPOCI', 'Comptabilisation post-omega Conso IFRS' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'POCE', 'Post-omega Conso EBS4' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'BookingPOCE', 'Comptabilisation Post-omega Conso EBS4' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'BookingPOCEAnnuel', 'Comptabilisation Post-omega Conso EBS4 Annuelle' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'Local', 'Local' )
INSERT INTO BEST..TIfrs17Request ( requestId, comment )  VALUES ( 'BookingSettel', 'Bookin settelment' )
go
--
-- init TIfrs17Plan table
--
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POSE', 'ESID2210', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POSE', 'ESID2220', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POSE', 'ESPD2570', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POSE', 'ESPD3610', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POSE', 'ESPD3620', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POSE', 'ESPD3630', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POSE', 'ESPD3640', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POCE', 'ESID2210', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POCE', 'ESID2220', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POCE', 'ESPD2570', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POCE', 'ESPD3610', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POCE', 'ESPD3620', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POCE', 'ESPD3630', 'PLAN2', 'PostOmegaEBS' )
INSERT INTO BEST..TIfrs17Plan ( requestId, chain, planId, comment ) VALUES ( 'POCE', 'ESPD3640', 'PLAN2', 'PostOmegaEBS' )
go

--
-- init TIfrs17ContextRequest table
--
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'Always', 'Always', 'Aucun inventaire programmé' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'IFRS', 'IFRS', 'Inventaire IFRS' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'IFRS_TRIM', 'IFRS', 'Inventaire IFRS TRIM' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'EBS', 'EBS', 'Inventaire EBS' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'BookingTech', 'IFRS', 'Compta technique' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'BookingTechTrim', 'IFRS', 'Compta technique trimestrielle' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'PlanVie', 'PlanVie', 'Plan Vie - Photoplan' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'POSI', 'POSI', 'Post-omega Social IFRS' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'BookingPOSI', 'POSI', 'Comptabilisation post-omega Social IFRS' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'POSE', 'POSE', 'Post-omega Social EBS4' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'BookingPOSE', 'POSE', 'Comptabilisation Post-omega Social EBS4' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'POCI', 'POCI', 'Post-omega Conso IFRS' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'BookingPOCI', 'POCI', 'Comptabilisation post-omega Conso IFRS' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'POCE', 'POCE', 'Post-omega Conso EBS4' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'BookingPOCE', 'POCE', 'Comptabilisation Post-omega Conso EBS4' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'Local', 'local', 'Local' )
INSERT INTO BEST..TIfrs17ContextRequest ( requestId, ContextId, comment )         VALUES ( 'BookingSettel', 'BookingSettel', 'Booking settelment' )

go

--
--
-- init TIfrs17Perm table
--

                
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EPO_FCTREST0', 'POCE', '${DFILP}/${PCH}ESPT0000_FCTREST0.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EPO_FCTREST0', 'POCI', '${DFILP}/${PCH}ESPT0000_FCTREST0.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EPO_FCTREST0', 'POSE', '${DFILP}/${PCH}ESPT0000_FCTREST0.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EPO_FCTREST0', 'POSI', '${DFILP}/${PCH}ESPT0000_FCTREST0.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EPO_FCTRULT', 'POCE', '${DFILP}/${PCH}ESPT0000_FCTRULT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EPO_FCTRULT', 'POCI', '${DFILP}/${PCH}ESPT0000_FCTRULT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EPO_FCTRULT', 'POSE', '${DFILP}/${PCH}ESPT0000_FCTRULT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EPO_FCTRULT', 'POSI', '${DFILP}/${PCH}ESPT0000_FCTRULT.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EST_DLDGTAACUM', 'POCE', '${DFILP}/${PCH}ESID2210_DLDGTAACUM.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EST_DLDGTAACUM', 'POCI', '${DFILP}/${PCH}ESID2210_DLDGTAACUM.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EST_DLDGTAACUM', 'POSE', '${DFILP}/${PCH}ESID2210_DLDGTAACUM.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EST_DLDGTAACUM', 'POSI', '${DFILP}/${PCH}ESID2210_DLDGTAACUM.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EST_FCTRULT', 'POCE', '${DFILP}/${PCH}ESPT0000_FCTRULT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EST_FCTRULT', 'POCI', '${DFILP}/${PCH}ESPT0000_FCTRULT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EST_FCTRULT', 'POSE', '${DFILP}/${PCH}ESPT0000_FCTRULT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )   VALUES ( 0, 'EST_FCTRULT', 'POSI', '${DFILP}/${PCH}ESPT0000_FCTRULT.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_BLANCHIMENT_RPCC', 'POCE', '${DFILP}/${PCH}ESPD2000_BLANCHIMENT_RPCC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_BLANCHIMENT_RPCC', 'POSE', '${DFILP}/${PCH}ESPD2000_BLANCHIMENT_RPCC.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_CTRULT02', 'POCE', '${DFILP}/${PCH}ESPT0000_CTRULT02.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_CTRULT02', 'POCI', '${DFILP}/${PCH}ESPT0000_CTRULT02.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_CTRULT02', 'POSE', '${DFILP}/${PCH}ESPT0000_CTRULT02.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_CTRULT02', 'POSI', '${DFILP}/${PCH}ESPT0000_CTRULT02.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DCGTAALOA', 'POCE', '${DFILP}/${PCH}ESPT0000_DCGTAALOA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DCGTAALOA', 'POCI', '${DFILP}/${PCH}ESPT0000_DCGTAALOA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DCGTAALOA', 'POSE', '${DFILP}/${PCH}ESPT0000_DCGTAALOA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DCGTAALOA', 'POSI', '${DFILP}/${PCH}ESPT0000_DCGTAALOA.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAA', 'POCE', '${DFILP}/${PCH}ESPT0000_DLCGTAA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAA', 'POCI', '${DFILP}/${PCH}ESPT0000_DLCGTAA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAA', 'POSE', '${DFILP}/${PCH}ESPT0000_DLCGTAA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAA', 'POSI', '${DFILP}/${PCH}ESPT0000_DLCGTAA.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAAEPPE', 'POCE', '${DFILP}/${PCH}ESPT0000_DLCGTAAEPPE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAAEPPE', 'POCI', '${DFILP}/${PCH}ESPT0000_DLCGTAAEPPE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAAEPPE', 'POSE', '${DFILP}/${PCH}ESPT0000_DLCGTAAEPPE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAAEPPE', 'POSI', '${DFILP}/${PCH}ESPT0000_DLCGTAAEPPE.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAAREC', 'POCE', '${DFILP}/${PCH}ESPT0000_DLCGTAAREC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAAREC', 'POCI', '${DFILP}/${PCH}ESPT0000_DLCGTAAREC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAAREC', 'POSE', '${DFILP}/${PCH}ESPT0000_DLCGTAAREC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCGTAAREC', 'POSI', '${DFILP}/${PCH}ESPT0000_DLCGTAAREC.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCUMGTAA', 'POCE', '${DFILP}/${PCH}ESPT0000_DLCUMGTAA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCUMGTAA', 'POCI', '${DFILP}/${PCH}ESPT0000_DLCUMGTAA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCUMGTAA', 'POSE', '${DFILP}/${PCH}ESPT0000_DLCUMGTAA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCUMGTAA', 'POSI', '${DFILP}/${PCH}ESPT0000_DLCUMGTAA.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCUMGTAAS', 'POCE', '${DFILP}/${PCH}ESPT0000_DLCUMGTAAS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCUMGTAAS', 'POCI', '${DFILP}/${PCH}ESPT0000_DLCUMGTAAS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCUMGTAAS', 'POSE', '${DFILP}/${PCH}ESPT0000_DLCUMGTAAS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLCUMGTAAS', 'POSI', '${DFILP}/${PCH}ESPT0000_DLCUMGTAAS.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAFPRE', 'POCE', '${DFILP}/${PCH}ESPT0000_DLGTAAFPRE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAFPRE', 'POCI', '${DFILP}/${PCH}ESPT0000_DLGTAAFPRE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAFPRE', 'POSE', '${DFILP}/${PCH}ESPT0000_DLGTAAFPRE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAFPRE', 'POSI', '${DFILP}/${PCH}ESPT0000_DLGTAAFPRE.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAPA', 'POCE', '${DFILP}/${PCH}ESPT0000_DLGTAAPA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAPA', 'POCI', '${DFILP}/${PCH}ESPT0000_DLGTAAPA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAPA', 'POSE', '${DFILP}/${PCH}ESPT0000_DLGTAAPA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAPA', 'POSI', '${DFILP}/${PCH}ESPT0000_DLGTAAPA.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAPRE', 'POCE', '${DFILP}/${PCH}ESPT0000_DLGTAAPRE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAPRE', 'POCI', '${DFILP}/${PCH}ESPT0000_DLGTAAPRE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAPRE', 'POSE', '${DFILP}/${PCH}ESPT0000_DLGTAAPRE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAAPRE', 'POSI', '${DFILP}/${PCH}ESPT0000_DLGTAAPRE.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAARPPE', 'POCE', '${DFILP}/${PCH}ESPT0000_DLGTAARPPE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAARPPE', 'POCI', '${DFILP}/${PCH}ESPT0000_DLGTAARPPE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAARPPE', 'POSE', '${DFILP}/${PCH}ESPT0000_DLGTAARPPE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAARPPE', 'POSI', '${DFILP}/${PCH}ESPT0000_DLGTAARPPE.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAATFPNAE', 'POCE', '${DFILP}/${PCH}ESPT0000_DLGTAATFPNAE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAATFPNAE', 'POCI', '${DFILP}/${PCH}ESPT0000_DLGTAATFPNAE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAATFPNAE', 'POSE', '${DFILP}/${PCH}ESPT0000_DLGTAATFPNAE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DLGTAATFPNAE', 'POSI', '${DFILP}/${PCH}ESPT0000_DLGTAATFPNAE.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DTSTATGTAA', 'POCE', '${DFILP}/${PCH}ESPT0000_DTSTATGTAA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DTSTATGTAA', 'POCI', '${DFILP}/${PCH}ESPT0000_DTSTATGTAA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DTSTATGTAA', 'POSE', '${DFILP}/${PCH}ESPT0000_DTSTATGTAA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_DTSTATGTAA', 'POSI', '${DFILP}/${PCH}ESPT0000_DTSTATGTAA.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTREST', 'POCE', '${DFILP}/${PCH}ESPD0060_FCTRESTSII.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTREST', 'POCI', '${DFILP}/${PCH}ESPT0000_FCTREST.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTREST', 'POSE', '${DFILP}/${PCH}ESPD0060_FCTRESTSII.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTREST', 'POSI', '${DFILP}/${PCH}ESPT0000_FCTREST.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTREST0', 'POCE', '${DFILP}/${PCH}ESPT0000_FCTREST0.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTREST0', 'POCI', '${DFILP}/${PCH}ESPT0000_FCTREST0.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTREST0', 'POSE', '${DFILP}/${PCH}ESPT0000_FCTREST0.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTREST0', 'POSI', '${DFILP}/${PCH}ESPT0000_FCTREST0.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTREST1', 'POCE', '${DFILP}/${PCH}ESPD2000_FCTREST1SIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTREST1', 'POSE', '${DFILP}/${PCH}ESPD2000_FCTREST1SIISO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTRGRO1', 'POCE', '${DFILP}/${PCH}ESPT0000_FCTRGRO1.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTRGRO1', 'POCI', '${DFILP}/${PCH}ESPT0000_FCTRGRO1.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTRGRO1', 'POSE', '${DFILP}/${PCH}ESPT0000_FCTRGRO1.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FCTRGRO1', 'POSI', '${DFILP}/${PCH}ESPT0000_FCTRGRO1.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FLOARAT', 'POCE', '${DFILP}/${PCH}ESPD2000_FLOARAT_EBS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FLOARAT', 'POSE', '${DFILP}/${PCH}ESPD2000_FLOARAT_EBS.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FPRMLOA', 'POCE', '${DFILP}/${PCH}ESPD2000_FPRMLOA_EBS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FPRMLOA', 'POSE', '${DFILP}/${PCH}ESPD2000_FPRMLOA_EBS.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FSEGEST', 'POCE', '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO.dat', NULL, NULL, '*', NULL, NULL )
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FSEGEST', 'POCI', '${DFILP}/${PCH}ESPD0060_FSEGEST_xxx.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FSEGEST', 'POSE', '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO.dat', NULL, NULL, '*', NULL, NULL )
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FSEGEST', 'POSI', '${DFILP}/${PCH}ESPD0060_FSEGEST_xxx.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FT', 'POCE', '${DFILP}/${PCH}ESPT0000_FT_EBS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FT', 'POCI', '${DFILP}/${PCH}ESPT0000_FT_EBS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FT', 'POSE', '${DFILP}/${PCH}ESPT0000_FT_EBS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FT', 'POSI', '${DFILP}/${PCH}ESPT0000_FT_EBS.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTFAC', 'POCE', '${DFILP}/${PCH}ESPT0000_FTFAC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTFAC', 'POCI', '${DFILP}/${PCH}ESPT0000_FTFAC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTFAC', 'POSE', '${DFILP}/${PCH}ESPT0000_FTFAC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTFAC', 'POSI', '${DFILP}/${PCH}ESPT0000_FTFAC.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTFAMCHG', 'POCE', '${DFILP}/${PCH}ESPT0000_FTFAMCHG.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTFAMCHG', 'POCI', '${DFILP}/${PCH}ESPT0000_FTFAMCHG.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTFAMCHG', 'POSE', '${DFILP}/${PCH}ESPT0000_FTFAMCHG.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTFAMCHG', 'POSI', '${DFILP}/${PCH}ESPT0000_FTFAMCHG.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTHRHLDUWY', 'POCE', '${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTHRHLDUWY', 'POCI', '${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTHRHLDUWY', 'POSE', '${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTHRHLDUWY', 'POSI', '${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTTR_PRM', 'POCE', '${DFILP}/${PCH}ESPT0000_FTTR_PRM.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTTR_PRM', 'POCI', '${DFILP}/${PCH}ESPT0000_FTTR_PRM.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTTR_PRM', 'POSE', '${DFILP}/${PCH}ESPT0000_FTTR_PRM.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_FTTR_PRM', 'POSI', '${DFILP}/${PCH}ESPT0000_FTTR_PRM.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFCI', 'POCE', '${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFCI', 'POCI', '${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFCI', 'POSE', '${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFCI', 'POSI', '${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFCT', 'POCE', '${DFILP}/${PCH}ESPT0000_IADPERIFCT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFCT', 'POCI', '${DFILP}/${PCH}ESPT0000_IADPERIFCT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFCT', 'POSE', '${DFILP}/${PCH}ESPT0000_IADPERIFCT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFCT', 'POSI', '${DFILP}/${PCH}ESPT0000_IADPERIFCT.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFR', 'POCE', '${DFILP}/${PCH}ESPT0000_IADPERIFR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFR', 'POCI', '${DFILP}/${PCH}ESPT0000_IADPERIFR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFR', 'POSE', '${DFILP}/${PCH}ESPT0000_IADPERIFR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IADPERIFR', 'POSI', '${DFILP}/${PCH}ESPT0000_IADPERIFR.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IBNR', 'POCE', '${DFILP}/${PCH}ESPD2000_IBNR_EBS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_IBNR', 'POSE', '${DFILP}/${PCH}ESPD2000_IBNR_EBS.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_LABOCY1', 'POCE', '${DFILP}/${PCH}ESPT0000_LABOCY1.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_LABOCY1', 'POCI', '${DFILP}/${PCH}ESPT0000_LABOCY1.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_LABOCY1', 'POSE', '${DFILP}/${PCH}ESPT0000_LABOCY1.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment )  VALUES ( 0, 'EST_LABOCY1', 'POSI', '${DFILP}/${PCH}ESPT0000_LABOCY1.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EPO_FTECLEDRSO', 'POCE', '${DFILP}/${PCH}ESPD3800_FTECLEDRSO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EPO_FTECLEDRSO', 'POCI', '${DFILP}/${PCH}ESPD3800_FTECLEDRSO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EPO_FTECLEDRSO', 'POSE', '${DFILP}/${PCH}ESPD3800_FTECLEDRSO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EPO_FTECLEDRSO', 'POSI', '${DFILP}/${PCH}ESPD3800_FTECLEDRSO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_CURGTA', 'EBS', '${DFILP}/${PCH}ESIX7000_CURGTA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_CURGTA', 'IFRS', '${DFILP}/${PCH}ESIX7000_CURGTA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_CURGTA', 'POCE', '${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_CURGTA', 'POCI', '${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_CURGTA', 'POSE', '${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_CURGTA', 'POSI', '${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLASIIGTAA', 'POCE', '${DFILP}/${PCH}ESPD3630_DLASIIGTAACO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLASIIGTAA', 'POSE', '${DFILP}/${PCH}ESPD3630_DLASIIGTAASO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLASIIGTAR', 'POCE', '${DFILP}/${PCH}ESPD3630_DLASIIGTARCO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLASIIGTAR', 'POSE', '${DFILP}/${PCH}ESPD3630_DLASIIGTARSO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLASIIGTR', 'POCE', '${DFILP}/${PCH}ESPD3700_DLASIIGTR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLASIIGTR', 'POSE', '${DFILP}/${PCH}ESPD3700_DLASIIGTR.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLCUMGTAAR', 'POCE', '${DFILI}/${PCH}ESPD3700_DLCUMGTAAR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLCUMGTAAR', 'POSE', '${DFILI}/${PCH}ESPD3700_DLCUMGTAAR.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLCUMGTAAR_IBNR_FUTCLAIMS', 'POCE', '${DFILP}/${PCH}ESPD3700_DLCUMGTAAR_IBNR_FUTCLAIMS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLCUMGTAAR_IBNR_FUTCLAIMS', 'POSE', '${DFILP}/${PCH}ESPD3700_DLCUMGTAAR_IBNR_FUTCLAIMS.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDGTAA', 'EBS', '${DFILP}/${PCH}ESID2000_DLDGTAA_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDGTAA', 'IFRS', '${DFILP}/${PCH}ESID2000_DLDGTAA_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDGTAA', 'POCE', '${DFILP}/${PCH}ESPD2000_DLDGTAASIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDGTAA', 'POSE', '${DFILP}/${PCH}ESPD2000_DLDGTAASIISO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDSIIGTAA', 'POCE', '${DFILP}/${PCH}ESPD3700_DLDSIIGTAACO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDSIIGTAA', 'POSE', '${DFILP}/${PCH}ESPD3700_DLDSIIGTAASO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDSIIGTAR', 'POCE', '${DFILP}/${PCH}ESPD3700_DLDSIIGTARCO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDSIIGTAR', 'POSE', '${DFILP}/${PCH}ESPD3700_DLDSIIGTARSO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDSIIGTR', 'EBS', '${DFILI}/${PCH}ESID3700_DLDSIIGTR_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDSIIGTR', 'IFRS', '${DFILI}/${PCH}ESID3700_DLDSIIGTR_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDSIIGTR', 'POCE', '${DFILP}/${PCH}ESPD3700_DLDSIIGTRSO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDSIIGTR', 'POCI', '${DFILP}/${PCH}ESPD3700_DLDSIIGTRSO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDSIIGTR', 'POSE', '${DFILP}/${PCH}ESPD3700_DLDSIIGTRSO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLDSIIGTR', 'POSI', '${DFILP}/${PCH}ESPD3700_DLDSIIGTRSO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLEIFTECLEDSIIEI', 'POCE', '${DFILP}/${PCH}ESPD3700_DLEIFTECLEDSIIEI.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLEIFTECLEDSIIEI', 'POSE', '${DFILP}/${PCH}ESPD3700_DLEIFTECLEDSIIEI.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLEIFTECLEDSIIEP', 'POCE', '${DFILP}/${PCH}ESPD3700_DLEIFTECLEDSIIEP.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLEIFTECLEDSIIEP', 'POSE', '${DFILP}/${PCH}ESPD3700_DLEIFTECLEDSIIEP.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLGTAUPUC', 'POCE', '${DFILP}/${PCH}ESID2220_DLGTAUPUC__.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLGTAUPUC', 'POCI', '${DFILP}/${PCH}ESID2220_DLGTAUPUC__.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLGTAUPUC', 'POSE', '${DFILP}/${PCH}ESID2220_DLGTAUPUC__.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLGTAUPUC', 'POSI', '${DFILP}/${PCH}ESID2220_DLGTAUPUC__.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREGTAR', 'EBS', '${DFILP}/${PCH}ESID2500_DLREGTAR_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREGTAR', 'IFRS', '${DFILP}/${PCH}ESID2500_DLREGTAR_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREGTAR', 'POCE', '${DFILP}/${PCH}ESPD2550_DLREGTARSIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREGTAR', 'POCI', '${DFILP}/${PCH}ESPD2550_DLREGTARSCO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREGTAR', 'POSE', '${DFILP}/${PCH}ESPD2550_DLREGTARSIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREGTAR', 'POSI', '${DFILP}/${PCH}ESPD2550_DLREGTARSO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREGTR', 'EBS', '${DFILP}/${PCH}ESPT0000_DLREGTR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREGTR', 'POCE', '${DFILP}/${PCH}ESPD2550_DLREGTRSIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREGTR', 'POCI', '${DFILP}/${PCH}ESPD2550_DLREGTRCO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREGTR', 'POSE', '${DFILP}/${PCH}ESPD2550_DLREGTRSIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREGTR', 'POSI', '${DFILP}/${PCH}ESPD2550_DLREGTRSO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTAR', 'EBS', '${DFILP}/${PCH}ESID2500_DLREMAJGTAR_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTAR', 'IFRS', '${DFILP}/${PCH}ESID2500_DLREMAJGTAR_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTAR', 'POCE', '${DFILP}/${PCH}ESPD2550_DLREMAJGTARSIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTAR', 'POCI', '${DFILP}/${PCH}ESPD2550_DLREMAJGTARCO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTAR', 'POSE', '${DFILP}/${PCH}ESPD2550_DLREMAJGTARSIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTAR', 'POSI', '${DFILP}/${PCH}ESPD2550_DLREMAJGTARSO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTR', 'EBS', '${DFILP}/${PCH}ESID2500_DLREMAJGTR_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTR', 'IFRS', '${DFILP}/${PCH}ESID2500_DLREMAJGTR_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTR', 'POCE', '${DFILP}/${PCH}ESPD2550_DLREMAJGTRSIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTR', 'POCI', '${DFILP}/${PCH}ESPD2550_DLREMAJGTRSO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTR', 'POSE', '${DFILP}/${PCH}ESPD2550_DLREMAJGTRSIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLREMAJGTR', 'POSI', '${DFILP}/${PCH}ESPD2550_DLREMAJGTRSO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLRGTAA', 'EBS', '${DFILI}/${PCH}ESID2050_DLRGTAA_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLRGTAA', 'IFRS', '${DFILI}/${PCH}ESID2050_DLRGTAA_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLRGTAA', 'POCE', '${DFILP}/${PCH}ESPD2550_DLRGTAASIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLRGTAA', 'POCI', '${DFILP}/${PCH}ESPD2550_DLRGTAACO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLRGTAA', 'POSE', '${DFILP}/${PCH}ESPD2550_DLRGTAASIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLRGTAA', 'POSI', '${DFILP}/${PCH}ESPD2550_DLRGTAASO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAA', 'POCE', '${DFILP}/${PCH}ESPD1800_DLSGTAASIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAA', 'POSE', '${DFILP}/${PCH}ESPD1800_DLSGTAASIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAA', 'POCI', '${DFILP}/${PCH}ESPD1800_DLSGTAACO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAA', 'POSI', '${DFILP}/${PCH}ESPD1800_DLSGTAASO.dat', NULL, NULL, '*', NULL, NULL )

-- modifs RC pas utilisé dans ESID3702A (induction en erreur)
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAASII', 'EBS', '${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat', NULL, NULL, '*', NULL, NULL )
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAASII', 'IFRS', '${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat', NULL, NULL, '*', NULL, NULL )
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAASII', 'POCE', '${DFILP}/${PCH}ESPD1800_DLSGTAASIICO.dat', NULL, NULL, '*', NULL, NULL )
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAASII', 'POCI', '${DFILP}/${PCH}ESPD1800_DLSGTAACO.dat', NULL, NULL, '*', NULL, NULL )
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAASII', 'POSE', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAR', 'POCE', '${DFILP}/${PCH}ESPD1800_DLSGTARSIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAR', 'POSE', '${DFILP}/${PCH}ESPD1800_DLSGTARSIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAR', 'POCI', '${DFILP}/${PCH}ESPD1800_DLSGTARCO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTAR', 'POSI', '${DFILP}/${PCH}ESPD1800_DLSGTARSO.dat', NULL, NULL, '*', NULL, NULL )

-- modifs RC pas utilisé dans ESID3702A (induction en erreur)
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTARSII', 'EBS', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTARSII', 'IFRS', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTARSII', 'POCE', '${DFILP}/${PCH}ESPD1800_DLSGTARSIICO.dat', NULL, NULL, '*', NULL, NULL )
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTARSII', 'POCI', '${DFILP}/${PCH}ESPD1800_DLSGTARSIICO.dat', NULL, NULL, '*', NULL, NULL )
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTARSII', 'POSE', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )
--INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTARSII', 'POSI', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTR', 'POCE', '${DFILP}/${PCH}ESPD1800_DLSGTRSIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTR', 'POCI', '${DFILP}/${PCH}ESPD1800_DLSGTRCO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTR', 'POSE', '${DFILP}/${PCH}ESPD1800_DLSGTRSIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_DLSGTR', 'POSI', '${DFILP}/${PCH}ESPD1800_DLSGTRSO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FBOPRSLNK', 'EBS', '${DFILI}/${PCH}ESCJ0060_FBOPRSLNK_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FBOPRSLNK', 'IFRS', '${DFILI}/${PCH}ESCJ0060_FBOPRSLNK_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FBOPRSLNK', 'POCE', '${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FBOPRSLNK', 'POCI', '${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FBOPRSLNK', 'POSE', '${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FBOPRSLNK', 'POSI', '${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPRSMAP', 'EBS', '${DFILI}/${PCH}ESCJ0060_FPRSMAP_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPRSMAP', 'IFRS', '${DFILI}/${PCH}ESCJ0060_FPRSMAP_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPRSMAP', 'POCE', '${DFILP}/${PCH}ESPT0000_FPRSMAP.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPRSMAP', 'POCI', '${DFILP}/${PCH}ESPT0000_FPRSMAP.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPRSMAP', 'POSE', '${DFILP}/${PCH}ESPT0000_FPRSMAP.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPRSMAP', 'POSI', '${DFILP}/${PCH}ESPT0000_FPRSMAP.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCTRFWH', 'EBS', '${DFILI}/${PCH}ESPD0060_FCTRFWH_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCTRFWH', 'IFRS', '${DFILI}/${PCH}ESPD0060_FCTRFWH_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCTRFWH', 'POCE', '${DFILP}/${PCH}ESPD0060_FCTRFWH.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCTRFWH', 'POCI', '${DFILP}/${PCH}ESPD0060_FCTRFWH.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCTRFWH', 'POSE', '${DFILP}/${PCH}ESPD0060_FCTRFWH.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCTRFWH', 'POSI', '${DFILP}/${PCH}ESPD0060_FCTRFWH.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERNFWH', 'EBS', '${DFILI}/${PCH}ESPD0060_FSEGPATTERNFWH_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERNFWH', 'IFRS', '${DFILI}/${PCH}ESPD0060_FSEGPATTERNFWH_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERNFWH', 'POCE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERNFWH.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERNFWH', 'POCI', '${DFILP}/${PCH}ESPD0060_FSEGPATTERNFWH.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERNFWH', 'POSE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERNFWH.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERNFWH', 'POSI', '${DFILP}/${PCH}ESPD0060_FSEGPATTERNFWH.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCLIENT', 'POCE', '${DFILP}/${PCH}ESPT0000_FCLIENT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCLIENT', 'POSE', '${DFILP}/${PCH}ESPT0000_FCLIENT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCTRGRO', 'POCE', '${DFILP}/${PCH}ESPT0000_FCTRGRO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCTRGRO', 'POSE', '${DFILP}/${PCH}ESPT0000_FCTRGRO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCTRGROLESII', 'POCE', '${DFILP}/${PCH}ESPT0000_FCTRGROLESII.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCTRGROLESII', 'POSE', '${DFILP}/${PCH}ESPT0000_FCTRGROLESII.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCURQUOT', 'EBS', '${DFILP}/${PCH}ESCJ0060_FCURQUOT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCURQUOT', 'IFRS', '${DFILP}/${PCH}ESCJ0060_FCURQUOT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCURQUOT', 'POCE', '${DFILP}/${PCH}ESPT0000_FCURQUOT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCURQUOT', 'POCI', '${DFILP}/${PCH}ESPT0000_FCURQUOT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCURQUOT', 'POSE', '${DFILP}/${PCH}ESPT0000_FCURQUOT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCURQUOT', 'POSI', '${DFILP}/${PCH}ESPT0000_FCURQUOT.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCURSII', 'POCE', '${DFILP}/${PCH}ESPT0000_FCURSII.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FCURSII', 'POSE', '${DFILP}/${PCH}ESPT0000_FCURSII.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FDETTRS', 'EBS', '${DFILP}/${PCH}ESCJ0060_FDETTRS_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FDETTRS', 'IFRS', '${DFILP}/${PCH}ESCJ0060_FDETTRS_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FDETTRS', 'POCE', '${DFILP}/${PCH}ESPT0000_FDETTRS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FDETTRS', 'POCI', '${DFILP}/${PCH}ESPT0000_FDETTRS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FDETTRS', 'POSE', '${DFILP}/${PCH}ESPT0000_FDETTRS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FDETTRS', 'POSI', '${DFILP}/${PCH}ESPT0000_FDETTRS.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FLIBEL2', 'POCE', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FLIBEL2', 'POCI', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FLIBEL2', 'POSE', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FLIBEL2', 'POSI', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPLATXCUM', 'POCE', '${DFILP}/${PCH}ESPT0000_FPLATXCUM.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPLATXCUM', 'POSE', '${DFILP}/${PCH}ESPT0000_FPLATXCUM.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPLATXCUMALL', 'POCE', '${DFILP}/${PCH}ESPT0000_FPLATXCUMALL.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPLATXCUMALL', 'POSE', '${DFILP}/${PCH}ESPT0000_FPLATXCUMALL.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPLC', 'EBS', '${DFILP}/${PCH}ESID2500_FPLC_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPLC', 'IFRS', '${DFILP}/${PCH}ESID2500_FPLC_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPLC', 'POCE', '${DFILP}/${PCH}ESPT0000_FPLC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPLC', 'POCI', '${DFILP}/${PCH}ESPT0000_FPLC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPLC', 'POSE', '${DFILP}/${PCH}ESPT0000_FPLC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FPLC', 'POSI', '${DFILP}/${PCH}ESPT0000_FPLC.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FRATINGRTO', 'POCE', '${DFILP}/${PCH}ESPT0000_FRATINGRTO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FRATINGRTO', 'POSE', '${DFILP}/${PCH}ESPT0000_FRATINGRTO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FRISKMSII', 'POCE', '${DFILP}/${PCH}ESPD0060_FRISKMSIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FRISKMSII', 'POSE', '${DFILP}/${PCH}ESPD0060_FRISKMSIISO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERN_BDT', 'POCE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_BDT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERN_BDT', 'POSE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_BDT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERN_CSF', 'POCE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERN_CSF', 'POSE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERN_DSC', 'POCE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERN_DSC', 'POSE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERN_ICR', 'POCE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_ICR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERN_ICR', 'POSE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_ICR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERN_INF', 'POCE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_INF.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSEGPATTERN_INF', 'POSE', '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_INF.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSSDACTR', 'EBS', '${DFILI}/${PCH}ESCJ0060_FSSDACTR_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSSDACTR', 'IFRS', '${DFILI}/${PCH}ESCJ0060_FSSDACTR_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSSDACTR', 'POCE', '${DFILP}/${PCH}ESPT0000_FSSDACTR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSSDACTR', 'POCI', '${DFILP}/${PCH}ESPT0000_FSSDACTR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSSDACTR', 'POSE', '${DFILP}/${PCH}ESPT0000_FSSDACTR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FSSDACTR', 'POSI', '${DFILP}/${PCH}ESPT0000_FSSDACTR.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDASII', 'EBS', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDASII', 'IFRS', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDASII', 'POCE', '${DFILP}/${PCH}ESPD3800_FTECLEDASIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDASII', 'POCI', '${DFILP}/${PCH}ESPD3800_FTECLEDASIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDASII', 'POSE', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDASII', 'POSI', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDASIISO', 'POCE', '${DFILP}/${PCH}ESPD3800_FTECLEDASIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDASIISO', 'POSE', '${DFILP}/empty.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDASO', 'POCE', '${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDASO', 'POSE', '${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDSII', 'POCE', '${DFILP}/${PCH}ESPD3700_FTECLEDSIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTECLEDSII', 'POSE', '${DFILP}/${PCH}ESPD3700_FTECLEDSIISO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTRSLNK', 'EBS', '${DFILI}/${PCH}ESCJ0060_FTRSLNK_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTRSLNK', 'IFRS', '${DFILI}/${PCH}ESCJ0060_FTRSLNK_*.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTRSLNK', 'POCE', '${DFILP}/${PCH}ESPT0000_FTRSLNK.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTRSLNK', 'POCI', '${DFILP}/${PCH}ESPT0000_FTRSLNK.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTRSLNK', 'POSE', '${DFILP}/${PCH}ESPT0000_FTRSLNK.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FTRSLNK', 'POSI', '${DFILP}/${PCH}ESPT0000_FTRSLNK.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FULAERAT', 'POCE', '${DFILP}/${PCH}ESPD0060_FULAERATCO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FULAERAT', 'POSE', '${DFILP}/${PCH}ESPD0060_FULAERATSO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FWHGTA', 'POCE', '${DFILP}/${PCH}ESPT0000_FWHGTA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FWHGTA', 'POSE', '${DFILP}/${PCH}ESPT0000_FWHGTA.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FWHGTR', 'POCE', '${DFILP}/${PCH}ESPT0000_FWHGTR.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_FWHGTR', 'POSE', '${DFILP}/${PCH}ESPT0000_FWHGTR.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_CASHFLOW', 'POCE', '${DFILP}/${PCH}ESPD3610_GTSII_CASHFLOW_SIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_CASHFLOW', 'POCI', '${DFILI}/${PCH}ESID2220_EST_GTSII_CASHFLOW_PO--_.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_CASHFLOW', 'POSE', '${DFILP}/${PCH}ESPD3610_GTSII_CASHFLOW_SIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_CASHFLOW', 'POSI', '${DFILI}/${PCH}ESID2220_EST_GTSII_CASHFLOW_PO--_.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_ESCOMPTE_CLM', 'POCE', '${DFILP}/${PCH}ESPD3700_GTSII_ESCOMPTE_CLM.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_ESCOMPTE_CLM', 'POSE', '${DFILP}/${PCH}ESPD3700_GTSII_ESCOMPTE_CLM.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_REMAINTOPAY_ULAE', 'POCE', '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_REMAINTOPAY_ULAE', 'POSE', '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_REMAINTOPAY_ULAE', 'POSI', '${DFILI}/${PCH}ESID2220_EST_GTSII_REMAINTOPAY_ULAE_PO--_.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_REMAINTOPAY_ULAEINF', 'POCE', '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_POCE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_REMAINTOPAY_ULAEINF', 'POCI', '${DFILI}/${PCH}ESID2220_EST_GTSII_REMAINTOPAY_ULAEINF_PO--_.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_REMAINTOPAY_ULAEINF', 'POSE', '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_POSE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_REMAINTOPAY_ULAEINF', 'POSI', '${DFILI}/${PCH}ESID2220_EST_GTSII_REMAINTOPAY_ULAEINF_PO--_.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_RISKMARGIN', 'POCE', '${DFILP}/${PCH}ESPD3700_GTSII_RISKMARGINCO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_GTSII_RISKMARGIN', 'POSE', '${DFILP}/${PCH}ESPD3700_GTSII_RISKMARGINSO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_IADPERICASE', 'EBS', '${DFILI}/${PCH}ESID0560_IADPERICASE_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_IADPERICASE', 'IFRS', '${DFILI}/${PCH}ESID0560_IADPERICASE_*.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_IADPERICASE', 'POCE', '${DFILP}/${PCH}ESPT0000_IADPERICASE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_IADPERICASE', 'POCI', '${DFILP}/${PCH}ESPT0000_IADPERICASE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_IADPERICASE', 'POSE', '${DFILP}/${PCH}ESPT0000_IADPERICASE.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_IADPERICASE', 'POSI', '${DFILP}/${PCH}ESPT0000_IADPERICASE.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_IGTAAF', 'POCE', '${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_IGTAAF', 'POSE', '${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_IRDPERICASE0', 'POCE', '${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES ( 0, 'EST_IRDPERICASE0', 'POSE', '${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat', NULL, NULL, '*', NULL, NULL )

INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASIISO','EBS','${DFILP}/${PCH}ESPD3800_FTECLEDASIISO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASIISO','IFRS','${DFILP}/${PCH}ESPD3800_FTECLEDASIISO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASIISO','POCE','${DFILP}/${PCH}ESPD3800_FTECLEDASIISO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASIISO','POCI','${DFILP}/${PCH}ESPD3800_FTECLEDASIISO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASIISO','POSE','${DFILP}/empty.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASIISO','POSI','${DFILP}/${PCH}ESPD3800_FTECLEDASIISO.dat')

INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASO','EBS','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASO','IFRS','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASO','POCE','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASO','POCI','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASO','POSE','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FTECLEDASO','POSI','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat')

INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_ARCSTATGTA','EBS','${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_ARCSTATGTA','IFRS','${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_ARCSTATGTA','POCE','${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_ARCSTATGTA','POCI','${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_ARCSTATGTA','POSE','${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_ARCSTATGTA','POSI','${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat')

INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLDGTAA_CUMULS_COUR','POSE','${DFILP}/${PCH}ESPD2000_DLDGTAASIISO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLDGTAA_CUMULS_PREC','POSE','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLDGTAA_CUMULS_PREC','POSI','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLDGTAA_CUMULS_COUR','POCE','${DFILP}/${PCH}ESPD2000_DLDGTAASIICO.dat')

INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLDGTAA_E_TRNCODEBS','EBS','${DFILI}/${PCH}ESID2000_DLDGTAA_E_TRNCODEBS_*.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLDGTAA_E_TRNCODEBS','IFRS','${DFILI}/${PCH}ESID2000_DLDGTAA_E_TRNCODEBS_*.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLDGTAA_E_TRNCODEBS','POCE','${DFILP}/${PCH}ESPD2000_DLDGTAASIICO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLDGTAA_E_TRNCODEBS','POCI','${DFILI}/${PCH}ESID2000_DLDGTAA_E_TRNCODEBS_*.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLDGTAA_E_TRNCODEBS','POSE','${DFILP}/${PCH}ESPD2000_DLDGTAASIISO.dat')

INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLGTAAPNAE','EBS','${DFILI}/${PCH}ESID2000_DLGTAAPNAE_*.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLGTAAPNAE','IFRS','${DFILI}/${PCH}ESID2000_DLGTAAPNAE_*.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLGTAAPNAE','POCE','${DFILP}/${PCH}ESPT0000_DLGTAAPNAE.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLGTAAPNAE','POCI','${DFILP}/${PCH}ESPT0000_DLGTAAPNAE.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLGTAAPNAE','POSE','${DFILP}/${PCH}ESPT0000_DLGTAAPNAE.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_DLGTAAPNAE','POSI','${DFILP}/${PCH}ESPT0000_DLGTAAPNAE.dat')

INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FCPLACC','EBS','${DFILP}/${PCH}ESID0560_FCPLACC_*.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FCPLACC','IFRS','${DFILP}/${PCH}ESID0560_FCPLACC_*.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FCPLACC','POCE','${DFILP}/${PCH}ESPT0000_FCPLACC.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FCPLACC','POCI','${DFILP}/${PCH}ESPT0000_FCPLACC.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FCPLACC','POSE','${DFILP}/${PCH}ESPT0000_FCPLACC.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FCPLACC','POSI','${DFILP}/${PCH}ESPT0000_FCPLACC.dat')

INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FSEGEST_SOLVENCY','EBS','${DFILP}/${PCH}ESPT0000_FSEGEST_SOLVENCY.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FSEGEST_SOLVENCY','IFRS','${DFILP}/${PCH}ESPT0000_FSEGEST_SOLVENCY.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FSEGEST_SOLVENCY','POCE','${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FSEGEST_SOLVENCY','POCI','${DFILP}/${PCH}ESPT0000_FSEGEST_SOLVENCY.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FSEGEST_SOLVENCY','POSE','${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FSEGEST_SOLVENCY','POSI','${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO.dat')

INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FUTURE_EBS','EBS','${DFILI}/${PCH}ESID2000_FUTURE_EBS_*.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FUTURE_EBS','IFRS','${DFILI}/${PCH}ESID2000_FUTURE_EBS_*.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FUTURE_EBS','POCE','${DFILP}/${PCH}ESPD2000_FUTURE_EBS.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FUTURE_EBS','POCI','${DFILP}/${PCH}ESPD2000_FUTURE_EBS.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FUTURE_EBS','POSE','${DFILP}/${PCH}ESPD2000_FUTURE_EBS.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_FUTURE_EBS','POSI','${DFILP}/${PCH}ESPD2000_FUTURE_EBS.dat')               
go



-- [001]
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_FUTURE_RETRO_EBS','POSE','${DFILP}/${PCH}ESPD2570_FUTURE_RETRO_EBS.dat',NULL, NULL, '*', NULL, NULL)
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_FUTURE_RETRO_EBS','POCE','${DFILP}/${PCH}ESPD2570_FUTURE_RETRO_EBS.dat',NULL, NULL, '*', NULL, NULL)
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_DLDGTR_E','POSE','${DFILP}/${PCH}ESPD2570_DLDGTRSIISO_E.dat',	NULL, NULL, '*', NULL, NULL)		
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_DLDGTR_E','POCE','${DFILP}/${PCH}ESPD2570_DLDGTRSIICO_E.dat',	NULL, NULL, '*', NULL, NULL)	
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_DLDGTR_CUMULS_PREC','POSE','${DFILP}/${PCH}ESPD2570_DLDGTR_CUMULS_PREC.dat',	NULL, NULL, '*', NULL, NULL)		
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_DLDGTR_CUMULS_PREC','POCE','${DFILP}/${PCH}ESPD2570_DLDGTR_CUMULS_PREC.dat',	NULL, NULL, '*', NULL, NULL)
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_DLDGTRSO','POSE','${DFILP}/${PCH}ESPD2570_DLDGTRSO.dat',	NULL, NULL, '*', NULL, NULL)		
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_DLDGTRCO','POCE','${DFILP}/${PCH}ESPD2570_DLDGTRCO.dat',	NULL, NULL, '*', NULL, NULL)	
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_FCURQUOT', 'POSE', '${DFILP}/${PCH}ESPT0000_FCURQUOT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_FCURQUOT', 'POCE', '${DFILP}/${PCH}ESPT0000_FCURQUOT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_FBOPRSLNK', 'POSE', '${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_FBOPRSLNK', 'POCE', '${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_FCLIENT', 'POSE', '${DFILP}/${PCH}ESPT0000_FCLIENT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_FCLIENT', 'POCE', '${DFILP}/${PCH}ESPT0000_FCLIENT.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_FCPLACC', 'POSE', '${DFILP}/${PCH}ESPT0000_FCPLACC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_FCPLACC', 'POCE', '${DFILP}/${PCH}ESPT0000_FCPLACC.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_IRDPERICASE0', 'POSE', '${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm ( version, fileVariable, ContextId, pattern, folder, fonction, chain, fileName, comment ) VALUES (0, 'EPO_IRDPERICASE0', 'POCE', '${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat', NULL, NULL, '*', NULL, NULL )
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_GTR','POSE','${DFILP}/${PCH}ESIX7000_GTR.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EST_GTR','POCE','${DFILP}/${PCH}ESIX7000_GTR.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FPLACEMT0','POSE','${DFILP}/${PCH}ESPT0000_FPLACEMT0.dat')
INSERT INTO BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) VALUES ('*',0,'EPO_FPLACEMT0','POCE','${DFILP}/${PCH}ESPT0000_FPLACEMT0.dat')
go


insert into  BEST..TIfrs17Perm (chain,version, fileVariable, ContextId,  pattern ) select chain,1, fileVariable, ContextId,  pattern from BEST..TIfrs17Perm
go
 
