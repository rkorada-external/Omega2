USE BEST
go
IF OBJECT_ID('dbo.PsLIFDRI_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFDRI_01_O2
    IF OBJECT_ID('dbo.PsLIFDRI_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFDRI_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFDRI_01_O2 >>>'
END
go
/*
 * creation de la procedure 
*/

Create Procedure dbo.PsLIFDRI_01_O2 (@p_end_nt        UEND_NT,
                              @p_sec_nf        USEC_NF,
                              @p_uw_nt         UUW_NT,
                              @p_uwy_nf        UUWY_NF,
	                          @p_visu_mois     tinyint,
	                          @p_visu_an  	   smallint,
	                          @p_ctr_nf        UCTR_NF,
	                          @p_acc		   tinyint)
As

/***************************************************

Programme                   : ESSDRI01

Fichier script associï¿½      : BEST_PsLIFDRI_01_O2.prc

Domaine                     : (ES) Estimation

Base principale             : BEST

Version                     : 1

Auteur                      : L.DEBEVER

Date de creation            : 

Description du programme    : Sï¿½lection d'enregistrement dans TLIFDRI :  ESTIMATIONS VIE, 
                              cas oï¿½ type comptable = 1 ou 4 (annï¿½e de compte = exercice)

Parametres                  : @p_end_nt        UEND_NT,
                              @p_sec_nf        USEC_NF,
                              @p_uw_nt         UUW_NT,
                              @p_uwy_nf        UUWY_NF,
	                          @p_visu_mois     tinyint,
	                          @p_visu_an  	   smallint,
	                          @p_ctr_nf        UCTR_NF,
	                          @p_acc		   tinyint

Conditions d'execution      : 

Commentaires                :
_________________
MODIFICATION                : 1

Auteur                      : L.DEBEVER
Date                        : 22/04/1999
Version                     :
Description                 : Par dï¿½faut, maj auto des postes = non en rï¿½tro
_________________
MODIFICATION                : 2

Auteur                      : G.BUISSON
Date                        : 18/02/2003
Version                     :
Description                 : Ajout de la recherche de CONRETCTR_B sur BRET..TRETCTR si retro
                              si Acceptation CONRETCTR_B = 0
_________________
MODIFICATION                : 3

Auteur                      : G.BUISSON
Date                        : 16/06/2006
Version                     : V06.1
Description                 : Spot nï¿½ 12720 : En acceptation uniquement
                              Si contrat de rï¿½tro interne alors l'initialisation des AC inexistantes
                              doit se faire sans mise ï¿½ jour automatique (AUTUPD_B = 0)
_________________
MODIFICATION                : 4

Auteur                      : C.CROS
Date                        : 30/10/2012
Version                     : 
Description                 : OMEGA2 Correction of the request due to omega1 consistency issue. Initialization of popup should be according to the status of the estimations.

_________________

MODIFICATION                : 5

Auteur                      : A. Deshpande
Date                        : 27/02/2014
Version                     : 
Description                 : As per SGLA06 evo card 9 accounting years will displatyed

_________________

MODIFICATION                : 6

Auteur                      : A. Deshpande
Date                        : 25/04/2014
Version                     : 
Description                 : Added RESPROPAG_B  for EST22 Evo Card

_________________

MODIFICATION                : 7

Auteur                      : P.-E. Marx
Date                        : 12/01/2014
Version                     : 
Description                 : Modified default values in retrocession & assumed cases

MODIFICATION                : 8

Auteur                      : A. Deshpande
Date                        : 23/05/2015
Version                     : 
Description                 : EST 39 - Default values for retro / assume

*****************************************************/

Declare @erreur int,
	    @acy_nf_1    smallint,  	/* annï¿½es de compte : bilan - 4 -> bilan + 2 */
	    @acy_nf_2    smallint,
	    @acy_nf_3    smallint,
	    @acy_nf_4    smallint,
	    @acy_nf_5    smallint,
	    @acy_nf_6    smallint,
	    @acy_nf_7    smallint,
	    @acy_nf_8    smallint,
	    @acy_nf_9    smallint, /*modif 5 - 9 acc years   */
	    @cre_d       UUPD_D,
        @conretctr_b bit,
        @lstuwy_nf   UUWY_NF,        /* Dernier exercice valide de la section du traitï¿½ */
        @retro       bit,            /* Indicateur de rï¿½tro interne */
        @ced_nf      ucli_nf,
        @clissd_cf   ussd_cf

/*--------------------------------------------------*/
/* Crï¿½ation tables temporaires ----------------------*/
/*--------------------------------------------------*/

/* Liste  */           
Create Table #liste (ACY_NF        smallint,
                     AUTUPD_B      bit,
                     COMACC_B      bit,
                     CMT_NT        UCMT_NT,
                     CONRETCTR_B   bit,
					 RESPROPAG_B   bit,
					 SEGUPD_B	   bit)	 

/* Lifdri rï¿½duit                                      */
Create Table #TLIFDRI (ACY_NF      smallint,
	                   AUTUPD_B    bit,
                       COMACC_B    bit,
	                   CMT_NT      UCMT_NT,
	                   CRE_D       datetime,
					   RESPROPAG_B   bit,
					   SEGUPD_B	   bit)

/*--------------------------------------------------*/
/* Calcul annï¿½es de compte : bilan - 4 -> bilan + 2 */
/*--------------------------------------------------*/

 Select @acy_nf_1 = @p_visu_an - 4
 Select @acy_nf_2 = @p_visu_an - 3
 Select @acy_nf_3 = @p_visu_an - 2
 Select @acy_nf_4 = @p_visu_an - 1
 Select @acy_nf_5 = @p_visu_an 
 Select @acy_nf_6 = @p_visu_an + 1
 Select @acy_nf_7 = @p_visu_an + 2
 Select @acy_nf_8 = @p_visu_an + 3
 Select @acy_nf_9 = @p_visu_an + 4

-- Recherche du dernier exercice valide de la section

Select @lstuwy_nf = max(UWY_NF)
From   BTRT..TSECTION
Where  CTR_NF     = @p_CTR_NF
And    END_NT     = @p_END_NT
And    UW_NT      = @p_UW_NT
And    SEC_NF     = @p_SEC_NF
And    SECSTS_CT in (14,16,17,19)

-- Recherche conretctr_b dans la base traite retro
-- ainsi que l'indicateur de rï¿½tro interne

If @p_acc = 1
    Begin
        Select @conretctr_b = 0

        Select @ced_nf = CED_NF
        From   BTRT..TCONTR
        Where  CTR_NF = @p_ctr_nf
        And    UWY_NF = @lstuwy_nf

        Select @clissd_cf = CLISSD_CF
        From   BCLI..TCLIENT
        Where  CLI_NF = @ced_nf

        If @clissd_cf Is Not Null
            Begin
                Select @retro = 1       -- Rï¿½tro interne
            End
        Else
            Begin
                Select @retro = 0
            End
    End
Else
    Begin
        Select @retro = 0

        Select @conretctr_b = CONRETCTR_B
        From   BRET..TRETCTR
        Where  RETCTR_NF = @p_ctr_nf
        And    RTY_NF    = @p_uwy_nf
    End

/*--------------------------------------------------*/
/* Selection dans TLIFDRI : on ne prend par annï¿½e   */ 
/* de compte que les info correspondant ï¿½ la date   */
/* de crï¿½ation la plus rï¿½cente                      */
/*--------------------------------------------------*/

/* 1ï¿½re partie   */

Insert Into #TLIFDRI
Select ACY_NF,
       AUTUPD_B,
       COMACC_B,
       CMT_NT,
       CRE_D,
	   RESPROPAG_B,
	   SEGUPD_B
	   
From   BEST..TLIFDRI
Where  CTR_NF        = @p_ctr_nf
And    END_NT        = @p_end_nt
And    SEC_NF        = @p_sec_nf
And    UW_NT         = @p_uw_nt
And    ACY_NF       <= @acy_nf_9  
And    ACY_NF       >= @acy_nf_1
And    BALSHEY_NF    = @p_visu_an 
And    BALSHTMTH_NF <= @p_visu_mois



/* 2ï¿½me partie   */

Insert Into #liste 
Select a.ACY_NF,
	   a.AUTUPD_B,
	   a.COMACC_B,
	   a.CMT_NT,
       @conretctr_b,
	   a.RESPROPAG_B,
	   a.SEGUPD_B
From   #TLIFDRI a
Where  a.CRE_D = (Select Max(b.CRE_D)
   				  From   #TLIFDRI b		
     			  Where  b.ACY_NF = a.ACY_NF)

Select @erreur = @@error
If @erreur != 0
    Begin
        Raiserror 20003 "APPLICATIF;TLIFDRI"
        Return @erreur
    End

/*----------------------------------------------------*/
/* Crï¿½ation row vide dans Liste s'il n'y existe pas   */
/* avec maj auto des postes = oui (autupd_b = 1) en   */
/* acceptation;                                       */
/* non (autupd_b = 0) en rï¿½tro (modif 1)              */
/*----------------------------------------------------*/
/*                                                    */
/* Modif GIBU : Si rï¿½tro interne alors initialisation */
/* acceptation se fait avec autupd_b = 0              */
/*                                                    */
/*----------------------------------------------------*/

If @p_acc = 1
    Begin
        If @retro = 1
            Begin
                If Not Exists (Select Null 
                               From   #liste
			                   Where  ACY_NF = @acy_nf_1)
                    Insert Into #liste Values(@acy_nf_1, 0, 0, 0, @conretctr_b,0,0)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_2)
                    Insert Into #liste Values(@acy_nf_2, 0, 0, 0, @conretctr_b,0,0)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_3)
                    Insert Into #liste Values(@acy_nf_3, 0, 0, 0, @conretctr_b,0,0)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_4)
                    Insert Into #liste Values(@acy_nf_4, 0, 0, 0, @conretctr_b,0,0)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_5)
                    Insert Into #liste Values(@acy_nf_5, 0, 0, 0, @conretctr_b,0,0)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_6)
                    Insert Into #liste Values(@acy_nf_6, 0, 0, 0, @conretctr_b,0,0)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_7)
                    Insert Into #liste Values(@acy_nf_7, 0, 0, 0, @conretctr_b,0,0)
                    
                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_8)
                    Insert Into #liste Values(@acy_nf_8, 0, 0, 0, @conretctr_b,0,0)
                    
                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_9)
                    Insert Into #liste Values(@acy_nf_9, 0, 0, 0, @conretctr_b,0,0)
                        
            End
        Else
            Begin
                If Not Exists (Select Null 
                               From   #liste
			                   Where  ACY_NF = @acy_nf_1)
                    Insert Into #liste Values(@acy_nf_1, 1, 0, 0, @conretctr_b,0,0) -- Modif 4 - OMEGA2 Correction of OMEGA1 defect consistency -- MOD7 - Changed default value of AUTUPD_B boolean

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_2)
                    Insert Into #liste Values(@acy_nf_2, 1, 0, 0, @conretctr_b,0,0) -- Modif 4 - OMEGA2 Correction of OMEGA1 defect consistency -- MOD7 - Changed default value of AUTUPD_B boolean

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_3)
                    Insert Into #liste Values(@acy_nf_3, 1, 0, 0, @conretctr_b,0,0) -- Modif 4 - OMEGA2 Correction of OMEGA1 defect consistency -- MOD7 - Changed default value of AUTUPD_B boolean

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_4)
                    Insert Into #liste Values(@acy_nf_4, 1, 0, 0, @conretctr_b,0,0) -- Modif 4 - OMEGA2 Correction of OMEGA1 defect consistency -- MOD7 - Changed default value of AUTUPD_B boolean

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_5)
                    Insert Into #liste Values(@acy_nf_5, 1, 0, 0, @conretctr_b,0,0) -- Modif 4 - OMEGA2 Correction of OMEGA1 defect consistency -- MOD7 - Changed default value of AUTUPD_B boolean

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_6)
                    Insert Into #liste Values(@acy_nf_6, 1, 0, 0, @conretctr_b,0,0) -- Modif 4 - OMEGA2 Correction of OMEGA1 defect consistency -- MOD7 - Changed default value of AUTUPD_B boolean

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_7)
                    Insert Into #liste Values(@acy_nf_7, 1, 0, 0, @conretctr_b,0,0) -- Modif 4 - OMEGA2 Correction of OMEGA1 defect consistency -- MOD7 - Changed default value of AUTUPD_B boolean

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_8)
                    Insert Into #liste Values(@acy_nf_8, 1, 0, 0, @conretctr_b,0,0) -- Modif 4 - OMEGA2 Correction of OMEGA1 defect consistency -- MOD7 - Changed default value of AUTUPD_B boolean
                    
                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_9)
                    Insert Into #liste Values(@acy_nf_9, 1, 0, 0, @conretctr_b,0,0) -- Modif 4 - OMEGA2 Correction of OMEGA1 defect consistency -- MOD7 - Changed default value of AUTUPD_B boolean
                        
            End
    End
Else
    Begin
        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_1)
            Insert Into #liste Values(@acy_nf_1, 0, 0, 0, @conretctr_b,1,0) -- MOD7 - Changed default value of RESPROPAG_B boolean

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_2)
            Insert Into #liste Values(@acy_nf_2, 0, 0, 0, @conretctr_b,1,0) -- MOD7 - Changed default value of RESPROPAG_B boolean

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_3)
            Insert Into #liste Values(@acy_nf_3, 0, 0, 0, @conretctr_b,1,0) -- MOD7 - Changed default value of RESPROPAG_B boolean

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_4)
            Insert Into #liste Values(@acy_nf_4, 0, 0, 0, @conretctr_b,1,0) -- MOD7 - Changed default value of RESPROPAG_B boolean

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_5)
            Insert Into #liste Values(@acy_nf_5, 0, 0, 0, @conretctr_b,1,0) -- MOD7 - Changed default value of RESPROPAG_B boolean

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_6)
            Insert Into #liste Values(@acy_nf_6, 0, 0, 0, @conretctr_b,1,0) -- MOD7 - Changed default value of RESPROPAG_B boolean

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_7)
            Insert Into #liste Values(@acy_nf_7, 0, 0, 0, @conretctr_b,1,0) -- MOD7 - Changed default value of RESPROPAG_B boolean
            
        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_8)
            Insert Into #liste Values(@acy_nf_8, 0, 0, 0, @conretctr_b,1,0) -- MOD7 - Changed default value of RESPROPAG_B boolean
            
        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_9)
            Insert Into #liste Values(@acy_nf_9, 0, 0, 0, @conretctr_b,1,0) -- MOD7 - Changed default value of RESPROPAG_B boolean
                
    End

/*--------------------------------------------------*/
/* Select final                                     */
/*--------------------------------------------------*/

Select ACY_NF,
       AUTUPD_B,
       COMACC_B,
       CMT_NT,
       CONRETCTR_B,
	   RESPROPAG_B,
	   SEGUPD_B
From   #liste 
Order By ACY_NF

/*--------------------------------------------------*/
/* Destruction des tables temporaires               */
/*--------------------------------------------------*/

fin:
Drop Table #TLIFDRI

Return 0
go
EXEC sp_procxmode 'dbo.PsLIFDRI_01_O2', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFDRI_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFDRI_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFDRI_01_O2 >>>'
go
GRANT EXECUTE ON dbo.PsLIFDRI_01_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFDRI_01_O2 TO GDBBATCH
go
