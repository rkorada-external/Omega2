USE BREF
GO

/********************************************************************************************/
/* No control between the Program n° and the subsidiary of the contract. 56800 */
/*                                                                                          */
/*                          D. BERTE 23/10/2019                                        */
/********************************************************************************************/

SET nocount ON -- ne pas indiquer le nombre de lignes affectees

DECLARE @msg varchar(200)

SELECT @msg=@@servername + ' => ' + host_name()

PRINT @msg

SELECT @msg='Start Updating reference number '
       + CONVERT(char(10), getdate(), 103)
       + ' '
       + CONVERT(char(8), getdate(), 8)
       + SUBSTRING(CONVERT(char(27), getdate(), 109), 21, 6)

PRINT @msg
go

BEGIN TRAN

    DECLARE @erreur         int
          , @trans_etat     int
          , @cmt_nt         int

    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 903 AND MESSTHM_C = "RETRO" AND LANG_C = "E"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('E','RETRO',903,'Assistance Entries are existing for the current or the previous quarter for this Retrocession Contract.',1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 903 AND MESSTHM_C = "RETRO" AND LANG_C = "F"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('F','RETRO',903,'Des écritures de service existent sur ce contrat de rétrocession pour le trimestre en cours ou pour le trimestre précédent',1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 906 AND MESSTHM_C = "RETRO" AND LANG_C = "E"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('E','RETRO',906,'Complete accounts are not done on this Retrocession Contract',1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 906 AND MESSTHM_C = "RETRO" AND LANG_C = "F"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('F','RETRO',906,'Les comptes ne sont pas complets pour ce contrat de rétrocession',1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 901 AND MESSTHM_C = "RETRO" AND LANG_C = "E"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('E','RETRO',901,'This Retrocession Contract is used in a valid Retrocession Plan',1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 901 AND MESSTHM_C = "RETRO" AND LANG_C = "F"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('F','RETRO',901,'Ce contrat de rétrocession est utilisé sur un plan valide.',1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 902 AND MESSTHM_C = "RETRO" AND LANG_C = "E"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('E','RETRO',902,'Do you want to record all cessions for this Retrocession Contract Underwriting Year?',1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 902 AND MESSTHM_C = "RETRO" AND LANG_C = "F"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('F','RETRO',902,'Souhaitez-vous historiser toutes les cessions pour cet exercice ?',1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 904 AND MESSTHM_C = "RETRO" AND LANG_C = "E"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('E','RETRO',904,'Do you want to delete all awaiting transactions for this Retrocession Contract Underwriting Year?',1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 904 AND MESSTHM_C = "RETRO" AND LANG_C = "F"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('F','RETRO',904,"Souhaitez-vous supprimer l\'ensemble des transactions en attente pour cet exercice?",1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 900 AND MESSTHM_C = "RETRO" AND LANG_C = "E"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('E','RETRO',900,'Reserves or financial elements still exist on this Retrocession Contract.',1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 900 AND MESSTHM_C = "RETRO" AND LANG_C = "F"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('F','RETRO',900,"Il existe des provisions ou des éléments financiers sur ce contrat de rétrocession.",1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 899 AND MESSTHM_C = "RETRO" AND LANG_C = "E"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('E','RETRO',899,'Reserves or financial elements still exist for this underwriting year',1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE'
	
    -- init erreur
    select @erreur = 0
    
    PRINT''
    PRINT 'Insertion dans TMESSAGE'
		delete BREF..TMESSAGE WHERE MESS_N = 899 AND MESSTHM_C = "RETRO" AND LANG_C = "F"
        insert into BREF..TMESSAGE 
		(LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T)
		values('F','RETRO',899,"Il existe des provisions ou des éléments financiers sur cet exercice",1, 0)
        -- récuperer codes retour insert --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'insert into BREF..TMESSAGE (LANG_C,MESSTHM_C,MESS_N,MESS_L,ICON_T,BUTT_T) - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
             
       PRINT''
    PRINT 'Insertion dans TMESSAGE' 
        
COMMIT TRAN
-- ROLLBACK TRAN

fin:
GO

DECLARE @msg varchar(200)

SELECT @msg='End Updating reference number '
       + convert(char(10),getdate(),103)
       + ' '
       + convert(char(8),getdate(),8)
       + ' '
       + substring(convert(char(27),getdate(),109),21,6)

PRINT @msg

SET nocount OFF
GO                          
