use BREF

go
set nocount on

-- print 'insert bref..tpcstype and bref..tpcstypel'

-- Creating Process type data for the Claims Platform
-- Delete from bref..tpcstype where PCSTYP_CF = '370'
-- Delete from bref..tpcstypel where PCSTYP_CF = '370'
-- 
-- insert bref..tpcstype(PCSTYP_CF, BPMTYP_CF, FUNCDMN_CF, OBJTYP_CF, CREUSR_CF, CRE_D, LSTUPDUSR_CF, LSTUPD_D) values('370', '1', 'EST','IBNR','dbo',getdate(),'dbo',getdate())
-- 
-- insert bref..tpcstypel(PCSTYP_CF, LAG_CF, PCSTYP_LS, PCSTYP_LM, CREUSR_CF, CRE_D, LSTUPDUSR_CF, LSTUPD_D) values('370','E','F. IBNR','FORCE IBNR','dbo',getdate(),'dbo',getdate()) 
-- insert bref..tpcstypel(PCSTYP_CF, LAG_CF, PCSTYP_LS, PCSTYP_LM, CREUSR_CF, CRE_D, LSTUPDUSR_CF, LSTUPD_D) values('370','F','F. IBNR','FORCE IBNR','dbo',getdate(),'dbo',getdate()) 
-- insert bref..tpcstypel(PCSTYP_CF, LAG_CF, PCSTYP_LS, PCSTYP_LM, CREUSR_CF, CRE_D, LSTUPDUSR_CF, LSTUPD_D) values('370','G','F. IBNR','FORCE IBNR','dbo',getdate(),'dbo',getdate()) 
-- insert bref..tpcstypel(PCSTYP_CF, LAG_CF, PCSTYP_LS, PCSTYP_LM, CREUSR_CF, CRE_D, LSTUPDUSR_CF, LSTUPD_D) values('370','S','F. IBNR','FORCE IBNR','dbo',getdate(),'dbo',getdate()) 
-- insert bref..tpcstypel(PCSTYP_CF, LAG_CF, PCSTYP_LS, PCSTYP_LM, CREUSR_CF, CRE_D, LSTUPDUSR_CF, LSTUPD_D) values('370','I','F. IBNR','FORCE IBNR','dbo',getdate(),'dbo',getdate()) 
	

-- Delete from bref..TNOTIFTYPE WHERE  PCSTYPE_CF = '370'
Delete from bref..TNOTIFTMPLT Where NOTIFTYP_NT IN (372)

print 'insert bref..TNOTIFTYPE Where NOTIFTYP_NT = 372'	
INSERT INTO bref..TNOTIFTYPE ( NOTIFTYP_NT, PCSTYPE_CF, NOTNAT_CT, NOTSTY_CT, PROCMOD_CT, EXTRESP_B, RESPMETH_CT, EXTINCPY_B, INCPYMETH_CT, REQCMT_B, TGTSCRINT_LM, TGTSCREXT_LL, EXTDUEDATE_B, ACTDUEDELTA_NB, EXTPRIORITY_B, ACTPRIORITY_CT, REQATTACH_B, THRHLDCTL_B, THRHLDTYP_NT, THRHLDLVL_NT, CREUSR_CF, CRE_D, LSTUPDUSR_CF, LSTUPD_D, ESCDUEDELTA_NB ) 
	VALUES ( 372, '370', 'FOI', '5', '1', 0, null, 0, null, 0, '','SCR-EST-PAC-34885', 0, NULL, 0, '2', 0, 0, 0, 0, suser_name(), getDate(), suser_name(), getDate(), NULL)		 
print 'insert bref..TNOTIFTMPLT Where NOTIFTYP_NT = 372'		 
insert BREF..TNOTIFTMPLT ( NOTIFTYP_NT,LAG_CF,SUBJECT_LM,CONTENT_LL,CREUSR_CF ,CRE_D,LSTUPDUSR_CF,LSTUPD_D ) values (372,'E','EBS-IBNR forced ','Dear all,<br/><br/>Please, be informed that “<br/><br/>IBNR has been forced for %s-%s-%s with this comment: %s”<br/><br/>Regards,',suser_name(),getDate(),suser_name(),getDate()) 
insert BREF..TNOTIFTMPLT ( NOTIFTYP_NT,LAG_CF,SUBJECT_LM,CONTENT_LL,CREUSR_CF ,CRE_D,LSTUPDUSR_CF,LSTUPD_D ) values (372,'F','EBS-IBNR forcé ','Bonjour,<br/><br/>Pour information "<br/><br/>IBNR a été forcé pour %s-%s-%s avec le commentaire: %s”.<br/><br/>Merci',suser_name(),getDate(),suser_name(),getDate()) 
insert BREF..TNOTIFTMPLT ( NOTIFTYP_NT,LAG_CF,SUBJECT_LM,CONTENT_LL,CREUSR_CF ,CRE_D,LSTUPDUSR_CF,LSTUPD_D ) values (372,'G','EBS-IBNR forced ','Dear all,<br/><br/>Please, be informed that “<br/><br/>IBNR has been forced for %s-%s-%s with this comment: %s”<br/><br/>Regards,',suser_name(),getDate(),suser_name(),getDate()) 
insert BREF..TNOTIFTMPLT ( NOTIFTYP_NT,LAG_CF,SUBJECT_LM,CONTENT_LL,CREUSR_CF ,CRE_D,LSTUPDUSR_CF,LSTUPD_D ) values (372,'I','EBS-IBNR forcé ','Bonjour,<br/><br/>Pour information "<br/><br/>IBNR a été forcé pour %s-%s-%s avec le commentaire: %s”.<br/><br/>Merci',suser_name(),getDate(),suser_name(),getDate()) 
insert BREF..TNOTIFTMPLT ( NOTIFTYP_NT,LAG_CF,SUBJECT_LM,CONTENT_LL,CREUSR_CF ,CRE_D,LSTUPDUSR_CF,LSTUPD_D ) values (372,'S','EBS-IBNR forcé ','Bonjour,<br/><br/>Pour information "<br/><br/>IBNR a été forcé pour %s-%s-%s avec le commentaire: %s”.<br/><br/>Merci',suser_name(),getDate(),suser_name(),getDate()) 



---------------------------------
/*
Insertion Completed
*/
print 'Process Completed'
set nocount off
go		