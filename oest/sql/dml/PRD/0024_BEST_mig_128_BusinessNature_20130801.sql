use BEST
go 

/*==============================================================*/
/* Table: Segmentation 128 - 1 */
/*==============================================================*/

delete from TSEGTYPE where SGTTYP_NT = 28

delete from TSEGMENTATION where SGT_NT = 128
delete from  TSEGMT where SGT_NT = 128
delete from  TSEGMENTLVL where SGT_NT = 128
delete from  TSEGMENTEXCEPT where SGT_NT = 128
delete from  TSEGMENTRULE2TYPE where SGT_NT = 128
delete from  TSEGMENTRULE2CRI where SGT_NT = 128
delete from  TSEGMENTRULE where SGT_NT = 128
delete from  TSEG2ESB where SGT_NT = 128
delete from  TSEG2CTRSTS where SGT_NT = 128
delete from  TSEG2CTRCAT where SGT_NT = 128
delete from  TSEG2SECSTS where SGT_NT = 128
delete from  TSEG2SECACCSTS where SGT_NT = 128
go

INSERT INTO TSEGTYPE values (28,'Business Nature','1','1','1',1, getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTATION values (128,1,28,'Business Nature','Business Nature',null,null,'3','3',0,1,0,0,4020,'DBEU','1','0',1,1,1,1,'1',null,null,getDate(),null,getDate(),'DBEU',getDate(),'DBEU',null)
go 

/*==============================================================*/
/* Table: Segmentation 128 - 1 */
/*==============================================================*/

insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (0, 128,1,'lvl 0',null,getDate(),'DBEU',getDate(),'DBEU',null)

go

--------
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 1, 128, 1, ' ', 1, 'BUSINESS_TYPE=''1''', 'StringUtils.equals(c.getSegLabel27Lvl0(), "1")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 2, 128, 1, ' ', 2, 'BUSINESS_TYPE=''2''', 'StringUtils.equals(c.getSegLabel27Lvl0(), "2")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 3, 128, 1, ' ', 3, 'BUSINESS_TYPE=''3'' AND P_NP=''N'' AND WORKING_CAT=2', 'StringUtils.equals(c.getSegLabel27Lvl0(), "3") && StringUtils.equals(c.getNatB(), "N") && IntegerUtils.equals(c.getWrkcatCt(), 2)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 4, 128, 1, ' ', 4, 'BUSINESS_TYPE=''3'' AND P_NP=''N'' AND WORKING_CAT=1', 'StringUtils.equals(c.getSegLabel27Lvl0(), "3") && StringUtils.equals(c.getNatB(), "N") && IntegerUtils.equals(c.getWrkcatCt(), 1)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 5, 128, 1, ' ', 5, 'BUSINESS_TYPE=''3'' AND P_NP=''N''', 'StringUtils.equals(c.getSegLabel27Lvl0(), "3") && StringUtils.equals(c.getNatB(), "N")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 6, 128, 1, ' ', 6, 'BUSINESS_TYPE=''3'' AND P_NP=''P''', 'StringUtils.equals(c.getSegLabel27Lvl0(), "3") && StringUtils.equals(c.getNatB(), "P")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 7, 128, 1, ' ', 7, 'BUSINESS_TYPE=''4'' AND P_NP=''N'' AND WORKING_CAT=2', 'StringUtils.equals(c.getSegLabel27Lvl0(), "4") && StringUtils.equals(c.getNatB(), "N") && IntegerUtils.equals(c.getWrkcatCt(), 2)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 8, 128, 1, ' ', 8, 'BUSINESS_TYPE=''4'' AND P_NP=''N'' AND WORKING_CAT=1', 'StringUtils.equals(c.getSegLabel27Lvl0(), "4") && StringUtils.equals(c.getNatB(), "N") && IntegerUtils.equals(c.getWrkcatCt(), 1)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 9, 128, 1, ' ', 9, 'BUSINESS_TYPE=''4'' AND P_NP=''N''', 'StringUtils.equals(c.getSegLabel27Lvl0(), "4") && StringUtils.equals(c.getNatB(), "N")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 10, 128, 1, ' ', 10, 'BUSINESS_TYPE=''4'' AND P_NP=''P''', 'StringUtils.equals(c.getSegLabel27Lvl0(), "4") && StringUtils.equals(c.getNatB(), "P")', getDate(),'DBEU',getDate(),'DBEU',null )

---------

go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,128,1,'1','Facs BS',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,1,128,1,27,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,128,1,'2','Facs Specialties',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,2,128,1,27,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,128,1,'3','Life NP Cat',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,128,1,'WORKING_CAT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,128,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,3,128,1,27,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,128,1,'4','Life NP Work',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,128,1,'WORKING_CAT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,128,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,4,128,1,27,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,128,1,'5','Life NP undefin.',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,5,128,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,5,128,1,27,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,128,1,'6','Life Prop',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,6,128,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,6,128,1,27,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,128,1,'7','NP Cat',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,128,1,'WORKING_CAT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,128,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,7,128,1,27,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (8,128,1,'8','NP Work',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,8,128,1,'WORKING_CAT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,8,128,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,8,128,1,27,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (9,128,1,'9','NP undef',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,9,128,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,9,128,1,27,getDate(),'DBEU')
go
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (10,128,1,'10','Prop',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,128,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,10,128,1,27,getDate(),'DBEU')
go

-- Update the Rule label with the label of the segment (TSEGMT.SGMT_LS)
UPDATE TSEGMENTRULE SET RULE_LS=SGMT_LS
FROM TSEGMENTRULE, TSEGMT
WHERE TSEGMT.SGT_NT = TSEGMENTRULE.SGT_NT AND TSEGMT.SGTVER_NT = TSEGMENTRULE.SGTVER_NT AND TSEGMENTRULE.SGMT_NF = TSEGMT.SGMT_NF
and TSEGMENTRULE.SGT_NT = 128
go