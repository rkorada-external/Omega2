use BEST
go 

/*==============================================================*/
/* Table: Segmentation 130 - 1 */
/*==============================================================*/

delete from TSEGTYPE where SGTTYP_NT = 30

delete from TSEGMENTATION where SGT_NT = 130
delete from  TSEGMT where SGT_NT = 130
delete from  TSEGMENTLVL where SGT_NT = 130
delete from  TSEGMENTEXCEPT where SGT_NT = 130
delete from  TSEGMENTRULE2TYPE where SGT_NT = 130
delete from  TSEGMENTRULE2CRI where SGT_NT = 130
delete from  TSEGMENTRULE where SGT_NT = 130
delete from  TSEG2ESB where SGT_NT = 130
delete from  TSEG2CTRSTS where SGT_NT = 130
delete from  TSEG2CTRCAT where SGT_NT = 130
delete from  TSEG2SECSTS where SGT_NT = 130
delete from  TSEG2SECACCSTS where SGT_NT = 130
go

INSERT INTO TSEGTYPE values (30,'IO Group','1','1','1',1, getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTATION values (130,1,30,'IO Group','IO Group',null,null,'3','3',0,1,0,0,4020,'DBEU','1','0',1,1,1,1,'1',null,null,getDate(),null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (0, 130,1,'lvl 0',null,getDate(),'DBEU',getDate(),'DBEU',null)

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,130,1,'1','Y',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,1,130,1,'',1,'CEDANT in (84600, 84599, 84603, 84602,56083)','(IntegerUtils.equals(c.getCedNf(), 84600) || IntegerUtils.equals(c.getCedNf(), 84599) || IntegerUtils.equals(c.getCedNf(), 84603) || IntegerUtils.equals(c.getCedNf(), 84602) || IntegerUtils.equals(c.getCedNf(), 56083))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,130,1,'CEDANT',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,1,130,1,'',3,'NOT(SUBSIDIARY in (10,17)) AND CLIENT_SCOR >= 1','!((IntegerUtils.equals(c.getSsdCf(), 10) || IntegerUtils.equals(c.getSsdCf(), 17)))  && IntegerUtils.superiorOrEquals(c.getClissdCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,1,130,1,'CLIENT_SCOR',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,1,130,1,'SUBSIDIARY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,1,130,1,'',4,'SUBSIDIARY = 10 AND (CEDANT in (12040,21115,22231,40237,50157,60018,70007,70130,80077,84001,30132,20688,22072,70204,70845,70210,30001,91190,91670,91126,91977,31081,21399,71713) OR (SUBLEDGER in (6,9) AND CEDANT in (71851,74916,75948,71249)))','IntegerUtils.equals(c.getSsdCf(), 10) && ((IntegerUtils.equals(c.getCedNf(), 12040) || IntegerUtils.equals(c.getCedNf(), 21115) || IntegerUtils.equals(c.getCedNf(), 22231) || IntegerUtils.equals(c.getCedNf(), 40237) || IntegerUtils.equals(c.getCedNf(), 50157) || IntegerUtils.equals(c.getCedNf(), 60018) || IntegerUtils.equals(c.getCedNf(), 70007) || IntegerUtils.equals(c.getCedNf(), 70130) || IntegerUtils.equals(c.getCedNf(), 80077) || IntegerUtils.equals(c.getCedNf(), 84001) || IntegerUtils.equals(c.getCedNf(), 30132) || IntegerUtils.equals(c.getCedNf(), 20688) || IntegerUtils.equals(c.getCedNf(), 22072) || IntegerUtils.equals(c.getCedNf(), 70204) || IntegerUtils.equals(c.getCedNf(), 70845) || IntegerUtils.equals(c.getCedNf(), 70210) || IntegerUtils.equals(c.getCedNf(), 30001) || IntegerUtils.equals(c.getCedNf(), 91190) || IntegerUtils.equals(c.getCedNf(), 91670) || IntegerUtils.equals(c.getCedNf(), 91126) || IntegerUtils.equals(c.getCedNf(), 91977) || IntegerUtils.equals(c.getCedNf(), 31081) || IntegerUtils.equals(c.getCedNf(), 21399) || IntegerUtils.equals(c.getCedNf(), 71713)) || ((IntegerUtils.equals(c.getAccesbCf(), 6) || IntegerUtils.equals(c.getAccesbCf(), 9)) && (IntegerUtils.equals(c.getCedNf(), 71851) || IntegerUtils.equals(c.getCedNf(), 74916) || IntegerUtils.equals(c.getCedNf(), 75948) || IntegerUtils.equals(c.getCedNf(), 71249))))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,1,130,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,1,130,1,'CEDANT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,1,130,1,'SUBSIDIARY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,1,130,1,'',5,'SUBSIDIARY=17 AND CLIENT_SCOR >= 1 AND (NOT(SUBLEDGER in (10,11,12,13)) or CEDANT <>31232)','IntegerUtils.equals(c.getSsdCf(), 17) && IntegerUtils.superiorOrEquals(c.getClissdCf(), 1) && (!((IntegerUtils.equals(c.getAccesbCf(), 10) || IntegerUtils.equals(c.getAccesbCf(), 11) || IntegerUtils.equals(c.getAccesbCf(), 12) || IntegerUtils.equals(c.getAccesbCf(), 13)))  || !IntegerUtils.equals(c.getCedNf(), 31232))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,1,130,1,'CLIENT_SCOR',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,1,130,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,1,130,1,'CEDANT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,1,130,1,'SUBSIDIARY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,1,130,1,'',6,'CONTRACT in (''10T003112'',''10T003113'',''10T005004'',''10T011012'',''10T010470'',''10T001009'',''10T000955'',''10T002338'',''10T004020'',''10ZA03145'')','(StringUtils.equals(c.getCtrNf(), "10T003112") || StringUtils.equals(c.getCtrNf(), "10T003113") || StringUtils.equals(c.getCtrNf(), "10T005004") || StringUtils.equals(c.getCtrNf(), "10T011012") || StringUtils.equals(c.getCtrNf(), "10T010470") || StringUtils.equals(c.getCtrNf(), "10T001009") || StringUtils.equals(c.getCtrNf(), "10T000955") || StringUtils.equals(c.getCtrNf(), "10T002338") || StringUtils.equals(c.getCtrNf(), "10T004020") || StringUtils.equals(c.getCtrNf(), "10ZA03145"))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,1,130,1,'CONTRACT',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,130,1,'0','N',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,2,130,1,'',2,'CEDANT in (84616,84617,30561,84835,84836,84837,84838)','(IntegerUtils.equals(c.getCedNf(), 84616) || IntegerUtils.equals(c.getCedNf(), 84617) || IntegerUtils.equals(c.getCedNf(), 30561) || IntegerUtils.equals(c.getCedNf(), 84835) || IntegerUtils.equals(c.getCedNf(), 84836) || IntegerUtils.equals(c.getCedNf(), 84837) || IntegerUtils.equals(c.getCedNf(), 84838))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,130,1,'CEDANT',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,2,130,1,'',7,'SUBSIDIARY>0','IntegerUtils.superior(c.getSsdCf(), 0)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,2,130,1,'SUBSIDIARY',getDate(),'DBEU')

go

-- Update the Rule label with the label of the segment (TSEGMT.SGMT_LS)
UPDATE TSEGMENTRULE SET RULE_LS=SGMT_LS
FROM TSEGMENTRULE, TSEGMT
WHERE TSEGMT.SGT_NT = TSEGMENTRULE.SGT_NT AND TSEGMT.SGTVER_NT = TSEGMENTRULE.SGTVER_NT AND TSEGMENTRULE.SGMT_NF = TSEGMT.SGMT_NF
and TSEGMENTRULE.SGT_NT = 130
go