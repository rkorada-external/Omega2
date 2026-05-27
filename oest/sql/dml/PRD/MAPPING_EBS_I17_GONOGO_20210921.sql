use BEST
go

--- select before 


select * 
from BEST..TI17REQFNC  
where idf_ct in 
(
'EBS_DLT_SAP_STD',
'EBS_ESFD3620' , 
'EBS_ESPD8000'  , 
'EBS_ESPD8100'  , 
'EBS_ESPD8200' ,
'EBS_DLT_SAP_STD',
'EBS_ESFD3620' , 
'EBS_ESPD8000'  , 
'EBS_ESPD8100'  , 
'EBS_ESPD8200',
'I17G_DLT_SAP_STD',
'I17L_DLT_SAP_STD',
'I17P_DLT_SAP_STD',
'I17P_OMG_BOK_STD'        ,
'I17L_OMG_BOK_STD'        ,
'I17G_OMG_BOK_STD'  ,
'I17L_OMG_OPNG_STD'      ,
'I17P_OMG_OPNG_STD'      ,
'I17G_OMG_OPNG_STD'
)
and reqcod_ct in 
(
'EBSEQINV',
'EBSEYINV',
'I17GQINV',	
'I17GYINV',	
'I17LQINV',	
'I17LYINV',	
'I17PQINV',	
'I17PYINV',
'I17GQINVB',		
'I17LQINVB',	
'I17PQINVB',	
'I17GYINVB',		
'I17LYINVB',		
'I17PYINVB'
)



---- bugfix

delete from BEST..TI17REQFNC  
where idf_ct in 
(
'EBS_DLT_SAP_STD',
'EBS_ESFD3620' , 
'EBS_ESPD8000'  , 
'EBS_ESPD8100'  , 
'EBS_ESPD8200' )
and reqcod_ct in 
(
'EBSEQINV')


delete from BEST..TI17REQFNC  
where idf_ct in 
(
'EBS_DLT_SAP_STD',
'EBS_ESFD3620' , 
'EBS_ESPD8000'  , 
'EBS_ESPD8100'  , 
'EBS_ESPD8200' )
and reqcod_ct in 
(
'EBSEYINV')


insert into BEST..TI17REQFNC values ('EBSEQINV', 'EBS_DLT_SAP_STD','')
insert into BEST..TI17REQFNC values ('EBSEQINV', 'EBS_ESFD3620'   ,''   )
insert into BEST..TI17REQFNC values ('EBSEQINV', 'EBS_ESPD8000'   ,''   )
insert into BEST..TI17REQFNC values ('EBSEQINV', 'EBS_ESPD8100'   ,''   )
insert into BEST..TI17REQFNC values ('EBSEQINV', 'EBS_ESPD8200'   ,''   )

insert into BEST..TI17REQFNC values ('EBSEYINV', 'EBS_DLT_SAP_STD','')
insert into BEST..TI17REQFNC values ('EBSEYINV', 'EBS_ESFD3620'   ,''   )
insert into BEST..TI17REQFNC values ('EBSEYINV', 'EBS_ESPD8000'   ,''   )
insert into BEST..TI17REQFNC values ('EBSEYINV', 'EBS_ESPD8100'   ,''   )
insert into BEST..TI17REQFNC values ('EBSEYINV', 'EBS_ESPD8200'   ,''   )

go


delete from BEST..TI17REQFNC  
where idf_ct in 
(
'I17G_DLT_SAP_STD',
'I17L_DLT_SAP_STD',
'I17P_DLT_SAP_STD'
)
and reqcod_ct in 
(
'I17GQINV',	
'I17GYINV',	
'I17LQINV',	
'I17LYINV',	
'I17PQINV',	
'I17PYINV'
)


insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DLT_SAP_STD'   ,'')
insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DLT_SAP_STD'   ,''   )
insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DLT_SAP_STD'   ,''   )
insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DLT_SAP_STD'   ,''   )
insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DLT_SAP_STD'   ,''   )
insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DLT_SAP_STD'   ,''   )

go


delete from BEST..TI17REQFNC  
where idf_ct in 
(
'I17P_OMG_BOK_STD'        ,
'I17L_OMG_BOK_STD'        ,
'I17G_OMG_BOK_STD'  
)      
and reqcod_ct in 
(
'I17GQINVB',	
'I17GYINVB',	
'I17LQINVB',	
'I17LYINVB',	
'I17PQINVB',	
'I17PYINVB'
)

insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_OMG_BOK_STD'   ,''   )
insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_OMG_BOK_STD'   ,''   )
insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_OMG_BOK_STD'   ,''   )
insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_OMG_BOK_STD'   ,''   )
insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_OMG_BOK_STD'   ,'')
insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_OMG_BOK_STD'   ,''   )

go

delete from BEST..TI17REQFNC  
where idf_ct in 
(
'I17L_OMG_OPNG_STD'      ,
'I17P_OMG_OPNG_STD'      ,
'I17G_OMG_OPNG_STD'
)      
and reqcod_ct in 
(	
'I17GYINVB',		
'I17LYINVB',		
'I17PYINVB'
)

insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_OMG_OPNG_STD'   ,''   )
insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_OMG_OPNG_STD'   ,''   )
insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_OMG_OPNG_STD'   ,''   )



go


--- select after
select * 
from BEST..TI17REQFNC  
where idf_ct in 
(
'EBS_DLT_SAP_STD',
'EBS_ESFD3620' , 
'EBS_ESPD8000'  , 
'EBS_ESPD8100'  , 
'EBS_ESPD8200' ,
'EBS_DLT_SAP_STD',
'EBS_ESFD3620' , 
'EBS_ESPD8000'  , 
'EBS_ESPD8100'  , 
'EBS_ESPD8200',
'I17G_DLT_SAP_STD',
'I17L_DLT_SAP_STD',
'I17P_DLT_SAP_STD',
'I17P_OMG_BOK_STD'        ,
'I17L_OMG_BOK_STD'        ,
'I17G_OMG_BOK_STD'  ,
'I17L_OMG_OPNG_STD'      ,
'I17P_OMG_OPNG_STD'      ,
'I17G_OMG_OPNG_STD'
)
and reqcod_ct in 
(
'EBSEQINV',
'EBSEYINV',
'I17GQINV',	
'I17GYINV',	
'I17LQINV',	
'I17LYINV',	
'I17PQINV',	
'I17PYINV',
'I17GQINVB',		
'I17LQINVB',		
'I17PQINVB',	
'I17GYINVB',		
'I17LYINVB',		
'I17PYINVB'
)


go



