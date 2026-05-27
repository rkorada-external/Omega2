USE BSAR
GO

/* DROP PROC dbo.PsETATCAC_04 */
IF OBJECT_ID('dbo.PsETATCAC_04') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsETATCAC_04
   PRINT '<<< DROPPED PROC dbo.PsETATCAC_04 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsETATCAC_04  (
                                @ParamDate datetime,
                                @P_Option int,
                                @AnneeBilan int,
                                @AnneSelect int
                                )
as

/***************************************************
Programme: PsETATCAC_04
Fichier script associé : BEST_PsETATCAC_04.PRC
Domaine : Estimations
Base principale : BSAR
Version: 1
Auteur: M.DJELLOULI / O.GIRAUX
Date de creation: 06/10/2005 M.DJELLOULI From O.GIRAUX 03/07/2002
Description du programme:  CF. BEST_PsETATCAC_04.PRC

Extraction des Données pour les Etats CACS. RETRO
Appelées plusiseurs Fois pour Plusieurs fichiers qui seront retraités par la suite par une Macro Excel.
Parametres:
Conditions d'execution:
Commentaires:
        La Proc est appelée dans 2 itérations :
            - La 1ère itération est "standard", c'est à dire qu'elle sera appelée constamment X Fois.
                        AnnéeSelect = 0
                        Itération (P_Option > 0)
            - La 2nd itération est évolutive, c'est à dire qu'elle sera appelée à partir de l'année 2001 jusque l' AnnéeBilan
                        AnnéeSelect > 0
                        Itération (P_Option = 0)
_________________
MODIFICATION 1
Auteur:    J. Ribot
Date:     14/06/2007
Version:
Description:  SPOT 14170 ajout filiale 05 07   02/10/2007 14170/2 filiale 6 pour 3T 2007

MODIFICATION 2
Auteur:    J. Ribot
Date:     06/03/2008
Version:
Description:  SPOT 15149   ajout test sur CTR_NF = ' '  dans  Sélection "Standard" - Non affectes

_________________
MODIFICATION 3

 10/10/2008    JFVDV  [SPOT16159] Dans le cadre de l'ajout de la colonne établissement (ESB_CF) dans la table
                      btravi..EST_ESID7100_ETATCACR après la colonne filiale (SSD_CF), il est nécessaire de compiler et de livrer la procédure
_________________
MODIFICATION 4

 14/11/2008    JFVDV  [SPOT16438] Ajout de la filiale 17
_________________
MODIFICATION    [005]
Auteur :        D.GATIBELZA
Date :          06/04/2009
Version:        9.1
Description :   ESTDOM17162 Etats CAC  inclure le témoin IFRS
                Juste une recompil pour réactualiser le select *.
_________________
MODIFICATION    [006]
Auteur :        Ph. VESSIERE
Date :          29/06/2009 (DD/MM/YYYY)
Version:        9.1
Description :   [SPOT17610] - ESTDOM - EVOLUTIONS SUR FICHIER CAC 2Q2009
*****************************************************/

-- --------------------------------------------------------------------
-- Définition Variables
-- --------------------------------------------------------------------

declare @erreur int
declare @RetourProc     int
declare @MsgErreur char(256)
declare @SuffixeTable char(1)

declare @AnneeDebut int
declare @AnneeFin int

-- Vérification Préliminaire des Paramètres

if ((@AnneeBilan = 0) or (@AnneeBilan = null))
    Begin
         Select @MsgErreur="Paramètre : Année Bilan Non renseignée"
         goto ErreurCAC
    End

--------------------------------------------------------------
-- SELECTION FINALE
--------------------------------------------------------------

if (@P_Option = 1)                  -- Sélection "Standard" - Non affectes
    Begin
        If Exists (select 1 from BTRAVI..EST_ESID7100_ETATCACR
                   where (uwy_nf = NULL or uwy_nf = 0) or CTR_NF = ' ')
        select * from BTRAVI..EST_ESID7100_ETATCACR
        where (uwy_nf = NULL or uwy_nf = 0) or CTR_NF = ' '

        if @@error != 0
           begin
             Select @MsgErreur="Erreur sur Sélection Option 1 - Non Affectés"
             goto ErreurCAC
           end

        goto fin
    End


if (@P_Option = 2)                  -- Sélection "Standard" - Filiale 3
    Begin

        --  Scor : tous les exercices
        If Exists (select 1 from BTRAVI..EST_ESID7100_ETATCACR
                   where ctr_nf like "0[3567]%" or ctr_nf like '17%')                                      --  SPOT 14170 filiale 03 05 07  02/10/2007 14170/2 filiale 6 pour 3T 2007 + [SPOT16438] Ajout de la filiale 17
        -- [SPOT14170] - filiale 03 05 07   02/10/2007 14170/2 filiale 6 pour 3T 2007 + [SPOT16438] Ajout de la filiale 17
        -- [SPOT17610] - Add subsidary 01 (= Filiale 1) => ctr_nf like "0[1]%"
        select * from BTRAVI..EST_ESID7100_ETATCACR where ctr_nf like "0[13567]%" or ctr_nf like '17%'
        order by ssd_cf, ctr_nf, sec_nf, uwy_nf

        if @@error != 0
           begin
             Select @MsgErreur="Erreur sur Sélection Option 2 - Filliale 1 3 5 6 7 17"
             goto ErreurCAC
           end

        goto fin
    End


If (@P_Option = 0)
Begin
    If (@AnneSelect = @AnneeBilan)          -- Dernière Année, on prend 'Large'
        Begin
            Select @AnneeDebut=@AnneeBilan
            Select @AnneeFin=9999
        End
    Else
        Begin
            Select @AnneeDebut=@AnneSelect
            Select @AnneeFin=@AnneSelect
        End
End


if (@P_Option > 2)                  -- Sélection "Standard" par Itération P_Option
    Begin

        If @P_Option = 3                                        -- 1. 1ère Sélection on prend < 1988
        Begin
            Select @AnneeDebut=1
            Select @AnneeFin=1994
        End

        If @P_Option = 4                                        -- 2. 1988 <= UWY <= 1992
        Begin
            Select @AnneeDebut=1995
            Select @AnneeFin=1997
        End

        If @P_Option = 5                                        -- 3. 1993 <= UWY <= 1994
        Begin
            Select @AnneeDebut=1998
            Select @AnneeFin=2001
        End

        If @P_Option = 6                                        -- 4. Scor Reass : 1995, 1996
        Begin
            Select @AnneeDebut=2002
            Select @AnneeFin=2003
        End

    End

-- Selection pour la Filiale 2
If ((@P_Option = 0) OR (@P_Option > 2))
Begin
        If Exists (select 1 from BTRAVI..EST_ESID7100_ETATCACR
                   WHERE CTR_NF LIKE "02%"
            and UWY_NF BETWEEN @AnneeDebut and @AnneeFin)
        SELECT * FROM BTRAVI..EST_ESID7100_ETATCACR
        WHERE CTR_NF LIKE "02%"
            and UWY_NF BETWEEN @AnneeDebut and @AnneeFin
        order by CTR_NF, SEC_NF, UWY_NF
End
goto fin

ErreurCAC:
    Raiserror 20006 , "Erreur : " , @MsgErreur
    return 1

fin:
return 0
go

exec sp_SCOR_INSPRC 'ETACAC02', 'PsETATCAC_04', 'BSAR', 'ME57'
go

IF OBJECT_ID('dbo.PsETATCAC_04') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsETATCAC_04 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsETATCAC_04 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PsETATCAC_04
 */
GRANT EXECUTE ON dbo.PsETATCAC_04 TO GOMEGA
go
