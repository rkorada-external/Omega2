use BEST
go 

/*==============================================================*/
/* Table: Segmentation 129 - 1 */
/*==============================================================*/

delete from TSEGTYPE where SGTTYP_NT = 29

delete from TSEGMENTATION where SGT_NT = 129
delete from  TSEGMT where SGT_NT = 129
delete from  TSEGMENTLVL where SGT_NT = 129
delete from  TSEGMENTEXCEPT where SGT_NT = 129
delete from  TSEGMENTRULE2TYPE where SGT_NT = 129
delete from  TSEGMENTRULE2CRI where SGT_NT = 129
delete from  TSEGMENTRULE where SGT_NT = 129
delete from  TSEG2ESB where SGT_NT = 129
delete from  TSEG2CTRSTS where SGT_NT = 129
delete from  TSEG2CTRCAT where SGT_NT = 129
delete from  TSEG2SECSTS where SGT_NT = 129
delete from  TSEG2SECACCSTS where SGT_NT = 129
go

INSERT INTO TSEGTYPE values (29,'IO Sub','1','1','1',1, getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTATION values (129,1,29,'IO Sub','IO Sub',null,null,'3','3',0,1,0,0,4020,'DBEU','1','0',1,1,1,1,'1',null,null,getDate(),null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (0, 129,1,'lvl 0',null,getDate(),'DBEU',getDate(),'DBEU',null)
go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,129,1,'1','Y',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,1,129,1,'',1,'SUBSIDIARY = 10 AND ((SUBLEDGER in (1,6,9) AND CEDANT in (70007,70147,70130,71080)) OR (SUBLEDGER=1 AND CEDANT in (71851,74916,75948,71249)))','IntegerUtils.equals(c.getSsdCf(), 10) && (((IntegerUtils.equals(c.getAccesbCf(), 1) || IntegerUtils.equals(c.getAccesbCf(), 6) || IntegerUtils.equals(c.getAccesbCf(), 9)) && (IntegerUtils.equals(c.getCedNf(), 70007) || IntegerUtils.equals(c.getCedNf(), 70147) || IntegerUtils.equals(c.getCedNf(), 70130) || IntegerUtils.equals(c.getCedNf(), 71080))) || (IntegerUtils.equals(c.getAccesbCf(), 1) && (IntegerUtils.equals(c.getCedNf(), 71851) || IntegerUtils.equals(c.getCedNf(), 74916) || IntegerUtils.equals(c.getCedNf(), 75948) || IntegerUtils.equals(c.getCedNf(), 71249))))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,129,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,129,1,'CEDANT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,129,1,'SUBSIDIARY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,1,129,1,'',2,'(SUBSIDIARY = 14 and SUBLEDGER in (1,2,5) and CEDANT = 84001)  ','(IntegerUtils.equals(c.getSsdCf(), 14) && (IntegerUtils.equals(c.getAccesbCf(), 1) || IntegerUtils.equals(c.getAccesbCf(), 2) || IntegerUtils.equals(c.getAccesbCf(), 5)) && IntegerUtils.equals(c.getCedNf(), 84001))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,1,129,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,1,129,1,'CEDANT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,1,129,1,'SUBSIDIARY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,1,129,1,'',3,'(SUBSIDIARY = 14 and SUBLEDGER = 3 and CEDANT = 79833)','(IntegerUtils.equals(c.getSsdCf(), 14) && IntegerUtils.equals(c.getAccesbCf(), 3) && IntegerUtils.equals(c.getCedNf(), 79833))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,1,129,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,1,129,1,'CEDANT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,1,129,1,'SUBSIDIARY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,1,129,1,'',4,'(SUBSIDIARY = 14 and SUBLEDGER = 4 and CEDANT = 84406)','(IntegerUtils.equals(c.getSsdCf(), 14) && IntegerUtils.equals(c.getAccesbCf(), 4) && IntegerUtils.equals(c.getCedNf(), 84406))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,1,129,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,1,129,1,'CEDANT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,1,129,1,'SUBSIDIARY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,1,129,1,'',5,'(SUBSIDIARY = 14 and SUBLEDGER = 6 and CEDANT = 84553)','(IntegerUtils.equals(c.getSsdCf(), 14) && IntegerUtils.equals(c.getAccesbCf(), 6) && IntegerUtils.equals(c.getCedNf(), 84553))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,1,129,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,1,129,1,'CEDANT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,1,129,1,'SUBSIDIARY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,1,129,1,'',6,'SUBSIDIARY in (2,3) AND CLIENT_SCOR in (2,3) and (NOT (CEDANT in (31242,28212)) OR SUBLEDGER<>1)','(IntegerUtils.equals(c.getSsdCf(), 2) || IntegerUtils.equals(c.getSsdCf(), 3)) && (IntegerUtils.equals(c.getClissdCf(), 2) || IntegerUtils.equals(c.getClissdCf(), 3)) && (!((IntegerUtils.equals(c.getCedNf(), 31242) || IntegerUtils.equals(c.getCedNf(), 28212)))  || !IntegerUtils.equals(c.getAccesbCf(), 1))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,1,129,1,'CLIENT_SCOR',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,1,129,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,1,129,1,'CEDANT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,1,129,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,129,1,'0','N',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,7,129,1,'',7,'SUBSIDIARY>0','IntegerUtils.superior(c.getSsdCf(), 0)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,129,1,'SUBSIDIARY',getDate(),'DBEU')

go
-- Update the Rule label with the label of the segment (TSEGMT.SGMT_LS)
UPDATE TSEGMENTRULE SET RULE_LS=SGMT_LS
FROM TSEGMENTRULE, TSEGMT
WHERE TSEGMT.SGT_NT = TSEGMENTRULE.SGT_NT AND TSEGMT.SGTVER_NT = TSEGMENTRULE.SGTVER_NT AND TSEGMENTRULE.SGMT_NF = TSEGMT.SGMT_NF
and TSEGMENTRULE.SGT_NT = 129
go