use BEST
go 

delete from TSEGTYPE where SGTTYP_NT = 16
go
delete from TSEGMENTATION where SGT_NT = 116
go
delete from  TSEGMT where SGT_NT = 116
go
delete from  TSEGMENTLVL where SGT_NT = 116
go
delete from  TSEGMENTEXCEPT where SGT_NT = 116
go
delete from  TSEGMENTRULE2TYPE where SGT_NT = 116
go
delete from  TSEGMENTRULE2CRI where SGT_NT = 116
go
delete from  TSEGMENTRULE where SGT_NT = 116
go
delete from  TSEG2ESB where SGT_NT = 116
go
delete from  TSEG2CTRSTS where SGT_NT = 116
go
delete from  TSEG2CTRCAT where SGT_NT = 116
go
delete from  TSEG2SECSTS where SGT_NT = 116
go
delete from  TSEG2SECACCSTS where SGT_NT = 116
go


/*==============================================================*/
/* Table: Segmentation 116 - 1 */
/*==============================================================*/
INSERT INTO TSEGTYPE values (16,'Discontinued Business','1','1','1',1, getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTATION values (116,1,16,'Discontinued Business','Discontinued Business',null,null,'3','3',0,1,0,0,4020,'DBEU','1','0',1,1,1,1,'1',null,null,getDate(),null,getDate(),'DBEU',getDate(),'DBEU',null)
 ---SQL Statement
insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (0, 116,1,'Discontinued Business','Discontinued Business',getDate(),'DBEU',getDate(),'DBEU',null)

 ---SQL Statement
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (10,116,1,'10','SOREMA SA',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (20,116,1,'20','VERITAS',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (200,116,1,'200','US Program Biz',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (201,116,1,'201','US Sorema Direct',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (210,116,1,'210','US C & S',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (211,116,1,'211','US A & H',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (212,116,1,'212','US Selected Grp',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (213,116,1,'213','US SOREMA NA Tty',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (214,116,1,'214','US Gen Sec......',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (215,116,1,'215','US WC S Alone',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (216,116,1,'216','US CRP',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (220,116,1,'220','US Fac Buffer',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (221,116,1,'221','US Fac Low Layer',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (222,116,1,'222','US SOREMA NA Fac',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,116,1,'0','Ongoing',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,1,116,1,'',13,'SUBSIDIARY=10','IntegerUtils.equals(c.getSsdCf(), 10)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,116,1,'SUBSIDIARY',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,10,116,1,'',15,'UW_PFT_ORIGIN=76 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 76) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,10,116,1,'',16,'UW_PFT_ORIGIN=77 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 77) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,10,116,1,'',17,'UW_PFT_ORIGIN=78 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 78) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,10,116,1,'',18,'UW_PFT_ORIGIN=100 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 100) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,10,116,1,'',19,'UW_PFT_ORIGIN=101 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 101) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,10,116,1,'',20,'UW_PFT_ORIGIN=102 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 102) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,10,116,1,'',21,'UW_PFT_ORIGIN=103 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 103) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (8,10,116,1,'',22,'UW_PFT_ORIGIN=104 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 104) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (9,10,116,1,'',23,'UW_PFT_ORIGIN=105 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 105) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (10,10,116,1,'',24,'UW_PFT_ORIGIN=106 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 106) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (11,10,116,1,'',25,'UW_PFT_ORIGIN=107 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 107) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (11,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (11,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (12,10,116,1,'',26,'UW_PFT_ORIGIN=108 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 108) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (12,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (12,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (13,10,116,1,'',27,'UW_PFT_ORIGIN=109 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 109) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (13,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (13,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (14,10,116,1,'',28,'UW_PFT_ORIGIN=110 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 110) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (14,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (14,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (15,10,116,1,'',29,'UW_PFT_ORIGIN=111 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 111) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (15,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (15,10,116,1,'UWY',getDate(),'DBEU')

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (16,10,116,1,'',30,'UW_PFT_ORIGIN=112 AND UWY <= 2000','IntegerUtils.equals(c.getUworgCf(), 112) && IntegerUtils.inferiorOrEquals(c.getUwyNf(), 2000)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (16,10,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (16,10,116,1,'UWY',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,20,116,1,'',14,'UW_PFT_ORIGIN=79','IntegerUtils.equals(c.getUworgCf(), 79)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,20,116,1,'UW_PFT_ORIGIN',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,200,116,1,'',1,'SUBSIDIARY=10 AND SEC_QUALIFIER3=200','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 200)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,200,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,200,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,201,116,1,'',2,'SUBSIDIARY=10 AND SEC_QUALIFIER3=201','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 201)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,201,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,201,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,210,116,1,'',3,'SUBSIDIARY=10 AND SEC_QUALIFIER3=210','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 210)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,210,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,210,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,211,116,1,'',4,'SUBSIDIARY=10 AND SEC_QUALIFIER3=211','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 211)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,211,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,211,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,212,116,1,'',5,'SUBSIDIARY=10 AND SEC_QUALIFIER3=212','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 212)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,212,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,212,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,213,116,1,'',6,'SUBSIDIARY=10 AND SEC_QUALIFIER3=213','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 213)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,213,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,213,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,214,116,1,'',7,'SUBSIDIARY=10 AND SEC_QUALIFIER3=214','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 214)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,214,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,214,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,215,116,1,'',8,'SUBSIDIARY=10 AND SEC_QUALIFIER3=215','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 215)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,215,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,215,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,216,116,1,'',9,'SUBSIDIARY=10 AND SEC_QUALIFIER3=216','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 216)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,216,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,216,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,220,116,1,'',10,'SUBSIDIARY=10 AND SEC_QUALIFIER3=220','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 220)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,220,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,220,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,221,116,1,'',11,'SUBSIDIARY=10 AND SEC_QUALIFIER3=221','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 221)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,221,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,221,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go



insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,222,116,1,'',12,'SUBSIDIARY=10 AND SEC_QUALIFIER3=222','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getSecqua3Cf(), 222)',getDate(),'DBEU',getDate(),'DBEU',null)

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,222,116,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,222,116,1,'SEC_QUALIFIER3',getDate(),'DBEU')

go

-- Update the Rule label with the label of the segment (TSEGMT.SGMT_LS)
UPDATE TSEGMENTRULE SET RULE_LS=SGMT_LS
FROM TSEGMENTRULE, TSEGMT
WHERE TSEGMT.SGT_NT = TSEGMENTRULE.SGT_NT AND TSEGMT.SGTVER_NT = TSEGMENTRULE.SGTVER_NT AND TSEGMENTRULE.SGMT_NF = TSEGMT.SGMT_NF
and TSEGMENTRULE.SGT_NT = 116
go