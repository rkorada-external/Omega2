use BEST
go 

/*==============================================================*/
/* Table: Segmentation 126 - 1 */
/*==============================================================*/

delete from TSEGTYPE where SGTTYP_NT = 26

delete from TSEGMENTATION where SGT_NT = 126
delete from  TSEGMT where SGT_NT = 126
delete from  TSEGMENTLVL where SGT_NT = 126
delete from  TSEGMENTEXCEPT where SGT_NT = 126
delete from  TSEGMENTRULE2TYPE where SGT_NT = 126
delete from  TSEGMENTRULE2CRI where SGT_NT = 126
delete from  TSEGMENTRULE where SGT_NT = 126
delete from  TSEG2ESB where SGT_NT = 126
delete from  TSEG2CTRSTS where SGT_NT = 126
delete from  TSEG2CTRCAT where SGT_NT = 126
delete from  TSEG2SECSTS where SGT_NT = 126
delete from  TSEG2SECACCSTS where SGT_NT = 126
go

INSERT INTO TSEGTYPE values (26,'Type of reinsurance','1','1','1',1, getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTATION values (126,1,26,'Type of reinsurance','Type of reinsurance',null,null,'3','3',0,1,0,0,4020,'DBEU','1','0',1,1,1,1,'1',null,null,getDate(),null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (0, 126,1,'lvl 0',null,getDate(),'DBEU',getDate(),'DBEU',null)
go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,126,1,'1','Direct Insurance',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,1,126,1,'',1,'RI_TYPE = 1','IntegerUtils.equals(c.getReitypCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,126,1,'RI_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,126,1,'2','Reinsurance',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,2,126,1,'',2,'RI_TYPE in (2,3,4,5,7,12)','(IntegerUtils.equals(c.getReitypCf(), 2) || IntegerUtils.equals(c.getReitypCf(), 3) || IntegerUtils.equals(c.getReitypCf(), 4) || IntegerUtils.equals(c.getReitypCf(), 5) || IntegerUtils.equals(c.getReitypCf(), 7) || IntegerUtils.equals(c.getReitypCf(), 12))',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,126,1,'RI_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,126,1,'3','Non Traditional',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,3,126,1,'',3,'RI_TYPE = 6','IntegerUtils.equals(c.getReitypCf(), 6)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,126,1,'RI_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,126,1,'4','Fronted Contract',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,4,126,1,'',4,'RI_TYPE = 8','IntegerUtils.equals(c.getReitypCf(), 8)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,126,1,'RI_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,126,1,'5','JU Direct',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,5,126,1,'',5,'RI_TYPE = 9','IntegerUtils.equals(c.getReitypCf(), 9)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,5,126,1,'RI_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,126,1,'6','SRT Retro',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,6,126,1,'',6,'RI_TYPE = 15','IntegerUtils.equals(c.getReitypCf(), 15)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,6,126,1,'RI_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,126,1,'7','SRT Structured QS',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,7,126,1,'',7,'RI_TYPE = 16','IntegerUtils.equals(c.getReitypCf(), 16)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,126,1,'RI_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (8,126,1,'8','SRT Agg XS/SL',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,8,126,1,'',8,'RI_TYPE = 17','IntegerUtils.equals(c.getReitypCf(), 17)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,8,126,1,'RI_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (9,126,1,'9','SRT Other',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,9,126,1,'',9,'RI_TYPE = 18','IntegerUtils.equals(c.getReitypCf(), 18)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,9,126,1,'RI_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (10,126,1,'10','ARF',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,10,126,1,'',10,'RI_TYPE = 19','IntegerUtils.equals(c.getReitypCf(), 19)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,126,1,'RI_TYPE',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (11,126,1,'20','JU Fronting Fac',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,11,126,1,'',11,'RI_TYPE = 20','IntegerUtils.equals(c.getReitypCf(), 20)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,11,126,1,'RI_TYPE',getDate(),'DBEU')

go


-- Update the Rule label with the label of the segment (TSEGMT.SGMT_LS)
UPDATE TSEGMENTRULE SET RULE_LS=SGMT_LS
FROM TSEGMENTRULE, TSEGMT
WHERE TSEGMT.SGT_NT = TSEGMENTRULE.SGT_NT AND TSEGMT.SGTVER_NT = TSEGMENTRULE.SGTVER_NT AND TSEGMENTRULE.SGMT_NF = TSEGMT.SGMT_NF
and TSEGMENTRULE.SGT_NT = 126
go