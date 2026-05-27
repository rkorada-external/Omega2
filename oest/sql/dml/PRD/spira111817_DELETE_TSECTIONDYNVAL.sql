USE BTRAV
go
-----------------------------------------
-- spira 111817
-----------------------------------------
SELECT 'Début Delete :', getdate()


DELETE FROM BTRT..TSECTIONDYNVAL 
WHERE 
    DYNFIELD_CT = 36 
AND FIELDVAL_B = 1
                    

--====================================
--  ETIQUETTE FIN TRAITEMENT PRINCIPAL
--====================================
SET nocount ON

SELECT 'Fin Delete :', getdate()


SET nocount OFF
GO

