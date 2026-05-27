Use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsLIFDRI_02
*/

IF OBJECT_ID('dbo.PsLIFDRI_02') IS NOT NULL
BEGIN
   DROP PROC dbo.PsLIFDRI_02
   PRINT '<<< DROPPED PROC dbo.PsLIFDRI_02 >>>'
END
go

/*
 * creation de la procedure 
*/

Create Procedure PsLIFDRI_02 (@p_end_nt        UEND_NT,
                              @p_sec_nf        USEC_NF,
                              @p_uw_nt         UUW_NT,
                              @p_uwy_nf        UUWY_NF,
	                          @p_visu_mois     tinyint,
	                          @p_visu_an  	   smallint,
	                          @p_ctr_nf        UCTR_NF,
	                          @p_acc		   tinyint)
As

/***************************************************

Programme                   : ESSDRI02

Fichier script associé      : BEST_PsLIFDRI_02.prc

Domaine                     : (ES) Estimation

Base principale             : BEST

Version                     : 1

Auteur                      : L.DEBEVER

Date de creation            : 

Description du programme    : Sélection d'enregistrement dans TLIFEST : ESTIMATIONS VIE: 
                              Correspond à type comptable <> 1 et <> 4 et à un exercice donné.

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
Description                 : Par défaut, maj auto des postes = non en rétro
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
Description                 : Spot n° 12720 : En acceptation uniquement
                              Si contrat de rétro interne alors l'initialisation des AC inexistantes
                              doit se faire sans mise à jour automatique (AUTUPD_B = 0)

*****************************************************/

Declare @erreur int,
	    @acy_nf_1    smallint,  	/* années de compte : bilan - 4 -> bilan + 2 */
	    @acy_nf_2    smallint,
	    @acy_nf_3    smallint,
	    @acy_nf_4    smallint,
	    @acy_nf_5    smallint,
	    @acy_nf_6    smallint,
	    @acy_nf_7    smallint,
	    @cre_d       UUPD_D,
        @lstuwy_nf   UUWY_NF,        /* Dernier exercice valide de la section du traité */
        @conretctr_b bit,
        @retro       bit,            /* Indicateur de rétro interne */
        @ced_nf      ucli_nf,
        @clissd_cf   ussd_cf

/*--------------------------------------------------*/
/* Création tables temporaires ----------------------*/
/*--------------------------------------------------*/

/* Liste  */           
Create Table #liste (ACY_NF       smallint,
                     AUTUPD_B     bit,
                     COMACC_B     bit,
                     CMT_NT       UCMT_NT,
                     CONRETCTR_B  bit)	 

/* Lifdri réduit                                      */
Create Table #TLIFDRI (ACY_NF      smallint,
	                   UWY_NF      UUWY_NF,
	                   AUTUPD_B    bit,
                       COMACC_B    bit,
	                   CMT_NT      UCMT_NT,
	                   CRE_D       datetime)

/*--------------------------------------------------*/
/* Calcul années de compte : bilan - 4 -> bilan + 2 */
/*--------------------------------------------------*/
 Select @acy_nf_1 = @p_visu_an - 4
 Select @acy_nf_2 = @p_visu_an - 3
 Select @acy_nf_3 = @p_visu_an - 2
 Select @acy_nf_4 = @p_visu_an - 1
 Select @acy_nf_5 = @p_visu_an 
 Select @acy_nf_6 = @p_visu_an + 1
 Select @acy_nf_7 = @p_visu_an + 2

 -- Recherche du dernier exercice valide de la section

Select @lstuwy_nf = max(UWY_NF)
From   BTRT..TSECTION
Where  CTR_NF     = @p_CTR_NF
And    END_NT     = @p_END_NT
And    UW_NT      = @p_UW_NT
And    SEC_NF     = @p_SEC_NF
And    SECSTS_CT in (14,16,17,19)

-- Recherche conretctr_b dans la base traite retro
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
                Select @retro = 1
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
/* Selection dans TLIFDRI : on ne prend poar année  */ 
/* de compte que les info correspondant à la date   */
/* de création la plus récente                      */
/*--------------------------------------------------*/

/* 1ère partie   */

Insert Into #TLIFDRI
Select ACY_NF,
	   UWY_NF,
       AUTUPD_B,
       COMACC_B,
       CMT_NT,
       CRE_D	
From   BEST..TLIFDRI
Where  CTR_NF        = @p_ctr_nf
And    END_NT        = @p_end_nt
And    SEC_NF        = @p_sec_nf
And    UW_NT         = @p_uw_nt
And    ACY_NF       <= @acy_nf_7  
And    ACY_NF       >= @acy_nf_1
And    BALSHEY_NF    = @p_visu_an 
And    BALSHTMTH_NF <= @p_visu_mois

/* 2ème partie   */

Insert Into #liste 
Select a.ACY_NF,
	   a.AUTUPD_B,
	   a.COMACC_B,
	   a.CMT_NT,
       @conretctr_b
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
/* Création row vide dans Liste s'il n'y existe pas   */
/* avec maj auto des postes = oui (autupd_b = 1) en   */
/* acceptation;                                       */
/* non (autupd_b = 0) en rétro (modif 1)              */
/*----------------------------------------------------*/
/*                                                    */
/* Modif GIBU : Si rétro interne alors initialisation */
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
                    Insert Into #liste Values(@acy_nf_1, 0, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_2)
                    Insert Into #liste Values(@acy_nf_2, 0, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_3)
                    Insert Into #liste Values(@acy_nf_3, 0, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_4)
                    Insert Into #liste Values(@acy_nf_4, 0, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_5)
                    Insert Into #liste Values(@acy_nf_5, 0, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_6)
                    Insert Into #liste Values(@acy_nf_6, 0, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_7)
                    Insert Into #liste Values(@acy_nf_7, 0, 0, 0, @conretctr_b)
            End
        Else
            Begin
                If Not Exists (Select Null 
                               From   #liste
			                   Where  ACY_NF = @acy_nf_1)
                    Insert Into #liste Values(@acy_nf_1, 1, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_2)
                    Insert Into #liste Values(@acy_nf_2, 1, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_3)
                    Insert Into #liste Values(@acy_nf_3, 1, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_4)
                    Insert Into #liste Values(@acy_nf_4, 1, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_5)
                    Insert Into #liste Values(@acy_nf_5, 1, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_6)
                    Insert Into #liste Values(@acy_nf_6, 1, 0, 0, @conretctr_b)

                If Not Exists (Select Null 
                               From   #liste
			                   Where ACY_NF = @acy_nf_7)
                    Insert Into #liste Values(@acy_nf_7, 1, 0, 0, @conretctr_b)
            End
    End
Else
    Begin
        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_1)
            Insert Into #liste Values(@acy_nf_1, 0, 0, 0, @conretctr_b)

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_2)
            Insert Into #liste Values(@acy_nf_2, 0, 0, 0, @conretctr_b)

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_3)
            Insert Into #liste Values(@acy_nf_3, 0, 0, 0, @conretctr_b)

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_4)
            Insert Into #liste Values(@acy_nf_4, 0, 0, 0, @conretctr_b)

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_5)
            Insert Into #liste Values(@acy_nf_5, 0, 0, 0, @conretctr_b)

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_6)
            Insert Into #liste Values(@acy_nf_6, 0, 0, 0, @conretctr_b)

        If Not Exists (Select Null 
                       From   #liste
			           Where ACY_NF = @acy_nf_7)
            Insert Into #liste Values(@acy_nf_7, 0, 0, 0, @conretctr_b)
    End



/*--------------------------------------------------*/
/* Select final                                     */
/*--------------------------------------------------*/

Select ACY_NF,
       AUTUPD_B,
       COMACC_B,
       CMT_NT,
       CONRETCTR_B
From   #liste 
Order By ACY_NF

/*--------------------------------------------------*/
/* Destruction des tables temporaires               */
/*--------------------------------------------------*/

fin:
Drop Table #TLIFDRI

Return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSDRI02', 'PsLIFDRI_02', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsLIFDRI_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsLIFDRI_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsLIFDRI_02 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PsLIFDRI_02
 */

GRANT EXECUTE ON dbo.PsLIFDRI_02 TO GOMEGA
go

