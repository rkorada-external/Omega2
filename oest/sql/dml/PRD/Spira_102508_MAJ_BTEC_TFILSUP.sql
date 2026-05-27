----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2022 MZM : spira 102508: Script de parametrage de BTEC..TFILSUP pour ESFD2550 
--                        IDF_CT : I17/G/L/P_FUT_RPO_INI ; 
--                                 I17/G/L/P_LCC_RPO_INI ; 
--                                 I17/G/L/P_RPO_NDC_STD ; 
--                                 I17/G/L/P_RPO_NDC_INI ;
--
--                         ==>         I17/G/L/P_AA00 ; I17/G/L/P_AA01 ; I17/G/L/P_AA02 ; I17/G/L/P_AA03
--
--  La colonne DOM_CF de la table BTEC..TFILSUP sera lu / stockée dans la variable NCHAIN_SHORT=${ARG2_CHN_2}_${NORME_CF} limite donc a 8 caracteres
--  export NCHAIN=${ENV_PREFIX}_${ARG2_CHN_2}_${NORME_CF} 
--  Il y a une redefinition de ${ARG2_CHN_2} en fonction de l'IDF_CT (MIC AIC, LCC INI et NDC INI)
--  NDC STANDARD Utilise le couloir EBS ; l'IDF_CT est EBS_ESFD2550 et la colonne DOM_CF est NDC_EBS. 
-- AJOUT de l'IDF_CT I17G_ESFD2550
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD2550
-------------------------------


delete   BTEC..TFILSUP where dom_cf in ('FUT_I17G','FUT_I17L','FUT_I17P','FUT_I17G','FUT_I17L','FUT_I17P','FUT_I17G','FUT_I17L','FUT_I17P','NDC_EBS','AA0_I17G','AA1_I17G','AA2_I17G','AA3_I17G','FUT_I17G','FUT_I17L','FUT_I17P', 
                                        'LCI_I17G','LCI_I17L','LCI_I17P','LCC_I17G','LCC_I17L', 'LCC_I17P','AA0_I17G','AA1_I17G','AA2_I17G','AA3_I17G','FUT_I17G','FUT_I17L','FUT_I17P','LCI_I17G','LCI_I17L','LCI_I17P',
                                        'LCC_I17G','LCC_I17L','LCC_I17P','NDI_I17G','NDI_I17L','NDI_I17P','NDC_EBS','AA0_I17G','AA1_I17G','AA2_I17G','AA3_I17G','FUT_I17G','FUT_I17L','FUT_I17P','LCI_I17G','LCI_I17L','LCI_I17P' ,'AAA_I17G')


insert into BTEC..TFILSUP values('FUT_I17G', 212,	'USA1')
insert into BTEC..TFILSUP values('FUT_I17G', 211,	'FRA1')
insert into BTEC..TFILSUP values('FUT_I17G', 210,	'SGP1')

insert into BTEC..TFILSUP values('FUT_I17L', 112,	'USA1')
insert into BTEC..TFILSUP values('FUT_I17L', 111,	'FRA1')
insert into BTEC..TFILSUP values('FUT_I17L', 110,	'SGP1')

insert into BTEC..TFILSUP values('FUT_I17P', 312,	'USA1')
insert into BTEC..TFILSUP values('FUT_I17P', 311,	'FRA1')
insert into BTEC..TFILSUP values('FUT_I17P', 310,	'SGP1')


insert into BTEC..TFILSUP values('LCI_I17G', 126,	'USA1') -- LCC_INI PB
insert into BTEC..TFILSUP values('LCI_I17G', 125,	'FRA1') -- LCC INI FRA1
insert into BTEC..TFILSUP values('LCI_I17G', 124,	'SGP1') -- LCC INI SGP1

insert into BTEC..TFILSUP values('LCI_I17P', 226,	'USA1') -- LCC_INI PB
insert into BTEC..TFILSUP values('LCI_I17P', 225,	'FRA1') -- LCC INI FRA1
insert into BTEC..TFILSUP values('LCI_I17P', 224,	'SGP1') -- LCC INI SGP1

insert into BTEC..TFILSUP values('LCI_I17L', 326,	'USA1') -- LCC_INI PB
insert into BTEC..TFILSUP values('LCI_I17L', 325,	'FRA1') -- LCC INI FRA1
insert into BTEC..TFILSUP values('LCI_I17L', 324,	'SGP1') -- LCC INI SGP1


insert into BTEC..TFILSUP values('NDI_I17G', 136,	'USA1') -- NDC_INI PB
insert into BTEC..TFILSUP values('NDI_I17G', 135,	'FRA1') -- NDC INI FRA1
insert into BTEC..TFILSUP values('NDI_I17G', 134,	'SGP1') -- NDC INI SGP1

insert into BTEC..TFILSUP values('NDI_I17P', 236,	'USA1') -- NDC_INI PB
insert into BTEC..TFILSUP values('NDI_I17P', 235,	'FRA1') -- NDC INI FRA1
insert into BTEC..TFILSUP values('NDI_I17P', 234,	'SGP1') -- NDC INI SGP1

insert into BTEC..TFILSUP values('NDI_I17L', 336,	'USA1') -- NDC_INI PB
insert into BTEC..TFILSUP values('NDI_I17L', 335,	'FRA1') -- NDC INI FRA1
insert into BTEC..TFILSUP values('NDI_I17L', 334,	'SGP1') -- NDC INI SGP1



insert into BTEC..TFILSUP values('AA0_I17G', 205,	'USA1')
insert into BTEC..TFILSUP values('AA0_I17G', 204,	'FRA1')
insert into BTEC..TFILSUP values('AA0_I17G', 203,'SGP1')

insert into BTEC..TFILSUP values('AA1_I17G', 208,	'USA1')
insert into BTEC..TFILSUP values('AA1_I17G', 207,	'FRA1')
insert into BTEC..TFILSUP values('AA1_I17G', 206,	'SGP1')

insert into BTEC..TFILSUP values('AA2_I17G', 308,	'USA1')
insert into BTEC..TFILSUP values('AA2_I17G', 307,	'FRA1')
insert into BTEC..TFILSUP values('AA2_I17G', 306,	'SGP1')

insert into BTEC..TFILSUP values('AA3_I17G', 305,	'USA1')
insert into BTEC..TFILSUP values('AA3_I17G', 304,	'FRA1')
insert into BTEC..TFILSUP values('AA3_I17G', 303, 'SGP1')



insert into BTEC..TFILSUP values('LCC_I17G', 119,	'USA1') -- LCC_STD et 
insert into BTEC..TFILSUP values('LCC_I17G', 219,	'FRA1') -- LCC STD FRA1
insert into BTEC..TFILSUP values('LCC_I17G', 319,	'SGP1') -- LCC STD SGP1

insert into BTEC..TFILSUP values('LCC_I17L', 118,	'USA1') -- LCC_STD et 
insert into BTEC..TFILSUP values('LCC_I17L', 218,	'FRA1') -- LCC STD FRA1
insert into BTEC..TFILSUP values('LCC_I17L', 318,	'SGP1') -- LCC STD SGP1

insert into BTEC..TFILSUP values('LCC_I17P', 124,	'USA1') -- LCC_STD et 
insert into BTEC..TFILSUP values('LCC_I17P', 224,	'FRA1') -- LCC STD FRA1
insert into BTEC..TFILSUP values('LCC_I17P', 324,	'SGP1') -- LCC STD SGP1


insert into BTEC..TFILSUP values('NDC_EBS', 123,	'USA1')  -- NDC USA1 -- NDC STANDARD Tourne avec la norme EBS
insert into BTEC..TFILSUP values('NDC_EBS', 223,	'FRA1')  -- NDC FRA1 -- NDC STANDARD Tourne avec la norme EBS
insert into BTEC..TFILSUP values('NDC_EBS', 323,	'SGP1') -- NDC SGP1  -- NDC STANDARD Tourne avec la norme EBS

insert into BTEC..TFILSUP values('AAA_I17G', 624,	'USA1') -- I17G_
insert into BTEC..TFILSUP values('AAA_I17G', 724,	'FRA1') -- I17G FRA1
insert into BTEC..TFILSUP values('AAA_I17G', 824,	'SGP1') -- I17G SGP1


--insert into BTEC..TFILSUP values('NDC_I17L', 423,	'USA1')
--insert into BTEC..TFILSUP values('NDC_I17L', 523,	'FRA1')
--insert into BTEC..TFILSUP values('NDC_I17L', 623,	'SGP1') -- NDC STANDARD Tourne avec la norme EBS
--
--insert into BTEC..TFILSUP values('NDC_I17P', 723,	'USA1')
--insert into BTEC..TFILSUP values('NDC_I17P', 823,	'FRA1')
--insert into BTEC..TFILSUP values('NDC_I17P', 923,	'SGP1') -- NDC STANDARD Tourne avec la norme EBS 

 

go
