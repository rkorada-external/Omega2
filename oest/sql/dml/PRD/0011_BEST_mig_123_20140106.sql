use BEST
go 

delete from TSEGTYPE where SGTTYP_NT = 23
go
delete from TSEGMENTATION where SGT_NT = 123
go
delete from  TSEGMT where SGT_NT = 123
go
delete from  TSEGMENTLVL where SGT_NT = 123
go
delete from  TSEGMENTEXCEPT where SGT_NT = 123
go
delete from  TSEGMENTRULE2TYPE where SGT_NT = 123
go
delete from  TSEGMENTRULE2CRI where SGT_NT = 123
go
delete from  TSEGMENTRULE where SGT_NT = 123
go
delete from  TSEG2ESB where SGT_NT = 123
go
delete from  TSEG2CTRSTS where SGT_NT = 123
go
delete from  TSEG2CTRCAT where SGT_NT = 123
go
delete from  TSEG2SECSTS where SGT_NT = 123
go
delete from  TSEG2SECACCSTS where SGT_NT = 123
go


/*==============================================================*/
/* Table: Segmentation 123 - 1 */
/*==============================================================*/
INSERT INTO TSEGTYPE values (23,'Retro GEO SII','1','2','1',1, getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTATION values (123,1,23,'GEO SII','GEO SII',null,null,'3','5',0,1,0,0,4020,'DBEU','1','0',1,1,1,1,'1',null,null,getDate(),null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (0, 123,1,'GEO SII','GEO SII',getDate(),'DBEU',getDate(),'DBEU',null)

 ---SQL Statement
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,123,1,'1','Cent & West Asia',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (10,123,1,'10','Western Europe',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (11,123,1,'11','NA excl. USA',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (12,123,1,'12','Carib. Cent. Ame',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (13,123,1,'13','Lat Am East',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (14,123,1,'14','Lat Am excl East',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (15,123,1,'15','North-east US',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (16,123,1,'16','South-east US',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (17,123,1,'17','Mid-west US',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (18,123,1,'18','Western US',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,123,1,'2','Eastern Asia',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,123,1,'3','South & SE Asia',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,123,1,'4','Oceania',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,123,1,'5','Northern Africa',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,123,1,'6','Southern Africa',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,123,1,'7','Eastern Europe',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (8,123,1,'8','Northern Europe',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (9,123,1,'9','Southern Europe',0,null,null,getDate(),'DBEU',getDate(),'DBEU',null)

go

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,2,123,1,'',19,'SUBSIDIARY=20 AND SUBLEDGER=2','IntegerUtils.equals(c.getSsdCf(), 20) && IntegerUtils.equals(c.getAccesbCf(), 2)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,2,123,1,'',22,'SUBSIDIARY=20 AND SUBLEDGER=5','IntegerUtils.equals(c.getSsdCf(), 20) && IntegerUtils.equals(c.getAccesbCf(), 5)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,2,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,2,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,2,123,1,'',23,'SUBSIDIARY=20 AND SUBLEDGER=7','IntegerUtils.equals(c.getSsdCf(), 20) && IntegerUtils.equals(c.getAccesbCf(), 7)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,2,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,2,123,1,'SUBSIDIARY',getDate(),'DBEU')
go

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,3,123,1,'',18,'SUBSIDIARY=20 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 20) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,3,123,1,'',21,'SUBSIDIARY=20 AND SUBLEDGER=4','IntegerUtils.equals(c.getSsdCf(), 20) && IntegerUtils.equals(c.getAccesbCf(), 4)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,3,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,3,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,3,123,1,'',29,'SUBSIDIARY=17 AND SUBLEDGER=14','IntegerUtils.equals(c.getSsdCf(), 17) && IntegerUtils.equals(c.getAccesbCf(), 14)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,3,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,3,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,3,123,1,'',31,'SUBSIDIARY=20 AND SUBLEDGER=11','IntegerUtils.equals(c.getSsdCf(), 20) && IntegerUtils.equals(c.getAccesbCf(), 11)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,3,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,3,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,3,123,1,'',32,'SUBSIDIARY=20 AND SUBLEDGER=12','IntegerUtils.equals(c.getSsdCf(), 20) && IntegerUtils.equals(c.getAccesbCf(), 12)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,3,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,3,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,3,123,1,'',44,'SUBSIDIARY=20 AND SUBLEDGER=8','IntegerUtils.equals(c.getSsdCf(), 20) && IntegerUtils.equals(c.getAccesbCf(), 8)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,3,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,3,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,3,123,1,'',45,'SUBSIDIARY=20 AND SUBLEDGER=10','IntegerUtils.equals(c.getSsdCf(), 20) && IntegerUtils.equals(c.getAccesbCf(), 10)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,3,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,3,123,1,'SUBSIDIARY',getDate(),'DBEU')
go

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,4,123,1,'',20,'SUBSIDIARY=20 AND SUBLEDGER=3','IntegerUtils.equals(c.getSsdCf(), 20) && IntegerUtils.equals(c.getAccesbCf(), 3)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,4,123,1,'',33,'SUBSIDIARY=22 AND SUBLEDGER=2','IntegerUtils.equals(c.getSsdCf(), 22) && IntegerUtils.equals(c.getAccesbCf(), 2)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,4,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,4,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,4,123,1,'',46,'SUBSIDIARY=22 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 22) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,4,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,4,123,1,'SUBSIDIARY',getDate(),'DBEU')
go

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,6,123,1,'',5,'SUBSIDIARY=2 AND SUBLEDGER=6','IntegerUtils.equals(c.getSsdCf(), 2) && IntegerUtils.equals(c.getAccesbCf(), 6)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,6,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,6,123,1,'SUBSIDIARY',getDate(),'DBEU')
go

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,7,123,1,'',4,'SUBSIDIARY=2 AND SUBLEDGER=4','IntegerUtils.equals(c.getSsdCf(), 2) && IntegerUtils.equals(c.getAccesbCf(), 4)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,123,1,'SUBSIDIARY',getDate(),'DBEU')
go

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,8,123,1,'',1,'SUBSIDIARY=1 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 1) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,8,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,8,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,8,123,1,'',2,'SUBSIDIARY=1 AND SUBLEDGER=2','IntegerUtils.equals(c.getSsdCf(), 1) && IntegerUtils.equals(c.getAccesbCf(), 2)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,8,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,8,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,8,123,1,'',13,'SUBSIDIARY=1 AND SUBLEDGER=10','IntegerUtils.equals(c.getSsdCf(), 1) && IntegerUtils.equals(c.getAccesbCf(), 10)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,8,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,8,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,8,123,1,'',15,'SUBSIDIARY=1 AND SUBLEDGER=11','IntegerUtils.equals(c.getSsdCf(), 1) && IntegerUtils.equals(c.getAccesbCf(), 11)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,8,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,8,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,8,123,1,'',16,'SUBSIDIARY=17 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 17) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,8,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,8,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,8,123,1,'',26,'SUBSIDIARY=17 AND SUBLEDGER=10','IntegerUtils.equals(c.getSsdCf(), 17) && IntegerUtils.equals(c.getAccesbCf(), 10)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,8,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,8,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,8,123,1,'',37,'SUBSIDIARY=15 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 15) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,8,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,8,123,1,'SUBSIDIARY',getDate(),'DBEU')
go

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,9,123,1,'',7,'SUBSIDIARY=6 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 6) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,9,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,9,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,9,123,1,'',34,'SUBSIDIARY=2 AND SUBLEDGER=2','IntegerUtils.equals(c.getSsdCf(), 2) && IntegerUtils.equals(c.getAccesbCf(), 2)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,9,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,9,123,1,'SUBSIDIARY',getDate(),'DBEU')
go

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,10,123,1,'',3,'SUBSIDIARY=2 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 2) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,10,123,1,'',6,'SUBSIDIARY=5 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 5) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,10,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,10,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,10,123,1,'',17,'SUBSIDIARY=17 AND SUBLEDGER=2','IntegerUtils.equals(c.getSsdCf(), 17) && IntegerUtils.equals(c.getAccesbCf(), 2)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,10,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,10,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,10,123,1,'',24,'SUBSIDIARY=5 AND SUBLEDGER=10','IntegerUtils.equals(c.getSsdCf(), 5) && IntegerUtils.equals(c.getAccesbCf(), 10)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,10,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,10,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,10,123,1,'',27,'SUBSIDIARY=17 AND SUBLEDGER=11','IntegerUtils.equals(c.getSsdCf(), 17) && IntegerUtils.equals(c.getAccesbCf(), 11)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,10,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,10,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,10,123,1,'',35,'SUBSIDIARY=3 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 3) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,10,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,10,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,10,123,1,'',36,'SUBSIDIARY=7 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 7) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,10,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,10,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (8,10,123,1,'',38,'SUBSIDIARY=17 AND SUBLEDGER=13','IntegerUtils.equals(c.getSsdCf(), 17) && IntegerUtils.equals(c.getAccesbCf(), 13)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,10,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,10,123,1,'SUBSIDIARY',getDate(),'DBEU')
go

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,11,123,1,'',12,'SUBSIDIARY=10 AND SUBLEDGER=9','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getAccesbCf(), 9)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,11,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,11,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,11,123,1,'',14,'SUBSIDIARY=11 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 11) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,11,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,11,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,11,123,1,'',28,'SUBSIDIARY=17 AND SUBLEDGER=12','IntegerUtils.equals(c.getSsdCf(), 17) && IntegerUtils.equals(c.getAccesbCf(), 12)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,11,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,11,123,1,'SUBSIDIARY',getDate(),'DBEU')
go

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,12,123,1,'',25,'SUBSIDIARY=10 AND SUBLEDGER=12','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getAccesbCf(), 12)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,12,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,12,123,1,'SUBSIDIARY',getDate(),'DBEU')
go

insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,15,123,1,'',8,'SUBSIDIARY=10 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,15,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,15,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,15,123,1,'',9,'SUBSIDIARY=10 AND SUBLEDGER=4','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getAccesbCf(), 4)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,15,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,15,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,15,123,1,'',10,'SUBSIDIARY=10 AND SUBLEDGER=6','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getAccesbCf(), 6)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,15,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,15,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,15,123,1,'',11,'SUBSIDIARY=10 AND SUBLEDGER=8','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getAccesbCf(), 8)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,15,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,15,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,15,123,1,'',30,'SUBSIDIARY=17 AND SUBLEDGER=15','IntegerUtils.equals(c.getSsdCf(), 17) && IntegerUtils.equals(c.getAccesbCf(), 15)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,15,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,15,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,15,123,1,'',39,'SUBSIDIARY=10 AND SUBLEDGER=2','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getAccesbCf(), 2)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,15,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,15,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,15,123,1,'',40,'SUBSIDIARY=10 AND SUBLEDGER=3','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getAccesbCf(), 3)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,15,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,15,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (8,15,123,1,'',41,'SUBSIDIARY=10 AND SUBLEDGER=7','IntegerUtils.equals(c.getSsdCf(), 10) && IntegerUtils.equals(c.getAccesbCf(), 7)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,15,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,15,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (9,15,123,1,'',42,'SUBSIDIARY=13 AND SUBLEDGER=1','IntegerUtils.equals(c.getSsdCf(), 13) && IntegerUtils.equals(c.getAccesbCf(), 1)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,15,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,15,123,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (10,15,123,1,'',43,'SUBSIDIARY=13 AND SUBLEDGER=2','IntegerUtils.equals(c.getSsdCf(), 13) && IntegerUtils.equals(c.getAccesbCf(), 2)',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,15,123,1,'SUBLEDGER',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,15,123,1,'SUBSIDIARY',getDate(),'DBEU')
go

-- Update the Rule label with the label of the segment (TSEGMT.SGMT_LS)
UPDATE TSEGMENTRULE SET RULE_LS=SGMT_LS
FROM TSEGMENTRULE, TSEGMT
WHERE TSEGMT.SGT_NT = TSEGMENTRULE.SGT_NT AND TSEGMT.SGTVER_NT = TSEGMENTRULE.SGTVER_NT AND TSEGMENTRULE.SGMT_NF = TSEGMT.SGMT_NF
and TSEGMENTRULE.SGT_NT = 123
go