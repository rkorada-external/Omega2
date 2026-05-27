Use BSTA
go

If OBJECT_ID('PuTSUIVINTACC_06') Is Not Null
Begin
    Drop Procedure PuTSUIVINTACC_06
    If OBJECT_ID('PuTSUIVINTACC_06') Is Not Null
        Print '<<< FAILED DROPPING PROCEDURE PuTSUIVINTACC_06 >>>'
    Else
        Print '<<< DROPPED PROCEDURE PuTSUIVINTACC_06 >>>'
End
go

Create Procedure PuTSUIVINTACC_06 (@p_APPLI    UMESSTHM_C,
                                   @p_SSD      USSD_CF,
                                   @p_ESB      UESB_CF,
                                   @p_NUMFIC   UUWENTNBR_NT)
with execute as caller as
/*********************************************************************************************************
Programme               : PuTSUIVINTACC_06
Domaine                 : COMPTA TECHNIQUE
Base principale         : BSTA
Fiche spot              : 23860
                        :spot:23860     LRAK
Version                 : 1
Auteur                  : LRAK (ASCOTT)
Date de creation        : 24/07/2012
Functional Description  : Update BSTA..TSUIVINTACC from BTRAVI..BSTA_TSUIVINTACC amount.

Input Parameters        : @p_APPLI  : Application
                          @p_SSD    : Subsidiary
                          @p_ESB    : Subledger
                          @p_NUMFIC : File number

Output Parameters       : => no error : 0
                          => with error : -1
_________________
MODIFICATION            : 1

Auteur                  : G. BUISSON
Date                    : 19/09/2012
Version                 : V12.1
Description             : Intégration de la partie "Sinistre"
----------------------------------------------------------------------
Modification - Removed dbo and added ‘with execute as caller as’                           
**********************************************************************************************************/

-- ------------------------- --
-- Declaration des variables --
-- ------------------------- --
Declare @erreur     Int,
        @tran_imbr	Bit,
        @trans_etat Int,
        @v_step     Char(02),
        @p_erreur   Varchar(250),
        @famille    UMESSTHM_C

-- Initialiser des variables
Select @erreur    = 0, 
       @tran_imbr = 1,
       @famille   = @p_APPLI

If @@trancount = 0
Begin
    Select @tran_imbr = 0
    BEGIN TRAN
End
 
If (@p_APPLI = 'SIN')
Begin
    Select @famille = 'CTA'
End
    
--- update BSTA..TSUIVINTACC --
Select @v_step = '10'
     
Update BSTA..TSUIVINTACC
Set    a.POSAMT_M = b.POSAMT_M,
       a.NEGAMT_M = b.NEGAMT_M,
       a.BLCSHT_D = b.BLCSHT_D
From   BSTA..TSUIVINTACC a, BTRAVI..BSTA_TSUIVINTACC b
Where  a.SSD_CF      = b.SSD_CF
And    a.ESB_CF      = b.ESB_CF
And    a.NUMFIC_NT   = b.NUMFIC_NT
And    a.MESSTHM_C   = @p_APPLI
AND    b.MESSTHM_C   = @famille
And    a.SSD_CF      = @p_SSD
And    a.ESB_CF      = @p_ESB
And    a.NUMFIC_NT   = @p_NUMFIC
 
-- Traiter code retour update --
Select @erreur = @@error, @trans_etat = @@transtate
If @erreur != 0 Or @trans_etat > 1
Begin
    Select @p_erreur = 'Update BSTA..TSUIVINTACC - Code SQL: ' + Convert(Char(5), @erreur)
    Goto fin
End                

-- SORTIE NORMALE : Validation et Envoi retour
If @tran_imbr = 0
Begin
    COMMIT TRAN
End

Return 0
   
-- SORTIE BRUTALE : Marche arriere et Envoi retour
fin:

If @tran_imbr = 0
Begin
    ROLLBACK TRAN
End

Select @p_erreur = 'Error BSTA_PuTSUIVINTACC_06 - Step: ' + @v_step + @p_erreur
Print @p_erreur

Return -1
go

Exec sp_procxmode 'PuTSUIVINTACC_06', 'unchained'
go

If OBJECT_ID('PuTSUIVINTACC_06') Is Not Null
    Print '<<< CREATED PROCEDURE PuTSUIVINTACC_06 >>>'
Else
    Print '<<< FAILED CREATING PROCEDURE PuTSUIVINTACC_06 >>>'
go

Grant EXECUTE On PuTSUIVINTACC_06 To GOMEGA
go
