use BEST
go 
delete from TSEGTYPE where SGTTYP_NT = 2
go
delete from TSEGMENTATION where SGT_NT = 101
go
delete from  TSEGMT where SGT_NT = 101
go
delete from  TSEGMENTLVL where SGT_NT = 101
go
delete from  TSEGMENTEXCEPT where SGT_NT = 101
go
delete from  TSEGMENTRULE2TYPE where SGT_NT = 101
go
delete from  TSEGMENTRULE2CRI where SGT_NT = 101
go
delete from  TSEGMENTRULE where SGT_NT = 101
go
delete from  TSEG2ESB where SGT_NT = 101
go
delete from  TSEG2CTRSTS where SGT_NT = 101
go
delete from  TSEG2CTRCAT where SGT_NT = 101
go
delete from  TSEG2SECSTS where SGT_NT = 101
go
delete from  TSEG2SECACCSTS where SGT_NT = 101
go

INSERT INTO TSEGTYPE values (2,'SEG LOB','1','1','1',1, getDate(),'DBEU',getDate(),'DBEU',null)
INSERT INTO TSEGMENTATION values (101,1,2,'LOB','LOB',null,null,'3','3',0,1,0,2,4020,'DBEU','1','0',1,1,1,1,'1',null,null,getDate(),null,getDate(),'DBEU',getDate(),'DBEU',null)
go

/*==============================================================*/
/* Table: Segmentation 101 - 1 */
/*==============================================================*/

 --- insertion Hierarchy Levels 101
insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (0, 101,1,'LOBN1','LOBN1',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1, 101,1,'LOBN2','LOBN2',getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMENTLVL (SGTLVL_CT, SGT_NT, SGTVER_NT, LVL_LS, LVL_LM, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2, 101,1,'LOBN3','LOBN3',getDate(),'DBEU',getDate(),'DBEU',null)
go


 --- insertion Segments 101
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (1,101,1,'1011','Credit',0,56,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (2,101,1,'1021','Surety',0,56,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (3,101,1,'1041','LRA',0,57,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (4,101,1,'1051','GAUM',0,58,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (5,101,1,'1061','MDU',0,59,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (6,101,1,'1071','Lloyds',0,60,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (7,101,1,'1081','Inwards Retro',0,61,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (8,101,1,'1101','Agriculture',0,62,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (9,101,1,'1111','Decennial',0,63,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (10,101,1,'1121','Space',0,64,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (11,101,1,'1131','Aviation',0,65,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (12,101,1,'1161','Engineering',0,70,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (13,101,1,'1171','Contingency',0,66,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (14,101,1,'1181','US CAT NAT',0,67,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (15,101,1,'1201','Retro (LPT/ADC)',0,68,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (16,101,1,'1211','Structured QS',0,68,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (17,101,1,'1221','Agg XS/Stop Loss',0,68,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (18,101,1,'1231','Other SRT',0,68,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (19,101,1,'1241','Marine',0,69,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (20,101,1,'1251','Offshore',0,69,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (21,101,1,'2201','Ppty Non Energy',0,74,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (22,101,1,'2211','Property Energy',0,74,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (23,101,1,'2221','Engineering',0,70,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (24,101,1,'2231','GL (EL included)',0,76,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (25,101,1,'2291','Pers. Insurance',0,72,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (26,101,1,'2401','ARF',0,71,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (27,101,1,'2411','Offshore Operat.',0,72,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (28,101,1,'2421','Const.Offsh&Ship',0,72,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (29,101,1,'3001','Property P',0,74,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (30,101,1,'3011','Property NPW',0,74,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (31,101,1,'3021','Property CAT',0,73,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (32,101,1,'3031','Property Fac',0,74,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (33,101,1,'3041','Auto P',0,75,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (34,101,1,'3051','Auto NP',0,75,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (35,101,1,'3061','Liability P',0,76,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (36,101,1,'3071','Liability NP',0,76,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (37,101,1,'3081','Other Work. Comp',0,76,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (38,101,1,'3091','Liability Fac',0,76,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (39,101,1,'3121','Special Risks',0,72,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (40,101,1,'3131','Pers. Insurance',0,72,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (41,101,1,'5020','Life-Individual',0,77,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (42,101,1,'5030','Life-Group',0,77,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (43,101,1,'5040','Saving&Annuities',0,77,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (44,101,1,'5050','Accident',0,77,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (45,101,1,'5060','Health',0,77,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (46,101,1,'5070','Disability',0,77,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (47,101,1,'5080','Long Term Care',0,77,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (48,101,1,'5090','Critical Illness',0,77,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (49,101,1,'5100','Unemployment',0,77,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (50,101,1,'5110','Non Proportional',0,77,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (51,101,1,'5120','Remark',0,78,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (52,101,1,'5130','Financing-Others',0,78,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (53,101,1,'5140','Non RiskTransfer',0,79,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (54,101,1,'5900','SGL to segment',0,80,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (55,101,1,'9999','Unspecified',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (56,101,1,'1100','C&S',1,82,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (57,101,1,'2080','LRA',1,83,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (58,101,1,'2030','Gaum',1,83,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (59,101,1,'2040','MDU',1,83,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (60,101,1,'2050','Lloyds',1,83,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (61,101,1,'2070','Inwards Retro',1,82,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (62,101,1,'1000','Agriculture',1,82,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (63,101,1,'1300','Decennial',1,82,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (64,101,1,'1700','Space',1,82,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (65,101,1,'2010','Aviation',1,82,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (66,101,1,'2020','Contingency',1,82,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (67,101,1,'2060','US CAT NAT',1,82,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (68,101,1,'1800','Struct. Products',1,82,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (69,101,1,'2000','Marine&Offshore',1,82,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (70,101,1,'1400','Engineering',1,82,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (71,101,1,'1850','ARF',1,86,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (72,101,1,'1900','Others',1,86,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (73,101,1,'1650','Property CAT',1,84,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (74,101,1,'1600','Property',1,84,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (75,101,1,'1500','Motor',1,87,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (76,101,1,'1200','Casualty',1,85,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (77,101,1,'5000','Classical Bus.',1,88,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (78,101,1,'5010','Financing Bus.',1,88,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (79,101,1,'5020','IAS39',1,88,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (80,101,1,'5900','SGL to segment',1,88,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (81,101,1,'9999','UNSPECIFIED',1,88,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (82,101,1,'2070','Oth. Specialties',2,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (83,101,1,'2080','J V & Lloyds',2,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (84,101,1,'1600','Property',2,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (85,101,1,'1200','Casualty',2,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (86,101,1,'1900','Others',2,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (87,101,1,'1500','Motor',2,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (88,101,1,'9999','UNSPECIFIED',2,null,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (100,101,1,'1031','Cred&Surety Fac',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (101,101,1,'1141','Credit & Surety',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (102,101,1,'1151','Marine & Offsh.',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (103,101,1,'2241','D&O, E&O',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (104,101,1,'2251','Offsh.&Shipbuild',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (105,101,1,'2261','Space/Aviat Fac',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (106,101,1,'2271','Decennial Fac',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (107,101,1,'2281','BS Treaties',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (108,101,1,'2301','Agriculture Fac',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (109,101,1,'3101','Transp./Offshore',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (110,101,1,'3111','Space/Aviat. Tty',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (111,101,1,'3141','Facs P&C',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)
insert into TSEGMT (SGMT_NF, SGT_NT, SGTVER_NT, SGMT_LS, SGMT_LL, SGTLVL_NT, PARSGMT_CF, BALAIMGT_CT, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp) values (112,101,1,'3151','Agriculture Tty',0,81,null,getDate(),'DBEU',getDate(),'DBEU',null)


---
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 52, 101, 1, ' ', 1, 'SOB=''81'' AND Group_Division=''400''', 'StringUtils.equals(c.getSobCf(), "81") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 53, 101, 1, ' ', 2, 'Group_Division=''400'' AND SEC_IFRS=2', 'StringUtils.equals(c.getSegLabel18Lvl0(), "400") && IntegerUtils.equals(c.getAssfinanceCt(), 2)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 51, 101, 1, ' ', 3, 'Group_Division=''400'' AND LIFE_TREATY_TYPE=''A9''', 'StringUtils.equals(c.getSegLabel18Lvl0(), "400") && StringUtils.equals(c.getLiftrttypCf(), "A9")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 52, 101, 1, ' ', 4, 'Group_Division=''400'' AND LIFE_TREATY_TYPE=''A4''', 'StringUtils.equals(c.getSegLabel18Lvl0(), "400") && StringUtils.equals(c.getLiftrttypCf(), "A4")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 52, 101, 1, ' ', 5, 'Group_Division=''400'' AND LIFE_TREATY_TYPE=''A3''', 'StringUtils.equals(c.getSegLabel18Lvl0(), "400") && StringUtils.equals(c.getLiftrttypCf(), "A3")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 4, 52, 101, 1, ' ', 6, 'Group_Division=''400'' AND LIFE_TREATY_TYPE=''B2''', 'StringUtils.equals(c.getSegLabel18Lvl0(), "400") && StringUtils.equals(c.getLiftrttypCf(), "B2")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 5, 52, 101, 1, ' ', 7, 'Group_Division=''400'' AND LIFE_TREATY_TYPE=''B7''', 'StringUtils.equals(c.getSegLabel18Lvl0(), "400") && StringUtils.equals(c.getLiftrttypCf(), "B7")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 6, 52, 101, 1, ' ', 8, 'Group_Division=''400'' AND LIFE_TREATY_TYPE=''B8''', 'StringUtils.equals(c.getSegLabel18Lvl0(), "400") && StringUtils.equals(c.getLiftrttypCf(), "B8")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 50, 101, 1, ' ', 9, 'P_NP=''N'' AND Group_Division=''400''', 'StringUtils.equals(c.getNatB(), "N") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 41, 101, 1, ' ', 10, 'LOB=''30'' AND P_NP=''P'' AND TOP=''900'' AND GUARANTEE=''900'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "900") && StringUtils.equals(c.getGarCf(), "900") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 41, 101, 1, ' ', 11, 'LOB=''30'' AND P_NP=''P'' AND TOP=''900'' AND GUARANTEE=''904'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "900") && StringUtils.equals(c.getGarCf(), "904") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 41, 101, 1, ' ', 12, 'LOB=''30'' AND P_NP=''P'' AND TOP=''900'' AND GUARANTEE=''960'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "900") && StringUtils.equals(c.getGarCf(), "960") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 4, 41, 101, 1, ' ', 13, 'LOB=''30'' AND P_NP=''P'' AND TOP=''900'' AND GUARANTEE=''080'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "900") && StringUtils.equals(c.getGarCf(), "080") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 5, 41, 101, 1, ' ', 14, 'LOB=''30'' AND P_NP=''P'' AND TOP=''900'' AND GUARANTEE=''995'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "900") && StringUtils.equals(c.getGarCf(), "995") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 6, 41, 101, 1, ' ', 15, 'LOB=''30'' AND P_NP=''P'' AND TOP=''900'' AND GUARANTEE=''999'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "900") && StringUtils.equals(c.getGarCf(), "999") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 7, 41, 101, 1, ' ', 16, 'LOB=''30'' AND P_NP=''P'' AND TOP=''900'' AND GUARANTEE=''917'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "900") && StringUtils.equals(c.getGarCf(), "917") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 8, 41, 101, 1, ' ', 17, 'LOB=''30'' AND P_NP=''P'' AND TOP=''900'' AND GUARANTEE=''918'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "900") && StringUtils.equals(c.getGarCf(), "918") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 9, 41, 101, 1, ' ', 18, 'LOB=''30'' AND P_NP=''P'' AND TOP=''911'' AND GUARANTEE=''900'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "911") && StringUtils.equals(c.getGarCf(), "900") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 10, 41, 101, 1, ' ', 19, 'LOB=''30'' AND P_NP=''P'' AND TOP=''911'' AND GUARANTEE=''904'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "911") && StringUtils.equals(c.getGarCf(), "904") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 11, 41, 101, 1, ' ', 20, 'LOB=''30'' AND P_NP=''P'' AND TOP=''911'' AND GUARANTEE=''960'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "911") && StringUtils.equals(c.getGarCf(), "960") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 12, 41, 101, 1, ' ', 21, 'LOB=''30'' AND P_NP=''P'' AND TOP=''911'' AND GUARANTEE=''080'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "911") && StringUtils.equals(c.getGarCf(), "080") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 13, 41, 101, 1, ' ', 22, 'LOB=''30'' AND P_NP=''P'' AND TOP=''911'' AND GUARANTEE=''995'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "911") && StringUtils.equals(c.getGarCf(), "995") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 14, 41, 101, 1, ' ', 23, 'LOB=''30'' AND P_NP=''P'' AND TOP=''911'' AND GUARANTEE=''999'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "911") && StringUtils.equals(c.getGarCf(), "999") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 15, 41, 101, 1, ' ', 24, 'LOB=''30'' AND P_NP=''P'' AND TOP=''911'' AND GUARANTEE=''917'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "911") && StringUtils.equals(c.getGarCf(), "917") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 16, 41, 101, 1, ' ', 25, 'LOB=''30'' AND P_NP=''P'' AND TOP=''911'' AND GUARANTEE=''918'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "911") && StringUtils.equals(c.getGarCf(), "918") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 17, 41, 101, 1, ' ', 26, 'LOB=''30'' AND P_NP=''P'' AND TOP=''940'' AND GUARANTEE=''900'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "940") && StringUtils.equals(c.getGarCf(), "900") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 18, 41, 101, 1, ' ', 27, 'LOB=''30'' AND P_NP=''P'' AND TOP=''940'' AND GUARANTEE=''904'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "940") && StringUtils.equals(c.getGarCf(), "904") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 19, 41, 101, 1, ' ', 28, 'LOB=''30'' AND P_NP=''P'' AND TOP=''940'' AND GUARANTEE=''960'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "940") && StringUtils.equals(c.getGarCf(), "960") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 20, 41, 101, 1, ' ', 29, 'LOB=''30'' AND P_NP=''P'' AND TOP=''940'' AND GUARANTEE=''080'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "940") && StringUtils.equals(c.getGarCf(), "080") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 21, 41, 101, 1, ' ', 30, 'LOB=''30'' AND P_NP=''P'' AND TOP=''940'' AND GUARANTEE=''995'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "940") && StringUtils.equals(c.getGarCf(), "995") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 22, 41, 101, 1, ' ', 31, 'LOB=''30'' AND P_NP=''P'' AND TOP=''940'' AND GUARANTEE=''999'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "940") && StringUtils.equals(c.getGarCf(), "999") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 23, 41, 101, 1, ' ', 32, 'LOB=''30'' AND P_NP=''P'' AND TOP=''940'' AND GUARANTEE=''917'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "940") && StringUtils.equals(c.getGarCf(), "917") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 24, 41, 101, 1, ' ', 33, 'LOB=''30'' AND P_NP=''P'' AND TOP=''940'' AND GUARANTEE=''918'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "940") && StringUtils.equals(c.getGarCf(), "918") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 25, 41, 101, 1, ' ', 34, 'LOB=''30'' AND P_NP=''P'' AND TOP=''900'' AND GUARANTEE=''906'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "900") && StringUtils.equals(c.getGarCf(), "906") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 26, 41, 101, 1, ' ', 35, 'LOB=''30'' AND P_NP=''P'' AND TOP=''911'' AND GUARANTEE=''906'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "911") && StringUtils.equals(c.getGarCf(), "906") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 27, 41, 101, 1, ' ', 36, 'LOB=''30'' AND P_NP=''P'' AND TOP=''940'' AND GUARANTEE=''906'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getTopCf(), "940") && StringUtils.equals(c.getGarCf(), "906") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 42, 101, 1, ' ', 37, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''900'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "900") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 42, 101, 1, ' ', 38, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''906'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "906") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 42, 101, 1, ' ', 39, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''904'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "904") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 4, 42, 101, 1, ' ', 40, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''960'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "960") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 5, 42, 101, 1, ' ', 41, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''080'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "080") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 6, 42, 101, 1, ' ', 42, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''995'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "995") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 7, 42, 101, 1, ' ', 43, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''999'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "999") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 8, 42, 101, 1, ' ', 44, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''917'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "917") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 9, 42, 101, 1, ' ', 45, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''918'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "918") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 43, 101, 1, ' ', 46, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''908'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "908") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 43, 101, 1, ' ', 47, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''912'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "912") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 43, 101, 1, ' ', 48, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''963'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "963") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 48, 101, 1, ' ', 49, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''947'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "947") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 48, 101, 1, ' ', 50, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''948'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "948") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 44, 101, 1, ' ', 51, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''900'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "900") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 44, 101, 1, ' ', 52, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''916'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "916") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 44, 101, 1, ' ', 53, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''920'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "920") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 46, 101, 1, ' ', 54, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''924'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "924") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 46, 101, 1, ' ', 55, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''917'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "917") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 46, 101, 1, ' ', 56, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''928'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "928") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 4, 46, 101, 1, ' ', 57, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''932'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "932") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 45, 101, 1, ' ', 58, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''936'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "936") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 45, 101, 1, ' ', 59, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''707'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "707") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 49, 101, 1, ' ', 60, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''940'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "940") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 47, 101, 1, ' ', 61, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''944'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "944") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 47, 101, 1, ' ', 62, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''945'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "945") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 4, 44, 101, 1, ' ', 63, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''080'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "080") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 5, 44, 101, 1, ' ', 64, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''082'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "082") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 6, 44, 101, 1, ' ', 65, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''445'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "445") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 10, 42, 101, 1, ' ', 66, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''905'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "905") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 11, 42, 101, 1, ' ', 67, 'LOB=''30'' AND P_NP=''P'' AND GUARANTEE=''916'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "916") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 7, 44, 101, 1, ' ', 68, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''905'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "905") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 8, 44, 101, 1, ' ', 69, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''995'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "995") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 9, 44, 101, 1, ' ', 70, 'LOB=''31'' AND P_NP=''P'' AND GUARANTEE=''999'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getNatB(), "P") && StringUtils.equals(c.getGarCf(), "999") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 54, 101, 1, ' ', 71, 'LOB=''30'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "30") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 54, 101, 1, ' ', 72, 'LOB=''31'' AND Group_Division=''400''', 'StringUtils.equals(c.getLobCf(), "31") && StringUtils.equals(c.getSegLabel18Lvl0(), "400")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 15, 101, 1, ' ', 73, 'CTR_TYPE=1 AND Group_Division=''600'' AND RI_TYPE=15', 'IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "600") && IntegerUtils.equals(c.getReitypCf(), 15)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 16, 101, 1, ' ', 74, 'CTR_TYPE=1 AND Group_Division=''600'' AND RI_TYPE=16', 'IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "600") && IntegerUtils.equals(c.getReitypCf(), 16)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 17, 101, 1, ' ', 75, 'CTR_TYPE=1 AND Group_Division=''600'' AND RI_TYPE=17', 'IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "600") && IntegerUtils.equals(c.getReitypCf(), 17)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 18, 101, 1, ' ', 76, 'CTR_TYPE=1 AND Group_Division=''600'' AND RI_TYPE=18', 'IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "600") && IntegerUtils.equals(c.getReitypCf(), 18)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 26, 101, 1, ' ', 77, 'CTR_TYPE=2 AND Group_Division=''100'' AND RI_TYPE=15', 'IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100") && IntegerUtils.equals(c.getReitypCf(), 15)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 26, 101, 1, ' ', 78, 'CTR_TYPE=2 AND Group_Division=''100'' AND RI_TYPE=16', 'IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100") && IntegerUtils.equals(c.getReitypCf(), 16)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 26, 101, 1, ' ', 79, 'CTR_TYPE=2 AND Group_Division=''100'' AND RI_TYPE=17', 'IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100") && IntegerUtils.equals(c.getReitypCf(), 17)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 4, 26, 101, 1, ' ', 80, 'CTR_TYPE=2 AND Group_Division=''100'' AND RI_TYPE=18', 'IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100") && IntegerUtils.equals(c.getReitypCf(), 18)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 4, 101, 1, ' ', 81, 'Group_Division=''600'' AND CTR_QUALIFIER3=10', 'StringUtils.equals(c.getSegLabel18Lvl0(), "600") && IntegerUtils.equals(c.getCtrqua3Cf(), 10)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 5, 101, 1, ' ', 82, 'Group_Division=''600'' AND CTR_QUALIFIER3=11', 'StringUtils.equals(c.getSegLabel18Lvl0(), "600") && IntegerUtils.equals(c.getCtrqua3Cf(), 11)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 6, 101, 1, ' ', 83, 'Group_Division=''600'' AND CTR_QUALIFIER3=12', 'StringUtils.equals(c.getSegLabel18Lvl0(), "600") && IntegerUtils.equals(c.getCtrqua3Cf(), 12)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 7, 101, 1, ' ', 84, 'CTR_TYPE=1 AND Group_Division=''600'' AND CTR_QUALIFIER3=17', 'IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "600") && IntegerUtils.equals(c.getCtrqua3Cf(), 17)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 14, 101, 1, ' ', 85, 'Group_Division=''600'' AND CTR_QUALIFIER3=13', 'StringUtils.equals(c.getSegLabel18Lvl0(), "600") && IntegerUtils.equals(c.getCtrqua3Cf(), 13)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 31, 101, 1, ' ', 86, 'LOB=''01'' AND CTR_TYPE=1 AND WORKING_CAT=2 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "01") && IntegerUtils.equals(c.getCtrtypCt(), 1) && IntegerUtils.equals(c.getWrkcatCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 30, 101, 1, ' ', 87, 'LOB=''01'' AND P_NP=''N'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "01") && StringUtils.equals(c.getNatB(), "N") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 29, 101, 1, ' ', 88, 'LOB=''01'' AND P_NP=''P'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "01") && StringUtils.equals(c.getNatB(), "P") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 32, 101, 1, ' ', 89, 'LOB=''01'' AND CTR_TYPE=2 AND FAC_SECTOR=695 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "01") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 695) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 32, 101, 1, ' ', 90, 'LOB=''01'' AND CTR_TYPE=2 AND FAC_SECTOR=999 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "01") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 999) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 22, 101, 1, ' ', 91, 'LOB=''01'' AND CTR_TYPE=2 AND SOB=''25'' AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "01") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSobCf(), "25") && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 21, 101, 1, ' ', 92, 'LOB=''01'' AND CTR_TYPE=2 AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "01") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 12, 101, 1, ' ', 93, 'LOB=''02'' AND CTR_TYPE=1 AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "02") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 12, 101, 1, ' ', 94, 'LOB=''02'' AND CTR_TYPE=2 AND FAC_SECTOR=695 AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "02") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 695) && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 12, 101, 1, ' ', 95, 'LOB=''02'' AND CTR_TYPE=2 AND FAC_SECTOR=698 AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "02") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 698) && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 4, 12, 101, 1, ' ', 96, 'LOB=''03'' AND CTR_TYPE=2 AND FAC_SECTOR=698 AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "03") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 698) && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 23, 101, 1, ' ', 97, 'LOB=''02'' AND CTR_TYPE=2 AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "02") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 30, 101, 1, ' ', 98, 'LOB=''03'' AND P_NP=''N'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "03") && StringUtils.equals(c.getNatB(), "N") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 29, 101, 1, ' ', 99, 'LOB=''03'' AND P_NP=''P'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "03") && StringUtils.equals(c.getNatB(), "P") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 32, 101, 1, ' ', 100, 'LOB=''03'' AND CTR_TYPE=2 AND FAC_SECTOR=695 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "03") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 695) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 4, 32, 101, 1, ' ', 101, 'LOB=''03'' AND CTR_TYPE=2 AND FAC_SECTOR=999 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "03") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 999) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 21, 101, 1, ' ', 102, 'LOB=''03'' AND CTR_TYPE=2 AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "03") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 9, 101, 1, ' ', 103, 'LOB=''04'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "04") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 3, 101, 1, ' ', 104, 'LOB=''10'' AND Group_Division=''600'' AND CTR_QUALIFIER3=18', 'StringUtils.equals(c.getLobCf(), "10") && StringUtils.equals(c.getSegLabel18Lvl0(), "600") && IntegerUtils.equals(c.getCtrqua3Cf(), 18)', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 2, 101, 1, ' ', 105, 'LOB=''05'' AND TOP=''150'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "05") && StringUtils.equals(c.getTopCf(), "150") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 2, 101, 1, ' ', 106, 'LOB=''05'' AND TOP=''151'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "05") && StringUtils.equals(c.getTopCf(), "151") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 2, 101, 1, ' ', 107, 'LOB=''05'' AND TOP=''152'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "05") && StringUtils.equals(c.getTopCf(), "152") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 4, 2, 101, 1, ' ', 108, 'LOB=''05'' AND TOP=''153'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "05") && StringUtils.equals(c.getTopCf(), "153") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 5, 2, 101, 1, ' ', 109, 'LOB=''05'' AND TOP=''154'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "05") && StringUtils.equals(c.getTopCf(), "154") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 6, 2, 101, 1, ' ', 110, 'LOB=''05'' AND TOP=''155'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "05") && StringUtils.equals(c.getTopCf(), "155") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 7, 2, 101, 1, ' ', 111, 'LOB=''05'' AND TOP=''156'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "05") && StringUtils.equals(c.getTopCf(), "156") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 8, 2, 101, 1, ' ', 112, 'LOB=''05'' AND TOP=''157'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "05") && StringUtils.equals(c.getTopCf(), "157") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 9, 2, 101, 1, ' ', 113, 'LOB=''05'' AND TOP=''158'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "05") && StringUtils.equals(c.getTopCf(), "158") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 10, 2, 101, 1, ' ', 114, 'LOB=''05'' AND TOP=''159'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "05") && StringUtils.equals(c.getTopCf(), "159") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 1, 101, 1, ' ', 115, 'LOB=''05'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "05") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 1, 101, 1, ' ', 116, 'LOB=''06'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "06") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 29, 101, 1, ' ', 117, 'LOB=''07'' AND P_NP=''P'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "07") && StringUtils.equals(c.getNatB(), "P") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 30, 101, 1, ' ', 118, 'LOB=''07'' AND P_NP=''N'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "07") && StringUtils.equals(c.getNatB(), "N") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 5, 32, 101, 1, ' ', 119, 'LOB=''07'' AND CTR_TYPE=2 AND FAC_SECTOR=695 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "07") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 695) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 6, 32, 101, 1, ' ', 120, 'LOB=''07'' AND CTR_TYPE=2 AND FAC_SECTOR=999 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "07") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 999) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 21, 101, 1, ' ', 121, 'LOB=''07'' AND CTR_TYPE=2 AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "07") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 19, 101, 1, ' ', 122, 'LOB=''08'' AND CTR_TYPE=1 AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "08") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 28, 101, 1, ' ', 123, 'LOB=''08'' AND CTR_TYPE=2 AND TOP=''275'' AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "08") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getTopCf(), "275") && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 19, 101, 1, ' ', 124, 'LOB=''08'' AND CTR_TYPE=2 AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "08") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 20, 101, 1, ' ', 125, 'LOB=''09'' AND CTR_TYPE=1 AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "09") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 28, 101, 1, ' ', 126, 'LOB=''09'' AND CTR_TYPE=2 AND TOP=''320'' AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "09") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getTopCf(), "320") && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 27, 101, 1, ' ', 127, 'LOB=''09'' AND CTR_TYPE=2 AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "09") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 11, 101, 1, ' ', 128, 'LOB=''10'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "10") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 10, 101, 1, ' ', 129, 'LOB=''11'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "11") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 36, 101, 1, ' ', 130, 'LOB=''12'' AND P_NP=''N'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "12") && StringUtils.equals(c.getNatB(), "N") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 35, 101, 1, ' ', 131, 'LOB=''12'' AND P_NP=''P'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "12") && StringUtils.equals(c.getNatB(), "P") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 38, 101, 1, ' ', 132, 'LOB=''12'' AND CTR_TYPE=2 AND FAC_SECTOR=695 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "12") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 695) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 38, 101, 1, ' ', 133, 'LOB=''12'' AND CTR_TYPE=2 AND FAC_SECTOR=999 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "12") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 999) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 24, 101, 1, ' ', 134, 'LOB=''12'' AND CTR_TYPE=2 AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "12") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 37, 101, 1, ' ', 135, 'LOB=''13'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "13") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 24, 101, 1, ' ', 136, 'LOB=''13'' AND CTR_TYPE=2 AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "13") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 34, 101, 1, ' ', 137, 'LOB=''14'' AND P_NP=''N'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "14") && StringUtils.equals(c.getNatB(), "N") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 33, 101, 1, ' ', 138, 'LOB=''14'' AND P_NP=''P'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "14") && StringUtils.equals(c.getNatB(), "P") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 24, 101, 1, ' ', 139, 'LOB=''14'' AND CTR_TYPE=2 AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "14") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 8, 101, 1, ' ', 140, 'LOB=''15'' AND Group_Division=''600''', 'StringUtils.equals(c.getLobCf(), "15") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 39, 101, 1, ' ', 141, 'LOB=''20'' AND CTR_TYPE=1 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "20") && IntegerUtils.equals(c.getCtrtypCt(), 1) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 13, 101, 1, ' ', 142, 'SUBSIDIARY=1 AND LOB=''20'' AND CTR_TYPE=2 AND TOP=''535'' AND Group_Division=''600''', 'IntegerUtils.equals(c.getSsdCf(), 1) && StringUtils.equals(c.getLobCf(), "20") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getTopCf(), "535") && StringUtils.equals(c.getSegLabel18Lvl0(), "600")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 39, 101, 1, ' ', 143, 'LOB=''20'' AND CTR_TYPE=2 AND FAC_SECTOR=695 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "20") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 695) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 39, 101, 1, ' ', 144, 'LOB=''20'' AND CTR_TYPE=2 AND FAC_SECTOR=999 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "20") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 999) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 4, 21, 101, 1, ' ', 145, 'LOB=''20'' AND CTR_TYPE=2 AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "20") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 40, 101, 1, ' ', 146, 'LOB=''22'' AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "22") && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 2, 40, 101, 1, ' ', 147, 'LOB=''22'' AND CTR_TYPE=2 AND FAC_SECTOR=695 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "22") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 695) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 3, 40, 101, 1, ' ', 148, 'LOB=''22'' AND CTR_TYPE=2 AND FAC_SECTOR=999 AND Group_Division=''200''', 'StringUtils.equals(c.getLobCf(), "22") && IntegerUtils.equals(c.getCtrtypCt(), 2) && IntegerUtils.equals(c.getFacactsctCt(), 999) && StringUtils.equals(c.getSegLabel18Lvl0(), "200")', getDate(),'DBEU',getDate(),'DBEU',null )
INSERT INTO best..tsegmentrule ( SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, RULE_LS, RULPRIO_CT, FUNCDEF_T, TECHDEF_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, timestamp )       VALUES ( 1, 25, 101, 1, ' ', 149, 'LOB=''22'' AND CTR_TYPE=2 AND Group_Division=''100''', 'StringUtils.equals(c.getLobCf(), "22") && IntegerUtils.equals(c.getCtrtypCt(), 2) && StringUtils.equals(c.getSegLabel18Lvl0(), "100")', getDate(),'DBEU',getDate(),'DBEU',null )

-- Update the Rule label with the label of the segment (TSEGMT.SGMT_LS)
UPDATE TSEGMENTRULE SET RULE_LS=SGMT_LS
FROM TSEGMENTRULE, TSEGMT
WHERE TSEGMT.SGT_NT = TSEGMENTRULE.SGT_NT AND TSEGMT.SGTVER_NT = TSEGMENTRULE.SGTVER_NT AND TSEGMENTRULE.SGMT_NF = TSEGMT.SGMT_NF
and TSEGMENTRULE.SGT_NT = 101
go

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,1,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,1,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,1,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,1,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,2,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,2,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,2,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,2,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,2,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,2,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,2,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,2,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,2,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,2,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (4,2,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,2,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,2,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (5,2,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,2,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,2,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (6,2,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,2,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,2,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (7,2,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,2,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,2,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (8,2,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,2,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,2,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (9,2,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,2,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,2,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (10,2,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,3,101,1,'CTR_QUALIFIER3',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,3,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,4,101,1,'CTR_QUALIFIER3',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,4,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,5,101,1,'CTR_QUALIFIER3',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,5,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,6,101,1,'CTR_QUALIFIER3',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,6,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,7,101,1,'CTR_QUALIFIER3',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,7,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,8,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,8,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,9,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,9,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,10,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,10,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,11,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,11,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,12,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,12,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,12,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,12,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,12,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,12,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,12,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,12,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,12,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,12,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,12,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,12,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,12,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,12,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (4,12,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,13,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,13,101,1,'SUBSIDIARY',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,13,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,13,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,13,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,14,101,1,'CTR_QUALIFIER3',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,14,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,15,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,15,101,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,15,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,16,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,16,101,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,16,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,17,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,17,101,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,17,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,18,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,18,101,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,18,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,19,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,19,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,19,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,19,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,19,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,19,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,20,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,20,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,20,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,21,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,21,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,21,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,21,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,21,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,21,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,21,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,21,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,21,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,21,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,21,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (4,21,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,22,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,22,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,22,101,1,'SOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,22,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,23,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,23,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,23,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,24,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,24,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,24,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,24,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,24,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,24,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,24,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,24,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,24,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,25,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,25,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,25,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,26,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,26,101,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,26,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,26,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,26,101,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,26,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,26,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,26,101,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,26,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,26,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,26,101,1,'RI_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (4,26,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,27,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,27,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,27,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,28,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,28,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,28,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,28,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,28,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,28,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,28,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,28,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,29,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,29,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,29,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,29,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,29,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,29,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,29,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,29,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,29,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,29,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,29,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,29,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,30,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,30,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,30,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,30,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,30,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,30,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,30,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,30,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,30,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,30,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,30,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,30,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,31,101,1,'WORKING_CAT',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,31,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,31,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,31,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,32,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,32,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,32,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,32,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,32,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,32,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,32,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,32,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,32,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,32,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,32,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,32,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,32,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,32,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,32,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (4,32,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,32,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,32,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,32,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (5,32,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,32,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,32,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,32,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (6,32,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,33,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,33,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,33,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,33,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,34,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,34,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,34,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,34,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,35,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,35,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,35,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,35,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,36,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,36,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,36,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,36,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,37,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,37,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,37,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,38,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,38,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,38,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,38,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,38,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,38,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,38,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,38,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,39,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,39,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,39,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,39,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,39,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,39,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,39,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,39,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,39,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,39,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,39,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,40,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,40,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,40,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,40,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,40,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,40,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,40,101,1,'CTR_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,40,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,40,101,1,'FAC_SECTOR',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,40,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (4,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (5,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (6,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (7,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (8,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (9,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (10,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (11,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (11,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (11,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (11,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (11,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (12,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (12,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (12,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (12,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (12,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (13,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (13,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (13,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (13,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (13,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (14,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (14,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (14,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (14,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (14,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (15,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (15,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (15,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (15,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (15,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (16,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (16,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (16,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (16,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (16,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (17,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (17,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (17,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (17,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (17,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (18,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (18,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (18,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (18,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (18,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (19,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (19,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (19,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (19,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (19,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (20,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (20,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (20,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (20,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (20,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (21,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (21,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (21,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (21,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (21,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (22,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (22,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (22,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (22,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (22,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (23,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (23,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (23,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (23,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (23,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (24,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (24,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (24,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (24,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (24,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (25,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (25,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (25,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (25,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (25,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (26,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (26,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (26,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (26,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (26,41,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (27,41,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (27,41,101,1,'TOP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (27,41,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (27,41,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (27,41,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,42,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,42,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,42,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,42,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,42,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,42,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,42,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,42,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,42,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,42,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,42,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,42,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,42,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,42,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,42,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (4,42,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,42,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,42,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,42,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (5,42,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,42,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,42,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,42,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (6,42,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,42,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,42,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,42,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (7,42,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,42,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,42,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,42,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (8,42,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,42,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,42,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,42,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (9,42,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,42,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,42,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (10,42,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (10,42,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (11,42,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (11,42,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (11,42,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (11,42,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,43,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,43,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,43,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,43,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,43,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,43,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,43,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,43,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,43,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,43,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,43,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,43,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,44,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,44,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,44,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,44,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,44,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,44,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,44,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,44,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,44,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,44,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,44,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,44,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,44,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,44,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,44,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (4,44,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,44,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,44,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,44,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (5,44,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,44,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,44,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,44,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (6,44,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,44,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,44,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (7,44,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (7,44,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,44,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,44,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (8,44,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (8,44,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,44,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,44,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (9,44,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (9,44,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,45,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,45,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,45,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,45,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,45,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,45,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,45,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,45,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,46,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,46,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,46,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,46,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,46,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,46,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,46,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,46,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,46,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,46,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,46,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,46,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,46,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,46,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,46,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (4,46,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,47,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,47,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,47,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,47,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,47,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,47,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,47,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,47,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,48,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,48,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,48,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,48,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,48,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,48,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,48,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,48,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,49,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,49,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,49,101,1,'GUARANTEE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,49,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,50,101,1,'P_NP',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,50,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,51,101,1,'LIFE_TREATY_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,51,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,52,101,1,'SOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,52,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,52,101,1,'LIFE_TREATY_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,52,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (3,52,101,1,'LIFE_TREATY_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (3,52,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (4,52,101,1,'LIFE_TREATY_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (4,52,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (5,52,101,1,'LIFE_TREATY_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (5,52,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (6,52,101,1,'LIFE_TREATY_TYPE',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (6,52,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,53,101,1,'SEC_IFRS',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,53,101,1,18,getDate(),'DBEU')
go


insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (1,54,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (1,54,101,1,18,getDate(),'DBEU')

insert into TSEGMENTRULE2CRI (SGTRULE_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTCRI_CF, CRE_D, CREUSR_CF) values (2,54,101,1,'LOB',getDate(),'DBEU')
insert into TSEGMENTRULE2TYPE (SGTRUL_NT, SGMT_NF, SGT_NT, SGTVER_NT, SGTTYP_NT, CRE_D, CREUSR_CF) values (2,54,101,1,18,getDate(),'DBEU')
go
