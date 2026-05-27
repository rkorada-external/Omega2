use BEST
go 

/*==============================================================*/
/* Table: Segmentation 119 - 1 */
/* fix FAC_ADMIN_TYPE (20/03/2014) */
/*==============================================================*/

delete from TSEGTYPE where SGTTYP_NT = 19

delete from TSEGMENTATION where SGT_NT = 119
delete from  TSEGMT where SGT_NT = 119
delete from  TSEGMENTLVL where SGT_NT = 119
delete from  TSEGMENTEXCEPT where SGT_NT = 119
delete from  TSEGMENTRULE2TYPE where SGT_NT = 119
delete from  TSEGMENTRULE2CRI where SGT_NT = 119
delete from  TSEGMENTRULE where SGT_NT = 119
delete from  TSEG2ESB where SGT_NT = 119
delete from  TSEG2CTRSTS where SGT_NT = 119
delete from  TSEG2CTRCAT where SGT_NT = 119
delete from  TSEG2SECSTS where SGT_NT = 119
delete from  TSEG2SECACCSTS where SGT_NT = 119
go

INSERT INTO TSEGTYPE values (19,'Organisational Division','1','1','1',1, getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTATION values (119,1,19,'Organisational Division','Organisational Division',null,null,'3','3',0,1,0,0,4020,'DBEU','1','0',1,1,1,1,'1',null,null,getDate(),null,getDate(),'DBEU',getDate(),'DBEU',null)
go 


insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (0, 119,1,'lvl 0',null,getDate(),'DBEU',getDate(),'DBEU',null)
go


-------------------------
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 400, 119, 1, ' ', 1, 'LOB in (''30'',''31'')', '(StringUtils.equals(c.getLobCf(), "30") || StringUtils.equals(c.getLobCf(), "31"))', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 100, 119, 1, ' ', 2, 'CTR_TYPE = 2 AND Group_Division = ''100''', 'IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 650, 119, 1, ' ', 3, 'CTR_TYPE = 1 AND Group_Division = ''200'' AND SEG_LOB in (''3001'', ''3011'', ''3061'', ''3071'') AND FAC_ADMIN_TYPE = 1', 'IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200") && (StringUtils.equals(c.getSegLabel2Lvl0(), "3001") || StringUtils.equals(c.getSegLabel2Lvl0(), "3011") || StringUtils.equals(c.getSegLabel2Lvl0(), "3061") || StringUtils.equals(c.getSegLabel2Lvl0(), "3071")) && IntegerUtils.equals(c.getFacadmtypCt(), 1)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 275, 119, 1, ' ', 4, 'CTR_TYPE = 2 AND Group_Division = ''200''', 'IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 200, 119, 1, ' ', 5, 'CTR_TYPE = 1 AND Group_Division = ''200''', 'IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 600, 119, 1, ' ', 6, 'CTR_TYPE = 2 AND Group_Division = ''600''', 'IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 600, 119, 1, ' ', 7, 'CTR_TYPE = 1 AND Group_Division = ''600'' AND FAC_ADMIN_TYPE = 1', 'IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "600") && IntegerUtils.equals(c.getFacadmtypCt(), 1)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 250, 119, 1, ' ', 8, 'CTR_TYPE = 1 AND Group_Division = ''600'' AND SEG_LOB in (''1161'',''1241'',''1251'')', 'IntegerUtils.equals(c.getCtrtypCt(), 1) && IntegerUtils.equals(c.getSeg18Lvl0(), 600) && (IntegerUtils.equals(c.getSeg2Lvl0(), 31) || IntegerUtils.equals(c.getSeg2Lvl0(), 37) || IntegerUtils.equals(c.getSeg2Lvl0(), 39))', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 600, 119, 1, ' ', 9, 'CTR_TYPE = 1 AND Group_Division = ''600''', 'IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )


-- Update the Rule label with the label of the segment (TSEGMT.SGMT_LS)
UPDATE TSEGMENTRULE SET RULE_LS=SGMT_LS
FROM TSEGMENTRULE, TSEGMT
WHERE TSEGMT.SGT_NT = TSEGMENTRULE.SGT_NT AND TSEGMT.SGTVER_NT = TSEGMENTRULE.SGTVER_NT AND TSEGMENTRULE.SGMT_NF = TSEGMT.SGMT_NF
and TSEGMENTRULE.SGT_NT = 119
go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (100,119,1,'100','BS',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,100,119,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,100,119,1,18,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (200,119,1,'200','P&C Core',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,200,119,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,200,119,1,18,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (250,119,1,'250','P&C Non Core',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,250,119,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,250,119,1,2,getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,250,119,1,18,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (275,119,1,'275','P&C CFS',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,275,119,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,275,119,1,18,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (400,119,1,'400','LIFE',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,400,119,1,'LOB',getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (600,119,1,'600','Spec Core',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,600,119,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,600,119,1,18,getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,600,119,1,'FAC_ADMIN_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,600,119,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,600,119,1,18,getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,600,119,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,600,119,1,18,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (650,119,1,'650','Spec Non Core',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,650,119,1,'FAC_ADMIN_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,650,119,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,650,119,1,2,getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,650,119,1,18,getDate(),'DBEU')
go
