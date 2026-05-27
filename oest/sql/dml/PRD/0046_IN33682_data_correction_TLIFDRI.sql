--
-- All retrocession contracts should have reserves propagation at true for non-complete years.
--

USE BEST

go

UPDATE BEST..TLIFDRI
   SET RESPROPAG_B = 1
  FROM BEST..TLIFDRI a
 WHERE     EXISTS
              (SELECT 1
                 FROM BRET..TRETCTR b
                WHERE b.RETCTR_NF = a.CTR_NF)
       AND a.COMACC_B = 0
       AND a.RESPROPAG_B = 0

go

