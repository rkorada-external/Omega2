-- --------------------------------------------------------------------------------------------- --
-- Script           : RET100617_UPDATE_TRETIFRS.sql
-- Domaine          : RETROCESSION
-- Auteur           : L. Rakotozafy
-- Date de création : 26/11/2021
-- Description      : Init P&C and Life Data into TRETIFRS
-- :spira:100617
-- --------------------------------------------------------------------------------------------- --
USE BRET
GO

-- --------------------- --
-- Début des traitements --    
-- --------------------- --

BEGIN TRAN
    
    Declare @erreur         int
          , @trans_etat     int
          , @datejour       datetime
          , @lstusr         char(4)
          
    SELECT @datejour  = getdate()
          ,@lstusr = SUBSTRING('100617',3,4)
          
          print ' BRET..TRETIFRS avant maj FSTVISA_D '
          select T4.RETRECOD_D,T4.* 
          FROM BRET..TRETCTR T1 , bret..TRETCTRVISA T2, bret..TRETIFRS T4
            WHERE T1.RETCTRSTS_CT in (3,19,18,23)
            AND T1.RETCTR_NF = T4.RETCTR_NF 
            AND T1.RTY_NF = T4.RTY_NF
            AND T1.RETCTR_NF = T2.RETCTR_NF
            AND T1.RTY_NF = T2.RTY_NF
            AND T2.VISA_NT = 1
            AND ((T2.FSTVISA_D != T2.SNDVISA_D) OR (T2.FSTVISA_D != null AND T2.SNDVISA_D in (null,'')) or (T2.SNDVISA_D != null AND T2.FSTVISA_D in (null,'')))
            

            Update BRET..TRETIFRS
            set RETRECOD_D = T2.FSTVISA_D
                 , LSTUPD_D     = @datejour
                 , LSTUPDUSR_CF = @lstusr 
            FROM BRET..TRETCTR T1 , bret..TRETCTRVISA T2, bret..TRETIFRS T4
            WHERE T1.RETCTRSTS_CT in (3,19,18,23)
            AND T1.RETCTR_NF = T4.RETCTR_NF 
            AND T1.RTY_NF = T4.RTY_NF
            AND T1.RETCTR_NF = T2.RETCTR_NF
            AND T1.RTY_NF = T2.RTY_NF
            AND T2.VISA_NT = 1
            AND ((T2.FSTVISA_D != T2.SNDVISA_D) OR (T2.FSTVISA_D != null AND T2.SNDVISA_D in (null,'')) or (T2.SNDVISA_D != null AND T2.FSTVISA_D in (null,'')))
            


-- récuperer codes retour et nb lignes impactées --
           SELECT @erreur = @@error, @trans_etat = @@transtate
           IF @erreur != 0 OR @trans_etat > 1
              BEGIN
                   PRINT 'BRET..TRETIFRS RETRECOD_D FSTVISA_D - update ERREUR : %1!',@erreur
                   ROLLBACK TRAN
                   GOTO fin
              END
              
          print''
          print''   
          print ' BRET..TRETIFRS apres maj FSTVISA_D '
          select T4.RETRECOD_D,T4.* 
          FROM BRET..TRETCTR T1 , bret..TRETCTRVISA T2, bret..TRETIFRS T4
            WHERE T1.RETCTRSTS_CT in (3,19,18,23)
            AND T1.RETCTR_NF = T4.RETCTR_NF 
            AND T1.RTY_NF = T4.RTY_NF
            AND T1.RETCTR_NF = T2.RETCTR_NF
            AND T1.RTY_NF = T2.RTY_NF
            AND T2.VISA_NT = 1
            AND ((T2.FSTVISA_D != T2.SNDVISA_D) OR (T2.FSTVISA_D != null AND T2.SNDVISA_D in (null,'')) or (T2.SNDVISA_D != null AND T2.FSTVISA_D in (null,'')))
                     



            print''
            print''
            print ' BRET..TRETIFRS avant maj CTRINCUWY_D '
            select T4.RETRECOD_D,T4.*
            FROM BRET..TRETCTR T1 , bret..TRETCTRVISA T2, bret..TRETIFRS T4
            WHERE T1.RETCTRSTS_CT in (3,19,18,23)
            AND T1.RETCTR_NF = T4.RETCTR_NF 
            AND T1.RTY_NF = T4.RTY_NF
            AND T1.RETCTR_NF = T2.RETCTR_NF
            AND T1.RTY_NF = T2.RTY_NF
            AND T2.VISA_NT = 1
            AND T2.FSTVISA_D = T2.SNDVISA_D
            
            
                       
            Update BRET..TRETIFRS
            set RETRECOD_D = T1.CTRINCUWY_D
                 , LSTUPD_D     = @datejour
                 , LSTUPDUSR_CF = @lstusr 
            FROM BRET..TRETCTR T1 , bret..TRETCTRVISA T2,  bret..TRETIFRS T4
            WHERE T1.RETCTRSTS_CT in (3,19,18,23)
            AND T1.RETCTR_NF = T4.RETCTR_NF 
            AND T1.RTY_NF = T4.RTY_NF
            AND T1.RETCTR_NF = T2.RETCTR_NF
            AND T1.RTY_NF = T2.RTY_NF
            AND T2.VISA_NT = 1
            AND T2.FSTVISA_D = T2.SNDVISA_D
            


-- récuperer codes retour et nb lignes impactées --
           SELECT @erreur = @@error, @trans_etat = @@transtate
           IF @erreur != 0 OR @trans_etat > 1
              BEGIN
                   PRINT 'BRET..TRETIFRS RETRECOD_D CTRINCUWY_D  - update ERREUR : %1!',@erreur
                   ROLLBACK TRAN
                   GOTO fin
              END

            
            print''
            print''
            print ' BRET..TRETIFRS apres maj CTRINCUWY_D '
            select T4.RETRECOD_D,T4.*
            FROM BRET..TRETCTR T1 , bret..TRETCTRVISA T2,  bret..TRETIFRS T4
            WHERE T1.RETCTRSTS_CT in (3,19,18,23)
            AND T1.RETCTR_NF = T4.RETCTR_NF 
            AND T1.RTY_NF = T4.RTY_NF
            AND T1.RETCTR_NF = T2.RETCTR_NF
            AND T1.RTY_NF = T2.RTY_NF
            AND T2.VISA_NT = 1
            AND T2.FSTVISA_D = T2.SNDVISA_D
            


-- ------------------- --
-- Fin transaction     --
-- ------------------- --
COMMIT TRAN
--ROLLBACK TRAN

fin:

go
