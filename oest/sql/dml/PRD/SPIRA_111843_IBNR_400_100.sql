USE BREF

GO

select * from  BREF..TTRSLNK
 WHERE     PRS_CF in (640) 
       AND 
       (
            ( (   DETTRS_CF LIKE ('%10120%')
                 OR DETTRS_CF LIKE ('%10130%')
                 OR DETTRS_CF LIKE ('%20070%')
                 OR DETTRS_CF LIKE ('%12030%')
                 OR DETTRS_CF LIKE ('%14010%')
                 OR DETTRS_CF LIKE ('%15000%')
                 OR DETTRS_CF LIKE ('%31000%')
                 OR DETTRS_CF LIKE ('%31010%')
                 OR DETTRS_CF LIKE ('%43010%')
                 OR DETTRS_CF LIKE ('%49410%'))
            AND (DETTRS_CF LIKE ('_A______') or DETTRS_CF LIKE ('_B______')  or DETTRS_CF LIKE ('_E______') or DETTRS_CF LIKE ('_G______') or DETTRS_CF LIKE ('_J______')  ) 
            )
       OR
	       (   DETTRS_CF LIKE ('%43010%')
             AND (DETTRS_CF LIKE ('_1______') or DETTRS_CF LIKE ('_2______') or DETTRS_CF LIKE ('_4______') or DETTRS_CF LIKE ('_5______')  or DETTRS_CF LIKE ('_7______')) 
           )
       ) 
       AND ACMTRS_NT in (400,100) 
	   
	   
go 
	   
UPDATE BREF..TTRSLNK
   SET ACMTRS_NT = 100
 WHERE     PRS_CF in (640) 
       AND 
       (
            ( (   DETTRS_CF LIKE ('%10120%')
                 OR DETTRS_CF LIKE ('%10130%')
                 OR DETTRS_CF LIKE ('%20070%')
                 OR DETTRS_CF LIKE ('%12030%')
                 OR DETTRS_CF LIKE ('%14010%')
                 OR DETTRS_CF LIKE ('%15000%')
                 OR DETTRS_CF LIKE ('%31000%')
                 OR DETTRS_CF LIKE ('%31010%')
                 OR DETTRS_CF LIKE ('%43010%')
                 OR DETTRS_CF LIKE ('%49410%'))
            AND (DETTRS_CF LIKE ('_A______') or DETTRS_CF LIKE ('_B______')  or DETTRS_CF LIKE ('_E______') or DETTRS_CF LIKE ('_G______') or DETTRS_CF LIKE ('_J______')  ) 
            )
       OR
	       (   DETTRS_CF LIKE ('%43010%')
             AND (DETTRS_CF LIKE ('_1______') or DETTRS_CF LIKE ('_2______') or DETTRS_CF LIKE ('_4______') or DETTRS_CF LIKE ('_5______')  or DETTRS_CF LIKE ('_7______')) 
           )
       ) 
       AND ACMTRS_NT in (400) 

GO


select * from  BREF..TTRSLNK
 WHERE     PRS_CF in (640) 
       AND 
       (
            ( (   DETTRS_CF LIKE ('%10120%')
                 OR DETTRS_CF LIKE ('%10130%')
                 OR DETTRS_CF LIKE ('%20070%')
                 OR DETTRS_CF LIKE ('%12030%')
                 OR DETTRS_CF LIKE ('%14010%')
                 OR DETTRS_CF LIKE ('%15000%')
                 OR DETTRS_CF LIKE ('%31000%')
                 OR DETTRS_CF LIKE ('%31010%')
                 OR DETTRS_CF LIKE ('%43010%')
                 OR DETTRS_CF LIKE ('%49410%'))
            AND (DETTRS_CF LIKE ('_A______') or DETTRS_CF LIKE ('_B______')  or DETTRS_CF LIKE ('_E______') or DETTRS_CF LIKE ('_G______') or DETTRS_CF LIKE ('_J______')  ) 
            )
       OR
	       (   DETTRS_CF LIKE ('%43010%')
             AND (DETTRS_CF LIKE ('_1______') or DETTRS_CF LIKE ('_2______') or DETTRS_CF LIKE ('_4______') or DETTRS_CF LIKE ('_5______')  or DETTRS_CF LIKE ('_7______')) 
           )
       ) 
       AND ACMTRS_NT in (400,100) 
go 



