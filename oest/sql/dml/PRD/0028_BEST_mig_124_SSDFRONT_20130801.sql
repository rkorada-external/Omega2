use BEST
go 

/*==============================================================*/
/* Table: Segmentation 124 - 1 */
/*==============================================================*/

delete from TSEGTYPE where SGTTYP_NT = 24

delete from TSEGMENTATION where SGT_NT = 124
delete from  TSEGMT where SGT_NT = 124
delete from  TSEGMENTLVL where SGT_NT = 124
delete from  TSEGMENTEXCEPT where SGT_NT = 124
delete from  TSEGMENTRULE2TYPE where SGT_NT = 124
delete from  TSEGMENTRULE2CRI where SGT_NT = 124
delete from  TSEGMENTRULE where SGT_NT = 124
delete from  TSEG2ESB where SGT_NT = 124
delete from  TSEG2CTRSTS where SGT_NT = 124
delete from  TSEG2CTRCAT where SGT_NT = 124
delete from  TSEG2SECSTS where SGT_NT = 124
delete from  TSEG2SECACCSTS where SGT_NT = 124
go

INSERT INTO TSEGTYPE values (24,'SSDFRONT','1','1','1',1, getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTATION values (124,1,24,'SSDFRONT','SSDFRONT',null,null,'3','3',0,1,0,0,4020,'DBEU','1','0',1,1,1,1,'1',null,null,getDate(),null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (0, 124,1,'lvl 0',null,getDate(),'DBEU',getDate(),'DBEU',null)
go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,124,1,'1','UK Direct by Paris',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,1,124,1,'',1,'RI_TYPE in (9,20) and SUBSIDIARY=1 AND CTR_TYPE=2 and UW_PFT_ORIGIN=2','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 1) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 2)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,124,1,'2','JU UK with US',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,2,124,1,'',2,'RI_TYPE in (9,20) and SUBSIDIARY=1 AND CTR_TYPE=2 and UW_PFT_ORIGIN=10','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 1) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 10)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,124,1,'3','JU UK with Canada',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,3,124,1,'',3,'RI_TYPE in (9,20) and SUBSIDIARY=1 AND CTR_TYPE=2 and UW_PFT_ORIGIN=11','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 1) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 11)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,124,1,'4','JU UK with Asia Pacific',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,4,124,1,'',4,'RI_TYPE in (9,20) and SUBSIDIARY=1 AND CTR_TYPE=2 and UW_PFT_ORIGIN=20','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 1) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 20)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,124,1,'5','JU UK with Switzerland',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,5,124,1,'',5,'RI_TYPE in (9,20) and SUBSIDIARY=1 AND CTR_TYPE=2 and UW_PFT_ORIGIN=17','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 1) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 17)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,5,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,5,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,5,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,5,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,124,1,'6','JU Brazil with Paris',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,6,124,1,'',6,'RI_TYPE in (9,20) and SUBSIDIARY=10 AND CTR_TYPE=2 and UW_PFT_ORIGIN=2 and UW_UNIT=4563','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 2) && IntegerUtils.equals(c.getUwgrpCf(), 4563)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,6,124,1,'UW_UNIT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,6,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,6,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,6,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,6,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,124,1,'7','JU Brazil with Zurich',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,7,124,1,'',7,'RI_TYPE in (9,20) and SUBSIDIARY=10 AND CTR_TYPE=2 and UW_PFT_ORIGIN=17 and UW_UNIT=4563','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 17) && IntegerUtils.equals(c.getUwgrpCf(), 4563)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,124,1,'UW_UNIT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (8,124,1,'8','JU Brazil with Asia Pacific',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,8,124,1,'',8,'RI_TYPE in (9,20) and SUBSIDIARY=10 AND CTR_TYPE=2 and UW_PFT_ORIGIN=20 and UW_UNIT=4563','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 20) && IntegerUtils.equals(c.getUwgrpCf(), 4563)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,8,124,1,'UW_UNIT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,8,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,8,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,8,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,8,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (9,124,1,'9','JU Brazil with UK',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,9,124,1,'',9,'RI_TYPE in (9,20) and SUBSIDIARY=10 AND CTR_TYPE=2 and UW_PFT_ORIGIN=1 and UW_UNIT=4563','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 1) && IntegerUtils.equals(c.getUwgrpCf(), 4563)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,9,124,1,'UW_UNIT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,9,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,9,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,9,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,9,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (10,124,1,'10','JU GSINDA with Paris',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,10,124,1,'',10,'RI_TYPE in (9,20) and SUBSIDIARY=10 AND CTR_TYPE=2 and UW_PFT_ORIGIN=2 and UW_UNIT<>4563','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 2) && !IntegerUtils.equals(c.getUwgrpCf(), 4563)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,124,1,'UW_UNIT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (11,124,1,'11','JU GSINDA with UK',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,11,124,1,'',11,'RI_TYPE in (9,20) and SUBSIDIARY=10 AND CTR_TYPE=2 and UW_PFT_ORIGIN=17 and UW_UNIT<>4563','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 17) && !IntegerUtils.equals(c.getUwgrpCf(), 4563)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,11,124,1,'UW_UNIT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,11,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,11,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,11,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,11,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (12,124,1,'12','JU GSINDA with Zurich',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,12,124,1,'',12,'RI_TYPE in (9,20) and SUBSIDIARY=10 AND CTR_TYPE=2 and UW_PFT_ORIGIN=20 and UW_UNIT<>4563','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 20) && !IntegerUtils.equals(c.getUwgrpCf(), 4563)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,12,124,1,'UW_UNIT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,12,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,12,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,12,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,12,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (13,124,1,'13','JU GSINDA with Asia Pacific',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,13,124,1,'',13,'RI_TYPE in (9,20) and SUBSIDIARY=10 AND CTR_TYPE=2 and UW_PFT_ORIGIN=1 and UW_UNIT<>4563','(IntegerUtils.equals(c.getReitypCf(), 9) || IntegerUtils.equals(c.getReitypCf(), 20)) && IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getUworgCf(), 1) && !IntegerUtils.equals(c.getUwgrpCf(), 4563)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,13,124,1,'UW_UNIT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,13,124,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,13,124,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,13,124,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,13,124,1,'SUBSIDIARY',getDate(),'DBEU')

go

-- Update the Rule label with the label of the segment (TSEGMT.SGMT_LS)
UPDATE TSEGMENTRULE SET RULE_LS=SGMT_LS
FROM TSEGMENTRULE, TSEGMT
WHERE TSEGMT.SGT_NT = TSEGMENTRULE.SGT_NT AND TSEGMT.SGTVER_NT = TSEGMENTRULE.SGTVER_NT AND TSEGMENTRULE.SGMT_NF = TSEGMT.SGMT_NF
and TSEGMENTRULE.SGT_NT = 124
go