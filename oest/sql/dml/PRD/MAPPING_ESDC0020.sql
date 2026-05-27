-------------------------------
--mapping of  ESDC0020

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESDC0020')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESDC0020')
	delete BEST..TI17FNC where CHAIN_CT='ESDC0020'
	delete BEST..TI17CHN  where CHAIN_CT='ESDC0020'

	insert into BEST..TI17CHN values ('ESDC0020',  'AE and PAI interface reports')

	----------IDF_CT:   I17G_AE_RPT_CHK ------------------

		insert into BEST..TI17FNC values ('I17G_AE_RPT_CHK','AE and PAI interface reports','ESDC0020',0)
					

		----------  Perms---------------------

      insert into BEST..TI17PERMFIL values ('I17G_AE_RPT_CHK',  'AE_FICHIER_CR','${DTRANSFER}/LifeReserving/to/${ENV_PREFIX}_ESIJ0780_CR_${PARM_CRE_D}.dat','I','')
      insert into BEST..TI17PERMFIL values ('I17G_AE_RPT_CHK',  'AE_FICHIER_RAPPORT','${DTRANSFER}/LifeReserving/to/${ENV_PREFIX}_ESIJ0780_ERROR_RAPPORT_${PARM_CRE_D}.csv','I','')
      insert into BEST..TI17PERMFIL values ('I17G_AE_RPT_CHK',  'PAI_FICHIER_CR_I17G','`ls -t ${DTRANSFER}/LifeReserving/to/${ENV_PREFIX}_ESFD3860_I17G_PRO_INT_STD_PI_REPORT_*_${PARM_CRE_D}.dat | head -1 `','I','')
      insert into BEST..TI17PERMFIL values ('I17G_AE_RPT_CHK',  'PAI_FICHIER_CR_I17P','`ls -t ${DTRANSFER}/LifeReserving/to/${ENV_PREFIX}_ESFD3860_I17P_PRO_INT_STD_PI_REPORT_*_${PARM_CRE_D}.dat | head -1 `','I','')
      insert into BEST..TI17PERMFIL values ('I17G_AE_RPT_CHK',  'PAI_FICHIER_CR_I17L','`ls -t ${DTRANSFER}/LifeReserving/to/${ENV_PREFIX}_ESFD3860_I17L_PRO_INT_STD_PI_REPORT_*_${PARM_CRE_D}.dat | head -1 `','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEQPOSB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEYPOSB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17GQINVB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17GYINVB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LQINVB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LQPOSB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LYINVB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LYPOSB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PQINVB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PQPOSB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IYPOC',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IYPOCB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IQPOS',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PYINVB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PYPOSB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IQPOC',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IQPOCB',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEQPOSP',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('EBSEYPOSP',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17GQPOSP',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17GYPOSP',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LQPOSP',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17LYPOSP',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PQPOSP',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I4IQPOSP',  'I17G_AE_RPT_CHK','')
			insert into BEST..TI17REQFNC values ('I17PYPOSP',  'I17G_AE_RPT_CHK','')
go

