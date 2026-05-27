USE BREF

GO

select * from  BREF..TTRSLNK
 WHERE     PRS_CF in (640) 
       AND (   DETTRS_CF LIKE ('%10120%')
            OR DETTRS_CF LIKE ('%10130%')
            OR DETTRS_CF LIKE ('%12007%')
            OR DETTRS_CF LIKE ('%12030%')
            OR DETTRS_CF LIKE ('%14010%')
            OR DETTRS_CF LIKE ('%15000%')
            OR DETTRS_CF LIKE ('%15020%')
            OR DETTRS_CF LIKE ('%15030%')
            OR DETTRS_CF LIKE ('%15040%')
            OR DETTRS_CF LIKE ('%31000%')
            OR DETTRS_CF LIKE ('%31010%')
            OR DETTRS_CF LIKE ('%43010%')
            OR DETTRS_CF LIKE ('%49410%'))
       AND DETTRS_CF LIKE ('_A______')
       AND ACMTRS_NT in (400,100)
go 
	   

