Use BSTA
go

/*
   DROP PROC dbo.PtTBOPAR_01.prc
*/

IF OBJECT_ID('dbo.PtTBOPAR_01') IS NOT NULL
BEGIN
     DROP PROC dbo.PtTBOPAR_01
     PRINT '<<< DROPPED PROC dbo.PtTBOPAR_01 >>>'
END
go

/*
 * Création de la Procédure
*/

Create Procedure PtTBOPAR_01 (@USR_CF        UUSR_CF,
                              @CLOPER_LS     Varchar(1),
                              @BALSHEYEA_NF  Smallint,
                              @BALSHTMTH_NF  Tinyint,
                              @CLODAT_D		Char(8))
As
/***************************************************

Programme                : PtTBOPAR_01
Fichier script associé   : BSTA_PtTBOPAR_01.prc
Domaine                  : Estimation
Base principale          : BSTA
Version                  : 1
Auteur                   : O.GIRAUX
Date de creation         : 09/07/2001
Description du programme : Mise a jour ou insert dans BSAR..TBOPAR. Dans ce cas l'utilisateur a fait une demande de type Z.
                           Lorsque l'utilisateur est autorisé et qu'il a spécifié un suffixe de table parmi A->F:
                           Prenons l'ex où CLOPER_LS vaut E:

                              Si il existe deja des lignes pour les tables XXXXXX_E
                                   Si la periode d'inventaire de ces lignes correspond aux parametres et que LSTUPD_D <> NULL
                                        => on ne fait rien, la periode d'inventaire a deja tourne sur ces tables
                                   Sinon, on met a jour les lignes avec la periode d'inventaire passee en parametre.
                              Sinon On insere l'ensemble des lignes correspond aux "E tables".
Parametres               :
Conditions d'execution   :
Commentaires             :
______________
MODIFICATION             : [01] MOD01

Auteur                   : O/GIRAUX
Date                     : 26/08/2003
Description              : La table TRETCOMP est à présent également déclinée en tables de A à F. ( alors qu'elle
                           n'existait jusqu'alors que sous la forme TRETCOMP_A) => réécriture de la proc en utilisant un curseur
                           attaquant chaque table.
_____________
MODIFICATION             : [02] MOD02

Auteur                   : M. DJELLOULI
Date                     : 30/04/2004
Description              : Si l'on demande une modification d'une nouvelle table pour une autre table existante déjà sur la même période,
                           on historise la table, et on effectue la modification.
_____________
MODIFICATION             : [03]

Auteur                   : G. BUISSON
Date                     : 06/11/2008
Description              : Spot 16406 : Ajout d'un Order By lors de la création du curseur car depuis le passage en ASE15
                                        et le changement de serveur, seule la dernière ligne était modifiée.
[004] 03/04/2013 Philippe Pezout :spot:25057 - suppression du controle autorisation des demandes Z dans la table BREF..TBANTECL
*****************************************************/

Declare @erreur          Int,
        @tran_imbr       Bit,
        @tab_cf          Char(20),
        @tab_code_find   Char(1)                       -- [02]

Select @erreur    = 0
Select @tran_imbr = 1

/* -----------------------------------------------------------
	Début de la transaction
   ----------------------------------------------------------- */

If @@trancount = 0
     Begin
          Select @tran_imbr = 0
          BEGIN TRAN
     End

/* [004]
If (Exists (Select 1
            From   BREF..TBANTECL
            Where  COLVAL_CT   = @USR_CF
            And    COL_LS      = "CLOLOAUSR_CF")
And @CLOPER_LS In ("A", "B", "C", "D", "E", "F"))
*/

If (@CLOPER_LS In ("A", "B", "C", "D", "E", "F"))
     Begin
          /*declaration et ouverture du curseur*/

          /* recuperation des tables ESTIMATION déclinée en _A :
          Le curseur "Tables_cur01" va contenir:
          TTECLEDA
          TTECLEDR
          TCTRSTAT
          TSEGSTAT
          TTECLEDASNEM
          TTECLEDRSNEM
          TRETCOMP
          */

          -- Début [02]
          Select Distinct @tab_code_find = Right(TABCIBLE_CF, 1)
          From   BSAR..TBOPAR
          Where  Right(TABCIBLE_CF, 1) In ('A', 'B', 'C', 'D', 'E', 'F')
          And    PAR_D                 Is NULL
          And    FIELD1_CF              = Convert(Char(6), @BALSHEYEA_NF * 100 + @BALSHTMTH_NF)
          And    FIELD2_CF              = @CLODAT_D
          And    Right(TABCIBLE_CF, 1) != @CLOPER_LS

          -- Mise a jour de la table en Historisé
          If @@rowcount <> 0
               Begin
                    Update BSAR..TBOPAR
                    Set    PAR_D = Getdate()
                    Where  Right(TABCIBLE_CF, 1) In ('A', 'B', 'C', 'D', 'E', 'F')
                    And    PAR_D                 Is NULL
                    And    FIELD1_CF              = Convert(Char(6), @BALSHEYEA_NF * 100 + @BALSHTMTH_NF)
                    And    FIELD2_CF              = @CLODAT_D
                    And    Right(TABCIBLE_CF, 1)  = @tab_code_find

                    Update BSAR..TBOPAR
                    Set    PAR_D = Getdate()
                    Where  Right(TABCIBLE_CF, 1) In ('A', 'B', 'C', 'D', 'E', 'F')
                    And    PAR_D                 Is NULL
                    And    Right(TABCIBLE_CF, 1)  = @CLOPER_LS
               End
          -- Fin [02]

          Declare Tables_cur01 Cursor For
               Select TAB_CF
               From   BSAR..TBOPAR
               Where  DMN_CF         = "EST"
               And    TABCIBLE_CF Like "%_A"
               Order By TAB_CF                              -- [03]
          For Read Only

          -- Ouverture curseur
          Open Tables_cur01
          If @@error !=0
               Begin
                    Raiserror 20005 "error on open cursor"
                    Goto erreur
               End


          -- Lecture initiale
          Fetch Tables_cur01 Into @tab_cf
          If @@error !=0
               Begin
                    Raiserror 20005 "error on fetch cursor"
                    Goto erreur
               End

          -- Boucle sur chaque nom de table
          While (@@sqlstatus = 0)
               Begin
                    If Exists (Select 1
                               From   BSAR..TBOPAR
                               Where  DMN_CF       = "EST"
                               And    TABCIBLE_CF  = Rtrim(@tab_cf) + "_" + @CLOPER_LS    -- Ex TTECLEDA_A
                               And    PAR_D       Is NULL)
                         Begin
                              -- Si ce n'est déjà fait, on update les périodes et dates d'inventaire
                              Update BSAR..TBOPAR
                              Set    FIELD1_CF    = Convert(Char(6), @BALSHEYEA_NF * 100 + @BALSHTMTH_NF),
                                     FIELD2_CF    = @CLODAT_D,
	                                LSTUPDUSR_CF = NULL,
                                     LSTUPD_D     = NULL
                              From   BSAR..TBOPAR A
                              Where  A.DMN_CF     = "EST"
                              And    TABCIBLE_CF  = Rtrim(@tab_cf) + "_" +@CLOPER_LS      --rtrim supprime les blancs à dte
                              And    PAR_D       Is NULL
                              And    Not Exists   (Select 1
                                                   From   BSAR..TBOPAR B
     	                  		                Where  B.DMN_CF       = "EST"
                                                   And    B.PAR_D       Is NULL
                   		                          And    B.TABCIBLE_CF  = Rtrim(@tab_cf) + "_" + @CLOPER_LS
            			                          And    B.FIELD1_CF    = Convert(Char(6), @BALSHEYEA_NF * 100 + @BALSHTMTH_NF)
                           			           And    B.FIELD2_CF    = @CLODAT_D
                         			           And    B.LSTUPD_D    Is Not Null)

                              If @@error !=0
                                   Begin
                                        Raiserror 20002 "Pb dans Update BSAR..TBOPAR "
                                        Goto erreur
                                   End
                         End

                    Else     -- Si la déclinaison de la table manque
                         Begin
                              Insert Into BSAR..TBOPAR Values ('EST', Rtrim(@tab_cf), Convert(Char(6), @BALSHEYEA_NF * 100 + @BALSHTMTH_NF),
                                                               @CLODAT_D, NULL, Rtrim(@tab_cf) + "_" + @CLOPER_LS, 0, NULL, NULL, NULL, NULL)
                              If @@error !=0
                                   Begin
                                        Raiserror 20003 "Pb dans insert BSAR..TBOPAR "
                                        Goto erreur
                                   End
                         End

    	               Fetch Tables_cur01 Into @tab_cf
               End	 -- Fin de la boucle sur chaque table

          Close Tables_cur01
          Deallocate Cursor Tables_cur01
     End   -- Fin du test autorisation des users

If @tran_imbr = 0
     COMMIT TRAN
RETURN 0

erreur:
If @tran_imbr = 0
     ROLLBACK TRAN
RETURN -1
go

IF OBJECT_ID('dbo.PtTBOPAR_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtTBOPAR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtTBOPAR_01 >>>'
go

/* Granting/Revoking Permissions on dbo.PtTBOPAR_01 */
Grant EXECUTE On dbo.PtTBOPAR_01 TO GOMEGA
go
