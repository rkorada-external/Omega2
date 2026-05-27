USE BRET
GO

-- --------------------------------------------------------------------------------------------- --
-- Script           : RET100876_UPDATE_TRETCTR_POPULATE_CTRINCUWY_D.sql
-- Domaine          : RETROCESSION
-- Base Principale  : BRET  
-- Auteur           : B. Lagha
-- Date de création : 06/12/2021
-- SPIRA            : 100876 - > Populate UWY Inception date (BRET..TRETCTR). 
-- Modifie par      : B. Lagha le 06/12/2021
-- --------------------------------------------------------------------------------------------- --

DECLARE
  @erreur      int,
  @trans_etat  int,
  @ctr_nbr     int,
  @p_spira     varchar(7),
  @user_cf     char(4)
  
SELECT @p_spira = '100876'

PRINT 'START'

-- --------------------------------------------------- --
-- check for number of ctr that have empty CTRINCUWY_D --
-- --------------------------------------------------- --
SELECT @ctr_nbr = COUNT(DISTINCT RETCTR_NF)
FROM BRET..TRETCTR
WHERE (
      CTRINCUWY_D  in (null, '')
      or (year(CTRINC_D) >= RTY_NF and CTRINC_D != CTRINCUWY_D)
    )

-- traiter code retour  --
SELECT @erreur = @@error
IF @erreur != 0 
BEGIN
  PRINT '<<< BEFORE UPDATE - PROBLEM OF TRETCTR SELECT - ERROR : %1! >>>', @erreur
  GOTO end_
END
ELSE
  PRINT 'NUMBER OF CONTRACTS THAT HAVE AN EMPTY/WRONG CTRINCUWY_D : %1!', @ctr_nbr



-- ==========================================================================
-- Update CTRINCUWY_D by CTRINC_D if under writing year is the first  year --
-- Else 01/01/UWY
-- ==========================================================================
-- User Name --
-- --------- --
IF @p_spira != null and @p_spira != ''
BEGIN
  IF len(@p_spira) <= 4
    SELECT @user_cf = @p_spira
  ELSE 
    SELECT @user_cf = (substring(@p_spira, len(@p_spira) - 3, 4))
END


-- ---------------------- --
-- Begin of the traitment --
-- ---------------------- --
-- Attention si nous avons beaucoup de lignes alors il faut faire le update 
-- par block (utiliser des locks) 
BEGIN TRAN

UPDATE BRET..TRETCTR
  set
    CTRINCUWY_D = (
      case 
        when RTY_NF = year(CTRINC_D) then CTRINC_D
        else '01/01/' + ( cast(RTY_NF as char(4)) )
      end
    ),
	LSTUPDUSR_CF = @user_cf,
	LSTUPD_D = getdate()
FROM BRET..TRETCTR 
WHERE CTRINC_D not in (null, '')
  and (
      CTRINCUWY_D  in (null, '')
      --or (year(CTRINC_D) >= RTY_NF and CTRINC_D != CTRINCUWY_D)
    )
  
-- traiter code retour  --
SELECT @erreur = @@error, @trans_etat = @@transtate
IF @erreur != 0 OR @trans_etat > 1
BEGIN
  -- Cancel changes
  ROLLBACK TRAN
  PRINT '<<< UPDATING FAILURE - PROBLEM OF TRETCTR UPDATE - ERROR : %1! >>>', @erreur
  PRINT '<<< CANCEL ALL CHANGES >>>'
  GOTO end_
END

-- if no error -> Write all changes
COMMIT TRAN

PRINT '<<< UPDATING SUCCESSFUL - ALL CTRINCUWY_D = NULL ARE UPDATED >>>'
-- -------------------- --
-- END of the traitment --
-- -------------------- --
-- ==========================================================================



-- --------------------------------------------------------- --
-- check for number of ctr that still have empty CTRINCUWY_D --
-- --------------------------------------------------------- --
SELECT @ctr_nbr = COUNT(DISTINCT RETCTR_NF)
FROM BRET..TRETCTR
WHERE (
      CTRINCUWY_D  in (null, '') 
      or (year(CTRINC_D) >= RTY_NF and CTRINC_D != CTRINCUWY_D)
    )

-- traiter code retour  --
SELECT @erreur = @@error, @trans_etat = @@transtate
IF @erreur != 0 OR @trans_etat > 1
BEGIN
  PRINT '<<< AFTER UPDATE - PROBLEM OF TRETCTR SELECT - ERROR : %1! >>>', @erreur
END
ELSE
  PRINT 'NUMBER OF CONTRACTS THAT STILL HAVE AN EMPTY/WRONG CTRINCUWY_D : %1!', @ctr_nbr


end_:
PRINT 'END'
	
go

