use BEST
go 

/*==============================================================*/
/* Table: Segmentation 118 - 1 */
/*==============================================================*/

delete from TSEGTYPE where SGTTYP_NT = 18

delete from TSEGMENTATION where SGT_NT = 118
delete from  TSEGMT where SGT_NT = 118
delete from  TSEGMENTLVL where SGT_NT = 118
delete from  TSEGMENTEXCEPT where SGT_NT = 118
delete from  TSEGMENTRULE2TYPE where SGT_NT = 118
delete from  TSEGMENTRULE2CRI where SGT_NT = 118
delete from  TSEGMENTRULE where SGT_NT = 118
delete from  TSEG2ESB where SGT_NT = 118
delete from  TSEG2CTRSTS where SGT_NT = 118
delete from  TSEG2CTRCAT where SGT_NT = 118
delete from  TSEG2SECSTS where SGT_NT = 118
delete from  TSEG2SECACCSTS where SGT_NT = 118
go

INSERT INTO TSEGTYPE values (18,'Group Division','1','1','1',1, getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTATION values (118,1,18,'Group Division','Group Division',null,null,'3','3',0,1,0,0,4020,'DBEU','1','0',1,1,1,1,'1',null,null,getDate(),null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (0, 118,1,'lvl 0',null,getDate(),'DBEU',getDate(),'DBEU',null)
go 

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (100,118,1,'100','BS',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,100,118,1,'',14,'CTR_TYPE = 2','IntegerUtils.equals(c.getCtrtypCt(), 2)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,100,118,1,'CTR_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (200,118,1,'200','P&C',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,200,118,1,'',4,'SUBSIDIARY = 13','IntegerUtils.equals(c.getSsdCf(), 13)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,200,118,1,'SUBSIDIARY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,200,118,1,'',13,'CTR_TYPE = 2 AND LOB in (''01'', ''03'', ''07'', ''12'', ''20'', ''22'') AND FAC_SECTOR in (695,999)','IntegerUtils.equals(c.getCtrtypCt(), 2) && (StringUtils.equals(c.getLobCf(), "01") || StringUtils.equals(c.getLobCf(), "03") || StringUtils.equals(c.getLobCf(), "07") || StringUtils.equals(c.getLobCf(), "12") || StringUtils.equals(c.getLobCf(), "20") || StringUtils.equals(c.getLobCf(), "22")) && (IntegerUtils.equals(c.getFacactsctCt(), 695) || IntegerUtils.equals(c.getFacactsctCt(), 999))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,200,118,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,200,118,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,200,118,1,'FAC_SECTOR',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,200,118,1,'',15,'CTR_TYPE = 1','IntegerUtils.equals(c.getCtrtypCt(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,200,118,1,'CTR_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (400,118,1,'400','LIFE',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,400,118,1,'',1,'LOB in (''30'',''31'')','(StringUtils.equals(c.getLobCf(), "30") || StringUtils.equals(c.getLobCf(), "31"))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,400,118,1,'LOB',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (600,118,1,'600','Specialties',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,600,118,1,'',2,'CTR_TYPE = 1 AND RI_TYPE in (15,16,17,18)','IntegerUtils.equals(c.getCtrtypCt(), 1) && (IntegerUtils.equals(c.getReitypCf(), 15) || IntegerUtils.equals(c.getReitypCf(), 16) || IntegerUtils.equals(c.getReitypCf(), 17) || IntegerUtils.equals(c.getReitypCf(), 18))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,600,118,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,600,118,1,'RI_TYPE',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,600,118,1,'',3,'CTR_QUALIFIER3 in (10,11,12,13,17)','(IntegerUtils.equals(c.getCtrqua3Cf(), 10) || IntegerUtils.equals(c.getCtrqua3Cf(), 11) || IntegerUtils.equals(c.getCtrqua3Cf(), 12) || IntegerUtils.equals(c.getCtrqua3Cf(), 13) || IntegerUtils.equals(c.getCtrqua3Cf(), 17))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,600,118,1,'CTR_QUALIFIER3',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,600,118,1,'',5,'CTR_TYPE = 1 AND LOB =  ''02''','IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getLobCf(), "02")',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,600,118,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,600,118,1,'LOB',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,600,118,1,'',6,'CTR_TYPE = 2 AND LOB =  ''02'' AND FAC_SECTOR in (695,698)','IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getLobCf(), "02") && (IntegerUtils.equals(c.getFacactsctCt(), 695) || IntegerUtils.equals(c.getFacactsctCt(), 698))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,600,118,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,600,118,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,600,118,1,'FAC_SECTOR',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,600,118,1,'',7,'CTR_TYPE = 2 AND LOB =  ''03'' AND FAC_SECTOR = 698','IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getLobCf(), "03") && IntegerUtils.equals(c.getFacactsctCt(), 698)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,600,118,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,600,118,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,600,118,1,'FAC_SECTOR',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,600,118,1,'',8,'CTR_TYPE = 1 AND LOB =  ''08''','IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getLobCf(), "08")',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,600,118,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,600,118,1,'LOB',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,600,118,1,'',9,'CTR_TYPE = 2 AND LOB =  ''08'' AND TOP<> ''275''','IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getLobCf(), "08") && !StringUtils.equals(c.getTopCf(), "275")',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,600,118,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,600,118,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,600,118,1,'LOB',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (8,600,118,1,'',10,'CTR_TYPE = 1 AND LOB =  ''09''','IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getLobCf(), "09")',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,600,118,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,600,118,1,'LOB',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (9,600,118,1,'',11,'CTR_TYPE = 2 AND LOB =  ''20'' AND TOP =  ''535'' AND SUBSIDIARY = 1','IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getLobCf(), "20") && StringUtils.equals(c.getTopCf(), "535") && IntegerUtils.equals(c.getSsdCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,600,118,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,600,118,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,600,118,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,600,118,1,'SUBSIDIARY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (10,600,118,1,'',12,'LOB in (''04'',''05'',''06'',''10'',''11'',''15'')','(StringUtils.equals(c.getLobCf(), "04") || StringUtils.equals(c.getLobCf(), "05") || StringUtils.equals(c.getLobCf(), "06") || StringUtils.equals(c.getLobCf(), "10") || StringUtils.equals(c.getLobCf(), "11") || StringUtils.equals(c.getLobCf(), "15"))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,600,118,1,'LOB',getDate(),'DBEU')

go

-- Update the Rule label with the label of the segment (TSEGMT.SGMT_LS)
UPDATE TSEGMENTRULE SET RULE_LS=SGMT_LS
FROM TSEGMENTRULE, TSEGMT
WHERE TSEGMT.SGT_NT = TSEGMENTRULE.SGT_NT AND TSEGMT.SGTVER_NT = TSEGMENTRULE.SGTVER_NT AND TSEGMENTRULE.SGMT_NF = TSEGMT.SGMT_NF
and TSEGMENTRULE.SGT_NT = 118
go