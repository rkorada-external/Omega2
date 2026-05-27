use BEST
go 

/*==============================================================*/
/* Table: Segmentation 127 - 1 */
/* fix FAC_ADMIN_TYPE (20/03/2014) */
/*==============================================================*/

delete from TSEGTYPE where SGTTYP_NT = 27

delete from TSEGMENTATION where SGT_NT = 127
delete from  TSEGMT where SGT_NT = 127
delete from  TSEGMENTLVL where SGT_NT = 127
delete from  TSEGMENTEXCEPT where SGT_NT = 127
delete from  TSEGMENTRULE2TYPE where SGT_NT = 127
delete from  TSEGMENTRULE2CRI where SGT_NT = 127
delete from  TSEGMENTRULE where SGT_NT = 127
delete from  TSEG2ESB where SGT_NT = 127
delete from  TSEG2CTRSTS where SGT_NT = 127
delete from  TSEG2CTRCAT where SGT_NT = 127
delete from  TSEG2SECSTS where SGT_NT = 127
delete from  TSEG2SECACCSTS where SGT_NT = 127
go

INSERT INTO TSEGTYPE values (27,'Business Type','1','1','1',1, getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTATION values (127,1,27,'Business Type','Business Type',null,null,'3','3',0,1,0,0,4020,'DBEU','1','0',1,1,1,1,'1',null,null,getDate(),null,getDate(),'DBEU',getDate(),'DBEU',null)
go 

insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (0, 127,1,'lvl 0',null,getDate(),'DBEU',getDate(),'DBEU',null)
go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,127,1,'1','Facs BS',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)


INSERT INTO TSEGMENTRULE ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp ) VALUES ( 1, 1, 127, 1, '1', 1, 'CTR_TYPE=2 AND FAC_ADMIN_TYPE=0', 'IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacadmtypCt(), 0)',getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTRULE ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp ) VALUES ( 1, 2, 127, 1, '2', 2, 'CTR_TYPE=2 AND FAC_ADMIN_TYPE=1', 'IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacadmtypCt(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
go

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,127,1,'FAC_ADMIN_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,127,1,'CTR_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,127,1,'2','Facs Specialties',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,127,1,'FAC_ADMIN_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,127,1,'CTR_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,127,1,'3','Life Treaties',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,3,127,1,'',3,'CTR_TYPE=1 AND LOB in (''30'',''31'')','IntegerUtils.equals(c.getCtrtypCt(), 1) && (StringUtils.equals(c.getLobCf(), "30") || StringUtils.equals(c.getLobCf(), "31"))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,127,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,127,1,'LOB',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,127,1,'4','P&C Treaties',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,4,127,1,'',4,'CTR_TYPE=1 AND NOT(LOB in (''30'',''31''))','IntegerUtils.equals(c.getCtrtypCt(), 1) && !((StringUtils.equals(c.getLobCf(), "30") || StringUtils.equals(c.getLobCf(), "31"))) ',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,127,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,127,1,'LOB',getDate(),'DBEU')

go

-- Update the Rule label with the label of the segment (TSEGMT.SGMT_LS)
UPDATE TSEGMENTRULE SET RULE_LS=SGMT_LS
FROM TSEGMENTRULE, TSEGMT
WHERE TSEGMT.SGT_NT = TSEGMENTRULE.SGT_NT AND TSEGMT.SGTVER_NT = TSEGMENTRULE.SGTVER_NT AND TSEGMENTRULE.SGMT_NF = TSEGMT.SGMT_NF
and TSEGMENTRULE.SGT_NT = 127
go