use BEST
go
if object_id('PsMANUPLD_NOTOVWRT_DIP0') is not null
begin
  drop procedure PsMANUPLD_NOTOVWRT_DIP0
  if object_id('PsMANUPLD_NOTOVWRT_DIP0') is not null
    print '<<< FAILED DROPPING procedure PsMANUPLD_NOTOVWRT_DIP0 >>>'
  else
    print '<<< DROPPED procedure PsMANUPLD_NOTOVWRT_DIP0 >>>'
end
go
create procedure PsMANUPLD_NOTOVWRT_DIP0
  (
 @p_SSD_CF       USSD_CF
 ,@p_CREUSR_CF    UUPDUSR_CF
 ,@p_type_fichier char(3) -- DSC Illiquidity/Discount ou CUM cumulative ou ICV incurred
 ,@p_clodat_d	  datetime		
 ,@p_per_cf		  varchar(5)	
  )
with execute as caller as 

declare
  @erreur      int
 ,@lignes      int
 
 
 
 if @p_type_fichier='DSC'			
  BEGIN
	INSERT INTO TCTRANO
	select distinct convert(char(8),getdate(),112),datepart(hour,getdate()),datepart(minute,getdate()),0, @p_SSD_CF, 'S', @p_CREUSR_CF,  811, LIGNE_N, NULL,NULL
    FROM BEST..TPATTERNSII A , BTRAV..EST_ESID0821_TPATTERNSII B
	WHERE
	isnull(A.SSD_CF, 0 ) = isnull(B.SSD_CF, 0 ) AND
	isnull(A.ESB_CF, 0 ) = isnull(B.ESB_CF, 0) AND			
	isnull(A.CUR_CF, '' ) = isnull(B.CUR_CF, '') AND
	isnull(A.NORME_CF, '' ) = isnull(B.NORME_CF, '') AND
	A.PATTYP_CT = B.PATTYP_CT AND
	A.RATEINDEX_CT = B.LOB_CF AND
	A.CREUSR_CF = 'DIP0' AND B.CREUSR_CF != 'DIP0' AND
	EXISTS 
	( SELECT 1 FROM BEST..TPATTERNSII A , BEST..TPATSEGSII C 
	  WHERE A.RATEINDEX_CT= C.RATEINDEX_CT AND A.PATTERN_ID = C.PATTERN_ID AND A.PATCAT_CT = C.PATCAT_CT  AND A.PATTYP_CT =C.PATTYP_CT
			AND isnull(A.SSD_CF, 0 ) = isnull(C.SSD_CF, 0 ) AND isnull(A.ESB_CF, 0 ) = isnull(C.ESB_CF, 0)
			AND isnull(A.CUR_CF, '' ) = isnull(C.CUR_CF, '') AND isnull(A.NORME_CF, '' ) = isnull(C.NORME_CF, '')				
			AND C.CLODAT_D = @p_clodat_d AND C.PER_CF = @p_per_cf
			AND C.CREUSR_CF = 'DIP0'
	)
	select @erreur=@@error, @lignes=@lignes+@@rowcount
	if @erreur!=0 return 1
  END
  
  return 0
go
if object_id('PsMANUPLD_NOTOVWRT_DIP0') is not null
  print '<<< CREATED procedure PsMANUPLD_NOTOVWRT_DIP0 >>>'
else
  print '<<< FAILED CREATING procedure PsMANUPLD_NOTOVWRT_DIP0 >>>'
go
grant execute on PsMANUPLD_NOTOVWRT_DIP0 TO GOMEGA
go
grant execute on PsMANUPLD_NOTOVWRT_DIP0 TO GDBBATCH
go