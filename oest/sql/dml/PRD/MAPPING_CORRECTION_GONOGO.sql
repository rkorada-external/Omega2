-- [001] 21/01/2021 : R.CAssis: SPIRA 91531 Correction de la planification POST OMEGA

USE BEST
go

-------------------------------
--	Init  ESPJ0090
-------------------------------

	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPJ0090')  insert into BEST..TI17CHN values ('ESPJ0090',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPJ0090'  ) insert into BEST..TI17FNC values ('EBS_ESPJ0090',  'IFRS4 Post omega  EBS')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPJ0090'  ) insert into BEST..TI17FNC values ('I4I_ESPJ0090',  'IFRS4 Post omega  IFRS')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT = 'ESPJ0090'

	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPJ0090','EBS_ESPJ0090','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPJ0090','EBS_ESPJ0090','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPJ0090','EBS_ESPJ0090','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPJ0090','EBS_ESPJ0090','')

	insert into BEST..TI17REQCHN values ('I4IQPOC',  'ESPJ0090','I4I_ESPJ0090','')
	insert into BEST..TI17REQCHN values ('I4IQPOCB',  'ESPJ0090','I4I_ESPJ0090','')
	insert into BEST..TI17REQCHN values ('I4IQPOS',  'ESPJ0090','I4I_ESPJ0090','')
	insert into BEST..TI17REQCHN values ('I4IQPOSB',  'ESPJ0090','I4I_ESPJ0090','')
	insert into BEST..TI17REQCHN values ('I4IYPOC',  'ESPJ0090','I4I_ESPJ0090','')
	insert into BEST..TI17REQCHN values ('I4IYPOCB',  'ESPJ0090','I4I_ESPJ0090','')
	insert into BEST..TI17REQCHN values ('I4IYPOS',  'ESPJ0090','I4I_ESPJ0090','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',  'ESPJ0090','I4I_ESPJ0090','')
go

-------------------------------
--	Init  ESPD0060
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD0060')  insert into BEST..TI17CHN values ('ESPD0060',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD0060'  ) insert into BEST..TI17FNC values ('EBS_ESPD0060',  '')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD0060'  ) insert into BEST..TI17FNC values ('I4I_ESPD0060',  '')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='ESPD0060'
	
	insert into BEST..TI17REQCHN values ('EBSEMINV',  'ESPD0060','EBS_ESPD0060','')
	insert into BEST..TI17REQCHN values ('EBSEMINVB', 'ESPD0060','EBS_ESPD0060','')
	insert into BEST..TI17REQCHN values ('EBSEQINV',  'ESPD0060','EBS_ESPD0060','')
	insert into BEST..TI17REQCHN values ('EBSEQINVB', 'ESPD0060','EBS_ESPD0060','')
	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPD0060','EBS_ESPD0060','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD0060','EBS_ESPD0060','')
	insert into BEST..TI17REQCHN values ('EBSEYINV',  'ESPD0060','EBS_ESPD0060','')
	insert into BEST..TI17REQCHN values ('EBSEYINVB', 'ESPD0060','EBS_ESPD0060','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPD0060','EBS_ESPD0060','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD0060','EBS_ESPD0060','')
	
	insert into BEST..TI17REQCHN values ('I4IQPOC',   'ESPD0060','I4I_ESPD0060','')
	insert into BEST..TI17REQCHN values ('I4IQPOCB',   'ESPD0060','I4I_ESPD0060','')
	insert into BEST..TI17REQCHN values ('I4IQPOS',   'ESPD0060','I4I_ESPD0060','')
	insert into BEST..TI17REQCHN values ('I4IQPOSB',   'ESPD0060','I4I_ESPD0060','')
	insert into BEST..TI17REQCHN values ('I4IYPOC',   'ESPD0060','I4I_ESPD0060','')
	insert into BEST..TI17REQCHN values ('I4IYPOCB',   'ESPD0060','I4I_ESPD0060','')
	insert into BEST..TI17REQCHN values ('I4IYPOS',   'ESPD0060','I4I_ESPD0060','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',   'ESPD0060','I4I_ESPD0060','')
go

-------------------------------
--	Init  ESPD1800
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD1800')  insert into BEST..TI17CHN values ('ESPD1800',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD1800'  ) insert into BEST..TI17FNC values ('EBS_ESPD1800',  '')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD1800'  ) insert into BEST..TI17FNC values ('I4I_ESPD1800',  '')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where     CHAIN_CT='ESPD1800'

	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPD1800','EBS_ESPD1800','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD1800','EBS_ESPD1800','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPD1800','EBS_ESPD1800','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD1800','EBS_ESPD1800','')

	insert into BEST..TI17REQCHN values ('I4IQPOC',  'ESPD1800','I4I_ESPD1800','')
	insert into BEST..TI17REQCHN values ('I4IQPOCB',  'ESPD1800','I4I_ESPD1800','')
	insert into BEST..TI17REQCHN values ('I4IQPOS',  'ESPD1800','I4I_ESPD1800','')
	insert into BEST..TI17REQCHN values ('I4IQPOSB',  'ESPD1800','I4I_ESPD1800','')
	insert into BEST..TI17REQCHN values ('I4IYPOC',  'ESPD1800','I4I_ESPD1800','')
	insert into BEST..TI17REQCHN values ('I4IYPOCB',  'ESPD1800','I4I_ESPD1800','')
	insert into BEST..TI17REQCHN values ('I4IYPOS',  'ESPD1800','I4I_ESPD1800','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',  'ESPD1800','I4I_ESPD1800','')
go

-------------------------------
--	Init  ESID2210
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESID2210')  insert into BEST..TI17CHN values ('ESID2210',  'IFRS Losses and IBNR calculation')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESID2210'  ) insert into BEST..TI17FNC values ('EBS_ESID2210',  'IFRS4 Post omega  EBS')

	----------   Reqs of chain   ---------------------


	delete BEST..TI17REQCHN where     CHAIN_CT='ESID2210'	

	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESID2210','EBS_ESID2210','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESID2210','EBS_ESID2210','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESID2210','EBS_ESID2210','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESID2210','EBS_ESID2210','')

go

-------------------------------
--	Init  ESPD4000
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD4000')  insert into BEST..TI17CHN values ('ESPD4000',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD4000'  ) insert into BEST..TI17FNC values ('EBS_ESPD4000',  '')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD4000'  ) insert into BEST..TI17FNC values ('I4I_ESPD4000',  '')

	----------   Reqs of chain   ---------------------


	delete BEST..TI17REQCHN where    CHAIN_CT = 'ESPD4000'

	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPD4000','EBS_ESPD4000','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD4000','EBS_ESPD4000','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPD4000','EBS_ESPD4000','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD4000','EBS_ESPD4000','')

	insert into BEST..TI17REQCHN values ('I4IQPOC',  'ESPD4000','I4I_ESPD4000','')
	insert into BEST..TI17REQCHN values ('I4IQPOCB',  'ESPD4000','I4I_ESPD4000','')
	insert into BEST..TI17REQCHN values ('I4IQPOS',  'ESPD4000','I4I_ESPD4000','')
	insert into BEST..TI17REQCHN values ('I4IQPOSB',  'ESPD4000','I4I_ESPD4000','')
	insert into BEST..TI17REQCHN values ('I4IYPOC',  'ESPD4000','I4I_ESPD4000','')
	insert into BEST..TI17REQCHN values ('I4IYPOCB',  'ESPD4000','I4I_ESPD4000','')
	insert into BEST..TI17REQCHN values ('I4IYPOS',  'ESPD4000','I4I_ESPD4000','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',  'ESPD4000','I4I_ESPD4000','')
go

-------------------------------
--	Init  ESFD2220
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD2220')  insert into BEST..TI17CHN values ('ESFD2220',  'Future at inception')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD2220'  ) insert into BEST..TI17FNC values ('EBS_ESFD2220',  'IFRS4 Post omega  EBS')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_FUT_ALL_INI'  ) insert into BEST..TI17FNC values ('I17G_FUT_ALL_INI',  'Future at inception')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD2220___AA0'  ) insert into BEST..TI17FNC values ('EBS_ESFD2220___AA0',  'Micro AOC Future Assumed AA0')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD2220___AA1'  ) insert into BEST..TI17FNC values ('EBS_ESFD2220___AA1',  'Micro AOC Future Assumed AA1')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD2220___AA2'  ) insert into BEST..TI17FNC values ('EBS_ESFD2220___AA2',  'Micro AOC Future Assumed AA2')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD2220___AA3'  ) insert into BEST..TI17FNC values ('EBS_ESFD2220___AA3',  'Micro AOC Future Assumed AA3')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='ESFD2220'

	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESFD2220','EBS_ESFD2220','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESFD2220','EBS_ESFD2220','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESFD2220','EBS_ESFD2220','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESFD2220','EBS_ESFD2220','')

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD2220'

	insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD2220','I17G_FUT_ALL_INI','')
	insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD2220','I17G_FUT_ALL_INI','')
	insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD2220','I17G_FUT_ALL_INI','')
	insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD2220','I17G_FUT_ALL_INI','')
	insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD2220','I17G_FUT_ALL_INI','')
	insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD2220','I17G_FUT_ALL_INI','')
	insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD2220','I17G_FUT_ALL_INI','')
	insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD2220','I17G_FUT_ALL_INI','')
	insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD2220','I17G_FUT_ALL_INI','')
	insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD2220','I17G_FUT_ALL_INI','')

		--  microAOC

	delete BEST..TI17REQCHN where   IDF_CT in ( 'EBS_ESFD2220___AA0','AA0_FUTR_LR') and  CHAIN_CT='ESFD2220'

	insert into BEST..TI17REQCHN values ('POSO',  'ESFD2220','EBS_ESFD2220___AA0','POSO')
	insert into BEST..TI17REQCHN values ('POCO',  'ESFD2220','EBS_ESFD2220___AA0','POCO')
	insert into BEST..TI17REQCHN values ('INVO',  'ESFD2220','EBS_ESFD2220___AA0','INVO')

	delete BEST..TI17REQCHN where   IDF_CT in ( 'EBS_ESFD2220___AA1') and  CHAIN_CT='ESFD2220'

	insert into BEST..TI17REQCHN values ('POSO',  'ESFD2220','EBS_ESFD2220___AA1','POSO')
	insert into BEST..TI17REQCHN values ('POCO',  'ESFD2220','EBS_ESFD2220___AA1','POCO')
	insert into BEST..TI17REQCHN values ('INVO',  'ESFD2220','EBS_ESFD2220___AA1','INVO')

	delete BEST..TI17REQCHN where   IDF_CT in ( 'EBS_ESFD2220___AA2') and  CHAIN_CT='ESFD2220'

	insert into BEST..TI17REQCHN values ('POSO',  'ESFD2220','EBS_ESFD2220___AA2','POSO')
	insert into BEST..TI17REQCHN values ('POCO',  'ESFD2220','EBS_ESFD2220___AA2','POCO')
	insert into BEST..TI17REQCHN values ('INVO',  'ESFD2220','EBS_ESFD2220___AA2','INVO')

	delete BEST..TI17REQCHN where   IDF_CT in ( 'EBS_ESFD2220___AA3') and  CHAIN_CT='ESFD2220'

	insert into BEST..TI17REQCHN values ('POSO',  'ESFD2220','EBS_ESFD2220___AA3','POSO')
	insert into BEST..TI17REQCHN values ('POCO',  'ESFD2220','EBS_ESFD2220___AA3','POCO')
	insert into BEST..TI17REQCHN values ('INVO',  'ESFD2220','EBS_ESFD2220___AA3','INVO')
go

-------------------------------
--	Init  ESPD2570
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD2570')  insert into BEST..TI17CHN values ('ESPD2570',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD2570'  ) insert into BEST..TI17FNC values ('EBS_ESPD2570',  'IFRS4 Post omega  EBS')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT = 'ESPD2570' and IDF_CT not in ('EBS_ESPD2570___AA0' , 'AA0_FUTR_LR_NP') 

	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPD2570','EBS_ESPD2570','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD2570','EBS_ESPD2570','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPD2570','EBS_ESPD2570','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD2570','EBS_ESPD2570','')
go

-------------------------------
--	Init  ESPD2550
-------------------------------


  if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD2550')  insert into BEST..TI17CHN values ('ESPD2550',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD2550'  ) insert into BEST..TI17FNC values ('EBS_ESPD2550',  'IFRS4 Post omega  EBS')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD2550'  ) insert into BEST..TI17FNC values ('I4I_ESPD2550',  'IFRS4 Post omega  IFRS')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT = 'ESPD2550'

	insert into BEST..TI17REQCHN values ('EBSEMINV',  'ESPD2550','EBS_ESPD2550','')
	insert into BEST..TI17REQCHN values ('EBSEMINVB', 'ESPD2550','EBS_ESPD2550','')
	insert into BEST..TI17REQCHN values ('EBSEQINV',  'ESPD2550','EBS_ESPD2550','')
	insert into BEST..TI17REQCHN values ('EBSEQINVB', 'ESPD2550','EBS_ESPD2550','')
	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPD2550','EBS_ESPD2550','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD2550','EBS_ESPD2550','')
	insert into BEST..TI17REQCHN values ('EBSEYINV',  'ESPD2550','EBS_ESPD2550','')
	insert into BEST..TI17REQCHN values ('EBSEYINVB', 'ESPD2550','EBS_ESPD2550','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPD2550','EBS_ESPD2550','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD2550','EBS_ESPD2550','')
	
	insert into BEST..TI17REQCHN values ('I4IQPOC',   'ESPD2550','I4I_ESPD2550','')
	insert into BEST..TI17REQCHN values ('I4IQPOCB',   'ESPD2550','I4I_ESPD2550','')
	insert into BEST..TI17REQCHN values ('I4IQPOS',   'ESPD2550','I4I_ESPD2550','')
	insert into BEST..TI17REQCHN values ('I4IQPOSB',   'ESPD2550','I4I_ESPD2550','')
	insert into BEST..TI17REQCHN values ('I4IYPOC',   'ESPD2550','I4I_ESPD2550','')
	insert into BEST..TI17REQCHN values ('I4IYPOCB',   'ESPD2550','I4I_ESPD2550','')
	insert into BEST..TI17REQCHN values ('I4IYPOS',   'ESPD2550','I4I_ESPD2550','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',   'ESPD2550','I4I_ESPD2550','')
go

-------------------------------
--	Init  ESPD3610
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3610')  insert into BEST..TI17CHN values ('ESPD3610',  'Cach flow calculation jobs ESID3702A et ESID3703A')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD3610'  ) insert into BEST..TI17FNC values ('EBS_ESPD3610',  'Post omega EBS')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='AAX_ESPD3610'  ) insert into BEST..TI17FNC values ('AAX_ESPD3610',  'MicroAOC Cashflow AA0')

  ---------- micro AOC AAX_ESPD3610

	delete BEST..TI17PERMFIL where IDF_CT ='AAX_ESPD3610'

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'EBS_ESPD3610' and  CHAIN_CT='ESPD3610'

	insert into BEST..TI17REQCHN values ('EBSEMINVB','ESPD3610','EBS_ESPD3610','Monthly INV EBS booking')
	insert into BEST..TI17REQCHN values ('EBSEQINV','ESPD3610','EBS_ESPD3610','Quarterly INV EBS')
	insert into BEST..TI17REQCHN values ('EBSEQINVB','ESPD3610','EBS_ESPD3610','Quarterly INV EBS booking')
	insert into BEST..TI17REQCHN values ('EBSEQPOS','ESPD3610','EBS_ESPD3610','Quarterly POS EBS')
	insert into BEST..TI17REQCHN values ('EBSEQPOC','ESPD3610','EBS_ESPD3610','Quarterly POC EBS')
	insert into BEST..TI17REQCHN values ('EBSEYINV','ESPD3610','EBS_ESPD3610','Annual INV EBS')
	insert into BEST..TI17REQCHN values ('EBSEYINVB','ESPD3610','EBS_ESPD3610','Annual INV EBS booking')
	insert into BEST..TI17REQCHN values ('EBSEYPOS','ESPD3610','EBS_ESPD3610','Annual POS EBS')
	insert into BEST..TI17REQCHN values ('EBSEYPOC','ESPD3610','EBS_ESPD3610','Annual POC EBS')

	insert into BEST..TI17REQCHN values ('POSO',  'ESPD3610','AAX_ESPD3610','AAX_ESPD3610')
	insert into BEST..TI17REQCHN values ('POCO',  'ESPD3610','AAX_ESPD3610','AAX_ESPD3610')
go
	
-------------------------------
--	Init  ESFD4020
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD4020')  insert into BEST..TI17CHN values ('ESFD4020',  'ITD FILE AND QUATERLY FILES')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD4020'  ) insert into BEST..TI17FNC values ('EBS_ESFD4020',  'IFRS4 Post omega  EBS')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESFD4020_POCE'  ) insert into BEST..TI17FNC values ('ESFD4020_POCE',  'IFRS4 Post omega conso EBS')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESFD4020_POSE'  ) insert into BEST..TI17FNC values ('ESFD4020_POSE',  'IFRS4 Post omega social EBS')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'ESFD4020_POCE' and  CHAIN_CT='ESFD4020'
	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESFD4020','EBS_ESFD4020','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESFD4020','EBS_ESFD4020','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESFD4020','EBS_ESFD4020','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESFD4020','EBS_ESFD4020','')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	insert into BEST..TI17REQCHN values ('POCE',  'ESFD4020','ESFD4020_POCE','POCE')
	insert into BEST..TI17REQCHN values ('POSE',  'ESFD4020','ESFD4020_POSE','POSE')
go

-------------------------------
--	Init  ESFD3620     pas fait
-------------------------------


go

-------------------------------
--	Init  ESPD3620
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3620')  insert into BEST..TI17CHN values ('ESPD3620',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD3620'  ) insert into BEST..TI17FNC values ('EBS_ESPD3620',  'IFRS4 Post omega  EBS')


	----------   Reqs of chain   ---------------------
	delete BEST..TI17REQCHN where   CHAIN_CT = 'ESPD3620'
	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPD3620','EBS_ESPD3620','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD3620','EBS_ESPD3620','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPD3620','EBS_ESPD3620','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD3620','EBS_ESPD3620','')
go

-------------------------------
--	Init  ESPD3630 
-------------------------------

	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3630')  insert into BEST..TI17CHN values ('ESPD3630',  'UPR cancellation chain ESPD3630')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD3630'  ) insert into BEST..TI17FNC values ('EBS_ESPD3630',  'Post omega EBS')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='ESPD3630'
	insert into BEST..TI17REQCHN values ('EBSEMINVB','ESPD3630','EBS_ESPD3630','Monthly INV EBS booking')
	insert into BEST..TI17REQCHN values ('EBSEQINV','ESPD3630','EBS_ESPD3630','Quarterly INV EBS')
	insert into BEST..TI17REQCHN values ('EBSEQINVB','ESPD3630','EBS_ESPD3630','Quarterly INV EBS booking')
	insert into BEST..TI17REQCHN values ('EBSEQPOS','ESPD3630','EBS_ESPD3630','Quarterly POS EBS')
	insert into BEST..TI17REQCHN values ('EBSEQPOC','ESPD3630','EBS_ESPD3630','	Quarterly POC EBS')
	insert into BEST..TI17REQCHN values ('EBSEYINV','ESPD3630','EBS_ESPD3630','Annual INV EBS')
	insert into BEST..TI17REQCHN values ('EBSEYINVB','ESPD3630','EBS_ESPD3630','Annual INV EBS booking')
	insert into BEST..TI17REQCHN values ('EBSEYPOS','ESPD3630','EBS_ESPD3630','Annual POS EBS')
	insert into BEST..TI17REQCHN values ('EBSEYPOC','ESPD3630','EBS_ESPD3630','Annual POC EBS')
go

-------------------------------
--	Init  ESPD3640
-------------------------------

	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3640')  insert into BEST..TI17CHN values ('ESPD3640',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD3640'  ) insert into BEST..TI17FNC values ('EBS_ESPD3640',  'IFRS4 Post omega  EBS')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT = 'ESPD3640'
	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPD3640','EBS_ESPD3640','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD3640','EBS_ESPD3640','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPD3640','EBS_ESPD3640','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD3640','EBS_ESPD3640','')
go

-------------------------------
--	Init  ESPD3710
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3710')  insert into BEST..TI17CHN values ('ESPD3710',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD3710'  ) insert into BEST..TI17FNC values ('EBS_ESPD3710',  '')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'EBS_ESPD3710' and  CHAIN_CT='ESPD3710'
	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPD3710','EBS_ESPD3710','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD3710','EBS_ESPD3710','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPD3710','EBS_ESPD3710','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD3710','EBS_ESPD3710','')
go

-------------------------------
--	Init  ESPD8000
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8000')  insert into BEST..TI17CHN values ('ESPD8000',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD8000'  ) insert into BEST..TI17FNC values ('EBS_ESPD8000',  'IFRS4 Post omega  EBS')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT = 'ESPD8000'
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD8000','EBS_ESPD8000','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD8000','EBS_ESPD8000','')
go

-------------------------------
--	Init  ESPD2050
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD2050')  insert into BEST..TI17CHN values ('ESPD2050',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD2050'  ) insert into BEST..TI17FNC values ('EBS_ESPD2050',  'IFRS4 Post omega  EBS')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD2050'  ) insert into BEST..TI17FNC values ('I4I_ESPD2050',  'IFRS4 Post omega  IFRS')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where    CHAIN_CT='ESPD2050'
	insert into BEST..TI17REQCHN values ('EBSEMINV',  'ESPD2050','EBS_ESPD2050','')
	insert into BEST..TI17REQCHN values ('EBSEMINVB', 'ESPD2050','EBS_ESPD2050','')
	insert into BEST..TI17REQCHN values ('EBSEQINV',  'ESPD2050','EBS_ESPD2050','')
	insert into BEST..TI17REQCHN values ('EBSEQINVB', 'ESPD2050','EBS_ESPD2050','')
	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPD2050','EBS_ESPD2050','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD2050','EBS_ESPD2050','')
	insert into BEST..TI17REQCHN values ('EBSEYINV',  'ESPD2050','EBS_ESPD2050','')
	insert into BEST..TI17REQCHN values ('EBSEYINVB', 'ESPD2050','EBS_ESPD2050','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPD2050','EBS_ESPD2050','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD2050','EBS_ESPD2050','')
	
	insert into BEST..TI17REQCHN values ('I4IQPOC',   'ESPD2050','I4I_ESPD2050','')
	insert into BEST..TI17REQCHN values ('I4IQPOCB',   'ESPD2050','I4I_ESPD2050','')
	insert into BEST..TI17REQCHN values ('I4IQPOS',   'ESPD2050','I4I_ESPD2050','')
	insert into BEST..TI17REQCHN values ('I4IQPOSB',   'ESPD2050','I4I_ESPD2050','')
	insert into BEST..TI17REQCHN values ('I4IYPOC',   'ESPD2050','I4I_ESPD2050','')
	insert into BEST..TI17REQCHN values ('I4IYPOCB',   'ESPD2050','I4I_ESPD2050','')
	insert into BEST..TI17REQCHN values ('I4IYPOS',   'ESPD2050','I4I_ESPD2050','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',   'ESPD2050','I4I_ESPD2050','')
go

-------------------------------
--	Init  ESPD8600
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8600')  insert into BEST..TI17CHN values ('ESPD8600',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD8600'  ) insert into BEST..TI17FNC values ('EBS_ESPD8600',  '')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where  CHAIN_CT='ESPD8600'
	insert into BEST..TI17REQCHN values ('EBSEQPOC',   'ESPD8600','EBS_ESPD8600','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',   'ESPD8600','EBS_ESPD8600','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',   'ESPD8600','EBS_ESPD8600','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',   'ESPD8600','EBS_ESPD8600','')
go

-------------------------------
--	Init  ESPD3800
-------------------------------

	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3800')  insert into BEST..TI17CHN values ('ESPD3800',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD3800'  ) insert into BEST..TI17FNC values ('EBS_ESPD3800',  'IFRS4 Post omega  EBS')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD3800'  ) insert into BEST..TI17FNC values ('I4I_ESPD3800',  'IFRS4 Post omega  IFRS')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT = 'ESPD3800'
	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPD3800','EBS_ESPD3800','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD3800','EBS_ESPD3800','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPD3800','EBS_ESPD3800','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD3800','EBS_ESPD3800','')

	insert into BEST..TI17REQCHN values ('I4IQPOC',  'ESPD3800','I4I_ESPD3800','')
	insert into BEST..TI17REQCHN values ('I4IQPOCB',  'ESPD3800','I4I_ESPD3800','')
	insert into BEST..TI17REQCHN values ('I4IQPOS',  'ESPD3800','I4I_ESPD3800','')
	insert into BEST..TI17REQCHN values ('I4IQPOSB',  'ESPD3800','I4I_ESPD3800','')
	insert into BEST..TI17REQCHN values ('I4IYPOC',  'ESPD3800','I4I_ESPD3800','')
	insert into BEST..TI17REQCHN values ('I4IYPOCB',  'ESPD3800','I4I_ESPD3800','')
	insert into BEST..TI17REQCHN values ('I4IYPOS',  'ESPD3800','I4I_ESPD3800','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',  'ESPD3800','I4I_ESPD3800','')
go

-------------------------------
--	Init  ESPD3900
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3900')  insert into BEST..TI17CHN values ('ESPD3900',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD3900'  ) insert into BEST..TI17FNC values ('EBS_ESPD3900',  '')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD3900'  ) insert into BEST..TI17FNC values ('I4I_ESPD3900',  '')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where    CHAIN_CT = 'ESPD3900'
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD3900','EBS_ESPD3900','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD3900','EBS_ESPD3900','')

	insert into BEST..TI17REQCHN values ('I4IQPOS',  'ESPD3900','I4I_ESPD3900','')
	insert into BEST..TI17REQCHN values ('I4IQPOSB',  'ESPD3900','I4I_ESPD3900','')
	insert into BEST..TI17REQCHN values ('I4IYPOS',  'ESPD3900','I4I_ESPD3900','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',  'ESPD3900','I4I_ESPD3900','')
go

-------------------------------
--	Init  ESPD2900
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD2900')  insert into BEST..TI17CHN values ('ESPD2900',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD2900'  ) insert into BEST..TI17FNC values ('EBS_ESPD2900',  'Annual EBS opening')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD2900'  ) insert into BEST..TI17FNC values ('I4I_ESPD2900',  'Annual I4I opening')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESPD2900'  ) insert into BEST..TI17FNC values ('ESPD2900',  '')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where    CHAIN_CT = 'ESPD2900'
	insert into BEST..TI17REQCHN values ('EBSEYPOSB',  'ESPD2900','EBS_ESPD2900','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',  'ESPD2900','I4I_ESPD2900','')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	insert into BEST..TI17REQCHN values ('ESPD2900',  'ESPD2900','ESPD2900','')
go

-------------------------------
--	Init  ESPD8900 
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8900')  insert into BEST..TI17CHN values ('ESPD8900',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD8900'  ) insert into BEST..TI17FNC values ('EBS_ESPD8900',  '')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD8900'  ) insert into BEST..TI17FNC values ('I4I_ESPD8900',  '')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where    CHAIN_CT = 'ESPD8900'
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD8900','EBS_ESPD8900','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD8900','EBS_ESPD8900','')

	insert into BEST..TI17REQCHN values ('I4IQPOS',  'ESPD8900','I4I_ESPD8900','')
	insert into BEST..TI17REQCHN values ('I4IQPOSB',  'ESPD8900','I4I_ESPD8900','')
	insert into BEST..TI17REQCHN values ('I4IYPOS',  'ESPD8900','I4I_ESPD8900','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',  'ESPD8900','I4I_ESPD8900','')
go

-------------------------------
--	Init  ESPD3810
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3810')  insert into BEST..TI17CHN values ('ESPD3810',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD3810'  ) insert into BEST..TI17FNC values ('EBS_ESPD3810',  'IFRS4 Post omega  EBS')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD3810'  ) insert into BEST..TI17FNC values ('I4I_ESPD3810',  'IFRS4 Post omega  IFRS')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT = 'ESPD3810'
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD3810','EBS_ESPD3810','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD3810','EBS_ESPD3810','')

	insert into BEST..TI17REQCHN values ('I4IQPOS',  'ESPD3810','I4I_ESPD3810','')
	insert into BEST..TI17REQCHN values ('I4IQPOSB',  'ESPD3810','I4I_ESPD3810','')
	insert into BEST..TI17REQCHN values ('I4IYPOS',  'ESPD3810','I4I_ESPD3810','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',  'ESPD3810','I4I_ESPD3810','')
go

-------------------------------
--	Init  ESPD3910
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3910')  insert into BEST..TI17CHN values ('ESPD3910',  'Split GLT EBS Common before  SAP Posting')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD3910'  ) insert into BEST..TI17FNC values ('EBS_ESPD3910',  'Split GLT EBS Common before  SAP Posting')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='ESPD3910'
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD3910','EBS_ESPD3910','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD3910','EBS_ESPD3910','')
go

-------------------------------
--	Init  ESFD3850
-------------------------------

	
	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3850')  insert into BEST..TI17CHN values ('ESFD3850',  'Send GLT Movement EBS and IFRS17 to SAP')
	
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_OMG_SAP_STD'  ) insert into BEST..TI17FNC values ('I17G_OMG_SAP_STD',  'Send GLT Movement EBS and IFRS17 to SAP')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_OMG_SAP_STD'  ) insert into BEST..TI17FNC values ('I17L_OMG_SAP_STD',  'Send GLT Movement EBS and IFRS17 to SAP')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_OMG_SAP_STD'  ) insert into BEST..TI17FNC values ('I17P_OMG_SAP_STD',  'Send GLT Movement EBS and IFRS17 to SAP')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_OMG_SAP_STD'  ) insert into BEST..TI17FNC values ('EBS_OMG_SAP_STD',  'Send GLT Movement EBS and IFRS17 to SAP')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD3850'  ) insert into BEST..TI17FNC values ('EBS_ESFD3850',  'Send GLT Movement EBS and IFRS17 to SAP')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESFD3850_POSE'  ) insert into BEST..TI17FNC values ('ESFD3850_POSE',  'Send GLT Movement EBS and IFRS17 to SAP')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESFD3850_POCE'  ) insert into BEST..TI17FNC values ('ESFD3850_POCE',  'Send GLT Movement EBS and IFRS17 to SAP')

	
	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='ESFD3850'
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_OMG_SAP_STD' and  CHAIN_CT='ESFD3850'
	insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3850','I17G_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3850','I17G_OMG_SAP_STD','')

	delete BEST..TI17REQCHN where   IDF_CT = 'I17L_OMG_SAP_STD' and  CHAIN_CT='ESFD3850'
	insert into BEST..TI17REQCHN values ('I17LMINV',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LMINVB',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LQINV',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LQINVB',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LQPOC',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LQPOCB',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LQPOS',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LQPOSB',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LYINV',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LYINVB',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LYPOC',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LYPOCB',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LYPOS',  'ESFD3850','I17L_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17LYPOSB',  'ESFD3850','I17L_OMG_SAP_STD','')

	delete BEST..TI17REQCHN where   IDF_CT = 'I17P_OMG_SAP_STD' and  CHAIN_CT='ESFD3850'
	insert into BEST..TI17REQCHN values ('I17PMINV',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PMINVB',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PQINV',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PQINVB',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PQPOC',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PQPOCB',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PQPOS',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PQPOSB',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PYINV',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PYINVB',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PYPOC',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PYPOCB',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PYPOS',  'ESFD3850','I17P_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('I17PYPOSB',  'ESFD3850','I17P_OMG_SAP_STD','')	

	delete BEST..TI17REQCHN where   IDF_CT = 'EBS_OMG_SAP_STD' and  CHAIN_CT='ESFD3850'
	insert into BEST..TI17REQCHN values ('EBSEMINV',  'ESFD3850','EBS_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('EBSEMINVB',  'ESFD3850','EBS_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQINV',  'ESFD3850','EBS_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQINVB',  'ESFD3850','EBS_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESFD3850','EBS_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESFD3850','EBS_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYINV',  'ESFD3850','EBS_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYINVB',  'ESFD3850','EBS_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESFD3850','EBS_OMG_SAP_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESFD3850','EBS_OMG_SAP_STD','')

	delete BEST..TI17REQCHN where   IDF_CT = 'EBS_ESFD3850' and  CHAIN_CT='ESFD3850'
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESFD3850','EBS_ESFD3850','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESFD3850','EBS_ESFD3850','')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	insert into BEST..TI17REQCHN values ('POCE',  'ESFD3850','ESFD3850_POCE','POCE')
	insert into BEST..TI17REQCHN values ('POSE',  'ESFD3850','ESFD3850_POSE','POSE')
go

-------------------------------
--	Init  ESFD3960
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3960')  insert into BEST..TI17CHN values ('ESFD3960',  'Integrate SAP file feedback to Omega')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_SAP_OMG_STD'  ) insert into BEST..TI17FNC values ('I17G_SAP_OMG_STD',  'Integrate SAP file feedback to Omega')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_SAP_OMG_STD'  ) insert into BEST..TI17FNC values ('I17L_SAP_OMG_STD',  'Integrate SAP file feedback to Omega')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_SAP_OMG_STD'  ) insert into BEST..TI17FNC values ('I17P_SAP_OMG_STD',  'Integrate SAP file feedback to Omega')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_SAP_OMG_STD'  ) insert into BEST..TI17FNC values ('EBS_SAP_OMG_STD',  'Integrate SAP file feedback to Omega')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD3960'  ) insert into BEST..TI17FNC values ('EBS_ESFD3960',  'Integrate SAP file feedback to Omega')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESFD3960_POSE'  ) insert into BEST..TI17FNC values ('ESFD3960_POSE',  'Integrate SAP file feedback to Omega')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESFD3960_POCE'  ) insert into BEST..TI17FNC values ('ESFD3960_POCE',  'Integrate SAP file feedback to Omega')
	

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_SAP_OMG_STD' and  CHAIN_CT='ESFD3960'
	insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3960','I17G_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3960','I17G_SAP_OMG_STD','')

	delete BEST..TI17REQCHN where   IDF_CT = 'I17L_SAP_OMG_STD' and  CHAIN_CT='ESFD3960'
	insert into BEST..TI17REQCHN values ('I17LMINV',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LMINVB',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LQINV',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LQINVB',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LQPOC',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LQPOCB',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LQPOS',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LQPOSB',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LYINV',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LYINVB',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LYPOC',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LYPOCB',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LYPOS',  'ESFD3960','I17L_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17LYPOSB',  'ESFD3960','I17L_SAP_OMG_STD','')

	delete BEST..TI17REQCHN where   IDF_CT = 'I17P_SAP_OMG_STD' and  CHAIN_CT='ESFD3960'
	insert into BEST..TI17REQCHN values ('I17PMINV',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PMINVB',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PQINV',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PQINVB',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PQPOC',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PQPOCB',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PQPOS',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PQPOSB',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PYINV',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PYINVB',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PYPOC',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PYPOCB',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PYPOS',  'ESFD3960','I17P_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('I17PYPOSB',  'ESFD3960','I17P_SAP_OMG_STD','')

	delete BEST..TI17REQCHN where   IDF_CT = 'EBS_SAP_OMG_STD' and  CHAIN_CT='ESFD3960'
	insert into BEST..TI17REQCHN values ('EBSEMINV',  'ESFD3960','EBS_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEMINVB',  'ESFD3960','EBS_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQINV',  'ESFD3960','EBS_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQINVB',  'ESFD3960','EBS_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESFD3960','EBS_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESFD3960','EBS_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYINV',  'ESFD3960','EBS_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYINVB',  'ESFD3960','EBS_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESFD3960','EBS_SAP_OMG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESFD3960','EBS_SAP_OMG_STD','')
go

-------------------------------
--	Init  ESPD3970
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3970')  insert into BEST..TI17CHN values ('ESPD3970',  'Merge GLT EBS Common after SAP Feedback')
	
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_MVT_MRG_STD'  ) insert into BEST..TI17FNC values ('EBS_MVT_MRG_STD',  'Merge GLT EBS Common after SAP Feedback')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'EBS_MVT_MRG_STD' and  CHAIN_CT='ESPD3970'
	insert into BEST..TI17REQCHN values ('EBSEMINV',  'ESPD3970','EBS_MVT_MRG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEMINVB',  'ESPD3970','EBS_MVT_MRG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQINV',  'ESPD3970','EBS_MVT_MRG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQINVB',  'ESPD3970','EBS_MVT_MRG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQPOC',  'ESPD3970','EBS_MVT_MRG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEQPOS',  'ESPD3970','EBS_MVT_MRG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYINV',  'ESPD3970','EBS_MVT_MRG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYINVB',  'ESPD3970','EBS_MVT_MRG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYPOC',  'ESPD3970','EBS_MVT_MRG_STD','')
	insert into BEST..TI17REQCHN values ('EBSEYPOS',  'ESPD3970','EBS_MVT_MRG_STD','')
go

-------------------------------
--	Init  ESPD8100
-------------------------------
 

	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8100')  insert into BEST..TI17CHN values ('ESPD8100',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD8100'  ) insert into BEST..TI17FNC values ('EBS_ESPD8100',  '')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD8100'  ) insert into BEST..TI17FNC values ('I4I_ESPD8100',  '')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='ESPD8100'
	insert into BEST..TI17REQCHN values('EBSEQPOC', 'ESPD8100', 'EBS_ESPD8100', '')
	insert into BEST..TI17REQCHN values('EBSEQPOS', 'ESPD8100', 'EBS_ESPD8100', '')
	insert into BEST..TI17REQCHN values('EBSEYPOC', 'ESPD8100', 'EBS_ESPD8100', '') 
	insert into BEST..TI17REQCHN values('EBSEYPOS', 'ESPD8100', 'EBS_ESPD8100', '') 
	insert into BEST..TI17REQCHN values('I4IQPOC', 'ESPD8100', 'I4I_ESPD8100', '') 
	insert into BEST..TI17REQCHN values('I4IQPOCB', 'ESPD8100', 'I4I_ESPD8100', '') 
	insert into BEST..TI17REQCHN values('I4IQPOS', 'ESPD8100', 'I4I_ESPD8100', '') 
	insert into BEST..TI17REQCHN values('I4IQPOSB', 'ESPD8100', 'I4I_ESPD8100', '')
	insert into BEST..TI17REQCHN values('I4IYPOC', 'ESPD8100', 'I4I_ESPD8100', '') 
	insert into BEST..TI17REQCHN values('I4IYPOCB', 'ESPD8100', 'I4I_ESPD8100', '') 
	insert into BEST..TI17REQCHN values('I4IYPOS', 'ESPD8100', 'I4I_ESPD8100', '') 
	insert into BEST..TI17REQCHN values('I4IYPOSB', 'ESPD8100', 'I4I_ESPD8100', '')
go

-------------------------------
--	Init  ESPD8800
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8800')  insert into BEST..TI17CHN values ('ESPD8800',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD8800'  ) insert into BEST..TI17FNC values ('EBS_ESPD8800',  '')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD8800'  ) insert into BEST..TI17FNC values ('I4I_ESPD8800',  '')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='ESPD8800'
	insert into BEST..TI17REQCHN values('EBSEQPOS', 'ESPD8800', 'EBS_ESPD8800', '')
	insert into BEST..TI17REQCHN values('EBSEYPOS', 'ESPD8800', 'EBS_ESPD8800', '') 
	insert into BEST..TI17REQCHN values('I4IQPOS', 'ESPD8800', 'I4I_ESPD8800', '') 
	insert into BEST..TI17REQCHN values('I4IQPOSB', 'ESPD8800', 'I4I_ESPD8800', '') 
	insert into BEST..TI17REQCHN values('I4IYPOS', 'ESPD8800', 'I4I_ESPD8800', '') 
	insert into BEST..TI17REQCHN values('I4IYPOSB', 'ESPD8800', 'I4I_ESPD8800', '')
go

-------------------------------
--	Init  ESPD8830
-------------------------------

	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8830')  insert into BEST..TI17CHN values ('ESPD8830',  '')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPD8830'  ) insert into BEST..TI17FNC values ('EBS_ESPD8830',  'IFRS4 Post omega  EBS')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD8830'  ) insert into BEST..TI17FNC values ('I4I_ESPD8830',  'IFRS4 Post omega  IFRS')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='ESPD8830'
	insert into BEST..TI17REQCHN values ('EBSEQPOSB',  'ESPD8830','EBS_ESPD8830','')
	insert into BEST..TI17REQCHN values ('EBSEYPOSB',  'ESPD8830','EBS_ESPD8830','')
	insert into BEST..TI17REQCHN values ('I4IQPOSB',  'ESPD8830','I4I_ESPD8830','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB',  'ESPD8830','I4I_ESPD8830','')
go

-------------------------------
--	Init  ESPJ8990
-------------------------------

	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPJ8990')  insert into BEST..TI17CHN values ('ESPJ8990',  'Post omega')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESPJ8990'  ) insert into BEST..TI17FNC values ('EBS_ESPJ8990',  'IFRS4 Post omega  EBS')
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPJ8990'  ) insert into BEST..TI17FNC values ('I4I_ESPJ8990',  'IFRS4 Post omega  IFRS')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT = 'ESPJ8990'
	insert into BEST..TI17REQCHN values('EBSEQPOC', 'ESPJ8990', 'EBS_ESPJ8990', '')
	insert into BEST..TI17REQCHN values('EBSEQPOCB', 'ESPJ8990', 'EBS_ESPJ8990', '')
	insert into BEST..TI17REQCHN values('EBSEQPOS', 'ESPJ8990', 'EBS_ESPJ8990', '')
	insert into BEST..TI17REQCHN values ('EBSEQPOSB', 'ESPJ8990','EBS_ESPJ8990','')
	insert into BEST..TI17REQCHN values('EBSEYPOC', 'ESPJ8990', 'EBS_ESPJ8990', '') 
	insert into BEST..TI17REQCHN values ('EBSEYPOCB', 'ESPJ8990','EBS_ESPJ8990','')
	insert into BEST..TI17REQCHN values('EBSEYPOS', 'ESPJ8990', 'EBS_ESPJ8990', '') 
	insert into BEST..TI17REQCHN values ('EBSEYPOSB', 'ESPJ8990','EBS_ESPJ8990','')
	insert into BEST..TI17REQCHN values('I4IQPOC', 'ESPJ8990', 'I4I_ESPJ8990', '') 
	insert into BEST..TI17REQCHN values('I4IQPOCB', 'ESPJ8990', 'I4I_ESPJ8990', '') 
	insert into BEST..TI17REQCHN values('I4IQPOS', 'ESPJ8990', 'I4I_ESPJ8990', '') 
	insert into BEST..TI17REQCHN values ('I4IQPOSB', 'ESPJ8990','I4I_ESPJ8990','')
	insert into BEST..TI17REQCHN values('I4IYPOC', 'ESPJ8990', 'I4I_ESPJ8990', '') 
	insert into BEST..TI17REQCHN values('I4IYPOCB', 'ESPJ8990', 'I4I_ESPJ8990', '') 
	insert into BEST..TI17REQCHN values('I4IYPOS', 'ESPJ8990', 'I4I_ESPJ8990', '') 
	insert into BEST..TI17REQCHN values ('I4IYPOSB', 'ESPJ8990','I4I_ESPJ8990','')
go


-------------------------------
--	Init  ESPD1520
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD1520')  insert into BEST..TI17CHN values ('ESPD1520',  'IFRS4 Post omega Life IFRS')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD1520'  ) insert into BEST..TI17FNC values ('I4I_ESPD1520',  'IFRS4 Post omega Life IFRS')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESPD1520'  ) insert into BEST..TI17FNC values ('ESPD1520',  '')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='ESPD1520'
	insert into BEST..TI17REQCHN values('I4IQPOS', 'ESPD1520', 'I4I_ESPD1520', '') 
	insert into BEST..TI17REQCHN values ('I4IQPOSB', 'ESPD1520','I4I_ESPD1520','')
	insert into BEST..TI17REQCHN values('I4IYPOS', 'ESPD1520', 'I4I_ESPD1520', '') 
	insert into BEST..TI17REQCHN values ('I4IYPOSB', 'ESPD1520','I4I_ESPD1520','')
	
	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	insert into BEST..TI17REQCHN values ('ALL',  'ESPD1520','ESPD1520','')
go

-------------------------------
--	Init  STPD1500
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='STPD1500')  insert into BEST..TI17CHN values ('STPD1500',  'IFRS4 Post omega Life IFRS')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_STPD1500'  ) insert into BEST..TI17FNC values ('I4I_STPD1500',  'IFRS4 Post omega Life IFRS')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='STPD1500'  ) insert into BEST..TI17FNC values ('STPD1500',  '')
	

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='STPD1500'
	insert into BEST..TI17REQCHN values('I4IQPOS', 'STPD1500', 'I4I_STPD1500', '') 
	insert into BEST..TI17REQCHN values ('I4IQPOSB', 'STPD1500','I4I_STPD1500','')
	insert into BEST..TI17REQCHN values('I4IYPOS', 'STPD1500', 'I4I_STPD1500', '') 
	insert into BEST..TI17REQCHN values ('I4IYPOSB', 'STPD1500','I4I_STPD1500','')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	insert into BEST..TI17REQCHN values ('ALL',  'STPD1500','STPD1500','')
go


-------------------------------
--	Init  STPD1200
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='STPD1200')  insert into BEST..TI17CHN values ('STPD1200',  'IFRS4 Post omega Life IFRS')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_STPD1200'  ) insert into BEST..TI17FNC values ('I4I_STPD1200',  'IFRS4 Post omega Life IFRS')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='STPD1200'  ) insert into BEST..TI17FNC values ('STPD1200',  '')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='STPD1200'
	insert into BEST..TI17REQCHN values('I4IQPOS', 'STPD1200', 'I4I_STPD1200', '') 
	insert into BEST..TI17REQCHN values ('I4IQPOSB', 'STPD1200','I4I_STPD1200','')
	insert into BEST..TI17REQCHN values('I4IYPOS', 'STPD1200', 'I4I_STPD1200', '') 
	insert into BEST..TI17REQCHN values ('I4IYPOSB', 'STPD1200','I4I_STPD1200','')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	insert into BEST..TI17REQCHN values ('ALL',  'STPD1200','STPD1500','')
go


-------------------------------
--	Init  STPD1280
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='STPD1280')  insert into BEST..TI17CHN values ('STPD1280',  'IFRS4 Post omega Life IFRS')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_STPD1280'  ) insert into BEST..TI17FNC values ('I4I_STPD1280',  'IFRS4 Post omega Life IFRS')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='STPD1280'  ) insert into BEST..TI17FNC values ('STPD1280',  '')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='STPD1280'
	insert into BEST..TI17REQCHN values('I4IQPOS', 'STPD1280', 'I4I_STPD1280', '') 
	insert into BEST..TI17REQCHN values ('I4IQPOSB', 'STPD1280','I4I_STPD1280','')
	insert into BEST..TI17REQCHN values('I4IYPOS', 'STPD1280', 'I4I_STPD1280', '') 
	insert into BEST..TI17REQCHN values ('I4IYPOSB', 'STPD1280','I4I_STPD1280','')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	insert into BEST..TI17REQCHN values ('ALL',  'STPD1280','STPD1280','')
go

-------------------------------
--	Init  ESPD3850 
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3850')  insert into BEST..TI17CHN values ('ESPD3850',  'IFRS4 Post omega IFRS')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD3850'  ) insert into BEST..TI17FNC values ('I4I_ESPD3850',  'IFRS4 Post omega IFRS')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where    CHAIN_CT='ESPD3850'
	insert into BEST..TI17REQCHN values('I4IQPOS', 'ESPD3850', 'I4I_ESPD3850', '') 
	insert into BEST..TI17REQCHN values ('I4IQPOSB', 'ESPD3850','I4I_ESPD3850','')
	insert into BEST..TI17REQCHN values('I4IYPOS', 'ESPD3850', 'I4I_ESPD3850', '') 
	insert into BEST..TI17REQCHN values ('I4IYPOSB', 'ESPD3850','I4I_ESPD3850','')
go

-------------------------------
--	Init  ESPD3860 
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3860')  insert into BEST..TI17CHN values ('ESPD3860',  'IFRS4 Post omega IFRS')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD3860'  ) insert into BEST..TI17FNC values ('I4I_ESPD3860',  'IFRS4 Post omega IFRS')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where    CHAIN_CT='ESPD3860'
	insert into BEST..TI17REQCHN values('I4IQPOS', 'ESPD3860', 'I4I_ESPD3860', '') 
	insert into BEST..TI17REQCHN values ('I4IQPOSB', 'ESPD3860','I4I_ESPD3860','')
	insert into BEST..TI17REQCHN values('I4IYPOS', 'ESPD3860', 'I4I_ESPD3860', '') 
	insert into BEST..TI17REQCHN values ('I4IYPOSB', 'ESPD3860','I4I_ESPD3860','')
go


-------------------------------
--	Init  ESPD8700
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8700')  insert into BEST..TI17CHN values ('ESPD8700',  'IFRS4 Post omega IFRS')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD8700'  ) insert into BEST..TI17FNC values ('I4I_ESPD8700',  'IFRS4 Post omega IFRS')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESPD8700'  ) insert into BEST..TI17FNC values ('ESPD8700',  '')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where    CHAIN_CT='ESPD8700'
	insert into BEST..TI17REQCHN values('I4IQPOS', 'ESPD8700', 'I4I_ESPD8700', '') 
	insert into BEST..TI17REQCHN values ('I4IQPOSB', 'ESPD8700','I4I_ESPD8700','')
	insert into BEST..TI17REQCHN values('I4IYPOS', 'ESPD8700', 'I4I_ESPD8700', '') 
	insert into BEST..TI17REQCHN values ('I4IYPOSB', 'ESPD8700','I4I_ESPD8700','')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	insert into BEST..TI17REQCHN values ('ALL',  'ESPD8700','ESPD8700','')
go


-------------------------------
--	Init  ESPD7000
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD7000')  insert into BEST..TI17CHN values ('ESPD7000',  'IFRS4 Post omega IFRS')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD7000'  ) insert into BEST..TI17FNC values ('I4I_ESPD7000',  'IFRS4 Post omega IFRS')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESPD7000'  ) insert into BEST..TI17FNC values ('ESPD7000',  '')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='ESPD7000'
	insert into BEST..TI17REQCHN values('I4IQPOS', 'ESPD7000', 'I4I_ESPD7000', '') 
	insert into BEST..TI17REQCHN values ('I4IQPOSB', 'ESPD7000','I4I_ESPD7000','')
	insert into BEST..TI17REQCHN values('I4IYPOS', 'ESPD7000', 'I4I_ESPD7000', '') 
	insert into BEST..TI17REQCHN values ('I4IYPOSB', 'ESPD7000','I4I_ESPD7000','')

	-- Temporaire en attendant que le TI17PERMFIL soit mis a jour
	insert into BEST..TI17REQCHN values ('ALL',  'ESPD7000','ESPD7000','')
go


-------------------------------
--	Init  ESPD9990
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESPD9990')  insert into BEST..TI17CHN values ('ESPD9990',  'IFRS4 Post omega IFRS')

	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I4I_ESPD9990'  ) insert into BEST..TI17FNC values ('I4I_ESPD9990',  'IFRS4 Post omega IFRS')


	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   CHAIN_CT='ESPD9990'
	insert into BEST..TI17REQCHN values ('I4IQPOSB', 'ESPD9990','I4I_ESPD9990','')
	insert into BEST..TI17REQCHN values ('I4IYPOSB', 'ESPD9990','I4I_ESPD9990','')
go



